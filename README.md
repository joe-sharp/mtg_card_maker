# MTG Card Maker

<p align=center>
  <img src="images/mtgcm_card.webp"
       alt="A card featuring artwork of a fiery dragon and anvil"
       width="300" />
</p>

A Ruby gem for creating high quality fan-made Magic: The Gathering cards. This tool generates custom MTG cards with authentic formatting, comprehensive mana cost support, and precise card layouts. Perfect for game designers, content creators, and MTG enthusiasts.


Please note this gem is for fan content creation only. **Using it commercially is a violation of the license.** If you have ideas for improvements, please create a feature request after reviewing the open issues here: https://github.com/joe-sharp/mtg_card_maker/issues

## Features
#### 🎨 Card Customization

**Core Card Properties:**
- **Card Name**: Customizable card titles with embedded font support
- **Mana Cost**: Complete MTG symbol support including hybrid, Phyrexian, and numeric costs
- **Type Line**: Customizable card types and subtypes (Creature, Instant, Sorcery, etc.)
- **Rules Text**: Rich text with automatic word wrapping and symbol replacement
- **Flavor Text**: Optional italicized flavor text with proper formatting
- **Power/Toughness**: Dynamic power/toughness display

**Visual Customization:**
- **Color Schemes**: 8 card colors (white, blue, black, red, green, colorless, gold, artifact)
- **Border Colors**: Customizable borders (white, black, gold, silver)
- **Art Integration**: Flexible artwork support via URLs or local paths
- **Font Embedding**: Base64 font embedding for portability

#### 🖼️ Advanced Sprite Sheet Features

**Performance Optimizations:**
- **Shared Assets**: Fonts, gradients, and masks defined once per sprite sheet
- **File Size Reduction**: Significantly smaller than individual card files
- **Layout Optimization**: Ideal for web applications, printing
and digital displays

**Layout Control:**
- **Cards Per Row**: Configurable grid layout (default: 4)
- **Spacing Control**: Pixel-perfect spacing between cards (default: 30px)
- **Dynamic Sizing**: Automatic sprite sheet dimensions based on card count

**Batch Processing:**
- **YAML Configuration**: Structured card definitions with validation
- **CLI Integration**: Streamlined command-line workflow
- **Error Handling**: Robust validation and helpful error messages

#### 🛠️ Technical Excellence

**SVG Generation:**
- **Vector Graphics**: High-quality SVG output suitable for any scale
- **Print Ready**: Optimized for both digital and print applications
- **Cross-Platform**: Compatible with all modern browsers and design software
  - NOTE: inline symbols in rule text may not render in some design software

**Development Infrastructure:**
- **Guard Integration**: Automated testing and quality monitoring
- **Status Summary**: Real-time development feedback with integrity checks
- **Comprehensive Testing**: 480+ tests with fixtures and helpers
- **Code Quality**: Zero RuboCop violations, consistent style

**Documentation:**
- **YARD Documentation**: 96.30% documented with local server
- **CLI Help**: Comprehensive command-line help and examples
- **Examples**: Multiple configuration examples and use cases

## 💽 Installation

### Prerequisites

This gem requires Ruby 3.2 or higher. The version of Ruby included with macOS is typically outdated and won't work. You can install a newer version of Ruby using tools like [asdf](https://asdf-vm.com/) (with the [Ruby plugin](https://github.com/asdf-vm/asdf-ruby)), [rbenv](https://github.com/rbenv/rbenv) or [RVM](https://rvm.io/). Note: This gem seems to work just fine on Ruby 3.5.0 but cannot be tested in CI currently.

Install the gem:
```bash
gem install mtg_card_maker
```

## Usage
### 🔧 Configuration Options

**Card Properties:**

Optionals without a default hide when omitted.
```yaml
name: "Card Name"                 # Required
type_line: "Creature - Dragon"    # Required
rules_text: "Card rules text"     # Required
mana_cost: 2RR                    # Optional
flavor_text: "Flavor text"        # Optional
power: 4                          # Optional
toughness: 4                      # Optional
color: red                        # Optional (default: colorless)
border_color: gold                # Optional (default: white)
art: path/to/art.jpg              # Optional
embed_font: false                 # Optional (default: true)
```

**Color Schemes Available:**
```rb
`artifact`  => Artifact cards (Brown, legacy)
`black`     => Black cards
`blue`      => Blue cards
`colorless` => Artifact/Land cards (Grey)
`gold`      => Multicolor cards (Metallic Gold)
`green`     => Green cards
`red`       => Red cards
`white`     => White cards
```

