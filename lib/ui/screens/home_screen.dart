import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import '../../providers/student_provider.dart';
import '../../models/student_model.dart';
import '../widgets/glass_container.dart';
import 'registration_screen.dart';
import 'edit_student_screen.dart';
import 'login_screen.dart';
import 'roles_permissions_screen.dart';
import '../../providers/admin_permission_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Dashboard' : 'Student List', style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E1E2C),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF1E1E2C),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primaryColor),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.white),
              title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() {
                  _currentIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: Colors.white),
              title: const Text('Admin', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.security, color: Colors.white),
              title: const Text('Roles & Permissions', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RolesPermissionsScreen()),
                );
              },
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', false);
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: IndexedStack(
            index: _currentIndex,
            children: const [
              DashboardSection(),
              AdminSection(),
            ],
          ),
        ),
      ),
    );
  }
}



class DashboardSection extends StatelessWidget {
  const DashboardSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Dashboard Overview',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Student>>(
            stream: context.read<StudentProvider>().getStudents(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }

              final students = snapshot.data ?? [];
              final totalRegistered = students.length;
              final passedPreviousClass = students.where((s) => s.passedPreviousClass).length;
              const totalSeats = 100;
              final availableSeats = totalSeats - totalRegistered;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildEnhancedStatCard(
                      'Total Students',
                      totalRegistered.toString(),
                      Icons.people,
                      Colors.blueAccent,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildEnhancedStatCard(
                            'Available Seats',
                            availableSeats.toString(),
                            Icons.event_seat,
                            Colors.greenAccent,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildEnhancedStatCard(
                            'Passed Students',
                            passedPreviousClass.toString(),
                            Icons.grade,
                            Colors.orangeAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            'Registration Progress',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          LinearProgressIndicator(
                            value: totalRegistered / totalSeats,
                            backgroundColor: Colors.white10,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentColor),
                            minHeight: 10,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${((totalRegistered / totalSeats) * 100).toStringAsFixed(1)}% Capacity Filled',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedStatCard(String title, String value, IconData icon, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AdminSection extends StatefulWidget {
  const AdminSection({Key? key}) : super(key: key);

  @override
  State<AdminSection> createState() => _AdminSectionState();
}

class _AdminSectionState extends State<AdminSection> {
  String _selectedRole = 'Basic Admin';
  final List<String> _roles = ['Basic Admin', 'Intermediate Admin', 'Super Admin'];

  @override
  Widget build(BuildContext context) {
    final permissionProvider = context.watch<AdminPermissionProvider>();
    final permissions = permissionProvider.getPermissionsFor(_selectedRole);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Student List',
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.security, color: AppColors.accentColor, size: 24),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RolesPermissionsScreen()),
                          );
                        },
                        tooltip: 'Privilege Control',
                      ),
                      if (permissions.write)
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white, size: 30),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RegistrationScreen()),
                            );
                          },
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    dropdownColor: const Color(0xFF1E1E2C),
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    items: _roles.map((String role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role, style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedRole = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: !permissions.read
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock, color: Colors.white24, size: 60),
                      SizedBox(height: 10),
                      Text('No Read Permission', style: TextStyle(color: Colors.white70, fontSize: 18)),
                    ],
                  ),
                )
              : StreamBuilder<List<Student>>(
                  stream: context.read<StudentProvider>().getStudents(),
                  builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
              }

              final students = snapshot.data ?? [];

              if (students.isEmpty) {
                return const Center(child: Text('No students registered yet', style: TextStyle(color: Colors.white70)));
              }

              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.75,
                ),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return _buildStudentCard(student, permissions);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(Student student, AdminPermissions permissions) {
    return GestureDetector(
      onTap: () => _showStudentDetails(context, student),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: student.photoUrl.isNotEmpty
                    ? Image.memory(base64Decode(student.photoUrl), fit: BoxFit.cover)
                    : Container(
                        color: Colors.white10,
                        child: const Icon(Icons.person, size: 50, color: Colors.white30),
                      ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Class: ${student.previousClass}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (permissions.write || permissions.delete)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (permissions.write)
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => EditStudentScreen(student: student)),
                                );
                              },
                            ),
                          if (permissions.write && permissions.delete) const SizedBox(width: 15),
                          if (permissions.delete)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _confirmDelete(context, student),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStudentDetails(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2C),
          title: Text(student.name, style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (student.photoUrl.isNotEmpty)
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: MemoryImage(base64Decode(student.photoUrl)),
                  ),
                ),
              const SizedBox(height: 15),
              Text('Age: ${student.age}', style: const TextStyle(color: Colors.white70)),
              Text('Address: ${student.address}', style: const TextStyle(color: Colors.white70)),
              Text('Previous Class: ${student.previousClass}', style: const TextStyle(color: Colors.white70)),
              Text('Passed: ${student.passedPreviousClass ? "Yes" : "No"}', style: const TextStyle(color: Colors.white70)),
              Text('Mobile: ${student.mobile}', style: const TextStyle(color: Colors.white70)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: AppColors.accentColor)),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2C),
          title: const Text('Delete Student', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure you want to delete ${student.name}?', style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final success = await context.read<StudentProvider>().deleteStudent(student.id!);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student deleted successfully')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete student')));
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }
}
