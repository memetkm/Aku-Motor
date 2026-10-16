import 'package:aku_motor/core/network/api_client.dart';
import 'package:aku_motor/features/motors/data/api_motor_repository.dart';
import 'package:aku_motor/features/motors/domain/motor.dart';
import 'package:flutter_test/flutter_test.dart';

class MockApiClient implements ApiClient {
  MockApiClient({
    this.response = const ApiResponse(statusCode: 200, body: '[]'),
    this.postResponse,
    this.putResponse,
    this.deleteResponse,
    this.throwException,
  });

  ApiResponse response;
  ApiResponse? postResponse;
  ApiResponse? putResponse;
  ApiResponse? deleteResponse;
  Object? throwException;

  String? requestedPath;
  Map<String, dynamic>? requestedBody;

  @override
  Future<ApiResponse> get(String path) async {
    requestedPath = path;
    if (throwException != null) throw throwException!;
    return response;
  }

  @override
  Future<ApiResponse> post(String path, {Map<String, dynamic>? body}) async {
    requestedPath = path;
    requestedBody = body;
    if (throwException != null) throw throwException!;
    return postResponse ?? response;
  }

  @override
  Future<ApiResponse> put(String path, {Map<String, dynamic>? body}) async {
    requestedPath = path;
    requestedBody = body;
    if (throwException != null) throw throwException!;
    return putResponse ?? response;
  }

  @override
  Future<ApiResponse> delete(String path) async {
    requestedPath = path;
    if (throwException != null) throw throwException!;
    return deleteResponse ?? response;
  }
}

void main() {
  group('Unit Test: Integrasi API dan Model Motor (Minimal 6 Skenario)', () {
    // -------------------------------------------------------------------------
    // 1. Model Valid
    // -------------------------------------------------------------------------
    test('1. Model valid: parsing JSON dari backend menghasilkan entitas Motor yang valid', () {
      final validJson = {
        'Id': 101,
        'Brand': 'Honda',
        'Model': 'Vario 160',
        'Year': 2024,
        'CurrentKilometer': 8500,
        'CreatedAt': '2026-10-01T10:00:00.000Z',
      };

      final motor = Motor.fromJson(validJson);

      expect(motor.id, '101');
      expect(motor.brand, 'Honda');
      expect(motor.model, 'Vario 160');
      expect(motor.year, 2024);
      expect(motor.currentKilometer, 8500);
      expect(motor.createdAt, DateTime.parse('2026-10-01T10:00:00.000Z'));
    });

    // -------------------------------------------------------------------------
    // 2. Model Invalid
    // -------------------------------------------------------------------------
    test(
      '2. Model invalid: JSON dengan atribut wajib yang tidak lengkap melempar FormatException',
      () {
      final missingBrandJson = {
        'Id': 102,
        // 'Brand' tidak ada
        'Model': 'NMAX 155',
        'Year': 2023,
        'CurrentKilometer': 12000,
      };

      expect(
        () => Motor.fromJson(missingBrandJson),
        throwsA(isA<FormatException>()),
      );

      final invalidYearJson = {
        'Id': 103,
        'Brand': 'Yamaha',
        'Model': 'Aerox',
        'Year': 'bukan_angka_tahun',
        'CurrentKilometer': 5000,
      };

      expect(
        () => Motor.fromJson(invalidYearJson),
        throwsA(isA<FormatException>()),
      );
    });

    // -------------------------------------------------------------------------
    // 3. API Sukses
    // -------------------------------------------------------------------------
    test('3. API sukses: berhasil memuat daftar data motor saat backend merespons HTTP 200', () async {
      const jsonResponse = '''
      [
        {
          "Id": 1,
          "Brand": "Honda",
          "Model": "Beat Street",
          "Year": 2023,
          "CurrentKilometer": 6000,
          "CreatedAt": "2026-10-01T08:00:00.000Z"
        },
        {
          "Id": 2,
          "Brand": "Yamaha",
          "Model": "NMAX 155",
          "Year": 2024,
          "CurrentKilometer": 14000,
          "CreatedAt": "2026-10-05T09:30:00.000Z"
        }
      ]
      ''';

      final mockClient = MockApiClient(
        response: const ApiResponse(statusCode: 200, body: jsonResponse),
      );
      final repository = ApiMotorRepository(mockClient);

      final motors = await repository.getAll();

      expect(mockClient.requestedPath, '/motors');
      expect(motors.length, 2);
      expect(motors[0].brand, 'Honda');
      expect(motors[0].model, 'Beat Street');
      expect(motors[1].brand, 'Yamaha');
      expect(motors[1].currentKilometer, 14000);
    });

    // -------------------------------------------------------------------------
    // 4. Data Kosong
    // -------------------------------------------------------------------------
    test('4. Data kosong: mengembalikan list kosong [] saat backend merespons array kosong', () async {
      final mockClient = MockApiClient(
        response: const ApiResponse(statusCode: 200, body: '[]'),
      );
      final repository = ApiMotorRepository(mockClient);

      final motors = await repository.getAll();

      expect(mockClient.requestedPath, '/motors');
      expect(motors, isEmpty);
    });

    // -------------------------------------------------------------------------
    // 5. HTTP Gagal
    // -------------------------------------------------------------------------
    test('5. HTTP gagal: melempar ApiException saat server merespons non-200 (misal 500)', () async {
      final mockClient = MockApiClient(
        response: const ApiResponse(
          statusCode: 500,
          body: '{"Message": "Terjadi kesalahan internal pada server database."}',
        ),
      );
      final repository = ApiMotorRepository(mockClient);

      expect(
        () => repository.getAll(),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });

    // -------------------------------------------------------------------------
    // 6. JSON Rusak
    // -------------------------------------------------------------------------
    test('6. JSON rusak: melempar FormatException saat HTTP 200 namun body response malformed', () async {
      final mockClient = MockApiClient(
        response: const ApiResponse(
          statusCode: 200,
          body: '{"Id": 1, "Brand": "Yamaha", INVALID_JSON_SYNTAX_HERE',
        ),
      );
      final repository = ApiMotorRepository(mockClient);

      expect(
        () => repository.getAll(),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('Unit Test Bonus: Create & Update ke Backend', () {
    test('Create: POST data motor baru dan mem-parsing response 201', () async {
      const createdResponse = '''
      {
        "Id": 99,
        "Brand": "Suzuki",
        "Model": "Satria F150",
        "Year": 2022,
        "CurrentKilometer": 9000,
        "CreatedAt": "2026-10-10T12:00:00.000Z"
      }
      ''';

      final mockClient = MockApiClient(
        postResponse: const ApiResponse(statusCode: 201, body: createdResponse),
      );
      final repository = ApiMotorRepository(mockClient);

      const draft = MotorDraft(
        brand: 'Suzuki',
        model: 'Satria F150',
        year: 2022,
        currentKilometer: 9000,
      );

      final created = await repository.create(draft);

      expect(mockClient.requestedPath, '/motors');
      expect(mockClient.requestedBody?['Brand'], 'Suzuki');
      expect(created.id, '99');
      expect(created.model, 'Satria F150');
    });
  });
}
