import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:collection/collection.dart';
import '../models/animation_step.dart';
import '../models/process.dart';

class MLFQAnimationWidget extends StatefulWidget {
  final List<AnimationStep> steps;
  const MLFQAnimationWidget({super.key, required this.steps});

  @override
  State<MLFQAnimationWidget> createState() => _MLFQAnimationWidgetState();
}

class _MLFQAnimationWidgetState extends State<MLFQAnimationWidget> {
  int currentStep = 0;

  void _nextStep() {
    if (currentStep < widget.steps.length - 1) {
      setState(() => currentStep++);
    }
  }

  void _prevStep() {
    if (currentStep > 0) {
      setState(() => currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[currentStep];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _prevStep,
            ),
            Text(
              'گام ${currentStep + 1} از ${widget.steps.length}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: _nextStep,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ProcessList(
                title: 'صف آماده',
                processes: step.readyQueue,
                highlight: step.running?.id,
                color: Colors.blue.shade100,
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const Text(
                    'CPU',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  step.running != null
                      ? _ProcessCard(
                          process: step.running!,
                          color: Colors.green.shade200,
                        )
                      : const Text('خالی'),
                ],
              ),
            ),
            Expanded(
              child: _ProcessList(
                title: 'پایان یافته',
                processes: step.finished,
                color: Colors.grey.shade200,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.yellow.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(step.explanation, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}

class _ProcessList extends StatelessWidget {
  final String title;
  final List<Process> processes;
  final int? highlight;
  final Color color;
  const _ProcessList({
    required this.title,
    required this.processes,
    this.highlight,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        AnimationLimiter(
          child: Column(
            children: processes.mapIndexed((i, p) {
              return AnimationConfiguration.staggeredList(
                position: i,
                duration: const Duration(milliseconds: 400),
                child: SlideAnimation(
                  verticalOffset: 20.0,
                  child: FadeInAnimation(
                    child: _ProcessCard(
                      process: p,
                      color: highlight == p.id ? Colors.orange.shade200 : color,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ProcessCard extends StatelessWidget {
  final Process process;
  final Color color;
  const _ProcessCard({required this.process, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          'P${process.id} | ورود: ${process.arrivalTime} | اجرا: ${process.burstTime} | اولویت: ${process.priority}',
        ),
      ),
    );
  }
}
