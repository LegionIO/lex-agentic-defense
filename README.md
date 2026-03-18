# lex-agentic-defense

Domain consolidation gem for cognitive defense, immunity, and error management. Bundles 15 source extensions into one loadable unit under `Legion::Extensions::Agentic::Defense`.

## Overview

**Gem**: `lex-agentic-defense`
**Version**: 0.1.0
**Namespace**: `Legion::Extensions::Agentic::Defense`

## Sub-Modules

| Sub-Module | Source Gem | Purpose |
|---|---|---|
| `Defense::ImmuneResponse` | `lex-cognitive-immune-response` | Active defense responses to cognitive threats |
| `Defense::Immunology` | `lex-cognitive-immunology` | Immune system modeling for belief protection |
| `Defense::Erosion` | `lex-cognitive-erosion` | Gradual degradation of outdated beliefs |
| `Defense::Friction` | `lex-cognitive-friction` | Resistance to undesired belief or behavior change |
| `Defense::Quicksand` | `lex-cognitive-quicksand` | Entrapment patterns — stuck states |
| `Defense::Quicksilver` | `lex-cognitive-quicksilver` | Rapid adaptive response to threats |
| `Defense::Phantom` | `lex-cognitive-phantom` | Phantom cognitive states — residual patterns after removal |
| `Defense::EpistemicVigilance` | `lex-epistemic-vigilance` | Critical evaluation of incoming information, deception detection |
| `Defense::Bias` | `lex-bias` | Cognitive bias catalog and de-biasing strategies |
| `Defense::Confabulation` | `lex-confabulation` | False memory generation detection |
| `Defense::Dissonance` | `lex-dissonance` | Cognitive dissonance detection and reduction |
| `Defense::ErrorMonitoring` | `lex-error-monitoring` | ACC error monitoring — anterior cingulate analog |
| `Defense::Extinction` | `lex-extinction` | Four-level containment ladder with authority-gated escalation |
| `Defense::Avalanche` | `lex-cognitive-avalanche` | Cascading cognitive failure detection |
| `Defense::Whirlpool` | `lex-cognitive-whirlpool` | Circular/recursive thought pattern detection |

## Actors

- `Defense::Extinction::Actors::ProtocolMonitor` — runs every 300s, monitors containment protocol state

## Installation

```ruby
gem 'lex-agentic-defense'
```

## Development

```bash
bundle install
bundle exec rspec        # 1696 examples, 0 failures
bundle exec rubocop      # 0 offenses
```

## License

MIT
