import 'package:flutter/widgets.dart';

import '../domain/cycle_predictor.dart';
import '../domain/models.dart';

/// Text available in every supported language. Longer health content lives
/// here rather than in ARB files so each tip stays next to its source.
class LocalizedText {
  const LocalizedText({required this.en, required this.tr});

  final String en;
  final String tr;

  String of(Locale locale) => locale.languageCode == 'tr' ? tr : en;
}

class Source {
  const Source(this.title, this.url);

  final String title;
  final String url;
}

class PhaseGuide {
  const PhaseGuide({
    required this.summary,
    required this.tips,
    required this.sources,
  });

  final LocalizedText summary;
  final List<LocalizedText> tips;
  final List<Source> sources;
}

class ConditionGuide {
  const ConditionGuide({
    required this.summary,
    required this.diet,
    required this.lifestyle,
    required this.sources,
    this.phaseNotes = const {},
  });

  final LocalizedText summary;
  final List<LocalizedText> diet;
  final List<LocalizedText> lifestyle;
  final List<Source> sources;

  /// Extra notes shown on the Today screen during specific phases.
  final Map<CyclePhase, LocalizedText> phaseNotes;
}

const _nhsPeriods = Source(
  'NHS – Periods',
  'https://www.nhs.uk/conditions/periods/',
);
const _nhsPeriodPain = Source(
  'NHS – Period pain',
  'https://www.nhs.uk/conditions/period-pain/',
);
const _nhsPms = Source(
  'NHS – PMS (premenstrual syndrome)',
  'https://www.nhs.uk/conditions/pre-menstrual-syndrome/',
);
const _nhsAnaemia = Source(
  'NHS – Iron deficiency anaemia',
  'https://www.nhs.uk/conditions/iron-deficiency-anaemia/',
);
const _nhsEatwell = Source(
  'NHS – The Eatwell Guide',
  'https://www.nhs.uk/live-well/eat-well/food-guidelines-and-food-labels/the-eatwell-guide/',
);
const _nhsActivity = Source(
  'NHS – Physical activity guidelines for adults',
  'https://www.nhs.uk/live-well/exercise/physical-activity-guidelines-for-adults-aged-19-to-64/',
);
const _nhsHeavyPeriods = Source(
  'NHS – Heavy periods',
  'https://www.nhs.uk/conditions/heavy-periods/',
);

/// A note shown with all phase tips: honest about the evidence base.
const phaseEvidenceNote = LocalizedText(
  en:
      'Research on eating differently in each cycle phase is limited. These '
      'tips follow general healthy-eating and NHS self-care advice for '
      'symptoms common in each phase.',
  tr:
      'Döngünün her evresinde farklı beslenmenin etkisine dair araştırmalar '
      'sınırlıdır. Bu öneriler, genel sağlıklı beslenme ilkelerine ve her '
      'evrede sık görülen belirtiler için NHS öz bakım tavsiyelerine dayanır.',
);

const fertilityDisclaimer = LocalizedText(
  en:
      'Fertile days are estimates. Sperm can survive up to 7 days, and '
      'ovulation varies from cycle to cycle. Never use these predictions as '
      'contraception.',
  tr:
      'Doğurgan günler tahminidir. Sperm 7 güne kadar yaşayabilir ve '
      'yumurtlama zamanı döngüden döngüye değişir. Bu tahminleri asla doğum '
      'kontrol yöntemi olarak kullanma.',
);

