#!/usr/bin/env sh
set -eu

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter is not installed or is not available in PATH."
  exit 1
fi

if [ ! -f android/gradlew ]; then
  flutter create --platforms=android .
fi

flutter pub get
echo "Android project is ready. Run: flutter run"
