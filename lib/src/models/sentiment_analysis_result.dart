class SentimentAnalysisResult {
  double negative;
  double neutral;
  double positive;
  double compound;

  SentimentAnalysisResult(
      [this.negative = 0.0, this.neutral = 0.0, this.positive = 0.0, this.compound = 0.0]);
}
