import '../core/enums.dart';
import '../models/process.dart';
import '../models/schedule_result.dart' as model;
import '../algorithms/fcfs.dart';
import '../algorithms/sjf.dart';
import '../algorithms/rr.dart' as rr_alg hide ScheduleResult;
import '../algorithms/priority.dart';

import '../algorithms/hrrn.dart';
import '../algorithms/srt.dart';
import '../models/animation_step.dart';

class SchedulerController {
  model.ScheduleResult schedule(
    SchedulingAlgorithm algorithm,
    List<Process> processes, {
    int quantum = 2,
  }) {
    switch (algorithm) {
      case SchedulingAlgorithm.fcfs:
        return fcfs(processes);
      case SchedulingAlgorithm.sjf:
        return sjf(processes);
      case SchedulingAlgorithm.rr:
        return rr_alg.rr(processes, quantum: quantum);
      case SchedulingAlgorithm.priority:
        return priorityScheduling(processes);
      case SchedulingAlgorithm.hrrn:
        return hrrnWithSteps(processes).result;
      case SchedulingAlgorithm.srt:
        return srt(processes);
    }
  }

  List<AnimationStep> hrrnAnimationSteps(List<Process> processes) {
    return hrrnWithSteps(processes).animationSteps;
  }
}
