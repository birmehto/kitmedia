# Testing the GitHub Update Feature

## Quick Test Setup

For testing purposes, you can use a public repository with releases. Here's how to test the feature:

### 1. Use a Test Repository

Update `lib/core/config/app_config.dart` with a test repository that has releases:

```dart
class AppConfig {
  // Test with Flutter's repository (has many releases)
  static const String githubRepoOwner = 'flutter';
  static const String githubRepoName = 'flutter';
  
  // Or use any other public repo with releases
  // static const String githubRepoOwner = 'microsoft';
  // static const String githubRepoName = 'vscode';
}
```

### 2. Test Scenarios

1. **Update Available**: Set your app version lower than the latest release
   - Edit `pubspec.yaml`: `version: 0.1.0` (if latest release is higher)
   
2. **Up to Date**: Set your app version equal to or higher than latest release
   - Edit `pubspec.yaml`: `version: 999.0.0`

3. **Network Error**: Test with airplane mode or no internet

### 3. Testing Steps

1. Open the app and go to Settings
2. Scroll to the "App Updates" section
3. Observe the automatic update check
4. Try manual "Check for Updates" button
5. If update is available, test the "Download" button
6. Test the "View Release Notes" button

### 4. Expected Behavior

- **Loading State**: Shows spinner while checking
- **Update Available**: Shows update badge and download button
- **Up to Date**: Shows checkmark and "You're up to date!" message
- **Error**: Shows error snackbar with network message

### 5. Production Setup

Once testing is complete, update the configuration with your actual repository:

```dart
class AppConfig {
  static const String githubRepoOwner = 'your-github-username';
  static const String githubRepoName = 'your-app-repository';
}
```

## Troubleshooting

- **No updates showing**: Check if your test repo has releases
- **Download not working**: Ensure releases have APK attachments
- **Network errors**: Check internet connection and repository accessibility
- **Version comparison issues**: Ensure version format matches (e.g., v1.0.0 vs 1.0.0)