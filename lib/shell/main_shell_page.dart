import 'package:flutter/material.dart';
import 'package:randomlottonumber/pages/community_page.dart';
import 'package:randomlottonumber/pages/lotto_draw_page.dart';
import 'package:randomlottonumber/pages/my_numbers_page.dart';
import 'package:randomlottonumber/pages/purchase_page.dart';
import 'package:randomlottonumber/pages/stats_page.dart';
import 'package:randomlottonumber/theme/app_colors.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int selectedIndex = 0;

  final pages = const [
    LottoDrawPage(),
    StatsPage(),
    PurchasePage(),
    MyNumbersPage(),
    CommunityPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        indicatorColor: mainColor.withOpacity(0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: '통계',
          ),
          NavigationDestination(
            icon: _PurchaseTabIcon(isSelected: false),
            selectedIcon: _PurchaseTabIcon(isSelected: true),
            label: '구매',
          ),
          NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(Icons.confirmation_number),
            label: '내 번호',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: '커뮤니티',
          ),
        ],
      ),
    );
  }
}

class _PurchaseTabIcon extends StatelessWidget {
  const _PurchaseTabIcon({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? mainColor : mainColor.withOpacity(0.12),
      ),
      child: Icon(
        Icons.shopping_bag_outlined,
        size: 20,
        color: isSelected ? whiteColor : mainColor,
      ),
    );
  }
}
