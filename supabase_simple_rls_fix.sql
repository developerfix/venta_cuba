-- SIMPLE RLS FIX for VentaCuba Chat Module
-- This approach uses simpler policies that work with anon access

-- Step 1: Ensure the set_config function exists and has proper permissions
CREATE OR REPLACE FUNCTION set_config(setting_name text, new_value text, is_local boolean)
RETURNS text AS $$
BEGIN
    PERFORM set_config(setting_name, new_value, is_local);
    RETURN new_value;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute to everyone (anon and authenticated)
GRANT EXECUTE ON FUNCTION set_config(text, text, boolean) TO anon, authenticated, public;

-- Step 2: Create a function to check current user context
CREATE OR REPLACE FUNCTION get_current_user_id()
RETURNS text AS $$
BEGIN
    RETURN current_setting('app.current_user_id', true);
EXCEPTION
    WHEN OTHERS THEN
        RETURN '';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION get_current_user_id() TO anon, authenticated, public;

-- Step 3: Create a debug function to check RLS status
CREATE OR REPLACE FUNCTION rls_status_check()
RETURNS json AS $$
DECLARE
    result json;
BEGIN
    SELECT json_build_object(
        'current_user_id', get_current_user_id(),
        'session_user', session_user,
        'current_user', current_user,
        'rls_enabled', (
            SELECT json_object_agg(tablename, rowsecurity)
            FROM pg_tables 
            WHERE schemaname = 'public' 
            AND tablename IN ('chats', 'messages', 'user_presence')
        )
    ) INTO result;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION rls_status_check() TO anon, authenticated, public;

-- Step 4: Drop existing policies and create new simpler ones
DROP POLICY IF EXISTS "secure_chats_access" ON public.chats;
DROP POLICY IF EXISTS "secure_messages_access" ON public.messages;
DROP POLICY IF EXISTS "secure_presence_access" ON public.user_presence;

-- Step 5: Create simple policies that check the user context
CREATE POLICY "simple_chats_policy" ON public.chats
  FOR ALL 
  USING (
    get_current_user_id() != '' AND (
      sender_id = get_current_user_id() OR 
      send_to_id = get_current_user_id()
    )
  )
  WITH CHECK (
    get_current_user_id() != '' AND (
      sender_id = get_current_user_id() OR 
      send_to_id = get_current_user_id()
    )
  );

CREATE POLICY "simple_messages_policy" ON public.messages
  FOR ALL 
  USING (
    get_current_user_id() != '' AND
    chat_id IN (
      SELECT id FROM public.chats 
      WHERE sender_id = get_current_user_id() 
         OR send_to_id = get_current_user_id()
    )
  )
  WITH CHECK (
    get_current_user_id() != '' AND
    chat_id IN (
      SELECT id FROM public.chats 
      WHERE sender_id = get_current_user_id() 
         OR send_to_id = get_current_user_id()
    )
  );

CREATE POLICY "simple_presence_policy" ON public.user_presence
  FOR ALL 
  USING (get_current_user_id() != '' AND user_id = get_current_user_id())
  WITH CHECK (get_current_user_id() != '' AND user_id = get_current_user_id());

-- Step 6: Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated, public;
GRANT ALL ON public.chats TO anon, authenticated, public;
GRANT ALL ON public.messages TO anon, authenticated, public;
GRANT ALL ON public.user_presence TO anon, authenticated, public;

-- Step 7: Test the setup
SELECT 'Testing RLS setup...' as status;

-- Test set_config function
SELECT set_config('app.current_user_id', 'test_user_123', true) as test_set_config;

-- Test get current user
SELECT get_current_user_id() as current_user_context;

-- Test status check
SELECT rls_status_check() as rls_status;

-- Clear test context
SELECT set_config('app.current_user_id', '', true) as cleanup;

SELECT 'RLS setup completed! Use RLSDebug.testRLSContext(userId) in Flutter to test.' as result;