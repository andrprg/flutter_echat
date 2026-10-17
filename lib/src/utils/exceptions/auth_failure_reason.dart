/// Причина ошибки аутентификации (email + пароль, см. макеты Login / Register).
///
/// Коды Firebase Auth маппятся в data-слое → [AuthFailureReason];
/// текст для UI — только через [message].
enum AuthFailureReason {
  /// Пользователь не вошёл в систему.
  notSignedIn,

  /// Неверный пароль (`wrong-password` / `invalid-credential`).
  wrongPassword,

  /// Пользователь с таким email не найден (`user-not-found`).
  userNotFound,

  /// Email уже зарегистрирован (`email-already-in-use`).
  emailAlreadyInUse,

  /// Некорректный формат email (`invalid-email`).
  invalidEmail,

  /// Слишком слабый пароль (`weak-password`).
  weakPassword,

  /// Аккаунт отключён (`user-disabled`).
  userDisabled,

  /// Слишком много попыток (`too-many-requests`).
  tooManyRequests,

  /// Операция недоступна (`operation-not-allowed`).
  operationNotAllowed,

  /// Нужна повторная аутентификация (`requires-recent-login`).
  requiresRecentLogin,

  /// Неизвестный код Auth SDK.
  unknown;

  /// Пользовательский текст ошибки (русский, по сценариям auth-макетов).
  String get message => switch (this) {
        notSignedIn => 'Войдите в аккаунт',
        wrongPassword => 'Неверный пароль',
        userNotFound => 'Пользователь не найден',
        emailAlreadyInUse => 'Email уже занят',
        invalidEmail => 'Некорректный email',
        weakPassword => 'Слишком слабый пароль',
        userDisabled => 'Аккаунт отключён',
        tooManyRequests => 'Слишком много попыток, попробуйте позже',
        operationNotAllowed => 'Операция недоступна',
        requiresRecentLogin => 'Войдите снова, чтобы продолжить',
        unknown => 'Ошибка авторизации',
      };
}
