-- Supabase RLS Secure Fix Script (Alternative)
-- Run this if you want more secure policies

-- Enable Row Level Security
ALTER TABLE public.chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_presence ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.device_tokens ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON public.chats;
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON public.messages;
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON public.user_presence;
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON public.device_tokens;

-- More secure policies based on your own user IDs
-- Users can only see chats where they are sender or recipient
CREATE POLICY "Users can access their own chats" ON public.chats
  FOR ALL USING (
    sender_id = current_setting('app.current_user_id', true) OR 
    send_to_id = current_setting('app.current_user_id', true)
  );

-- Users can only see messages in chats they participate in
CREATE POLICY "Users can access messages in their chats" ON public.messages
  FOR ALL USING (
    chat_id IN (
      SELECT id FROM public.chats 
      WHERE sender_id = current_setting('app.current_user_id', true) 
         OR send_to_id = current_setting('app.current_user_id', true)
    )
  );

-- Users can manage their own presence
CREATE POLICY "Users can manage their presence" ON public.user_presence
  FOR ALL USING (user_id = current_setting('app.current_user_id', true));

-- Users can manage their own device tokens
CREATE POLICY "Users can manage their device tokens" ON public.device_tokens
  FOR ALL USING (user_id = current_setting('app.current_user_id', true));

-- Grant usage on schema
GRANT USAGE ON SCHEMA public TO anon, authenticated;

-- Grant table permissions
GRANT ALL ON public.chats TO anon, authenticated;
GRANT ALL ON public.messages TO anon, authenticated;
GRANT ALL ON public.user_presence TO anon, authenticated;
GRANT ALL ON public.device_tokens TO anon, authenticated;