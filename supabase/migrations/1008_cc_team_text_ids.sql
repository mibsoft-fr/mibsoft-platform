-- The legacy game generates team IDs of the form 'team_<uuid>', which is
-- not a valid uuid. Switch cc_teams.id and cc_team_answers.team_id to text so
-- the shim can pass through the legacy IDs unchanged.

alter table public.cc_team_answers drop constraint cc_team_answers_team_id_fkey;
alter table public.cc_team_answers alter column team_id type text;
alter table public.cc_teams alter column id drop default;
alter table public.cc_teams alter column id type text;
alter table public.cc_team_answers
  add constraint cc_team_answers_team_id_fkey
  foreign key (team_id) references public.cc_teams(id) on delete cascade;
