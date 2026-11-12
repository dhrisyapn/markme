import 'failures.dart';

/// Sealed Result type for functional error handling without throwing unhandled exceptions.
sealed class Result<S, F extends Failure> {
  const Result();

  bool get isSuccess => this is Success<S, F>;
  bool get isFailure => this is ErrorResult<S, F>;

  S get data {
    if (this is Success<S, F>) {
      return (this as Success<S, F>).value;
    }
    throw StateError('Cannot access data on an ErrorResult: ${(this as ErrorResult<S, F>).error}');
  }

  F get failure {
    if (this is ErrorResult<S, F>) {
      return (this as ErrorResult<S, F>).error;
    }
    throw StateError('Cannot access failure on a Success');
  }

  /// Fold method pattern for clean UI branching.
  R fold<R>({
    required R Function(S data) onSuccess,
    required R Function(F failure) onFailure,
  }) {
    if (this is Success<S, F>) {
      return onSuccess((this as Success<S, F>).value);
    } else {
      return onFailure((this as ErrorResult<S, F>).error);
    }
  }
}

class Success<S, F extends Failure> extends Result<S, F> {
  final S value;
  const Success(this.value);

  @override
  String toString() => 'Success($value)';
}

class ErrorResult<S, F extends Failure> extends Result<S, F> {
  final F error;
  const ErrorResult(this.error);

  @override
  String toString() => 'ErrorResult($error)';
}

