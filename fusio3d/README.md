# Fusio3D — Android приложение за заявки за 3D печат

Мобилно Android приложение (Kotlin + Jetpack Compose), с което клиент подава
**заявка за 3D печат**. За сега без цени и каталог — само заявка: клиентът описва
какво иска да се принтира, а заявката се доставя до собственика.

Продукцията засега е на **Bambu Lab H2S** (FDM), затова материалите по подразбиране
са PLA / PETG / ABS / ASA / TPU.

## Как работи изпращането

Приложението работи **без бекенд**. При натискане на „Изпрати заявка":

1. Ако е конфигуриран **webhook URL** (виж по-долу) — заявката се праща като JSON
   `POST` заявка към него.
2. Иначе — отваря се системен **share sheet** (Gmail / имейл / WhatsApp / Telegram /
   SMS), с предварително попълнен текст на заявката към имейла на собственика.

Така приложението е използваемо веднага, а по-късно лесно се закача към сайт/бекенд.

### Конфигуриране без промяна на кода

Стойностите се подават като Gradle properties при билд:

```bash
./gradlew assembleRelease \
  -PorderEmail=you@example.com \
  -PorderWebhookUrl=https://api.example.com/orders
```

По подразбиране: `orderEmail=yasinuzunow@gmail.com`, `orderWebhookUrl` е празен
(т.е. използва се share sheet).

Полетата стигат до кода през `BuildConfig.ORDER_EMAIL` и `BuildConfig.ORDER_WEBHOOK_URL`.

## Стек

- Kotlin, Jetpack Compose, Material 3
- Min SDK 24 (Android 7.0), Target/Compile SDK 34
- AGP 8.5.2, Gradle 8.7, Kotlin 1.9.24
- Без външни мрежови библиотеки — само `HttpURLConnection`

## Данни на заявката

| Поле | Задължително |
|---|---|
| Име | да |
| Контакт (тел./имейл) | да |
| Какво да принтираме | да |
| Материал | PLA/PETG/ABS/ASA/TPU/друг |
| Брой | по подразбиране 1 |
| Цвят | не |
| Линк към модел/снимка | не |
| Бележки | не |

## Билд

Изисква Android SDK (platform 34, build-tools 34) и JDK 17.

```bash
cd fusio3d
# посочи SDK пътя (или чрез ANDROID_HOME)
echo "sdk.dir=$HOME/Android/Sdk" > local.properties

./gradlew assembleDebug        # -> app/build/outputs/apk/debug/app-debug.apk
```

Инсталиране на устройство/емулатор:

```bash
adb install -r app/build/outputs/apk/debug/app-debug.apk
```

## Тествано

Билднат и пуснат на Android 14 емулатор (Pixel 6, x86_64):
изгледът се зарежда, валидацията на задължителните полета работи, dropdown-ът за
материал работи, а изпращането отваря share sheet с попълнена заявка. (Виж
скрийншотите в описанието на PR-а.)

## Известни ограничения / следващи стъпки

- Няма цени/каталог (по проектно решение — само заявка засега).
- Няма локална история на заявките.
- Няма качване на файл (STL/3MF) — за сега се подава линк към модел. Може да се
  добави прикачване на файл през share sheet или качване към бекенд.
- Следваща стъпка: същински бекенд + сайт (`fusio3d.com` е свободен) и връзка
  на приложението към него през `orderWebhookUrl`.
