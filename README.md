<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

# Gamification for Flutter

This package provides integration with gamification provided by The Logical Banya.

## Installation
You can install this package by adding this line to your pubspec.yaml
```yaml
  gamification:
    git:
      url: https://github.com/TheLogicalBanya/GamificationFlutter.git
      ref: main
```


## Usage
To use this package add this GamificationWebView widget to your screen and pass the credentials

```dart
  @override
Widget build(BuildContext context) {
  return const Scaffold(
    body: GamificationWebView(
      clientId: 'id',
      keyValue: 'value',
      userID: 'id',
      username: 'name',
      keyString: 'key',
      baseUrl: 'baseUrl',);
}

```

