# Cyclia

[![CI](https://github.com/efemir255/cyclia/actions/workflows/ci.yml/badge.svg)](https://github.com/efemir255/cyclia/actions/workflows/ci.yml)
![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?logo=flutter)
![Platforms](https://img.shields.io/badge/platforms-Android%20%7C%20iOS-lightgrey)
![Status](https://img.shields.io/badge/status-phase%201-orange)
![License](https://img.shields.io/badge/license-MIT-green)

A private, offline-first menstrual cycle and women's health companion for
**Android and iOS**, built with Flutter.

Cyclia predicts upcoming periods, explains what each cycle phase means for
nutrition and wellbeing, and gives diet and lifestyle guidance that takes the
user's own diagnosed conditions and blood test results into account.

## Principles

- **Your data never leaves your phone.** There is no server and no account.
  Everything is stored in an encrypted on-device database and the app can be
  locked with biometrics or a PIN.
- **No diagnosis.** Cyclia never diagnoses conditions. Users enter conditions a
  doctor has already diagnosed, and the app adapts its general guidance to
  them. Out-of-range lab values are flagged with a suggestion to talk to a
  doctor.
- **Sourced guidance.** Health and nutrition content is based on reputable
  public sources (e.g. WHO, NHS, ACOG), which are cited in the app.
- **Built with real feedback.** Features are shaped by feedback from real users
  and tracked openly in GitHub Issues.

## Roadmap

| Phase | Scope | Status |
| --- | --- | --- |
| 1. Cycle tracking | Period logging, start/end predictions, calendar, daily symptom & mood log, reminders, phase-based nutrition tips, diagnosed conditions with tailored guidance, encrypted storage, app lock | 🚧 In progress |
| 2. Lab results | Manual blood test entry, reference ranges, trend charts | Planned |
| 3. Lab report scanning | Read values from a photo or PDF of a lab report, fully on-device | Planned |
| 4. Diet planning | Daily macro- and micronutrient targets based on lab results and conditions, food database | Planned |
| 5. Sexual health | Test result records, testing reminders, educational content | Planned |

## Features (phase 1)

- **Cycle tracking** – log when a period starts and ends from the Today screen,
  or add and edit past periods from the calendar.
- **Predictions** – next period start and end, estimated ovulation and fertile
  window, cycle day and phase, and a "days late" status. Averages come from the
  last six plausible cycles; gaps from unlogged periods are ignored.
- **Calendar** – logged, predicted and fertile days at a glance.
- **Daily log** – flow, ten common symptoms, mood and a free-text note.
- **Phase guidance** – nutrition and self-care tips for each phase, with an
  honest note on how limited the evidence for phase-specific diets is.
- **Diagnosed conditions** – PCOS/PMOS, endometriosis, iron deficiency anaemia,
  underactive thyroid and insulin resistance / type 2 diabetes, each with diet
  and lifestyle guidance and phase-specific notes. Every tip cites its source.
- **Insights** – average cycle and period length, recent cycle lengths chart,
  most logged symptoms.
- **Reminders** – two days before the next period and an optional daily
  check-in. Notification text is neutral and hidden on the lock screen.
- **App lock** – fingerprint, face or device PIN.
- **English and Turkish**, light and dark theme.

## How privacy is implemented

| Concern | Implementation |
| --- | --- |
| Storage | SQLCipher-encrypted SQLite database (`sqflite_sqlcipher`) |
| Encryption key | Random 256-bit key generated on first launch and kept in the Android Keystore / iOS Keychain (`flutter_secure_storage`) |
| Backups | Android auto-backup disabled so health data is never copied to the cloud |
| Network | No servers, accounts, analytics or tracking. Source links are copied, not opened |
| Notifications | Neutral wording, private visibility on the Android lock screen |
| App access | Optional lock using the device's biometrics or screen lock (`local_auth`) |
| Deletion | "Delete all data" permanently erases every record on the device |

## Architecture

```
lib/
├── core/      DST-safe calendar-day helpers
├── domain/    Models, cycle prediction and calendar rules (pure Dart, fully unit tested)
├── data/      CycliaRepository interface, SQL implementation, encryption key store
├── content/   Sourced, bilingual phase and condition guidance
├── services/  Notification scheduling and app lock, behind interfaces
├── state/     Riverpod providers: settings, cycle data, forecast, reminder sync
├── ui/        Screens and widgets
└── l10n/      English and Turkish strings
```

The UI only talks to Riverpod providers. Providers depend on interfaces
(`CycliaRepository`, `ReminderScheduler`, `AppLocker`) that `main.dart` wires to
the real implementations and tests replace with in-memory fakes. Prediction
logic is pure and takes `today` as a parameter, which keeps it deterministic.

## Testing

```bash
flutter test
```

- **Domain** – predictions, averages, late periods, phases, fertile windows,
  calendar marking and period editing rules, including daylight-saving changes.
- **Data** – the real SQL schema against an in-memory database.
- **Widgets** – onboarding, starting and ending a period, logging symptoms,
  condition notes, reminder scheduling, app lock, language switching and
  deleting all data.

CI runs formatting, analysis and tests on every push, then builds a release APK
and an unsigned iOS app on a macOS runner.

## Getting started

Requirements: Flutter 3.47+ and Android Studio (for the Android SDK). Building
for iOS requires macOS with Xcode, or the project's CI.

```bash
git clone https://github.com/efemir255/cyclia.git
cd cyclia
flutter pub get
flutter run
```

## Disclaimer

Cyclia provides general information and is not a medical device. It does not
replace professional medical advice, diagnosis or treatment. Cycle and
fertility predictions are estimates and must not be used as a method of
contraception.

## License

[MIT](LICENSE)