const phaseGuides = <CyclePhase, PhaseGuide>{
  CyclePhase.menstrual: PhaseGuide(
    summary: LocalizedText(
      en:
          'Your period. The lining of the womb is shed, and hormone levels '
          'are at their lowest.',
      tr:
          'Adet dönemi. Rahim iç zarı dökülür ve hormon seviyeleri en '
          'düşük düzeyindedir.',
    ),
    tips: [
      LocalizedText(
        en:
            'You lose iron with blood. Include iron-rich foods such as meat, '
            'pulses (beans, lentils, chickpeas), dark-green leafy vegetables '
            'and dried fruit like apricots.',
        tr:
            'Kanla birlikte demir kaybedersin. Et, kuru baklagiller (fasulye, '
            'mercimek, nohut), koyu yeşil yapraklı sebzeler ve kuru kayısı '
            'gibi demirden zengin besinlere yer ver.',
      ),
      LocalizedText(
        en:
            'Tea, coffee and dairy make iron harder to absorb in large '
            'amounts, so try having them between meals rather than with them.',
        tr:
            'Çay, kahve ve süt ürünleri fazla tüketildiğinde demir emilimini '
            'zorlaştırır; bunları yemekle birlikte değil, öğün aralarında '
            'içmeyi dene.',
      ),
      LocalizedText(
        en:
            'For cramps: a heat pad or hot water bottle on your tummy, a '
            'warm bath, and gentle exercise like walking, swimming or yoga.',
        tr:
            'Kramplar için: karnına sıcak su torbası veya ısı yastığı, ılık '
            'bir banyo ve yürüyüş, yüzme ya da yoga gibi hafif egzersizler.',
      ),
    ],
    sources: [_nhsPeriodPain, _nhsAnaemia],
  ),
  CyclePhase.follicular: PhaseGuide(
    summary: LocalizedText(
      en:
          'After your period, oestrogen rises as an egg matures. Many people '
          'notice their energy and mood lift.',
      tr:
          'Adetten sonra bir yumurta olgunlaşırken östrojen yükselir. Pek '
          'çok kişi enerjisinin ve ruh halinin yükseldiğini fark eder.',
    ),
    tips: [
      LocalizedText(
        en:
            'Build meals on the Eatwell Guide: plenty of fruit and vegetables, '
            'wholegrain starchy foods, and a source of protein.',
        tr:
            'Öğünlerini dengeli tabak modeline göre kur: bol meyve ve sebze, '
            'tam tahıllı nişastalı besinler ve bir protein kaynağı.',
      ),
      LocalizedText(
        en:
            'If you feel more energetic, this can be a good time for more '
            'active workouts. Adults are advised to do at least 150 minutes '
            'of moderate activity a week.',
        tr:
            'Kendini daha enerjik hissediyorsan daha tempolu antrenmanlar '
            'için iyi bir zaman olabilir. Yetişkinlere haftada en az 150 '
            'dakika orta yoğunlukta hareket önerilir.',
      ),
    ],
    sources: [_nhsEatwell, _nhsActivity],
  ),
  CyclePhase.ovulation: PhaseGuide(
    summary: LocalizedText(
      en:
          'An egg is released, about 12 to 16 days before your next period. '
          'This is your most fertile time.',
      tr:
          'Bir sonraki adetinden yaklaşık 12-16 gün önce bir yumurta '
          'serbest bırakılır. Bu, en doğurgan olduğun zamandır.',
    ),
    tips: [
      LocalizedText(
        en:
            'Keep up a balanced diet with fibre-rich foods, fruit and '
            'vegetables, and drink plenty of fluids.',
        tr:
            'Lifli besinler, meyve ve sebzelerle dengeli beslenmeye devam et '
            've bol sıvı tüket.',
      ),
      LocalizedText(
        en:
            'Some people feel a one-sided twinge around ovulation. Logging it '
            'helps you learn your own pattern.',
        tr:
            'Bazı kişiler yumurtlama sırasında tek taraflı hafif bir sancı '
            'hisseder. Bunu kaydetmek kendi düzenini öğrenmene yardımcı olur.',
      ),
    ],
    sources: [_nhsPeriods, _nhsEatwell],
  ),
  CyclePhase.luteal: PhaseGuide(
    summary: LocalizedText(
      en:
          'After ovulation, progesterone rises. In the days before your '
          'period you may notice PMS symptoms like bloating, cravings or '
          'mood changes.',
      tr:
          'Yumurtlamadan sonra progesteron yükselir. Adetten önceki günlerde '
          'şişkinlik, tatlı isteği veya ruh hali değişiklikleri gibi PMS '
          'belirtileri fark edebilirsin.',
    ),
    tips: [
      LocalizedText(
        en:
            'Smaller, more frequent meals every 2 to 3 hours can help with '
            'PMS symptoms.',
        tr:
            'Her 2-3 saatte bir daha küçük ve sık öğünler PMS belirtilerine '
            'iyi gelebilir.',
      ),
      LocalizedText(
        en:
            'Regular exercise, plenty of sleep, and stress relief such as yoga '
            'or meditation can ease PMS. Avoid smoking and too much alcohol.',
        tr:
            'Düzenli egzersiz, yeterli uyku ve yoga ya da meditasyon gibi '
            'stres azaltıcı uğraşlar PMS\'i hafifletebilir. Sigaradan ve '
            'fazla alkolden uzak dur.',
      ),
      LocalizedText(
        en:
            'Keep a symptom diary for at least 2 cycles. It is useful to '
            'bring to a doctor if symptoms affect your daily life.',
        tr:
            'En az 2 döngü boyunca belirti günlüğü tut. Belirtiler günlük '
            'hayatını etkiliyorsa doktora götürmek için çok faydalıdır.',
      ),
    ],
    sources: [_nhsPms],
  ),
};

