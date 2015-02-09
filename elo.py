#!/usr/bin/env python
# -*- coding: utf-8 -*-

from datetime import date, timedelta
import psycopg2
import sys

conn = psycopg2.connect(database="vagrant")
cursor = conn.cursor()

teams = {}
elo_rows = []

cursor.execute("SELECT team_id, team_name FROM soccerdome.teams")
for row in cursor.fetchall():
    teams[row[0]] = {"name": row[1], "elo": 1000, "games": 0}

cursor.execute("SELECT game_id, home_team, home_score, away_team, away_score FROM soccerdome.games ORDER BY game_date")
for row in cursor.fetchall():
    home_team = teams[row[1]]
    away_team = teams[row[3]]

    home_team["games"] += 1
    away_team["games"] += 1

    home_result = cmp(row[2], row[4]) * 0.5 + 0.5
    away_result = 1 - home_result

    home_expected_result = 1 / float(pow(10, float(away_team["elo"] - home_team["elo"]) / 400) + 1)
    away_expected_result = 1 - home_expected_result

    if abs(row[2] - row[4]) <= 1:
        diff_index = 1.0
    elif abs(row[2] - row[4]) == 2:
        diff_index = 1.5
    else:
        diff_index = float(11 + abs(row[2] - row[4])) / 8

    home_change = int(20 * diff_index * (home_result - home_expected_result))
    away_change = 0 - home_change

    elo_rows.append([row[1], row[0], home_team["elo"], home_team["elo"] + home_change])
    elo_rows.append([row[3], row[0], away_team["elo"], away_team["elo"] + away_change])

    home_team["elo"] += home_change
    away_team["elo"] += away_change


cursor.execute("TRUNCATE TABLE soccerdome.elo_ratings")

for row in elo_rows:
    cursor.execute("INSERT INTO soccerdome.elo_ratings(team_id, game_id, rating_before, rating_after) VALUES(%s, %s, %s, %s)", row)

conn.commit()
