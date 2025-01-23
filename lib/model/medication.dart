class Medication {
  Medication({
    this.name = '', 
    List<bool>? weekdays,
    List<String>? actionTimes,
  }) : weekdays = weekdays ?? [false, false, false, false, false, false, false], 
        actionTimes = actionTimes ?? [];
  
  String name;
  List<bool> weekdays;
  List<String> actionTimes;
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'weekdays': weekdays,
      'actionTimes': actionTimes,
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      name: json['name'] ?? '',
      weekdays: List<bool>.from(json['weekdays'] ??
          [false, false, false, false, false, false, false]),
      actionTimes: List<String>.from(json['actionTimes'] ?? []),
    );
  }
}