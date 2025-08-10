# 🔔 Venta Cuba Push Notifications Setup (ntfy.sh)

## ✅ Why ntfy.sh Works in Cuba

Unlike Firebase and OneSignal (which are blocked due to US trade embargo), ntfy.sh:
- **No Firebase/Google dependency** - Works without any Google services
- **HTTP/WebSocket based** - Uses standard web protocols
- **Self-hostable** - Deploy on any server outside Cuba
- **100% Open Source** - No restrictions or embargos
- **Battery efficient** - WebSocket keeps connection alive with minimal battery usage

## 📱 How It Works

1. **User logs in** → App gets unique user ID
2. **App subscribes** to user's personal ntfy topic (e.g., `venta_cuba_user_123`)
3. **When message sent** → Server sends HTTP POST to ntfy
4. **Recipient receives** notification instantly via WebSocket
5. **Offline users** get notifications when they reconnect

## 🚀 Quick Start (Using Public Server)

The app is **already configured** to use the public ntfy.sh server. Just run your app and notifications will work!

```dart
// Already configured in app_config.dart:
static const String ntfyServerUrl = 'https://ntfy.sh';
```

**That's it!** Push notifications will work immediately in Cuba.

## 🏗️ Production Setup (Self-Hosted Server)

For production, deploy your own ntfy server on a VPS outside Cuba:

### Option 1: DigitalOcean (Recommended - $6/month)

1. **Create Droplet**
   - Go to https://www.digitalocean.com
   - Create account (use credit card or PayPal)
   - Click "Create" → "Droplets"
   - Choose: Ubuntu 22.04, Basic plan ($6/month), any region except US
   - Create droplet

2. **SSH into server**
   ```bash
   ssh root@your-server-ip
   ```

3. **Install ntfy (one command!)**
   ```bash
   curl -sSL https://github.com/binwiederhier/ntfy/releases/latest/download/install.sh | sudo bash
   ```

4. **Configure ntfy**
   ```bash
   sudo nano /etc/ntfy/server.yml
   ```
   Add:
   ```yaml
   base-url: "http://your-server-ip"
   behind-proxy: false
   ```

5. **Start ntfy**
   ```bash
   sudo systemctl start ntfy
   sudo systemctl enable ntfy
   ```

6. **Update your Flutter app**
   ```dart
   // In app_config.dart, change to:
   static const String ntfyServerUrl = 'http://your-server-ip';
   ```

### Option 2: Vultr ($6/month)
Similar to DigitalOcean, create VPS and follow same steps.

### Option 3: Fly.io (Free tier available)

1. **Install flyctl**
   ```bash
   curl -L https://fly.io/install.sh | sh
   ```

2. **Create app**
   ```bash
   fly launch --image binwiederhier/ntfy
   ```

3. **Deploy**
   ```bash
   fly deploy
   ```

4. **Your server URL**
   ```
   https://your-app-name.fly.dev
   ```

## 🔧 Server Configuration (Optional)

### Add HTTPS with Let's Encrypt (Recommended)

```bash
sudo apt install certbot
sudo certbot certonly --standalone -d your-domain.com
```

Update `/etc/ntfy/server.yml`:
```yaml
base-url: "https://your-domain.com"
listen-https: ":443"
cert-file: "/etc/letsencrypt/live/your-domain.com/fullchain.pem"
key-file: "/etc/letsencrypt/live/your-domain.com/privkey.pem"
```

### Authentication (Optional)
Add to `/etc/ntfy/server.yml`:
```yaml
auth-file: "/var/lib/ntfy/user.db"
auth-default-access: "deny-all"
```

Create users:
```bash
ntfy user add --role=admin admin_user
ntfy user add user1
```

## 📲 Testing Push Notifications

### Test from Command Line
```bash
# Send test notification
curl -d "Hello from Cuba!" https://ntfy.sh/venta_cuba_user_123

# With title and priority
curl -H "Title: New Message" -H "Priority: 4" -d "You have a new message!" https://ntfy.sh/venta_cuba_user_123
```

### Test from Flutter Debug Console
```dart
// In debug console, after user login:
await NtfyPushService.sendNotification(
  recipientUserId: '123',
  title: 'Test',
  body: 'Hello from Cuba!',
);
```

## 🛠️ Troubleshooting

### Notifications not received?

1. **Check connection status**
   ```dart
   print('Connected: ${NtfyPushService.isConnected}');
   ```

2. **Check user topic**
   ```dart
   // Should be: venta_cuba_user_[userId]
   print('Topic: ${_userTopic}');
   ```

3. **Test server directly**
   ```bash
   curl your-server-url/health
   # Should return: {"healthy":true}
   ```

### Server errors?

1. **Check logs**
   ```bash
   sudo journalctl -u ntfy -f
   ```

2. **Restart service**
   ```bash
   sudo systemctl restart ntfy
   ```

## 💰 Cost Comparison

| Service | Monthly Cost | Works in Cuba | Setup Time |
|---------|-------------|---------------|------------|
| ntfy.sh (public) | **FREE** | ✅ Yes | Instant |
| ntfy (self-hosted) | **$6** | ✅ Yes | 30 minutes |
| Firebase FCM | Free* | ❌ No | - |
| OneSignal | Free* | ❌ No | - |
| Pushy.me | $20+ | ✅ Yes | 1 hour |

*But doesn't work in Cuba due to embargo

## 📝 Database Schema

The app stores notifications in Supabase for persistence:

```sql
-- Already created in your supabase_push_notifications_table.sql
CREATE TABLE push_notifications (
  id BIGSERIAL PRIMARY KEY,
  recipient_user_id TEXT NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  data JSONB DEFAULT '{}',
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

## 🔄 How Messages Flow

1. **User A sends message** in chat
2. **SupabaseChatController** saves message to Supabase
3. **SupabasePushService** is called with recipient info
4. **NtfyPushService** sends HTTP POST to ntfy server
5. **Ntfy server** delivers via WebSocket to User B
6. **User B's app** shows local notification
7. **Notification stored** in Supabase for history

## 🎯 Key Features

- ✅ **Real-time delivery** via WebSocket
- ✅ **Offline support** - messages queued until online
- ✅ **Battery efficient** - single connection for all notifications
- ✅ **No Firebase** - works in Cuba, China, Iran, etc.
- ✅ **Fallback to polling** if WebSocket fails
- ✅ **Automatic reconnection** on network changes
- ✅ **Local notifications** for foreground/background

## 📱 iOS Setup (Additional Steps)

Add to `ios/Runner/Info.plist`:
```xml
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>remote-notification</string>
</array>
```

## 🤝 Support

- **ntfy Documentation**: https://docs.ntfy.sh
- **Community Forum**: https://github.com/binwiederhier/ntfy/discussions
- **Telegram Group**: @ntfy_chat

## ✨ Next Steps

1. **Test locally** with public ntfy.sh server
2. **Deploy your server** when ready for production
3. **Update app_config.dart** with your server URL
4. **Monitor usage** via ntfy web interface

---

**Remember**: This solution is 100% legal and works perfectly in Cuba without any US service dependencies! 🇨🇺
