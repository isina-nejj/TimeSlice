import '../models/process.dart';
import '../models/schedule_result.dart';

ScheduleResult rr(List<Process> processes, {int quantum = 2}) {
  List<Process> queue = List.from(processes);
  List<int> remaining = queue.map((p) => p.burstTime).toList();
  int time = 0;
  List<GanttItem> gantt = [];
  double totalWaiting = 0;
  double totalTurnaround = 0;
  while (queue.any((p) => remaining[queue.indexOf(p)] > 0)) {
    for (int i = 0; i < queue.length; i++) {
      if (remaining[i] > 0 && queue[i].arrivalTime <= time) {
        int start = time;
        int exec = remaining[i] > quantum ? quantum : remaining[i];
        time += exec;
        remaining[i] -= exec;
        gantt.add(GanttItem(processId: queue[i].id, start: start, end: time));
        if (remaining[i] == 0) {
          totalWaiting += time - queue[i].arrivalTime - queue[i].burstTime;
          totalTurnaround += time - queue[i].arrivalTime;
        }
      }
    }
    if (!queue.any(
      (p) => p.arrivalTime <= time && remaining[queue.indexOf(p)] > 0,
    )) {
      time++;
    }
  }
  return ScheduleResult(
    ganttChart: gantt,
    avgWaitingTime: totalWaiting / processes.length,
    avgTurnaroundTime: totalTurnaround / processes.length,
  );
}
