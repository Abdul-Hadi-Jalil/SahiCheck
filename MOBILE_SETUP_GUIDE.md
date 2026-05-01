# Mobile-Laptop Connection Setup Guide

## Step 1: Find Your Laptop's IP Address

### Windows:
1. Open Command Prompt (Win + R, type `cmd`, press Enter)
2. Run: `ipconfig`
3. Look for "IPv4 Address" under your active network connection
4. Note the IP address (e.g., `192.168.1.100`)

### Mac/Linux:
1. Open Terminal
2. Run: `ifconfig` or `ip addr`
3. Look for "inet" address under your active network interface
4. Note the IP address (e.g., `192.168.1.100`)

## Step 2: Update API Service

1. Open `lib/services/api_service.dart`
2. Replace `192.168.1.100` with your actual laptop IP:
   ```dart
   static const String baseUrl = 'http://YOUR_IP_ADDRESS:8002';
   ```

## Step 3: Start Backend Server

1. Open terminal in backend directory:
   ```bash
   cd sahicheck_backend
   python -m uvicorn main:app --host 0.0.0.0 --port 8002 --reload
   ```
   
   **Important:** Use `--host 0.0.0.0` to allow external connections!

## Step 4: Connect Mobile to Laptop

### Option A: USB Connection (Recommended)
1. Connect phone to laptop via USB
2. Enable USB Debugging on your phone
3. Run Flutter app:
   ```bash
   cd sahicheck_frontend
   flutter run
   ```

### Option B: Same WiFi Network
1. Connect both laptop and mobile to the same WiFi network
2. Ensure firewall allows port 8002
3. Run Flutter app on mobile device

## Step 5: Test Connection

1. Open the Flutter app on your mobile
2. Go to "Integration Test" screen
3. Click "Run Tests"
4. Check if all tests pass

## Troubleshooting

### Connection Refused Error:
- Check if backend server is running
- Verify IP address is correct
- Ensure `--host 0.0.0.0` is used in backend command

### Firewall Issues:
- Windows: Allow Python/uvicorn through Windows Firewall
- Mac: Allow incoming connections in System Preferences
- Antivirus: Add exception for port 8002

### Network Issues:
- Ensure both devices are on same network
- Try pinging laptop IP from mobile (if possible)
- Restart backend server

## Quick Test Commands

### Test Backend from Mobile Browser:
Open mobile browser and go to: `http://YOUR_IP_ADDRESS:8002`

### Test with curl (from another computer):
```bash
curl http://YOUR_IP_ADDRESS:8002/
```

## Security Notes

- This setup is for development only
- In production, use HTTPS and proper authentication
- Consider using a reverse proxy (nginx) for better security
