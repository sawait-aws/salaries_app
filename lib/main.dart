// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'manager_dashboard.dart';
import 'employee_dashboard.dart';
import 'login_page.dart';
import 'api_service.dart'; // Ensure this is included

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure all async tasks complete
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salaries App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // Start with the splash/loading screen
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus(); // Check if the user is authenticated
  }

  Future<void> _checkAuthStatus() async {
    try {
      // Retrieve token and role using getUserData()
      final Map<String, String?>? userData = await _apiService.getUserData();

      if (userData != null) {
        final String? token = userData['token'];
        final String? role = userData['role'];

        // Navigate to the appropriate dashboard if token and role exist
        if (token != null && role != null) {
          if (role == 'manager') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const ManagerDashboard()),
              (Route<dynamic> route) => false, // Clear all previous routes
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => EmployeeDashboard()),
              (Route<dynamic> route) => false, // Clear all previous routes
            );
          }
        } else {
          _redirectToLogin();
        }
      } else {
        _redirectToLogin();
      }
    } catch (e) {
      _redirectToLogin();
    }
  }

  void _redirectToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false, // Clear all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body:
          Center(child: CircularProgressIndicator()), // Show loading indicator
    );
  }
}
