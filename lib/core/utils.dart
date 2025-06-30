// توابع کمکی مثل محاسبه زمان انتظار و ...
int calculateWaitingTime(List<int> burstTimes, int index) {
  int waitingTime = 0;
  for (int i = 0; i < index; i++) {
    waitingTime += burstTimes[i];
  }
  return waitingTime;
}
