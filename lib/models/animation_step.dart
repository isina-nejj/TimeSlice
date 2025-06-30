import 'process.dart';

class AnimationStep {
  final int time;
  final List<Process> readyQueue;
  final Process? running;
  final List<Process> finished;
  final String explanation;

  AnimationStep({
    required this.time,
    required this.readyQueue,
    required this.running,
    required this.finished,
    required this.explanation,
  });
}
