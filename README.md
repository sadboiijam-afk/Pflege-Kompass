# PflegeKompass

Ein deutschsprachiges, lokales SwiftUI-MVP zur Orientierung bei einer neuen Pflegesituation in Deutschland.

## Was im MVP funktioniert

- Pflegeprofil erfassen oder Demo starten
- „Pflegegrad erhalten – was jetzt?"-Flow
- Vorsichtiger Anspruchs-Check ohne Beträge oder verbindliche Zusagen
- Lokale To-dos und Vorlagen
- Apple-Vision-Dokumentenscan mit regelbasierter Einordnung und Frist-Hinweis
- Datenschutz- und Orientierungshinweise

## Öffnen und prüfen

Öffne `PflegeKompass.xcodeproj` in Xcode 15+ und wähle ein iOS-17+-Simulatorziel.

```sh
xcodebuild build -project PflegeKompass.xcodeproj -scheme PflegeKompass -sdk iphonesimulator
xcodebuild test -project PflegeKompass.xcodeproj -scheme PflegeKompass -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Datenschutz- und Backendstatus

Der MVP sendet keine Profil- oder Dokumentdaten an einen Server. Die Cloud- und KI-Schnittstellen sind nur abstrahierte, nicht konfigurierte Erweiterungspunkte. Vor Produktivnutzung sind insbesondere Einwilligung, Löschkonzept, Schlüsselverwaltung, Authentifizierung, RLS und ein Datenschutz-/Rechtsreview erforderlich.
