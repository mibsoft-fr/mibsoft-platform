-- =====================================================================
-- Challenge Cup SSIAP — Initial schema (cc_ prefixed for MIB instance)
-- =====================================================================

create extension if not exists pgcrypto;
create extension if not exists "uuid-ossp";

create table public.cc_modules (
  id            text primary key,
  level         smallint not null check (level between 1 and 3),
  title         text not null,
  subtitle      text,
  icon          text default '📋',
  color         text default 'from-blue-500 to-indigo-600',
  display_order integer not null default 0,
  is_active     boolean not null default true,
  created_at    timestamptz default now()
);

create index cc_modules_level_idx on public.cc_modules(level, display_order);

create table public.cc_questions (
  id              text primary key,
  module_id       text not null references public.cc_modules(id) on delete cascade,
  type            text not null check (type in (
                    'quiz','true-false','multiple-select','sequence','ranking',
                    'matching','fill-blank','find-intruder','scenario',
                    'categories','decision','pictogram'
                  )),
  title           text,
  question        text not null,
  scenario        text,
  situation       text,
  explanation     text,
  correct_answer  integer,
  correct_answers integer[],
  correct_order   integer[],
  correct_blanks  text[],
  correct_path    integer[],
  word_bank       text[],
  sentence        text,
  image_url       text,
  video_url       text,
  difficulty      smallint default 1 check (difficulty between 1 and 3),
  tags            text[] default '{}',
  status          text default 'published' check (status in ('draft','published','archived')),
  is_active       boolean default true,
  display_order   integer default 0,
  created_at      timestamptz default now(),
  updated_at      timestamptz default now()
);

create index cc_questions_module_idx on public.cc_questions(module_id, display_order);
create index cc_questions_type_idx   on public.cc_questions(type);
create index cc_questions_active_idx on public.cc_questions(is_active) where is_active;

create table public.cc_question_options (
  id           bigserial primary key,
  question_id  text not null references public.cc_questions(id) on delete cascade,
  option_index integer not null,
  option_text  text not null,
  unique (question_id, option_index)
);

create table public.cc_question_items (
  id          bigserial primary key,
  question_id text not null references public.cc_questions(id) on delete cascade,
  item_index  integer not null,
  item_text   text not null,
  unique (question_id, item_index)
);

create table public.cc_question_pairs (
  id          bigserial primary key,
  question_id text not null references public.cc_questions(id) on delete cascade,
  pair_index  integer not null,
  left_text   text not null,
  right_text  text not null,
  unique (question_id, pair_index)
);

create table public.cc_question_categories (
  id              bigserial primary key,
  question_id     text not null references public.cc_questions(id) on delete cascade,
  category_index  integer not null,
  category_id     text not null,
  category_label  text not null,
  unique (question_id, category_index)
);

create table public.cc_question_category_items (
  id               bigserial primary key,
  question_id      text not null references public.cc_questions(id) on delete cascade,
  item_index       integer not null,
  item_text        text not null,
  correct_category text not null,
  unique (question_id, item_index)
);

create table public.cc_question_decision_steps (
  id          bigserial primary key,
  question_id text not null references public.cc_questions(id) on delete cascade,
  step_index  integer not null,
  step_question text not null,
  options     jsonb not null default '[]'::jsonb,
  unique (question_id, step_index)
);

create table public.cc_sessions (
  id                uuid primary key default uuid_generate_v4(),
  session_code      text unique not null,
  level             smallint not null check (level between 1 and 3),
  status            text default 'waiting' check (status in ('waiting','playing','correction','finished')),
  current_module_id text references public.cc_modules(id),
  current_q_idx     integer default 0,
  opened_modules    text[] default '{}',
  config            jsonb not null default '{"qpb": 8, "activeModules": [], "qtypeFilters": [], "diffFilters": []}'::jsonb,
  randomized_games  jsonb default '[]'::jsonb,
  question_started_at timestamptz,
  answers_count       integer default 0,
  created_at        timestamptz default now(),
  finished_at       timestamptz,
  supervisor_id     uuid
);

create index cc_sessions_code_idx   on public.cc_sessions(session_code);
create index cc_sessions_status_idx on public.cc_sessions(status);

create table public.cc_teams (
  id              uuid primary key default uuid_generate_v4(),
  session_id      uuid not null references public.cc_sessions(id) on delete cascade,
  name            text not null,
  avatar          text default '👷',
  score           integer default 0,
  total_correct   integer default 0,
  total_answered  integer default 0,
  has_answered    boolean default false,
  online          boolean default true,
  joined_at       timestamptz default now(),
  last_seen_at    timestamptz default now(),
  unique (session_id, name)
);

create index cc_teams_session_idx on public.cc_teams(session_id);

