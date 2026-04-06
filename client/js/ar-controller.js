// ============================================================
//  client/js/ar-controller.js
//  AR.js Marker Tespit Kontrolcüsü
// ============================================================

const ARController = (() => {
  let _initialized = false;
  let _detectedMarkers = new Set();
  let _cooldowns = new Map(); // marker -> timestamp
  const COOLDOWN_MS = 3000; // Aynı marker için min bekleme süresi

  // Marker tipi haritalama
  const MARKER_MAP = {
    hiro: "blue",
    kanji: "yellow",
    "barcode-0": "red",
    "barcode-1": "green"
  };

  const MARKER_LABELS = {
    blue: "🔵 Keşif Noktası",
    yellow: "🟡 Yakıt Deposu",
    red: "🔴 Tehlike Bölgesi",
    green: "🟢 Güvenli Liman"
  };

  let _onMarkerDetected = null;
  let _onMarkerLost = null;

  function init({ onDetected, onLost }) {
    if (_initialized) return;

    _onMarkerDetected = onDetected;
    _onMarkerLost = onLost;

    // A-Frame sahnesi yüklendikten sonra marker eventlerini bağla
    const scene = document.querySelector("a-scene");
    if (!scene) {
      console.error("[AR] a-scene bulunamadı!");
      return;
    }

    scene.addEventListener("loaded", () => {
      _bindMarkerEvents();
      _initialized = true;
      console.log("[AR] AR Kontrolcüsü hazır.");
    });

    // Eğer sahne zaten yüklüyse
    if (scene.hasLoaded) {
      _bindMarkerEvents();
      _initialized = true;
    }
  }

  function _bindMarkerEvents() {
    // Tüm a-marker elementlerine event listener ekle
    document.querySelectorAll("a-marker").forEach((marker) => {
      const preset = marker.getAttribute("preset");
      const value = marker.getAttribute("value");
      const markerId = preset || `barcode-${value}`;
      const markerType = MARKER_MAP[markerId] || "unknown";

      marker.addEventListener("markerFound", () => {
        _handleMarkerFound(markerId, markerType, marker);
      });

      marker.addEventListener("markerLost", () => {
        _handleMarkerLost(markerId, markerType);
      });
    });
  }

  function _handleMarkerFound(markerId, markerType, markerEl) {
    const now = Date.now();
    const lastDetect = _cooldowns.get(markerId) || 0;

    // Cooldown kontrolü
    if (now - lastDetect < COOLDOWN_MS) return;

    _cooldowns.set(markerId, now);
    _detectedMarkers.add(markerId);

    const label = MARKER_LABELS[markerType] || markerType;
    console.log(`[AR] Marker bulundu: ${label} (${markerId})`);

    // AR elementine animasyon ekle
    const entity = markerEl.querySelector("[ar-object]");
    if (entity) {
      entity.setAttribute("animation__found", "property:scale;to:1.2 1.2 1.2;dur:300;easing:easeOutElastic");
    }

    if (_onMarkerDetected) {
      _onMarkerDetected({ markerId, markerType, label, element: markerEl });
    }
  }

  function _handleMarkerLost(markerId, markerType) {
    _detectedMarkers.delete(markerId);
    console.log(`[AR] Marker kayboldu: ${markerId}`);

    if (_onMarkerLost) {
      _onMarkerLost({ markerId, markerType });
    }
  }

  // El ile marker tetikle (test modu)
  function simulateMarker(markerType) {
    const markerId = Object.entries(MARKER_MAP).find(([, t]) => t === markerType)?.[0];
    if (!markerId) return;
    const label = MARKER_LABELS[markerType] || markerType;
    if (_onMarkerDetected) {
      _onMarkerDetected({ markerId, markerType, label, simulated: true });
    }
  }

  function isDetected(markerId) { return _detectedMarkers.has(markerId); }
  function reset() { _detectedMarkers.clear(); _cooldowns.clear(); }

  return { init, simulateMarker, isDetected, reset, MARKER_MAP, MARKER_LABELS };
})();

window.ARController = ARController;
