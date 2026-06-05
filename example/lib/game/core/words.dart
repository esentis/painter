import 'dart:math';

const _words = [
  'cat', 'dog', 'house', 'tree', 'car', 'sun', 'moon', 'fish',
  'bird', 'flower', 'book', 'chair', 'table', 'phone', 'clock',
  'guitar', 'pizza', 'rocket', 'umbrella', 'bicycle', 'airplane',
  'snowman', 'rainbow', 'castle', 'dragon', 'robot', 'elephant',
  'penguin', 'volcano', 'dinosaur', 'butterfly', 'mushroom',
  'mountain', 'waterfall', 'lighthouse', 'pirate', 'mermaid',
  'cactus', 'tornado', 'octopus', 'sandwich', 'telescope',
  'helicopter', 'strawberry', 'scorpion', 'trampoline',
];

final _random = Random();

String getRandomWord() => _words[_random.nextInt(_words.length)];
