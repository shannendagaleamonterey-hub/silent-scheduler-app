class Schedule {
  final String title;
  final String date;
  final String startTime;
  final String endTime;
  final String mode;
  final String language;

  Schedule({
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.mode,
    required this.language,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'mode': mode,
      'language': language,
    };
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      mode: json['mode'] ?? 'silent',
      language: json['language'] ?? 'en',
    );
  }
}