**Symbols Available for Mana Cost:**

**Mana Symbols:**
- `W` - White mana <img src="images/icons/white.svg" width="16" valign="middle" />
- `B` - Black mana <img src="images/icons/black.svg" width="16" valign="middle" />
- `R` - Red mana <img src="images/icons/red.svg" width="16" valign="middle" />
- `G` - Green mana <img src="images/icons/green.svg" width="16" valign="middle" />
- `U` - Blue mana <img src="images/icons/blue.svg" width="16" valign="middle" />
- `C` - Colorless mana <img src="images/icons/colorless.svg" width="16" valign="middle" />
- `S` - Snow mana <img src="images/icons/snow.svg" width="16" valign="middle" />
- `{C/P}` - Colorless Phyrexian mana <img src="images/icons/phyrexian/colorless.svg" width="20" valign="middle" />
- `{R/P}` - Red Phyrexian mana <img src="images/icons/phyrexian/red.svg" width="20" valign="middle" />
- `{G/P}` - Green Phyrexian mana <img src="images/icons/phyrexian/green.svg" width="20" valign="middle" />
- `{U/P}` - Blue Phyrexian mana <img src="images/icons/phyrexian/blue.svg" width="20" valign="middle" />
- `{B/P}` - Black Phyrexian mana <img src="images/icons/phyrexian/black.svg" width="20" valign="middle" />
- `{W/P}` - White Phyrexian mana <img src="images/icons/phyrexian/white.svg" width="20" valign="middle" />

**Advanced Mana Support:**
Hybrid and Phyrexian mana are now fully supported! See all the
notations below in the rule text section. The notation uses curly braces for complex symbols:
- `{R/G}` Red / Green Mana <img src="images/icons/hybrid/red-green.svg" width="20" valign="middle" />
- `{G/W/P}` Green / White Phyrexian Mana <img src="images/icons/phyrexian/green-white.svg" width="20" valign="middle" />

**Numeric Symbols:**
- `0` through `99` - Generic mana costs (0-99) <img src="images/icons/single-digit.svg" width="16" valign="middle" />
- `X` - X symbol <img src="images/icons/x.svg" width="16" valign="middle" />

**Combination Examples:**
- `16US` - 16 generic + 1 blue + 1 snow <img src="images/icons/double-digit.svg" width="16" valign="middle" /> <img src="images/icons/blue.svg" width="16" valign="middle" /> <img src="images/icons/snow.svg" width="16" valign="middle" />
- `XG` - X generic + 1 green <img src="images/icons/x.svg" width="16" valign="middle" /> <img src="images/icons/green.svg" width="16" valign="middle" />
- `X3R` - X generic + 3 generic + 1 red <img src="images/icons/x.svg" width="16" valign="middle" /> <img src="images/icons/single-digit.svg" width="16" valign="middle" /> <img src="images/icons/red.svg" width="16" valign="middle" />
- `3WU` - 3 generic + 1 white + 1 blue <img src="images/icons/single-digit.svg" width="16" valign="middle" /> <img src="images/icons/white.svg" width="16" valign="middle" /> <img src="images/icons/blue.svg" width="16" valign="middle" />
- `WU{B/P}RG` White, Blue, Phyrexian Black, Red, Green <img src="images/icons/white.svg" width="16" valign="middle" /> <img src="images/icons/blue.svg" width="16" valign="middle" /> <img src="images/icons/phyrexian/black.svg" width="20" valign="middle" /> <img src="images/icons/red.svg" width="16" valign="middle" /> <img src="images/icons/green.svg" width="16" valign="middle" />
- `X` - X generic only <img src="images/icons/x.svg" width="16" valign="middle" />
- `3` - 3 generic only <img src="images/icons/single-digit.svg" width="16" valign="middle" />
- `B` - black only <img src="images/icons/black.svg" width="16" valign="middle" />

**Symbols Available in Rules Text:**

You can use MTG symbols in your rules text by wrapping them in curly braces "{C}". The following symbols are supported:

