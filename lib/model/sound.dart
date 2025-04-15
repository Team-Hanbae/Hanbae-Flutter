enum Sound {
  janggu,
  buk,
  clave,
}

extension SoundLabel on Sound {
  String get label {
    switch (this) {
      case Sound.janggu:
        return '장구';
      case Sound.buk:
        return '북';
      case Sound.clave:
        return '나무';
    }
  }
}