-- Enable the synchronous HTTP client extension so we can pull data
-- from the source Supabase project (uojhwuwplpodgnwvwvmm) directly
-- inside the destination database, avoiding round-trips through any
-- client or agent context.
create extension if not exists http with schema extensions;