**Mana Symbols:**
- `{W}` - White mana <img src="images/icons/white.svg" width="16" valign="middle" />
- `{B}` - Black mana <img src="images/icons/black.svg" width="16" valign="middle" />
- `{R}` - Red mana <img src="images/icons/red.svg" width="16" valign="middle" />
- `{G}` - Green mana <img src="images/icons/green.svg" width="16" valign="middle" />
- `{U}` - Blue mana <img src="images/icons/blue.svg" width="16" valign="middle" />
- `{C}` - Colorless mana <img src="images/icons/colorless.svg" width="16" valign="middle" />
- `{S}` - Snow mana symbol <img src="images/icons/snow.svg" width="16" valign="middle" />
- `{C/P}` - Colorless Phyrexian mana <img src="images/icons/phyrexian/colorless.svg" width="20" valign="middle" />
- `{R/P}` - Red Phyrexian mana <img src="images/icons/phyrexian/red.svg" width="20" valign="middle" />
- `{G/P}` - Green Phyrexian mana <img src="images/icons/phyrexian/green.svg" width="20" valign="middle" />
- `{U/P}` - Blue Phyrexian mana <img src="images/icons/phyrexian/blue.svg" width="20" valign="middle" />
- `{B/P}` - Black Phyrexian mana <img src="images/icons/phyrexian/black.svg" width="20" valign="middle" />
- `{W/P}` - White Phyrexian mana <img src="images/icons/phyrexian/white.svg" width="20" valign="middle" />

**Hybrid Mana Symbols:**

**White hybrid:** `{W/B}` `{W/R}` `{W/G}` `{W/U}` - <img src="images/icons/hybrid/white-black.svg" width="20" valign="middle" /> <img src="images/icons/hybrid/white-red.svg" width="20" valign="middle" /> <img src="images/icons/hybrid/white-green.svg" width="20" valign="middle" /> <img src="images/icons/hybrid/white-blue.svg" width="20" valign="middle" />

**Black hybrid:** `{B/W}` `{B/R}` `{B/G}` `{B/U}` - <img src="images/icons/hybrid/black-white.svg" width="20" valign="middle" /> <img src="images/icons/hybrid/black-red.svg" width="20" valign="middle" /> <img src="images/icons/hybrid/black-green.svg" width="20" valign="middle" /> <img src="images/icons/hybrid/black-blue.svg" width="20" valign="middle" />

**Red hybrid:** `{R/W}` `{R/B}` `{R/G}` `{R/U}` - <img src="images/icons/hybrid/red-white.svg" width="20" valign="middle" /> <img src="images/icons/hybrid/red-black.svg" width="20" valign="middle" /> <img src="images/icons/hybrid/red-green.svg" width="20" valign="middle" /> <img src="images/icons/hybrid/red-blue.svg" width="20" valign="middle" />

**Green hybrid:** `{G/W}` `{G/B}` `{G/R}` `{G/U}` - <img src="images/icons/hybrid/green-white.svg" width="20" valign="middle" /> <img src="images/icons/hybrid/green-black.svg" width="20" valign="middle" /> <img src="images/icons/hybrid/green-red.svg" width="20" valign="middle" /> <img src="images/icons/hybrid/green-blue.svg" width="20" valign="middle" />

**Blue hybrid:** `{U/W}` `{U/B}` `{U/R}` `{U/G}` - <img src="images/icons/hybrid/blue-white.svg" width="20" valign="middle" /> <img src="images/icons/hybrid/blue-black.svg" width="20" valign="middle" /> <img src="images/icons/hybrid/blue-red.svg" width="20" valign="middle" /> <img src="images/icons/hybrid/blue-green.svg" width="20" valign="middle" />

**"Two-brids":** `{2/W}` `{2/B}` `{2/R}` `{2/G}` `{2/U}` - <img src="images/icons/hybrid/2-white.svg" width="20" valign="middle" /> <img src="images/icons/hybrid/2-black.svg" width="20" valign="middle" /> <img src="images/icons/hybrid/2-red.svg" width="20" valign="middle" /> <img src="images/icons/hybrid/2-green.svg" width="20" valign="middle" /> <img src="images/icons/hybrid/2-blue.svg" width="20" valign="middle" />

**Colorless hybrid:** `{C/W}` `{C/B}` `{C/R}` `{C/G}` `{C/U}` - <img src="images/icons/hybrid/colorless-white.svg" width="20" valign="middle" /> <img src="images/icons/hybrid/colorless-black.svg" width="20" valign="middle" /> <img src="images/icons/hybrid/colorless-red.svg" width="20" valign="middle" /> <img src="images/icons/hybrid/colorless-green.svg" width="20" valign="middle" /> <img src="images/icons/hybrid/colorless-blue.svg" width="20" valign="middle" />

