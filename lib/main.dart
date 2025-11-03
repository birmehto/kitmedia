import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';

import 'app_binding.dart';
import 'core/config/app_config.dart';
import 'core/localization/app_translations.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/controllers/language_controller.dart';
import 'features/settings/controllers/theme_controller.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Media Kit
  MediaKit.ensureInitialized();

  Get.put(ThemeController());
  Get.put(LanguageController());
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
              // Enhanced navigation with Material 3 expressive theming
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
