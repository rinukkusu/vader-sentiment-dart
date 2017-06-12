// Copyright (c) 2017, 'rinukkusu'. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import '../lib/vader_sentiment.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    VaderSentiment vader;

    setUp(() {
      vader = new VaderSentiment();
    });

    test('First Test', () {
      expect(vader.polarityScores("VADER is smart, handsome, and funny."), new SentimentAnalysisResult(
        0.0, 0.254, 0.764, 0.8316
      ));
    });
  });
}
