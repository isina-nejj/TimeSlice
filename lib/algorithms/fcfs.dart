import '../models/process.dart';
import '../models/schedule_result.dart';

ScheduleResult fcfs(List<Process> processes) {
  processes.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));
  int time = 0;
  List<GanttItem> gantt = [];
  double totalWaiting = 0;
  double totalTurnaround = 0;
  for (var p in processes) {
    int start = time < p.arrivalTime ? p.arrivalTime : time;
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
