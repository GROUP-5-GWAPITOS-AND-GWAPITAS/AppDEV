import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/theme.dart';

class SignInDashboard extends StatefulWidget {
  const SignInDashboard({super.key});
  @override
  State<SignInDashboard> createState() => _SignInDashboardState();
}

class _SignInDashboardState extends State<SignInDashboard> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  bool isRegistering = false;
  String error = "";
  bool isPasswordVisible = false;
  String selectedRole = 'client'; // Default role

  void submit() async {
    setState(() => error = "");
    final auth = context.read<AuthProvider>();

    if (isRegistering) {
      // 1. Create the account
      final success = await auth.register(
        nameCtrl.text, 
        emailCtrl.text, 
        passCtrl.text,
        selectedRole 
      );
      
      if (success) {
        // 2. Wait 1 second for the backend to save the Worker Profile
        await Future.delayed(const Duration(seconds: 1));
        
        // 3. Log in to grab the token and workerProfileId
        final loginSuccess = await auth.login(emailCtrl.text, passCtrl.text);
        if (!loginSuccess) {
          setState(() => error = "Account created, but login failed. Please try signing in.");
        }
      } else {
        setState(() => error = "Email already exists or error occurred.");
      }
    } else {
      final success = await auth.login(emailCtrl.text, passCtrl.text);
      if (!success) setState(() => error = "Invalid email or password");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.work, size: 80, color: primaryNavy),
                const SizedBox(height: 16),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryNavy),
                    children: [
                      TextSpan(text: "WORK "),
                      TextSpan(text: "| ", style: TextStyle(color: accentOrange)),
                      TextSpan(text: "MATCH"),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(isRegistering ? "Create a new account." : "Sign in to find the best pros.", style: const TextStyle(color: textGray)),
                const SizedBox(height: 40),

                if (isRegistering) ...[
                  TextField(controller: nameCtrl, decoration: InputDecoration(labelText: "Full Name", prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white)),
                  const SizedBox(height: 16),
                  
                  // --- ROLE DROPDOWN ADDED HERE ---
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: "I am a...",
                      prefixIcon: const Icon(Icons.badge),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'client', child: Text('Client (Hiring)')),
                      DropdownMenuItem(value: 'worker', child: Text('Worker (Finding Jobs)')),
                    ],
                    onChanged: (val) => setState(() => selectedRole = val!),
                  ),
                  const SizedBox(height: 16),
                ],

                TextField(controller: emailCtrl, decoration: InputDecoration(labelText: "Email", prefixIcon: const Icon(Icons.email_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white)),
                const SizedBox(height: 16),
                TextField(controller: passCtrl, obscureText: !isPasswordVisible, decoration: InputDecoration(labelText: "Password", prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white)),
                if (error.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Text(error, style: const TextStyle(color: Colors.red))),
                const SizedBox(height: 24),

                SizedBox(width: double.infinity, height: 56, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: primaryNavy, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: submit, child: Text(isRegistering ? "Create Account" : "Sign In", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
                const SizedBox(height: 16),
                TextButton(onPressed: () => setState(() => isRegistering = !isRegistering), child: Text(isRegistering ? "Already have an account? Sign In" : "Don't have an account? Create one", style: const TextStyle(color: primaryNavy, fontWeight: FontWeight.bold))),
                const SizedBox(height: 24),
                const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("OR", style: TextStyle(color: textGray))), Expanded(child: Divider())]),
                const SizedBox(height: 24),
                SizedBox(width: double.infinity, height: 56, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), icon: const Icon(Icons.g_mobiledata, size: 40, color: Colors.blue), label: const Text("Continue with Google", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), onPressed: () => context.read<AuthProvider>().loginWithGoogle())),
              ],
            ),
          ),
        ),
      ),
    );
  }
}