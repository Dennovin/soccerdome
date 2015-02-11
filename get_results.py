#!/usr/bin/env python
# -*- coding: utf-8 -*-

from Config import Config

from bs4 import BeautifulSoup
import datetime
import psycopg2
import pytz
import re
import requests
import sys

db_opts = Config.get("db_opts")
conn = psycopg2.connect(**db_opts)
cursor = conn.cursor()

current_date = datetime.date.today() - datetime.timedelta(days=datetime.date.today().isoweekday())
failures = 0

cursor.execute("SELECT DATE_TRUNC('day', game_date) FROM soccerdome.games GROUP BY 1 HAVING bool_and(complete) ORDER BY 1 DESC LIMIT 1")
row = cursor.fetchone()

if row is None:
    current_date = datetime.date(2013, 01, 20)
else:
    current_date = row[0]

tz = pytz.timezone("US/Eastern")

while True:
    current_date += datetime.timedelta(days=7)

    print "Getting results for {:%Y-%m-%d}...".format(current_date)

    url = "http://soccerdome-2.ezleagues.ezfacility.com/schedule.aspx?facility_id=50&d={:%m/%d/%Y}".format(current_date)
    req = requests.get(url)
    soup = BeautifulSoup(req.text)
    table = soup.find(id="ctl00_C_Schedule1_GridView1")

    if table.find("tr", class_="EmptyDataRowStyle"):
        failures += 1
        if failures >= 5:
            print "No data for the last 5 weeks. Exiting."
            break

        continue

    failures = 0

    rows = table.find_all("tr")
    for row in rows:
        cells = row.find_all("td")
        if not cells:
            continue

        league_name = cells[0].get_text().strip()
        if "Sun Coed" not in league_name and "Sunday Coed" not in league_name:
            continue

        m = re.match("leagues\/(\d+)\/", cells[0].find("a")["href"])
        if m is None:
            continue
        league_id = m.group(1)

        away_team = unicode(cells[1].get_text().strip())
        home_team = unicode(cells[3].get_text().strip())
        score = cells[2].get_text().strip()

        complete = False
        home_score = None
        away_score = None

        m = re.match("(\d+)\s*\-\s*(\d+)", score)
        if m is not None:
            away_score = m.group(1)
            home_score = m.group(2)
            complete = True

        try:
            game_time = datetime.datetime.strptime(cells[4].get_text().strip(), "%I:%M %p").time()
        except ValueError:
            game_time = datetime.time(0, 0)

        game_dt = tz.localize(datetime.datetime.combine(current_date, game_time))

        cursor.execute("INSERT INTO soccerdome.leagues(league_id, league_name) VALUES(%s, %s)", [league_id, league_name])
        cursor.execute("INSERT INTO soccerdome.teams(team_name) VALUES (%s), (%s)", [away_team, home_team])

        cursor.execute("""
                       INSERT INTO soccerdome.games(league_id, game_date, complete, home_team, home_score, away_team, away_score)
                       SELECT %s, %s, %s, h.team_id, %s, a.team_id, %s
                       FROM soccerdome.teams h, soccerdome.teams a
                       WHERE h.team_name = %s AND a.team_name = %s
                       """,
                       [league_id, game_dt, complete, home_score, away_score, home_team, away_team])

    conn.commit()


