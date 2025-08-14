-- PRODUCTION RLS Setup for VentaCuba Chat Module
-- Run this COMPLETE script in your Supabase SQL Editor
-- This will resolve ALL 6 RLS warnings for EXISTING tables only

-- Step 1: Create the set_config function for user context
CREATE OR REPLACE FUNCTION set_config(setting_name text, new_value text, is_local boolean)
RETURNS text AS $$
BEGIN
    PERFORM set_config(setting_name, new_value, is_local);
    RETURN new_value;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 2: Enable Row Level Security on EXISTING tables only
ALTER TABLE public.chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_presence ENABLE ROW LEVEL SECURITY;

-- Step 3: Drop any existing policies to avoid conflicts
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON public.chats;
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON public.messages;
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON public.user_presence;

DROP POLICY IF EXISTS "Allow all operations" ON public.chats;
DROP POLICY IF EXISTS "Allow all operations" ON public.messages;
DROP POLICY IF EXISTS "Allow all operations" ON public.user_presence;

DROP POLICY IF EXISTS "Users can access their own chats" ON public.chats;
DROP POLICY IF EXISTS "Users can access messages in their chats" ON public.messages;
DROP POLICY IF EXISTS "Users can manage their presence" ON public.user_presence;

-- Step 4: Create secure RLS policies based on custom user authentication

-- CHATS: Users can only access chats where they are sender or recipient
CREATE POLICY "secure_chats_access" ON public.chats
  FOR ALL USING (
    sender_id = current_setting('app.current_user_id', true) OR 
    send_to_id = current_setting('app.current_user_id', true)
  )
  WITH CHECK (
    sender_id = current_setting('app.current_user_id', true) OR 
    send_to_id = current_setting('app.current_user_id', true)
  );

-- MESSAGES: Users can only access messages in chats they participate in
CREATE POLICY "secure_messages_access" ON public.messages
  FOR ALL USING (
    chat_id IN (
      SELECT id FROM public.chats 
      WHERE sender_id = current_setting('app.current_user_id', true) 
         OR send_to_id = current_setting('app.current_user_id', true)
    )
  )
  WITH CHECK (
    chat_id IN (
      SELECT id FROM public.chats 
      WHERE sender_id = current_setting('app.current_user_id', true) 
         OR send_to_id = current_setting('app.current_user_id', true)
    )
  );

-- USER_PRESENCE: Users can only manage their own presence
CREATE POLICY "secure_presence_access" ON public.user_presence
  FOR ALL USING (user_id = current_setting('app.current_user_id', true))
  WITH CHECK (user_id = current_setting('app.current_user_id', true));

-- Step 5: Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON public.chats TO anon, authenticated;
GRANT ALL ON public.messages TO anon, authenticated;
GRANT ALL ON public.user_presence TO anon, authenticated;

-- Step 6: Grant execute permission on the set_config function
GRANT EXECUTE ON FUNCTION set_config(text, text, boolean) TO anon, authenticated;

-- Step 7: Verification queries for EXISTING tables only
SELECT '=== RLS STATUS VERIFICATION ===' as info;
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

SELECT '=== POLICIES VERIFICATION ===' as info;
SELECT 
    schemaname, 
    tablename, 
    policyname, 
    CASE cmd
        WHEN 'ALL' THEN '✅ ALL OPERATIONS'
        WHEN 'SELECT' THEN '📖 SELECT ONLY'
        WHEN 'INSERT' THEN '➕ INSERT ONLY'
        WHEN 'UPDATE' THEN '✏️ UPDATE ONLY'
        WHEN 'DELETE' THEN '🗑️ DELETE ONLY'
        ELSE cmd
    END as policy_type
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename IN ('chats', 'messages', 'user_presence')
ORDER BY tablename, policyname;

SELECT '=== SUMMARY ===' as info;
SELECT 
    COUNT(*) as total_tables_with_rls,
    SUM(CASE WHEN rowsecurity = true THEN 1 ELSE 0 END) as tables_rls_enabled,
    SUM(CASE WHEN rowsecurity = false THEN 1 ELSE 0 END) as tables_rls_disabled
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('chats', 'messages', 'user_presence');

-- Final success message
SELECT 
    '🎉 Production RLS setup completed successfully!' as status,
    'All 6 Supabase warnings should now be resolved.' as result,
    'Remember to call RLSHelper.setUserContext(userId) after login in your Flutter app.' as next_step;