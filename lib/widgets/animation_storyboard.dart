import 'dart:async';
import 'package:flutter/material.dart';
import '../models/process.dart';
import '../models/schedule_result.dart';
import '../core/enums.dart';

class AnimationStoryboard extends StatefulWidget {
  final List<Process> processes;
  final SchedulingAlgorithm algorithm;
  final int quantum;

  AnimationStoryboard({
    Key? key,
    List<Process>? processes,
    SchedulingAlgorithm? algorithm,
    int? quantum,
  }) : processes = (processes == null || processes.isEmpty)
           ? [Process(id: 1, arrivalTime: 0, burstTime: 1)]
           : processes,
       algorithm = algorithm ?? SchedulingAlgorithm.fcfs,
       quantum = (quantum == null || quantum == 0) ? 1 : quantum,
       super(key: key);

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
  int? _rrQuantum;

  Future<void> _askQuantumIfNeeded() async {
    if (widget.algorithm == SchedulingAlgorithm.rr &&
        (_rrQuantum == null || _rrQuantum! <= 0)) {
      int? result = await showDialog<int>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          final controller = TextEditingController();
          return AlertDialog(
            title: const Text('لطفا مقدار کوانتوم را وارد کنید'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'مثلاً 2'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final value = int.tryParse(controller.text);
                  if (value != null && value > 0) {
                    Navigator.of(context).pop(value);
                  }
                },
                child: const Text('تایید'),
              ),
            ],
          );
        },
      );
      if (result != null && result > 0) {
        setState(() {
          _rrQuantum = result;
        });
      }
    }
  }

  // SRT helpers as class fields
  final Map<int, int> srtRemaining = {};
  int remainingBurstFor(Process p) {
    if (widget.algorithm == SchedulingAlgorithm.srt) {
      if (!srtRemaining.containsKey(p.id)) {
        srtRemaining[p.id] = p.burstTime;
      }
      return srtRemaining[p.id]!;
    }
    return p.burstTime;
  }

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
    int rrQuantum = _rrQuantum ?? widget.quantum;
    if (!mounted) return;
    setState(() {
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
            readyQueue.sort(
              (a, b) => remainingBurstFor(a).compareTo(remainingBurstFor(b)),
            );
            running = readyQueue.removeAt(0);
            remainingBurst = remainingBurstFor(running!);
            break;
        }
        if (running != null) {
          gantt.add(GanttItem(processId: running!.id, start: time, end: time));
        }
      }

      // SRT preemption: هر بار بررسی کن که آیا فرآیند جدید با زمان باقی‌مانده کمتر آمده است
      if (widget.algorithm == SchedulingAlgorithm.srt &&
          readyQueue.isNotEmpty) {
        List<Process> allReady = [if (running != null) running!, ...readyQueue];
        allReady.sort(
          (a, b) => remainingBurstFor(a).compareTo(remainingBurstFor(b)),
        );
        if (running == null || running!.id != allReady.first.id) {
          if (running != null) {
            readyQueue.add(running!);
          }
          running = allReady.first;
          readyQueue.removeWhere((p) => p.id == running!.id);
          remainingBurst = remainingBurstFor(running!);
          if (gantt.isEmpty ||
              gantt.last.processId != running!.id ||
              gantt.last.end != time) {
            gantt.add(
              GanttItem(processId: running!.id, start: time, end: time),
            );
          }
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
          } else if (rrTimeSlice == rrQuantum) {
            readyQueue.add(running!);
            running = null;
            rrTimeSlice = 0;
          }
        } else if (widget.algorithm == SchedulingAlgorithm.srt) {
          // SRT: decrement remaining burst for running process
          srtRemaining[running!.id] =
              (srtRemaining[running!.id] ?? running!.burstTime) - 1;
          remainingBurst = srtRemaining[running!.id]!;
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
            // Remove from readyQueue if present
            readyQueue.removeWhere((p) => p.id == running?.id);
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

  void _onPlay() async {
    if (finished.length == widget.processes.length) return;
    await _askQuantumIfNeeded();
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
        // حذف متغیر استفاده‌نشده startTime
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
