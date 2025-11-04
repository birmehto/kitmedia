# CI/CD Guide for KitMedia

This guide explains how to use the automated CI/CD workflows for the KitMedia Flutter project.

## Overview

The project uses GitHub Actions for continuous integration and deployment with two main workflows:

1. **Flutter CI** (`flutter_ci.yml`) - Runs on every push and pull request
2. **Release** (`release.yml`) - Runs when you create a new version tag

## Flutter CI Workflow

### When it runs
- Every push to `main` or `beta` branches
- Every pull request to `main` or `beta` branches

### What it does
1. **Test Job**:
   - Sets up Flutter (latest stable)
   - Gets dependencies (`flutter pub get`)
   - Analyzes code (`flutter analyze`)
   - Runs tests (`flutter test`)

2. **Build Job** (runs after tests pass):
   - Sets up Flutter and Java 17
   - Builds release APK
   - Uploads APK as artifact for download

### Viewing Results
- Go to the **Actions** tab in your GitHub repository
- Click on any workflow run to see details
- Download build artifacts from successful runs

## Release Workflow

### When it runs
- Only when you push a version tag (e.g., `v1.0.0`, `v2.1.3`)

### What it does
1. Sets up Flutter and Java
2. Builds both APK and App Bundle (AAB)
3. Creates a GitHub release with:
   - Release notes template
   - APK file for direct download
   - AAB file for Google Play Store

### Creating a Release

1. **Tag your version**:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. **The workflow automatically**:
   - Creates a GitHub release
   - Uploads APK and AAB files
   - Uses the tag name in release title

3. **Edit the release**:
   - Go to **Releases** in your GitHub repo
   - Edit the auto-generated release
   - Update the changelog with actual features/fixes

## Workflow Configuration

### Flutter Setup
- Uses latest stable Flutter version
- No version pinning for automatic updates
- Compatible with your Dart SDK ^3.9.2

### Build Configuration
- **APK**: For direct installation on Android devices
- **AAB**: For Google Play Store distribution
- **Java 17**: Required for modern Android builds

## Troubleshooting

### Common Issues

**Build fails with dependency errors**:
- Check if new dependencies are compatible
- Run `flutter pub get` locally first

**Tests fail**:
- Ensure all tests pass locally: `flutter test`
- Check test files for any environment-specific issues

**Release workflow doesn't trigger**:
- Ensure you're pushing tags, not just commits
- Tag format must start with 'v' (e.g., v1.0.0)

### Manual Workflow Trigger
You can manually run workflows from the GitHub Actions tab if needed.

## Best Practices

1. **Before pushing**:
   - Run `flutter analyze` locally
   - Run `flutter test` locally
   - Test build: `flutter build apk --release`

2. **For releases**:
   - Update version in `pubspec.yaml`
   - Update `CHANGELOG.md`
   - Create descriptive tag names
   - Edit release notes after auto-creation

3. **Branch protection**:
   - Consider requiring CI checks to pass before merging
   - Use pull requests for code review

## Customization

### Adding Steps
Edit `.github/workflows/flutter_ci.yml` to add:
- Code formatting checks
- Additional test suites
- Security scans
- Performance tests

### Modifying Release Notes
Edit the `body` section in `.github/workflows/release.yml` to customize the release template.

### Build Variants
Add different build configurations by modifying the build commands:
```yaml
- name: Build Debug APK
  run: flutter build apk --debug
```

## Support

For issues with the CI/CD setup:
1. Check the Actions tab for error logs
2. Verify your Flutter/Dart versions locally
3. Ensure all dependencies are up to date
4. Check GitHub Actions documentation for action-specific issues