/// GLB model yolları — `3dmodelbalik/` klasöründeki animasyonlu balıklar.
class FishModelAssets {
  FishModelAssets._();

  static const String balik1 = '3dmodelbalik/1.balik/textured.glb';
  static const String balik2 = '3dmodelbalik/2.balik/textured.glb';

  static const Map<String, String> byFishId = {
    'clownfish': balik1,
    'angelfish': balik2,
  };

  static String? pathFor(String fishId) => byFishId[fishId];

  static bool hasModel(String fishId) => byFishId.containsKey(fishId);
}
