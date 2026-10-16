import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_failure_reason.dart';

part 'failures.freezed.dart';

/// Доменная ошибка приложения (sealed Freezed).
///
/// Репозитории возвращают `Either<Failure, T>`; UI берёт текст только из
/// [displayMessage]. Сырые SDK-исключения (Firebase и др.) живут в DataSource
/// и маппятся сюда — см. `architecture_echat.md` §10.
@freezed
sealed class Failure with _$Failure {
  const Failure._();

  /// Нет сети / таймаут транспорта.
  const factory Failure.network([String? message]) = NetworkFailure;

  /// Ошибка аутентификации (Login / Register).
  const factory Failure.auth(AuthFailureReason reason) = AuthFailure;

  /// Ошибка Firestore / БД.
  const factory Failure.firestore(String code) = FirestoreFailure;

  /// Сущность не найдена.
  const factory Failure.notFound() = NotFoundFailure;

  /// Непредвиденная ошибка.
  const factory Failure.unexpected(Object error) = UnexpectedFailure;

  /// Текст для snackbar / ErrorView (русский).
  String get displayMessage => switch (this) {
        NetworkFailure(:final message) =>
          message ?? 'Нет подключения к сети',
        AuthFailure(:final reason) => reason.message,
        FirestoreFailure(:final code) => 'Ошибка базы данных: $code',
        NotFoundFailure() => 'Запрошенные данные не найдены',
        UnexpectedFailure() => 'Что-то пошло не так, попробуйте позже',
      };
}
