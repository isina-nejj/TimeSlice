<p align="center">
  <b>🗣 زبان | Language:</b>
  <a href="README.en.md">English</a> | 🇮🇷 فارسی
</p>

# ⏱️ TimeSlice - شبیه‌ساز گرافیکی الگوریتم‌های زمان‌بندی CPU

**TimeSlice** یک اپلیکیشن گرافیکی و تعاملی برای شبیه‌سازی و تحلیل الگوریتم‌های زمان‌بندی CPU در سیستم‌عامل‌هاست که با استفاده از فریم‌ورک **Flutter** پیاده‌سازی شده است.


---

## 🎯 هدف پروژه

این ابزار به منظور کمک به **دانشجویان مهندسی کامپیوتر**، **مدرسان دروس سیستم‌عامل** و حتی **علاقه‌مندان به مفاهیم پایین‌سطح سیستم‌ها** طراحی شده است تا با درک بصری و شهودی از الگوریتم‌های زمان‌بندی، مفاهیم دشوار این حوزه را ساده‌تر و قابل لمس‌تر کند.

---

## 📌 قابلیت‌ها

- طراحی واکنش‌گرا برای موبایل و وب
- وارد کردن و مدیریت پردازه‌ها (نام، زمان ورود، زمان اجرا)
- نمایش نمودار گانت به‌صورت تعاملی
- محاسبه و نمایش:
  - زمان اتمام
  - زمان انتظار
  - زمان برگشت (Turnaround)
- پشتیبانی از الگوریتم‌های کلاسیک:
  - FCFS (نخست‌آمده، نخست‌خدمت‌گرفته)
  - SJF (کوتاه‌ترین پردازه ابتدا)
  - Round Robin (مدور با زمان‌بُرش)
  - Priority Scheduling (اولویت‌محور)
  - HRRN (نرخ پاسخ‌دهی بالا)
  - SRT (کوتاه‌ترین زمان باقی‌مانده)
---

## 📂 ساختار پروژه (Flutter)

```
timeslice/
├── android/
├── assets/
├── build/
├── ios/
├── lib/
│   ├── algorithms/
│   │   ├── fcfs.dart
│   │   ├── hrrn.dart
│   │   ├── priority.dart
│   │   ├── rr.dart
│   │   ├── sjf.dart
│   │   ├── srt.dart
│   │   └── srt_animation.dart
│   ├── controllers/
│   │   └── scheduler_controller.dart
│   ├── core/
│   │   ├── constants.dart
│   │   ├── enums.dart
│   │   └── utils.dart
│   ├── data/
│   │   └── sample_data.dart
│   ├── models/
│   │   ├── animation_step.dart
│   │   ├── process.dart
│   │   └── schedule_result.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── input_screen.dart
│   │   └── result_screen.dart
│   └── widgets/
│       ├── animation_storyboard.dart
│       ├── gantt_chart.dart
│       ├── hrrn_animation.dart
│       ├── mlfq_animation.dart
│       ├── mlq_animation.dart
│       ├── process_input_form.dart
│       ├── process_table.dart
│       └── srt_animation.dart
├── linux/
├── macos/
├── test/
├── web/
├── windows/
├── analysis_options.yaml
├── pubspec.lock
├── pubspec.yaml
├── README.en.md
├── README.md
└── timeslice.iml
```

---

## 🔗 نسخه آنلاین برنامه

پلتفرم: Flutter Web  
لینک دمو: [https://timeslice.vercel.app](https://timeslice.vercel.app)

---

## 🧠 مخاطبین هدف

- دانشجویان دوره کارشناسی/کارشناسی ارشد دروس سیستم‌عامل
- توسعه‌دهندگان علاقه‌مند به معماری سیستم
- اساتید جهت نمایش مفاهیم در کلاس درس
- شرکت‌کنندگان در رویدادها و مسابقات علمی-دانشجویی

---

## 🛠️ نحوه اجرا

```bash
flutter pub get
flutter run -d chrome
```

---

## 👨‍💻 توسعه‌دهنده

طراحی و توسعه توسط **سینا نژادحسینی**  
رشته علوم کامپیوتر – علاقه‌مند به سیستم‌عامل، شبکه و توسعه چندسکویی.

---

## 📜 مجوز

پروژه تحت مجوز MIT منتشر شده است.
