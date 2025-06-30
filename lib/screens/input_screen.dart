import 'package:flutter/material.dart';
import '../widgets/process_input_form.dart';
import '../data/sample_data.dart';
import '../core/enums.dart';
import '../screens/result_screen.dart';
import '../models/process.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  SchedulingAlgorithm _algorithm = SchedulingAlgorithm.fcfs;
  List<Process> _processes = List.from(sampleProcesses);
  int _quantum = 2;

  Future<void> _onSubmit(List<Process> processes) async {
    setState(() {
      _processes = processes;
    });
    int quantum = _quantum;
    if (_algorithm == SchedulingAlgorithm.rr) {
      final result = await showDialog<int>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          final controller = TextEditingController();
          return AlertDialog(
            title: const Text('لطفا مقدار کوانتوم را وارد کنید'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'مثلاً 2'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // مقدار پیش‌فرض 1 اگر خالی بود
                  final value = controller.text.trim().isEmpty
                      ? 1
                      : int.tryParse(controller.text);
                  if (value != null && value > 0) {
                    Navigator.of(context).pop(value);
                  } else {
                    // اگر مقدار نامعتبر بود، مقدار 1 قرار بده
                    Navigator.of(context).pop(1);
                  }
                },
                child: const Text('تایید'),
              ),
            ],
          );
        },
      );
      quantum = (result != null && result > 0) ? result : 1;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          algorithm: _algorithm,
          processes: _processes,
          quantum: quantum,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ورود داده‌ها'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'حذف همه فرآیندها',
            onPressed: () {
              setState(() {
                _processes.clear();
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              child: DropdownButtonFormField<SchedulingAlgorithm>(
                value: _algorithm,
                decoration: InputDecoration(
                  labelText: 'انتخاب الگوریتم',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: SchedulingAlgorithm.values
                    .map(
                      (alg) => DropdownMenuItem(
                        value: alg,
                        child: Text(_algorithmNameFa(alg)),
                      ),
                    )
                    .toList(),
                onChanged: (alg) {
                  if (alg != null) setState(() => _algorithm = alg);
                },
              ),
            ),
            // فیلد ورودی کوانتوم حذف شد
            Expanded(
              child: ProcessInputForm(
                onSubmit: _onSubmit,
                initialProcesses: _processes,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _algorithmNameFa(SchedulingAlgorithm alg) {
    switch (alg) {
      case SchedulingAlgorithm.fcfs:
        return 'FCFS (FIFO)';
      case SchedulingAlgorithm.sjf:
        return 'SJF';
      case SchedulingAlgorithm.rr:
        return 'Round Robin (RR)';
      case SchedulingAlgorithm.priority:
        return 'Priority';
      case SchedulingAlgorithm.hrrn:
        return 'HRRN';
      case SchedulingAlgorithm.srt:
        return 'SRT (Shortest Remaining Time)';
    }
  }
}
