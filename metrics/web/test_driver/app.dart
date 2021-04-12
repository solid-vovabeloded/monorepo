import 'package:flutter_driver/flutter_driver.dart';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final driver = await FlutterDriver.connect(printCommunication: true);

  driver.webDriver.addEventListener((event) async {
    final result = event.result;
    if (result is Map && result['isError'] is bool) {
      final isError = result['isError'] as bool;

      if (isError) print('${event.exception}\n${event.stackTrace}');
    }
  });

  return integrationDriver(driver: driver);
}
