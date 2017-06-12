import 'dart:async';
import 'dart:io';
import 'models/sentiment_analysis_result.dart';
import 'senti_text.dart';
import 'sentiment_utils.dart';
import 'String_helper.dart';

class VaderSentiment {
  static const double _ExclIncr = 0.292;
  static const double _QuesIncrSmall = 0.18;
  static const double _QuesIncrLarge = 0.96;

  Map<String, double> _lexicon;
  List<String> _lexiconFullFile;

  VaderSentiment();

  Future<Null> _initialize() async {
    if (_lexicon == null) {
      _lexiconFullFile =
          await new File('./lib/src/data/vader_lexicon.txt').readAsLines();

      _lexicon = _makeLexDic();
    }
  }

  Map<String, double> _makeLexDic() {
    var dic = new Map<String, double>();
    for (var line in _lexiconFullFile) {
      var lineArray = line.trim().split('\t');
      dic[lineArray[0]] = double.parse(lineArray[1]);
    }
    return dic;
  }

  Future<SentimentAnalysisResult> polarityScores(String input) async {
    await _initialize();

    SentiText sentiText = new SentiText(input);
    List<double> sentiments = new List<double>();
    List<String> wordsAndEmoticons = sentiText.wordsAndEmoticons;

    for (int i = 0; i < wordsAndEmoticons.length; i++) {
      String item = wordsAndEmoticons[i];
      double valence = 0.0;
      if (i < wordsAndEmoticons.length - 1 &&
              item.toLowerCase() == "kind" &&
              wordsAndEmoticons[i + 1] == "of" ||
          SentimentUtils.BoosterMap.containsKey(item.toLowerCase())) {
        sentiments.add(valence);
        continue;
      }
      sentiments = _sentimentValence(valence, sentiText, item, i, sentiments);
    }

    sentiments = _butCheck(wordsAndEmoticons, sentiments);

    return _scoreValence(sentiments, input);
  }

  List<double> _sentimentValence(double valence, SentiText sentiText,
      String item, int i, List<double> sentiments) {
    String itemLowerCase = item.toLowerCase();
    if (!_lexicon.containsKey(itemLowerCase)) {
      sentiments.add(valence);
      return sentiments;
    }

    bool isCapDiff = sentiText.isCapDifferential;
    List<String> wordsAndEmoticons = sentiText.wordsAndEmoticons;
    valence = _lexicon[itemLowerCase];
    if (isCapDiff && isUpper(item)) {
      if (valence > 0)
        valence += SentimentUtils.CIncr;
      else
        valence -= SentimentUtils.CIncr;
    }

    for (int startI = 0; startI < 3; startI++) {
      if (i > startI &&
          !_lexicon
              .containsKey(wordsAndEmoticons[i - (startI + 1)].toLowerCase())) {
        double s = SentimentUtils.scalarIncDec(
            wordsAndEmoticons[i - (startI + 1)], valence, isCapDiff);
        if (startI == 1 && s != 0) s = s * 0.95;
        if (startI == 2 && s != 0) s = s * 0.9;
        valence = valence + s;

        valence = _neverCheck(valence, wordsAndEmoticons, startI, i);

        if (startI == 2) {
          valence = _idiomsCheck(valence, wordsAndEmoticons, i);
        }
      }
    }

    valence = _leastCheck(valence, wordsAndEmoticons, i);
    sentiments.add(valence);
    return sentiments;
  }

  List<double> _butCheck(
      List<String> wordsAndEmoticons, List<double> sentiments) {
    bool containsBUT = wordsAndEmoticons.contains("BUT");
    bool containsbut = wordsAndEmoticons.contains("but");
    if (!containsBUT && !containsbut) return sentiments;

    int butIndex = (containsBUT)
        ? wordsAndEmoticons.indexOf("BUT")
        : wordsAndEmoticons.indexOf("but");

    for (int i = 0; i < sentiments.length; i++) {
      double sentiment = sentiments[i];
      if (i < butIndex) {
        sentiments.removeAt(i);
        sentiments.insert(i, sentiment * 0.5);
      } else if (i > butIndex) {
        sentiments.removeAt(i);
        sentiments.insert(i, sentiment * 1.5);
      }
    }
    return sentiments;
  }

  double _leastCheck(double valence, List<String> wordsAndEmoticons, int i) {
    if (i > 1 &&
        !_lexicon.containsKey(wordsAndEmoticons[i - 1].toLowerCase()) &&
        wordsAndEmoticons[i - 1].toLowerCase() == "least") {
      if (wordsAndEmoticons[i - 2].toLowerCase() != "at" &&
          wordsAndEmoticons[i - 2].toLowerCase() != "very")
        valence = valence * SentimentUtils.NScalar;
    } else if (i > 0 &&
        !_lexicon.containsKey(wordsAndEmoticons[i - 1].toLowerCase()) &&
        wordsAndEmoticons[i - 1].toLowerCase() == "least")
      valence = valence * SentimentUtils.NScalar;

    return valence;
  }

