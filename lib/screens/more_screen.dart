import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/session_manager.dart';
import '../services/database_service.dart';
import '../models/user_profile.dart';
import 'auth/login_screen.dart';

class MoreScreen extends StatefulWidget {
  @override
  _MoreScreenState createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  bool _biometricsEnabled = false;
  String _currency = 'USD';
  String _themeMode = 'Light';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadSettings();
  }

  Future<void> _loadUserProfile() async {
    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    final userProfile = await databaseService.getUserProfile();
    
    setState(() {
      _userProfile = userProfile;
      _isLoading = false;
    });
  }

  Future<void> _loadSettings() async {
    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    final settings = await databaseService.getSettings();
    
    setState(() {
      _notificationsEnabled = settings['notificationsEnabled'] == 1;
      _biometricsEnabled = settings['biometricsEnabled'] == 1;
      _currency = settings['currency'] ?? 'USD';
      _themeMode = settings['themeMode'] ?? 'Light';
    });
  }

  Future<void> _saveUserProfile(UserProfile updatedProfile) async {
    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    await databaseService.saveUserProfile(updatedProfile);
    
    setState(() {
      _userProfile = updatedProfile;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile updated successfully'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _saveSettings() async {
    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    await databaseService.saveSettings({
      'notificationsEnabled': _notificationsEnabled ? 1 : 0,
      'biometricsEnabled': _biometricsEnabled ? 1 : 0,
      'currency': _currency,
      'themeMode': _themeMode,
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Settings saved successfully'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionManager = Provider.of<SessionManager>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'More',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Color(0xFF9B6DFF)),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF9B6DFF)))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // User Profile Header
                  _buildUserHeader(),
                  
                  // Account Section
                  _buildSectionHeader('Account'),
                  _buildListTile(
                    icon: Icons.person_outline,
                    title: 'Profile',
                    color: Colors.blue,
                    onTap: () {
                      _showEditProfileDialog();
                    },
                  ),
                  _buildListTile(
                    icon: Icons.security_outlined,
                    title: 'Privacy & Security',
                    color: Colors.green,
                    onTap: () {
                      _showPrivacySettings();
                    },
                  ),
                  
                  // App Settings Section
                  _buildSectionHeader('Preferences'),
                  _buildSwitchTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    color: Colors.orange,
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      _saveSettings();
                    },
                  ),
                  _buildSwitchTile(
                    icon: Icons.fingerprint_outlined,
                    title: 'Biometric Login',
                    color: Colors.purple,
                    value: _biometricsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _biometricsEnabled = value;
                      });
                      _saveSettings();
                    },
                  ),
                  _buildSelectionTile(
                    icon: Icons.currency_exchange_outlined,
                    title: 'Currency',
                    color: Colors.teal,
                    value: _currency,
                    onTap: () {
                      _showCurrencySelection();
                    },
                  ),
                  _buildSelectionTile(
                    icon: Icons.brightness_6_outlined,
                    title: 'Theme',
                    color: Colors.indigo,
                    value: _themeMode,
                    onTap: () {
                      _showThemeSelection();
                    },
                  ),
                  
                  // Budget Section
                  _buildSectionHeader('Budget'),
                  _buildListTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Budget Limits',
                    color: Color(0xFF9B6DFF),
                    onTap: () {
                      _showBudgetLimits();
                    },
                  ),
                  _buildListTile(
                    icon: Icons.category_outlined,
                    title: 'Manage Categories',
                    color: Colors.blueGrey,
                    onTap: () {
                      _showCategoryManagement();
                    },
                  ),
                  
                  // Support Section
                  _buildSectionHeader('Support'),
                  _buildListTile(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    color: Colors.blueGrey,
                    onTap: () {
                      _showHelpSupport();
                    },
                  ),
                  _buildListTile(
                    icon: Icons.feedback_outlined,
                    title: 'Send Feedback',
                    color: Colors.teal,
                    onTap: () {
                      _showFeedbackForm();
                    },
                  ),
                  _buildListTile(
                    icon: Icons.info_outline,
                    title: 'About',
                    color: Colors.indigo,
                    onTap: () {
                      _showAboutDialog();
                    },
                  ),
                  
                  // Data Management
                  _buildSectionHeader('Data'),
                  _buildListTile(
                    icon: Icons.backup_outlined,
                    title: 'Backup & Restore',
                    color: Colors.blue,
                    onTap: () {
                      _showBackupOptions();
                    },
                  ),
                  _buildListTile(
                    icon: Icons.delete_outline,
                    title: 'Clear Data',
                    color: Colors.red,
                    onTap: () {
                      _showClearDataDialog();
                    },
                  ),
                  
                  // Logout Section
                  SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: _buildListTile(
                        icon: Icons.logout,
                        title: 'Logout',
                        color: Colors.red,
                        onTap: () async {
                          await _showLogoutConfirmationDialog(context, sessionManager);
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  
                  // App Version
                  Text(
                    'BudgetBunny v1.0.0',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Color(0xFF9B6DFF).withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(0xFF9B6DFF).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.person,
              size: 35,
              color: Color(0xFF9B6DFF),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userProfile?.name ?? 'Your Name',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _userProfile?.email ?? 'user@example.com',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: Color(0xFF9B6DFF)),
            onPressed: () {
              _showEditProfileDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Color(0xFF9B6DFF),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  Widget _buildSelectionTile({
    required IconData icon,
    required String title,
    required Color color,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          SizedBox(width: 4),
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
        ],
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _userProfile?.name);
    final emailController = TextEditingController(text: _userProfile?.email);
    final phoneController = TextEditingController(text: _userProfile?.phone);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedProfile = UserProfile(
                  name: nameController.text,
                  email: emailController.text,
                  phone: phoneController.text,
                );
                _saveUserProfile(updatedProfile);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF9B6DFF),
                foregroundColor: Colors.white,
              ),
              child: Text('Save'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  void _showCurrencySelection() {
    final currencies = ['USD', 'EUR', 'GBP', 'JPY', 'INR', 'CAD', 'AUD'];
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Currency'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: currencies.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(currencies[index]),
                  trailing: _currency == currencies[index]
                      ? Icon(Icons.check, color: Color(0xFF9B6DFF))
                      : null,
                  onTap: () {
                    setState(() {
                      _currency = currencies[index];
                    });
                    _saveSettings();
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  void _showThemeSelection() {
    final themes = ['Light', 'Dark', 'System'];
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Theme'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: themes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(themes[index]),
                  trailing: _themeMode == themes[index]
                      ? Icon(Icons.check, color: Color(0xFF9B6DFF))
                      : null,
                  onTap: () {
                    setState(() {
                      _themeMode = themes[index];
                    });
                    _saveSettings();
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  void _showPrivacySettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Privacy & Security'),
          content: Text('Privacy settings will be implemented in a future update.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  void _showBudgetLimits() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Budget Limits'),
          content: Text('Budget limits management will be implemented in a future update.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  void _showCategoryManagement() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Manage Categories'),
          content: Text('Category management will be implemented in a future update.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  void _showHelpSupport() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Help & Support'),
          content: Text('Help and support resources will be implemented in a future update.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  void _showFeedbackForm() {
    final feedbackController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Send Feedback'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('We\'d love to hear your feedback!'),
              SizedBox(height: 16),
              TextField(
                controller: feedbackController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Enter your feedback here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // In a real app, you would send this feedback to your server
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Thank you for your feedback!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF9B6DFF),
                foregroundColor: Colors.white,
              ),
              child: Text('Send'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'BudgetBunny',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2023 BudgetBunny. All rights reserved.',
      children: [
        SizedBox(height: 16),
        Text('A smart finance management app to track your expenses and income.'),
      ],
    );
  }

  void _showBackupOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Backup & Restore'),
          content: Text('Backup and restore functionality will be implemented in a future update.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear All Data'),
          content: Text('Are you sure you want to clear all your data? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Implement clear data functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('All data has been cleared'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pop();
              },
              child: Text('Clear', style: TextStyle(color: Colors.red)),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  Future<void> _showLogoutConfirmationDialog(
      BuildContext context, SessionManager sessionManager) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await sessionManager.clearSession();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              },
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}