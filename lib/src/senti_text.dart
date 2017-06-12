import 'sentiment_utils.dart';
import 'string_helper.dart';

class SentiText {
  String _text;
  List<String> wordsAndEmoticons;
  bool isCapDifferential;

  SentiText(this._text) {
    wordsAndEmoticons = _getWordsAndEmoticons();
    isCapDifferential = SentimentUtils.allCapDifferential(wordsAndEmoticons);
  }

  Map<String, String> _wordsPlusPunc() {
    String noPuncText = removePunctuation(_text);
    var wordsOnly = noPuncText.split(' ').where((x) => x.length > 1);

    //for each word in wordsOnly, get each possible variant of punclist before/after
    //Seems poor. Maybe I can improve in future.
    Map<String, String> puncDic = new Map();
    for (var word in wordsOnly) {
      for (var punc in SentimentUtils.PuncList) {
        if (puncDic.containsKey(word + punc)) continue;

        puncDic[word + punc] = word;
        puncDic[punc + word] = word;
      }
    }
    return puncDic;
  }

  List<String> _getWordsAndEmoticons() {
    List<String> wes = _text.split(' ').where((x) => x.length > 1).toList();
    Map<String, String> wordsPuncDic = _wordsPlusPunc();
    for (int i = 0; i < wes.length; i++) {
      if (wordsPuncDic.containsKey(wes[i])) wes[i] = wordsPuncDic[wes[i]];
    }

    return wes;
  }
}
