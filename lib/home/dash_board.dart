import 'package:accountie/graphs/curve_chart.dart';
import 'package:accountie/graphs/monthly_bar_chart.dart';
import 'package:accountie/home/account_rack.dart';
import 'package:accountie/home/total_balance.dart';
import 'package:accountie/records/add_update_record_page.dart';
import 'package:accountie/util/calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:accountie/services/data_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();
    final records = dataService.records;
    final monthlyDataList = getMonthlyIncomeExpense(records);
    return LayoutBuilder(builder: (_, constraints) {
      final isWideScreen = constraints.maxWidth >= 600;
      return Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard')
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
        // bottomNavigationBar: ,
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
