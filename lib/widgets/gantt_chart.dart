import 'package:flutter/material.dart';
import '../models/schedule_result.dart';

class GanttChart extends StatelessWidget {
  final List<GanttItem> ganttItems;
  const GanttChart({super.key, required this.ganttItems});

  @override
  Widget build(BuildContext context) {
    if (ganttItems.isEmpty) return const SizedBox.shrink();
    int minTime = ganttItems
        .map((g) => g.start)
        .reduce((a, b) => a < b ? a : b);
    int maxTime = ganttItems.map((g) => g.end).reduce((a, b) => a > b ? a : b);
    double totalDuration = (maxTime - minTime).toDouble();
    const double minBlockWidth = 32.0;
    const double maxBlockWidth = 200.0;
    const double chartWidth =
        400.0; 
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: ganttItems.length,
        itemBuilder: (context, i) {
          final item = ganttItems[i];
          double rel =
              (item.end - item.start) /
              (totalDuration == 0 ? 1 : totalDuration);
          double width = (rel * chartWidth).clamp(minBlockWidth, maxBlockWidth);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: width,
            decoration: BoxDecoration(
              color: Colors.primaries[item.processId % Colors.primaries.length],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'P${item.processId}\n${item.start}-${item.end}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}