**Phyrexian Hybrid Mana Symbols:**

**White Phyrexian hybrid:** `{W/B/P}` `{W/R/P}` `{W/G/P}` `{W/U/P}` - <img src="images/icons/phyrexian/white-black.svg" width="20" valign="middle" /> <img src="images/icons/phyrexian/white-red.svg" width="20" valign="middle" /> <img src="images/icons/phyrexian/white-green.svg" width="20" valign="middle" /> <img src="images/icons/phyrexian/white-blue.svg" width="20" valign="middle" />

**Black Phyrexian hybrid:** `{B/W/P}` `{B/R/P}` `{B/G/P}` `{B/U/P}` - <img src="images/icons/phyrexian/black-white.svg" width="20" valign="middle" /> <img src="images/icons/phyrexian/black-red.svg" width="20" valign="middle" /> <img src="images/icons/phyrexian/black-green.svg" width="20" valign="middle" /> <img src="images/icons/phyrexian/black-blue.svg" width="20" valign="middle" />

**Red Phyrexian hybrid:** `{R/W/P}` `{R/B/P}` `{R/G/P}` `{R/U/P}` - <img src="images/icons/phyrexian/red-white.svg" width="20" valign="middle" /> <img src="images/icons/phyrexian/red-black.svg" width="20" valign="middle" /> <img src="images/icons/phyrexian/red-green.svg" width="20" valign="middle" /> <img src="images/icons/phyrexian/red-blue.svg" width="20" valign="middle" />

**Green Phyrexian hybrid:** `{G/W/P}` `{G/B/P}` `{G/R/P}` `{G/U/P}` - <img src="images/icons/phyrexian/green-white.svg" width="20" valign="middle" /> <img src="images/icons/phyrexian/green-black.svg" width="20" valign="middle" /> <img src="images/icons/phyrexian/green-red.svg" width="20" valign="middle" /> <img src="images/icons/phyrexian/green-blue.svg" width="20" valign="middle" />

**Blue Phyrexian hybrid:** `{U/W/P}` `{U/B/P}` `{U/R/P}` `{U/G/P}` - <img src="images/icons/phyrexian/blue-white.svg" width="20" valign="middle" /> <img src="images/icons/phyrexian/blue-black.svg" width="20" valign="middle" /> <img src="images/icons/phyrexian/blue-red.svg" width="20" valign="middle" /> <img src="images/icons/phyrexian/blue-green.svg" width="20" valign="middle" />

**Numeric Symbols:**
- `{0}` through `{99}` - Generic mana costs (0-99) <img src="images/icons/single-digit.svg" width="16" valign="middle" />
- `{X}` - X symbol <img src="images/icons/x.svg" width="16" valign="middle" />

**Special Symbols:**
- `{T}` - Tap symbol <img src="images/icons/tap.svg" width="16" valign="middle" />
- `{Q}` - Untap symbol <img src="images/icons/untap.svg" width="16" valign="middle" />
- `{E}` - Energy symbol <img src="images/icons/energy.svg" width="16" valign="middle" />

**Example Usage:**
```yaml
rules_text: "{T}: Add {W} or {U} to your mana pool."
```
<p align=center>
  <img src="images/icons/tap.svg"
       alt="{T}" width="16" valign="middle" />
  : Add
  <img src="images/icons/white.svg"
       alt="{W}" width="16" valign="middle" />
  or
  <img src="images/icons/blue.svg"
       alt="{U}" width="16" valign="middle" />
  to your mana pool
</p>

## 🧪 Basic Examples

### Single Card

**Generate:**
```bash
mtg_card_maker generate_card \
  --name="Lightning Bolt" \
  --mana-cost=R \
  --type-line=Instant \
  --rules-text="Deal 3 damage to any target." \
  --color=red
```

**Add to YAML:**
```bash
mtg_card_maker add_card deck.yml \
  --name="Counterspell" \
  --mana-cost="UU" \
  --type-line="Instant" \
  --rules-text="Counter target spell." \
  --color="blue"
```
*Shortcuts:*
- `g` or `gc` for `generate_card`
- `a` or `ac` for `add_card`

### Generate a Sprite Sheet

For printing or displaying multiple cards on a webpage, using a sprite sheet is recommended. This approach embeds fonts and gradients once per sheet instead of repeating them for each individual card, improving file size and loading efficiency.
Generate a sprite sheet from YAML configuration:

