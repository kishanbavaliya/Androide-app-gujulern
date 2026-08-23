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

### Fixing "android/app/build.gradle... could not be found"
This means a stale or partial `android/` folder is already committed
to your git repo (commonly from testing `flutter create .` locally
before pushing). Flutter's scaffolding step won't overwrite an
existing platform folder, even a broken one, so the CI build fails
looking for a file that isn't there. The workflow now wipes and
regenerates platform folders on every run to prevent this, but you
also need to stop git from tracking any old copy already in your
repo:

```bash
git rm -r --cached android ios web linux macos windows 2>/dev/null
git commit -m "Stop tracking generated platform folders"
git push
```

`.gitignore` already excludes these folders going forward, so this is
a one-time cleanup.

### Note on build.gradle vs build.gradle.kts
Recent Flutter versions scaffold Android projects using Kotlin DSL
(`android/app/build.gradle.kts`) instead of the older Groovy
`build.gradle`. Both are valid and `flutter build apk` works with
either — the workflow's verification step checks for both filenames,
so this doesn't need any action on your part.

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

Each item now also carries an optional `emoji` field used for the
animated visual (see "Animated visuals" below):

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

## Animated visuals

The word-detail screen ("A for Apple", a number, a color, an animal)
renders through `AnimatedLearningVisual`
(`shared/widgets/animated_learning_visual.dart`), which gives every
item motion appropriate to its category — letters bounce, numbers
pulse, colors wiggle, animals gently float.

**Important scope note:** this app is fully offline with no bundled
photographic or GIF artwork (there's no way to fetch real animated
image files without a network connection at build time). "Animated"
is currently delivered as lightweight, built-in Flutter motion applied
to an emoji glyph per item (each item's `emoji` field in the content
JSON) — e.g. "A for Apple" shows 🍎 bouncing, not a photo/GIF of an
apple. This keeps the app instantly offline-safe with zero asset
weight while still fulfilling "animated visuals wherever helpful."

The architecture supports dropping in real animations later with
**zero code changes**: `AnimatedLearningVisual` accepts an optional
`lottieAsset` path (Lottie/`.json` animation files, via the bundled
`lottie` package) and falls back automatically — Lottie file if
present → static image if present → animated emoji. To upgrade a
specific item, add a `.json` Lottie file under
`assets/animations/<language>/` and pass its path as `lottieAsset`
when constructing the widget for that item (currently done in
`word_detail_screen.dart`).

The letter/number/color/animal **grid boxes** (`LessonScreen`)
intentionally stay static rather than animated — with up to 100 boxes
on screen at once (the Numbers lesson), animating all of them
simultaneously would hurt scroll performance and readability. Full
motion is reserved for the one-item-at-a-time detail view where it
adds the most delight without the cost.

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

- Gujarati, Hindi, English, and Sanskrit are fully populated: each has
  a complete Alphabet (all letters, "A for Apple" style with an
  animated glyph), Numbers 1–100, 12 Colors, and 25 Animals. Numbers
  1–100 in Hindi, Gujarati, and Sanskrit were individually sourced
  and verified against dedicated numeral references (linked in the
  PR/commit notes) since these languages use largely irregular
  number-word formation — not derived by pattern-guessing.
- Sanskrit's alphabet and vocabulary intentionally use a curated
  subset of consonants (skipping ङ ञ ण ट ठ ड ढ थ, which rarely begin
  simple standalone words in any of these three scripts) rather than
  inventing shaky example words just to fill every slot — the same
  simplification many children's Hindi/Sanskrit alphabet charts use.
- No bundled illustration artwork or GIF/photo animations — see
  "Animated visuals" above for what's actually shipped (built-in
  motion on emoji) versus the drop-in path for real Lottie files.
- Other languages beyond these four are listed in the picker but
  marked "Coming soon" until content JSON is authored for them, per
  the extensible data model.
- Voice practice (speech recognition) was intentionally left out to
  keep the app 100% offline-safe without adding a heavy on-device STT
  dependency; the architecture leaves room to add it as an optional
  feature later without any backend.
