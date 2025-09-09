import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../models/transaction.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<Transaction> _transactions = [];
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(Duration(days: 30)),
    end: DateTime.now(),
  );
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final databaseService = Provider.of<DatabaseService>(context, listen: false);
      final transactions = await databaseService.getTransactions();
      
      setState(() {
        _transactions = transactions.where((t) => 
          t.date.isAfter(_selectedDateRange.start.subtract(Duration(days: 1))) && 
          t.date.isBefore(_selectedDateRange.end.add(Duration(days: 1)))
        ).toList();
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading transactions: $e");
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load transactions'),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  Future<void> _selectDateRange() async {
    try {
      final DateTimeRange? picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
        initialDateRange: _selectedDateRange,
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: Color(0xFF9B6DFF),
                onPrimary: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );
      
      if (picked != null) {
        setState(() {
          _selectedDateRange = picked;
        });
        _loadTransactions();
      }
    } catch (e) {
      print("Error selecting date range: $e");
    }
  }

  Map<String, double> _getCategoryTotals(String type) {
    try {
      final filtered = _transactions.where((t) => t.type == type);
      final Map<String, double> totals = {};
      
      for (var transaction in filtered) {
        totals.update(
          transaction.category,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
      
      final sortedTotals = Map.fromEntries(
        totals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value))
      );
      
      return sortedTotals;
    } catch (e) {
      print("Error calculating category totals: $e");
      return {};
    }
  }

  double _getTotalAmount(String type) {
    try {
      return _transactions
          .where((t) => t.type == type)
          .fold(0.0, (sum, t) => sum + t.amount);
    } catch (e) {
      print("Error calculating total amount: $e");
      return 0.0;
    }
  }

  // Get monthly trend data - FIXED TYPE ISSUE HERE
  List<Map<String, dynamic>> _getMonthlyTrend(String type) {
    try {
      final Map<String, double> monthlyData = {};
      
      for (var transaction in _transactions.where((t) => t.type == type)) {
        final monthKey = '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';
        monthlyData.update(
          monthKey,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount
        );
      }
      
      final sortedEntries = monthlyData.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      
      return sortedEntries.map((entry) {
        final parts = entry.key.split('-');
        final month = int.parse(parts[1]);
        final year = int.parse(parts[0]);
        return <String, dynamic>{
          'label': '${_getMonthAbbreviation(month)} $year',
          'amount': entry.value,
          'color': type == 'income' ? Color(0xFF4CAF50) : Color(0xFFF44336)
        };
      }).toList();
    } catch (e) {
      print("Error calculating monthly trend: $e");
      return [];
    }
  }

  String _getMonthAbbreviation(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final incomeTotals = _getCategoryTotals('income');
    final expenseTotals = _getCategoryTotals('expense');
    
    final totalIncome = _getTotalAmount('income');
    final totalExpense = _getTotalAmount('expense');
    final netAmount = totalIncome - totalExpense;

    final incomeTrend = _getMonthlyTrend('income');
    final expenseTrend = _getMonthlyTrend('expense');

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Financial Reports',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadTransactions,
            tooltip: 'Refresh data',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF9B6DFF)))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Range Selector
                    _buildDateRangeSelector(),
                    
                    SizedBox(height: 20),
                    
                    // Financial Summary
                    _buildFinancialSummary(totalIncome, totalExpense, netAmount),
                    
                    SizedBox(height: 24),
                    
                    // Monthly Trends
                    _buildMonthlyTrendsSection(incomeTrend, expenseTrend),
                    
                    SizedBox(height: 24),
                    
                    // Income Breakdown
                    _buildCategorySection(
                      'Income Breakdown', 
                      incomeTotals, 
                      Color(0xFF4CAF50),
                      totalIncome,
                      Icons.arrow_upward,
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Expense Breakdown
                    _buildCategorySection(
                      'Expense Breakdown', 
                      expenseTotals, 
                      Color(0xFFF44336),
                      totalExpense,
                      Icons.arrow_downward,
                    ),
                    
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(Icons.calendar_today, color: Color(0xFF9B6DFF)),
        title: Text(
          'Date Range',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${_formatDate(_selectedDateRange.start)} - ${_formatDate(_selectedDateRange.end)}',
        ),
        trailing: Icon(Icons.arrow_drop_down, color: Colors.grey),
        onTap: _selectDateRange,
      ));
  }

  Widget _buildFinancialSummary(double totalIncome, double totalExpense, double netAmount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Financial Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Income', 
                totalIncome, 
                Color(0xFF4CAF50),
                Icons.arrow_upward,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Total Expense', 
                totalExpense, 
                Color(0xFFF44336),
                Icons.arrow_downward,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Net Amount', 
                netAmount, 
                netAmount >= 0 ? Color(0xFF4CAF50) : Color(0xFFF44336),
                netAmount >= 0 ? Icons.trending_up : Icons.trending_down,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthlyTrendsSection(List<Map<String, dynamic>> incomeTrend, List<Map<String, dynamic>> expenseTrend) {
    if (incomeTrend.isEmpty && expenseTrend.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Trends',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                'No data available for the selected period',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ),
        ],
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Trends',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Table header
                _buildTrendRow('Month', 'Income', 'Expense', isHeader: true),
                Divider(height: 20),
                // Table data
                ..._buildTrendRows(incomeTrend, expenseTrend),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTrendRows(List<Map<String, dynamic>> incomeTrend, List<Map<String, dynamic>> expenseTrend) {
    final allMonths = {...incomeTrend.map((e) => e['label'] as String), ...expenseTrend.map((e) => e['label'] as String)}.toList();
    
    allMonths.sort((a, b) {
      final aParts = a.split(' ');
      final bParts = b.split(' ');
      
      final aMonth = _getMonthNumber(aParts[0]);
      final aYear = int.parse(aParts[1]);
      
      final bMonth = _getMonthNumber(bParts[0]);
      final bYear = int.parse(bParts[1]);
      
      final aDate = DateTime(aYear, aMonth);
      final bDate = DateTime(bYear, bMonth);
      
      return aDate.compareTo(bDate);
    });
    
    return allMonths.map((month) {
      final income = incomeTrend.firstWhere(
        (e) => e['label'] == month, 
        orElse: () => {'amount': 0.0}
      )['amount'] as double;
      
      final expense = expenseTrend.firstWhere(
        (e) => e['label'] == month, 
        orElse: () => {'amount': 0.0}
      )['amount'] as double;
      
      return Column(
        children: [
          _buildTrendRow(month, income, expense),
          if (month != allMonths.last) Divider(height: 16),
        ],
      );
    }).toList();
  }

  int _getMonthNumber(String monthAbbr) {
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
    };
    return months[monthAbbr] ?? 1;
  }

  Widget _buildTrendRow(String month, dynamic income, dynamic expense, {bool isHeader = false}) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            month,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.w600,
              color: isHeader ? Colors.grey.shade700 : Colors.black87,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            '\$${(_parseDouble(income)).toStringAsFixed(2)}',
            style: TextStyle(
              color: isHeader ? Colors.grey.shade700 : Color(0xFF4CAF50),
              fontWeight: isHeader ? FontWeight.bold : FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            '\$${(_parseDouble(expense)).toStringAsFixed(2)}',
            style: TextStyle(
              color: isHeader ? Colors.grey.shade700 : Color(0xFFF44336),
              fontWeight: isHeader ? FontWeight.bold : FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Widget _buildSummaryCard(String title, double amount, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
  ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    String title, 
    Map<String, double> totals, 
    Color color,
    double totalAmount,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: totals.isEmpty
              ? Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No transactions found',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                )
              : Column(
                  children: totals.entries.map((entry) {
                    final percentage = totalAmount > 0 ? (entry.value / totalAmount) * 100 : 0;
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${percentage.toStringAsFixed(1)}%',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              '\$${entry.value.toStringAsFixed(2)}',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthAbbreviation(date.month)} ${date.year}';
  }
}