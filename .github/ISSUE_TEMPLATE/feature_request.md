---
name: ✨ Feature Request
about: Suggest an idea for MTG Card Maker
title: '[FEATURE] '
labels: ['enhancement', 'needs-triage']
assignees: ['joe-sharp']
---

## 🎯 Feature Description

**A clear and concise description of what you'd like to see:**

## 🎴 Use Case

**Describe the problem this feature would solve:**

- **Current Limitation:** [e.g. "Can't create split cards"]
- **Desired Outcome:** [e.g. "Would like to create cards with split mana costs"]

## 🖼️ Visual Examples

**If applicable, include mockups or examples:**

- **Reference Images:** [e.g. "Similar to MTG split cards"]
- **Mockup:** [e.g. "Card should look like..."]
- **Inspiration:** [e.g. "Based on existing MTG card types"]

## 🔧 Technical Requirements

**Describe the technical implementation you envision:**

### New Properties
```yaml
# Example of new YAML properties
name: "Split Card"
type_line: "Instant // Sorcery"
mana_cost: "1(RU)(RU)"
split_cost: true
# ... other new properties
```

### CLI Commands
```bash
# Example of new CLI options
mtg_card_maker generate_card --split-cost --mana-cost="1(RU)(RU)"
```

## 🎨 Design Considerations

**How should this feature integrate with existing functionality:**

- **Color Schemes:** [e.g. "Should work with all existing colors"]
- **Border Types:** [e.g. "Should support gold borders"]
- **Sprite Sheets:** [e.g. "Should work in batch generation"]
- **Backward Compatibility:** [e.g. "Should not break existing cards"]

## 📝 Implementation Ideas

**If you have technical knowledge, suggest implementation approaches:**

- **File Structure:** [e.g. "New layer type for split cards"]
- **Dependencies:** [e.g. "May need additional SVG libraries"]
- **Testing Strategy:** [e.g. "New test fixtures needed"]

## 🧪 Acceptance Criteria

**Define what "done" looks like:**

- [ ] Feature works with single card generation
- [ ] Feature works with sprite sheet generation
- [ ] Feature works with YAML configuration
- [x] Feature has comprehensive test coverage
- [x] Feature is documented in README
- [x] Feature maintains backward compatibility

## 📋 Additional Context

**Add any other context, screenshots, or examples:**

- **Related Issues:** [e.g. #123, #456]
- **Community Interest:** [e.g. "Discussed in Discord"]
- **Similar Features:** [e.g. "Like feature X in other tools"]

## 📝 Checklist

- [ ] I have searched existing issues to avoid duplicates
- [ ] I have provided clear use cases and examples
- [ ] I have checked if this aligns with project goals

---

**Note:** This is a fan-made tool for creating custom MTG cards. Please ensure your feature request complies with Wizards of the Coast's Fan Content Policy and doesn't infringe on their intellectual property.
