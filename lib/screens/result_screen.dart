import 'package:flutter/material.dart';
import '../core/enums.dart';
import '../models/process.dart';
import '../controllers/scheduler_controller.dart';
import '../widgets/gantt_chart.dart';
// import '../widgets/process_table.dart';
import '../widgets/animation_storyboard.dart';
import '../models/schedule_result.dart';

class ResultScreen extends StatefulWidget {
  final SchedulingAlgorithm algorithm;
  final List<Process> processes;
  final int quantum;

  const ResultScreen({
    super.key,
    required this.algorithm,
    required this.processes,
    this.quantum = 2,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool showAnimation = false;

  @override
  Widget build(BuildContext context) {
    final controller = SchedulerController();
    final result = controller.schedule(
      widget.algorithm,
      widget.processes,
      quantum: widget.quantum,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('نتیجه زمان‌بندی')),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.play_circle_fill),
                label: const Text('نمایش انیمیشن'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () => setState(() => showAnimation = true),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (showAnimation)
            AnimationStoryboard(
              processes: widget.processes,
              algorithm: widget.algorithm,
              quantum: widget.quantum,
            ),
          if (!showAnimation) ...[
            GanttChart(ganttItems: result.ganttChart),
            // جدول جدید بر اساس ترتیب اجرا در Gantt Chart
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('ورود')),
                    DataColumn(label: Text('اجرا از')),
                    DataColumn(label: Text('اجرا تا')),
                    DataColumn(label: Text('اولویت')),
                  ],
                  rows: result.ganttChart.map((item) {
                    final p = widget.processes.firstWhere(
                      (pr) => pr.id == item.processId,
                    );
                    return DataRow(
                      cells: [
                        DataCell(Text('P${item.processId}')),
                        DataCell(Text('${p.arrivalTime}')),
                        DataCell(Text('${item.start}')),
                        DataCell(Text('${item.end}')),
                        DataCell(Text('${p.priority}')),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            Text(
              'میانگین زمان انتظار: ${result.avgWaitingTime.toStringAsFixed(2)}',
            ),
            Text(
              'میانگین زمان گردش: ${result.avgTurnaroundTime.toStringAsFixed(2)}',
            ),
          ],
        ],
      ),
    );
  }
}

class _SchedulingAnimation extends StatefulWidget {
  final List<GanttItem> ganttItems;
  final List<Process> processes;
  final SchedulingAlgorithm algorithm;
  const _SchedulingAnimation({
    required this.ganttItems,
    required this.processes,
    required this.algorithm,
  });

  @override
  State<_SchedulingAnimation> createState() => _SchedulingAnimationState();
}

class _SchedulingAnimationState extends State<_SchedulingAnimation>
    with SingleTickerProviderStateMixin {
  String _shortenText(String text, {int maxLength = 30}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength) + '...';
  }

  int currentStep = 0;

  // ...existing code...

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), _nextStep);
  }

  void _nextStep() {
    if (currentStep < widget.ganttItems.length) {
      setState(() {
        currentStep++;
      });
      Future.delayed(const Duration(seconds: 1), _nextStep);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shownItems = widget.ganttItems.take(currentStep).toList();
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: shownItems.length,
                itemBuilder: (context, i) {
                  final item = shownItems[i];
                  final process = widget.processes.firstWhere(
                    (p) => p.id == item.processId,
                  );
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 700),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: (item.end - item.start) * 40.0,
                    decoration: BoxDecoration(
                      color: Colors
                          .primaries[item.processId % Colors.primaries.length],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black12, width: 2),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'P${item.processId}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '${item.start} - ${item.end}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Tooltip(
                              message: _explainStep(
                                item,
                                process,
                                widget.algorithm,
                              ),
                              child: SelectableText(
                                _shortenText(
                                  _explainStep(item, process, widget.algorithm),
                                ),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                // toolbarOptions: ToolbarOptions(
                                //   copy: true,
                                //   selectAll: true,
                                // ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                  // ...existing code...
                },
              ),
            ),
            if (currentStep == 0)
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text('در حال آماده‌سازی انیمیشن ...'),
              ),
          ],
        ),
      ),
    );
  }

  String _explainStep(
    GanttItem item,
    Process process,
    SchedulingAlgorithm algorithm,
  ) {
    switch (algorithm) {
      case SchedulingAlgorithm.fcfs:
        return 'فرآیند ${item.processId} چون زودتر وارد شد (FCFS)';
      case SchedulingAlgorithm.sjf:
        return 'فرآیند ${item.processId} با کوتاه‌ترین زمان اجرا انتخاب شد (SJF)';
      case SchedulingAlgorithm.rr:
        return 'فرآیند ${item.processId} به مدت کوانتوم اجرا شد (RR)';
      case SchedulingAlgorithm.priority:
        return 'فرآیند ${item.processId} با اولویت بالاتر انتخاب شد (Priority)';
      case SchedulingAlgorithm.hrrn:
        return 'فرآیند ${item.processId} با بالاترین نسبت پاسخ انتخاب شد (HRRN)';
      case SchedulingAlgorithm.srt:
        return 'فرآیند ${item.processId} با کمترین زمان باقی‌مانده اجرا شد (SRT)';
      default:
        return 'فرآیند ${item.processId} اجرا شد.';
    }
  }
}
