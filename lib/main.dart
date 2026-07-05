import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 1. IMPORT SUPABASE

import 'package:helpdesk_app/core/theme/app_theme.dart';
import 'package:helpdesk_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:helpdesk_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:helpdesk_app/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:helpdesk_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:helpdesk_app/features/comment/presentation/providers/comment_provider.dart'; 
import 'package:helpdesk_app/features/history/presentation/providers/history_provider.dart'; 
import 'package:helpdesk_app/features/history/presentation/pages/ticket_history_page.dart';
import 'features/notification/presentation/providers/notification_provider.dart';

import 'package:helpdesk_app/features/splash/presentation/pages/splash_page.dart';
import 'package:helpdesk_app/features/auth/presentation/pages/login_page.dart';
import 'package:helpdesk_app/features/main/presentation/pages/main_page.dart';
import 'package:helpdesk_app/features/ticket/presentation/pages/create_ticket_page.dart';
import 'package:helpdesk_app/features/ticket/presentation/pages/ticket_list_page.dart';
import 'package:helpdesk_app/features/auth/presentation/pages/register_page.dart';
import 'package:helpdesk_app/features/auth/presentation/pages/forgot_password_page.dart';

import 'package:helpdesk_app/features/dashboard/presentation/pages/admin_dashboard_page.dart';

// 2. BUAT VARIABEL GLOBAL SUPABASE
final supabase = Supabase.instance.client;

// 3. TAMBAHKAN async KARENA INISIALISASI BUTUH WAKTU
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 4. NYALAKAN MESIN SUPABASE SEBELUM runApp
  await Supabase.initialize(
    url: 'https://eqolyewomnpczprqqgnv.supabase.co',
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxb2x5ZXdvbW5wY3pwcnFxZ252Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMxNjU1MzksImV4cCI6MjA5ODc0MTUzOX0.imduS0o90apDADjfN8CVo_ZwZtbqhtFR11oh_aQqj2c',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => TicketProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()), 
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        return MaterialApp(
          title: 'HelpDesk App',
          debugShowCheckedModeBanner: false,
          
          themeMode: profileProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: AppTheme.lightTheme, 
          darkTheme: AppTheme.darkTheme, 
          
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashPage(),
            '/login': (context) => const LoginPage(),
            '/register': (context) => RegisterPage(),
            '/forgot-password': (context) => ForgotPasswordPage(),
            
            // --- ROUTING HALAMAN UTAMA ---
            // Asumsi: MainPage adalah halaman yang ada BottomNavigationBar-nya untuk User
            '/main': (context) => const MainPage(), 
            '/dashboard-user': (context) => const MainPage(), 
            
            // --- ROUTING KHUSUS ROLE ---
            '/dashboard-admin': (context) => const AdminDashboardPage(), 
            
            // Sementara kita arahkan Helpdesk ke MainPage dulu sebelum kita buat halamannya
            '/dashboard-helpdesk': (context) => const MainPage(), 
            
            // --- ROUTING HALAMAN LAINNYA ---
            '/create-ticket': (context) => const CreateTicketPage(),
          },
        );
      },
    );
  }
}