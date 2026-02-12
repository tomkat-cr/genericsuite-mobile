// Basic conversion utilities
import 'package:genericsuite/services/crud_editor_selector.dart';
import 'package:genericsuite/services/utilities.dart';

const cuDebug = true;

// const String msgSelectAnOption = "Select an option...";

double convertHeight(dynamic height, String? heightUnit, String? targetUnit) {
  final h = (height is num)
      ? height.toDouble()
      : double.tryParse(height.toString()) ?? 0.0;
  if (heightUnit == null ||
      heightUnit.isEmpty ||
      heightUnit == msgSelectAnOption ||
      targetUnit == null ||
      targetUnit.isEmpty ||
      targetUnit == msgSelectAnOption) {
    return 0.0;
  }
  if (heightUnit == targetUnit) {
    return h;
  }
  // cm <-> m
  if (heightUnit == 'cm' && targetUnit == 'm') return h / 100;
  if (heightUnit == 'm' && targetUnit == 'cm') return h * 100;
  // inches <-> m
  if (heightUnit == 'i' && targetUnit == 'm') return h * 0.0254;
  if (heightUnit == 'm' && targetUnit == 'i') return h / 0.0254;
  // inches <-> cm
  if (heightUnit == 'i' && targetUnit == 'cm') return h * 2.54;
  if (heightUnit == 'cm' && targetUnit == 'i') return h / 2.54;

  logErrorRaw(
    'Unsupported height conversion from "$heightUnit" to "$targetUnit"',
  );
  return h;
}

double convertWeight(dynamic weight, String? weightUnit, String? targetUnit) {
  final w = (weight is num)
      ? weight.toDouble()
      : double.tryParse(weight.toString()) ?? 0.0;
  if (weightUnit == null ||
      weightUnit.isEmpty ||
      weightUnit == msgSelectAnOption ||
      targetUnit == null ||
      targetUnit.isEmpty ||
      targetUnit == msgSelectAnOption) {
    return 0.0;
  }
  if (weightUnit == targetUnit) {
    return w;
  }
  if (weightUnit == 'kg' && targetUnit == 'lb') return w * 2.20462;
  if (weightUnit == 'lb' && targetUnit == 'kg') return w / 2.20462;

  logErrorRaw(
    'Unsupported weight conversion from "$weightUnit" to "$targetUnit"',
  );
  return w;
}

dynamic interpretString(String str) {
  /*
  interprete un string, de tal forma que si es un numero, lo devuelva,
  si tiene solo letras (sin espacios), devuelve la cantidad de letras,
  y si no devuelva la cantidad de palabras sin contar las comas o los puntos.
  */
  final n = double.tryParse(str);
  if (n != null) return n;

  final words = str
      .replaceAll(RegExp(r'[.,]'), '')
      .split(' ')
      .where((w) => w.trim().isNotEmpty)
      .toList();
  if (words.length == 1) {
    return words[0].length;
  }
  return words.length;
}

int calculateAge(String dateOfBirth) {
  try {
    final birthDate = DateTime.parse(dateOfBirth);
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  } catch (e) {
    logErrorRaw('Error calculating age: $e');
    return 0;
  }
}

double convertCaloriesToUnit(
  dynamic calories,
  String fromUnit, [
  String toUnit = "kcal",
]) {
  final c = (calories is num)
      ? calories.toDouble()
      : double.tryParse(calories.toString()) ?? 0.0;
  const calorieUnits = {'kcal': 1.0, 'kj': 0.239006};

  final fromFactor = calorieUnits[fromUnit] ?? 1.0;
  final toFactor = calorieUnits[toUnit] ?? 1.0;

  return c * fromFactor / toFactor;
}
