# GitHub Update Feature Setup

This document explains how to configure the GitHub update feature for your KitMedia app.

## Configuration

1. **Update Repository Information**
   
   Edit `lib/core/config/app_config.dart` and update the following values:
   
   ```dart
   static const String githubRepoOwner = 'your-username'; // Your GitHub username
   static const String githubRepoName = 'kitmedia'; // Your repository name
   ```

2. **GitHub Repository Setup**
   
   - Ensure your repository is public (or configure authentication for private repos)
   - Create releases with version tags (e.g., `v1.0.0`, `v1.1.0`)
   - Attach APK files to releases for direct download

## Features

- **Automatic Update Checking**: Checks for updates when settings screen loads
- **Manual Update Check**: Users can manually check for updates
- **Version Comparison**: Compares current app version with latest GitHub release
- **Direct Download**: Downloads APK files directly from GitHub releases
- **Release Notes**: Shows release notes and changelog
- **Update Notifications**: Visual indicators when updates are available

## Usage

1. The update section appears in the Settings screen
2. Shows current app version and update status
3. Provides buttons to:
   - Check for updates manually
   - Download latest version
   - View release notes

## Release Process

1. Update version in `pubspec.yaml`
2. Build and test your app
3. Create a new release on GitHub with:
   - Version tag (e.g., `v1.2.0`)
   - Release title and description
   - Attach the built APK file
4. Users will be notified of the update in the app

## Customization

You can customize the update behavior by modifying:
- `AppConfig` class for configuration
- `AppUpdateService` for update logic
- `UpdateSection` widget for UI appearance
- Update check frequency and behavior

## Security Notes

- Only download APKs from trusted sources
- Consider implementing signature verification
- Test updates thoroughly before release
- Provide clear release notes for users