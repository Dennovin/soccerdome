set search_path = vagrant, public, soccerdome;

-- all ratings as of a date
select l.league_name as "League", t.team_name as "Team Name", r.rating_after as "Rating",
  (select count(1) from games bg where t.team_id in (bg.home_team, bg.away_team) and date_trunc('day', bg.game_date) <= date_trunc('day', g.game_date)) as "Games Played"
from games g
  join leagues l on (g.league_id = l.league_id)
  join teams t on (t.team_id in (g.home_team, g.away_team))
  join elo_ratings r on (g.game_id = r.game_id and t.team_id = r.team_id)
where date_trunc('day', g.game_date) = '2015-01-25'
order by r.rating_after desc;


-- leagues with start/end dates
select l.league_id, l.league_name, min(date_trunc('day', g.game_date)), max(date_trunc('day', g.game_date))
from leagues l
  left join games g on (l.league_id = g.league_id)
group by l.league_id
order by max(date_trunc('day', g.game_date));


-- season end dates
select distinct max(date_trunc('day', g.game_date))
from leagues l
  left join games g on (l.league_id = g.league_id)
group by l.league_id
order by max(date_trunc('day', g.game_date));


-- biggest upsets
select date_trunc('day', g.game_date) as "Game Date",
  h.team_name || ' (' || hr.rating_before || ')' as "Home Team",
  a.team_name || ' (' || ar.rating_before || ')' as "Away Team",
  g.home_score || '-' || g.away_score as "Score",
  (sign(g.home_score - g.away_score) * (ar.rating_before - hr.rating_before)) as "Rating Difference",
  to_char(100 / (pow(10, (sign(g.home_score - g.away_score) * (ar.rating_before - hr.rating_before))::float / 400) + 1), '99.00') || '%' as "Chance to Win"
from games g
  join elo_ratings hr on (g.game_id = hr.game_id and g.home_team = hr.team_id)
  join elo_ratings ar on (g.game_id = ar.game_id and g.away_team = ar.team_id)
  join teams h on (g.home_team = h.team_id)
  join teams a on (g.away_team = a.team_id)
where (select count(1) from games hg where g.home_team in (hg.home_team, hg.away_team) and date_trunc('day', hg.game_date) < date_trunc('day', g.game_date)) > 5
  and (select count(1) from games ag where g.away_team in (ag.home_team, ag.away_team) and date_trunc('day', ag.game_date) < date_trunc('day', g.game_date)) > 5
order by 5 desc
limit 20;


-- worst odds
select date_trunc('day', g.game_date) as "Game Date",
  h.team_name || ' (' || hr.rating_before || ')' as "Home Team",
  a.team_name || ' (' || ar.rating_before || ')' as "Away Team",
  g.home_score || '-' || g.away_score as "Score",
  abs(ar.rating_before - hr.rating_before) as "Rating Difference",
  to_char(100 / (pow(10, abs(ar.rating_before - hr.rating_before)::float / 400) + 1), '99.00') || '%' as "Chance to Win"
from games g
  join elo_ratings hr on (g.game_id = hr.game_id and g.home_team = hr.team_id)
  join elo_ratings ar on (g.game_id = ar.game_id and g.away_team = ar.team_id)
  join teams h on (g.home_team = h.team_id)
  join teams a on (g.away_team = a.team_id)
where (select count(1) from games hg where g.home_team in (hg.home_team, hg.away_team) and date_trunc('day', hg.game_date) < date_trunc('day', g.game_date)) > 5
  and (select count(1) from games ag where g.away_team in (ag.home_team, ag.away_team) and date_trunc('day', ag.game_date) < date_trunc('day', g.game_date)) > 5
order by 5 desc
limit 20;


-- biggest blowouts
select date_trunc('day', g.game_date) as "Game Date",
  h.team_name || ' (' || hr.rating_before || ')' as "Home Team",
  a.team_name || ' (' || ar.rating_before || ')' as "Away Team",
  g.home_score || '-' || g.away_score as "Score",
  abs(ar.rating_before - hr.rating_before) as "Rating Difference",
  to_char(100 / (pow(10, abs(ar.rating_before - hr.rating_before)::float / 400) + 1), '99.00') || '%' as "Chance to Win"
from games g
  join elo_ratings hr on (g.game_id = hr.game_id and g.home_team = hr.team_id)
  join elo_ratings ar on (g.game_id = ar.game_id and g.away_team = ar.team_id)
  join teams h on (g.home_team = h.team_id)
  join teams a on (g.away_team = a.team_id)
where (select count(1) from games hg where g.home_team in (hg.home_team, hg.away_team) and date_trunc('day', hg.game_date) < date_trunc('day', g.game_date)) > 5
  and (select count(1) from games ag where g.away_team in (ag.home_team, ag.away_team) and date_trunc('day', ag.game_date) < date_trunc('day', g.game_date)) > 5
