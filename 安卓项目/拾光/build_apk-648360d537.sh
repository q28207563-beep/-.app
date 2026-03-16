#!/usr/bin/env bash

# This script is used to build the Android APK for the Flutter project.

# Exit on error
set -e

# Change to the project directory
cd "$(dirname "${BASH_SOURCE[0]}")"

# Build the APK
flutter build apk --release

# Check if the build was successful
if [ $? -eq 0 ]; then
    echo "APK built successfully!"
    echo "APK file location: build/app/outputs/apk/release/app-release.apk"
else
    echo "Error: Failed to build APK"
    exit 1
fi