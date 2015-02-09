#!/usr/bin/env python
# -*- coding: utf-8 -*-

import psycopg2

conn = psycopg2.connect(database="vagrant")
cursor = conn.cursor()

duplicates = {
    "BST2": [ "BST 2", "Bst2" ],
    "Cobra Kai": [ "Cobra- Kai", "Cobra-Kai" ],
    "Crazy Honeybadgers": [ "Crazy HoneyBadgers" ],
    "Delicia FC": [ "Delicia" ],
    "Dogfunk": [ "Dog Funk" ],
    "Hoco United": [ "Hoco- United" ],
    "Kicking Impossible": [ "Kicking Imposible", "Kicking Impossilbe" ],
    "L-Town United": [ "L - Town United" ],
    "Minions FC": [ "Minions" ],
    "P.I.M.A. FC": [ "P.I.M.A FC" ],
    "Pitch Slap": [ "Pitck Slap" ],
    "Reckless": [ "Recklesss" ],
    "SBS United": [ "S.B.S United", "S.B.S. United" ],
    "Shamrocks": [ "ShamRocks" ],
    "Sloppy Sausages": [ "Sloppy Sausager" ],
    "Trout FC": [ "Trout" ],
    "Water Break": [ "Water break", "Waterbreak" ],
    "We're Not Very Good": [ "We're Not Verry Good" ],
    "Trivets": [ "trivest" ],
    "Joga Bonito": [ "Yoga Bonito" ],
    }

for real_name, bad_spellings in duplicates.items():
    placeholders = ",".join(["%s" for i in bad_spellings])

    cursor.execute("""UPDATE soccerdome.games SET home_team = (SELECT team_id FROM soccerdome.teams WHERE team_name = %s)
                        WHERE home_team IN (SELECT team_id FROM soccerdome.teams WHERE team_name IN ({}))""".format(placeholders),
                   [real_name] + bad_spellings)
    cursor.execute("""UPDATE soccerdome.games SET away_team = (SELECT team_id FROM soccerdome.teams WHERE team_name = %s)
                        WHERE away_team IN (SELECT team_id FROM soccerdome.teams WHERE team_name IN ({}))""".format(placeholders),
                   [real_name] + bad_spellings)

    cursor.execute("DELETE FROM soccerdome.teams WHERE team_name IN ({})".format(placeholders), bad_spellings)

    conn.commit()
