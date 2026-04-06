// ============================================================
//  server/gameEngine.js
//  Finite State Machine — Oyun Durum Makinesi
// ============================================================

const STATES = {
  IDLE: "IDLE",
  LOBBY: "LOBBY",
  BRIEFING: "BRIEFING",
  EXPLORATION: "EXPLORATION",
  QUIZ: "QUIZ",
  CRISIS: "CRISIS",
  RESOLUTION: "RESOLUTION",
  COMPLETE: "COMPLETE"
};

const ROLES = {
  CAPTAIN: "captain",
  SCOUT1: "scout1",
  SCOUT2: "scout2",
  BIOLOGIST: "biologist",
  TEACHER: "teacher"
};

const ROLE_LABELS = {
  captain: "🎯 Kaptan",
  scout1: "🔭 Gözcü 1",
  scout2: "🔭 Gözcü 2",
  biologist: "🔬 Biyolog",
  teacher: "📊 Öğretmen"
};

const MAX_MISSIONS = 3;

class GameEngine {
  constructor(sessionId, io, reportService) {
    this.sessionId = sessionId;
    this.io = io;
    this.report = reportService;

    this.state = STATES.IDLE;
    this.players = {}; // { role: { socketId, name, connected } }
    this.currentMission = null;
    this.score = 0;
    this.missionsCompleted = 0;
    this.questionStartTime = null;
    this.markerScanStartTime = null;
    this.missionTimer = null;
  }

  // ── Durum Yönetimi ──────────────────────────────────────────

  transition(newState, data = {}) {
    const prevState = this.state;
    this.state = newState;
    console.log(`[Session ${this.sessionId}] State: ${prevState} → ${newState}`);

    this.report.logEvent("STATE_CHANGE", { from: prevState, to: newState });
    this.broadcast("game:state-changed", { state: newState, prevState, data });
  }

  broadcast(event, data) {
    this.io.to(this.sessionId).emit(event, data);
  }

  emitToRole(role, event, data) {
    const player = this.players[role];
    if (player && player.socketId) {
      this.io.to(player.socketId).emit(event, data);
    }
  }

  // ── Oyuncu Yönetimi ─────────────────────────────────────────

  addPlayer(role, socketId, name) {
    if (!Object.values(ROLES).includes(role)) {
      return { success: false, error: "Geçersiz rol." };
    }

    if (this.players[role] && this.players[role].socketId !== socketId) {
      return { success: false, error: `${ROLE_LABELS[role]} rolü zaten dolu.` };
    }

    this.players[role] = { socketId, name, connected: true, joinedAt: Date.now() };

    this.report.logEvent("PLAYER_JOINED", { role, name });

    if (this.state === STATES.IDLE) {
      this.transition(STATES.LOBBY);
    }

    this.broadcast("game:player-joined", {
      role,
      roleLabel: ROLE_LABELS[role],
      name,
      players: this.getPlayerList()
    });

    return { success: true, role, roleLabel: ROLE_LABELS[role] };
  }

  removePlayer(socketId) {
    for (const [role, player] of Object.entries(this.players)) {
      if (player.socketId === socketId) {
        player.connected = false;
        this.report.logEvent("PLAYER_LEFT", { role, name: player.name });
        this.broadcast("game:player-left", {
          role,
          roleLabel: ROLE_LABELS[role],
          name: player.name,
          players: this.getPlayerList()
        });
        return role;
      }
    }
    return null;
  }

  getPlayerList() {
    return Object.entries(this.players).map(([role, p]) => ({
      role,
      roleLabel: ROLE_LABELS[role],
      name: p.name,
      connected: p.connected
    }));
  }

  getConnectedCount() {
    return Object.values(this.players).filter((p) => p.connected).length;
  }

  // ── Oyun Akışı ──────────────────────────────────────────────

  startMission(mission) {
    if (this.state !== STATES.LOBBY && this.state !== STATES.RESOLUTION) {
      return { success: false, error: "Şu an görev başlatılamaz." };
    }

    this.currentMission = mission;
    this.markerScanStartTime = null;
    this.questionStartTime = null;

    this.transition(STATES.BRIEFING, { mission });

    // Rolle özel briefing gönder
    this.emitToRole(ROLES.CAPTAIN, "mission:captain-briefing", {
      mission: {
        title: mission.title,
        storyText: mission.storyText,
        captainBriefing: mission.captainBriefing
      }
    });

    this.emitToRole(ROLES.SCOUT1, "mission:scout-instruction", {
      instruction: mission.scoutInstruction,
      targetMarker: mission.markerType
    });

    this.emitToRole(ROLES.SCOUT2, "mission:scout-instruction", {
      instruction: mission.scoutInstruction,
      targetMarker: mission.markerType
    });

    this.emitToRole(ROLES.BIOLOGIST, "mission:biologist-standby", {
      message: "Gözcünün marker bulmasını bekliyorsun... Hazır ol!"
    });

    // 5 saniye sonra keşif moduna geç
    setTimeout(() => {
      if (this.state === STATES.BRIEFING) {
        this.transition(STATES.EXPLORATION);
        this._startMissionTimer(mission.duration);
      }
    }, 5000);

    return { success: true };
  }

