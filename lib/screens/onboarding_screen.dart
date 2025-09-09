// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/session_manager.dart';
import 'auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> onboardingData = [
    {
      'title': 'Track Your Expenses',
      'subtitle': 'Easily monitor your spending habits and stay on budget',
      'icon': Icons.account_balance_wallet,
    },
    {
      'title': 'Manage Your Income',
      'subtitle': 'Keep track of all your income sources in one place',
      'icon': Icons.attach_money,
    },
    {
      'title': 'Generate Reports',
      'subtitle': 'Get detailed insights into your financial health',
      'icon': Icons.bar_chart,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Background decorative elements
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Color(0xFF9B6DFF).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -60,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Color(0xFF9B6DFF).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            
            Column(
              children: [
                // Skip button at top right
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0, right: 16.0),
                    child: TextButton(
                      onPressed: _skipOnboarding,
                      child: Text(
                        'Skip', 
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF9B6DFF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: onboardingData.length,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemBuilder: (context, index) {
                      return OnboardingPage(
                        title: onboardingData[index]['title']!,
                        subtitle: onboardingData[index]['subtitle']!,
                        icon: onboardingData[index]['icon']!,
                        pageNumber: index + 1,
                      );
                    },
                  ),
                ),
                
                // Page indicator
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length,
                      (index) => _buildDot(index: index),
                    ),
                  ),
                ),
                
                // Next/Get Started button
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: ElevatedButton(
                    onPressed: _currentPage == onboardingData.length - 1
                        ? _completeOnboarding
                        : _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF9B6DFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentPage == onboardingData.length - 1
                          ? 'Get Started'
                          : 'Continue',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot({required int index}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: _currentPage == index
            ? Color(0xFF9B6DFF)
            : Color(0xFF9B6DFF).withOpacity(0.3),
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _completeOnboarding() async {
    final sessionManager = Provider.of<SessionManager>(context, listen: false);
    await sessionManager.setFirstTime(false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final int pageNumber;

  const OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.pageNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated illustration container
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: Color(0xFF9B6DFF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 80,
              color: Color(0xFF9B6DFF),
            ),
          ),
          SizedBox(height: 40),
          
          // Page number indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xFF9B6DFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Step $pageNumber of 3',
              style: TextStyle(
                color: Color(0xFF9B6DFF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 24),
          
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          
          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}