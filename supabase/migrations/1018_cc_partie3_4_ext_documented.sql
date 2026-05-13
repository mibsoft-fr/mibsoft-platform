-- SSIAP 1 partie 3 « Installations techniques » (+26 q) and partie 4
-- « Rôle et missions agent SSIAP 1 » (+26 q) extension batches.
--
-- These were applied directly via Supabase MCP execute_sql in the same
-- session. This file documents the schema/seed change for git traceability.
--
-- Distribution per partie after this batch:
--   partie3 : 15 (starter) + 26 (this batch) = 41 challenge ✅
--   partie4 : 14 (starter) + 26 (this batch) = 40 challenge ✅
--
-- Prefixes for the rows: ssiap1-hc-p3-ext-q1..q26 / ssiap1-hc-p4-ext-q1..q26
-- All tagged ['handcrafted','starter-pack','partie3-ext' or 'partie4-ext']
-- Pool = 'challenge'.
--
-- See chat session for the full content (cc_questions, options, sub-tables).
-- The DB is the source of truth; this file is informational only.

select 'partie3 batch extension applied via mcp' as note;
select 'partie4 batch extension applied via mcp' as note;