create table public.cc_team_answers (
  id              uuid primary key default uuid_generate_v4(),
  session_id      uuid not null references public.cc_sessions(id) on delete cascade,
  team_id         uuid not null references public.cc_teams(id) on delete cascade,
  question_id     text not null references public.cc_questions(id),
  module_id       text not null references public.cc_modules(id),
  q_idx           integer not null,
  answer          jsonb,
  is_correct      boolean default false,
  answer_time_ms  integer default 0,
  base_points     integer default 0,
  speed_bonus     integer default 0,
  total_points    integer default 0,
  answered_at     timestamptz default now(),
  unique (team_id, question_id)
);

create index cc_team_answers_session_idx on public.cc_team_answers(session_id);
create index cc_team_answers_team_idx    on public.cc_team_answers(team_id);

create table public.cc_supervisors (
  id            uuid primary key default gen_random_uuid(),
  email         text unique not null,
  password_hash text not null,
  firstname     text,
  lastname      text,
  status        text default 'active' check (status in ('active','suspended','archived')),
  plan          text default 'DEMO',
  license_key   text,
  created_at    timestamptz default now()
);

create table public.cc_logs (
  id          bigserial primary key,
  session_id  uuid references public.cc_sessions(id) on delete set null,
  level       text default 'info' check (level in ('info','warn','error','success','debug')),
  category    text,
  message     text,
  team_name   text,
  metadata    jsonb default '{}'::jsonb,
  created_at  timestamptz default now()
);

create index cc_logs_session_idx on public.cc_logs(session_id, created_at desc);

create or replace function public.cc_verify_supervisor(p_email text, p_password text)
returns table (id uuid, email text, firstname text, lastname text, plan text)
language plpgsql
security definer
set search_path = public, extensions
as $$
begin
  return query
  select s.id, s.email, s.firstname, s.lastname, s.plan
  from public.cc_supervisors s
  where s.email = p_email
    and s.status = 'active'
    and s.password_hash = extensions.crypt(p_password, s.password_hash);
end;
$$;

revoke all on function public.cc_verify_supervisor(text, text) from public;
grant execute on function public.cc_verify_supervisor(text, text) to anon, authenticated;

create or replace function public.cc_create_session(
  p_level smallint,
  p_config jsonb
)
returns table (id uuid, session_code text)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_code text;
  v_id   uuid;
begin
  loop
    v_code := upper(substr(md5(random()::text), 1, 6));
    exit when not exists (select 1 from public.cc_sessions where session_code = v_code);
  end loop;

  insert into public.cc_sessions (session_code, level, config)
  values (v_code, p_level, coalesce(p_config, '{}'::jsonb))
  returning cc_sessions.id into v_id;

  return query select v_id, v_code;
end;
$$;

grant execute on function public.cc_create_session(smallint, jsonb) to anon, authenticated;

alter table public.cc_modules                 enable row level security;
alter table public.cc_questions               enable row level security;
alter table public.cc_question_options        enable row level security;
alter table public.cc_question_items          enable row level security;
alter table public.cc_question_pairs          enable row level security;
alter table public.cc_question_categories     enable row level security;
alter table public.cc_question_category_items enable row level security;
alter table public.cc_question_decision_steps enable row level security;
alter table public.cc_sessions                enable row level security;
alter table public.cc_teams                   enable row level security;
alter table public.cc_team_answers            enable row level security;
alter table public.cc_supervisors             enable row level security;
alter table public.cc_logs                    enable row level security;

create policy "cc_modules read"            on public.cc_modules                 for select using (is_active);
create policy "cc_questions read"          on public.cc_questions               for select using (is_active and status = 'published');
create policy "cc_options read"            on public.cc_question_options        for select using (true);
create policy "cc_items read"              on public.cc_question_items          for select using (true);
create policy "cc_pairs read"              on public.cc_question_pairs          for select using (true);
create policy "cc_categories read"         on public.cc_question_categories     for select using (true);
create policy "cc_cat items read"          on public.cc_question_category_items for select using (true);
create policy "cc_decision steps read"     on public.cc_question_decision_steps for select using (true);

create policy "cc_sessions read"  on public.cc_sessions for select using (true);
create policy "cc_sessions write" on public.cc_sessions for update using (true) with check (true);

create policy "cc_teams read"   on public.cc_teams for select using (true);
create policy "cc_teams insert" on public.cc_teams for insert with check (true);
create policy "cc_teams update" on public.cc_teams for update using (true) with check (true);

create policy "cc_team_answers read"   on public.cc_team_answers for select using (true);
create policy "cc_team_answers insert" on public.cc_team_answers for insert with check (true);

create policy "cc_logs read"   on public.cc_logs for select using (true);
create policy "cc_logs insert" on public.cc_logs for insert with check (true);

alter publication supabase_realtime add table public.cc_sessions;
alter publication supabase_realtime add table public.cc_teams;
alter publication supabase_realtime add table public.cc_team_answers;
