// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Cyclia';

  @override
  String get navToday => 'Bugün';

  @override
  String get navCalendar => 'Takvim';

  @override
  String get navHealth => 'Sağlık';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get next => 'İleri';

  @override
  String get back => 'Geri';

  @override
  String get save => 'Kaydet';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get delete => 'Sil';

  @override
  String get edit => 'Düzenle';

  @override
  String get sources => 'Kaynaklar';

  @override
  String get onboardingWelcomeTitle => 'Cyclia\'ya hoş geldin';

  @override
  String get onboardingWelcomeBody =>
      'Döngünü takip et, her evreyi anla ve sağlığına uygun öneriler al.';

  @override
  String get privacyLocal =>
      'Verilerin bu telefonda kalır. Hesap yok, bulut yok.';

  @override
  String get privacyEncrypted => 'Her şey şifreli bir veritabanında saklanır.';

  @override
  String get privacyNoDiagnosis =>
      'Cyclia asla teşhis koymaz. Önerileri genel bilgi niteliğindedir, tıbbi tavsiye değildir.';

  @override
  String get disclaimerAccept =>
      'Cyclia\'nın tıbbi bir cihaz olmadığını ve tahminlerinin doğum kontrol yöntemi olarak kullanılmaması gerektiğini anlıyorum.';

  @override
  String get lastPeriodTitle => 'Son adetin ne zaman başladı?';

  @override
  String get lastPeriodUnknown => 'Hatırlamıyorum';

  @override
  String get cycleTitle => 'Her zamanki döngün';

  @override
  String get cycleLength => 'Döngü süresi';

  @override
  String get periodLength => 'Adet süresi';

  @override
  String get cycleLengthHint =>
      'Bir adetin ilk gününden bir sonrakinin ilk gününe kadar geçen süre. Emin değilsen varsayılanları bırak; Cyclia kayıt girdikçe öğrenir.';

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gün',
    );
    return '$_temp0';
  }

  @override
  String get conditionsTitle => 'Teşhis konmuş durumlar';

  @override
  String get conditionsBody =>
      'İsteğe bağlı. Doktorunun teşhis koyduğu durumları seç, Cyclia önerilerini buna göre uyarlasın. Daha sonra değiştirebilirsin.';

  @override
  String get finishOnboarding => 'Cyclia\'yı kullanmaya başla';

  @override
  String get conditionPcos => 'PKOS / PMOS';

  @override
  String get conditionEndometriosis => 'Endometriozis';

  @override
  String get conditionIronDeficiencyAnemia => 'Demir eksikliği anemisi';

  @override
  String get conditionHypothyroidism => 'Az çalışan tiroid (hipotiroidi)';

  @override
  String get conditionInsulinResistance => 'İnsülin direnci / tip 2 diyabet';

  @override
  String get phaseMenstrual => 'Adet evresi';

  @override
  String get phaseFollicular => 'Foliküler evre';

  @override
  String get phaseOvulation => 'Yumurtlama';

  @override
  String get phaseLuteal => 'Luteal evre';

  @override
  String get noDataTitle => 'Tahminleri görmek için adetini kaydet';

  @override
  String get noDataBody =>
      'Bir sonraki adetinin ilk günü aşağıdaki düğmeye dokun ya da takvimden geçmiş bir adet ekle.';

  @override
  String get periodStarted => 'Adetim başladı';

  @override
  String get periodEnded => 'Adetim bitti';

  @override
  String periodDay(int day) {
    return 'Adetin $day. günü';
  }

  @override
  String periodExpectedEnd(String date) {
    return 'Tahmini bitiş: $date';
  }

  @override
  String periodIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Adetine $count gün var',
      one: 'Adetin yarın bekleniyor',
      zero: 'Adetin bugün bekleniyor',
    );
    return '$_temp0';
  }

  @override
  String periodLate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Adetin $count gün gecikti',
    );
    return '$_temp0';
  }

  @override
  String get lateHint =>
      'Adet stres, hastalık, kilo değişimi ve başka nedenlerle gecikebilir. Hamile olma ihtimalin varsa test yap; endişeleniyorsan bir doktorla konuş.';

  @override
  String cycleDay(int day) {
    return 'Döngünün $day. günü';
  }

  @override
  String nextPeriodOn(String date) {
    return 'Sonraki adet tahmini: $date';
  }

  @override
  String fertileWindow(String start, String end) {
    return 'Tahmini doğurgan günler: $start – $end';
  }

  @override
  String get todayLog => 'Bugünün kaydı';

  @override
  String get logSymptoms => 'Belirti ve ruh hali kaydet';

  @override
  String get nothingLogged => 'Bugün henüz bir şey kaydetmedin.';

  @override
  String get phaseTips => 'Bu evre için öneriler';

  @override
  String get forYourConditions => 'Durumların için';

  @override
  String get errorInFuture => 'Gelecekteki bir gün için adet kaydedemezsin.';

  @override
  String get errorInsidePeriod => 'Bu gün için zaten bir adet kaydı var.';

  @override
  String get flow => 'Akış';

  @override
  String get flowSpotting => 'Lekelenme';

  @override
  String get flowLight => 'Hafif';

  @override
  String get flowMedium => 'Orta';

  @override
  String get flowHeavy => 'Yoğun';

  @override
  String get symptoms => 'Belirtiler';

  @override
  String get symptomCramps => 'Kramp';

  @override
  String get symptomHeadache => 'Baş ağrısı';

  @override
  String get symptomBloating => 'Şişkinlik';

  @override
  String get symptomBackPain => 'Bel ağrısı';

  @override
  String get symptomBreastTenderness => 'Göğüs hassasiyeti';

  @override
  String get symptomAcne => 'Sivilce';

  @override
  String get symptomFatigue => 'Yorgunluk';

  @override
  String get symptomNausea => 'Bulantı';

  @override
  String get symptomCravings => 'Tatlı / yemek isteği';

  @override
  String get symptomInsomnia => 'Kötü uyku';

  @override
  String get mood => 'Ruh hali';

  @override
  String get moodHappy => 'Mutlu';

  @override
  String get moodCalm => 'Sakin';

  @override
  String get moodEnergetic => 'Enerjik';

  @override
  String get moodSensitive => 'Hassas';

  @override
  String get moodSad => 'Üzgün';

  @override
  String get moodAnxious => 'Kaygılı';

  @override
  String get moodIrritable => 'Sinirli';

  @override
  String get note => 'Not';

  @override
  String get period => 'Adet';

  @override
  String get startPeriodHere => 'Adetim bu gün başladı';

  @override
  String get endPeriodHere => 'Adetim bu gün bitti';

  @override
  String get deletePeriod => 'Bu adet kaydını sil';

  @override
  String get deletePeriodTitle => 'Adet kaydı silinsin mi?';

  @override
  String deletePeriodBody(String start) {
    return '$start tarihinde başlayan adet kaydı silinecek. Belirti kayıtların korunur.';
  }

  @override
  String loggedPeriodRange(String start, String end) {
    return 'Kayıtlı adet: $start – $end';
  }

  @override
  String ongoingPeriodFrom(String start) {
    return '$start tarihinden beri süren adet';
  }

  @override
  String get legendPeriod => 'Adet';

  @override
  String get legendPredicted => 'Tahmini';

  @override
  String get legendFertile => 'Doğurgan';

  @override
  String get legendOvulation => 'Yumurtlama';

  @override
  String get today => 'Bugün';

  @override
  String get yourCycle => 'Döngün';

  @override
  String get averageCycle => 'Ortalama döngü';

  @override
  String get averagePeriod => 'Ortalama adet';

  @override
  String get cyclesLogged => 'Kayıtlı döngü';

  @override
  String get recentCycles => 'Son döngü süreleri';

  @override
  String get notEnoughCycles =>
      'Döngü geçmişini görmek için en az iki adet kaydet.';

  @override
  String get commonSymptoms => 'En sık kaydedilen belirtiler (son 90 gün)';

  @override
  String get noSymptoms => 'Son 90 günde belirti kaydı yok.';

  @override
  String get myConditions => 'Durumlarım';

  @override
  String get noConditions =>
      'Eklenmiş bir durum yok. Doktorunun teşhis koyduğu durumları eklersen Cyclia önerilerini sana göre uyarlar.';

  @override
  String get dietTips => 'Beslenme';

  @override
  String get lifestyleTips => 'Yaşam tarzı';

  @override
  String get cyclePhases => 'Döngü evrelerin';

  @override
  String get disclaimerShort =>
      'Cyclia genel bilgi sunar, tıbbi tavsiye vermez. Sağlığınla ilgili konularda bir doktora danış.';

  @override
  String get appearance => 'Görünüm';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get language => 'Dil';

  @override
  String get languageSystem => 'Sistem';

  @override
  String get privacySecurity => 'Gizlilik ve güvenlik';

  @override
  String get appLock => 'Uygulama kilidi';

  @override
  String get appLockSubtitle =>
      'Cyclia\'yı açmak için parmak izi, yüz tanıma veya cihaz PIN\'i iste';

  @override
  String get appLockUnavailable =>
      'Uygulama kilidini kullanmak için cihazında bir ekran kilidi ayarla.';

  @override
  String get reminders => 'Hatırlatıcılar';

  @override
  String get periodReminder => 'Yaklaşan adet';

  @override
  String get periodReminderSubtitle => 'Tahmini adetinden iki gün önce';

  @override
  String get dailyReminder => 'Günlük kayıt hatırlatması';

  @override
  String get off => 'Kapalı';

  @override
  String get notificationsDenied =>
      'Cyclia için bildirimler kapalı. Hatırlatıcı almak için telefonunun ayarlarından aç.';

  @override
  String get cycleDefaults => 'Varsayılan döngü';

  @override
  String get cycleDefaultsHint =>
      'Kişisel ortalamaların hesaplanmasına yetecek kadar döngü kaydedene kadar kullanılır.';

  @override
  String get about => 'Hakkında';

  @override
  String get aboutBody =>
      'Cyclia açık kaynaklı bir projedir. Verilerin asla bu cihazdan çıkmaz.';

  @override
  String get disclaimerFull =>
      'Cyclia genel bilgi sağlar ve tıbbi bir cihaz değildir. Profesyonel tıbbi tavsiye, teşhis veya tedavinin yerini tutmaz. Döngü ve doğurganlık tahminleri yaklaşıktır ve doğum kontrol yöntemi olarak kullanılmamalıdır.';

  @override
  String get deleteAllData => 'Tüm verileri sil';

  @override
  String get deleteAllTitle => 'Tüm veriler silinsin mi?';

  @override
  String get deleteAllBody =>
      'Bu işlem bu telefondaki tüm adet, günlük ve durum kayıtlarını kalıcı olarak siler. Geri alınamaz.';

  @override
  String get deleteAllConfirm => 'Her şeyi sil';

  @override
  String get lockedTitle => 'Cyclia kilitli';

  @override
  String get unlock => 'Kilidi aç';

  @override
  String get unlockReason =>
      'Sağlık verilerini görmek için Cyclia\'nın kilidini aç';

  @override
  String get periodReminderBody =>
      'Yaklaşık iki gün içinde yeni bir döngü başlayabilir.';

  @override
  String get dailyReminderBody =>
      'Bugün nasıl hissediyorsun? Kayıt için bir dakikanı ayır.';

  @override
  String get dbErrorTitle => 'Verilerin açılamıyor';

  @override
  String get dbErrorBody =>
      'Bu telefondaki şifreleme anahtarı kayıp ya da değişmiş, bu yüzden mevcut veriler okunamıyor. Sıfırdan başlayabilirsin; okunamayan veriler silinecek.';

  @override
  String get startFresh => 'Sil ve sıfırdan başla';
}
