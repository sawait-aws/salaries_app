// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'api_service.dart'; // Make sure to import your API service
import 'manager_dashboard.dart';

class EditEmployeePage extends StatefulWidget {
  final String employeeId; // Adding employeeId as a required parameter
  final Map<String, dynamic>
      employeeDetails; // Expecting a map of employee details

  const EditEmployeePage({
    super.key,
    required this.employeeId,
    required this.employeeDetails,
  });

  @override
  _EditEmployeePageState createState() => _EditEmployeePageState();
}

class _EditEmployeePageState extends State<EditEmployeePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _joiningDateController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService apiService = ApiService();
  @override
  void initState() {
    super.initState();
    // Set initial values from employeeDetails
    _firstNameController.text = widget.employeeDetails['first_name'];
    _lastNameController.text = widget.employeeDetails['last_name'];
    _positionController.text = widget.employeeDetails['position'];
    _joiningDateController.text = widget.employeeDetails['joining_date'];
    _userIdController.text = widget.employeeDetails['user_id'].toString();
    // Password remains blank for security
  }

  Future<void> _editEmployee() async {
    String employeeId = widget.employeeId;
    String message = await apiService.editEmployee(
      employeeId,
      _firstNameController.text,
      _lastNameController.text,
      _positionController.text,
      _joiningDateController.text,
      _userIdController.text,
      _passwordController.text,
    );

    // Show a message and navigate back to the dashboard
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    // Navigate to the manager dashboard and remove all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ManagerDashboard()), // Replace with your actual manager dashboard widget
      (route) => false, // This removes all previous routes from the stack
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Employee'),
      ),
      body: _buildEditEmployeeForm(),
    );
  }

  Widget _buildEditEmployeeForm() {
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _editEmployee,
              child: const Text('Update Employee'),
            ),
          ],
        ),
      ),
    );
  }
}