  double _neverCheck(
      double valence, List<String> wordsAndEmoticons, int startI, int i) {
    if (startI == 0) {
      if (SentimentUtils.Negated(<String>[wordsAndEmoticons[i - 1]]))
        valence = valence * SentimentUtils.NScalar;
    }
    if (startI == 1) {
      if (wordsAndEmoticons[i - 2] == "never" &&
          (wordsAndEmoticons[i - 1] == "so" ||
              wordsAndEmoticons[i - 1] == "this"))
        valence = valence * 1.5;
      else if (SentimentUtils
          .Negated(<String>[wordsAndEmoticons[i - (startI + 1)]]))
        valence = valence * SentimentUtils.NScalar;
    }
    if (startI == 2) {
      if (wordsAndEmoticons[i - 3] == "never" &&
              (wordsAndEmoticons[i - 2] == "so" ||
                  wordsAndEmoticons[i - 2] == "this") ||
          (wordsAndEmoticons[i - 1] == "so" ||
              wordsAndEmoticons[i - 1] == "this"))
        valence = valence * 1.25;
      else if (SentimentUtils
          .Negated(<String>[wordsAndEmoticons[i - (startI + 1)]]))
        valence = valence * SentimentUtils.NScalar;
    }

    return valence;
  }

  double _idiomsCheck(double valence, List<String> wordsAndEmoticons, int i) {
    String oneZero = "${wordsAndEmoticons[i - 1]} ${wordsAndEmoticons[i]}";
    String twoOneZero =
        "${wordsAndEmoticons[i - 2]} ${wordsAndEmoticons[i - 1]} ${wordsAndEmoticons[i]}";
    String twoOne = "${wordsAndEmoticons[i - 2]} ${wordsAndEmoticons[i - 1]}";
    String threeTwoOne =
        "${wordsAndEmoticons[i - 3]} ${wordsAndEmoticons[i - 2]} ${wordsAndEmoticons[i - 1]}";
    String threeTwo = "${wordsAndEmoticons[i - 3]} ${wordsAndEmoticons[i - 2]}";

    List<String> sequences = [
      oneZero,
      twoOneZero,
      twoOne,
      threeTwoOne,
      threeTwo
    ];

    for (var seq in sequences) {
      if (SentimentUtils.SpecialCaseIdioms.containsKey(seq)) {
        valence = SentimentUtils.SpecialCaseIdioms[seq];
        break;
      }
    }

    if (wordsAndEmoticons.length - 1 > i) {
      String zeroOne = "${wordsAndEmoticons[i]} ${wordsAndEmoticons[i + 1]}";

      if (SentimentUtils.SpecialCaseIdioms.containsKey(zeroOne))
        valence = SentimentUtils.SpecialCaseIdioms[zeroOne];
    }

    if (wordsAndEmoticons.length - 1 > i + 1) {
      String zeroOneTwo =
          "${wordsAndEmoticons[i]} ${wordsAndEmoticons[i + 1]} ${wordsAndEmoticons[i + 2]}";
      if (SentimentUtils.SpecialCaseIdioms.containsKey(zeroOneTwo))
        valence = SentimentUtils.SpecialCaseIdioms[zeroOneTwo];
    }

    if (SentimentUtils.BoosterMap.containsKey(threeTwo) ||
        SentimentUtils.BoosterMap.containsKey(twoOne))
      valence += SentimentUtils.BDecr;

    return valence;
  }

  double _punctuationEmphasis(String text) {
    return _amplifyExclamation(text) + _amplifyQuestion(text);
  }

  double _amplifyExclamation(String text) {
    int epCount = text.runes.where((x) => x == '!'.runes.first).length;

    if (epCount > 4) epCount = 4;

    return epCount * _ExclIncr;
  }

  double _amplifyQuestion(String text) {
    int qmCount = text.runes.where((x) => x == '?'.runes.first).length;

    if (qmCount < 1) return 0.0;

    if (qmCount <= 3) return qmCount * _QuesIncrSmall;

    return _QuesIncrLarge;
  }

  _SiftSentiments _siftSentimentScores(List<double> sentiments) {
    _SiftSentiments siftSentiments = new _SiftSentiments();

    for (var sentiment in sentiments) {
      if (sentiment > 0)
        siftSentiments.posSum += (sentiment + 1); //1 compensates for neutrals

      if (sentiment < 0) siftSentiments.negSum += (sentiment - 1);

      if (sentiment == 0) siftSentiments.neuCount++;
    }
    return siftSentiments;
  }

  SentimentAnalysisResult _scoreValence(List<double> sentiments, String text) {
    if (sentiments.length == 0)
      return new SentimentAnalysisResult(); //will return with all 0

    double sum = sentiments.reduce((a, b) => a + b);
    double puncAmplifier = _punctuationEmphasis(text);

    if (sum > 0) {
      sum += puncAmplifier;
    } else if (sum < 0) {
      sum -= puncAmplifier;
    }

    double compound = SentimentUtils.normalize(sum);
    _SiftSentiments sifted = _siftSentimentScores(sentiments);

    if (sifted.posSum > sifted.negSum.abs()) {
      sifted.posSum += puncAmplifier;
    } else if (sifted.posSum < sifted.negSum.abs()) {
      sifted.negSum -= puncAmplifier;
    }

    double total = sifted.posSum + sifted.negSum.abs() + sifted.neuCount;
    return new SentimentAnalysisResult(
        (sifted.negSum / total).abs(),
        (sifted.neuCount / total).abs(),
        (sifted.posSum / total).abs(),
        compound);
  }
}

class _SiftSentiments {
  double posSum = 0.0;
  double negSum = 0.0;
  int neuCount = 0;
}
