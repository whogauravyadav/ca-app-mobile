# Current Affairs — Mobile

Flutter Android app for competitive exam current affairs.

Repo: https://github.com/whogauravyadav/ca-app-mobile  
API: https://github.com/whogauravyadav/ca-app-web

## Change API URL (one file)

Edit only:

[`lib/core/app_config.dart`](lib/core/app_config.dart)

```dart
static const String apiRoot = 'https://ca.risebix.com';
```

Full mobile API base becomes: `https://ca.risebix.com/api/mobile`

## Branding / icon

- Logo asset: `assets/images/app_logo.png` (splash + login)
- Launcher icons: generated under `android/app/src/main/res/mipmap-*`
- To regenerate icons after replacing the PNG:

```bash
dart run flutter_launcher_icons
```

## Setup

```bash
flutter pub get
flutter run
```

**Demo student:** `student@currentaffairs.app` / `password`
