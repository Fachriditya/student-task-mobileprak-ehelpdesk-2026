import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B39EF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Reset Password", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Lupa Password?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Masukkan email kamu yang terdaftar. Kami akan mengirimkan tautan untuk mengatur ulang password.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            const Text("Email Address", style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            AuthTextField(
              controller: _emailController,
              label: "you@example.com",
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 24),

            if (authProvider.errorMessage != null) ...[
              Text(
                authProvider.errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
              const SizedBox(height: 16),
            ],

            AppButton(
              label: "Send Reset Link",
              isLoading: authProvider.isLoading,
              onPressed: () => _handleReset(context),
            ),
          ],
        ),
      ),
    );
  }

  void _handleReset(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email tidak boleh kosong!")),
      );
      return;
    }

    final success = await authProvider.resetPassword(_emailController.text);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Link reset password berhasil dikirim ke email kamu!"), 
          backgroundColor: Colors.green
        ),
      );
      Navigator.pop(context); // Kembali ke halaman login
    }
  }
}