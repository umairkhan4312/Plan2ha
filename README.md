# Smart Floor Plan – Home Assistant

A simple Flutter Android application that converts an architectural floor-plan file into a PNG suitable for a Home Assistant dashboard.

## Two-step workflow

1. Choose a PDF, JPG, JPEG, or PNG floor plan.
2. Tap **Generate PNG**, then save or share the result.

For a multi-page PDF, page 1 is selected automatically and the user can choose another page when needed.

## Architectural guarantee

The application never uses generative AI and never redraws, moves, guesses, or improves walls, doors, windows, rooms, boundaries, or dimensions. A PDF page is rendered directly; a PNG is copied without alteration; and JPG/JPEG is only re-encoded as PNG.

## Features

- Native Flutter Android application
- Imports PDF, PNG, JPG, and JPEG
- High-resolution PDF rendering (3× page resolution)
- PDF page selection
- Zoomable result preview
- Save/share generated PNG
- Material 3 light and dark themes
- No account, server, or API key required
- Local, on-device processing

## Project structure

```text
lib/
  models/       File and result data
  screens/      Two-step converter interface
  services/     File selection and conversion
  app.dart      Theme and application shell
  main.dart     Application entry point
```

## Run the project

1. Install the current stable Flutter SDK and Android Studio.
2. Clone or download this repository.
3. Open a terminal in the project folder.
4. Generate any SDK-specific Android wrapper files, without replacing the Dart source:

```bash
flutter create --platforms=android .
```

5. Run:

```bash
flutter pub get
flutter run
```

## Build an installable Android APK

```bash
flutter build apk --release
```

The APK will be created at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

### Build automatically on GitHub

Upload the project to GitHub. Open **Actions → Build Android APK → Run workflow**. When it finishes, download the `smart-floor-plan-apk` artifact. No local Flutter installation is required for this method.

## Privacy

Files remain on the phone. The app does not upload floor plans to a cloud service.