**Required Arguments:**
- `YAML_FILE`: Path to YAML configuration file
- `OUTPUT_FILE`: Output filename for the sprite sheet

**Optional Options:**
- `--cards-per-row`: Number of cards per row in sprite (default: 4)
- `--spacing`: Spacing between cards in pixels (default: 30)


```bash
mtg_card_maker generate_sprite deck.yml sprite_sheet.svg \
--cards-per-row=3 --spacing=5
```
*Shortcuts:*
- `gs` or `gcs` for `generate_sprite`

### 🖼️ Experimental WebP Conversion

**⚠️ Experimental Feature - Mac Only**

The gem includes experimental support for converting SVG cards to WebP format using Chrome's headless mode. This feature is currently **Mac-only** and requires specific dependencies.

**Why?:**
It seems a lot more user-friendly for use in things like this README.md file. The file size is bigger and it can't scale so I wouldn't use this option unless something in the SVG isn't working with whatever you are trying to do. You should also report that at https://github.com/joe-sharp/mtg_card_maker/issues . Thanks in advance!

**Prerequisites:**
- **macOS**: Chrome must be installed at `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome`
- **cwebp**: Google's WebP encoder must be installed (install via Homebrew: `brew install webp`)

**Usage:**
```bash
# Convert a single SVG card to WebP
bin/svg_to_webp output_card.svg

# Convert any SVG file to WebP
bin/svg_to_webp path/to/your/card.svg
```

**Features:**
- **Lossless Conversion**: High-quality WebP output with transparency support
- **Automatic Cropping**: Removes Chrome's window chrome for clean card output
- **Optimized Dimensions**: Outputs at 630x880 pixels (standard MTG card ratio)
- **Transparent Background**: Preserves transparency for web and design use

**Caveats:**
- **Platform Limitation**: Currently only works on macOS with Chrome installed
- **Dependency Required**: Requires `cwebp` command-line tool for final processing
- **Experimental Status**: May have issues with complex SVG content or Chrome updates
- **File Size**: WebP files may be larger than optimized SVGs for simple cards

**Future Plans:**
- Cross-platform support (Windows, Linux)
- Integration with main CLI commands

## 🔮 Examples

<p>
<img align=right
     src="images/joe-sharp_card.webp"
     alt="A card featuring artwork of a bearded man writing on a magical scroll with a feather pen"
     width="300" />
</p>

**Generate a creature card:**

```bash
mtg_card_maker generate_card \
  --name="Joe Sharp" \
  --mana-cost=3UR \
  --type-line="Engineer - Fullstack" \
  --rules-text='When Joe Sharp enters the battlefield, all malfunctioning computers begin working.\nWhenever you cast a Red spell, draw a card.\n\n{E}: Debug program. Ignore this cost, if a Coffee token is in play.\n\n' \
  --flavor-text='\"Nothing is true, everything is a string.\"\n\t\t\t\t- The ENV Creed' \
  --power=3 \
  --toughness=3 \
  --border-color=gold \
  --color=blue \
  --art=images/joe.webp
```



**Add multiple cards to a YAML file:**
```bash
mtg_card_maker add_card deck.yml --name="Lightning Bolt" --mana-cost="R" --type-line="Instant" --rules-text="Deal 3 damage to any target." --color="red"

mtg_card_maker add_card deck.yml --name="Counterspell" --mana-cost="UU" --type-line="Instant" --rules-text="Counter target spell." --color="blue"
```

**Generate a sprite sheet from YAML:**
```bash
mtg_card_maker generate_sprite deck.yml sprite_sheet.svg --cards-per-row=3 --spacing=20
```

## 🚧 Development

### Setup

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

### Development Workflow with Guard

