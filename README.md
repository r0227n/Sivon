# Sivon

Sivon is a macOS 14+ SwiftUI task app focused on today's tasks, overdue tasks, and quick rescheduling.

## Development

Generate the Xcode project:

```sh
xcodegen generate
```

Build and test from the command line:

```sh
xcodebuild -project Sivon.xcodeproj -scheme Sivon -destination 'platform=macOS' -skipMacroValidation CODE_SIGNING_ALLOWED=NO test
```

The app uses SwiftUI, TCA, SwiftData, and `Resources/Localizable.xcstrings` for English and Japanese localization.
