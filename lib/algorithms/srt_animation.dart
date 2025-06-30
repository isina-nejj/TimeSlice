import '../models/process.dart';
import '../models/animation_step.dart';

List<AnimationStep> srtAnimationSteps(List<Process> processes) {
  int time = 0;
  List<AnimationStep> steps = [];
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
      steps.add(
        AnimationStep(
          time: time,
          readyQueue: ready,
          running: null,
          finished: List.from(finished),
          explanation: 'هیچ فرآیندی آماده نیست. زمان جلو می‌رود.',
        ),
      );
      time++;
      continue;
    }
    ready.sort((a, b) => remaining[a.id]!.compareTo(remaining[b.id]!));
    var running = ready.first;
    steps.add(
      AnimationStep(
        time: time,
        readyQueue: ready,
        running: running,
        finished: List.from(finished),
        explanation: 'اجرای P${running.id} (SRT) با کمترین زمان باقی‌مانده.',
      ),
    );
    remaining[running.id] = remaining[running.id]! - 1;
    if (remaining[running.id] == 0) {
      finished.add(running);
    }
    lastRunning = running;
    time++;
  }
  return steps;
}
