# Flutter Project Scripts

Essential scripts for Flutter development workflow.

## Available Scripts

- **`run_dev.sh`** - Start development server with hot reload
- **`flutter_clean_build.sh`** - Clean and rebuild project
- **`build_release.sh`** - Build production APK and AAB
- **`code_quality.sh`** - Run formatting and analysis
- **`version_upgrade.sh`** - Increment version and create git tag

## Usage

```bash
# Start development
./scripts/run_dev.sh

# Clean build
./scripts/flutter_clean_build.sh

# Build release
./scripts/build_release.sh

# Check code quality
./scripts/code_quality.sh

# Upgrade version (patch by default)
./scripts/version_upgrade.sh

# Upgrade minor version
./scripts/version_upgrade.sh minor

# Upgrade major version
./scripts/version_upgrade.sh major
```

Run from project root directory.