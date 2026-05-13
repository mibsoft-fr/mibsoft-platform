-- Server-side resync of Challenge Cup SSIAP data from source project
-- uojhwuwplpodgnwvwvmm.supabase.co into the cc_* tables on this MIB
-- project. Uses the http extension to fetch JSON over PostgREST, then
-- jsonb_populate_recordset to insert into the destination tables.
--
-- Why this approach: a JSON dump+restore of 1203 questions + 5125 sub-rows
-- (~5 MB total) is too large to round-trip via execute_sql without saturating
-- the agent/client context. Doing it server-side avoids that bottleneck.
--
-- Idempotency: this migration assumes cc_modules / cc_questions / cc_question_*
-- have been truncated (see 1031). Re-applying it on top of populated tables
-- will throw PK violations.
--
-- Anon key for source project is a public publishable JWT (legacy anon key),
-- safe to commit. It only grants read access to the source's public
-- catalogue tables under their existing RLS policies.
do $$
declare
  v_apikey text := 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVvamh3dXdwbHBvZGdud3Z3dm1tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc5MjQ4ODgsImV4cCI6MjA5MzUwMDg4OH0.Lsb50DFGGcOkzevcdKvbxkCbf4jlLTk8KkUVTfAfCuY';
  v_base   text := 'https://uojhwuwplpodgnwvwvmm.supabase.co/rest/v1/';
  v_chunk  int  := 1000;
  v_tables text[] := array[
    'modules|public.cc_modules|display_order',
    'questions|public.cc_questions|id',
    'question_options|public.cc_question_options|id',
    'question_items|public.cc_question_items|id',
    'question_pairs|public.cc_question_pairs|id',
    'question_categories|public.cc_question_categories|id',
    'question_category_items|public.cc_question_category_items|id',
    'question_decision_steps|public.cc_question_decision_steps|id'
  ];
  v_tdef text;
  v_parts text[];
  v_src text;
  v_dest text;
  v_order text;
  v_offset int;
  v_rows jsonb;
  v_status int;
  v_count int;
  v_total int;
  v_url text;
begin
  foreach v_tdef in array v_tables loop
    v_parts := string_to_array(v_tdef, '|');
    v_src   := v_parts[1];
    v_dest  := v_parts[2];
    v_order := v_parts[3];
    v_offset := 0;
    v_total  := 0;

    loop
      v_url := v_base || v_src
            || '?select=*&order=' || v_order
            || '&limit=' || v_chunk
            || '&offset=' || v_offset;

      select status, content::jsonb
        into v_status, v_rows
        from extensions.http((
          'GET',
          v_url,
          array[
            extensions.http_header('apikey', v_apikey),
            extensions.http_header('Authorization', 'Bearer ' || v_apikey),
            extensions.http_header('Accept', 'application/json')
          ],
          null, null
        )::extensions.http_request);

      if v_status <> 200 then
        raise exception 'HTTP % fetching %: %', v_status, v_src, v_rows::text;
      end if;

      v_count := coalesce(jsonb_array_length(v_rows), 0);
      exit when v_count = 0;

      execute format(
        'insert into %s select * from jsonb_populate_recordset(null::%s, $1)',
        v_dest, v_dest
      ) using v_rows;

      v_total := v_total + v_count;
      exit when v_count < v_chunk;
      v_offset := v_offset + v_chunk;
    end loop;

    raise notice 'Synced %: % rows', v_dest, v_total;
  end loop;

  -- Bump sequences for sub-tables (their bigint id PKs were preserved verbatim)
  perform setval(pg_get_serial_sequence('public.cc_question_options','id'),         greatest(coalesce((select max(id) from public.cc_question_options),1),1));
  perform setval(pg_get_serial_sequence('public.cc_question_items','id'),           greatest(coalesce((select max(id) from public.cc_question_items),1),1));
  perform setval(pg_get_serial_sequence('public.cc_question_pairs','id'),           greatest(coalesce((select max(id) from public.cc_question_pairs),1),1));
  perform setval(pg_get_serial_sequence('public.cc_question_categories','id'),      greatest(coalesce((select max(id) from public.cc_question_categories),1),1));
  perform setval(pg_get_serial_sequence('public.cc_question_category_items','id'),  greatest(coalesce((select max(id) from public.cc_question_category_items),1),1));
  perform setval(pg_get_serial_sequence('public.cc_question_decision_steps','id'),  greatest(coalesce((select max(id) from public.cc_question_decision_steps),1),1));
end $$;
