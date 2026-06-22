# PflegeKompass agent guide

## Scope

- Build an iOS 17+ SwiftUI app for orientation and organization in German care situations.
- Do not provide medical diagnoses, treatment advice, binding legal advice, or definitive benefit decisions.
- Keep care documents and related data local by default. Never add analytics, sensitive logs, or an external document/AI transfer without explicit consent and a server-side abstraction.

## Architecture

- Use feature-based MVVM: keep SwiftUI views declarative; put rules, persistence, OCR, and networking behind models/services/repositories.
- Keep benefit rules structured and testable. Results must use cautious German wording (for example, “möglicherweise relevant” and “bitte prüfen”).
- No third-party dependency without an explicit product decision. Supabase and AI are integration seams only until backend configuration and privacy decisions exist.

## Design and accessibility

- Use German-first copy, Dynamic Type-friendly layouts, VoiceOver labels, strong contrast, and comfortable tap targets.
- Use the app palette: cream background, dark green/charcoal typography, restrained sage/gold accents.

## Validation

- On macOS, inspect schemes with `xcodebuild -list -project PflegeKompass.xcodeproj`.
- Build with `xcodebuild build -project PflegeKompass.xcodeproj -scheme PflegeKompass -sdk iphonesimulator`.
- Test with `xcodebuild test -project PflegeKompass.xcodeproj -scheme PflegeKompass -destination 'platform=iOS Simulator,name=iPhone 15'`.
- Do not claim a build/test passed unless its command ran successfully.

## Delivery

- Add unit tests for changed rule/OCR logic using synthetic data only.
- State privacy, legal-wording, accessibility, and environment limitations in the handoff.
