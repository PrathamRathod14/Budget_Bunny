import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/database_service.dart';
import '../../services/session_manager.dart';
import '../../models/category.dart';

class CategorySelectionScreen extends StatefulWidget {
  final String type;

  CategorySelectionScreen({required this.type});

  @override
  _CategorySelectionScreenState createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  List<Category> _categories = [];
  bool _isLoading = true;
  final TextEditingController _newCategoryController = TextEditingController();
  final TextEditingController _newIconController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    final categories = await databaseService.getCategories();
    
    setState(() {
      _categories = categories.where((c) => c.type == widget.type).toList();
      _isLoading = false;
    });
  }

  Future<void> _createNewCategory() async {
    if (_newCategoryController.text.isEmpty) return;

    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    final sessionManager = Provider.of<SessionManager>(context, listen: false);
    final userId = await sessionManager.getUserId();

    final newCategory = Category(
      id: '',
      name: _newCategoryController.text,
      type: widget.type,
      icon: _newIconController.text.isNotEmpty ? _newIconController.text : '💰',
      userId: userId!, // Use the actual userId
    );

    final success = await databaseService.addCategory(newCategory);
    
    if (success) {
      _newCategoryController.clear();
      _newIconController.clear();
      _loadCategories(); // Reload categories
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category created successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create category'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _showCreateCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Create New ${widget.type.capitalize()} Category',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _newCategoryController,
                  decoration: InputDecoration(
                    labelText: 'Category Name',
                    labelStyle: TextStyle(color: Colors.grey.shade600),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF9B6DFF)),
                    ),
                  ),
                  autofocus: true,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _newIconController,
                  decoration: InputDecoration(
                    labelText: 'Icon (Optional - e.g., 🏠, 🚗, 🍔)',
                    labelStyle: TextStyle(color: Colors.grey.shade600),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF9B6DFF)),
                    ),
                  ),
                  maxLength: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _createNewCategory();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF9B6DFF),
                foregroundColor: Colors.white,
              ),
              child: Text('Create'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Select ${widget.type.capitalize()} Category',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Color(0xFF9B6DFF)),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Color(0xFF9B6DFF)),
            onPressed: _showCreateCategoryDialog,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFF9B6DFF),
              ),
            )
          : Column(
              children: [
                // Create New Category Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _showCreateCategoryDialog,
                      icon: Icon(Icons.add, color: Color(0xFF9B6DFF)),
                      label: Text(
                        'Create New Category',
                        style: TextStyle(color: Color(0xFF9B6DFF)),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: Color(0xFF9B6DFF)),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _categories.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.category,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No categories found',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap the + button to create a new category',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            return Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF9B6DFF).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      category.icon,
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  category.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey.shade400,
                                ),
                                onTap: () {
                                  Navigator.pop(context, category.name);
                                },
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}