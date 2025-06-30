import 'dart:async';
import 'package:flutter/material.dart';
import '../models/process.dart';
import '../models/schedule_result.dart';
import '../core/enums.dart';

class AnimationStoryboard extends StatefulWidget {
  final List<Process> processes;
  final SchedulingAlgorithm algorithm;
  final int quantum;

  const AnimationStoryboard({
    super.key,
    required this.processes,
    required this.algorithm,
    this.quantum = 2,
  });

  @override
  State<AnimationStoryboard> createState() => _AnimationStoryboardState();
}

class _AnimationStoryboardState extends State<AnimationStoryboard> {
  int time = 0;
  List<Process> readyQueue = [];
  List<Process> finished = [];
  Process? running;
  List<GanttItem> gantt = [];
  Timer? timer;
  int? remainingBurst;
  int rrTimeSlice = 0;
  bool isPlaying = true;

  @override
  void initState() {
    super.initState();
    _reset();
    _startTimer();
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isPlaying) _tick();
    });
  }

  void _reset() {
    time = 0;
    readyQueue = [];
    finished = [];
    running = null;
    gantt = [];
    remainingBurst = null;
    rrTimeSlice = 0;
    isPlaying = false;
    setState(() {});
  }

  void _tick() {
    if (!mounted) return;
    setState(() {
      // Add new arrivals
      for (var p in widget.processes) {
        if (p.arrivalTime == time &&
            !readyQueue.contains(p) &&
            !finished.contains(p)) {
          readyQueue.add(p);
        }
      }

      if (running == null && readyQueue.isNotEmpty) {
        switch (widget.algorithm) {
          case SchedulingAlgorithm.fcfs:
            running = readyQueue.removeAt(0);
            remainingBurst = running!.burstTime;
            break;
          case SchedulingAlgorithm.sjf:
            readyQueue.sort((a, b) => a.burstTime.compareTo(b.burstTime));
            running = readyQueue.removeAt(0);
            remainingBurst = running!.burstTime;
            break;
          case SchedulingAlgorithm.priority:
            readyQueue.sort((a, b) => a.priority.compareTo(b.priority));
            running = readyQueue.removeAt(0);
            remainingBurst = running!.burstTime;
            break;
          case SchedulingAlgorithm.rr:
            running = readyQueue.removeAt(0);
            remainingBurst =
                (remainingBurst == null || running!.burstTime < remainingBurst!)
                ? running!.burstTime
                : remainingBurst;
            rrTimeSlice = 0;
            break;
          case SchedulingAlgorithm.hrrn:
            readyQueue.sort((a, b) {
              double r1 = (time - a.arrivalTime + a.burstTime) / a.burstTime;
              double r2 = (time - b.arrivalTime + b.burstTime) / b.burstTime;
              return r2.compareTo(r1);
            });
            running = readyQueue.removeAt(0);
            remainingBurst = running!.burstTime;
            break;
          case SchedulingAlgorithm.srt:
            break;
          default:
            break;
        }
        if (running != null) {
          gantt.add(GanttItem(processId: running!.id, start: time, end: time));
        }
      }

      if (running != null) {
        if (widget.algorithm == SchedulingAlgorithm.rr) {
          remainingBurst = (remainingBurst ?? running!.burstTime) - 1;
          rrTimeSlice++;
          if (gantt.isNotEmpty && gantt.last.processId == running!.id) {
            gantt[gantt.length - 1] = GanttItem(
              processId: running!.id,
              start: gantt.last.start,
              end: time + 1,
            );
          }
          if (remainingBurst == 0) {
            finished.add(running!);
            running = null;
            remainingBurst = null;
            rrTimeSlice = 0;
          } else if (rrTimeSlice == widget.quantum) {
            readyQueue.add(running!);
            running = null;
            rrTimeSlice = 0;
          }
        } else {
          remainingBurst = (remainingBurst ?? running!.burstTime) - 1;
          if (gantt.isNotEmpty && gantt.last.processId == running!.id) {
            gantt[gantt.length - 1] = GanttItem(
              processId: running!.id,
              start: gantt.last.start,
              end: time + 1,
            );
          }
          // Check for completion
          if (remainingBurst == 0) {
            finished.add(running!);
            running = null;
            remainingBurst = null;
          }
        }
      }

      time++;
      // Stop timer if all done
      if (finished.length == widget.processes.length) {
        timer?.cancel();
        isPlaying = false;
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _onPlay() {
    if (finished.length == widget.processes.length) return;
    setState(() {
      isPlaying = true;
    });
    if (timer == null || !(timer?.isActive ?? false)) {
      _startTimer();
    }
  }

  void _onPause() {
    setState(() {
      isPlaying = false;
    });
  }

  void _onReplay() {
    setState(() {
      _reset();
      isPlaying = true;
    });
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    double avgWaiting = 0;
    double avgTurnaround = 0;
    if (finished.isNotEmpty && gantt.isNotEmpty) {
      int totalWaiting = 0;
      int totalTurnaround = 0;
      for (var p in finished) {
        // Find all GanttItems for this process
        final ganttItems = gantt.where((g) => g.processId == p.id).toList();
        if (ganttItems.isEmpty) continue;
        final startTime = ganttItems.first.start;
        final finishTime = ganttItems.last.end;
        final turnaround = finishTime - p.arrivalTime;
        final waiting = turnaround - p.burstTime;
        totalWaiting += waiting;
        totalTurnaround += turnaround;
      }
      avgWaiting = totalWaiting / finished.length;
      avgTurnaround = totalTurnaround / finished.length;
    }
    return Column(
      children: [
        // Ready Queue
        _SectionTitle(title: 'Ready Queue'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: readyQueue
                .map(
                  (p) => _ProcessBox(
                    process: p,
                    isRunning: false,
                    isCompleted: false,
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        // CPU
        _SectionTitle(title: 'CPU'),
        running != null
            ? _ProcessBox(
                process: running!,
                isRunning: true,
                isCompleted: false,
              )
            : const Text(
                'Idle',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
        const SizedBox(height: 16),
        // Completed
        _SectionTitle(title: 'Completed'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: finished
                .map(
                  (p) => _ProcessBox(
                    process: p,
                    isRunning: false,
                    isCompleted: true,
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        // Timeline (Gantt Chart)
        _SectionTitle(title: 'Timeline'),
        // می‌توانید از GanttChart خود پروژه استفاده کنید
        // GanttChart(ganttItems: gantt),
        const SizedBox(height: 16),
        Text(
          'Time: $time',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.replay),
              tooltip: 'Replay',
              onPressed: _onReplay,
            ),
            IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              tooltip: isPlaying ? 'Pause' : 'Play',
              onPressed: isPlaying ? _onPause : _onPlay,
            ),
          ],
        ),
        if (finished.length == widget.processes.length &&
            finished.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'میانگین زمان انتظار: ${avgWaiting.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'میانگین زمان گردش: ${avgTurnaround.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ],
    );
  }
}

class _ProcessBox extends StatelessWidget {
  final Process process;
  final bool isRunning;
  final bool isCompleted;

  const _ProcessBox({
    required this.process,
    required this.isRunning,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    Color color = isCompleted
        ? Colors.grey.shade400
        : isRunning
        ? Colors.orangeAccent
        : Colors.blue[100]!;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (isRunning) BoxShadow(color: Colors.orange, blurRadius: 12),
        ],
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'P${process.id}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('Arrival: ${process.arrivalTime}'),
          Text('Burst: ${process.burstTime}'),
        ],
      ),
    );
  }
}
//     );
//   }
// }

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
