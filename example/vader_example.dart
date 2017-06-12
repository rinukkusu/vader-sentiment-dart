// Copyright (c) 2017, 'rinukkusu'. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:vader_sentiment/vader_sentiment.dart';

main() async {
  var vader = new VaderSentiment();
  var scores = await vader.polarityScores("VADER is smart, handsome, and funny.");

  print('negative: ${scores.negative}');
  print('neutral: ${scores.neutral}');
  print('positive: ${scores.positive}');
  print('compound: ${scores.compound}');
}