order by abs(g.home_score - g.away_score) desc
limit 20;


-- highest scoring
select date_trunc('day', g.game_date) as "Game Date",
  h.team_name || ' (' || hr.rating_before || ')' as "Home Team",
  a.team_name || ' (' || ar.rating_before || ')' as "Away Team",
  g.home_score || '-' || g.away_score as "Score",
  abs(ar.rating_before - hr.rating_before) as "Rating Difference",
  to_char(100 / (pow(10, abs(ar.rating_before - hr.rating_before)::float / 400) + 1), '99.00') || '%' as "Chance to Win"
from games g
  join elo_ratings hr on (g.game_id = hr.game_id and g.home_team = hr.team_id)
  join elo_ratings ar on (g.game_id = ar.game_id and g.away_team = ar.team_id)
  join teams h on (g.home_team = h.team_id)
  join teams a on (g.away_team = a.team_id)
where (select count(1) from games hg where g.home_team in (hg.home_team, hg.away_team) and date_trunc('day', hg.game_date) < date_trunc('day', g.game_date)) > 5
  and (select count(1) from games ag where g.away_team in (ag.home_team, ag.away_team) and date_trunc('day', ag.game_date) < date_trunc('day', g.game_date)) > 5
order by g.home_score + g.away_score desc
limit 20;


-- all results for a team
select date_trunc('day', g.game_date) as "Game Date",
  o.team_name as "Opponent",
  to_char(100 / (pow(10, (ro.rating_before - r.rating_before)::float / 400) + 1), '99.00') || '%' as "Chance to Win",
  (case when t.team_id = g.home_team then g.home_score || '-' || g.away_score else g.away_score || '-' || g.home_score end) as "Score",
  to_char(r.rating_after - r.rating_before, 'S99') as "Rating Change",
  r.rating_after as "New Rating"
from teams t
  join games g on (t.team_id in (g.home_team, g.away_team))
  join teams o on (o.team_id in (g.home_team, g.away_team) and o.team_id != t.team_id)
  join elo_ratings r on (t.team_id = r.team_id and g.game_id = r.game_id)
  join elo_ratings ro on (o.team_id = ro.team_id and g.game_id = ro.game_id)
where t.team_name = 'Guarani'
order by date_trunc('day', g.game_date)


-- rating difference vs. score difference, for one season
select g.game_id as "Game ID", date_trunc('day', g.game_date) as "Date",
  abs(hr.rating_before - ar.rating_before) as "Rating Difference",
  (g.home_score - g.away_score) * sign(hr.rating_before - ar.rating_before + 0.001) as "Score Difference"
from games g
  join elo_ratings hr on (g.game_id = hr.game_id and g.home_team = hr.team_id)
  join elo_ratings ar on (g.game_id = ar.game_id and g.away_team = ar.team_id)
where (select count(1) from games hg where g.home_team in (hg.home_team, hg.away_team) and date_trunc('day', hg.game_date) < date_trunc('day', g.game_date)) >= 9
  and (select count(1) from games ag where g.away_team in (ag.home_team, ag.away_team) and date_trunc('day', ag.game_date) < date_trunc('day', g.game_date)) >= 9
  and g.league_id in (212319, 212365, 212533, 212534)
order by date_trunc('day', g.game_date);


-- team record and rating change by season
with w as (
  select distinct on (g.league_id)
    g.league_id,
    min(date_trunc('day', g.game_date)) over (partition by g.league_id) as start_date,
    max(date_trunc('day', g.game_date)) over (partition by g.league_id) as end_date,
    sum(case when (case when t.team_id = g.home_team then g.home_score else g.away_score end) > least(g.home_score, g.away_score) then 1 else 0 end) over (partition by g.league_id) as wins,
    sum(case when (case when t.team_id = g.home_team then g.home_score else g.away_score end) < greatest(g.home_score, g.away_score) then 1 else 0 end) over (partition by g.league_id) as losses,
    sum(case when g.home_score = g.away_score then 1 else 0 end) over (partition by g.league_id) as draws,
    sum(case when t.team_id = g.home_team then g.home_score - g.away_score else g.away_score - g.home_score end) over (partition by g.league_id) as gd,
    first_value(r.rating_after) over (partition by g.league_id order by date_trunc('day', g.game_date) desc) as rating_after,
    first_value(r.rating_after) over (partition by g.league_id order by date_trunc('day', g.game_date) desc) - first_value(r.rating_after) over (partition by g.league_id order by date_trunc('day', g.game_date)) as rating_change
  from teams t
    join games g on (t.team_id in (g.home_team, g.away_team))
    join elo_ratings r on (t.team_id = r.team_id and g.game_id = r.game_id)
  where t.team_id = 7
)
select * from w
union all
select null, null, null, sum(w.wins), sum(w.losses), sum(w.draws), sum(w.gd), null, null from w;

