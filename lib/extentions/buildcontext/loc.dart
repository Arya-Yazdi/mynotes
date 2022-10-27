import 'package:flutter/material.dart' show BuildContext;
import 'package:flutter_gen/gen_l10n/app_localizations.dart'
    show AppLocalizations;

// Extend AppLocalizations so we dont have to type "AppLocalizations.of(context)!.<key>"
// everytime we want to use i18n/l10n.
// This way we can just type "BuildContext.loc.<key>" or "context.loc.<key>".
extension Localization on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;
}
