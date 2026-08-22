# Gujju Learn — Offline Multilingual Learning App

A fully offline Flutter language-learning app. No backend, no Firebase,
no login, no internet connection required for the core learning
experience. All content ships locally as JSON assets.

## Flow

Splash → Country → App (UI) Language → Learning Language → Welcome →
Home (bottom-nav shell: Home / Learn / Practice / Progress / Settings)

The app deliberately separates two concepts:
- **App language** — the language the interface itself is shown in.
- **Learning language** — the language the lessons teach.

## Getting started

This archive contains the Dart source, assets, and `pubspec.yaml` only —
it does not include the generated native `android/`, `ios/`, `web/`,
etc. platform folders, since those are toolchain-generated and shouldn't
be hand-written. To run the app:

```bash
# 1. Unzip this project, then from inside the folder:
flutter create .          # scaffolds android/ios/web/etc. around the
                           # existing lib/, pubspec.yaml and assets/
                           # without overwriting your source files

flutter pub get
flutter run
```

If `flutter create .` prompts about an existing pubspec.yaml/lib, that's
expected — it only adds the missing platform directories.

## Getting an APK without installing Flutter locally

This project includes a ready-to-use GitHub Actions workflow at
`.github/workflows/build_apk.yml` that builds a release APK in the
cloud — no local Flutter/Android SDK install required:

1. Push this project to a new GitHub repository (public or private).
2. Go to the repo's **Actions** tab. The workflow runs automatically on
   a push to `main`, or trigger it manually via **Run workflow**.
3. When it finishes (a few minutes), open the run and download the
   **gujju-learn-apk** artifact from the "Artifacts" section at the
   bottom of the page. It contains a per-architecture split APK set
   (`app-armeabi-v7a-release.apk`, `app-arm64-v8a-release.apk`,
   `app-x86_64-release.apk`) — `arm64-v8a` is the right one for almost
   all modern Android phones.
4. Transfer the APK to your phone and install it (you'll need to allow
   "install from unknown sources" for whichever app you use to open
   it, since it isn't from the Play Store).

### Android TTS note
Some Android emulators ship without Gujarati/Hindi TTS voices installed.
If pronunciation doesn't play, install the language pack under
`Settings → Accessibility → Text-to-speech` on the device, or test on
Settings → Languages → check the languages available on your emulator
image, or a physical device with an updated Google TTS engine.

### About the Sanskrit locale
Almost no phone ships with a genuine `sa-IN` (Sanskrit) TTS voice, so
`languages.json` deliberately sets Sanskrit's `locale` to `hi-IN` —
the Hindi voice reads the same Devanagari script and gives an
intelligible (if not perfectly accented) pronunciation, which is far
more useful than a locale that will almost always report as
unavailable. If a genuine Sanskrit voice becomes available on more
devices later, just change that one `locale` value in
`assets/data/languages.json` — nothing else needs to change.

## Project structure

```
lib/
  core/
    constants/     # app constants, badge/gamification definitions
    providers/      # AppProvider (single ChangeNotifier for app state)
    router/         # named routes + onGenerateRoute
    theme/          # Material 3 theme, colors, typography
  data/
    models/         # CountryModel, LanguageModel, LearningItem/Category, UserProgress
    repositories/    # ContentRepository — loads/parses local JSON assets
    local/           # LocalStorageService — SharedPreferences wrapper
  services/
    tts_service.dart # TextToSpeechService — wraps flutter_tts
  features/
    splash/
    onboarding/      # country, app-language, learning-language, welcome
    home/            # bottom-nav shell + dashboard
    learning/        # category list, lesson (boxes), word detail
    practice/         # multiple-choice quiz
    progress/         # stats + badges
    settings/
  shared/widgets/     # CountryCard, LanguageCard, LessonCard, LearningBox,
                       # AppImage, AudioButton, ProgressCard, QuizOption
  main.dart
assets/
  data/                 # countries.json, languages.json, gujarati/hindi/english.json
  images/<language>/    # local image assets referenced by content JSON
```

## Adding a new country

Add an entry to `assets/data/countries.json` with its `code`, `name`,
`flag` emoji, and the `languageCodes` it offers. No UI/Dart changes
required — the grid picks it up automatically.

## Adding a new learning language

1. Add the language to `assets/data/languages.json` (locale is the
   TTS BCP-47 code, e.g. `es-ES`).
2. Create `assets/data/<language>.json` following the same shape as
   `gujarati.json` (categories → items, each with `character`, `word`,
   `translation`, `image`).
3. Set `"hasContent": true` and point `"contentFile"` at the new JSON
   file.
4. Add the new file to the `flutter: assets:` list in `pubspec.yaml`
   if you also add a new `assets/images/<language>/` folder.

## Content data shape

```json
{
  "language": "Gujarati",
  "code": "gu",
  "locale": "gu-IN",
  "categories": [
    {
      "id": "alphabet",
      "title": "Gujarati Alphabet",
      "icon": "abc",
      "items": [
        {
          "id": "gu_k",
          "character": "ક",
          "word": "કબૂતર",
          "translation": "Pigeon",
          "image": "assets/images/gujarati/kabutar.png"
        }
      ]
    }
  ]
}
```

Hundreds/thousands of items can be added by extending the `items`
arrays — the UI, models and repository already handle arbitrary sizes.

## Images

`AppImage` (in `shared/widgets/app_image.dart`) tries to load the
asset path from the content JSON and gracefully falls back to a
colored placeholder if the file is missing, so the app never crashes
on a missing image. Sample content currently ships with **placeholder
paths only** (no bundled artwork) — drop real PNGs into
`assets/images/<language>/` at the exact paths referenced in the JSON
to replace the placeholders; no code changes needed.

## Text-to-Speech

`TextToSpeechService` (in `services/tts_service.dart`) wraps
`flutter_tts`. The learning language's `locale` field automatically
drives pronunciation — screens never hardcode a locale. If a locale
isn't installed on the device, the word-detail screen shows a
friendly message instead of crashing.

## Progress & gamification

`UserProgress` is persisted via `SharedPreferences` as a single JSON
blob (`data/local/local_storage_service.dart`). It tracks selections,
completed words/categories, XP, streaks, quiz stats and unlocked
badges — all offline, nothing leaves the device. Reset is available
under Settings, with a confirmation dialog.

## State management

A single `AppProvider` (`ChangeNotifier` via `package:provider`) holds
all app state. This keeps things simple and avoids over-engineering
state management for an app of this scope.

## Known limitations / next steps

- Sample lesson content covers Gujarati, Hindi, English, and Sanskrit
  (Alphabet, Numbers, Colors, Animals categories); other languages are
  listed but marked "Coming soon" until content JSON is authored for
  them, per the extensible data model.
- No bundled illustration artwork — `AppImage` shows a graceful emoji
  placeholder until real images are added.
- Voice practice (speech recognition) was intentionally left out to
  keep the app 100% offline-safe without adding a heavy on-device STT
  dependency; the architecture leaves room to add it as an optional
  feature later without any backend.
