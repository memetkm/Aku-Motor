import 'booking.dart';

abstract final class BookingValidation {
  static Map<String, String> validate(BookingDraft draft, {DateTime? now}) {
    final errors = <String, String>{};

    if (draft.motorDescription.trim().isEmpty) {
      errors['motorDescription'] = 'Deskripsi motor tidak boleh kosong.';
    } else if (draft.motorDescription.trim().length < 3) {
      errors['motorDescription'] = 'Deskripsi motor minimal 3 karakter.';
    }

    if (draft.serviceType.trim().isEmpty) {
      errors['serviceType'] = 'Pilih jenis layanan servis.';
    }

    if (draft.workshopName.trim().isEmpty) {
      errors['workshopName'] = 'Nama bengkel tujuan wajib diisi.';
    }

    final today = now ?? DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final bookingDay = DateTime(
      draft.bookingDate.year,
      draft.bookingDate.month,
      draft.bookingDate.day,
    );

    if (bookingDay.isBefore(startOfToday)) {
      errors['bookingDate'] = 'Tanggal booking tidak boleh di masa lampau.';
    }

    return errors;
  }

  static bool isValid(BookingDraft draft, {DateTime? now}) {
    return validate(draft, now: now).isEmpty;
  }
}
