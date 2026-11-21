import 'package:flutter/widgets.dart';
import 'package:tabkha_app/Localization/app_localizations.dart';

extension LocalizedBuildContext on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this);
}
