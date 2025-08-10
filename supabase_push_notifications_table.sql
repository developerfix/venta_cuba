-- Create push_notifications table in your Supabase dashboard
-- Go to SQL Editor and run this query:

CREATE TABLE IF NOT EXISTS push_notifications (
  id BIGSERIAL PRIMARY KEY,
  recipient_user_id TEXT NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  data JSONB DEFAULT '{}',
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_push_notifications_recipient_user_id 
ON push_notifications(recipient_user_id);

CREATE INDEX IF NOT EXISTS idx_push_notifications_is_read 
ON push_notifications(is_read);

-- Enable Row Level Security (optional, for security)
-- Note: You may want to disable RLS for simplicity during testing
-- ALTER TABLE push_notifications ENABLE ROW LEVEL SECURITY;

-- Simple policies that allow all operations (disable RLS for easier testing)
-- If you want security, uncomment the RLS line above and use these policies:
-- CREATE POLICY "Allow all select" ON push_notifications FOR SELECT USING (true);
-- CREATE POLICY "Allow all insert" ON push_notifications FOR INSERT WITH CHECK (true);  
-- CREATE POLICY "Allow all update" ON push_notifications FOR UPDATE USING (true);
-- CREATE POLICY "Allow all delete" ON push_notifications FOR DELETE USING (true);