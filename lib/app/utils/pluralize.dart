String pluralize(int count, List<String> words) {
  if (words.length != 3) {
    throw ArgumentError('List must contain exactly 3 forms.');
  }

  final remainder10 = count % 10;
  final remainder100 = count % 100;

  if (remainder100 >= 11 && remainder100 <= 19) {
    return words[2]; // Например: 12, 13, 14 → "символов"
  }

  if (remainder10 == 1) {
    return words[0]; // Например: 1 → "символ"
  } else if (remainder10 >= 2 && remainder10 <= 4) {
    return words[1]; // Например: 2, 3, 4 → "символа"
  } else {
    return words[2]; // Все остальные случаи → "символов"
  }
}