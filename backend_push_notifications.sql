-- ================================================
-- SUPABASE EDGE FUNCTION FOR PUSH NOTIFICATIONS
-- ================================================
-- 
-- Deploy this as a Supabase Edge Function to automatically
-- send push notifications when new messages are inserted
--
-- Documentation: https://supabase.com/docs/guides/functions

-- Step 1: Create this Edge Function in Supabase Dashboard
-- Go to: Functions → New Function → Name it "send-chat-notification"

// supabase/functions/send-chat-notification/index.ts

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

const NTFY_SERVER_URL = 'https://ntfy.sh' // Or your self-hosted server

serve(async (req) => {
  try {
    // Get the message data from the webhook
    const { record } = await req.json()
    
    // Extract message details
    const {
      chat_id,
      message,
      send_by,
      sender_name,
      message_type
    } = record
    
    // Get the chat to find recipient
    const { data: chat } = await supabase
      .from('chats')
      .select('sender_id, send_to_id')
      .eq('id', chat_id)
      .single()
    
    // Determine recipient
    const recipientId = chat.sender_id === send_by 
      ? chat.send_to_id 
      : chat.sender_id
    
    // Format message body based on type
    let body = message
    if (message_type === 'image') body = '📷 Photo'
    if (message_type === 'video') body = '📹 Video'
    if (message_type === 'file') body = '📎 File'
    
    // Send notification via ntfy
    const ntfyResponse = await fetch(NTFY_SERVER_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        topic: `venta_cuba_user_${recipientId}`,
        title: sender_name || 'New Message',
        message: body,
        priority: 4,
        click: `myapp://chat/${chat_id}`,
        actions: [
          {
            action: 'view',
            label: 'Open Chat',
            url: `myapp://chat/${chat_id}`
          }
        ]
      })
    })
    
    // Store notification in database for history
    await supabase
      .from('push_notifications')
      .insert({
        recipient_user_id: recipientId,
        title: sender_name || 'New Message',
        body: body,
        data: {
          chat_id,
          sender_name,
          message_type
        },
        is_read: false
      })
    
    return new Response(
      JSON.stringify({ success: true }),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 400, headers: { 'Content-Type': 'application/json' } }
    )
  }
})

-- ================================================
-- Step 2: Create Database Webhook
-- ================================================
-- 
-- In Supabase Dashboard:
-- 1. Go to Database → Webhooks
-- 2. Create new webhook
-- 3. Name: "new-message-notification"
-- 4. Table: messages
-- 5. Events: INSERT
-- 6. URL: https://YOUR_PROJECT.supabase.co/functions/v1/send-chat-notification
-- 7. Enable webhook

-- ================================================
-- ALTERNATIVE: PostgreSQL Trigger (if Edge Functions not available)
-- ================================================

CREATE OR REPLACE FUNCTION notify_new_message()
RETURNS trigger AS $$
DECLARE
  recipient_id TEXT;
  chat_data RECORD;
BEGIN
  -- Get chat details
  SELECT * INTO chat_data 
  FROM chats 
  WHERE id = NEW.chat_id;
  
  -- Determine recipient
  IF chat_data.sender_id = NEW.send_by THEN
    recipient_id := chat_data.send_to_id;
  ELSE
    recipient_id := chat_data.sender_id;
  END IF;
  
  -- Insert notification record
  INSERT INTO push_notifications (
    recipient_user_id,
    title,
    body,
    data,
    is_read
  ) VALUES (
    recipient_id,
    NEW.sender_name,
    CASE 
      WHEN NEW.message_type = 'image' THEN '📷 Photo'
      WHEN NEW.message_type = 'video' THEN '📹 Video'
      WHEN NEW.message_type = 'file' THEN '📎 File'
      ELSE NEW.message
    END,
    jsonb_build_object(
      'chat_id', NEW.chat_id,
      'sender_name', NEW.sender_name,
      'message_type', NEW.message_type
    ),
    false
  );
  
  -- Send HTTP request to ntfy (requires pg_net extension)
  -- Note: Install pg_net extension first: CREATE EXTENSION pg_net;
  PERFORM net.http_post(
    url := 'https://ntfy.sh/',
    headers := '{"Content-Type": "application/json"}'::jsonb,
    body := jsonb_build_object(
      'topic', 'venta_cuba_user_' || recipient_id,
      'title', NEW.sender_name,
      'message', NEW.message,
      'priority', 4,
      'click', 'myapp://chat/' || NEW.chat_id
    )::text
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
CREATE TRIGGER on_new_message_trigger
AFTER INSERT ON messages
FOR EACH ROW
EXECUTE FUNCTION notify_new_message();

-- ================================================
-- SIMPLE NODE.JS BACKEND EXAMPLE
-- ================================================

/*
// If using Node.js backend instead of Supabase Functions:

const express = require('express');
const axios = require('axios');
const app = express();

app.use(express.json());

// Endpoint called when message is sent
app.post('/api/send-message', async (req, res) => {
  const { 
    chatId, 
    message, 
    senderId, 
    senderName,
    recipientId,
    messageType 
  } = req.body;
  
  try {
    // Save message to Supabase
    await supabase
      .from('messages')
      .insert({
        chat_id: chatId,
        message: message,
        send_by: senderId,
        sender_name: senderName,
        message_type: messageType
      });
    
    // Send push notification via ntfy
    await axios.post('https://ntfy.sh/', {
      topic: `venta_cuba_user_${recipientId}`,
      title: senderName,
      message: messageType === 'image' ? '📷 Photo' : message,
      priority: 4,
      click: `myapp://chat/${chatId}`
    });
    
    res.json({ success: true });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: error.message });
  }
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
*/

-- ================================================
-- TESTING THE NOTIFICATIONS
-- ================================================

-- Test by inserting a message directly:
INSERT INTO messages (
  chat_id,
  message,
  send_by,
  sender_name,
  message_type
) VALUES (
  'test-chat-123',
  'Hello from Cuba!',
  'user-1',
  'John Doe',
  'text'
);

-- Check if notification was created:
SELECT * FROM push_notifications 
ORDER BY created_at DESC 
LIMIT 1;

-- ================================================
-- MONITORING & DEBUGGING
-- ================================================

-- View recent notifications
SELECT 
  id,
  recipient_user_id,
  title,
  body,
  is_read,
  created_at
FROM push_notifications
ORDER BY created_at DESC
LIMIT 20;

-- Count unread notifications per user
SELECT 
  recipient_user_id,
  COUNT(*) as unread_count
FROM push_notifications
WHERE is_read = false
GROUP BY recipient_user_id;

-- Clean old notifications (run periodically)
DELETE FROM push_notifications
WHERE created_at < NOW() - INTERVAL '30 days';
