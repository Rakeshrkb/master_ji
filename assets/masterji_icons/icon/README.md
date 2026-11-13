# MasterJi app icons (B, B2, C)

Each folder holds one icon design:

| File | Use |
|---|---|
| play_icon_512.png | Play Console → Store listing → App icon (512×512, no transparency) |
| icon_1024.png | Master copy / iOS / anywhere a big square icon is needed |
| adaptive_foreground_432.png | Android adaptive icon foreground (transparent, logo inside the safe zone) |
| adaptive_background_432.png | Android adaptive icon background (teal gradient) |
| splash_logo_transparent_1024.png | Splash screen logo on the teal (#12A07A) background |

## Put the chosen icon in the Flutter app

1. Copy the folder you picked (e.g. `C`) to `assets/icon/` in the project.
2. Add to `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.4

flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/icon/icon_1024.png"
  adaptive_icon_background: "assets/icon/adaptive_background_432.png"
  adaptive_icon_foreground: "assets/icon/adaptive_foreground_432.png"
  min_sdk_android: 21
```

3. Run:

```bash
flutter pub get
dart run flutter_launcher_icons
flutter clean && flutter run
```

Uninstall the old app first if the launcher keeps showing the old icon (launchers cache icons).
