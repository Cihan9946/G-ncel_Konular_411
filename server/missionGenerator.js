// ============================================================
//  server/missionGenerator.js
//  Görev üreteci — Türkçe ilkokul seviyesi içerik
// ============================================================

const MISSIONS = [
  // ── GÖREV 1: Yakıt Krizi (Matematik - Toplama) ──────────────
  {
    id: "mission_fuel_01",
    title: "⚡ Yakıt Krizi!",
    markerType: "yellow",        // Sarı marker tetikler
    storyText:
      "Dikkat mürettebat! Denizaltımızın yakıt deposu kritik seviyeye düştü! " +
      "Sarı ışıklı deposumuzu bulduk ama ne kadar yakıt yükleyeceğimizi hesaplamamız gerekiyor. " +
      "Biyolog, hemen hesapla!",
    captainBriefing:
      "Kaptan olarak görevin: Gözcüyü mavi mürekkep fabrikasına yönlendir ve yakıt miktarını hesapla. Ardından 'Yakıt Yükle!' komutunu ver.",
    scoutInstruction:
      "Sarı marker'ı bul! Kameranı yavaşça akvaryumun sağ köşesindeki sarı işaretçiye yönelt.",
    biologyChallenge: {
      type: "math",
      question: "Depoda 18 litre yakıt vardı. Mavi depostan 24 litre daha yükledik. Şimdi toplam kaç litre yakıtımız var?",
      choices: ["38", "42", "32", "46"],
      correctAnswer: "42",
      explanation:
        "18 + 24 = 42 litre! Harika hesapladın! Denizaltımız artık yeterli yakıta sahip.",
      points: 100,
      difficulty: "easy"
    },
    arContent: {
      object: "fuel_tank",      // AR'da görünecek nesne
      animation: "pulse_yellow",
      soundCue: "alarm_beep"
    },
    successMessage: "🎉 Yakıt deposu dolu! Misyon tamamlandı!",
    duration: 90 // saniye
  },

  // ── GÖREV 2: Gizemli Yaratık (Biyoloji) ─────────────────────
  {
    id: "mission_creature_01",
    title: "🐙 Gizemli Yaratık Tespiti!",
    markerType: "blue",          // Mavi marker tetikler
    storyText:
      "Alarmmm! Sonarımız çok büyük bir yabancı yaratık tespit etti! " +
      "Derin denizin bu gizemli sakinini tanımamamız gerekiyor. " +
      "Gözcüler mavi işaretçiyi tarayın, biyolog veri tabanını inceleyin!",
    captainBriefing:
      "Kaptan olarak görevin: Sonar sesini duyuyorsun! Gözcüyü mavi marker'a yönlendir, biyologdan bilgi al ve merkeze rapor ver. 'Yaratık Tanımlandı!' komutunu unutma!",
    scoutInstruction:
      "Mavi marker'ı bul! Kameranı sol taraftaki mavi işaretçiye yönelt ve hologram belirene kadar bekle.",
    biologyChallenge: {
      type: "biology",
      question: "Ahtapotun kaç kolu (tentakülü) vardır?",
      choices: ["6", "8", "10", "12"],
      correctAnswer: "8",
      explanation:
        "Doğru! Ahtapotun 8 kolu vardır. Her kolu üzerinde vantuzlar bulunur ve bu vantuzlarla hem tutunur hem de tatma duyusunu kullanır!",
      funFact:
        "🤯 Biliyor muydun? Ahtapot 3 kalbe sahiptir ve kanı mavi renktedir!",
      points: 120,
      difficulty: "easy"
    },
    arContent: {
      object: "octopus_hologram",
      animation: "float_rotate",
      soundCue: "sonar_ping"
    },
    successMessage: "🐙 Yaratık tanımlandı! Deniz biyolojisi veri tabanı güncellendi!",
    duration: 90
  },

  // ── GÖREV 3: Deniz Haritası (Okuma Anlama) ──────────────────
  {
    id: "mission_map_01",
    title: "🗺️ Kayıp Deniz Haritası!",
    markerType: "green",         // Yeşil marker tetikler
    storyText:
      "Kaptanlar günlüğünde şifreli bir mesaj bulduk! " +
      "Yeşil marker'ın arkasında çok eski bir deniz haritası gizli. " +
      "Onu bulmadan bu denizden çıkamayız!",
    captainBriefing:
      "Kaptan olarak görevin: Biyolog şifreli mesajı okuyacak. Dikkatle dinle ve doğru soruyu yanıtla. Ardından 'Rota Belirlendi!' komutunu ver.",
    scoutInstruction:
      "Yeşil marker'ı bul! Akvaryumun alt köşesindeki yeşil işaretçiyi tara.",
    biologyChallenge: {
      type: "reading",
      passage:
        "Derin denizlerde yaşayan balıklar çok özel özelliklere sahiptir. " +
        "Bu balıkların çoğu, karanlık sularda ışık üretebilir. " +
        "Bu özelliğe 'biyolüminesans' denir. " +
        "Ayrıca derin deniz balıklarının gözleri çok büyüktür. " +
        "Büyük gözler sayesinde az ışıkta bile görebilirler.",
      question: "Derin deniz balıklarının gözleri neden büyüktür?",
      choices: [
        "Daha hızlı yüzmek için",
        "Az ışıkta görebilmek için",
        "Av yakalamak için",
        "Düşmanlarından kaçmak için"
      ],
      correctAnswer: "Az ışıkta görebilmek için",
      explanation:
        "Harika! Derin sularda güneş ışığı ulaşmadığı için büyük gözler çok daha fazla ışık toplayarak görmelerine yardımcı olur.",
      points: 150,
      difficulty: "medium"
    },
    arContent: {
      object: "treasure_map",
      animation: "glow_green",
      soundCue: "discovery_chime"
    },
    successMessage: "🗺️ Harita çözüldü! Yol güvenli, ilerliyoruz!",
    duration: 120
  },

  // ── GÖREV 4: Tehlike Bölgesi (Hızlı Karar) ─────────────────
  {
    id: "mission_danger_01",
    title: "🚨 ALARM! Tehlike Bölgesi!",
    markerType: "red",           // Kırmızı marker tetikler
    storyText:
      "ACİL DURUM! Sonar, önümüzde büyük bir kaya engeli tespit etti! " +
      "Sağa mı döneceğiz, sola mı? Hızlı düşün, hızlı karar ver! " +
      "Mürettebat, kaptan komuta bekliyor!",
    captainBriefing:
      "Kaptan olarak TÜM KARAR SENİN! Gözcünün verdiği bilgiyi al ve sağa ya da sola dönme kararını ver. Süren sadece 30 saniye!",
    scoutInstruction:
      "ACELE! Kırmızı marker'ı bul! Kameranı hızlıca kırmızı işaretçiye yönelt!",
    biologyChallenge: {
      type: "decision",
      question: "Sonar verisine göre sağ tarafta 3 kaya, sol tarafta 5 balık okulu var. Hangisi daha az riskli?",
      choices: [
        "Sağa dön — kaya riski al",
        "Sola dön — balık okuluyla karşılaş",
        "Dur ve yardım iste",
        "Geri dön"
      ],
      correctAnswer: "Sola dön — balık okuluyla karşılaş",
      explanation:
        "Zekice! Balıklar denizaltıya zarar vermez ama kayalar tehlikeli olabilir. İyi karar verdin!",
      points: 200,
      difficulty: "hard"
    },
    arContent: {
      object: "warning_beacon",
      animation: "flash_red",
      soundCue: "alarm_urgent"
    },
    successMessage: "✅ Tehlike atlatıldı! Kaptan harika bir karar verdi!",
    duration: 60
  },

  // ── GÖREV 5: Deniz Sayımı (Matematik - Çarpma temel) ────────
  {
    id: "mission_count_01",
    title: "🐠 Balık Sayımı!",
    markerType: "blue",
    storyText:
      "Bilim için akvaryumdaki balıkları saymalıyız! " +
      "Her grupta eşit sayıda balık var. " +
      "Toplam balık sayısını bulabilir misiniz?",
    captainBriefing:
      "Kaptan olarak görevin: Biyologun hesaplamasını onaylamak. Doğru sayıyı bulduktan sonra 'Sayım Tamamlandı!' de.",
    scoutInstruction:
      "Mavi marker'ı tarayarak balık hologramını aktive et!",
    biologyChallenge: {
      type: "math",
      question: "Akvaryumda 4 grup balık var. Her grupta 6 balık var. Toplam kaç balık var?",
      choices: ["20", "24", "18", "26"],
      correctAnswer: "24",
      explanation:
        "4 × 6 = 24 balık! Tebrikler! Çarpma işlemini harika kullandın!",
      points: 130,
      difficulty: "medium"
    },
    arContent: {
      object: "fish_school",
      animation: "swimming_group",
      soundCue: "bubble_pop"
    },
    successMessage: "📊 Balık sayımı tamamlandı! Bilim veri tabanı güncellendi!",
    duration: 90
  }
];

