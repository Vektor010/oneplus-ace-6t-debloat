<div align="center">

<img src="https://raw.githubusercontent.com/Vektor010/oneplus-ace-6t-debloat/main/assets/banner.gif?v=2" width="100%" alt="OnePlus Ace 6T ColorOS 16 CN Debloat Toolbox">

<br>

<img src="https://readme-typing-svg.herokuapp.com?font=Fira+Code&weight=700&size=28&duration=2800&pause=900&color=EB0028&center=true&vCenter=true&width=760&lines=ONEPLUS+ACE+6T+%C2%B7+PLR110+CN01;82+DISABLED+%2B+13+FROZEN+APPS;ZERO+ROOT+%C2%B7+100%25+ROLLBACK;ADB+%2B+USB+DRIVER+INCLUDED" alt="Typing SVG">

<br>

[![Скачать готовый архив](https://img.shields.io/badge/%D0%A1%D0%9A%D0%90%D0%A7%D0%90%D0%A2%D0%AC_%D0%90%D0%A0%D0%A5%D0%98%D0%92_(ADB_%2B_%D0%94%D0%A0%D0%90%D0%99%D0%92%D0%95%D0%A0)-v1.0.0-10B981?style=for-the-badge&logo=android&logoColor=white)](https://github.com/Vektor010/oneplus-ace-6t-debloat/releases/latest)

<br>

[![Гайд новичкам](https://img.shields.io/badge/%D0%93%D0%B0%D0%B9%D0%B4_%D0%BD%D0%BE%D0%B2%D0%B8%D1%87%D0%BA%D0%B0%D0%BC-2563EB?style=for-the-badge&logo=rocket&logoColor=white)](#-установка-и-запуск-для-новичков)
[![Вернуть Остров](https://img.shields.io/badge/%D0%92%D0%B5%D1%80%D0%BD%D1%83%D1%82%D1%8C_%D0%9E%D1%81%D1%82%D1%80%D0%BE%D0%B2-EB0028?style=for-the-badge&logo=oneplus&logoColor=white)](#-как-вернуть-нужную-функцию-отдельно)
[![Все 95 пакетов](https://img.shields.io/badge/%D0%92%D1%81%D0%B5_95_%D0%BF%D0%B0%D0%BA%D0%B5%D1%82%D0%BE%D0%B2-7C3AED?style=for-the-badge&logo=bookstack&logoColor=white)](#-справочник-всех-95-пакетов)
[![FAQ и Откат](https://img.shields.io/badge/FAQ_%D0%B8_%D0%9E%D1%82%D0%BA%D0%B0%D1%82-F97316?style=for-the-badge&logo=dependabot&logoColor=white)](#-частые-вопросы)

<br>

![OnePlus Ace 6T](https://img.shields.io/badge/OnePlus_Ace_6T-PLR110-18181B?style=flat-square&logo=oneplus&logoColor=EB0028)
![ColorOS 16](https://img.shields.io/badge/ColorOS_16-CN01-18181B?style=flat-square&logo=android&logoColor=3DDC84)
![Root](https://img.shields.io/badge/Root-%D0%9D%D0%B5_%D0%BD%D1%83%D0%B6%D0%B5%D0%BD-18181B?style=flat-square)
![Rollback](https://img.shields.io/badge/%D0%9E%D1%82%D0%BA%D0%B0%D1%82-100%25_%D0%B2_1_%D0%BA%D0%BB%D0%B8%D0%BA-18181B?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-18181B?style=flat-square)

</div>

---

## Что делает этот инструмент

Инструмент переносит проверенную рабочую конфигурацию **OnePlus Ace 6T (PLR110, ColorOS 16 CN01)** на ваш смартфон в один клик:

* **Отключает 82 лишних пакета (`pm disable-user`)** — убирает китайские сервисы (Baidu, AutoNavi, FinShell, UnionPay, HeyTap Music/Yoli), тяжёлый 3D-движок живых обоев (`colorfulengine`), фоновую телеметрию и лишние региональные службы.
* **Замораживает 13 защищённых служб (`pm suspend`)** — полностью останавливает в фоне **HeyTap Browser**, **App Market**, рекламу **Oppo Ads**, карусель обоев экрана блокировки, **Breeno Voice** и китайский защитник **Security Guard**.
* **Анализирует жор батареи (`Top App Drain`)** — считывает `dumpsys batterystats` и показывает реальный ТОП-15 приложений по расходу заряда в **мА·ч (mAh)**.
* **Ускоряет систему (`ART speed-profile`)** — безопасно очищает системный кэш и компилирует приложения под процессор Snapdragon для плавных анимаций.

> [!IMPORTANT]
> **Защита от «кирпича»:** Скрипт работает без Root, не затрагивает раздел `/system` и сохраняет все ваши фото и данные. Перед запуском автоматически проверяется модель **`PLR110`** и регион **`CN01`** — на другом смартфоне скрипт остановится. Клавиатура (Gboard), рабочий стол, связь, Google Play (`gms`, `vending`) и VPN защищены жёстким белым списком.

---

## 🚀 Установка и запуск для новичков

> [!NOTE]
> **Ничего дополнительно искать не нужно.** В архиве уже лежат рабочий портативный **ADB** (`platform-tools`), официальный **Google USB Driver** (`Drivers/usb_driver`), запуск в 1 клик (`Run_Debloat.bat`) и оффлайн-гайд (`ИНСТРУКЦИЯ_ДЛЯ_НОВИЧКОВ.txt`).

### Шаг 1. Скачайте и распакуйте архив
Скачайте [**`OnePlus_Ace6T_Debloat_Tool.zip`**](https://github.com/Vektor010/oneplus-ace-6t-debloat/releases/latest) и **распакуйте** в отдельную папку *(правый клик → «Извлечь все...»)*. Не запускайте файлы прямо внутри окна архиватора.

### Шаг 2. Включите отладку по USB на телефоне
1. Откройте **Настройки** ➔ **Об устройстве** ➔ **Версия** ➔ нажмите **7 раз** на **Номер сборки**.
2. Перейдите в **Настройки** ➔ **Дополнительные настройки** *(или Система и обновления)* ➔ **Для разработчиков**.
3. Включите **«Отладка по USB»** и *(рекомендуется для ColorOS)* **«Отключить мониторинг разрешений»**.

### Шаг 3. Подключите к ПК
1. Подключите OnePlus Ace 6T к ПК кабелем USB и разблокируйте экран.
2. В шторке уведомлений выберите режим USB **«Передача файлов»** *(не оставляйте «Только зарядка»)*.
3. На **Windows 10 / 11** драйвер (`WinUSB`) уже встроен в систему — смартфон определяется автоматически.

<details>
<summary>Если Windows не видит телефон — 3 способа поставить драйвер</summary>
<br>

1. **Встроенный драйвер OnePlus:** откройте «Этот компьютер» ➔ виртуальный диск `OnePlus Drivers` ➔ запустите `OnePlus_USB_Drivers_Setup.exe`.
2. **Официальный Google USB Driver (уже в архиве):** нажмите `Win + X` ➔ **Диспетчер устройств** ➔ ПКМ по устройству с жёлтым треугольником (`一加 Ace 6T` / `ADB Interface`) ➔ **Обновить драйвер** ➔ **Найти на этом компьютере** ➔ **Выбрать из списка** ➔ **Показать все устройства** ➔ **Установить с диска...** ➔ выберите `Drivers\usb_driver\android_winusb.inf` ➔ **Android ADB Interface**.
3. **Установщик в 1 клик:** скачайте официальный [Universal ADB Driver (.msi)](https://github.com/koush/adb.clockworkmod.com/releases/latest).

</details>

### Шаг 4. Запустите `Run_Debloat.bat`
1. Дважды кликните по **`Run_Debloat.bat`** *(если появится окно Windows SmartScreen — нажмите «Подробнее» → «Выполнить в любом случае»)*.
2. **На экране смартфона** отметьте *«Всегда разрешать с этого компьютера»* и нажмите **«Разрешить»**.
3. В главном меню введите **`1`** ➔ подтвердите **`1`** ➔ дождитесь завершения (~20 сек) и перезагрузите смартфон.

---

## 🏝️ Как вернуть нужную функцию отдельно

Если после применения слепка вы хотите вернуть **только одну конкретную функцию** (не откатывая всё целиком):  
откройте папку `platform-tools` из архива, введите `cmd` в адресной строке проводника (`Enter`) и вставьте нужную команду кнопкой копирования справа сверху блока.

### Вернуть «Остров» (Fluid Cloud / Живые оповещения / Плеер у камеры)
За работу динамического острова вокруг камеры отвечают системная шина `OCS`, контроллер медиа и движок сценариев:

```cmd
adb shell pm enable --user 0 com.coloros.ocs.opencapabilityservice
adb shell pm enable --user 0 com.oplus.smartmediacontroller
adb shell pm enable --user 0 com.oplus.smartengine
adb shell pm enable --user 0 com.oplus.aiwidgets
adb shell pm enable --user 0 com.oplus.metis
adb shell pm enable --user 0 com.coloros.sceneservice
```

> [!TIP]
> После возврата **«Острова»** или **AOD** перезагрузите телефон (`adb reboot`), чтобы ColorOS заново запустила службы.

### Вернуть Always-On Display (AOD)

```cmd
adb shell pm enable --user 0 com.oplus.aod
```

### Вернуть расширенные скриншоты и запись экрана

```cmd
adb shell pm enable --user 0 com.oplus.screenshot
adb shell pm enable --user 0 com.oplus.screenrecorder
```

### Вернуть Умную боковую панель (Smart Sidebar)

```cmd
adb shell pm enable --user 0 com.coloros.smartsidebar
```

### Вернуть Игровой режим (Game Toolkit)

```cmd
adb shell pm enable --user 0 com.oplus.games
```

<details>
<summary>Показать команды для остальных функций (Диктофон, Компас, ИК-пульт, OShare, Android Auto, Gmail, Браузер)</summary>
<br>

**Диктофон и Компас:**
```cmd
adb shell pm enable --user 0 com.coloros.soundrecorder
adb shell pm enable --user 0 com.coloros.compass2
```

**ИК-пульт (управление ТВ / кондиционером):**
```cmd
adb shell pm enable --user 0 com.oplus.consumerIRApp
```

**Защита зрения (Eye Comfort):**
```cmd
adb shell pm enable --user 0 com.oplus.eyeprotect
```

**OShare и Трансляция экрана:**
```cmd
adb shell pm enable --user 0 com.coloros.oshare
adb shell pm enable --user 0 com.coloros.sharescreen
```

**Android Auto:**
```cmd
adb shell pm enable --user 0 com.google.android.projection.gearhead
```

**Gmail, Google Поиск и Google Объектив (Lens):**
```cmd
adb shell pm enable --user 0 com.google.android.gm
adb shell pm enable --user 0 com.google.android.googlequicksearchbox
adb shell pm enable --user 0 com.google.ar.lens
```

**Разморозить китайский браузер, App Market или Магазин тем:**
```cmd
adb shell pm unsuspend --user 0 com.heytap.browser
adb shell pm unsuspend --user 0 com.heytap.market
adb shell pm unsuspend --user 0 com.oplus.themestore
```

</details>

---

## 📋 Справочник всех 95 пакетов

Ниже расписан **каждый** пакет из скрипта (82 отключаемых + 13 замораживаемых).  
Значок `🟡` отмечает пакеты, отвечающие за видимые функции интерфейса (их можно вернуть отдельно командами выше).

<details open>
<summary><b>13 замороженных служб ColorOS (<code>pm suspend --user 0</code>)</b></summary>
<br>

| Пакет | За что отвечает |
| :--- | :--- |
| `com.heytap.browser` | Встроенный китайский браузер HeyTap с рекламой |
| `com.heytap.market` | Китайский магазин приложений App Market |
| `com.heytap.pictorial` | Карусель обоев экрана блокировки (сильный жор батареи) |
| `com.heytap.quicksearchbox` | Китайская строка поиска на рабочем столе |
| `com.heytap.htms` | Системный транспортный сервис HeyTap |
| `com.opos.ads` | Главный рекламный модуль ColorOS / OPPO Ads |
| `com.coloros.securityguard` | Китайский защитник (мешает установке сторонних APK) |
| `com.nearme.instant.platform` | Платформа мгновенных китайских приложений Quick Apps |
| `com.oplus.themestore` | 🟡 Магазин тем OPlus Theme Store |
| `com.oppo.store` | Фирменный интернет-магазин техники OPPO Store |
| `com.heytap.speechassist` | Китайский голосовой помощник Breeno |
| `com.oplus.ovoicemanager` | Движок распознавания речи Breeno Voice |
| `com.oplus.ovoicemanager.wakeup` | Фоновое прослушивание ключевой фразы Breeno |

</details>

<details>
<summary><b>31 пакет — Утилиты и функции ColorOS / OPlus (<code>pm disable-user</code>)</b></summary>
<br>

| Пакет | За что отвечает |
| :--- | :--- |
| `com.heytap.colorfulengine` | 🟡 Тяжёлый 3D-движок живых обоев ColorOS (жор GPU/RAM) |
| `com.android.wallpaper.livepicker.overlay` | 🟡 Системный оверлей выбора живых обоев |
| `com.coloros.ocs.opencapabilityservice` | 🟡 **«Остров» (Fluid Cloud)** — системная шина OCS |
| `com.oplus.smartmediacontroller` | 🟡 **«Остров» (Fluid Cloud)** — плеер у камеры и на экране блокировки |
| `com.oplus.smartengine` | 🟡 **«Остров» (Fluid Cloud)** — триггеры и сценарии SmartEngine |
| `com.oplus.aiwidgets` | 🟡 **«Остров» / AI** — умные карточки и виджеты ColorOS |
| `com.oplus.aod` | 🟡 **Always-On Display** — часы на выключенном экране |
| `com.oplus.screenshot` | 🟡 **Скриншоты** — расширенные и длинные скриншоты ColorOS |
| `com.oplus.screenrecorder` | 🟡 **Запись экрана** — встроенный рекордер ColorOS |
| `com.coloros.smartsidebar` | 🟡 **Смарт-панель** — выдвижная боковая панель |
| `com.oplus.games` | 🟡 **Игровой режим** — центр игр и панель Game Toolkit |
| `com.coloros.soundrecorder` | 🟡 **Диктофон** — встроенная запись звука |
| `com.coloros.compass2` | 🟡 **Компас** — встроенное приложение компаса |
| `com.oplus.consumerIRApp` | 🟡 **ИК-пульт** — управление ТВ и кондиционером |
| `com.oplus.eyeprotect` | 🟡 **Защита зрения** — оверлей режима Eye Comfort |
| `com.coloros.oshare` | 🟡 **OShare** — быстрая передача файлов OPPO/OnePlus |
| `com.coloros.sharescreen` | 🟡 **Трансляция экрана** — совместный просмотр экрана |
| `com.oplus.account` | 🟡 Облачный аккаунт HeyTap / OPPO Account |
| `com.coloros.codebook` | Встроенный китайский менеджер паролей Codebook |
| `com.coloros.digitalwellbeing` | Модуль «Цифровое благополучие» ColorOS |
| `com.coloros.karaoke` | Аудио-эффекты микрофона для китайских караоке-приложений |
| `com.coloros.mapcom.frame` | Вспомогательный фреймворк китайских карт |
| `com.coloros.remoteguardservice` | Китайский сервис родительского контроля RemoteGuard |
| `com.coloros.securepay` | Проверка безопасности китайских платёжных приложений |
| `com.coloros.smartlock` | Умная разблокировка ColorOS SmartLock |
| `com.gamma.scan` | Предустановленный китайский сканер документов |
| `com.oplus.melody` | Сервис мелодий и китайской обвязки HeyMelody |
| `com.oplus.ovoicemanager` | Голосовой движок Breeno Voice |
| `com.oplus.ovoicemanager.wakeup` | Пробуждение голосового ассистента Breeno |
| `com.oplus.owork` | Китайский рабочий профиль OWork |
| `com.oplus.phonenoareainquire` | Определение китайских провинций по номеру телефона |

</details>

<details>
<summary><b>15 пакетов — Китайские сервисы и партнёрский софт (<code>pm disable-user</code>)</b></summary>
<br>

| Пакет | За что отвечает |
| :--- | :--- |
| `com.baidu.searchbox` | Китайский поисковик и браузер Baidu |
| `com.baidu.input_oppo` | Китайская клавиатура Baidu IME *(Gboard защищена)* |
| `com.autonavi.minimap` | Китайские карты и навигатор AutoNavi (Amap) |
| `com.finshell.wallet` | Китайский кошелёк FinShell Wallet / HeyTap Pay |
| `com.unionpay.tsmservice` | Служба бесконтактной оплаты UnionPay TSM |
| `com.heytap.themestore` | Магазин тем HeyTap (legacy-пакет) |
| `com.heytap.music` | Китайский музыкальный сервис HeyTap Music |
| `com.heytap.vip` | Клуб лояльности и подписок HeyTap VIP |
| `com.heytap.yoli` | Китайский видеосервис HeyTap Yoli |
| `com.heytap.accessory` | Менеджер подключения китайских аксессуаров HeyTap |
| `com.heytap.speechassist` | Китайский голосовой ассистент Breeno |
| `com.oppo.store` | Фирменный магазин OPPO Store CN |
| `com.oppo.ctautoregist` | Фоновая авторегистрация SIM China Telecom |
| `com.oppo.instant.local.service` | Локальная служба Quick Apps CN |
| `com.ted.number` | База китайских спам-номеров Ted Number |

</details>

<details>
<summary><b>14 пакетов — Телеметрия, логи и рекламные SDK (<code>pm disable-user</code>)</b></summary>
<br>

| Пакет | За что отвечает |
| :--- | :--- |
| `com.oplus.sauhelper` | Фоновая служба тихих обновлений и телеметрии SAU |
| `com.oplus.logtrial` | Сборщик системных логов и краш-дампов |
| `com.oplus.powermonitor` | Фоновый сборщик статистики расхода и аналитики |
| `com.oplus.atlas` | Диагностическая телеметрия подсистем Atlas |
| `com.oplus.dfs` | Распределённая файловая служба экосистемы OPPO |
| `com.oplus.owkservice` | Фоновая служба синхронизации и пробуждения OWK |
| `com.oplus.sos` | Региональные экстренные вызовы SOS (CN) |
| `com.oplus.stdsp` | Вспомогательная служба DSP-аналитики |
| `com.oplus.subsys` | Сервисный демон мониторинга подсистем Subsys |
| `com.oplus.vdc` | Контроллер виртуальных дисплеев VDC |
| `com.qti.dcf` | Телеметрия чипсета Qualcomm DCF |
| `com.android.adservices.api` | Рекламное API Android Privacy Sandbox |
| `com.android.federatedcompute.services` | Фоновое федеративное обучение (ML-аналитика) |
| `com.android.ondevicepersonalization.services` | Персонализация рекламы на устройстве |

</details>

<details>
<summary><b>5 пакетов — Автомобильные сервисы и IoT (<code>pm disable-user</code>)</b></summary>
<br>

| Пакет | За что отвечает |
| :--- | :--- |
| `com.heytap.opluscarlink` | Подключение к мультимедиа китайских авто CarLink |
| `com.oplus.ocar` | Автомобильная оболочка OCar |
| `com.oplus.cardigitalkey` | Цифровой NFC/BLE-ключ для китайских авто |
| `com.oplus.viewtalk` | Видеосвязь и вывод в авто ViewTalk |
| `com.oplus.travelengine` | Китайский сервис подсказок в поездках (рейсы, отели) |

</details>

<details>
<summary><b>13 пакетов — Редко используемые службы Android / Qualcomm / MS (<code>pm disable-user</code>)</b></summary>
<br>

| Пакет | За что отвечает |
| :--- | :--- |
| `andes.oplus.documentsreader` | Встроенный просмотрщик документов Andes |
| `com.android.cellbroadcastreceiver` | Широковещательные оповещения ЧС (Cell Broadcast) |
| `com.android.cts.priv.ctsshim` | Заводской тестовый модуль Compatibility Test Suite |
| `com.android.DeviceAsWebcam` | 🟡 Использование смартфона как USB веб-камеры для ПК |
| `com.android.dynsystem` | Загрузчик тестовых динамических образов DSU |
| `com.android.healthconnect.controller` | 🟡 Агрегатор фитнес-данных Health Connect |
| `com.android.hotspot2.osulogin` | Авторизация корпоративных сетей Wi-Fi Passpoint |
| `com.android.musicfx` | Устаревший системный эквалайзер AOSP MusicFX |
| `com.android.printspooler` | 🟡 Служба сетевой печати на принтеры |
| `com.android.simappdialog` | Меню оператора SIM Toolkit (часто шлёт спам) |
| `com.android.virtualization.terminal` | Виртуальный Linux-терминал Android Virtualization |
| `com.microsoftsdk.crossdeviceservicebroker` | 🟡 Фоновый брокер «Связь с Windows» от Microsoft |
| `com.qualcomm.qti.powersavemode` | Устаревший модуль энергосбережения Qualcomm |

</details>

<details>
<summary><b>4 пакета — Доп. приложения Google (Play Market и GMS НЕ тронуты)</b></summary>
<br>

| Пакет | За что отвечает |
| :--- | :--- |
| `com.google.android.gm` | 🟡 Почтовый клиент Gmail |
| `com.google.android.googlequicksearchbox` | 🟡 Приложение «Google Поиск» и виджет поиска |
| `com.google.android.projection.gearhead` | 🟡 **Android Auto** (подключение к магнитоле авто) |
| `com.google.ar.lens` | 🟡 Поиск по камере Google Объектив (Lens) |

</details>

---

## ❓ Частые вопросы

<details>
<summary><b>Как полностью откатить всё обратно?</b></summary>
<br>
Запустите <code>Run_Debloat.bat</code> ➔ выберите пункт <b>[4] Полный откат</b> ➔ подтвердите цифрой <b>1</b>. Все 82 отключённых и 13 замороженных пакетов вернутся в заводское состояние.
</details>

<details>
<summary><b>Не сломается ли Google Play, связь или уведомления?</b></summary>
<br>
Нет. <code>com.google.android.gms</code> (Google Play Services), <code>com.android.vending</code> (Google Play), активная клавиатура, рабочий стол, связь и VPN защищены жёстким белым списком и не затрагиваются.
</details>

<details>
<summary><b>Как узнать, какое приложение сажает батарею?</b></summary>
<br>
Запустите <code>Run_Debloat.bat</code> и выберите пункт <b>[3] Анализ расхода батареи</b> — скрипт выведет ТОП-15 приложений по реальному расходу энергии в <b>мА·ч (mAh)</b>.
</details>

---

<div align="center">

<sub><b>OnePlus Ace 6T (PLR110 · ColorOS 16 CN01)</b> &bull; Debloat &amp; Battery Optimization Tool &bull; By <b>Vektor010</b> &bull; MIT</sub>

</div>
