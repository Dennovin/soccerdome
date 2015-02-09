#!/usr/bin/env python
# -*- coding: utf-8 -*-

from bs4 import BeautifulSoup
from datetime import date, timedelta
import psycopg2
import re
import requests
import sys

current_date = date.today() - timedelta(days=date.today().isoweekday())

conn = psycopg2.connect(database="vagrant")
cursor = conn.cursor()
failures = 0

cursor.execute("SELECT MAX(game_date) FROM soccerdome.games")
row = cursor.fetchone()
max_date_in_db = row[0]

while current_date > max_date_in_db:
    print "Getting results for {:%Y-%m-%d}...".format(current_date)

    url = "http://soccerdome-2.ezleagues.ezfacility.com/schedule.aspx?facility_id=50&d={:%m/%d/%Y}".format(current_date)
    req = requests.get(url)
    soup = BeautifulSoup(req.text)
    table = soup.find(id="ctl00_C_Schedule1_GridView1")

    if table.find("tr", class_="EmptyDataRowStyle"):
        failures += 1
        current_date -= timedelta(days=7)

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

        m = re.match("(\d+)\s*\-\s*(\d+)", score)
        if m is None:
            continue

        away_score = m.group(1)
        home_score = m.group(2)

        cursor.execute("INSERT INTO soccerdome.leagues(league_id, league_name) VALUES(%s, %s)", [league_id, league_name])
        cursor.execute("INSERT INTO soccerdome.teams(team_name) VALUES (%s), (%s)", [away_team, home_team])

        cursor.execute("""
                       INSERT INTO soccerdome.games(league_id, game_date, home_team, home_score, away_team, away_score)
                       SELECT %s, %s, h.team_id, %s, a.team_id, %s
                       FROM soccerdome.teams h, soccerdome.teams a
                       WHERE h.team_name = %s AND a.team_name = %s
                       """,
                       [league_id, current_date, home_score, away_score, home_team, away_team])

    conn.commit()
    current_date -= timedelta(days=7)

