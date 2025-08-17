-- Quick check to see which tables exist in your database
-- Run this FIRST to verify which tables you have

SELECT '=== EXISTING TABLES ===' as info;

SELECT 
    schemaname,
    tablename,
    CASE 
        WHEN rowsecurity = true THEN '✅ RLS ENABLED'
        ELSE '❌ RLS DISABLED'
    END as current_rls_status
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('chats', 'messages', 'user_presence', 'device_tokens')
ORDER BY tablename;

SELECT '=== CURRENT POLICIES ===' as info;

SELECT 
    schemaname,
    tablename,
    policyname,
    cmd as operation
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename IN ('chats', 'messages', 'user_presence', 'device_tokens')
ORDER BY tablename, policyname;

SELECT '=== TABLES COUNT ===' as info;

SELECT 
    COUNT(*) as total_chat_tables_found
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('chats', 'messages', 'user_presence', 'device_tokens');