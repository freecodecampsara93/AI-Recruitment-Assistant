-- ============================================================
-- AI Recruitment Assistant: human approval setup
-- Run this in the Supabase SQL Editor after the candidates table exists.
-- ============================================================

-- 1) Pending requests created by the agent.
--    The agent can only INSERT here. It cannot change candidates or send emails.
--    Status flow: pending -> awaiting (sent to HR) -> done / rejected
CREATE TABLE IF NOT EXISTS pending_actions (
  id SERIAL PRIMARY KEY,
  action TEXT NOT NULL CHECK (action IN ('update_status', 'send_email')),
  candidate_id INT NOT NULL REFERENCES candidates(id),
  payload JSONB NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'awaiting', 'approved', 'rejected', 'done')),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 2) Only allow valid candidate statuses.
--    The database rejects any other value, even if the model sends it.
--    Check existing data first:  SELECT DISTINCT status FROM candidates;
ALTER TABLE candidates
  ADD CONSTRAINT candidates_status_check
  CHECK (status IN ('new', 'screening', 'interview', 'rejected', 'hired'));
