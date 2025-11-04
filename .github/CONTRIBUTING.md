# Contributing to KitMedia

Thank you for your interest in contributing to KitMedia! This document provides guidelines and information for contributors.

## 🚀 Getting Started

### Prerequisites
- Flutter 3.9.2 or higher
- Dart 3.0 or higher
- Android Studio or VS Code
- Git

### Setting up the development environment

1. **Clone the repository**
   ```bash
   git clone https://github.com/kitmedia/kitmedia.git
   cd kitmedia
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📋 How to Contribute

### Reporting Bugs
- Use the [Bug Report template](.github/ISSUE_TEMPLATE/bug_report.md)
- Include device information and steps to reproduce
- Add screenshots or videos if helpful

### Suggesting Features
- Use the [Feature Request template](.github/ISSUE_TEMPLATE/feature_request.md)
- Explain the use case and expected behavior
- Consider implementation complexity

### Contributing Code

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
4. **Test your changes**
   ```bash
   flutter test
   flutter analyze
   ```
5. **Commit your changes**
   ```bash
   git commit -m "feat: add your feature description"
   ```
6. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```
7. **Create a Pull Request**

### Contributing Translations
- Use the [Translation Request template](.github/ISSUE_TEMPLATE/translation_request.md)
- Translation files are located in `lib/core/localization/languages/`
- Follow the existing format and naming conventions

## 🎯 Development Guidelines

### Code Style
- Follow Dart/Flutter conventions
- Use `dart format` to format your code
- Run `flutter analyze` to check for issues
- Add comments for complex logic

### Commit Messages
Use conventional commit format:
- `feat:` for new features
- `fix:` for bug fixes
- `docs:` for documentation changes
- `style:` for formatting changes
- `refactor:` for code refactoring
- `test:` for adding tests
- `chore:` for maintenance tasks

### Testing
- Write tests for new features
- Ensure existing tests pass
- Test on different Android versions when possible

### Architecture
- Follow the existing project structure
- Use GetX for state management
- Separate UI, business logic, and data layers
- Keep widgets focused and reusable

## 🌍 Translation Guidelines

### Adding a New Language

1. Create a new file in `lib/core/localization/languages/[language_code].dart`
2. Add the language to `LanguageConstants.supportedLocales`
3. Add language name and flag to `LanguageConstants`
4. Import the new language in `app_translations.dart`
5. Test the translation in the app

### Translation Quality
- Use native speaker translations when possible
- Keep translations concise and clear
- Consider cultural context
- Test translations in the UI to ensure they fit

## 🔍 Code Review Process

1. All submissions require review
2. Reviewers will check:
   - Code quality and style
   - Functionality and testing
   - Documentation updates
   - Breaking changes
3. Address feedback promptly
4. Maintain a respectful tone in discussions

## 📱 Platform-Specific Guidelines

### Android
- Target Android 7.0 (API 24) and above
- Test on different screen sizes
- Consider performance on older devices
- Follow Material Design guidelines

## 🐛 Debugging Tips

- Use `flutter doctor` to check your setup
- Enable verbose logging for debugging
- Use Android Studio's debugging tools
- Check device logs with `adb logcat`

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [GetX Documentation](https://github.com/jonataslaw/getx)
- [Material Design Guidelines](https://material.io/design)

## 🤝 Community

- Be respectful and inclusive
- Help others learn and grow
- Share knowledge and best practices
- Follow our Code of Conduct

## ❓ Questions?

If you have questions about contributing:
- Check existing issues and discussions
- Create a new discussion for general questions
- Contact maintainers for specific guidance

Thank you for contributing to KitMedia! 🎉