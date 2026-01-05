# Repository Guidelines

## Project Structure & Module Organization
- `lib/main.dart` is the app entry point. Shared app code lives in `lib/core`, `lib/const`, `lib/data`, and `lib/widget`.
- Feature code is organized under `lib/src/features/<domain>/...` (e.g., `lib/src/features/energy`). Cross-cutting code also appears in `lib/src/core`.
- Localization files are in `lib/l10n` and configured by `l10n.yaml`; generated output is written back into `lib/l10n`.
- Assets live under `assets/` with subfolders like `assets/icons/` and `assets/lottie/`, referenced in `pubspec.yaml`.
- Platform shells are in `android/` and `ios/`. Build outputs are in `build/` and should not be edited manually.
- Tests live in `test/`, with feature-related tests under `test/src/...`.

## Build, Test, and Development Commands
- `flutter pub get` fetches dependencies.
- `flutter run` runs the app on a connected device or emulator.
- `flutter test` runs the test suite; target a file with `flutter test test/widget_test.dart`.
- `flutter analyze` runs static analysis (configured by `analysis_options.yaml`).
- `dart format .` formats Dart code.
- `dart run build_runner build --delete-conflicting-outputs` regenerates code for Freezed/JSON.
- `flutter gen-l10n` regenerates localization output from ARB files.

## Coding Style & Naming Conventions
- Use 2-space indentation and keep files formatted with `dart format`.
- Linting follows `flutter_lints` plus `dart_code_metrics` rules in `analysis_options.yaml`.
- File and directory names use `lower_snake_case`; classes use `UpperCamelCase`; variables/functions use `lowerCamelCase`.

## Testing Guidelines
- Tests use `flutter_test` and `mocktail` for mocking.
- Name tests with the `_test.dart` suffix and place them under `test/` mirroring feature paths when possible.
- There is no explicit coverage gate; add tests for new business logic or regressions.

## Commit & Pull Request Guidelines
- Existing commit history uses short, lowercase messages (e.g., `post`, `yolla`). Keep messages concise and action-oriented.
- PRs should include a brief summary, testing notes, and screenshots for UI changes when relevant.
