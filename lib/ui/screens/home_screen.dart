import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import 'dashboard_screen.dart';
import 'user_list_screen.dart';
import 'role_list_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const UserListScreen(),
    const RoleListScreen(),
  ];

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Dashboard', 'icon': Icons.dashboard_outlined, 'module': 'Dashboard'},
    {'title': 'Users', 'icon': Icons.people_outline, 'module': 'User'},
    {'title': 'Roles & Permissions', 'icon': Icons.security_outlined, 'module': 'Role & Permissions'},
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(_menuItems[_selectedIndex]['title'], style: const TextStyle(color: Color(0xFF1A1C1E), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1C1E)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () async {
              await auth.logout();
              if (mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primaryColor),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(user?.name.substring(0, 1).toUpperCase() ?? 'U', style: const TextStyle(color: AppColors.primaryColor, fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              accountName: Text(user?.name ?? 'Guest User', style: const TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text(user?.role ?? 'Role Not Assigned'),
            ),
            Expanded(
              child: Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  final visibleItems = _menuItems.where((item) => auth.hasPermission(item['module'], 'read')).toList();
                  
                  if (visibleItems.isEmpty) {
                    return const Center(child: Text('No access granted', style: TextStyle(color: Colors.grey)));
                  }

                  return ListView.builder(
                    itemCount: visibleItems.length,
                    itemBuilder: (context, index) {
                      final item = visibleItems[index];
                      // Find original index for selection state
                      final originalIndex = _menuItems.indexWhere((m) => m['title'] == item['title']);

                      return ListTile(
                        leading: Icon(item['icon'], color: _selectedIndex == originalIndex ? AppColors.primaryColor : Colors.grey),
                        title: Text(item['title'], style: TextStyle(color: _selectedIndex == originalIndex ? AppColors.primaryColor : Colors.black87, fontWeight: _selectedIndex == originalIndex ? FontWeight.bold : FontWeight.normal)),
                        onTap: () {
                          setState(() => _selectedIndex = originalIndex);
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
    );
  }
}
