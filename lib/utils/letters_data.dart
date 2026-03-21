/// Central data source for all Letters-mode game content.
/// Mirrors the same structures used by DB-driven number screens.
class LettersData {
  /// All 26 letters in order.
  static const List<String> letters = [
    'a','b','c','d','e','f','g','h','i','j','k','l','m',
    'n','o','p','q','r','s','t','u','v','w','x','y','z',
  ];

  /// Returns the icon asset path for a letter (ba.webp … bz.webp).
  static String iconPath(String letter) =>
      'assets/icons/learn/letters/b$letter.webp';

  /// Returns the sound asset path for a letter (l_a.wav … l_z.wav).
  static String soundPath(String letter) =>
      'assets/sounds/learn/letters/l_$letter.wav';

  /// Object image associated with each letter (for Count / Matching / Train screens).
  /// All images are Twemoji SVG→WebP emoji assets (Apache 2.0 licence).
  static const Map<String, String> letterObjects = {
    'a': 'assets/images/letters/a.webp',  // 🍎 Apple
    'b': 'assets/images/letters/b.webp',  // 🎈 Balloon
    'c': 'assets/images/letters/c.webp',  // 🚗 Car
    'd': 'assets/images/letters/d.webp',  // 🦆 Duck
    'e': 'assets/images/letters/e.webp',  // 🥚 Egg
    'f': 'assets/images/letters/f.webp',  // 🐠 Fish
    'g': 'assets/images/letters/g.webp',  // 🍇 Grapes
    'h': 'assets/images/letters/h.webp',  // 🎩 Hat
    'i': 'assets/images/letters/i.webp',  // 🍦 Ice cream
    'j': 'assets/images/letters/j.webp',  // 🫙 Jar
    'k': 'assets/images/letters/k.webp',  // 🪁 Kite
    'l': 'assets/images/letters/l.webp',  // 🍋 Lemon
    'm': 'assets/images/letters/m.webp',  // 🧁 Muffin
    'n': 'assets/images/letters/n.webp',  // 🪺 Nest
    'o': 'assets/images/letters/o.webp',  // 🍊 Orange
    'p': 'assets/images/letters/p.webp',  // 🐷 Pig
    'q': 'assets/images/letters/q.webp',  // 👑 Crown (Queen)
    'r': 'assets/images/letters/r.webp',  // 🌈 Rainbow
    's': 'assets/images/letters/s.webp',  // 🌞 Sun
    't': 'assets/images/letters/t.webp',  // 🌳 Tree
    'u': 'assets/images/letters/u.webp',  // 🌂 Umbrella
    'v': 'assets/images/letters/v.webp',  // 🎻 Violin
    'w': 'assets/images/letters/w.webp',  // 🍉 Watermelon
    'x': 'assets/images/letters/x.webp',  // 🎹 Xylophone
    'y': 'assets/images/letters/y.webp',  // 🪀 Yo-yo
    'z': 'assets/images/letters/z.webp',  // 🦓 Zebra
  };

  /// Human-readable name of the object for each letter (used for TTS).
  static const Map<String, String> letterObjectNames = {
    'a': 'Apple',    'b': 'Balloon',   'c': 'Car',       'd': 'Duck',
    'e': 'Egg',      'f': 'Fish',      'g': 'Grapes',    'h': 'Hat',
    'i': 'Ice cream','j': 'Jar',       'k': 'Kite',      'l': 'Lemon',
    'm': 'Muffin',   'n': 'Nest',      'o': 'Orange',    'p': 'Pig',
    'q': 'Queen',    'r': 'Rainbow',   's': 'Sun',       't': 'Tree',
    'u': 'Umbrella', 'v': 'Violin',    'w': 'Watermelon','x': 'Xylophone',
    'y': 'Yo-yo',    'z': 'Zebra',
  };

  /// Human-readable uppercase display label for each letter.
  static String label(String letter) => letter.toUpperCase();

  /// Map of letter → icon path (same structure as the number totalNumbers maps).
  static Map<String, String> get iconMap => {
    for (final l in letters) l: iconPath(l),
  };

  /// Map of letter → object image path.
  static Map<String, String> get objectMap => {
    for (final l in letters) l: letterObjects[l]!,
  };

  /// True when [index] (0-based) is a valid letter index.
  static bool isValid(int index) => index >= 0 && index < letters.length;

  /// Letter at 0-based index.
  static String at(int index) => letters[index];
}
