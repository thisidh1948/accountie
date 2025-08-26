import 'package:accountie/categories/template.page.dart';
import 'package:accountie/features/loans/loan_view_page.dart';
import 'package:accountie/features/transactions/transaction_view_page.dart';
import 'package:accountie/graphs/curve_chart.dart';
import 'package:accountie/graphs/monthly_bar_chart.dart';
import 'package:accountie/home/account_rack.dart';
import 'package:accountie/home/total_balance.dart';
import 'package:accountie/records/add_update_record_page.dart';
import 'package:accountie/records/records_view_page.dart';
import 'package:accountie/util/calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:accountie/services/data_service.dart';

// Helper class for navigation items
class NavItem {
  final String label;
  final IconData icon;
  final Widget Function(BuildContext) pageBuilder;
  const NavItem(
      {required this.label, required this.icon, required this.pageBuilder});
}

// Stub page for missing navigation targets
class _StubPage extends StatelessWidget {
  final String title;
  const _StubPage({required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('This is the $title page.')),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedNavIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  final List<NavItem> _navItems = [
    NavItem(
        label: 'Transactions',
        icon: Icons.list_alt,
        pageBuilder: (ctx) => const RecordListPage()),
    NavItem(
        label: 'Loans',
        icon: Icons.account_balance_wallet,
        // pageBuilder: (ctx) => const LoansListPage()),
        pageBuilder: (ctx) => const LoanViewPage()),
    NavItem(
        label: 'Templates',
        icon: Icons.account_balance_wallet,
        pageBuilder: (ctx) => const TemplatePage()),
    NavItem(
        label: 'Settings',
        icon: Icons.settings,
        pageBuilder: (ctx) => const _StubPage(title: 'Settings')),
    NavItem(
        label: 'Profile',
        icon: Icons.person,
        pageBuilder: (ctx) => const _StubPage(title: 'Profile')),
    NavItem(
        label: 'ALL',
        icon: Icons.person,
        pageBuilder: (ctx) => const TransactionViewPage()),
  ];

  void _onNavTap(int idx, BuildContext context) {
    setState(() => _selectedNavIndex = idx);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => _navItems[idx].pageBuilder(ctx)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final dataService = context.watch<DataService>();
    final records = dataService.records;
    final monthlyDataList = getMonthlyIncomeExpense(records);
    return LayoutBuilder(builder: (_, constraints) {
      final isWideScreen = constraints.maxWidth >= 600;
      return Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: isWideScreen
              ? _navItems
                  .map((item) => TextButton.icon(
                        onPressed: () =>
                            _onNavTap(_navItems.indexOf(item), context),
                        icon: Icon(item.icon, color: Colors.white),
                        label: Text(item.label,
                            style: const TextStyle(color: Colors.white)),
                      ))
                  .toList()
              : null,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TotalBalance(),
                const SizedBox(height: 12),
                const Text('Accounts',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const AccountCardsCarousel(),
                const SizedBox(height: 8),
                //BarChart
                const Text('Booking Trends',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 280,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MonthlyBarChart(
                        monthlyDataList: monthlyDataList,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 280,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return MontlyLineChart(monthlyData: monthlyDataList);
                    },
                  ),
                )
              ],
            ),
          ),
        ),
        bottomNavigationBar: isWideScreen
            ? null
            : SizedBox(
                height: 64,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _navItems.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final selected = idx == _selectedNavIndex;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 4),
                        child: GestureDetector(
                          onTap: () => _onNavTap(idx, context),
                          child: Container(
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.deepPurple
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            child: Row(
                              children: [
                                Icon(_navItems[idx].icon,
                                    color: selected
                                        ? Colors.white
                                        : Colors.black54),
                                const SizedBox(width: 6),
                                Text(_navItems[idx].label,
                                    style: TextStyle(
                                        color: selected
                                            ? Colors.white
                                            : Colors.black87)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
        floatingActionButton: SpeedDial(
          icon: Icons.add, // FAB icon
          activeIcon: Icons.close, // Icon when expanded
          backgroundColor: Colors.deepPurple,
          spacing: 10, // Space between children
          spaceBetweenChildren: 8, // Child button gap
          children: [
            SpeedDialChild(
              child: const Icon(Icons.add),
              label: 'Add Transaction',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddRecordDialogPage(),
                  ),
                );
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.event),
              label: 'Add Event',
              onTap: () => debugPrint('Add Event tapped'),
            ),
            SpeedDialChild(
              child: const Icon(Icons.picture_as_pdf),
              label: 'Add Document',
              onTap: () => debugPrint('Add Document tapped'),
            ),
          ],
        ),
      );
    });
  }
}
