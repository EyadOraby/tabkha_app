import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:material_ui/material_ui.dart';
import 'package:tabkha_app/Localization/app_localizations.dart';

/// The app's strings plus Material, Cupertino and widget localisations.
///
/// The generated `AppLocalizations.localizationsDelegates` still lists the
/// framework's Material and Cupertino delegates, which the material_ui and
/// cupertino_ui widgets do not read, so the app uses this list instead.
const List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
];
