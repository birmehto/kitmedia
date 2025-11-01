#!/bin/bash

# Test Runner Script
# Runs different types of tests with coverage

set -e

# Default values
COVERAGE=false
INTEGRATION=false
UNIT_ONLY=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --coverage)
            COVERAGE=true
            shift
            ;;
        --integration)
            INTEGRATION=true
            shift
            ;;
        --unit-only)
            UNIT_ONLY=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--coverage] [--integration] [--unit-only]"
            echo "  --coverage     Generate test coverage report"
            echo "  --integration  Run integration tests"
            echo "  --unit-only    Run only unit tests"
            exit 0
            ;;
        *)
            echo "Unknown option $1"
            exit 1
            ;;
    esac
done

echo "🧪 Running Flutter tests..."

if [ "$UNIT_ONLY" = true ]; then
    echo "📋 Running unit tests only..."
    flutter test test/unit/
elif [ "$INTEGRATION" = true ]; then
    echo "🔗 Running integration tests..."
    flutter test integration_test/
else
    echo "📋 Running all tests..."
    if [ "$COVERAGE" = true ]; then
        echo "📊 Generating coverage report..."
        flutter test --coverage
        
        # Generate HTML coverage report if lcov is available
        if command -v genhtml &> /dev/null; then
            genhtml coverage/lcov.info -o coverage/html
            echo "📊 Coverage report generated at coverage/html/index.html"
        fi
    else
        flutter test
    fi
fi

echo "✅ Tests completed!"