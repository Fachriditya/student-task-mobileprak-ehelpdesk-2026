import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER SECTION (UNGU) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 80, bottom: 40),
              decoration: const BoxDecoration(
                color: Color(0xFF4B39EF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0), 
                  bottomRight: Radius.circular(0),
                ),
              ),
              child: Column(
                children: [
                  // Logo Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.headset_mic_rounded, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Welcome back",
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Sign in to your HelpDesk account",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            // --- FORM SECTION ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Email or Username", style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _usernameController,
                    label: "you@example.com",
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 20),
                  const Text("Password", style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _passwordController,
                    label: "Enter your password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  
                  // Tombol Forgot Password 
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                      child: const Text("Forgot Password?", style: TextStyle(color: Color(0xFF4B39EF))),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Menampilkan Error dari Supabase (Jika password salah / email tidak ada)
                  if (authProvider.errorMessage != null) ...[
                    Text(
                      authProvider.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Tombol Sign In
                  AppButton(
                    label: "Sign In",
                    isLoading: authProvider.isLoading,
                    onPressed: () => _handleLogin(context),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Tombol Pindah ke Register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/register'),
                        child: const Text("Register", style: TextStyle(color: Color(0xFF4B39EF), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context) async {
    // ... (kodingan validasi di atasnya tetap sama)

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(_usernameController.text, _passwordController.text);

    if (success && mounted) {
      // Semua user, baik admin, helpdesk, maupun pengguna, 
      // dilempar ke /main. Biar MainPage yang mengurus tampilannya!
      Navigator.pushReplacementNamed(context, '/main');
    }
  }
}