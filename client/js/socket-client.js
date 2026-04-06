// ============================================================
//  client/js/socket-client.js
//  Socket.io Bağlantı Yöneticisi
// ============================================================

class SocketClient {
  constructor() {
    this.socket = null;
    this.connected = false;
    this.sessionId = null;
    this.role = null;
    this.listeners = new Map();
    this._retryCount = 0;
    this._maxRetries = 5;
  }

  connect(serverUrl) {
    return new Promise((resolve, reject) => {
      try {
        this.socket = io(serverUrl || window.location.origin, {
          transports: ["websocket", "polling"],
          reconnection: true,
          reconnectionAttempts: this._maxRetries,
          reconnectionDelay: 2000,
          timeout: 10000
        });

        this.socket.on("connect", () => {
          this.connected = true;
          this._retryCount = 0;
          console.log("[Socket] Bağlandı:", this.socket.id);
          this._emit("connect", { socketId: this.socket.id });
          resolve(this.socket.id);
        });

        this.socket.on("disconnect", (reason) => {
          this.connected = false;
          console.warn("[Socket] Bağlantı kesildi:", reason);
          this._emit("disconnect", { reason });
        });

        this.socket.on("connect_error", (err) => {
          console.error("[Socket] Bağlantı hatası:", err.message);
          this._emit("connection-error", { error: err.message });
          reject(err);
        });

        this.socket.on("reconnect", (attempt) => {
          this.connected = true;
          console.log("[Socket] Yeniden bağlandı, deneme:", attempt);
          this._emit("reconnect", { attempt });
          // Oturuma yeniden katıl
          if (this.sessionId && this.role) {
            this.joinSession(this.sessionId, this.role, window.PLAYER_NAME || this.role);
          }
        });

        // Sunucu olaylarını yönlendir
        this._forwardEvents([
          "session-joined",
          "error",
          "game:state-changed",
          "game:player-joined",
          "game:player-left",
          "game:report-ready",
          "mission:captain-briefing",
          "mission:scout-instruction",
          "mission:biologist-standby",
          "mission:question",
          "mission:captain-alert",
          "mission:answer-result",
          "mission:timer",
          "mission:timeout",
          "game:marker-detected"
        ]);

      } catch (err) {
        reject(err);
      }
    });
  }

  _forwardEvents(events) {
    for (const event of events) {
      this.socket.on(event, (data) => {
        console.log(`[Socket] ← ${event}`, data);
        this._emit(event, data);
      });
    }
  }

  // ── Oyun Komutları ──────────────────────────────────────────

  joinSession(sessionId, role, playerName) {
    this.sessionId = sessionId;
    this.role = role;
    this._send("join-session", { sessionId, role, playerName });
  }

  startMission() {
    this._send("start-mission");
  }

  markerDetected(markerType) {
    this._send("marker-detected", { markerType });
  }

  submitAnswer(questionId, answer) {
    this._send("submit-answer", { questionId, answer });
  }

  nextMission() {
    this._send("next-mission");
  }

  requestReport() {
    this._send("request-report");
  }

  // ── İç Yardımcılar ─────────────────────────────────────────

  _send(event, data = {}) {
    if (!this.socket || !this.connected) {
      console.warn("[Socket] Gönderilemedi (bağlantı yok):", event);
      return;
    }
    console.log(`[Socket] → ${event}`, data);
    this.socket.emit(event, data);
  }

  // ── Olay Dinleyici Sistemi ──────────────────────────────────

  on(event, handler) {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, []);
    }
    this.listeners.get(event).push(handler);
    return this; // zincir
  }

  off(event, handler) {
    if (!this.listeners.has(event)) return;
    if (!handler) {
      this.listeners.delete(event);
    } else {
      const arr = this.listeners.get(event).filter((h) => h !== handler);
      this.listeners.set(event, arr);
    }
    return this;
  }

  _emit(event, data) {
    const handlers = this.listeners.get(event) || [];
    for (const h of handlers) {
      try { h(data); }
      catch (e) { console.error(`[Socket] Handler hatası (${event}):`, e); }
    }
  }

  get socketId() { return this.socket?.id || null; }
}

// Tekil örnek
window.socketClient = new SocketClient();
