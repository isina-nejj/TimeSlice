class GanttItem {
  final int processId;
  final int start;
  final int end;
  GanttItem({required this.processId, required this.start, required this.end});
}

class ScheduleResult {
  final List<GanttItem> ganttChart;
  final double avgWaitingTime;
  final double avgTurnaroundTime;

  ScheduleResult({
    required this.ganttChart,
    required this.avgWaitingTime,
    required this.avgTurnaroundTime,
  });
}
