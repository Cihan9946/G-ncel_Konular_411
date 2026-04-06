// ============================================================
//  server/reportService.js
//  Öğretmen raporu için performans verisi toplama
// ============================================================

class ReportService {
  constructor(sessionId) {
    this.sessionId = sessionId;
    this.startTime = Date.now();
    this.events = []; // Tüm oyun olayları]
    this.answers = []; // Verilen cevaplar
    this.markerScans = []; // Taranan markerlar
    this.roleActivity = {
      captain: { decisions: 0, correctDecisions: 0 },
      scout1: { markersFound: 0, scanTime: [] },
      scout2: { markersFound: 0, scanTime: [] },
      biologist: { answersGiven: 0, correctAnswers: 0, totalTime: 0 }
    };
  }

  /** Bir oyun olayını kaydet */
  logEvent(type, data) {
    this.events.push({
      timestamp: Date.now(),
      elapsed: Math.round((Date.now() - this.startTime) / 1000),
      type,
      data
    });
  }

  /** Cevap sonucunu kaydet */
  logAnswer({ questionId, questionType, correct, timeSpent, role }) {
    this.answers.push({
      timestamp: Date.now(),
      questionId,
      questionType,
      correct,
      timeSpent,
      role
    });

    if (role === "biologist") {
      this.roleActivity.biologist.answersGiven++;
      if (correct) this.roleActivity.biologist.correctAnswers++;
      this.roleActivity.biologist.totalTime += timeSpent;
    }

    if (role === "captain") {
      this.roleActivity.captain.decisions++;
      if (correct) this.roleActivity.captain.correctDecisions++;
    }
  }

  /** Marker taramasını kaydet */
  logMarkerScan({ marker, role, scanDuration }) {
    this.markerScans.push({ timestamp: Date.now(), marker, role, scanDuration });

    const roleKey = role === "scout1" ? "scout1" : "scout2";
    if (this.roleActivity[roleKey]) {
      this.roleActivity[roleKey].markersFound++;
      this.roleActivity[roleKey].scanTime.push(scanDuration);
    }
  }

  /** Toplam skoru hesapla */
  calculateScore(missionsCompleted) {
    const baseScore = missionsCompleted * 100;
    const correctAnswers = this.answers.filter((a) => a.correct).length;
    const totalAnswers = this.answers.length;
    const accuracyBonus = totalAnswers > 0
      ? Math.round((correctAnswers / totalAnswers) * 200)
      : 0;

    const timeBonus = this._calculateTimeBonus();

    return {
      base: baseScore,
      accuracyBonus,
      timeBonus,
      total: baseScore + accuracyBonus + timeBonus
    };
  }

  _calculateTimeBonus() {
    const elapsedMin = (Date.now() - this.startTime) / 60000;
    if (elapsedMin < 10) return 150;
    if (elapsedMin < 15) return 100;
    if (elapsedMin < 20) return 50;
    return 0;
  }

  /** Öğretmen için rapor oluştur */
  generateReport(sessionData, missionsCompleted) {
    const totalTime = Math.round((Date.now() - this.startTime) / 1000);
    const correctAnswers = this.answers.filter((a) => a.correct).length;
    const totalAnswers = this.answers.length;
    const accuracy = totalAnswers > 0
      ? Math.round((correctAnswers / totalAnswers) * 100)
      : 0;

    // Konu bazlı analiz
    const byType = {};
    for (const a of this.answers) {
      if (!byType[a.questionType]) byType[a.questionType] = { correct: 0, total: 0 };
      byType[a.questionType].total++;
      if (a.correct) byType[a.questionType].correct++;
    }

    const subjectPerformance = Object.entries(byType).map(([type, data]) => ({
      subject: this._typeLabel(type),
      correct: data.correct,
      total: data.total,
      percentage: Math.round((data.correct / data.total) * 100)
    }));

    const avgBiologistTime = this.roleActivity.biologist.answersGiven > 0
      ? Math.round(this.roleActivity.biologist.totalTime / this.roleActivity.biologist.answersGiven)
      : 0;

    const score = this.calculateScore(missionsCompleted);

    return {
      sessionId: this.sessionId,
      date: new Date().toLocaleDateString("tr-TR"),
      time: new Date().toLocaleTimeString("tr-TR"),
      totalPlayTime: `${Math.floor(totalTime / 60)} dk ${totalTime % 60} sn`,
      missionsCompleted,
      players: sessionData.players,

      performance: {
        overallAccuracy: accuracy,
        totalQuestions: totalAnswers,
        correctAnswers,
        score,
        subjectPerformance
      },

      teamwork: {
        captainDecisionAccuracy:
          this.roleActivity.captain.decisions > 0
            ? Math.round(
                (this.roleActivity.captain.correctDecisions /
                  this.roleActivity.captain.decisions) *
                  100
              )
            : 0,
        scoutEfficiency: this._calculateScoutEfficiency(),
        avgBiologistResponseTime: `${avgBiologistTime} sn`
      },

      events: this.events.slice(-20), // Son 20 olay
      generatedAt: new Date().toISOString(),

      teacherNotes: this._generateTeacherNotes(accuracy, subjectPerformance)
    };
  }

  _typeLabel(type) {
    const labels = {
      math: "Matematik",
      biology: "Biyoloji",
      reading: "Okuma Anlama",
      decision: "Problem Çözme"
    };
    return labels[type] || type;
  }

  _calculateScoutEfficiency() {
    const allScans = [
      ...this.roleActivity.scout1.scanTime,
      ...this.roleActivity.scout2.scanTime
    ];
    if (allScans.length === 0) return 100;
    const avg = allScans.reduce((a, b) => a + b, 0) / allScans.length;
    if (avg < 10) return 95;
    if (avg < 20) return 80;
    if (avg < 30) return 65;
    return 50;
  }

  _generateTeacherNotes(accuracy, subjectPerformance) {
    const notes = [];

    if (accuracy >= 90) {
      notes.push("🌟 Takım mükemmel bir performans sergiledi! Tüm konularda üst düzey başarı.");
    } else if (accuracy >= 70) {
      notes.push("✅ Takım genel olarak başarılı. Birkaç konuda ek pratik önerilir.");
    } else {
      notes.push("📚 Grup bazı konularda daha fazla desteğe ihtiyaç duyabilir.");
    }

    const weakSubjects = subjectPerformance.filter((s) => s.percentage < 60);
    if (weakSubjects.length > 0) {
      notes.push(
        `⚠️ Geliştirilmesi önerilen konular: ${weakSubjects.map((s) => s.subject).join(", ")}`
      );
    }

    notes.push("💡 İşbirliği ve iletişim becerileri oyun boyunca aktif olarak kullanıldı.");

    return notes;
  }
}

module.exports = { ReportService };
