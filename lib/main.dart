import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/app_constants.dart';
import 'data/services/location_service.dart';
import 'data/services/firebase_location_service.dart';
import 'presentation/providers/map_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final userId = await _deviceUserId();
  var firebaseAvailable = false;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseAvailable = true;
    debugPrint('✅ Firebase inicializado correctamente');
  } catch (e) {
    firebaseAvailable = false;
    debugPrint('⚠️ Firebase no disponible: $e');
    debugPrint('    La app funciona sin sincronización en la nube.');
    debugPrint('    Ejecuta: flutterfire configure  para activarlo.');
  }

  runApp(HotelApp(firebaseAvailable: firebaseAvailable, userId: userId));
}

Future<String> _deviceUserId() async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'device_user_id';
  final existing = prefs.getString(key);
  if (existing != null && existing.isNotEmpty) {
    return existing;
  }

  final generatedId =
      'device_${DateTime.now().millisecondsSinceEpoch ~/ 100000}_${DateTime.now().microsecondsSinceEpoch}';
  await prefs.setString(key, generatedId);
  return generatedId;
}

class HotelApp extends StatelessWidget {
  final bool firebaseAvailable;
  final String userId;

  const HotelApp({
    super.key,
    required this.firebaseAvailable,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MapProvider(
            locationService: LocationService(),
            firebaseService: FirebaseLocationService(
              userId: userId,
              available: firebaseAvailable,
            ),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'HotelFlow',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const HomeScreen(),
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.gold),
      scaffoldBackgroundColor: AppColors.lightBg,
    );
  }
}
