# Cyclia

![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?logo=flutter)
![Platforms](https://img.shields.io/badge/platforms-Android%20%7C%20iOS-lightgrey)
![Status](https://img.shields.io/badge/status-early%20development-orange)
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
