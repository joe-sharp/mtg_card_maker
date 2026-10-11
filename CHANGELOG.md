## [Unreleased]

## [0.2.1] - 2026-10-11

### 🐛 Fixed
- `rules_text` is optional again in the Ruby API, YAML configuration, and CLI (`--rules-text`), so vanilla creatures and other cards without rules text can be generated. 0.2.0 required it as part of the new field validation. `name` and `type_line` remain required.
- `generate_sprite` reports `YAML file not found: <path>` for a missing YAML file again, instead of the generic "Failed to generate sprite sheet" error.

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
- **Symbols:** hybrid mana (`{W/U}`, `{2/W}`, `{C/W}`), Phyrexian mana (`{R/P}`, `{W/B/P}`), snow (`{S}`), energy (`{E}`), tap and untap (`{T}`, `{Q}`), `{X}`, and numeric symbols `{0}` through `{99}`, in mana costs and in rules text. Symbols in rules text are rendered inline.
- **Font embedding option:** `--embed-font` / `--no-embed-font` on the CLI and `embed_font:` in the Ruby API and YAML configuration.
- **Italic flavor text.**
- **Quieter, consistent CLI output:** messages go through a new `MtgCardMaker::Logger` (success and info to stdout, warnings and errors to stderr).
- **viewBox on generated SVGs**, so cards scale correctly when embedded or resized.
- SVG to WebP conversion script (`bin/svg_to_webp`, experimental, in the source repository only).

### 🔄 Changed
- **Fonts are embedded by default.** Generated cards now embed the card font as base64 (`embed_font` defaults to `true`; pass `--no-embed-font` or `embed_font: false` to opt out). Single-card SVGs are about 95 KB larger. Sprite sheets embed the font once, and only when a card sets `embed_font: true`.
- **Generated SVG markup:** the rules text CSS class `card-description` is now `card-rules-text`, and the text box gradient ids `<scheme>_description_gradient` are now `<scheme>_text_box_gradient`. Stylesheets that target the old names need updating.
- **Public Ruby API renames (affects direct users of these classes):**
  - `ColorScheme#description_gradient_*` → `#text_box_gradient_*`
  - `SvgGradientService.description_gradient_id` / `.define_description_gradient` → `.text_box_gradient_id` / `.define_text_box_gradient`
  - `IconService#available_colors` and `#icon_svg` → `#available_icon_types` and `#symbol_svg`; `IconService::ICON_SETS` → `IconService.icon_sets`
  - `LayerConfig#text_positioning_config` → `#text_box_config`; `#mana_cost_font_size`, `#mana_cost_icon_opacity`, `#mana_cost_text_y_offset`, and `#icon_opacity_config` were removed
  - `ColorScheme.silver` and `ManaCost::COLOR_MAP` were removed

### 🐛 Fixed
- Snow and energy symbols no longer corrupt the SVG output.
- Mana costs combining `X` and a number (for example `X3R`) render correctly.
- An empty YAML file passed to `generate_sprite` now exits with "Failed to generate sprite sheet" instead of `undefined method 'empty?' for nil`.

### 📚 Documentation
- README updated with hybrid, Phyrexian, snow, energy, tap, and numeric symbol references, and Markdown docs support; YARD documentation refreshed.

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