// ── Mission seçimi ─────────────────────────────────────────────
class MissionGenerator {
  constructor() {
    this.usedMissionIds = new Set();
  }

  /**
   * Rastgele bir görev seç (aynı görev tekrar seçilmez)
   * @param {string} [preferredMarker] - Belirli bir marker tipi için görev
   * @returns {Object} mission
   */
  getNextMission(preferredMarker = null) {
    let pool = MISSIONS.filter((m) => !this.usedMissionIds.has(m.id));

    if (pool.length === 0) {
      // Tüm görevler oynandı — havuzu sıfırla
      this.usedMissionIds.clear();
      pool = [...MISSIONS];
    }

    if (preferredMarker) {
      const filtered = pool.filter((m) => m.markerType === preferredMarker);
      if (filtered.length > 0) pool = filtered;
    }

    const mission = pool[Math.floor(Math.random() * pool.length)];
    this.usedMissionIds.add(mission.id);
    return { ...mission }; // immutable copy
  }

  /**
   * Marker tipine göre görev getir
   * @param {string} markerType - "red" | "blue" | "yellow" | "green"
   */
  getMissionByMarker(markerType) {
    const matching = MISSIONS.filter((m) => m.markerType === markerType);
    if (matching.length === 0) return this.getNextMission();
    return { ...matching[Math.floor(Math.random() * matching.length)] };
  }

  /** Tüm görevleri listele */
  getAllMissions() {
    return MISSIONS.map((m) => ({
      id: m.id,
      title: m.title,
      markerType: m.markerType,
      difficulty: m.biologyChallenge.difficulty
    }));
  }

  reset() {
    this.usedMissionIds.clear();
  }
}

module.exports = { MissionGenerator, MISSIONS };
