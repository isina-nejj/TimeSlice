import 'package:flutter/material.dart';
import '../models/process.dart';
import '../models/schedule_result.dart';

class ProcessTable extends StatelessWidget {
  final List<Process> processes;
  final ScheduleResult result;
  const ProcessTable({
    super.key,
    required this.processes,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('ورود')),
        DataColumn(label: Text('اجرا')),
        DataColumn(label: Text('اولویت')),
      ],
      rows: processes
          .map(
            (p) => DataRow(
              cells: [
                DataCell(Text('P${p.id}')),
                DataCell(Text('${p.arrivalTime}')),
                DataCell(Text('${p.burstTime}')),
                DataCell(Text('${p.priority}')),
              ],
            ),
          )
          .toList(),
    );
  }
}
