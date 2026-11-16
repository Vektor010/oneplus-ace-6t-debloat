# ⚡ OnePlus Ace 6T (ColorOS 16 CN) — Debloat, Freeze & Battery Tool

Универсальный инструмент для репликации чистой рабочей конфигурации смартфона **OnePlus Ace 6T** (модель `PLR110`, сборка `ColorOS 16 CN01`).

Инструмент основан на реальном проверенном профиле устройства автора: отключает 82 ненужных пакета, безопасно замораживает 13 системных служб (которые прошивка запрещает отключать напрямую), выполняет ART-оптимизацию и диагностирует приложения с повышенным расходом аккумулятора.

[![Device](https://img.shields.io/badge/Device-OnePlus%20Ace%206T%20(PLR110)-orange?style=flat-square)](https://github.com/Vektor010/oneplus-ace-6t-debloat)
[![OS](https://img.shields.io/badge/OS-ColorOS%2016%20CN01-blue?style=flat-square)](https://github.com/Vektor010/oneplus-ace-6t-debloat)
[![Root](https://img.shields.io/badge/Root-Not%20Required-success?style=flat-square)](https://github.com/Vektor010/oneplus-ace-6t-debloat)
[![Rollback](https://img.shields.io/badge/Rollback-100%25%20Supported-brightgreen?style=flat-square)](https://github.com/Vektor010/oneplus-ace-6t-debloat)
[![License](https://img.shields.io/badge/License-MIT-lightgrey?style=flat-square)](https://github.com/Vektor010/oneplus-ace-6t-debloat/blob/main/LICENSE)

---

## 📦 Быстрый старт

1. Скачайте готовый архив из раздела [**Releases**](https://github.com/Vektor010/oneplus-ace-6t-debloat/releases/latest) (`OnePlus_Ace6T_Debloat_Tool.zip`).
   > Архив уже содержит портативные компоненты `adb` — ничего дополнительно на ПК настраивать не нужно.
2. Распакуйте архив в любую папку.
3. Включите **«Отладку по USB»** на смартфоне (`Настройки` → `Об устройстве` → `Версия` → 7 раз по `Номер сборки` → `Дополнительные настройки` → `Для разработчиков` → `Отладка по USB`).
4. Подключите телефон к компьютеру по USB и подтвердите диалог авторизации отладки.
5. Запустите **`Run_Debloat.bat`** (или выполните `OnePlus_Ace6T_Clone_Debloat.ps1` через PowerShell).

---

## 🎯 Основные возможности

### 1. Отключение 82 пакетов (`pm disable-user --user 0`)
- **Китайские сервисы**: Baidu Search, Baidu Input, AutoNavi Amap, FinShell Wallet, UnionPay TSM, HeyTap Music, Yoli Video, Oppo Store.
- **Тяжелая графика**: `com.heytap.colorfulengine` (3D/OpenGL движок живых обоев ColorOS, создающий постоянную нагрузку на RAM и GPU).
- **Фоновая телеметрия**: `sauhelper`, `logtrial`, `powermonitor`, `qti.dcf`, компоненты рекламных песочниц Android Privacy Sandbox.
- **Ненужные службы**: OCar, CarLink, DigitalKey, ViewTalk, TravelEngine, системный сканер Gamma Scan.

### 2. Заморозка 13 служб (`pm suspend --user 0`)
В ColorOS 16 ряд системных пакетов защищен от прямого отключения (`pm disable-user` возвращает ошибку или сбрасывается системой). Скрипт переводит их в состояние глубокой заморозки:
1. `com.heytap.browser` — встроенный китайский браузер
2. `com.heytap.market` — китайский магазин приложений App Market
3. `com.heytap.pictorial` — карусель обоев экрана блокировки (один из главных источников жора батареи)
4. `com.heytap.quicksearchbox` — поисковая строка на рабочем столе
5. `com.heytap.htms` — системный транспорт HeyTap
6. `com.opos.ads` — модуль контекстной рекламы Oppo/ColorOS
7. `com.coloros.securityguard` — защитник ColorOS Security Guard (вызывает ложные блокировки сторонних APK)
8. `com.nearme.instant.platform` — платформа мгновенных приложений Instant Apps
9. `com.oplus.themestore` — магазин тем
10. `com.oppo.store` — китайский магазин
11. `com.heytap.speechassist` — голосовой помощник Breeno
12. `com.oplus.ovoicemanager` — распознавание речи Breeno Voice
13. `com.oplus.ovoicemanager.wakeup` — фоновое прослушивание ключевой фразы

### 3. Оптимизация системы и кэша
- Безопасный сброс дискового кэша (`pm trim-caches 999999999999`) без сброса учетных записей.
- Принудительная AOT-компиляция профилей (`cmd package compile -m speed-profile -a`) для устранения микрофризов в анимациях.

### 4. 🔋 Аналитика энергопотребления (Top App Drain)
- Считывание метрик из `dumpsys batterystats` с привязкой UID к реальным именам приложений через `pm list packages -U`.
- Таблица расхода в миллиампер-часах (мА·ч / mAh) с разделением на экранные процессы и фоновую активность.

---

## 🛡️ Безопасность и защита от сбоев

- **Проверка модели**: Скрипт валидирует `ro.product.model == PLR110` и регион прошивки перед выполнением любых операций.
- **Динамический белый список (Whitelist)**:
  - Текущая клавиатура (Gboard и др.) защищена от отключения.
  - Активный лаунчер (рабочий стол) защищен от отключения.
  - VPN-сервисы (включая `com.happproxy`), сервисы Google Play (`com.google.android.gms`, `com.android.vending`) и установленные игры не затрагиваются.
- **Автоматический бэкап**: Перед внесением изменений список пакетов устройства сохраняется в папку `Backups/`.
- **100% обратимость (Rollback)**: Пункт меню `[4]` выполняет `pm enable` для всех 82 пакетов и `pm unsuspend` для всех 13 служб, возвращая телефон в заводское состояние.

---

## 📋 Меню утилиты

```text
======================================================================
   ONEPLUS ACE 6T (PLR110) - COLOROS 16 CN01 TOOLBOX                   
======================================================================
 Выберите действие:
 [1] Применить слепок автора (Отключить 82 пакета + Заморозить 13 пакетов)
 [2] Оптимизация приложений (ART Dexopt) и безопасная очистка кэша
 [3] Анализ расхода батареи (Поиск фонового жора и Top App Drain)
 [4] Полный откат (Включить 82 пакета + Разморозить 13 пакетов)
 [5] Диагностика состояния устройства (версия, заряд, память)
 [6] Перезагрузить устройство
 [0] Выход
```

---

## 📑 Содержимое репозитория

| Файл | Описание |
| :--- | :--- |
| `OnePlus_Ace6T_Clone_Debloat.ps1` | Основной исполняемый скрипт PowerShell с интерактивным меню |
| `Run_Debloat.bat` | Пакетный файл запуска в 1 клик с обходом ExecutionPolicy |
| `disabled_packages_list.txt` | Полный каталог отключенных и замороженных компонентов с пояснениями |
| `README.md` | Документация и руководство пользователя |

---

## ⚖️ Дисклеймер

Инструмент тестировался исключительно на модели **OnePlus Ace 6T (PLR110)** с китайской версией прошивки **ColorOS 16 CN01**. Автор не несет ответственности за попытки применения скрипта на других смартфонах или других версиях ОС.
