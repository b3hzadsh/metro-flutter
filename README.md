# 🚇 مسیریاب هوشمند و آفلاین مترو تهران
**Tehran Metro Offline Router**

یک اپلیکیشن فلاتری (Flutter) فوق‌سریع و کاملاً آفلاین برای مسیریابی در شبکه پیچیده متروی تهران. این پروژه با رعایت دقیق اصول **معماری پاک (Clean Architecture)** توسعه یافته و از الگوریتم **دایجسترا (Dijkstra)** برای یافتن کوتاه‌ترین زمان سفر استفاده می‌کند.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat-square&logo=dart)
![Architecture](https://img.shields.io/badge/Architecture-Clean-success?style=flat-square)
![Database](https://img.shields.io/badge/Database-ObjectBox-red?style=flat-square)
![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub_Actions-2088FF?style=flat-square&logo=github-actions)

---

## ✨ ویژگی‌های کلیدی

* **⚡ مسیریابی ۱۰۰٪ آفلاین:** پس از یک‌بار دریافت نقشه، تمام پردازش‌ها روی دستگاه کاربر انجام می‌شود.
* **🧠 الگوریتم دایجسترا:** محاسبه کوتاه‌ترین مسیر و زمان تخمینی سفر در کسری از میلی‌ثانیه.
* **💾 پایگاه داده ObjectBox:** استفاده از موتور C++ برای ذخیره‌سازی و بازیابی فوق‌سریع گراف مترو.
* **🇮🇷 پشتیبانی کامل از زبان فارسی:** دارای سیستم Reverse Lookup برای جستجوی نام ایستگاه‌ها به زبان فارسی و پردازش انگلیسی در پس‌زمینه.
* **🎨 طراحی Engineering Chic:** رابط کاربری مینیمال، تمیز و متمرکز بر عملکرد (Dumb UI).
* **🛡 تست‌شده و پایدار:** دارای پوشش کامل تست‌های Unit و Integration.

---

## 🏗 معماری و تکنولوژی‌ها (Tech Stack)

این پروژه بر پایه **Clean Architecture** و اصول **SOLID** بنا شده است:

* **Presentation Layer:** مدیریت Stateها با `flutter_bloc` و `equatable`.
* **Domain Layer:** کپسوله‌سازی منطق تجاری (Business Logic) و الگوریتم گراف. مدیریت خطاها با برنامه نویسی تابعی (`dartz`).
* **Data Layer:** کلاینت شبکه با `dio` و کش محلی با `objectbox`.
* **Dependency Injection:** مدیریت وابستگی‌ها با `get_it`.

---

## 🚀 راهنمای نصب و اجرا (Getting Started)

برای اجرای این پروژه روی ماشین محلی خود، مراحل زیر را دنبال کنید:

### ۱. پیش‌نیازها
* نصب بودن Flutter SDK (نسخه ۳.۰ به بالا)
* نصب بودن Dart SDK

### ۲. دریافت کدها

git clone [https://github.com/b3hzadsh/metro-flutter.git](https://github.com/b3hzadsh/metro-flutter.git)

cd metro-flutter
