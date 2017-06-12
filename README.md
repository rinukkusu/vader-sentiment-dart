# vader_dart

Sentiment analysis using VADER with Dart.

## Usage

A simple usage example:

'''dart
import 'package:vader_sentiment/vader_sentiment.dart';

main() async {
  var vader = new VaderSentiment();
  var scores = await vader.polarityScores("VADER is smart, handsome, and funny.");

  print('negative: ${scores.negative}');
  print('neutral: ${scores.neutral}');
  print('positive: ${scores.positive}');
  print('compound: ${scores.compound}');
}
'''

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/rinukkusu/vader-dart/issues
