import '../../../../core/config/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/admin_attendance_record_model.dart';
import '../models/qr_session_model.dart';

abstract class AdminRemoteDataSource {
  Future<QrSessionModel> createQrSession({int? durationMinutes});

  Future<List<AdminAttendanceRecordModel>> getAllAttendanceRecords({
    int offset = 0,
    int limit = 20,
    String? workDate,
  });
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final DioClient _client;

  const AdminRemoteDataSourceImpl(this._client);

  @override
  Future<QrSessionModel> createQrSession({int? durationMinutes}) async {
    final data = <String, dynamic>{};
    if (durationMinutes != null) {
      data['p_duration_minutes'] = durationMinutes;
    }

    final response = await _client.post(
      AppConstants.rpcCreateAttendanceSession,
      data: data,
    );

    return QrSessionModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<AdminAttendanceRecordModel>> getAllAttendanceRecords({
    int offset = 0,
    int limit = 20,
    String? workDate,
  }) async {
    final queryParams = <String, dynamic>{
      'select': '*,employees(employee_code,name)',
      'order': 'work_date.desc,created_at.desc',
      'limit': limit,
      'offset': offset,
    };

    if (workDate != null && workDate.isNotEmpty) {
      queryParams['work_date'] = 'eq.$workDate';
    }

    final response = await _client.get(
      AppConstants.endpointAttendanceRecords,
      queryParameters: queryParams,
    );

    final data = response.data;
    if (data is List) {
      return data
          .map((item) => AdminAttendanceRecordModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }
}

