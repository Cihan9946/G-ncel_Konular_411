// ============================================================
//  client/js/ui-manager.js
//  UI Animasyon ve Geçiş Yöneticisi
// ============================================================

const UIManager = (() => {
  // ── Toast Bildirimleri ──────────────────────────────────────

  let _toastContainer = null;

  function _getToastContainer() {
    if (!_toastContainer) {
      _toastContainer = document.createElement("div");
      _toastContainer.className = "toast-container";
      document.body.appendChild(_toastContainer);
    }
    return _toastContainer;
  }

  function toast(message, type = "info", duration = 3500) {
    const container = _getToastContainer();
    const el = document.createElement("div");
    el.className = `toast toast-${type}`;

    const icons = { info: "ℹ️", success: "✅", error: "❌", warning: "⚠️" };
    el.innerHTML = `<span>${icons[type] || "ℹ️"}</span><span>${message}</span>`;

    container.appendChild(el);

    const remove = () => {
      el.classList.add("toast-exit");
      el.addEventListener("animationend", () => el.remove(), { once: true });
    };

    setTimeout(remove, duration);
    el.addEventListener("click", remove);
    return remove;
  }

  // ── Yükleme Ekranı ─────────────────────────────────────────

  function showLoading(text = "Bağlanıyor...") {
    let screen = document.getElementById("loading-screen");
    if (!screen) {
      screen = document.createElement("div");
      screen.id = "loading-screen";
      screen.className = "loading-screen";
      screen.innerHTML = `
        <div class="loading-spinner"></div>
        <p id="loading-text" style="font-family:var(--font-mono);font-size:14px;
           color:var(--cyan-glow);letter-spacing:2px;text-transform:uppercase">${text}</p>
      `;
      document.body.appendChild(screen);
    } else {
      document.getElementById("loading-text").textContent = text;
      screen.classList.remove("hidden");
    }
  }

  function hideLoading() {
    const screen = document.getElementById("loading-screen");
    if (screen) {
      screen.style.opacity = "0";
      screen.style.transition = "opacity 400ms";
      setTimeout(() => screen.classList.add("hidden"), 420);
    }
  }

  // ── Animasyon Yardımcıları ──────────────────────────────────

  function fadeIn(el, duration = 300) {
    if (!el) return;
    el.style.opacity = "0";
    el.style.transition = `opacity ${duration}ms`;
    el.classList.remove("hidden");
    requestAnimationFrame(() => {
      requestAnimationFrame(() => { el.style.opacity = "1"; });
    });
  }

  function fadeOut(el, duration = 300, remove = false) {
    if (!el) return;
    el.style.opacity = "0";
    el.style.transition = `opacity ${duration}ms`;
    setTimeout(() => {
      if (remove) el.remove();
      else el.classList.add("hidden");
    }, duration);
  }

  function slideUp(el, duration = 400) {
    if (!el) return;
    el.style.animation = `slide-up ${duration}ms cubic-bezier(0.16,1,0.3,1) forwards`;
    el.classList.remove("hidden");
  }

  function pulseEl(el, color = "var(--cyan-glow)") {
    if (!el) return;
    const orig = el.style.boxShadow;
    el.style.transition = "box-shadow 300ms";
    el.style.boxShadow = `0 0 0 4px ${color}44, 0 0 20px ${color}`;
    setTimeout(() => { el.style.boxShadow = orig; }, 600);
  }

  // ── Ekran Paneli Yönetimi ───────────────────────────────────

  function showPanel(panelId) {
    document.querySelectorAll("[data-panel]").forEach((p) => {
      if (p.dataset.panel === panelId) {
        p.classList.remove("hidden");
        slideUp(p);
      } else {
        p.classList.add("hidden");
      }
    });
  }

  // ── Sayaç ──────────────────────────────────────────────────

  function createCountdown(el, total, onTick, onDone) {
    let remaining = total;
    const interval = setInterval(() => {
      remaining--;
      if (el) {
        el.textContent = remaining;
        // Son 10 saniyede kırmızı
        if (remaining <= 10) el.style.color = "var(--danger-red)";
        if (remaining <= 5) el.style.animation = "blink 0.5s infinite";
      }
      if (onTick) onTick(remaining);
      if (remaining <= 0) {
        clearInterval(interval);
        if (el) el.style.animation = "";
        if (onDone) onDone();
      }
    }, 1000);
    return () => clearInterval(interval);
  }

  // ── Doğru/Yanlış Efekti ────────────────────────────────────

  function correctEffect() {
    _flashBackground("#22c55e22");
    AudioManager?.play("correct");
  }

  function wrongEffect() {
    _flashBackground("#ef444422");
    AudioManager?.play("wrong");
  }

  function _flashBackground(color) {
    const flash = document.createElement("div");
    flash.style.cssText = `position:fixed;inset:0;background:${color};z-index:9000;
      pointer-events:none;transition:opacity 400ms;`;
    document.body.appendChild(flash);
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        flash.style.opacity = "0";
        setTimeout(() => flash.remove(), 450);
      });
    });
  }

  // ── Oyuncu Listesi Render ──────────────────────────────────

  function renderPlayerList(containerId, players) {
    const el = document.getElementById(containerId);
    if (!el) return;

    const roleColors = {
      captain: "var(--captain-gold)",
      scout1: "var(--scout-cyan)",
      scout2: "var(--scout-cyan)",
      biologist: "var(--bio-green)",
      teacher: "var(--teacher-purple)"
    };

    el.innerHTML = players.map((p) => `
      <div style="display:flex;align-items:center;gap:8px;padding:8px 12px;
        border-radius:8px;background:rgba(255,255,255,0.04);
        border:1px solid rgba(255,255,255,0.06);">
        <div style="width:8px;height:8px;border-radius:50%;
          background:${p.connected ? "#22c55e" : "#ef4444"};
          box-shadow:0 0 6px ${p.connected ? "#22c55e" : "#ef4444"}"></div>
        <span style="color:${roleColors[p.role] || "#fff"};font-weight:700;font-size:12px">
          ${p.roleLabel}</span>
        <span style="color:rgba(255,255,255,0.6);font-size:13px">${p.name}</span>
      </div>
    `).join("");
  }

  // ── Puan Animasyonu ────────────────────────────────────────

  function animateScore(el, from, to, duration = 800) {
    if (!el) return;
    const startTime = performance.now();
    const range = to - from;

    function update(now) {
      const t = Math.min((now - startTime) / duration, 1);
      const eased = 1 - Math.pow(1 - t, 3);
      el.textContent = Math.round(from + range * eased);
      if (t < 1) requestAnimationFrame(update);
    }

    requestAnimationFrame(update);
  }

  return {
    toast, showLoading, hideLoading,
    fadeIn, fadeOut, slideUp, pulseEl,
    showPanel, createCountdown,
    correctEffect, wrongEffect,
    renderPlayerList, animateScore
  };
})();

window.UIManager = UIManager;
