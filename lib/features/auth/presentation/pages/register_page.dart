import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
        title: const Text("Create Account", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Field Nama
            const Text("Full Name", style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            AuthTextField(
              controller: _nameController,
              label: "Fachri Ditya",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),

            // Field Email
            const Text("Email Address", style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            AuthTextField(
              controller: _emailController,
              label: "you@example.com",
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 20),

            // Field Password
            const Text("Password", style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            AuthTextField(
              controller: _passwordController,
              label: "Min. 6 characters",
              icon: Icons.lock_outline,
              isPassword: true,
            ),
            const SizedBox(height: 20),
            
            const SizedBox(height: 32),
            
            // Pesan Error jika ada
            if (authProvider.errorMessage != null) ...[
              Text(
                authProvider.errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
              const SizedBox(height: 16),
            ],

            // Tombol Register
            AppButton(
              label: "Sign Up",
              isLoading: authProvider.isLoading,
              onPressed: () => _handleRegister(context),
            ),
          ],
        ),
      ),
    );
  }

  void _handleRegister(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    
    // Validasi sederhana
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua kolom harus diisi!")),
      );
      return;
    }

    final success = await authProvider.register(
      _emailController.text,
      _passwordController.text,
      _nameController.text,
      'pengguna',
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrasi Berhasil! Silakan Login."), backgroundColor: Colors.green),
      );
      // Kembali ke halaman login setelah sukses
      Navigator.pop(context); 
    }
  }
}