import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/qr_session.dart';
import '../repositories/admin_repository.dart';

class CreateQrSessionUseCase {
  final AdminRepository _repository;

  const CreateQrSessionUseCase(this._repository);

  Future<Result<QrSession, Failure>> call({int? durationMinutes}) {
    return _repository.createQrSession(durationMinutes: durationMinutes);
  }
}

