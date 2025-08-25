-- Migration: Update device_tokens table for cross-platform support
-- Run this in your Supabase SQL Editor

-- First, ensure the device_tokens table exists with proper structure
CREATE TABLE IF NOT EXISTS public.device_tokens (
    id BIGSERIAL PRIMARY KEY,
    user_id TEXT NOT NULL,
    device_token TEXT NOT NULL,
    platform TEXT DEFAULT 'android',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, device_token)
);

-- Add platform column if it doesn't exist
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'device_tokens' 
                   AND column_name = 'platform') THEN
        ALTER TABLE public.device_tokens 
        ADD COLUMN platform TEXT DEFAULT 'android';
    END IF;
END $$;

-- Add is_active column if it doesn't exist
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'device_tokens' 
                   AND column_name = 'is_active') THEN
        ALTER TABLE public.device_tokens 
        ADD COLUMN is_active BOOLEAN DEFAULT true;
    END IF;
END $$;

-- Add updated_at column if it doesn't exist
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'device_tokens' 
                   AND column_name = 'updated_at') THEN
        ALTER TABLE public.device_tokens 
        ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

-- Create an index on user_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_device_tokens_user_id 
ON public.device_tokens(user_id);

-- Create an index on is_active for filtering
CREATE INDEX IF NOT EXISTS idx_device_tokens_is_active 
ON public.device_tokens(is_active);

-- Create a function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-update updated_at
DROP TRIGGER IF EXISTS update_device_tokens_updated_at ON public.device_tokens;
CREATE TRIGGER update_device_tokens_updated_at
BEFORE UPDATE ON public.device_tokens
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Update existing tokens to set platform based on token pattern
UPDATE public.device_tokens 
SET platform = CASE 
    WHEN device_token LIKE 'ntfy_user_%' OR device_token LIKE 'venta_cuba_user_%' THEN 'android'
    WHEN LENGTH(device_token) > 100 THEN 'ios'
    ELSE 'android'
END
WHERE platform IS NULL OR platform = '';

-- Ensure RLS is enabled on device_tokens table
ALTER TABLE public.device_tokens ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for device_tokens
DROP POLICY IF EXISTS "Users can view their own device tokens" ON public.device_tokens;
CREATE POLICY "Users can view their own device tokens" 
ON public.device_tokens FOR SELECT 
USING (auth.uid()::TEXT = user_id);

DROP POLICY IF EXISTS "Users can insert their own device tokens" ON public.device_tokens;
CREATE POLICY "Users can insert their own device tokens" 
ON public.device_tokens FOR INSERT 
WITH CHECK (auth.uid()::TEXT = user_id);

DROP POLICY IF EXISTS "Users can update their own device tokens" ON public.device_tokens;
CREATE POLICY "Users can update their own device tokens" 
ON public.device_tokens FOR UPDATE 
USING (auth.uid()::TEXT = user_id);

DROP POLICY IF EXISTS "Users can delete their own device tokens" ON public.device_tokens;
CREATE POLICY "Users can delete their own device tokens" 
ON public.device_tokens FOR DELETE 
USING (auth.uid()::TEXT = user_id);

-- Grant necessary permissions
GRANT ALL ON public.device_tokens TO authenticated;
GRANT ALL ON public.device_tokens TO service_role;

-- Add comment to table
COMMENT ON TABLE public.device_tokens IS 'Stores device tokens for push notifications with platform information';
COMMENT ON COLUMN public.device_tokens.platform IS 'Platform type: ios or android';
COMMENT ON COLUMN public.device_tokens.device_token IS 'FCM token for iOS or ntfy topic for Android';