const conditionGuides = <Condition, ConditionGuide>{
  Condition.pcos: ConditionGuide(
    summary: LocalizedText(
      en:
          'PCOS (now also called PMOS) commonly causes irregular periods, so '
          'cycle predictions may be less accurate for you.',
      tr:
          'PKOS (yeni adıyla PMOS) sıklıkla düzensiz adetlere yol açar; bu '
          'yüzden döngü tahminleri senin için daha az isabetli olabilir.',
    ),
    diet: [
      LocalizedText(
        en:
            'Eat a healthy, balanced diet based on fruit, vegetables, '
            'wholegrains and lean protein.',
        tr:
            'Meyve, sebze, tam tahıllar ve yağsız proteine dayalı sağlıklı '
            've dengeli beslen.',
      ),
      LocalizedText(
        en:
            'If you are overweight, losing weight can improve symptoms. Ask '
            'your doctor before starting a strict diet.',
        tr:
            'Fazla kilon varsa kilo vermek belirtileri iyileştirebilir. Katı '
            'bir diyete başlamadan önce doktoruna danış.',
      ),
    ],
    lifestyle: [
      LocalizedText(en: 'Exercise regularly.', tr: 'Düzenli egzersiz yap.'),
      LocalizedText(
        en: 'If symptoms are affecting your mood, talking therapy can help.',
        tr:
            'Belirtiler ruh halini etkiliyorsa konuşma terapisi yardımcı '
            'olabilir.',
      ),
    ],
    sources: [
      Source(
        'NHS – PCOS',
        'https://www.nhs.uk/conditions/polycystic-ovary-syndrome-pcos/',
      ),
    ],
  ),
  Condition.endometriosis: ConditionGuide(
    summary: LocalizedText(
      en:
          'Endometriosis can cause painful periods and long-term pain. '
          'Tracking your pain helps you and your doctor see patterns.',
      tr:
          'Endometriozis ağrılı adetlere ve uzun süreli ağrıya yol açabilir. '
          'Ağrını kaydetmek, senin ve doktorunun örüntüleri görmesine '
          'yardımcı olur.',
    ),
    diet: [
      LocalizedText(
        en:
            'No specific diet has been proven to treat endometriosis. A food '
            'and symptom diary can help you spot your own triggers. Talk to a '
            'doctor or dietitian before cutting out whole food groups.',
        tr:
            'Endometriozisi tedavi ettiği kanıtlanmış belirli bir diyet yok. '
            'Besin ve belirti günlüğü kendi tetikleyicilerini fark etmene '
            'yardımcı olabilir. Bir besin grubunu tamamen bırakmadan önce '
            'doktora veya diyetisyene danış.',
      ),
    ],
    lifestyle: [
      LocalizedText(
        en: 'Heat, rest and gentle exercise can ease pain on bad days.',
        tr:
            'Kötü günlerde sıcak uygulama, dinlenme ve hafif egzersiz ağrıyı '
            'hafifletebilir.',
      ),
      LocalizedText(
        en:
            'Support organisations such as Endometriosis UK offer help with '
            'living with the condition.',
        tr:
            'Endometriosis UK gibi destek kuruluşları hastalıkla yaşama '
            'konusunda yardım sunar.',
      ),
    ],
    sources: [
      Source(
        'NHS – Endometriosis',
        'https://www.nhs.uk/conditions/endometriosis/',
      ),
      _nhsPeriodPain,
    ],
    phaseNotes: {
      CyclePhase.menstrual: LocalizedText(
        en:
            'With endometriosis, log your pain each day of your period. A '
            'record is very useful at appointments.',
        tr:
            'Endometriozisin olduğu için adet boyunca ağrını her gün kaydet. '
            'Bu kayıt doktor randevularında çok işe yarar.',
      ),
    },
  ),
  Condition.ironDeficiencyAnemia: ConditionGuide(
    summary: LocalizedText(
      en:
          'Iron deficiency anaemia means your body is low on iron. Heavy '
          'periods are a common cause.',
      tr:
          'Demir eksikliği anemisi, vücudunda demirin az olduğu anlamına '
          'gelir. Yoğun adet kanamaları sık görülen bir nedendir.',
    ),
    diet: [
      LocalizedText(
        en:
            'Eat more: dark-green leafy vegetables (like kale), iron-fortified '
            'cereals and bread, meat, dried fruit (apricots, prunes, raisins) '
            'and pulses (beans, peas, lentils).',
        tr:
            'Daha çok tüket: koyu yeşil yapraklı sebzeler (karalahana gibi), '
            'demirle zenginleştirilmiş tahıllar ve ekmek, et, kuru meyveler '
            '(kayısı, erik, üzüm) ve baklagiller (fasulye, bezelye, mercimek).',
      ),
      LocalizedText(
        en:
            'Have less, especially around meals and iron tablets: tea, coffee, '
            'milk and dairy, and foods high in phytic acid like wholegrain '
            'cereals.',
        tr:
            'Özellikle yemeklerin ve demir ilacının yakınında daha az tüket: '
            'çay, kahve, süt ve süt ürünleri ile tam tahıllı gevrekler gibi '
            'fitik asitten zengin besinler.',
      ),
    ],
    lifestyle: [
      LocalizedText(
        en: 'Take iron tablets exactly as prescribed.',
        tr: 'Demir ilacını tam olarak reçete edildiği gibi kullan.',
      ),
      LocalizedText(
        en:
            'If your periods are heavy, tell your doctor: treating heavy '
            'bleeding helps prevent anaemia coming back.',
        tr:
            'Adetlerin yoğunsa doktoruna söyle: yoğun kanamanın tedavisi '
            'aneminin tekrarlamasını önlemeye yardımcı olur.',
      ),
    ],
    sources: [_nhsAnaemia, _nhsHeavyPeriods],
    phaseNotes: {
      CyclePhase.menstrual: LocalizedText(
        en:
            'With iron deficiency anaemia, your period is when iron intake '
            'matters most. If bleeding is heavy, let your doctor know.',
        tr:
            'Demir eksikliği anemin olduğu için adet dönemi, demir alımının en '
            'önemli olduğu zaman. Kanama yoğunsa doktorunu bilgilendir.',
      ),
    },
  ),
  Condition.hypothyroidism: ConditionGuide(
    summary: LocalizedText(
      en:
          'An underactive thyroid can make periods heavier or irregular, and '
          'often causes tiredness.',
      tr:
          'Az çalışan tiroid, adetleri yoğunlaştırabilir veya düzensiz hale '
          'getirebilir ve sıklıkla yorgunluğa yol açar.',
    ),
    diet: [
      LocalizedText(
        en:
            'Levothyroxine is taken on an empty stomach, 30 to 60 minutes '
            'before breakfast, caffeinated drinks or other medicines.',
        tr:
            'Levotiroksin aç karnına; kahvaltıdan, kafeinli içeceklerden ve '
            'diğer ilaçlardan 30-60 dakika önce alınır.',
      ),
      LocalizedText(
        en:
            'Calcium and iron supplements can affect how levothyroxine works. '
            'Ask your pharmacist how to time them.',
        tr:
            'Kalsiyum ve demir takviyeleri levotiroksinin etkisini '
            'değiştirebilir. Ne zaman alacağını eczacına sor.',
      ),
    ],
    lifestyle: [
      LocalizedText(
        en: 'Try to take your medicine at the same time each day.',
        tr: 'İlacını her gün aynı saatte almaya çalış.',
      ),
      LocalizedText(
        en:
            'Tell your doctor if your periods change, as your dose may need '
            'checking.',
        tr:
            'Adetlerinde değişiklik olursa doktoruna söyle; dozunun kontrol '
            'edilmesi gerekebilir.',
      ),
    ],
    sources: [
      Source(
        'NHS – Underactive thyroid',
        'https://www.nhs.uk/conditions/underactive-thyroid-hypothyroidism/',
      ),
      Source(
        'NHS – Levothyroxine',
        'https://www.nhs.uk/medicines/levothyroxine/',
      ),
    ],
  ),
  Condition.insulinResistance: ConditionGuide(
    summary: LocalizedText(
      en:
          'Insulin resistance and type 2 diabetes make it harder to keep '
          'blood sugar steady. Diet and activity make a real difference.',
      tr:
          'İnsülin direnci ve tip 2 diyabet kan şekerini dengede tutmayı '
          'zorlaştırır. Beslenme ve hareket gerçek bir fark yaratır.',
    ),
    diet: [
      LocalizedText(
        en:
            'Base meals on fruit, vegetables, wholegrains such as wholemeal '
            'bread and oats, and pulses such as chickpeas and lentils.',
        tr:
            'Öğünlerini meyve, sebze, tam buğday ekmeği ve yulaf gibi tam '
            'tahıllar ve nohut, mercimek gibi baklagiller üzerine kur.',
      ),
      LocalizedText(
        en:
            'Limit processed foods high in salt and sugar. Do not start a very '
            'low-calorie diet without talking to a health professional.',
        tr:
            'Tuz ve şeker oranı yüksek işlenmiş gıdaları sınırla. Bir sağlık '
            'profesyoneliyle konuşmadan çok düşük kalorili bir diyete başlama.',
      ),
    ],
    lifestyle: [
      LocalizedText(
        en:
            'Aim for at least 2.5 hours a week of walking or other activity '
            'that leaves you out of breath.',
        tr:
            'Haftada en az 2,5 saat yürüyüş veya seni nefes nefese bırakan '
            'başka bir aktivite hedefle.',
      ),
      LocalizedText(
        en:
            'Small changes each week are easier to keep than a big change '
            'all at once.',
        tr:
            'Her hafta yapılan küçük değişiklikleri sürdürmek, bir anda '
            'yapılan büyük bir değişiklikten daha kolaydır.',
      ),
    ],
    sources: [
      Source(
        'NHS – Type 2 diabetes',
        'https://www.nhs.uk/conditions/type-2-diabetes/',
      ),
    ],
    phaseNotes: {
      CyclePhase.luteal: LocalizedText(
        en:
            'Cravings are common before a period. Choosing wholegrain, '
            'high-fibre snacks over sugary ones helps keep your blood sugar '
            'steadier.',
        tr:
            'Adet öncesinde tatlı isteği sık görülür. Şekerli atıştırmalıklar '
            'yerine tam tahıllı, lifli seçenekler kan şekerini daha dengede '
            'tutmaya yardımcı olur.',
      ),
    },
  ),
};
