import '../models/process.dart';
import '../models/schedule_result.dart';
import '../models/animation_step.dart';

class HRRNResult {
  final ScheduleResult result;
  final List<AnimationStep> animationSteps;
  HRRNResult(this.result, this.animationSteps);
}

HRRNResult hrrnWithSteps(List<Process> processes) {
  List<Process> queue = List.from(processes);
  int time = 0;
  List<GanttItem> gantt = [];
  double totalWaiting = 0;
  double totalTurnaround = 0;
  List<Process> finished = [];
  List<AnimationStep> steps = [];
  while (queue.isNotEmpty) {
    var ready = queue.where((p) => p.arrivalTime <= time).toList();
    if (ready.isEmpty) {
      steps.add(
        AnimationStep(
          time: time,
          readyQueue: List.from(ready),
          running: null,
          finished: List.from(finished),
          explanation: 'در این لحظه هیچ فرآیندی آماده نیست. زمان جلو می‌رود.',
        ),
      );
      time++;
      continue;
    }
    ready.sort((a, b) {
      double r1 = (time - a.arrivalTime + a.burstTime) / a.burstTime;
      double r2 = (time - b.arrivalTime + b.burstTime) / b.burstTime;
      return r2.compareTo(r1);
    });
    var p = ready.first;
    queue.remove(p);
    int start = time;
    int waiting = start - p.arrivalTime;
    totalWaiting += waiting;
    int end = start + p.burstTime;
    totalTurnaround += end - p.arrivalTime;
    gantt.add(GanttItem(processId: p.id, start: start, end: end));
    steps.add(
      AnimationStep(
        time: time,
        readyQueue: List.from(ready),
        running: p,
        finished: List.from(finished),
        explanation:
            'فرآیند P${p.id} با بالاترین HRRN انتخاب شد و اجرا می‌شود.',
      ),
    );
    time = end;
    finished.add(p);
  }
  return HRRNResult(
    ScheduleResult(
      ganttChart: gantt,
      avgWaitingTime: totalWaiting / processes.length,
      avgTurnaroundTime: totalTurnaround / processes.length,
    ),
    steps,
  );
}
