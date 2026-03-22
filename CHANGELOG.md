# Changelog

## [Unreleased]

## [0.1.3] - 2026-03-21

### Added
- Right-to-erasure propagation from extinction level 4 to Apollo knowledge store
- Apollo erasure wired in enforce_escalation_effects (delete non-confirmed, redact confirmed)

### Changed
- enforce_escalation_effects restructured: DigitalWorker termination uses if-block instead of early return

## [0.1.2] - 2026-03-18

### Changed
- Enforce ANTIGEN_TYPES at ImmuneResponse::ImmuneEngine method boundaries: `register_antigen` and `create_antibody` return nil for invalid antigen_type values (v0.1.1)
- Enforce MANIPULATION_TACTICS at Immunology::ImmuneEngine method boundaries: `detect_threat` and `create_antibody` return nil for invalid tactic values (v0.1.1)
- Added 8 new enum validation specs (2 per enforced constant)

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
