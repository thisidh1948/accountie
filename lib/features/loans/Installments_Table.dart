import 'package:accountie/models/loan_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class InstallmentDataGrid extends StatelessWidget {
  final List<Installment> installments;
  final Function(List<Installment>) onInstallmentsUpdated;

  const InstallmentDataGrid({
    super.key,
    required this.installments,
    required this.onInstallmentsUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return SfDataGrid(
      source: InstallmentDataSource(
        installments,
        onInstallmentsUpdated,
      ),
      allowEditing: true,
      allowSorting: true,
      allowFiltering: true,
      selectionMode: SelectionMode.single,
      navigationMode: GridNavigationMode.cell,
      columnWidthMode: ColumnWidthMode.auto,
      columns: [
        buildCol('ID', allowEditing: false),
        buildCol('PaidDate'),
        buildCol('Principal'),
        buildCol('Interest'),
        buildCol('Paid'),
        buildCol('Status', allowEditing: false),
      ],
    );
  }
}

class InstallmentDataSource extends DataGridSource {
  final List<Installment> installments;
  final Function(List<Installment>)? onInstallmentsUpdated;

  InstallmentDataSource(this.installments, this.onInstallmentsUpdated) {
    buildDataGridRows();
  }

  List<DataGridRow> dataGridRows = [];

  void buildDataGridRows() {
    dataGridRows = installments.map((installment) {
      return DataGridRow(cells: [
        DataGridCell<String>(
            columnName: 'ID', value: installment.installmentId),
        DataGridCell<String>(
          columnName: 'PaidDate',
          value: installment.paidDate != null
              ? DateFormat('dd/MM/yyyy').format(installment.paidDate!)
              : 'N/A',
        ),
        DataGridCell<String>(
          columnName: 'Principal',
          value: installment.principalComponent.toStringAsFixed(2),
        ),
        DataGridCell<String>(
          columnName: 'Interest',
          value: installment.interestComponent.toStringAsFixed(2),
        ),
        DataGridCell<String>(
          columnName: 'Paid',
          value: installment.paidAmount.toStringAsFixed(2),
        ),
        DataGridCell<String>(
          columnName: 'Status',
          value: installment.isPaid ? 'Paid' : 'Pending',
        ),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map((cell) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            cell.value.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
    );
  }

  @override
  Future<void> onCellSubmit(
    DataGridRow row,
    RowColumnIndex rowColumnIndex,
    GridColumn column,
  ) async {
    final rowIndex = rowColumnIndex.rowIndex - 1;
    if (rowIndex < 0 || rowIndex >= installments.length) return;

    final DataGridCell cell =
        row.getCells().firstWhere((c) => c.columnName == column.columnName);
    final editedValue = cell.value.toString();
    final installment = installments[rowIndex];
    switch (column.columnName) {
      case 'Principal':
        installment.principalComponent = double.tryParse(editedValue) ?? 0.0;
        break;
      case 'PaidDate':
        final parsedDate = _tryParseDate(editedValue);
        if (parsedDate != null) {
          installment.paidDate = parsedDate;
        }
        break;
      case 'Interest':
        installment.interestComponent = double.tryParse(editedValue) ?? 0.0;
        break;
      case 'Paid':
        installment.paidAmount = double.tryParse(editedValue) ?? 0.0;
        break;
      case 'Status':
        installment.isPaid = editedValue.toLowerCase() == 'paid';
        break;
    }

    buildDataGridRows();
    notifyListeners();
    onInstallmentsUpdated?.call(installments);
  }

  DateTime? _tryParseDate(String input) {
    try {
      return DateFormat('dd/MM/yyyy').parseStrict(input);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget? buildEditWidget(
    DataGridRow dataGridRow,
    RowColumnIndex rowColumnIndex,
    GridColumn column,
    CellSubmit submitCell,
  ) {
    final String displayText = dataGridRow
            .getCells()
            .firstWhere((cell) => cell.columnName == column.columnName)
            .value
            ?.toString() ??
        '';

    final TextEditingController editingController =
        TextEditingController(text: displayText);
    return TextField(
      controller: editingController,
      autofocus: true,
      textAlign: TextAlign.center,
      textInputAction: TextInputAction.done,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        border: OutlineInputBorder(),
      ),
      onSubmitted: (newValue) {
        print('newvalue : ${newValue}');
        final cellIndex = dataGridRow.getCells().indexWhere(
              (c) => c.columnName == column.columnName,
            );

        if (cellIndex != -1) {
          dataGridRow.getCells()[cellIndex] = DataGridCell<String>(
            columnName: column.columnName,
            value: newValue,
          );
        }

        submitCell(); // ✅ This will now reliably trigger onCellSubmit
      },
    );

  }

}

GridColumn buildCol(String label, {bool allowEditing = true}) {
  return GridColumn(
    columnName: label,
    allowEditing: allowEditing,
    label: Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
