DROP SCHEMA IF EXISTS soccerdome CASCADE;

CREATE SCHEMA soccerdome;

CREATE TABLE soccerdome.teams (
  team_id SERIAL PRIMARY KEY,
  team_name TEXT UNIQUE NOT NULL
);

CREATE RULE teams_ignore_duplicates AS
ON INSERT TO soccerdome.teams
WHERE EXISTS (SELECT 1 FROM soccerdome.teams WHERE team_name = NEW.team_name)
DO INSTEAD NOTHING;

CREATE TABLE soccerdome.leagues (
  league_id INTEGER PRIMARY KEY,
  league_name TEXT NOT NULL
);

CREATE RULE leagues_ignore_duplicates AS
ON INSERT TO soccerdome.leagues
WHERE EXISTS (SELECT 1 FROM soccerdome.leagues WHERE league_id = NEW.league_id)
DO INSTEAD NOTHING;

CREATE TABLE soccerdome.games (
  game_id SERIAL PRIMARY KEY,
  league_id INTEGER,
  game_date DATE,
  home_team INTEGER,
  away_team INTEGER,
  home_score INTEGER,
  away_score INTEGER,
  FOREIGN KEY (league_id) REFERENCES soccerdome.leagues(league_id),
  FOREIGN KEY (home_team) REFERENCES soccerdome.teams(team_id),
  FOREIGN KEY (away_team) REFERENCES soccerdome.teams(team_id)
);

CREATE INDEX ON soccerdome.games(home_team);
CREATE INDEX ON soccerdome.games(away_team);
CREATE INDEX ON soccerdome.games(game_date);

CREATE TABLE soccerdome.elo_ratings (
  rating_id SERIAL PRIMARY KEY,
  team_id INTEGER,
  game_id INTEGER,
  rating_before INTEGER,
  rating_after INTEGER,
  FOREIGN KEY (team_id) REFERENCES soccerdome.teams(team_id),
  FOREIGN KEY (game_id) REFERENCES soccerdome.games(game_id)
);

CREATE INDEX ON soccerdome.elo_ratings(team_id);
CREATE INDEX ON soccerdome.elo_ratings(game_id);
