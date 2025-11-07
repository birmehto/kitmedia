import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app_binding.dart';
import 'core/config/app_config.dart';
import 'core/localization/app_translations.dart';
import 'core/services/app_initialization_service.dart';
import 'core/services/intent_handler_service.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/controllers/language_controller.dart';
import 'features/settings/controllers/theme_controller.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage
  await GetStorage.init();

  // Initialize core services
  Get.put(AppInitializationService(), permanent: true);
  await AppInitializationService.to.initializeApp();

  // Initialize controllers
  Get.put(ThemeController(), permanent: true);
  Get.put(LanguageController(), permanent: true);

  // Initialize intent handler for receiving shared videos
  await Get.putAsync(() => IntentHandlerService().init(), permanent: true);

  runApp(const KitMediaApp());
}

class KitMediaApp extends StatelessWidget {
  const KitMediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return GetBuilder<ThemeController>(
          builder: (themeController) {
            return GetMaterialApp(
              title: AppConfig.appName,
              theme: AppTheme.buildLightTheme(
                themeController.isDynamicColorEnabled ? lightDynamic : null,
              ),
              darkTheme: AppTheme.buildDarkTheme(
                themeController.isDynamicColorEnabled ? darkDynamic : null,
              ),
              themeMode: themeController.themeMode,
              // GetX translations
              translations: AppTranslations(),
              locale: const Locale('en'),
              fallbackLocale: const Locale('en'),
              // GetX routes
              initialRoute: AppRoutes.home,
              getPages: AppRoutes.routes,
              initialBinding: AppBindings(),
              debugShowCheckedModeBanner: false,
              builder: (context, child) {
                if (child == null) return const SizedBox.shrink();
                return MediaQuery(
                  data:
                      MediaQuery.maybeOf(
                        context,
                      )?.copyWith(textScaler: TextScaler.noScaling) ??
                      const MediaQueryData().copyWith(
                        textScaler: TextScaler.noScaling,
                      ),
                  child: child,
                );
              },
            );
          },
        );
      },
    );
  }
}
