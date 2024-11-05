// ignore_for_file: library_private_types_in_public_api, empty_catches

import 'package:flutter/material.dart';
import 'api_service.dart';
import 'login_page.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  _EmployeeDashboardState createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  final ApiService apiService = ApiService();
  Map<String, dynamic>? employeeData;
  Map<String, dynamic>? latestSalary;
  List<dynamic> salaries = [];
  String currentMonth = 'Loading...'; // Default month display

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    try {
      final userData = await apiService.getUserData();
      if (userData != null) {
        await _loadEmployeeDetails();
      } else {
        _redirectToLogin();
      }
    } catch (e) {
      _redirectToLogin();
    }
  }

  Future<void> _loadEmployeeDetails() async {
    try {
      final response = await apiService.getEmployeeDetails();
      setState(() {
        employeeData = response?['employee'];
        latestSalary = response?['latestSalary'];
        salaries = response?['salaries'] ?? [];
        currentMonth = '${latestSalary?['year']}-${latestSalary?['month']}';
      });
    } catch (e) {}
  }

  Future<void> _loadSpecificSalary(int id) async {
    try {
      final salaryDetails = await apiService.loadSalaryDetails(id);
      setState(() {
        latestSalary = salaryDetails;
        currentMonth = '${salaryDetails?['year']}-${salaryDetails?['month']}';
      });
    } catch (e) {}
  }

  Future<void> _logout() async {
    try {
      await apiService.logout();
      await apiService.clearUserData();
      _redirectToLogin();
    } catch (e) {}
  }

  void _redirectToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCenteredProfileCard(),
              const SizedBox(height: 20),
              Text(
                'Salary Details ($currentMonth)', // Updates dynamically
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF005CB2),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              _buildDetailedSalaryCards(), // All required salary fields
              const SizedBox(height: 20),
              const Text(
                'Previous Salaries',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF005CB2),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Flexible(
                child: SingleChildScrollView(
                  child: _buildPreviousSalariesColumn(),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005CB2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenteredProfileCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(16.0),
        child: employeeData == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${employeeData?['first_name']} ${employeeData?['last_name']}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF005CB2),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'User ID: ${employeeData?['user_id']}',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Position: ${employeeData?['position']}',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Joined: ${employeeData?['joining_date']}',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'ُEmail Address: ${employeeData?['email_address']}',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDetailedSalaryCards() {
    final salaryFields = {
      'Gross Salary': latestSalary?['gross_salary'],
      'Commission': latestSalary?['commission'],
      'Salaf': latestSalary?['salaf'],
      'Salaf Deducted': latestSalary?['salaf_deducted'],
      'Working Days': latestSalary?['working_days'],
      'Unpaid Days': latestSalary?['unpaid_days'],
      'Sick Leave': latestSalary?['sick_leave'],
      'Annual Days Off': latestSalary?['remaining_annual_days_off'],
      'Deduction': latestSalary?['deduction'],
      'Bonus': latestSalary?['bonus'],
      'Salary to Be Paid': latestSalary?['salary_to_be_paid'],
    };

    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: salaryFields.entries.map((entry) {
          return _buildSalaryCard(entry.key, entry.value?.toString() ?? 'N/A');
        }).toList(),
      ),
    );
  }

  Widget _buildSalaryCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFB3D7FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF005CB2),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF005CB2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousSalariesColumn() {
    return Column(
      children: salaries.map((salary) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: ElevatedButton(
            onPressed: () => _loadSpecificSalary(salary['id']),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB3D7FF),
              foregroundColor: const Color(0xFF005CB2),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('${salary['year']}-${salary['month']}'),
          ),
        );
      }).toList(),
    );
  }
}
