import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Add this import

class ApiService {
  final String baseUrl =
      'http://192.168.100.26:8000/api'; // Replace with your actual API URL

  // Sign in function (already implemented)
  Future<Map<String, dynamic>> signIn(String userId, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        throw Exception('Failed to sign in: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  // Local file methods (already implemented)
  final String dataFileName = 'user_data.txt';

  Future<File> _getLocalFile() async {
    final directory = Directory('/data/data/com.sawa.salaries_app/files');
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }
    return File('${directory.path}/$dataFileName');
  }

  Future<void> saveUserData(String token, String role) async {
    try {
      final file = await _getLocalFile();
      final data = jsonEncode({'token': token, 'role': role});
      await file.writeAsString(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, String>?> getUserData() async {
    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final Map<String, dynamic> data = jsonDecode(content);
        return {'token': data['token'], 'role': data['role']};
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // NEW: Clear user data (for logout)
  Future<void> clearUserData() async {
    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        await file.delete();
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  // NEW: Logout function
  Future<void> logout() async {
    try {
      final userData = await getUserData();
      if (userData != null) {
        final token = userData['token'];
        final url = Uri.parse('$baseUrl/logout');
        final response = await http.post(
          url,
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          await clearUserData();
        } else {
          throw Exception('Logout failed: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // NEW: Get employee details for the dashboard
  Future<Map<String, dynamic>?> getEmployeeDetails() async {
    try {
      final userData = await getUserData();
      if (userData != null) {
        final token = userData['token'];
        final url = Uri.parse('$baseUrl/employee/dashboard');
        final response = await http.get(
          url,
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data;
        } else {
          throw Exception('Failed to load employee details');
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> viewEmployeeAsManager(int id) async {
    try {
      final userData = await getUserData();
      if (userData != null) {
        final token = userData['token'];
        final url = Uri.parse('$baseUrl/manager/view-employee/$id');
        final response = await http.get(
          url,
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else {
          throw Exception('Failed to load employee details');
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // NEW: Load specific salary details when a salary box is tapped
  Future<Map<String, dynamic>?> loadSalaryDetails(int id) async {
    try {
      final userData = await getUserData();
      if (userData != null) {
        final token = userData['token'];
        final url = Uri.parse('$baseUrl/employee/load-salary/$id');
        final response = await http.get(
          url,
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data;
        } else {
          throw Exception('Failed to load salary details');
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getManagerDashboardData() async {
    try {
      // Retrieve the stored token from user data.
      final userData = await getUserData();
      if (userData != null) {
        final token = userData['token'];
        final url = Uri.parse('$baseUrl/manager/dashboard/');

        // Send GET request with token in the header.
        final response = await http.get(
          url,
          headers: {'Authorization': 'Bearer $token'},
        );

        // If the response is successful, decode and return the JSON data.
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data;
        } else {
          throw Exception('Failed to load manager dashboard data');
        }
      }
      return null; // Return null if user data is not found.
    } catch (e) {
      return null; // Handle errors gracefully.
    }
  }

  Future<Map<String, dynamic>?> addEmployee(
      Map<String, dynamic> employeeData) async {
    try {
      final userData = await getUserData(); // Retrieve the saved token
      if (userData != null) {
        final token = userData['token'];
        final url = Uri.parse('$baseUrl/manager/add-employee');

        final response = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(employeeData),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data;
        } else {
          throw Exception('Failed to add employee');
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> uploadSalaries(String filePath) async {
    try {
      final userData = await getUserData(); // Retrieve the saved token
      if (userData != null) {
        final token = userData['token'];
        final url = Uri.parse('$baseUrl/manager/upload-salaries');

        // Create a multipart request
        var request = http.MultipartRequest('POST', url)
          ..headers['Authorization'] = 'Bearer $token'
          ..files.add(
            await http.MultipartFile.fromPath(
              'csv_file', // Use the correct field name as expected by the API
              filePath,
              contentType: MediaType('text', 'csv'), // Set MIME type explicitly
            ),
          );

        // Send the request
        final response = await request.send();

        // Check the response status
        if (response.statusCode == 200) {
          final responseData = await response.stream.bytesToString();
          final data = jsonDecode(responseData);
          return data;
        } else {
          final errorResponse = await response.stream.bytesToString();
          throw Exception(
              'Failed to upload salaries: ${response.statusCode} - $errorResponse');
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String> deleteEmployee(int employeeId) async {
    try {
      final userData = await getUserData(); // Get the token
      if (userData != null) {
        final token = userData['token'];
        final url = Uri.parse('$baseUrl/manager/delete-employee/$employeeId');

        final response = await http.delete(
          url,
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['message'];
        } else {
          throw Exception('Failed to delete employee');
        }
      }
      return 'Unauthorized request';
    } catch (e) {
      return 'Error deleting employee';
    }
  }

  Future<String> editEmployee(
    String employeeId,
    String firstName,
    String lastName,
    String position,
    String joiningDate,
    String userId,
    String password,
  ) async {
    try {
      final userData = await getUserData(); // Get the token
      if (userData != null) {
        final token = userData['token'];
        final url = Uri.parse('$baseUrl/manager/edit-employee/$employeeId');

        // Prepare the body data for the PUT request
        final bodyData = {
          'first_name': firstName,
          'last_name': lastName,
          'position': position,
          'joining_date': joiningDate,
          'user_id': userId,
          'password': password.isEmpty ? null : password, // Optional password
        };

        final response = await http.put(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(bodyData),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['message'];
        } else {
          throw Exception('Failed to update employee');
        }
      }
      return 'Unauthorized request';
    } catch (e) {
      return 'Error updating employee';
    }
  }
}
