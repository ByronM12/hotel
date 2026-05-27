import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'core/app_constants.dart';
import 'data/services/location_service.dart';
import 'data/services/firebase_location_service.dart';
import 'presentation/providers/map_provider.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint('App will run without Firebase features');
  }

  runApp(const HotelApp());
}

class HotelApp extends StatelessWidget {
  const HotelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MapProvider(
            locationService: LocationService(),
            firebaseService: FirebaseLocationService(userId: 'guest_user'),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Hotel App',
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
