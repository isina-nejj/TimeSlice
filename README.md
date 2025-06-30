
# ⏱️ TimeSlice

**TimeSlice** is a visual and interactive simulator of CPU scheduling algorithms (like FCFS, SJF, Round Robin) built with Flutter. It aims to help students and developers understand how operating systems manage processes in real-time.

🔗 Live Web App: [https://timeslice.vercel.app](https://timeslice.vercel.app)

---

## ✨ Features

- Responsive design for Web and Android
- Visual Gantt chart representation
- Add/edit/delete processes with:
  - Name
  - Arrival Time
  - Burst Time
- Support for key scheduling algorithms:
  - FCFS (First Come First Serve)
  - SJF (Shortest Job First)
  - Round Robin
  - Priority Scheduling
- Calculation of:
  - Completion time
  - Waiting time
  - Turnaround time

---

## 🧠 Who is this for?

- CS and CE students studying Operating Systems
- Instructors visualizing process scheduling
- Developers exploring low-level system behavior

---

## 📂 Project Structure

```
lib/
├── main.dart
├── screens/
│   ├── home_screen.dart
│   ├── input_screen.dart
│   ├── edit_processes_screen.dart
│   └── result_screen.dart
├── algorithms/
├── controllers/
├── widgets/
├── models/
└── core/
```

---

## 🛠️ Getting Started

```bash
flutter pub get
flutter run -d chrome
```

---

## 📄 License

Licensed under the MIT License.

---

📖 [Read this in Persian (فارسی)](README.fa.md)
