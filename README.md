# lex-agentic-defense

Domain consolidation gem for cognitive defense, immunity, and error management. Bundles 15 sub-modules into one loadable unit under `Legion::Extensions::Agentic::Defense`.

## Overview

**Gem**: `lex-agentic-defense`
**Version**: 0.1.9
**Namespace**: `Legion::Extensions::Agentic::Defense`

## Sub-Modules

| Sub-Module | Purpose |
|---|---|
| `Defense::ImmuneResponse` | Reactive immune memory — antigen/antibody matching, vaccination, immunity decay |
| `Defense::Immunology` | Proactive threat detection and resistance building |
| `Defense::Erosion` | Gradual degradation of outdated beliefs |
| `Defense::Friction` | Resistance to undesired belief or behavior change |
| `Defense::Quicksand` | Entrapment patterns — stuck states |
| `Defense::Quicksilver` | Rapid adaptive response to threats |
| `Defense::Phantom` | Phantom cognitive states — residual patterns after removal |
| `Defense::EpistemicVigilance` | Critical evaluation of incoming information, deception detection |
| `Defense::Bias` | Cognitive bias catalog and de-biasing strategies |
| `Defense::Confabulation` | False memory generation detection and claim decay |
| `Defense::Dissonance` | Cognitive dissonance detection and reduction |
| `Defense::ErrorMonitoring` | ACC error monitoring — anterior cingulate analog |
| `Defense::Extinction` | Four-level containment ladder with authority-gated escalation |
| `Defense::Avalanche` | Cascading cognitive failure detection |
| `Defense::Whirlpool` | Circular/recursive thought pattern detection |

## Actors

11 interval-based actors handle autonomous background processing:

- `Defense::Bias::Actor::Update` — every 60s, updates bias calibration
- `Defense::Confabulation::Actor::Decay` — every 300s, decays unverified claims
- `Defense::Dissonance::Actor::Update` — every 300s, updates dissonance model
- `Defense::EpistemicVigilance::Actor::Update` — every 300s, updates vigilance baseline
- `Defense::ErrorMonitoring::Actor::Tick` — every 15s, runs error monitoring tick
- `Defense::Erosion::Actor::Weather` — every 600s, weathers belief formations
- `Defense::Extinction::Actor::ProtocolMonitor` — every 300s, monitors containment protocol state
- `Defense::ImmuneResponse::Actor::Decay` — every 300s, decays immune responses
- `Defense::Immunology::Actor::Decay` — every 300s, decays immunological resistance
- `Defense::Phantom::Actor::Decay` — every 300s, decays phantom states
- `Defense::Whirlpool::Actor::Tick` — every 60s, ticks whirlpool detection

## Safety Note

`Defense::Extinction` level 4 is **irreversible** and triggers cryptographic erasure. Level escalation requires authority-gated governance approval.

## Installation

```ruby
gem 'lex-agentic-defense'
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
