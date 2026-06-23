class SentenceModel {
  final String korean;
  final String english;

  SentenceModel({
    required this.korean,
    required this.english,
  });

  factory SentenceModel.fromJson(Map<String, dynamic> json) {
    return SentenceModel(
      korean: json['korean'] as String? ?? '',
      english: json['english'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'korean': korean,
      'english': english,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SentenceModel &&
          runtimeType == other.runtimeType &&
          korean == other.korean &&
          english == other.english;

  @override
  int get hashCode => korean.hashCode ^ english.hashCode;
}
