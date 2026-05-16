enum CrewRole {
  kaptan,
  gozcu,
  biyolog,
}

extension CrewRoleX on CrewRole {
  String get title {
    switch (this) {
      case CrewRole.kaptan:
        return 'Kaptan';
      case CrewRole.gozcu:
        return 'Gözcü';
      case CrewRole.biyolog:
        return 'Biyolog';
    }
  }

  String get subtitle {
    switch (this) {
      case CrewRole.kaptan:
        return 'Denizaltı Komutanı';
      case CrewRole.gozcu:
        return 'Keşif Uzmanı';
      case CrewRole.biyolog:
        return 'Canlı Bilimci';
    }
  }

  String get emoji {
    switch (this) {
      case CrewRole.kaptan:
        return '⚓';
      case CrewRole.gozcu:
        return '🔭';
      case CrewRole.biyolog:
        return '🔬';
    }
  }

  String get description {
    switch (this) {
      case CrewRole.kaptan:
        return 'Takıma ipucu ver, görevleri yönet ve puanları topla.';
      case CrewRole.gozcu:
        return 'Doğru akvaryum camını bul, işaretçiyi tara ve ekibi yönlendir.';
      case CrewRole.biyolog:
        return 'AR balıklara dokun, bilgi topla ve bulmacaları çöz.';
    }
  }

  List<String> get missions {
    switch (this) {
      case CrewRole.kaptan:
        return [
          'Gözcüye hangi bölgeye gidileceğini söyle',
          'Biyoloğun bulmaca çözmesini onayla',
          'Takım skorunu takip et',
        ];
      case CrewRole.gozcu:
        return [
          'Kaptanın verdiği ipucuna göre camı bul',
          'QR işaretçiyi kamerayla tara',
          'Keşfedilen istasyonu takıma bildir',
        ];
      case CrewRole.biyolog:
        return [
          'AR balığa dokunarak bilgi kartını aç',
          'DNA veya habitat bulmacasını tamamla',
          '3 farklı balık hakkında not al',
        ];
    }
  }
}
