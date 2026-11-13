import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/sign_in_dashboard.dart';
import 'screens/main_navigation.dart';
<<<<<<< HEAD
import 'screens/worker_dashboard.dart'; 
=======
import 'screens/worker_dashboard.dart'; // ADD THIS IMPORT
>>>>>>> 442337e284513d10fd81b7622f5f6d52596e3e26
import 'core/theme.dart';

// ... (keep void main() the same) ...

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SkillsShare',
      theme: appTheme,
      home: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if (auth.isAuthenticated) {
            if (auth.userRole == 'worker') {
<<<<<<< HEAD
              return const WorkerDashboard(); 
            } else {
              return const MainNavigation(); 
=======
              return const WorkerDashboard(); // Route to worker UI
            } else {
              return const MainNavigation(); // Route to client UI
>>>>>>> 442337e284513d10fd81b7622f5f6d52596e3e26
            }
          } else {
            return const SignInDashboard(); 
          }
        },
      ),
    );
  }
}