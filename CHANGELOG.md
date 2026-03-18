# Changelog

## [Unreleased]

## [0.1.1] - 2026-03-18

### Changed
- Enforce STATE_TYPES at FrictionEngine method boundaries: `set_current_state`, `set_friction`, `get_friction`, `attempt_transition`, `force_transition` return nil for invalid state values
- Enforce CLAIM_VERDICTS at VigilanceEngine#adjudicate_claim: returns nil for invalid verdict values
- Updated specs to use valid STATE_TYPES values; added 8 new enum validation specs

## [0.1.0] - 2026-03-18

### Added
- Initial release as domain consolidation gem
- Consolidated source extensions into unified domain gem under `Legion::Extensions::Agentic::<Domain>`
- All sub-modules loaded from single entry point
- Full spec suite with zero failures
- RuboCop compliance across all files
