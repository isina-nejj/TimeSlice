import 'package:flutter/material.dart';
import '../widgets/process_input_form.dart';
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
  List<Process> _processes = [];
  int _quantum = 2;

  void _onSubmit(List<Process> processes) {
    setState(() {
      _processes = processes;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          algorithm: _algorithm,
          processes: _processes,
          quantum: _quantum,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ورود داده‌ها')),
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
                        child: Text(
                          alg.toString().split('.').last.toUpperCase(),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (alg) {
                  if (alg != null) setState(() => _algorithm = alg);
                },
              ),
            ),
            if (_algorithm == SchedulingAlgorithm.rr)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Quantum',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => _quantum = int.tryParse(val) ?? 2,
                ),
              ),
            Expanded(child: ProcessInputForm(onSubmit: _onSubmit)),
          ],
        ),
      ),
    );
  }
}
