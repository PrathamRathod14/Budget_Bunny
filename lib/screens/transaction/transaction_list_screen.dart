import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget_buddy/services/database_service.dart';
import 'package:budget_buddy/models/transaction.dart';

class TransactionListScreen extends StatefulWidget {
  @override
  _TransactionListScreenState createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  List<Transaction> _transactions = [];
  List<Transaction> _filteredTransactions = [];
  bool _isLoading = true;
  String _filterType = 'all'; // 'all', 'income', 'expense'
  String _sortBy = 'date'; // 'date', 'amount', 'category'
  bool _sortAscending = false;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        _applyFilters();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });
    
    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    final transactions = await databaseService.getTransactions();
    
    setState(() {
      _transactions = transactions;
      _applyFilters();
      _isLoading = false;
    });
  }

  void _applyFilters() {
    // Filter by type
    List<Transaction> filtered = _transactions;
    if (_filterType != 'all') {
      filtered = _transactions.where((t) => t.type == _filterType).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) => 
        t.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        t.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        t.amount.toString().contains(_searchQuery)
      ).toList();
    }
    
    // Sort the transactions
    filtered.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'date':
          comparison = a.date.compareTo(b.date);
          break;
        case 'amount':
          comparison = a.amount.compareTo(b.amount);
          break;
        case 'category':
          comparison = a.category.compareTo(b.category);
          break;
        default:
          comparison = a.date.compareTo(b.date);
      }
      return _sortAscending ? comparison : -comparison;
    });
    
    setState(() {
      _filteredTransactions = filtered;
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter & Sort',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text('Transaction Type', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: Text('All'),
                        selected: _filterType == 'all',
                        onSelected: (selected) {
                          setModalState(() {
                            _filterType = 'all';
                          });
                        },
                      ),
                      FilterChip(
                        label: Text('Income'),
                        selected: _filterType == 'income',
                        onSelected: (selected) {
                          setModalState(() {
                            _filterType = 'income';
                          });
                        },
                      ),
                      FilterChip(
                        label: Text('Expense'),
                        selected: _filterType == 'expense',
                        onSelected: (selected) {
                          setModalState(() {
                            _filterType = 'expense';
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text('Sort By', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: Text('Date'),
                        selected: _sortBy == 'date',
                        onSelected: (selected) {
                          setModalState(() {
                            _sortBy = 'date';
                          });
                        },
                      ),
                      FilterChip(
                        label: Text('Amount'),
                        selected: _sortBy == 'amount',
                        onSelected: (selected) {
                          setModalState(() {
                            _sortBy = 'amount';
                          });
                        },
                      ),
                      FilterChip(
                        label: Text('Category'),
                        selected: _sortBy == 'category',
                        onSelected: (selected) {
                          setModalState(() {
                            _sortBy = 'category';
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              _sortAscending = true;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _sortAscending ? Color(0xFF9B6DFF) : Colors.grey,
                            side: BorderSide(
                              color: _sortAscending ? Color(0xFF9B6DFF) : Colors.grey,
                            ),
                          ),
                          child: Text('Ascending'),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              _sortAscending = false;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: !_sortAscending ? Color(0xFF9B6DFF) : Colors.grey,
                            side: BorderSide(
                              color: !_sortAscending ? Color(0xFF9B6DFF) : Colors.grey,
                            ),
                          ),
                          child: Text('Descending'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _applyFilters();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF9B6DFF),
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Apply Filters'),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _clearFilters() {
    setState(() {
      _filterType = 'all';
      _sortBy = 'date';
      _sortAscending = false;
      _searchController.clear();
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = _filteredTransactions.fold(0.0, (sum, t) {
      return t.type == 'income' ? sum + t.amount : sum - t.amount;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('All Transactions'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          if (_filterType != 'all' || _sortBy != 'date' || _searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(Icons.filter_alt_off),
              tooltip: 'Clear filters',
              onPressed: _clearFilters,
            ),
          IconButton(
            icon: Icon(Icons.filter_list),
            tooltip: 'Filter & Sort',
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (_filteredTransactions.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_filteredTransactions.length} transaction${_filteredTransactions.length != 1 ? 's' : ''}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Net: \$${totalAmount.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      color: totalAmount >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Color(0xFF9B6DFF)))
                : _filteredTransactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty || _filterType != 'all'
                                  ? 'No matching transactions'
                                  : 'No transactions yet',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            if (_searchQuery.isNotEmpty || _filterType != 'all')
                              TextButton(
                                onPressed: _clearFilters,
                                child: Text(
                                  'Clear filters',
                                  style: TextStyle(color: Color(0xFF9B6DFF)),
                                ),
                              ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadTransactions,
                        color: Color(0xFF9B6DFF),
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final transaction = _filteredTransactions[index];
                            return _buildTransactionItem(transaction);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: transaction.type == 'income' 
                ? Colors.green.withOpacity(0.15) 
                : Colors.red.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            transaction.type == 'income' ? Icons.arrow_upward : Icons.arrow_downward,
            color: transaction.type == 'income' ? Colors.green : Colors.red,
            size: 22,
          ),
        ),
        title: Text(
          transaction.category,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.description.isNotEmpty)
              Text(
                transaction.description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            SizedBox(height: 4),
            Text(
              _formatDate(transaction.date),
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${transaction.type == 'income' ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: transaction.type == 'income' ? Colors.green : Colors.red,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              transaction.type.toUpperCase(),
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);
    
    if (transactionDate == today) {
      return 'Today, ${_formatTime(date)}';
    } else if (transactionDate == yesterday) {
      return 'Yesterday, ${_formatTime(date)}';
    } else {
      return '${_getMonth(date.month)} ${date.day}, ${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getMonth(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}