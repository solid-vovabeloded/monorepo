import 'package:metrics/auth/presentation/models/password_validation_error_message.dart';
import 'package:metrics_core/metrics_core.dart';

/// A class for validating a password.
class PasswordValidator {
  /// Validates the given [value] as a password.
  ///
  /// Returns an error message if the [value] is not a valid password,
  /// otherwise returns null.
  static String validate(String value) {
    PasswordValidationErrorMessage errorMessage;

    try {
      Password(value);
    } on PasswordValidationException catch (exception) {
      errorMessage = PasswordValidationErrorMessage(
        exception.code,
      );
    }

    return errorMessage?.message;
  }
}
