class Medication {
  Medication({
    this.id = 0,
    this.name = '', 
    List<bool>? weekdays,
    List<String>? actionTimes,
  }) : weekdays = weekdays ?? [false, false, false, false, false, false, false], 
        actionTimes = actionTimes ?? [];
  
  int id;
  String name;
  List<bool> weekdays;
  List<String> actionTimes;
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'weekdays': weekdays,
      'actionTimes': actionTimes,
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      weekdays: List<bool>.from(json['weekdays'] ??
          [false, false, false, false, false, false, false]),
      actionTimes: List<String>.from(json['actionTimes'] ?? []),
    );
  }

  Medication copyWith({
    int? id,
    String? name,
    List<bool>? weekdays,
    List<String>? actionTimes,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      weekdays: weekdays ?? List<bool>.from(this.weekdays),
      actionTimes: actionTimes ?? List<String>.from(this.actionTimes),
    );
  }
}