// ============================================================
//  server/server.js
//  Ana Sunucu — Express + Socket.io + QR Kod
// ============================================================

const express = require("express");
const http = require("http");
const { Server } = require("socket.io");
const path = require("path");
const QRCode = require("qrcode");
const os = require("os");

const { GameEngine, ROLES } = require("./gameEngine");
const { MissionGenerator } = require("./missionGenerator");
const { ReportService } = require("./reportService");

// ── Uygulama Kurulumu ─────────────────────────────────────────
const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: "*" },
  transports: ["websocket", "polling"]
});

const PORT = process.env.PORT || 3000;

// ── Statik Dosyalar ───────────────────────────────────────────
app.use(express.static(path.join(__dirname, "../client")));
app.use(express.json());

// ── Oturum (Session) Yönetimi ─────────────────────────────────
// sessions: { sessionId: { engine, missionGen } }
const sessions = new Map();

function generateSessionId() {
  return Math.random().toString(36).substring(2, 8).toUpperCase();
}

function getOrCreateSession(sessionId) {
  if (!sessions.has(sessionId)) {
    const report = new ReportService(sessionId);
    const engine = new GameEngine(sessionId, io, report);
    const missionGen = new MissionGenerator();
    sessions.set(sessionId, { engine, missionGen });
    console.log(`[Server] Yeni oturum oluşturuldu: ${sessionId}`);
  }
  return sessions.get(sessionId);
}

// ── REST API ──────────────────────────────────────────────────

/** Yeni oturum oluştur + QR kodu döndür */
app.post("/api/session/create", async (req, res) => {
  const sessionId = generateSessionId();
  getOrCreateSession(sessionId);

  const localIP = getLocalIP();
  const sessionUrl = `http://${localIP}:${PORT}/?session=${sessionId}`;
  const qrDataUrl = await QRCode.toDataURL(sessionUrl, { width: 300, margin: 2 });

  console.log(`[Server] Oturum URL: ${sessionUrl}`);

  res.json({ sessionId, sessionUrl, qrDataUrl });
});

/** Oturum durumu sorgula */
app.get("/api/session/:sessionId", (req, res) => {
  const sessionId = req.params.sessionId.toUpperCase();
  if (!sessions.has(sessionId)) {
    return res.status(404).json({ error: "Oturum bulunamadı." });
  }
  const { engine } = sessions.get(sessionId);
  res.json(engine.getSnapshot());
});

/** Mevcut tüm oturumları listele (admin/debug) */
app.get("/api/sessions", (req, res) => {
  const list = [];
  for (const [id, { engine }] of sessions) {
    list.push(engine.getSnapshot());
  }
  res.json(list);
});