This project uses [Guard](https://github.com/guard/guard) for automated testing and code quality checks during development. Guard monitors file changes and automatically runs relevant tests and checks.

**Start Guard:**
```bash
bundle exec guard
```

**What Guard monitors:**
- **RuboCop**: Automatically checks code style when Ruby files change
- **RSpec**: Runs tests when spec files or corresponding lib files change
- **Status Summary**: Monitors changes and runs `bin/status_summary` to check card generation integrity (end-to-end tests)

**Guard Output:**
- RuboCop results are saved to `tmp/rubocop_status.txt`
- RSpec results are saved to `tmp/rspec_status.txt`
- Status summary provides real-time feedback on code quality and card generation

**Development Benefits:**
- **Zero Configuration**: Just run `bundle exec guard` and start coding
- **Instant Feedback**: See test results and code quality status immediately
- **Regression Prevention**: Automatic integrity checks prevent breaking changes
- **Productivity Boost**: Focus on coding while Guard handles quality assurance

### Status Summary Script

The `bin/status_summary` script provides a comprehensive development status overview, it is meant to only be run by guard.

**What it does:**
- Generates test cards and sprite sheets to verify functionality
- Compares generated output against expected fixtures
- Checks for unexpected changes in SVG files
- Displays status indicators, requires you run with guard:
  - ✅ RuboCop violations (with count if any)
  - ✅ RSpec test failures (with count if any)
  - ✅ Card generation integrity
  - ✅ Sprite sheet generation integrity

**Status Indicators:**
- `✅` - All good
- `⚠️` - Issues detected (with count)
- `❌` - Failures
- `🔄` - Unexpected changes detected

### Interactive Development

**Console:**
```bash
bin/console
```

Start an interactive Ruby console with the gem loaded for experimentation.

**Manual Testing:**
Note: just use guard
```bash
# Run all tests
bundle exec rspec

# Check code style
bundle exec rubocop

# Generate test cards

# See examples above, but you will need to use bin/mtg_card_maker from the project root to use the in-development code.

# Or run `bundle exec guard` and monitor output_card.svg and color_cards_sprite.svg for changes, it is far better, really.
```

## 🏗️ Technical Architecture

**Design Patterns & Best Practices:**
- **Layered Architecture**: Clean separation between card components (art, text, frame, border)
- **Factory Pattern**: `LayerFactory` provides flexible layer creation
- **Service-Oriented Design**: Dedicated services for icons, sprites, gradients, and text rendering
- **Single Responsibility**: Each class has a focused, well-defined purpose
- **Dependency Injection**: Clean interfaces and testable components

**Advanced Features:**
- **Symbol Replacement Engine**: Sophisticated parsing of MTG notation with regex optimization
- **Dynamic Gradient Generation**: Real-time SVG gradient creation for card colors
- **Font Embedding System**: Base64 font embedding for portable SVG files
- **Sprite Sheet Optimization**: Shared asset management reducing file sizes considerably
- **Comprehensive Validation**: Robust error handling and input validation throughout

## 📰 Documentation

### API Documentation

The gem includes comprehensive YARD documentation for all classes and methods. You can generate and view the documentation locally:

**Generate Documentation:**
```bash
bundle exec yard doc
```

**Serve Documentation Locally:**
```bash
bundle exec yard server
```
Then visit `http://localhost:8808` to browse the documentation.



### Installation and Release

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## 🤝🏻 Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/joe-sharp/mtg_card_maker. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/joe-sharp/mtg_card_maker/blob/main/CODE_OF_CONDUCT.md).

## 🪪 License

<a href="https://projects.joe-sharp.com/mtg_card_maker">MTG Card Maker</a> © 2025 by <a href="https://github.com/joe-sharp/mtg_card_maker">Joe Sharp</a> is licensed under <a href="https://creativecommons.org/licenses/by-nc-nd/4.0/">CC BY-NC-ND 4.0</a> <img src="https://mirrors.creativecommons.org/presskit/icons/cc.svg" width="20" valign=bottom><img src="https://mirrors.creativecommons.org/presskit/icons/by.svg" width="20" valign=bottom><img src="https://mirrors.creativecommons.org/presskit/icons/nc.svg" width="20" valign=bottom><img src="https://mirrors.creativecommons.org/presskit/icons/nd.svg" width="20" valign=bottom>

The gem is available as open source under the terms of this license.

## ©️ Copyright

© 2025 Joe Sharp. Some rights reserved.
MTG Card Maker is unofficial Fan Content permitted under the [Fan Content Policy.](https://company.wizards.com/en/legal/fancontentpolicy) Not approved/endorsed by Wizards. Portions of the materials used are property of Wizards of the Coast. © Wizards of the Coast LLC.

The removal or alteration of copyright notices, attributions, and/or QR codes from generated images constitutes a material breach of the license agreement. All copyright notices and identifying marks must remain intact and unmodified in accordance with the terms of use.

## 🧙🏻 Code of Conduct

Everyone interacting in the MTG Card Maker project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/joe-sharp/mtg_card_maker/blob/main/CODE_OF_CONDUCT.md).
