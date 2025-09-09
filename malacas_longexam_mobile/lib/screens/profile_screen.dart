import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:malacas_longexam_mobile/services/user_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>> getUserData() async {
    UserService userService = UserService();
    final userData = await userService.getUserData();
    return userData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No user data found"));
          }

          final userData = snapshot.data!;

          return SingleChildScrollView(
            padding: EdgeInsets.all(20.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: 20),
                Text(
                  "${userData['firstName']} ${userData['lastName']}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  userData['email'] ?? "",
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),

                // Card for details
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      buildInfoTile("User Type", userData['type']),
                      // buildInfoTile("Username", userData['username']),
                      // buildInfoTile("Age", userData['age']),
                      // buildInfoTile("Gender", userData['gender']),
                      // buildInfoTile("Contact Number", userData['contactNumber']),
                      // buildInfoTile("Address", userData['address']),
                      // buildInfoTile("Status", userData['isActive'] == true ? "Active" : "Inactive"),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Reusable ListTile widget
  Widget buildInfoTile(String title, dynamic value) {
    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value?.toString() ?? ""),
    );
  }
}
