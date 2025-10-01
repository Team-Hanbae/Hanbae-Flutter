enum Sound {
  janggu1,
  janggu2,
  buk1,
  buk2,
  clave,
}

extension SoundLabel on Sound {
  String get label {
    switch (this) {
      case Sound.janggu1:
        return '장구1';
      case Sound.buk1:
        return '북1';
      case Sound.janggu2:
        return '장구2';
      case Sound.buk2:
        return '북2';
      case Sound.clave:
        return '나무';
    }
  }
}