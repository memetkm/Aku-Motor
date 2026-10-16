import 'dart:convert';

import '../../../core/network/api_client.dart';
import '../domain/motor.dart';
import '../domain/motor_repository.dart';

class ApiMotorRepository implements MotorRepository {
  ApiMotorRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<Motor>> getAll() async {
    final response = await _client.get('/motors');

    if (!response.isSuccess) {
      throw ApiException(
        response.statusCode,
        'Gagal memuat data motor dari server: ${response.body}',
      );
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException catch (e) {
      throw FormatException('Response backend bukan JSON yang valid: ${e.message}');
    }

    if (decoded is! List) {
      throw const FormatException(
        'Format data response server tidak sesuai (harus berupa array).',
      );
    }

    return decoded
        .map((item) => Motor.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  @override
  Future<Motor> create(MotorDraft draft) async {
    final response = await _client.post('/motors', body: draft.toJson());

    if (response.statusCode != 201 && !response.isSuccess) {
      throw ApiException(
        response.statusCode,
        'Gagal menyimpan data motor baru ke server: ${response.body}',
      );
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException catch (e) {
      throw FormatException('Response create bukan JSON yang valid: ${e.message}');
    }

    if (decoded is! Map) {
      throw const FormatException('Response create motor tidak valid.');
    }

    return Motor.fromJson(Map<String, dynamic>.from(decoded));
  }

  @override
  Future<Motor> update(String id, MotorDraft draft) async {
    final response = await _client.put('/motors/$id', body: draft.toJson());

    if (!response.isSuccess) {
      throw ApiException(
        response.statusCode,
        'Gagal memperbarui data motor pada server: ${response.body}',
      );
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException catch (e) {
      throw FormatException('Response update bukan JSON yang valid: ${e.message}');
    }

    if (decoded is! Map) {
      throw const FormatException('Response update motor tidak valid.');
    }

    return Motor.fromJson(Map<String, dynamic>.from(decoded));
  }

  @override
  Future<void> delete(String id) async {
    final response = await _client.delete('/motors/$id');

    if (response.statusCode != 204 && !response.isSuccess) {
      throw ApiException(
        response.statusCode,
        'Gagal menghapus motor dari server: ${response.body}',
      );
    }
  }
}

