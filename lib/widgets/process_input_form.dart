import 'package:flutter/material.dart';
import '../models/process.dart';

class ProcessInputForm extends StatefulWidget {
  final void Function(List<Process>) onSubmit;
  const ProcessInputForm({super.key, required this.onSubmit});

  @override
  State<ProcessInputForm> createState() => _ProcessInputFormState();
}

class _ProcessInputFormState extends State<ProcessInputForm> {
  final List<Process> _processes = [];
  final _formKey = GlobalKey<FormState>();
  int _id = 1;
  final TextEditingController _arrivalController = TextEditingController();
  final TextEditingController _burstController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();

  @override
  void dispose() {
    _arrivalController.dispose();
    _burstController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  String _toEnglishNumber(String input) {
    // تبدیل اعداد فارسی و عربی به انگلیسی
    const fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < 10; i++) {
      input = input.replaceAll(fa[i], i.toString());
      input = input.replaceAll(ar[i], i.toString());
    }
    return input;
  }

  void _addProcess() {
    if (_formKey.currentState!.validate()) {
      final arrival =
          int.tryParse(_toEnglishNumber(_arrivalController.text)) ?? 0;
      final burst = int.tryParse(_toEnglishNumber(_burstController.text)) ?? 1;
      final priority =
          int.tryParse(_toEnglishNumber(_priorityController.text)) ?? 1;
      setState(() {
        _processes.add(
          Process(
            id: _id,
            arrivalTime: arrival,
            burstTime: burst,
            priority: priority,
          ),
        );
        _id++;
        _arrivalController.clear();
        _burstController.clear();
        _priorityController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Form(
          key: _formKey,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: TextFormField(
                    controller: _arrivalController,
                    decoration: InputDecoration(
                      labelText: 'زمان ورود',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'اجباری';
                      final n = int.tryParse(_toEnglishNumber(val));
                      if (n == null || n < 0) return 'عدد معتبر وارد کنید';
                      return null;
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: TextFormField(
                    controller: _burstController,
                    decoration: InputDecoration(
                      labelText: 'زمان اجرا',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'اجباری';
                      final n = int.tryParse(_toEnglishNumber(val));
                      if (n == null || n <= 0) return 'باید بزرگتر از صفر باشد';
                      return null;
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: TextFormField(
                    controller: _priorityController,
                    decoration: InputDecoration(
                      labelText: 'اولویت',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'اجباری';
                      final n = int.tryParse(_toEnglishNumber(val));
                      if (n == null || n < 0) return 'عدد معتبر وارد کنید';
                      return null;
                    },
                  ),
                ),
              ),
              Container(
                height: 56,
                width: 56,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Icon(Icons.add, size: 32),
                  onPressed: _addProcess,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _processes.length,
            itemBuilder: (context, i) {
              final p = _processes[i];
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                child: ListTile(
                  title: Text(
                    'P${p.id} - ورود: ${p.arrivalTime}، اجرا: ${p.burstTime}، اولویت: ${p.priority}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => setState(() => _processes.removeAt(i)),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('محاسبه'),
            onPressed: () => widget.onSubmit(_processes),
          ),
        ),
      ],
    );
  }
}
