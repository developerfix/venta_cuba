-- Supabase RLS Disable Script (Option 3)
-- Run this if you want to completely disable RLS and remove all policies

-- Remove all existing policies first
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON public.chats;
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON public.messages;
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON public.user_presence;
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON public.device_tokens;

-- Disable Row Level Security completely
ALTER TABLE public.chats DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_presence DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.device_tokens DISABLE ROW LEVEL SECURITY;

-- Verify RLS is disabled
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('chats', 'messages', 'user_presence', 'device_tokens');