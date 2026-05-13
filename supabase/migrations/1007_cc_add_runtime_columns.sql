-- Runtime columns required by the live game (mirroring Firebase paths)

alter table public.cc_sessions
  add column if not exists game_status text default 'waiting',
  add column if not exists current_game jsonb,
  add column if not exists current_box_idx integer default -1;

alter table public.cc_teams
  add column if not exists current_answer  jsonb,
  add column if not exists current_is_correct boolean,
  add column if not exists last_points     integer default 0,
  add column if not exists last_speed_bonus integer default 0,
  add column if not exists last_offline_log timestamptz;