  onMarkerDetected(markerType, role) {
    if (this.state !== STATES.EXPLORATION) return;
    if (!this.currentMission) return;

    const scanDuration = this.markerScanStartTime
      ? Math.round((Date.now() - this.markerScanStartTime) / 1000)
      : 0;

    this.report.logMarkerScan({ marker: markerType, role, scanDuration });

    const isCorrectMarker = markerType === this.currentMission.markerType;

    this.broadcast("game:marker-detected", {
      markerType,
      role,
      roleLabel: ROLE_LABELS[role] || role,
      isCorrectMarker,
      arContent: isCorrectMarker ? this.currentMission.arContent : null
    });

    if (isCorrectMarker) {
      this._clearMissionTimer();
      this.transition(STATES.QUIZ);
      this.questionStartTime = Date.now();

      // Biyologa soruyu gönder
      const challenge = this.currentMission.biologyChallenge;
      this.emitToRole(ROLES.BIOLOGIST, "mission:question", {
        questionId: this.currentMission.id,
        type: challenge.type,
        question: challenge.question,
        passage: challenge.passage || null,
        choices: challenge.choices,
        funFact: challenge.funFact || null,
        timeLimit: 60
      });

      // Kaptan bilgilendir
      this.emitToRole(ROLES.CAPTAIN, "mission:captain-alert", {
        message: "🔥 Marker bulundu! Biyolog soruyu yanıtlıyor...",
        awaitingAnswer: true
      });
    }
  }

  onAnswerSubmitted(questionId, answer, role) {
    if (this.state !== STATES.QUIZ) return { success: false };
    if (!this.currentMission) return { success: false };

    const timeSpent = this.questionStartTime
      ? Math.round((Date.now() - this.questionStartTime) / 1000)
      : 0;

    const challenge = this.currentMission.biologyChallenge;
    const correct = answer === challenge.correctAnswer;
    const pointsEarned = correct ? challenge.points : Math.round(challenge.points * 0.2);

    this.score += pointsEarned;
    this.report.logAnswer({
      questionId,
      questionType: challenge.type,
      correct,
      timeSpent,
      role
    });

    // Tüm oyunculara sonucu bildir
    this.broadcast("mission:answer-result", {
      correct,
      answer,
      correctAnswer: challenge.correctAnswer,
      explanation: challenge.explanation,
      funFact: challenge.funFact || null,
      pointsEarned,
      totalScore: this.score,
      timeSpent
    });

    this.missionsCompleted++;
    this.transition(STATES.RESOLUTION, {
      correct,
      successMessage: correct ? this.currentMission.successMessage : "😔 Yanlış cevap ama deneyim kazandık!",
      score: this.score,
      missionsCompleted: this.missionsCompleted
    });

    if (this.missionsCompleted >= MAX_MISSIONS) {
      setTimeout(() => this._endGame(), 4000);
    }

    return { success: true, correct, pointsEarned };
  }

  onMissionTimeout() {
    if (this.state !== STATES.EXPLORATION) return;
    this.broadcast("mission:timeout", { message: "⏰ Süre doldu! Marker bulunamadı." });
    this.transition(STATES.RESOLUTION, { timeout: true, score: this.score });
    this.missionsCompleted++;
    if (this.missionsCompleted >= MAX_MISSIONS) {
      setTimeout(() => this._endGame(), 3000);
    }
  }

  resetForNextMission() {
    if (this.state !== STATES.RESOLUTION) return { success: false };
    this.currentMission = null;
    this.transition(STATES.LOBBY);
    return { success: true };
  }

  _startMissionTimer(seconds) {
    this.markerScanStartTime = Date.now();
    let remaining = seconds;

    this._clearMissionTimer();
    this.missionTimer = setInterval(() => {
      remaining--;
      this.broadcast("mission:timer", { remaining, total: seconds });

      if (remaining <= 0) {
        this._clearMissionTimer();
        this.onMissionTimeout();
      }
    }, 1000);
  }

  _clearMissionTimer() {
    if (this.missionTimer) {
      clearInterval(this.missionTimer);
      this.missionTimer = null;
    }
  }

  _endGame() {
    this._clearMissionTimer();
    const report = this.report.generateReport(
      { players: this.getPlayerList() },
      this.missionsCompleted
    );
    this.transition(STATES.COMPLETE, { score: this.score, report });
    this.emitToRole(ROLES.TEACHER, "game:report-ready", { report });
  }

  getSnapshot() {
    return {
      sessionId: this.sessionId,
      state: this.state,
      score: this.score,
      missionsCompleted: this.missionsCompleted,
      players: this.getPlayerList(),
      currentMission: this.currentMission
        ? { title: this.currentMission.title, markerType: this.currentMission.markerType }
        : null
    };
  }
}

module.exports = { GameEngine, STATES, ROLES, ROLE_LABELS };
