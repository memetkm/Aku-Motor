import 'motor.dart';

abstract final class MotorValidation {
  static const int minYear = 1900;
  static int maxYear([DateTime? now]) => (now ?? DateTime.now()).year + 1;
  static const int maxKilometer = 1000000;

  static Map<String, String> validate(MotorDraft draft, {DateTime? now}) {
    final errors = <String, String>{};

    if (draft.brand.trim().isEmpty) {
      errors['brand'] = 'Merek motor wajib diisi.';
    } else if (draft.brand.trim().length < 2) {
      errors['brand'] = 'Merek motor minimal 2 karakter.';
    } else if (draft.brand.trim().length > 50) {
      errors['brand'] = 'Merek motor maksimal 50 karakter.';
    }

    if (draft.model.trim().isEmpty) {
      errors['model'] = 'Model motor wajib diisi.';
    } else if (draft.model.trim().length < 2) {
      errors['model'] = 'Model motor minimal 2 karakter.';
    } else if (draft.model.trim().length > 50) {
      errors['model'] = 'Model motor maksimal 50 karakter.';
    }

    final limitYear = maxYear(now);
    if (draft.year < minYear || draft.year > limitYear) {
      errors['year'] = 'Tahun pembuatan harus antara $minYear dan $limitYear.';
    }

    if (draft.currentKilometer < 0) {
      errors['currentKilometer'] = 'Kilometer tidak boleh bernilai negatif.';
    } else if (draft.currentKilometer > maxKilometer) {
      errors['currentKilometer'] = 'Kilometer melebihi batas wajar ($maxKilometer km).';
    }

    return errors;
  }

  static bool isValid(MotorDraft draft, {DateTime? now}) {
    return validate(draft, now: now).isEmpty;
  }
}
