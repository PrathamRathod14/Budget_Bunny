import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/database_service.dart';
import '../../services/session_manager.dart';
import '../../models/transaction.dart';
import 'category_selection_screen.dart';

class AddTransactionScreen extends StatefulWidget {
  final String? initialType;
  final Transaction? transaction; // Add this parameter for editing

  AddTransactionScreen({this.initialType, this.transaction}); // Update constructor

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedType = 'expense';
  String _selectedCategory = '';
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;
  bool _isEditing = false; // Add flag for editing mode

  @override
  void initState() {
    super.initState();
    
    // Initialize form with transaction data if editing
    if (widget.transaction != null) {
      _isEditing = true;
      final transaction = widget.transaction!;
      _selectedType = transaction.type;
      _selectedCategory = transaction.category;
      _selectedDate = transaction.date;
      _amountController.text = transaction.amount.toString();
      _descriptionController.text = transaction.description;
    } else if (widget.initialType != null) {
      _selectedType = widget.initialType!;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF9B6DFF),
              onPrimary: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectCategory() async {
    final selectedCategory = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategorySelectionScreen(type: _selectedType),
      ),
    );

    if (selectedCategory != null) {
      setState(() {
        _selectedCategory = selectedCategory;
      });
    }
  }

  Future<void> _submitTransaction() async {
    if (_formKey.currentState!.validate() && _selectedCategory.isNotEmpty) {
      setState(() {
        _isSubmitting = true;
      });
      
      final sessionManager = Provider.of<SessionManager>(context, listen: false);
      final databaseService = Provider.of<DatabaseService>(context, listen: false);
      
      final userId = await sessionManager.getUserId();
      
      final transaction = Transaction(
        id: _isEditing ? widget.transaction!.id : '', // Keep existing ID if editing
        userId: userId!,
        type: _selectedType,
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        description: _descriptionController.text,
        date: _selectedDate,
        createdAt: _isEditing ? widget.transaction!.createdAt : DateTime.now(), // Keep original creation date
      );

      bool success;
      if (_isEditing) {
        success = await databaseService.updateTransaction(transaction.id, transaction);
      } else {
        success = await databaseService.addTransaction(transaction);
      }
      
      setState(() {
        _isSubmitting = false;
      });
      
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Transaction updated successfully' : 'Transaction added successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Failed to update transaction' : 'Failed to add transaction'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } else if (_selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Transaction' : 'Add Transaction', // Dynamic title
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Color(0xFF9B6DFF)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Transaction Type Selector
              Container(
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
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedType = 'income';
                            _selectedCategory = '';
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _selectedType == 'income' 
                                ? Colors.green.withOpacity(0.1) 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.arrow_upward,
                                color: _selectedType == 'income' 
                                    ? Colors.green 
                                    : Colors.grey,
                                size: 24,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Income',
                                style: TextStyle(
                                  color: _selectedType == 'income' 
                                      ? Colors.green 
                                      : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedType = 'expense';
                            _selectedCategory = '';
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _selectedType == 'expense' 
                                ? Colors.red.withOpacity(0.1) 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.arrow_downward,
                                color: _selectedType == 'expense' 
                                    ? Colors.red 
                                    : Colors.grey,
                                size: 24,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Expense',
                                style: TextStyle(
                                  color: _selectedType == 'expense' 
                                      ? Colors.red 
                                      : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Amount Input
              Container(
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
                child: TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    labelStyle: TextStyle(color: Colors.grey.shade600),
                    prefixIcon: Icon(Icons.attach_money, color: Color(0xFF9B6DFF)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  style: TextStyle(fontSize: 16),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Amount must be greater than 0';
                    }
                    return null;
                  },
                ),
              ),
              
              SizedBox(height: 16),
              
              // Category Selection
              Container(
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
                child: ListTile(
                  leading: Icon(Icons.category, color: Color(0xFF9B6DFF)),
                  title: Text(
                    'Category',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    _selectedCategory.isEmpty ? 'Select category' : _selectedCategory,
                    style: TextStyle(
                      color: _selectedCategory.isEmpty ? Colors.grey.shade400 : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
                  onTap: _selectCategory,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Date Selection
              Container(
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
                child: ListTile(
                  leading: Icon(Icons.calendar_today, color: Color(0xFF9B6DFF)),
                  title: Text(
                    'Date',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    '${_selectedDate.toLocal()}'.split(' ')[0],
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
                  onTap: () => _selectDate(context),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Description Input
              Container(
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
                child: TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    labelStyle: TextStyle(color: Colors.grey.shade600),
                    prefixIcon: Icon(Icons.description, color: Color(0xFF9B6DFF)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  style: TextStyle(fontSize: 16),
                  maxLines: 3,
                ),
              ),
              
              SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF9B6DFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _isEditing ? 'Update Transaction' : 'Add Transaction',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}