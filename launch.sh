#!/bin/bash

# Pigeon Flutter App Launch Script
echo "🕊️  Starting Pigeon Flutter App..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo "Please install Flutter from https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check Flutter version
echo "📋 Checking Flutter version..."
flutter --version

# Clean and get dependencies
echo "🧹 Cleaning project..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

# Check for any issues
echo "🔍 Running Flutter doctor..."
flutter doctor

# Launch the app
echo "🚀 Launching Pigeon on Chrome..."
echo "🌐 The app will open in your default browser"
echo "⚡ Hot reload is enabled - make changes and see them instantly!"
echo ""
echo "🔧 To configure AI APIs:"
echo "   1. Open lib/core/providers/ai_provider.dart"
echo "   2. Replace the API key placeholders with your actual keys"
echo "   3. Save the file and hot reload"
echo ""
echo "📚 For setup instructions, see README.md"
echo ""

# Run the app
flutter run -d chrome --web-port=3000

echo "👋 Thanks for using Pigeon!"
