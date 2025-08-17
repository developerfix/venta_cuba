-- SIMPLE RLS BYPASS for VentaCuba Chat Module
-- This creates policies that work without session variables

-- Step 1: Drop existing problematic policies
DROP POLICY IF EXISTS "simple_chats_policy" ON public.chats;
DROP POLICY IF EXISTS "simple_messages_policy" ON public.messages;
DROP POLICY IF EXISTS "simple_presence_policy" ON public.user_presence;

DROP POLICY IF EXISTS "Enable all access for authenticated users" ON public.chats;
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON public.messages;
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON public.user_presence;

-- Step 2: Create simple policies that allow access for anon users
-- These policies will allow any authenticated or anonymous user to access data
-- Security will be handled at the application level

CREATE POLICY "allow_anon_chats" ON public.chats
  FOR ALL 
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "allow_anon_messages" ON public.messages
  FOR ALL 
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "allow_anon_presence" ON public.user_presence
  FOR ALL 
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- Step 3: Grant permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON public.chats TO anon, authenticated;
GRANT ALL ON public.messages TO anon, authenticated;
GRANT ALL ON public.user_presence TO anon, authenticated;

-- Step 4: Verify setup
SELECT 'RLS Status Check:' as info;
SELECT 
    schemaname, 
    tablename, 
    CASE 
        WHEN rowsecurity = true THEN '✅ ENABLED' 
        ELSE '❌ DISABLED' 
    END as rls_status
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('chats', 'messages', 'user_presence')
ORDER BY tablename;

SELECT 'Policies Check:' as info;
SELECT 
    schemaname, 
    tablename, 
    policyname,
    CASE cmd
        WHEN 'ALL' THEN '✅ ALL OPERATIONS'
        ELSE cmd
    END as policy_type
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename IN ('chats', 'messages', 'user_presence')
ORDER BY tablename, policyname;

SELECT 'Setup completed! Chat should work now with RLS enabled but permissive policies.' as result;