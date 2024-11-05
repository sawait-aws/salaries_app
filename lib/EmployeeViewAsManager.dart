// ignore_for_file: library_private_types_in_public_api, file_names, empty_catches, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'api_service.dart';
import 'manager_dashboard.dart';
import 'EditEmployeePage.dart';

class EmployeeViewAsManager extends StatefulWidget {
  final int employeeId; // ID of the employee

  const EmployeeViewAsManager({super.key, required this.employeeId});

  @override
  _EmployeeViewAsManagerState createState() => _EmployeeViewAsManagerState();
}

class _EmployeeViewAsManagerState extends State<EmployeeViewAsManager> {
  final ApiService apiService = ApiService();
  Map<String, dynamic>? employeeData;
  Map<String, dynamic>? latestSalary;
  List<dynamic> salaries = [];
  String currentMonth = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadEmployeeData(); // Fetch employee details when screen opens
  }

  Future<void> _loadEmployeeData() async {
    try {
      final data = await apiService.viewEmployeeAsManager(widget.employeeId);
      if (data != null) {
        setState(() {
          employeeData = data['employee'];
          latestSalary = data['latestSalary'];
          salaries = data['salaries'] ?? [];
          currentMonth = '${latestSalary?['year']}-${latestSalary?['month']}';
        });
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FF),
      appBar: AppBar(
        title: const Text('Employee Details'),
        backgroundColor: const Color(0xFF005CB2),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCenteredProfileCard(),
              const SizedBox(height: 20),
              Text(
                'Salary Details ($currentMonth)',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF005CB2),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              _buildDetailedSalaryCards(),
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
              _buildActionButtons(),
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
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: employeeData == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Text(
                    'Viewing Employee as Manager',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                  Text('User ID: ${employeeData?['user_id']}'),
                  Text('Position: ${employeeData?['position']}'),
                  Text('Joined: ${employeeData?['joining_date']}'),
                  Text('Email Address: ${employeeData?['email_address']}'),
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF005CB2),
              ),
              textAlign: TextAlign.center,
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

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditEmployeePage(
                  employeeId:
                      employeeData!['id'].toString(), // Ensure this is a string
                  employeeDetails: {
                    'first_name': employeeData?['first_name'],
                    'last_name': employeeData?['last_name'],
                    'position': employeeData?['position'],
                    'joining_date': employeeData?['joining_date'],
                    'email_address': employeeData?['email_address'],
                    'user_id': employeeData?['user_id'],
                  },
                ),
              ),
            );
          },
          icon: const Icon(Icons.edit, color: Colors.white),
          label: const Text(
            'Edit',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF005CB2), // Blue color
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _confirmDeleteEmployee(employeeData?['id']),
          icon: const Icon(Icons.delete, color: Colors.white),
          label: const Text(
            'Delete',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF005CB2), // Blue color
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
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

  void _confirmDeleteEmployee(int employeeId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this employee?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _deleteEmployee(employeeId);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteEmployee(int employeeId) async {
    try {
      final message = await apiService.deleteEmployee(employeeId);
      if (message.contains('deleted successfully')) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        // Navigate back to the manager dashboard, clearing all previous screens
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ManagerDashboard()),
          (Route<dynamic> route) => false, // Remove all previous routes
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete employee.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting employee.')),
      );
    }
  }
}
