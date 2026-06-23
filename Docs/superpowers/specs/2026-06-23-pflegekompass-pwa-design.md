# PflegeKompass Cloudflare PWA design

## Purpose

Build a mobile-first, installable PWA for relatives in Germany who need orientation after a Pflegegrad decision or during a care-related process. The app gives clear next steps and cautious benefit orientation; it does not give medical, binding legal, or entitlement advice.

## Delivery boundary

- The Vite + React + TypeScript application lives at the repository root.
- Cloudflare Pages contract: `npm run build` produces `dist/`.
- No backend, authentication, payments, analytics, external AI, document upload, or secrets.
- The native SwiftUI prototype remains in the repository as a future reference and is not changed by the PWA.

## Experience

The visual system follows the approved generated references: warm cream canvas; dark forest-green/charcoal typography; soft sage selected states; limited muted-gold emphasis; white rounded surfaces; large mobile targets; restrained borders and shadows. It is an iPhone-first single-column app with a fixed bottom navigation after onboarding.

### Screens and navigation

1. **Welcome** — claim, short orientation explanation, mandatory disclaimer, and start action.
2. **Onboarding wizard** — situation, Pflegegrad, care location, provider setup, and existing-benefits checklist. One primary forward action and explicit back action maintain focus.
3. **Dashboard** — care-profile summary, grouped benefit orientation (`Wahrscheinlich relevant`, `Bitte prüfen`, `Aktuell unklar`), generated to-dos, and disclaimer card.
4. **To-dos** — checkable tasks generated from the profile, with local completion state.
5. **Brief verstehen** — document-type selection only; deterministic mock explanation; no file input and no data transfer.
6. **Vorlagen** — five cautious writing templates; copy-to-clipboard action with local success feedback.
7. **Mehr** — privacy explanation and `Profil zurücksetzen` confirmation.

## State and persistence

`CareProfile` stores the situation, care grade, location, provider setup, selected existing benefits, and creation date. `TaskItem` stores generated task data and completion state. A versioned localStorage adapter persists this state under a single app-owned key. Reset deletes that key and returns to the welcome screen.

No sensitive content is logged, uploaded, or fetched. Document mock explanations are deterministic in-memory data keyed by a user-selected document type.

## Rule architecture

- `src/domain/models.ts`: typed domain names, benefit/result/task/template document models.
- `src/domain/benefitRules.ts`: pure function from care profile to cautious benefit results. It never emits a legal conclusion or an amount.
- `src/domain/taskRules.ts`: pure function from care profile and results to practical tasks. A common Pflegegrad 2–5 home-care profile has at least five tasks.
- UI consumes those results through React state and does not contain scattered eligibility logic.

Rules use only the product-safe labels `wahrscheinlich relevant`, `bitte prüfen`, `aktuell unklar`, and `möglicherweise relevant`, paired with “bitte mit Pflegekasse oder Pflegeberatung klären”.

## Component structure

```
src/
  app/                 App shell and local state coordination
  components/          Buttons, selectable rows, cards, status badges, bottom navigation
  features/
    onboarding/        Wizard screens
    dashboard/         Dashboard composition
    benefits/          Benefit groups and cards
    tasks/             To-do list
    documents/         Local mock letter explanation
    templates/         Template cards and copy interaction
    settings/          Privacy and reset controls
  domain/              Pure models and rules
  storage/             LocalStorage adapter
  styles/              Global tokens and responsive CSS
```

## PWA and deployment

- Include `public/manifest.webmanifest`, placeholder icons, a service worker, theme/background colors, mobile viewport metadata, and Apple standalone meta tags.
- README documents installation, development, build, Cloudflare Pages settings, iPhone Home Screen installation, privacy, and the future native-iOS boundary.
- Cloudflare Pages uses the repository root, build command `npm run build`, and output directory `dist`.

## Validation

- Unit-test pure benefit and task rules with common home care, unknown care grade, provider setup, and care-home scenarios.
- Run `npm run build` after implementation.
- Use the in-app browser to verify onboarding through dashboard, local persistence, reset, mock document explanation, template copying, and a phone-width layout.
- Review the rendered PWA against the accepted dashboard and onboarding references.
