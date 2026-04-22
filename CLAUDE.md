# lex-agentic-defense

**Parent**: `../CLAUDE.md`

## What Is This Gem?

Domain consolidation gem for cognitive defense, immunity, and error management. Bundles 15 sub-modules into one loadable unit under `Legion::Extensions::Agentic::Defense`.

**Gem**: `lex-agentic-defense`
**Version**: 0.1.9
**Namespace**: `Legion::Extensions::Agentic::Defense`

## Sub-Modules

| Sub-Module | Purpose | Runner Methods |
|---|---|---|
| `Defense::ImmuneResponse` | Reactive immune memory — antigen registration, antibody creation, vaccination, immunity decay | `register_antigen`, `encounter_antigen`, `create_antibody`, `vaccinate`, `escalate_threat`, `de_escalate_threat`, `immunity_for`, `decay_all`, `critical_antigens`, `memory_cells`, `most_threatening`, `strongest_antibodies`, `immune_report`, `immune_status` |
| `Defense::Immunology` | Proactive threat detection and resistance building; distinct from ImmuneResponse (which is reactive) | `decay_all`, `cognitive_immunology_status`, `register_threat`, `build_resistance` |
| `Defense::Erosion` | Gradual degradation of outdated beliefs | `weather_all`, `erode_formation`, `erosion_status` |
| `Defense::Friction` | Resistance to undesired belief or behavior change | `add_friction`, `remove_friction`, `friction_status` |
| `Defense::Quicksand` | Entrapment patterns — stuck states | `enter_pit`, `escape_pit`, `quicksand_status` |
| `Defense::Quicksilver` | Rapid adaptive response to threats | `create_droplet`, `pool_status` |
| `Defense::Phantom` | Phantom cognitive states — residual patterns after removal | `decay_all`, `phantom_status` |
| `Defense::EpistemicVigilance` | Critical evaluation of incoming information, deception detection | `update_epistemic_vigilance`, `assess_source`, `vigilance_status` |
| `Defense::Bias` | Cognitive bias catalog and de-biasing strategies | `update_bias`, `register_bias`, `bias_report` |
| `Defense::Confabulation` | False memory generation detection and claim decay | `register_claim`, `verify_claim`, `flag_confabulation`, `confabulation_report`, `high_risk_claims`, `confabulation_status`, `decay_claims` |
| `Defense::Dissonance` | Cognitive dissonance detection and reduction | `update_dissonance`, `add_belief`, `dissonance_status` |
| `Defense::ErrorMonitoring` | ACC error monitoring — anterior cingulate analog | `update_error_monitoring`, `record_error`, `error_monitoring_status` |
| `Defense::Extinction` | Four-level containment ladder with authority-gated escalation; level 4 triggers cryptographic erasure | `escalate`, `deescalate`, `extinction_status`, `monitor_protocol`, `check_reversibility` |
| `Defense::Avalanche` | Cascading cognitive failure detection | `detect_avalanche`, `avalanche_status` |
| `Defense::Whirlpool` | Circular/recursive thought pattern detection | `tick_all`, `whirlpool_status` |

## Actors

All actors extend `Legion::Extensions::Actors::Every` (interval-based).

| Actor | Interval | Target Method |
|---|---|---|
| `Defense::Bias::Actor::Update` | 60s | `Bias#update_bias` |
| `Defense::Confabulation::Actor::Decay` | 300s | `Confabulation#decay_claims` |
| `Defense::Dissonance::Actor::Update` | 300s | `Dissonance#update_dissonance` |
| `Defense::EpistemicVigilance::Actor::Update` | 300s | `EpistemicVigilance#update_epistemic_vigilance` |
| `Defense::ErrorMonitoring::Actor::Tick` | 15s | `ErrorMonitoring#update_error_monitoring` |
| `Defense::Erosion::Actor::Weather` | 600s | `CognitiveErosion#weather_all` |
| `Defense::Extinction::Actor::ProtocolMonitor` | 300s | `Extinction#monitor_protocol` |
| `Defense::ImmuneResponse::Actor::Decay` | 300s | `CognitiveImmuneResponse#decay_all` |
| `Defense::Immunology::Actor::Decay` | 300s | `CognitiveImmunology#decay_all` |
| `Defense::Phantom::Actor::Decay` | 300s | `CognitivePhantom#decay_all` |
| `Defense::Whirlpool::Actor::Tick` | 60s | `CognitiveWhirlpool#tick_all` |

## Dependencies

| Gem | Purpose |
|---|---|
| `legion-cache` >= 1.3.11 | Cache access |
| `legion-crypt` >= 1.4.9 | Encryption/Vault (Extinction level 4 erasure path) |
| `legion-data` >= 1.4.17 | DB (Extinction state migration) |
| `legion-json` >= 1.2.1 | JSON serialization |
| `legion-logging` >= 1.3.2 | Logging |
| `legion-settings` >= 1.3.14 | Settings |
| `legion-transport` >= 1.3.9 | AMQP |

## Key Architecture Notes

- `Defense::ImmuneResponse` is **reactive** (antigen→antibody matching on encounter). `Defense::Immunology` is **proactive** (builds resistance before threats arrive). They are separate sub-modules.
- `Defense::Extinction` is safety-critical: level 4 is **irreversible** and triggers: mesh isolation, cryptographic erasure via `lex-privatecore`, termination of all active DigitalWorker records, and Apollo erasure propagation. Level escalation requires authority-gated governance approval.
- `Defense::Extinction` has a local DB migration: `20260316000040_create_extinction_state`.
- Stale escalation (level > 0 for >24 hours) emits `extinction.stale_escalation` via `Legion::Events`.

## Development

```bash
bundle install
bundle exec rspec        # 0 failures
bundle exec rubocop      # 0 offenses
```
