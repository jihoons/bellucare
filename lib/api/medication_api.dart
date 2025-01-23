import 'dart:convert';

import 'package:bellucare/model/medication.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedicationApi {
  MedicationApi._privateConstructor();

  static final MedicationApi _instance = MedicationApi._privateConstructor();

  factory MedicationApi() {
    return _instance;
  }

  Future<List<Medication>> load() async {
    var spf = await SharedPreferences.getInstance();
    var data = spf.getString("medication");
    if (data == null) {
      return [];
    }
    var list = jsonDecode(data) as List<dynamic>;
    return list.map((e) => Medication.fromJson(e as Map<String, dynamic>),).toList(growable: true);
  }
  
  Future<List<Medication>> getMedications() async {
    return Future.delayed(Duration(milliseconds: 300), () async {
      return load();
    });
  }

  Future<Medication?> saveMedication(Medication medication) async {
    return Future.delayed(Duration(milliseconds: 200), () async {
      var list = await load();

      Medication? saved;
      if (medication.id > 0) {
        list = list.map((e) => e.id == medication.id ? medication : e,).toList(growable: true);
        saved = medication;
      } else {
        var maxId = list.isNotEmpty
            ? list.map((e) => e.id).reduce((a, b) => a > b ? a : b)
            : 0;
        maxId += 1;
        saved = medication.copyWith(id: maxId);
        list.add(saved);
      }

      var spf = await SharedPreferences.getInstance();
      spf.setString("medication", jsonEncode(list.map((e) => e.toJson(),).toList(growable: false)));
      return saved;
    });
  }

  Future<Medication?> removeMedication(Medication medication) async {
    return Future.delayed(Duration(milliseconds: 200), () async {
      var list = await load();
      list.removeWhere((element) => element.id == medication.id,);
      var spf = await SharedPreferences.getInstance();
      spf.setString("medication", jsonEncode(list.map((e) => e.toJson(),).toList(growable: false)));
      return medication;
    });
  }
}
