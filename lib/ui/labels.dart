import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../domain/cycle_predictor.dart';
import '../domain/models.dart';
import '../l10n/app_localizations.dart';

/// Localized names for domain enums, kept out of the domain layer.
extension EnumLabels on AppLocalizations {
  String phaseLabel(CyclePhase p) => switch (p) {
    CyclePhase.menstrual => phaseMenstrual,
    CyclePhase.follicular => phaseFollicular,
    CyclePhase.ovulation => phaseOvulation,
    CyclePhase.luteal => phaseLuteal,
  };

  String flowLabel(FlowLevel f) => switch (f) {
    FlowLevel.spotting => flowSpotting,
    FlowLevel.light => flowLight,
    FlowLevel.medium => flowMedium,
    FlowLevel.heavy => flowHeavy,
  };

  String symptomLabel(Symptom s) => switch (s) {
    Symptom.cramps => symptomCramps,
    Symptom.headache => symptomHeadache,
    Symptom.bloating => symptomBloating,
    Symptom.backPain => symptomBackPain,
    Symptom.breastTenderness => symptomBreastTenderness,
    Symptom.acne => symptomAcne,
    Symptom.fatigue => symptomFatigue,
    Symptom.nausea => symptomNausea,
    Symptom.cravings => symptomCravings,
    Symptom.insomnia => symptomInsomnia,
  };

  String moodLabel(Mood m) => switch (m) {
    Mood.happy => moodHappy,
    Mood.calm => moodCalm,
    Mood.energetic => moodEnergetic,
    Mood.sensitive => moodSensitive,
    Mood.sad => moodSad,
    Mood.anxious => moodAnxious,
    Mood.irritable => moodIrritable,
  };

  String conditionLabel(Condition c) => switch (c) {
    Condition.pcos => conditionPcos,
    Condition.endometriosis => conditionEndometriosis,
    Condition.ironDeficiencyAnemia => conditionIronDeficiencyAnemia,
    Condition.hypothyroidism => conditionHypothyroidism,
    Condition.insulinResistance => conditionInsulinResistance,
  };
}

/// Short locale-aware dates like "12 Mar" / "12 Mar".
String shortDate(BuildContext context, DateTime d) =>
    DateFormat.MMMd(Localizations.localeOf(context).toLanguageTag()).format(d);

String longDate(BuildContext context, DateTime d) =>
    DateFormat.yMMMMEEEEd(Localizations.localeOf(context).toLanguageTag())
        .format(d);
