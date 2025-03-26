import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/customers_screen.dart';
import 'screens/vehicles_screen.dart';
import 'screens/repairs_screen.dart';
import 'screens/invoices_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notifications_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eCar Garage Admin',
      debugShowCheckedModeBanner: false,
      // Add responsive framework for better web experience
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 600, name: MOBILE),
          const Breakpoint(start: 601, end: 900, name: TABLET),
          const Breakpoint(start: 901, end: 1200, name: DESKTOP),
          const Breakpoint(start: 1201, end: double.infinity, name: '4K'),
        ],
      ),
      theme: ThemeData(
        // Define the default brightness and colors based on brand specs
        brightness: Brightness.light,
        primaryColor: Colors.black,
        colorScheme: ColorScheme.light(
          primary: Colors.black,
          secondary: Colors.white,
          onSecondary: Colors.black,
          // Brand-specific accent colors
          tertiary: const Color(0xFF0066B1), // BMW Blue
          tertiaryContainer: const Color(0xFF9A9A9A), // Mercedes Silver
          onTertiaryContainer: const Color(0xFF003399), // VW Blue
        ),
        
        // Apply Google Fonts
        textTheme: GoogleFonts.openSansTextTheme(
          const TextTheme(
            displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            displayMedium: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold),
            displaySmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            headlineMedium: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
            titleLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
            bodyLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w300),
            bodyMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300),
            labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
          ),
        ),
        
        // Define button styles
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        
        // Card theme
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        
        // App bar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        
        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
        ),
      ),
      
      // Localization support
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('fr'), // French
        Locale('ar'), // Arabic
      ],
      
      // Define routes - use initialRoute instead of home
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/customers': (context) => const CustomersScreen(),
        '/vehicles': (context) => const VehiclesScreen(),
        '/repairs': (context) => const RepairsScreen(),
        '/invoices': (context) => const InvoicesScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/notifications': (context) => const NotificationsScreen(),
      },
    );
  }
}
