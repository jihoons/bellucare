import 'dart:async';
import 'dart:math';

import 'package:bellucare/api/medication_api.dart';
import 'package:bellucare/model/medication.dart';
import 'package:bellucare/style/colors.dart';
import 'package:bellucare/style/text.dart';
import 'package:bellucare/utils/logger.dart';
import 'package:bellucare/widget/medication_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

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
            child: MedicationSummary(
              value.medications[index],
              onTap: () {
                context.push("/medication", extra: value.medications[index]);
              },
              onDelete: () {
                ref.read(medicationProvider.notifier).removeMedication(value.medications[index]);
              },
            ) ,
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

final medicationProvider = AsyncNotifierProvider<MedicationNotifier, MedicationState>(
      () => MedicationNotifier(),
);

class MedicationState {
  final List<Medication> medications;
  MedicationState({required this.medications});

  MedicationState copyWith({
    List<Medication>? medications,
  }) {
    return MedicationState(
      medications: medications ?? this.medications,
    );
  }
}

class MedicationNotifier extends AsyncNotifier<MedicationState> {
  @override
  FutureOr<MedicationState> build() async {
    var list = await MedicationApi().getMedications();
    return MedicationState(medications: list);
  }

  Future<void> saveMedication(Medication medication) async {
    state = await AsyncValue.guard(() async {
      var saved = await MedicationApi().saveMedication(medication);
      if (saved != null) {
        if (medication.id == 0) {
          state.value!.medications.add(saved);
        }
        return state.value!.copyWith();
      }
      return state.value!;
    });
  }

  Future<void> removeMedication(Medication medication) async {
    state = await AsyncValue.guard(() async {
      var saved = await MedicationApi().removeMedication(medication);
      if (saved != null) {
        state.value!.medications.removeWhere((element) => element.id == medication.id,);
        return state.value!.copyWith();
      }
      return state.value!;
    });
  }

  Future<List<Medication>> fetchMedications() async {
    return await MedicationApi().getMedications();
  }
}