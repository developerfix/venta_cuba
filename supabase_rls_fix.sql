-- Supabase RLS Fix Script
-- Run this in your Supabase SQL Editor to resolve RLS warnings

-- First, check current RLS status
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('chats', 'messages', 'user_presence', 'device_tokens');

-- Enable Row Level Security on all chat-related tables
ALTER TABLE public.chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_presence ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.device_tokens ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON public.chats;
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON public.messages;
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON public.user_presence;
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON public.device_tokens;

-- Since you don't use Supabase authentication, create policies that allow all access
-- Option 1: Allow all access (simple but less secure)
CREATE POLICY "Allow all operations" ON public.chats
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations" ON public.messages
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations" ON public.user_presence
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations" ON public.device_tokens
  FOR ALL USING (true) WITH CHECK (true);

-- Verify RLS is now enabled
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('chats', 'messages', 'user_presence', 'device_tokens');

-- List all policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename IN ('chats', 'messages', 'user_presence', 'device_tokens');