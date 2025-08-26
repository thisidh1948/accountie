import 'package:accountie/features/loans/Installments_Table.dart';
import 'package:accountie/models/loan_model.dart';
import 'package:accountie/services/data_service.dart';
import 'package:flutter/material.dart';
import 'package:accountie/features/loans/payment_page.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class LoanDetailsPage extends StatefulWidget {
  final LoanModel loan;

  const LoanDetailsPage({super.key, required this.loan});

  @override
  State<LoanDetailsPage> createState() => _LoanDetailsPageState();
}

class _LoanDetailsPageState extends State<LoanDetailsPage> {
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context, listen: true);
    double progressValue =
        (widget.loan.principalAmount - widget.loan.balanceAmount) /
            widget.loan.principalAmount;
    if (!(progressValue >= 0 && progressValue <= 1)) progressValue = 0;
    int noOfTiles = MediaQuery.of(context).size.width >= 600 ? 6 : 3;
    LoanModel _currentLoan = widget.loan;

    return Scaffold(
      appBar: AppBar(
        title: Text('Loan Details: ${widget.loan.partyName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                LinearPercentIndicator(
                  width: MediaQuery.of(context).size.width * 0.9,
                  animation: true,
                  lineHeight: 45.0,
                  animationDuration: 800,
                  percent: progressValue,
                  center: Text(
                      "${(progressValue * 100).toInt()}% [${widget.loan.balanceAmount.toStringAsFixed(2)} / ${widget.loan.principalAmount.toStringAsFixed(2)}]"),
                  linearStrokeCap: LinearStrokeCap.roundAll,
                  progressColor: Colors.green.shade300,
                  backgroundColor: const Color.fromARGB(123, 236, 21, 21),
                  barRadius: const Radius.circular(16),
                ),
                // Text('${(progressValue * 100).toInt()}%', style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),),
              ],
            ),
            const SizedBox(height: 8),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: noOfTiles,
                //childAspectRatio: 1,
                mainAxisExtent: 100,
              ),
              children: [
                gridTile(
                    "Interest Rate",
                    '${widget.loan.interestRate.toStringAsFixed(2)}%',
                    Colors.green),
                gridTile("Status", widget.loan.isOpen ? 'Open' : 'Closed',
                    widget.loan.isOpen ? Colors.green : Colors.red),
                gridTile(
                    "Start Date",
                    widget.loan.startDate.toLocal().toString().split(' ')[0],
                    Colors.grey),
                if (widget.loan.endDate != null)
                  gridTile(
                      "End Date",
                      widget.loan.endDate!.toLocal().toString().split(' ')[0],
                      Colors.grey),
                gridTile(
                    "Balance",
                    '₹${widget.loan.balanceAmount.toStringAsFixed(2)}',
                    Colors.grey),
                gridTile(
                    "Total Paid",
                    '₹${widget.loan.TotalPaid.toStringAsFixed(2)}',
                    Colors.grey),
                gridTile(
                    "Total Interest Paid",
                    '₹${widget.loan.TotalIntersetPaid.toStringAsFixed(2)}  ',
                    Colors.grey),
              ],
            ),
            const SizedBox(height: 20),
            //show installments if available
            if (widget.loan.installments.isNotEmpty)
              Text('Installments: ${widget.loan.installments.length}',
                  style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),

            SfDataGrid(
              source: InstallmentDataSource(
                widget.loan.installments,
                (updatedInstallments) {
                  setState(() {
                    _currentLoan!.installments = updatedInstallments;
                  });
                },
              ),
              allowSorting: true,
              allowEditing: true,
              allowFiltering: true,
              selectionMode: SelectionMode.single,
              navigationMode: GridNavigationMode.row,
              columnWidthMode: ColumnWidthMode.auto,
              columns: [
                buildCol('ID'),
                buildCol('PaidDate'),
                buildCol('Principal'),
                buildCol('Interest'),
                buildCol('Paid'),
                buildCol('Status'),
              ],
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (_) => PaymentDialog(loan: widget.loan),
                    );
                    await dataService.handleLoan(
                        widget.loan, true); // persist updates
                  },
                  icon: const Icon(Icons.payment),
                  label: const Text('MAKE PAYMENT'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                    label: const Text('DELETE'),
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                                  title: const Text(
                                      'Are you sure you want to delete this loan?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel')),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        dataService.handleLoan(
                                            widget.loan, false,
                                            isDelete: true);
                                        Navigator.pop(context);
                                      },
                                      label: const Text('Delete'),
                                      icon: const Icon(Icons.delete),
                                    ),
                                  ]));
                    })
              ],
            ),
          ],
        ),
      ),
    );
  }

  Card gridTile(String label, String value, Color color) {
    return Card(
        child: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          value,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
              fontStyle: FontStyle.italic),
        ),
        Text(
          label,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
        )
      ]),
    ));
  }
}
