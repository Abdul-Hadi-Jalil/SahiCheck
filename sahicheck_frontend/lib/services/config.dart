class AppConfig {
  // DEVELOPMENT SETTINGS
  // Change this based on where you're running the app:

  // Option 1: Running on mobile connected to laptop
  // static const String baseUrl = 'http://192.168.1.100:8002'; // Replace with your laptop IP

  // Option 2: Running on Android emulator
  // static const String baseUrl = 'http://10.0.2.2:8002';

  // Option 1: Running on mobile connected to laptop
  static const String baseUrl = 'http://192.168.18.251:8002'; // Your laptop IP

  // Option 3: Running on web/desktop (localhost)
  // static const String baseUrl = 'http://localhost:8002';

  // Option 4: Auto-detect platform (uncomment to use)
  // static String get baseUrl {
  //   if (kIsWeb) return 'http://localhost:8002';
  //   if (Platform.isAndroid) return 'http://192.168.1.100:8002'; // Replace with your IP
  //   if (Platform.isIOS) return 'http://192.168.1.100:8002'; // Replace with your IP
  //   return 'http://localhost:8002';
  // }
}
