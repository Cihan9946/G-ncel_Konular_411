// ============================================================
//  client/js/audio-manager.js
//  Ses Efektleri — Web Audio API ile çalışır (kurulum yok)
// ============================================================

const AudioManager = (() => {
  let _ctx = null;
  let _enabled = true;
  let _volume = 0.6;

  function _getCtx() {
    if (!_ctx) {
      _ctx = new (window.AudioContext || window.webkitAudioContext)();
    }
    return _ctx;
  }

  function _resume() {
    const ctx = _getCtx();
    if (ctx.state === "suspended") ctx.resume();
  }

  // ── Temel Ton Üretici ───────────────────────────────────────

  function _beep(freq, type, duration, gain, delay = 0) {
    if (!_enabled) return;
    _resume();
    const ctx = _getCtx();

    const osc = ctx.createOscillator();
    const gainNode = ctx.createGain();
    osc.connect(gainNode);
    gainNode.connect(ctx.destination);

    osc.type = type || "sine";
    osc.frequency.setValueAtTime(freq, ctx.currentTime + delay);

    gainNode.gain.setValueAtTime(0, ctx.currentTime + delay);
    gainNode.gain.linearRampToValueAtTime(gain * _volume, ctx.currentTime + delay + 0.01);
    gainNode.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + delay + duration);

    osc.start(ctx.currentTime + delay);
    osc.stop(ctx.currentTime + delay + duration + 0.05);
  }

  // ── Ses Efektleri ──────────────────────────────────────────

  const _sounds = {
    // Sonar ping
    sonar: () => {
      _beep(1200, "sine", 0.8, 0.4);
      _beep(900, "sine", 0.4, 0.2, 0.3);
    },

    // Alarm bip
    alarm: () => {
      for (let i = 0; i < 3; i++) {
        _beep(880, "square", 0.12, 0.3, i * 0.2);
        _beep(440, "square", 0.12, 0.3, i * 0.2 + 0.14);
      }
    },

    // Acil alarm (kırmızı marker)
    alarm_urgent: () => {
      for (let i = 0; i < 5; i++) {
        _beep(1000, "sawtooth", 0.1, 0.4, i * 0.15);
        _beep(600, "sawtooth", 0.1, 0.4, i * 0.15 + 0.08);
      }
    },

    // Keşif zili (yeşil marker)
    discovery: () => {
      [523, 659, 784, 1047].forEach((f, i) => {
        _beep(f, "sine", 0.3, 0.3, i * 0.1);
      });
    },

    // Baloncuk pop
    bubble: () => {
      _beep(800, "sine", 0.1, 0.2);
      _beep(1200, "sine", 0.05, 0.15, 0.08);
    },

    // Doğru cevap
    correct: () => {
      [523, 659, 784].forEach((f, i) => _beep(f, "sine", 0.25, 0.5, i * 0.12));
      _beep(1047, "sine", 0.5, 0.6, 0.36);
    },

    // Yanlış cevap
    wrong: () => {
      _beep(200, "sawtooth", 0.4, 0.5);
      _beep(150, "sawtooth", 0.3, 0.4, 0.25);
    },

    // Görev tamamlandı
    mission_complete: () => {
      const notes = [523, 659, 784, 1047, 1319];
      notes.forEach((f, i) => _beep(f, "sine", 0.3, 0.7, i * 0.15));
    },

    // Marker tespit
    marker_found: () => {
      _beep(660, "sine", 0.2, 0.5);
      _beep(880, "sine", 0.3, 0.6, 0.15);
    },

    // Geri sayım tıklaması
    tick: () => { _beep(600, "square", 0.05, 0.2); },

    // Son 5 saniye
    tick_urgent: () => { _beep(900, "square", 0.08, 0.4); },

    // UI tıklaması
    click: () => { _beep(400, "sine", 0.08, 0.3); }
  };

  function play(soundName) {
    const fn = _sounds[soundName] || _sounds[soundName.replace(/-/g, "_")];
    if (fn) {
      try { fn(); }
      catch (e) { console.warn("[Audio] Ses çalma hatası:", e); }
    } else {
      console.warn("[Audio] Bilinmeyen ses:", soundName);
    }
  }

  function setEnabled(val) { _enabled = val; }
  function setVolume(val) { _volume = Math.max(0, Math.min(1, val)); }
  function toggle() { _enabled = !_enabled; return _enabled; }

  // Kullanıcı etkileşimi sonrası ses bağlamını hazırla
  document.addEventListener("click", () => { try { _resume(); } catch (e) {} }, { once: true });
  document.addEventListener("touchstart", () => { try { _resume(); } catch (e) {} }, { once: true });

  return { play, setEnabled, setVolume, toggle };
})();

window.AudioManager = AudioManager;
