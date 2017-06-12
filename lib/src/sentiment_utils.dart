import 'dart:math';
import 'string_helper.dart';

class SentimentUtils {
  static const double BIncr = 0.293;
  static const double BDecr = -0.293;
  static const double CIncr = 0.733;
  static const double NScalar = -0.74;

  static const List<String> PuncList = const [
    ".",
    "!",
    "?",
    ",",
    ";",
    ":",
    "-",
    "'",
    "\"",
    "!!",
    "!!!",
    "??",
    "???",
    "?!?",
    "!?!",
    "?!?!",
    "!?!?"
  ];

  static const List<String> Negate = const [
    "aint",
    "arent",
    "cannot",
    "cant",
    "couldnt",
    "darent",
    "didnt",
    "doesnt",
    "ain't",
    "aren't",
    "can't",
    "couldn't",
    "daren't",
    "didn't",
    "doesn't",
    "dont",
    "hadnt",
    "hasnt",
    "havent",
    "isnt",
    "mightnt",
    "mustnt",
    "neither",
    "don't",
    "hadn't",
    "hasn't",
    "haven't",
    "isn't",
    "mightn't",
    "mustn't",
    "neednt",
    "needn't",
    "never",
    "none",
    "nope",
    "nor",
    "not",
    "nothing",
    "nowhere",
    "oughtnt",
    "shant",
    "shouldnt",
    "uhuh",
    "wasnt",
    "werent",
    "oughtn't",
    "shan't",
    "shouldn't",
    "uh-uh",
    "wasn't",
    "weren't",
    "without",
    "wont",
    "wouldnt",
    "won't",
    "wouldn't",
    "rarely",
    "seldom",
    "despite"
  ];

  static const Map<String, double> BoosterMap = const {
    "absolutely": BIncr,
    "amazingly": BIncr,
    "awfully": BIncr,
    "completely": BIncr,
    "considerably": BIncr,
    "decidedly": BIncr,
    "deeply": BIncr,
    "effing": BIncr,
    "enormously": BIncr,
    "entirely": BIncr,
    "especially": BIncr,
    "exceptionally": BIncr,
    "extremely": BIncr,
    "fabulously": BIncr,
    "flipping": BIncr,
    "flippin": BIncr,
    "fricking": BIncr,
    "frickin": BIncr,
    "frigging": BIncr,
    "friggin": BIncr,
    "fully": BIncr,
    "fucking": BIncr,
    "greatly": BIncr,
    "hella": BIncr,
    "highly": BIncr,
    "hugely": BIncr,
    "incredibly": BIncr,
    "intensely": BIncr,
    "majorly": BIncr,
    "more": BIncr,
    "most": BIncr,
    "particularly": BIncr,
    "purely": BIncr,
    "quite": BIncr,
    "really": BIncr,
    "remarkably": BIncr,
    "so": BIncr,
    "substantially": BIncr,
    "thoroughly": BIncr,
    "totally": BIncr,
    "tremendously": BIncr,
    "uber": BIncr,
    "unbelievably": BIncr,
    "unusually": BIncr,
    "utterly": BIncr,
    "very": BIncr,
    "almost": BDecr,
    "barely": BDecr,
    "hardly": BDecr,
    "just enough": BDecr,
    "kind of": BDecr,
    "kinda": BDecr,
    "kindof": BDecr,
    "kind-of": BDecr,
    "less": BDecr,
    "little": BDecr,
    "marginally": BDecr,
    "occasionally": BDecr,
    "partly": BDecr,
    "scarcely": BDecr,
    "slightly": BDecr,
    "somewhat": BDecr,
    "sort of": BDecr,
    "sorta": BDecr,
    "sortof": BDecr,
    "sort-of": BDecr
  };

  static const Map<String, double> SpecialCaseIdioms = const {
    "the shit": 3.0,
    "the bomb": 3.0,
    "bad ass": 1.5,
    "yeah right": -2.0,
    "cut the mustard": 2.0,
    "kiss of death": -1.5,
    "hand to mouth": -2.0
  };

  static bool Negated(List<String> inputWords, [bool includenT = true]) {
    for (var word in Negate) {
      if (inputWords.contains(word)) return true;
    }

    if (includenT) {
      for (var word in inputWords) {
        if (word.contains("n't")) return true;
      }
    }

    if (inputWords.contains("least")) {
      int i = inputWords.indexOf("least");
      if (i > 0 && inputWords[i - 1] != "at") return true;
    }

    return false;
  }

  static double normalize(double score, [double alpha = 15.0]) {
    double normScore = score / sqrt(score * score + alpha);

    if (normScore < -1.0) return -1.0;
    if (normScore > 1.0) return 1.0;

    return normScore;
  }

  static bool allCapDifferential(List<String> words) {
    int allCapWords = 0;

    for (var word in words) {
      if (isUpper(word))
        allCapWords++;
    }

    int capDifferential = words.length - allCapWords;
    if (capDifferential > 0 && capDifferential < words.length)
      return true;

    return false;
  }

  static double scalarIncDec(String word, double valence, bool isCapDiff) {
    String wordLower = word.toLowerCase();
    if (!BoosterMap.containsKey(wordLower))
      return 0.0;

    double scalar = BoosterMap[wordLower];
    if (valence < 0)
      scalar *= -1;

    if (isUpper(word) && isCapDiff)
      scalar += (valence > 0) ? CIncr : -CIncr;

    return scalar;
  }
}
