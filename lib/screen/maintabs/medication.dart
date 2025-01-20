import 'dart:async';
import 'dart:math';

import 'package:bellucare/style/colors.dart';
import 'package:bellucare/style/text.dart';
import 'package:bellucare/widget/medication_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

class Medication {
  Medication({
    required this.name,
  });
  String name;

  Medication copyWith({
    String? name,
  }) {
    return Medication(
      name: name ?? this.name,
    );
  }
}

class MedicationState {
  MedicationState({
    required this.medications,
  });

  List<Medication> medications;

  MedicationState copyWith({
    List<Medication>? medications
  }) {
    return MedicationState(
      medications: medications ?? this.medications,
    );
  }
}

class MedicationNotifier extends AsyncNotifier<MedicationState> {
  Future<void> addMedication(Medication medication) async {
    if (state.hasValue) {
      state = await AsyncValue.guard(() async {
        state.value!.medications.add(medication);
        return state.value!.copyWith();
      },);
    }
  }

  @override
  FutureOr<MedicationState> build() async {
    return Future.delayed(Duration(seconds: 1), () {
      return MedicationState(
        medications: List.empty(growable: true),
      );
    },);
  }
}

final medicationProvider = AsyncNotifierProvider<MedicationNotifier,MedicationState>(
      () => MedicationNotifier(),
);


class MedicationMainTab extends ConsumerWidget {
  const MedicationMainTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return getBody(context, ref);
  }

  Widget getBody(BuildContext context, WidgetRef ref) {
    var value = ref.watch(medicationProvider);
    return value.when(
      data: (data) => getMedicationList(context, ref, data),
      error: (error, stackTrace) => getSkeleton(context),
      loading: () => getSkeleton(context),
    );
  }

  Widget getMedicationList(BuildContext context, WidgetRef ref, MedicationState value) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: value.medications.length + 1,
      itemBuilder: (context, index) {
        if (index < value.medications.length) {
          return Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: MedicationSummary(value.medications[index]),
          );
        } else {
          return SizedBox(height: 60,);
        }
      },
    );
  }

  Widget createMedicationSkeleton(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: skeletonBaseColor,
        highlightColor: skeletonHighlightColor,
        child: Container(
          width: MediaQuery.sizeOf(context).width - 32,
          height: 102,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: skeletonBaseColor,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        )
    );
  }
  Widget getSkeleton(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        spacing: 6,
        children: List.generate(10, (index) => createMedicationSkeleton(context),),
      ),
    );
  }
}