// ignore_for_file: empty_catches, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'api_service.dart';
import 'login_page.dart';
import 'package:lean_file_picker/lean_file_picker.dart';
import 'EmployeeViewAsManager.dart';

class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  final ApiService apiService = ApiService();
  Map<String, dynamic>? manager; // Holds manager details.
  List<Map<String, dynamic>> employees = []; // Holds employee list.
  String? selectedFilePath; // Store the path of the selected CSV file.
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _joiningDateController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? selectedFileName; // Variable to hold the selected file name

  @override
  void initState() {
    super.initState();
    _loadDashboardData(); // Trigger data load on screen load.
  }

  Future<void> _loadDashboardData() async {
    try {
      // Call the API service to fetch the manager dashboard data.
      final response = await ApiService().getManagerDashboardData();

      if (response != null) {
        setState(() {
          // Safely extract and cast the employees list from the response.
          final employeesData = response['employees'] as List<dynamic>?;

          if (employeesData != null) {
            employees = employeesData
                .map((e) => Map<String, dynamic>.from(e))
                .toList(); // Convert each employee to a Map.
          } else {
            employees = []; // Fallback in case of null.
          }

          // Safely extract the manager data from the response.
          manager = response['manager'] as Map<String, dynamic>?;
        });
      } else {
        // Handle the scenario when the response is null (e.g., API call failed).
        setState(() {
          employees = [];
          manager = null;
        });
      }
    } catch (e) {
      // Handle errors gracefully.
      setState(() {
        employees = [];
        manager = null;
      });
    }
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Manager Profile Header
              if (manager != null) _buildManagerHeader(),

              const SizedBox(height: 20),

              // Employees Section Title
              const Text(
                'Employees',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF005CB2),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Employee Cards
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: employees
                      .map((employee) => Padding(
                            padding: const EdgeInsets.only(
                                right: 8.0), // Space between cards
                            child: _buildEmployeeCard(employee),
                          ))
                      .toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Add Employee Form
              _buildAddEmployeeForm(),

              const SizedBox(height: 20),

              // CSV Upload Section
              _buildCsvUploadSection(),
            ],
          ),
        ),
      ),
    );
  }

  // Manager Header Widget
  Widget _buildManagerHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${manager!['first_name']} ${manager!['last_name']}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF005CB2),
              ),
            ),
            const SizedBox(height: 8),
            Text('User ID: ${manager!['user_id']}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF005CB2),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Employee Card Widget
  Widget _buildEmployeeCard(Map<String, dynamic> employee) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                EmployeeViewAsManager(employeeId: employee['id']),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(12.0),
          decoration: const BoxDecoration(
            color: Color(0xFFB3D7FF),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${employee['first_name']} ${employee['last_name']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF005CB2),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text('User ID: ${employee['user_id']}'),
              Text('Position: ${employee['position']}'),
              const Text('Joining Date:'),
              Text('${employee['joining_date']}'),
            ],
          ),
        ),
      ),
    );
  }

  // Add Employee Form Widget
  Widget _buildAddEmployeeForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _positionController,
                    decoration: const InputDecoration(labelText: 'Position'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _joiningDateController,
                    decoration: const InputDecoration(
                      labelText: 'Joining Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        _joiningDateController.text = date.toIso8601String();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _userIdController,
                    decoration: const InputDecoration(labelText: 'User ID'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _addEmployee,
              child: const Text('Add Employee'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addEmployee() async {
    // Collect the data from the form fields.
    final employeeData = {
      "first_name": _firstNameController.text,
      "last_name": _lastNameController.text,
      "position": _positionController.text,
      "joining_date": _joiningDateController.text,
      "user_id": _userIdController.text,
      "password": _passwordController.text,
    };

    try {
      // Call the API service to add the employee.
      final response = await apiService.addEmployee(employeeData);

      if (response != null &&
          response['message'] == 'Employee added successfully.') {
        // Reload the dashboard to reflect the new employee.
        _loadDashboardData();
        _firstNameController.clear();
        _lastNameController.clear();
        _positionController.clear();
        _joiningDateController.clear();
        _userIdController.clear();
        _passwordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee added successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add employee.')),
        );
      }
    } catch (e) {
      // Handle errors gracefully.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  // CSV Upload Section Widget
  Widget _buildCsvUploadSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Upload Salary Data (CSV)'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _chooseFile, // Call the method to choose a file
                    child: const Text('Choose File'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _uploadSalaries, // Call the upload function
                  child: const Text('Upload'),
                ),
              ],
            ),
            if (selectedFileName != null) ...[
              const SizedBox(height: 8),
              Text(
                  'Selected File: $selectedFileName'), // Display the selected file
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _chooseFile() async {
    // Use Lean File Picker to select a CSV file
    final file = await pickFile(
      allowedExtensions: ['csv'], // Only allow CSV files
      allowedMimeTypes: ['text/csv'], // CSV MIME type
    );

    if (file != null) {
      setState(() {
        selectedFilePath = file.path; // Get the selected file path
        selectedFileName = getFileName(selectedFilePath!);
      });
    } else {
      // Handle the case when no file is selected
    }
  }

  Future<void> _uploadSalaries() async {
    if (selectedFilePath != null) {
      // Call the API to upload the salaries
      final response = await apiService.uploadSalaries(selectedFilePath!);

      if (response != null &&
          response['message'] == 'Salaries uploaded successfully.') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Salaries uploaded successfully!')),
        );

        // Reset the file selection after successful upload
        setState(() {
          selectedFilePath = null;
          selectedFileName = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload salaries.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a file first.')),
      );
    }
  }

  String getFileName(String filePath) {
    // Split the file path by the '/' or '\' and get the last segment
    return filePath.split('/').last.split('\\').last;
  }
}
