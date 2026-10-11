## [Unreleased]

## [0.2.1] - 2026-10-11

### 🐛 Fixed
- `rules_text` is optional again in the Ruby API, YAML configuration, and CLI (`--rules-text`), so vanilla creatures and other cards without rules text can be generated. 0.2.0 required it as part of the new field validation. `name` and `type_line` remain required.

## [0.2.0] - 2026-10-11

### 📜 License
- **Relicensed from CC BY-NC-ND 4.0 to the MIT License.** Version 0.1.0 remains available under its original license.
- Wizards of the Coast materials and the bundled Goudy Bookletter 1911 font (SIL OFL 1.1) are explicitly excluded from the MIT grant and keep their own terms (see `LICENSE.txt`).
- Generated cards no longer carry "Some rights reserved"; the footer now reads "MTG Card Maker by Joe Sharp". Cards and their content belong to their creators.
- Replaced the bundled Goudy Mediaeval DemiBold font, which is licensed for personal use only, with Goudy Bookletter 1911. Embedded card text renders slightly differently, and SVGs with embedded fonts are about 38 KB larger.

### ⚠️ Breaking Changes
- **Card validation.** The Ruby API and YAML configuration now raise `ArgumentError: Missing required fields` when `name`, `type_line`, or `rules_text` is missing or blank. In 0.1.0 these cards rendered without the missing text. The `rules_text` requirement was removed again in 0.2.1.
- **Dropped support for Ruby 3.2.** Ruby 3.3 or higher is now required (Ruby 3.2 reached end of life in March 2026).

### ✨ Features
- Hybrid and Phyrexian mana symbol support, with a new `IconFilenameService` for symbol mapping
- SVG to WebP conversion script (experimental)
- Italicized flavor text
- Improved SVG initialization and viewBox scaling in card rendering

### 📚 Documentation
- README updated with new symbols and Markdown docs support; YARD documentation refreshed

## [0.1.0] - 2025-07-12

### 🎯 Initial Release
### ✨ Features

#### 🎴 Card Generation
- **Single Card Generation**: Create individual MTG cards with full customization
- **Sprite Sheet Generation**: Generate multiple cards in a single SVG file for efficient printing and web display
- **YAML Configuration**: Define multiple cards in YAML files for batch processing

#### 📋 System Requirements
- Ruby 3.2 or higher
- Compatible with Ruby 3.5.0 (manually tested)
- Cross-platform support (macOS, Linux, Windows (untested))
