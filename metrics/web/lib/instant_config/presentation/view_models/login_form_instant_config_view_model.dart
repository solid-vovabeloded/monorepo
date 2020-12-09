import 'package:meta/meta.dart';
import 'package:metrics/instant_config/presentation/view_models/instant_config_view_model.dart';

/// A view model that represents an instant config for the login form feature.
class LoginFormInstantConfigViewModel extends InstantConfigViewModel {
  /// Creates a new instance of the [LoginFormInstantConfigViewModel]
  /// with the given [isEnabled] value.
  const LoginFormInstantConfigViewModel({
    @required bool isEnabled,
  }) : super(isEnabled: isEnabled);
}
