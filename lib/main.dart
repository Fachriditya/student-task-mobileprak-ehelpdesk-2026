import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:helpdesk_app/core/theme/app_theme.dart';
import 'package:helpdesk_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:helpdesk_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:helpdesk_app/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:helpdesk_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:helpdesk_app/features/splash/presentation/pages/splash_page.dart';
import 'package:helpdesk_app/features/auth/presentation/pages/login_page.dart';
import 'package:helpdesk_app/features/main/presentation/pages/main_page.dart';
import 'package:helpdesk_app/features/ticket/presentation/pages/create_ticket_page.dart';
import 'package:helpdesk_app/features/ticket/presentation/pages/ticket_list_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => TicketProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // BUNGKUS DENGAN CONSUMER PROFILEPROVIDER
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        return MaterialApp(
          title: 'HelpDesk App',
          debugShowCheckedModeBanner: false,
          
          // --- KUNCI DARK MODE ADA DI SINI ---
          themeMode: profileProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: AppTheme.lightTheme, // Panggil tema Light dari core
          darkTheme: AppTheme.darkTheme, // Panggil tema Dark dari core
          
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashPage(),
            '/login': (context) => const LoginPage(),
            '/main': (context) => const MainPage(),
            // Arahkan rute dashboard ke MainPage agar Navbar selalu muncul
            '/dashboard-user': (context) => const MainPage(),
            '/dashboard-helpdesk': (context) => const MainPage(),
            '/dashboard-admin': (context) => const MainPage(),
            '/create-ticket': (context) => const CreateTicketPage(),
          },
        );
      },
    );
  }
}