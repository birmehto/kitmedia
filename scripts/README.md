# Flutter Project Scripts

This directory contains useful bash scripts to streamline your Flutter development workflow.

## Available Scripts

### 🚀 Development Scripts

- **`dev_setup.sh`** - Sets up the development environment and checks dependencies
- **`run_dev.sh`** - Starts Flutter in development mode with hot reload
- **`flutter_clean_build.sh`** - Performs a complete clean and rebuild

### 🧪 Testing Scripts

- **`test_runner.sh`** - Runs tests with various options
  - `--coverage` - Generate test coverage report
  - `--integration` - Run integration tests
  - `--unit-only` - Run only unit tests

### 🏗️ Build Scripts

- **`build_release.sh`** - Builds production-ready APK and iOS app
- **`code_quality.sh`** - Runs linting, formatting, and code analysis

### 🛠️ Utility Scripts

- **`backup_project.sh`** - Creates a backup excluding build files
- **`git_hooks_setup.sh`** - Sets up useful git hooks for quality control

## Usage Examples

```bash
# Set up development environment
./scripts/dev_setup.sh

# Start development server
./scripts/run_dev.sh

# Run tests with coverage
./scripts/test_runner.sh --coverage

# Build release version
./scripts/build_release.sh

# Check code quality
./scripts/code_quality.sh

# Create project backup
./scripts/backup_project.sh

# Set up git hooks
./scripts/git_hooks_setup.sh
```

## Requirements

- Flutter SDK
- Bash shell
- Git (for git hooks)
- Optional: `jq` for JSON parsing in some scripts
- Optional: `lcov` for HTML coverage reports

All scripts are designed to be run from the project root directory.