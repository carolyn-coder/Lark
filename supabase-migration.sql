-- ============================================================
-- Summer 2026 Schedule — Supabase migration
-- Paste this ENTIRE file into Supabase → SQL Editor → New query, then click 'Run'.
-- Safe to re-run: tables drop + recreate.
-- ============================================================

-- 1. DROP existing (safe re-run)
DROP TABLE IF EXISTS messages CASCADE;
DROP TABLE IF EXISTS entries CASCADE;

-- 2. Schema

CREATE TABLE entries (
  id              text PRIMARY KEY,
  family_id       text NOT NULL,
  date            date NOT NULL,
  type            text NOT NULL CHECK (type IN ('hosting','asking','going','busy')),
  location        text,
  start_time      time,
  end_time        time,
  notes           text,
  recurrence_id   text,
  finalized       boolean DEFAULT false,
  responses       jsonb DEFAULT '{}'::jsonb,
  created_by      uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at      timestamptz DEFAULT now(),
  updated_at      timestamptz DEFAULT now()
);

CREATE TABLE messages (
  id              text PRIMARY KEY,
  family_id       text NOT NULL,
  text            text NOT NULL,
  created_by      uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at      timestamptz DEFAULT now()
);

-- helpful indexes
CREATE INDEX entries_date_idx          ON entries(date);
CREATE INDEX entries_family_idx        ON entries(family_id);
CREATE INDEX entries_recurrence_idx    ON entries(recurrence_id) WHERE recurrence_id IS NOT NULL;
CREATE INDEX messages_created_at_idx   ON messages(created_at);

-- updated_at trigger for entries
CREATE OR REPLACE FUNCTION set_updated_at() RETURNS trigger AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER entries_updated_at
  BEFORE UPDATE ON entries
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- 3. Row-Level Security
-- Anyone signed in can read + write everything.
-- The auth allow-list (Supabase Dashboard → Auth → Users) controls who can sign in.

ALTER TABLE entries  ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "auth_all_entries"  ON entries  FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "auth_all_messages" ON messages FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- 4. Realtime — turn on so the app gets live updates
ALTER PUBLICATION supabase_realtime ADD TABLE entries;
ALTER PUBLICATION supabase_realtime ADD TABLE messages;

-- DONE.
-- Next: copy your project URL + anon key from Supabase → Project Settings → API into the app.