// ── Socket.io Olayları ─────────────────────────────────────────
io.on("connection", (socket) => {
  console.log(`[Socket] Bağlantı: ${socket.id}`);
  let currentSessionId = null;
  let currentRole = null;

  // ─── Oturuma katıl ──────────────────────────────────────────
  socket.on("join-session", ({ sessionId, role, playerName }) => {
    const sid = (sessionId || "").toUpperCase();
    if (!sid) return socket.emit("error", { message: "Oturum ID gerekli." });
    if (!role) return socket.emit("error", { message: "Rol seçimi gerekli." });

    const { engine } = getOrCreateSession(sid);

    const result = engine.addPlayer(role, socket.id, playerName || role);
    if (!result.success) {
      return socket.emit("error", { message: result.error });
    }

    currentSessionId = sid;
    currentRole = role;
    socket.join(sid);

    socket.emit("session-joined", {
      sessionId: sid,
      role,
      roleLabel: result.roleLabel,
      snapshot: engine.getSnapshot()
    });

    console.log(`[Session ${sid}] ${result.roleLabel}: ${playerName}`);
  });

  // ─── Görev başlat (Kaptan, Öğretmen) ───────────────────────
  socket.on("start-mission", () => {
    if (!currentSessionId) return;
    const { engine, missionGen } = sessions.get(currentSessionId) || {};
    if (!engine) return;

    if (currentRole !== ROLES.CAPTAIN && currentRole !== ROLES.TEACHER) {
      return socket.emit("error", { message: "Sadece Kaptan veya Öğretmen görev başlatabilir." });
    }

    const mission = missionGen.getNextMission();
    const result = engine.startMission(mission);
    if (!result.success) {
      socket.emit("error", { message: result.error });
    }
  });

  // ─── Marker tespit edildi (Gözcü) ───────────────────────────
  socket.on("marker-detected", ({ markerType }) => {
    if (!currentSessionId || !currentRole) return;
    const { engine } = sessions.get(currentSessionId) || {};
    if (!engine) return;

    engine.onMarkerDetected(markerType, currentRole);
  });

  // ─── Cevap gönderildi (Biyolog) ─────────────────────────────
  socket.on("submit-answer", ({ questionId, answer }) => {
    if (!currentSessionId || !currentRole) return;
    const { engine } = sessions.get(currentSessionId) || {};
    if (!engine) return;

    if (currentRole !== ROLES.BIOLOGIST) {
      return socket.emit("error", { message: "Sadece Biyolog cevap gönderebilir." });
    }

    engine.onAnswerSubmitted(questionId, answer, currentRole);
  });

  // ─── Sonraki göreve geç (Kaptan) ────────────────────────────
  socket.on("next-mission", () => {
    if (!currentSessionId) return;
    const { engine } = sessions.get(currentSessionId) || {};
    if (!engine) return;

    if (currentRole !== ROLES.CAPTAIN && currentRole !== ROLES.TEACHER) return;
    engine.resetForNextMission();
  });

  // ─── Rapor iste (Öğretmen) ──────────────────────────────────
  socket.on("request-report", () => {
    if (!currentSessionId) return;
    const { engine } = sessions.get(currentSessionId) || {};
    if (!engine) return;

    const snapshot = engine.getSnapshot();
    socket.emit("game:report-ready", { report: engine.report.generateReport(
      { players: snapshot.players },
      snapshot.missionsCompleted
    )});
  });

  // ─── Bağlantı kesildi ───────────────────────────────────────
  socket.on("disconnect", () => {
    console.log(`[Socket] Bağlantı kesildi: ${socket.id}`);
    if (currentSessionId && sessions.has(currentSessionId)) {
      const { engine } = sessions.get(currentSessionId);
      engine.removePlayer(socket.id);
    }
  });
});

// ── Yardımcı ─────────────────────────────────────────────────
function getLocalIP() {
  const interfaces = os.networkInterfaces();
  for (const iface of Object.values(interfaces)) {
    for (const alias of iface) {
      if (alias.family === "IPv4" && !alias.internal) {
        return alias.address;
      }
    }
  }
  return "localhost";
}

// ── Sunucuyu Başlat ──────────────────────────────────────────
server.listen(PORT, "0.0.0.0", () => {
  const ip = getLocalIP();
  console.log("");
  console.log("🌊 ================================================== 🌊");
  console.log("   Derin Denizaltı Mürettebatı — AR Sunucu Aktif!");
  console.log("🌊 ================================================== 🌊");
  console.log(`🖥️  Yerel:    http://localhost:${PORT}`);
  console.log(`📡 Ağ:      http://${ip}:${PORT}`);
  console.log(`📱 Lobi:    http://${ip}:${PORT}/?session=<ID>`);
  console.log(`🔧 Admin:   http://${ip}:${PORT}/api/sessions`);
  console.log("");
  console.log("💡 Tablet'ten bağlanmak için yukarıdaki 📡 Ağ adresini kullanın.");
  console.log("🔐 Not: Kamera için HTTPS gerekir. ngrok veya mkcert kullanın.");
  console.log("🌊 ================================================== 🌊");
  console.log("");
});

module.exports = { app, server };
