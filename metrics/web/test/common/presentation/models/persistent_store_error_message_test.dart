// https://github.com/platform-platform/monorepo/issues/140
// ignore_for_file: prefer_const_constructors
import 'package:metrics/common/domain/entities/persistent_store_error_code.dart';
import 'package:metrics/common/presentation/models/persistent_store_error_message.dart';
import 'package:metrics/common/presentation/strings/common_strings.dart';
import 'package:test/test.dart';

void main() {
  group("PersistentStoreErrorMessage", () {
    test(
      ".message returns null if the given code is null",
      () {
        final errorMessage = PersistentStoreErrorMessage(null);

        expect(errorMessage.message, isNull);
      },
    );

    test(
      ".message returns an open connection failed error message if the given error code is the open connection failed error code",
      () {
        const expectedMessage = CommonStrings.openConnectionFailedErrorMessage;

        final errorMessage = PersistentStoreErrorMessage(
          PersistentStoreErrorCode.openConnectionFailed,
        );

        expect(errorMessage.message, equals(expectedMessage));
      },
    );

    test(
      ".message returns a read failed error message if the given error code is the read error code",
      () {
        const expectedMessage = CommonStrings.readErrorMessage;

        final errorMessage = PersistentStoreErrorMessage(
          PersistentStoreErrorCode.readError,
        );

        expect(errorMessage.message, equals(expectedMessage));
      },
    );

    test(
      ".message returns an update failed error message if the given error code is the update error code",
      () {
        const expectedMessage = CommonStrings.updateErrorMessage;

        final errorMessage = PersistentStoreErrorMessage(
          PersistentStoreErrorCode.updateError,
        );

        expect(errorMessage.message, equals(expectedMessage));
      },
    );

    test(
      ".message returns a close connection failed error message if the given error code is the close connection failed error code",
      () {
        const expectedMessage = CommonStrings.closeConnectionFailedErrorMessage;

        final errorMessage = PersistentStoreErrorMessage(
          PersistentStoreErrorCode.closeConnectionFailed,
        );

        expect(errorMessage.message, equals(expectedMessage));
      },
    );

    test(
      ".message returns an unknown error message if the given error code is the unknown error code",
      () {
        const expectedMessage = CommonStrings.unknownErrorMessage;

        final errorMessage = PersistentStoreErrorMessage(
          PersistentStoreErrorCode.unknown,
        );

        expect(errorMessage.message, equals(expectedMessage));
      },
    );
  });
}
