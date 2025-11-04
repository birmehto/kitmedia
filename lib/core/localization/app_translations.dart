import 'package:get/get.dart';

import 'languages/de.dart';
import 'languages/en.dart';
import 'languages/es.dart';
import 'languages/fr.dart';
import 'languages/hi.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': en,
    'es': es,
    'fr': fr,
    'de': de,
    'hi': hi,
  };
}
