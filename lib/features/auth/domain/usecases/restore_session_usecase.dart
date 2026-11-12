import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/employee_profile.dart';
import '../repositories/auth_repository.dart';

class RestoreSessionUseCase {
  final AuthRepository _repository;

  const RestoreSessionUseCase(this._repository);

  Future<Result<EmployeeProfile, Failure>> call() {
    return _repository.restoreSession();
  }
}

