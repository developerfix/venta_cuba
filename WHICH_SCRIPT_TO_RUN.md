# ⚠️ IMPORTANT: Which SQL Script to Run

## ❌ DON'T Use These (Old Scripts):
- ~~`supabase_rls_fix.sql`~~ - References device_tokens table that doesn't exist
- ~~`supabase_production_rls.sql`~~ - References device_tokens table that doesn't exist  
- ~~`supabase_fix_existing_tables.sql`~~ - For the original warnings only

## ✅ USE This Script (For Chat Fix):
**`supabase_simple_rls_fix.sql`** - This is the correct script for fixing your chat RLS error

## 🚀 Steps:
1. **Open** `supabase_simple_rls_fix.sql` file
2. **Copy** ALL content from that file
3. **Paste** in Supabase SQL Editor
4. **Run** the script
5. **Look for** "RLS setup completed!" message

## 🎯 What Each Script Does:

### `supabase_simple_rls_fix.sql` ✅
- **Purpose**: Fix the chat RLS permission error you're experiencing
- **Creates**: Enhanced functions with proper permissions
- **Works with**: Only existing tables (chats, messages, user_presence)
- **Result**: Chat will work properly with RLS security

### Old Scripts ❌
- **Problem**: Reference `device_tokens` table that doesn't exist in your database
- **Result**: Will cause "relation does not exist" errors

## 🔍 How to Identify the Right File:
The correct file starts with:
```sql
-- SIMPLE RLS FIX for VentaCuba Chat Module
-- This approach uses simpler policies that work with anon access
```

And creates these functions:
- `set_config()`
- `get_current_user_id()` 
- `rls_status_check()`

**Use `supabase_simple_rls_fix.sql` to fix your chat error!** 🎯