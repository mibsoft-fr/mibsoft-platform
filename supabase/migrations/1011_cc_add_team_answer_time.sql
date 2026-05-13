-- Adds the legacy `answerTime` field as a real column so the score
-- calculation `calculatePointsWithSpeedBonus(true, team.answerTime)` works.
alter table public.cc_teams
  add column if not exists answer_time integer;
