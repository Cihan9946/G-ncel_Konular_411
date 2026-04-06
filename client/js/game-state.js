// ============================================================
//  client/js/game-state.js
//  İstemci taraflı durum yönetimi
// ============================================================

const GameState = (() => {
  let _state = {
    sessionId: null,
    role: null,
    roleLabel: null,
    playerName: null,
    gameState: "IDLE",
    score: 0,
    missionsCompleted: 0,
    players: [],
    currentMission: null,
    currentQuestion: null,
    timerRemaining: null
  };

  const _listeners = new Map();

  function get(key) { return key ? _state[key] : { ..._state }; }

  function set(updates) {
    const prev = { ..._state };
    Object.assign(_state, updates);
    for (const [key, handlers] of _listeners) {
      if (key === "*" || updates[key] !== undefined) {
        for (const h of handlers) {
          try { h(_state[key], prev[key]); }
          catch (e) { console.error("[GameState] Handler hatası:", e); }
        }
      }
    }
  }

  function watch(key, handler) {
    if (!_listeners.has(key)) _listeners.set(key, []);
    _listeners.get(key).push(handler);
  }

  function reset() {
    set({
      gameState: "IDLE",
      score: 0,
      missionsCompleted: 0,
      players: [],
      currentMission: null,
      currentQuestion: null,
      timerRemaining: null
    });
  }

  // URL parametrelerinden session ve rol çek
  function initFromURL() {
    const params = new URLSearchParams(window.location.search);
    const sessionId = params.get("session")?.toUpperCase();
    const role = params.get("role");
    const name = params.get("name") || params.get("playerName");
    if (sessionId) set({ sessionId });
    if (role) set({ role });
    if (name) set({ playerName: name });
    return { sessionId, role, playerName: name };
  }

  return { get, set, watch, reset, initFromURL };
})();

window.GameState = GameState;
