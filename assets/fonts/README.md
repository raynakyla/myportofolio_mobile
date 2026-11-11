# Offline typography

Playfair Display and DM Sans are a new visual choice for the Flutter app,
approved by the owner. They are not the original Django website fonts;
the website uses a platform-dependent system sans-serif stack.

Unmodified variable TTF files downloaded from the official Google Fonts
repository on 2026-11-11:

- https://github.com/google/fonts/tree/main/ofl/playfairdisplay
  - `PlayfairDisplay[wght].ttf` → `playfair_display/PlayfairDisplay-Variable.ttf`
  - `PlayfairDisplay-Italic[wght].ttf` → `playfair_display/PlayfairDisplay-Italic-Variable.ttf`
  - License: `playfair_display/OFL.txt` (SIL OFL 1.1)
- https://github.com/google/fonts/tree/main/ofl/dmsans
  - `DMSans[opsz,wght].ttf` → `dm_sans/DMSans-Variable.ttf`
  - License: `dm_sans/OFL.txt` (SIL OFL 1.1)

The same variable asset is registered for each requested weight in pubspec.yaml.
DM Sans supplies body weights 400, 600, and 700. Playfair Display supplies
heading weights 600 and 700, plus 600 italic for the brand only.
Flutter bundles these assets; no runtime font download or font package is used.
