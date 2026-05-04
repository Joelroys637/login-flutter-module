import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/admin_permission_provider.dart';

class RolesPermissionsScreen extends StatefulWidget {
  const RolesPermissionsScreen({Key? key}) : super(key: key);

  @override
  State<RolesPermissionsScreen> createState() => _RolesPermissionsScreenState();
}

class _RolesPermissionsScreenState extends State<RolesPermissionsScreen> {
  String _selectedAdmin = 'Basic Admin';
  final List<String> _admins = ['Basic Admin', 'Intermediate Admin', 'Super Admin'];
  
  // Local state for permissions before saving
  late bool _read;
  late bool _write;
  late bool _delete;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _loadPermissions();
      _isInitialized = true;
    }
  }

  void _loadPermissions() {
    final provider = Provider.of<AdminPermissionProvider>(context, listen: false);
    final p = provider.getPermissionsFor(_selectedAdmin);
    _read = p.read;
    _write = p.write;
    _delete = p.delete;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12121A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Admin to Configure',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  _buildAdminDropdown(),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Controls',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildControlItem('Write', _write, (val) {
                          setState(() => _write = val);
                        }),
                        _buildControlItem('Read', _read, (val) {
                          setState(() => _read = val);
                        }),
                        _buildControlItem('Delete', _delete, (val) {
                          setState(() => _delete = val);
                        }),
                        _buildControlItem('All', _write && _read && _delete, (val) {
                          setState(() {
                            _write = val;
                            _read = val;
                            _delete = val;
                          });
                        }),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Roles & Permissions',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                children: const [
                  Text('Home', style: TextStyle(color: Colors.white54, fontSize: 14)),
                  Icon(Icons.chevron_right, color: Colors.white54, size: 16),
                  Text('Roles', style: TextStyle(color: Colors.white54, fontSize: 14)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              _buildActionButton('Back', Icons.arrow_back, const Color(0xFF00BCD4), () => Navigator.pop(context)),
              const SizedBox(width: 10),
              _buildActionButton('Save', null, const Color(0xFF00E5FF), () async {
                final provider = Provider.of<AdminPermissionProvider>(context, listen: false);
                await provider.updatePermission(
                  _selectedAdmin,
                  read: _read,
                  write: _write,
                  delete: _delete,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Permissions Saved to Firebase')),
                  );
                }
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData? icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (icon != null) ...[Icon(icon, size: 16, color: Colors.black), const SizedBox(width: 4)],
            Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedAdmin,
          dropdownColor: const Color(0xFF1E1E2C),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00BCD4)),
          items: _admins.map((String admin) {
            return DropdownMenuItem<String>(
              value: admin,
              child: Text(admin, style: const TextStyle(color: Colors.white, fontSize: 18)),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedAdmin = newValue;
                _loadPermissions();
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildControlItem(String label, bool value, Function(bool) onChanged) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: value ? const Color(0xFF00E5FF) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24, width: 2),
            ),
            child: value
                ? const Icon(Icons.check, color: Colors.black, size: 40)
                : null,
          ),
        ),
      ],
    );
  }
}
