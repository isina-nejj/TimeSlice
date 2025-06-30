import '../models/process.dart';
import '../models/schedule_result.dart';

ScheduleResult srt(List<Process> processes) {
  int time = 0;
  List<GanttItem> gantt = [];
  double totalWaiting = 0;
  double totalTurnaround = 0;
  Map<int, int> remaining = {for (var p in processes) p.id: p.burstTime};
  List<Process> finished = [];
  Process? lastRunning;
  while (finished.length < processes.length) {
    var ready = processes
        .where(
          (p) =>
              p.arrivalTime <= time &&
              !finished.contains(p) &&
              remaining[p.id]! > 0,
        )
        .toList();
    if (ready.isEmpty) {
      time++;
      continue;
    }
    ready.sort((a, b) => remaining[a.id]!.compareTo(remaining[b.id]!));
    var running = ready.first;
    if (lastRunning == null || lastRunning.id != running.id) {
      gantt.add(GanttItem(processId: running.id, start: time, end: time + 1));
    } else {
      gantt.last = GanttItem(
        processId: running.id,
        start: gantt.last.start,
        end: time + 1,
      );
    }
    remaining[running.id] = remaining[running.id]! - 1;
    if (remaining[running.id] == 0) {
      finished.add(running);
      totalWaiting += time + 1 - running.arrivalTime - running.burstTime;
      totalTurnaround += time + 1 - running.arrivalTime;
    }
    lastRunning = running;
    time++;
  }
  int n = processes.length;
  return ScheduleResult(
    ganttChart: gantt,
    avgWaitingTime: totalWaiting / n,
    avgTurnaroundTime: totalTurnaround / n,
  );
}
