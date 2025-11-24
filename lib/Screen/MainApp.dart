import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'HomePage.dart';
import 'ExpensePage.dart';

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;
  
  // Pages to display in the bottom navigation
  final List<Widget> _pages = [
    const HomePage(),
    const ExpensePage(),
    const Scaffold(body: Center(child: Text('Budget'))),
    const Scaffold(body: Center(child: Text('Profile'))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined, size: 26),
                activeIcon: Icon(Icons.home, size: 26, color: Color(0xFF6C63FF)),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics_outlined, size: 26),
                activeIcon: Icon(Icons.analytics, size: 26, color: Color(0xFF6C63FF)),
                label: 'Expenses',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet_outlined, size: 26),
                activeIcon: Icon(Icons.account_balance_wallet, size: 26, color: Color(0xFF6C63FF)),
                label: 'Budget',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline, size: 26),
                activeIcon: Icon(Icons.person, size: 26, color: Color(0xFF6C63FF)),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xFF6C63FF),
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            onTap: _onItemTapped,
            selectedLabelStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
