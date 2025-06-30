import '../models/process.dart';
import '../models/schedule_result.dart';

ScheduleResult priorityScheduling(List<Process> processes) {
  List<Process> queue = List.from(processes);
  int time = 0;
  List<GanttItem> gantt = [];
  double totalWaiting = 0;
  double totalTurnaround = 0;
  while (queue.isNotEmpty) {
    var ready = queue.where((p) => p.arrivalTime <= time).toList();
    if (ready.isEmpty) {
      time++;
      continue;
    }
    ready.sort((a, b) => a.priority.compareTo(b.priority));
    var p = ready.first;
    queue.remove(p);
    int start = time;
    int waiting = start - p.arrivalTime;
    totalWaiting += waiting;
    int end = start + p.burstTime;
    totalTurnaround += end - p.arrivalTime;
    gantt.add(GanttItem(processId: p.id, start: start, end: end));
    time = end;
  }
  return ScheduleResult(
    ganttChart: gantt,
    avgWaitingTime: totalWaiting / processes.length,
    avgTurnaroundTime: totalTurnaround / processes.length,
  );
}
