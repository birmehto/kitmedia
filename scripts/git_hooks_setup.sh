#!/bin/bash

# Git Hooks Setup Script
# Sets up useful git hooks for the project

set -e

echo "🪝 Setting up Git hooks..."

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

echo "🔍 Running pre-commit checks..."

# Check if there are any Dart files to commit
if git diff --cached --name-only | grep -q '\.dart$'; then
    # Format Dart files
    echo "✨ Formatting Dart files..."
    git diff --cached --name-only | grep '\.dart$' | xargs dart format

    # Add formatted files back to staging
    git diff --cached --name-only | grep '\.dart$' | xargs git add

    # Run quick analysis
    echo "🔬 Running Dart analysis..."
    flutter analyze --no-fatal-infos

    # Run tests
    echo "🧪 Running tests..."
    flutter test --no-sound-null-safety || {
        echo "❌ Tests failed. Commit aborted."
        exit 1
    }
fi

echo "✅ Pre-commit checks passed!"
EOF

# Pre-push hook
cat > .git/hooks/pre-push << 'EOF'
#!/bin/bash

echo "🚀 Running pre-push checks..."

# Run full test suite
echo "🧪 Running full test suite..."
flutter test || {
    echo "❌ Tests failed. Push aborted."
    exit 1
}

# Check for TODO/FIXME comments in staged files
if git diff origin/main --name-only | grep -q '\.dart$'; then
    TODO_COUNT=$(git diff origin/main --name-only | grep '\.dart$' | xargs grep -n "TODO\|FIXME" | wc -l)
    if [ "$TODO_COUNT" -gt 0 ]; then
        echo "⚠️  Found $TODO_COUNT TODO/FIXME comments in changed files"
        echo "Consider addressing them before pushing"
    fi
fi

echo "✅ Pre-push checks passed!"
EOF

# Make hooks executable
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/pre-push

echo "✅ Git hooks installed successfully!"
echo "💡 Hooks will run automatically on commit and push"