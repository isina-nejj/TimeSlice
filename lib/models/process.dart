class Process {
  final int id;
  final int arrivalTime;
  final int burstTime;
  final int priority;

  Process({
    required this.id,
    required this.arrivalTime,
    required this.burstTime,
    this.priority = 0,
  });
}
