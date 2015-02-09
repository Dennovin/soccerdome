set search_path = vagrant, public, soccerdome;

-- all ratings as of a date
select l.league_name as "League", t.team_name as "Team Name", r.rating_after as "Rating"
from games g
  join leagues l on (g.league_id = l.league_id)
  join teams t on (g.away_team = t.team_id or g.home_team = t.team_id)
  join elo_ratings r on (g.game_id = r.game_id and t.team_id = r.team_id)
where g.game_date = '2015-01-25'
order by r.rating_after desc;


-- season end dates
select distinct max(g.game_date)
from leagues l
  left join games g on (l.league_id = g.league_id)
group by l.league_id
order by max(g.game_date);


-- biggest upsets
select g.game_date as "Game Date",
  h.team_name || ' (' || hr.rating_before || ')' as "Home Team",
  a.team_name || ' (' || ar.rating_before || ')' as "Away Team",
  g.home_score || '-' || g.away_score as "Score",
  ((case when g.home_score = g.away_score then 0 else (g.home_score - g.away_score) / abs(g.home_score - g.away_score) end) * (ar.rating_before - hr.rating_before)) as "Rating Difference",
  to_char(100 / (pow(10, ((case when g.home_score = g.away_score then 0 else (g.home_score - g.away_score) / abs(g.home_score - g.away_score) end) * (ar.rating_before - hr.rating_before))::float / 400) + 1), '99.00') || '%' as "Chance to Win"
from games g
  join elo_ratings hr on (g.game_id = hr.game_id and g.home_team = hr.team_id)
  join elo_ratings ar on (g.game_id = ar.game_id and g.away_team = ar.team_id)
  join teams h on (g.home_team = h.team_id)
  join teams a on (g.away_team = a.team_id)
where (select count(1) from games hg where g.home_team in (hg.home_team, hg.away_team) and hg.game_date < g.game_date) > 5
  and (select count(1) from games ag where g.away_team in (ag.home_team, ag.away_team) and ag.game_date < g.game_date) > 5
order by ((case when g.home_score = g.away_score then 0 else (g.home_score - g.away_score) / abs(g.home_score - g.away_score) end) * (ar.rating_before - hr.rating_before)) desc
limit 20;
