# lex-argument-mapping

**Level 3 Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Grandparent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## Purpose

Toulmin-model argument mapping for LegionIO — claim/grounds/warrant/backing/qualifier/rebuttal argument construction, strength assessment, and soundness evaluation. Models structured argumentation so the agent can reason about and evaluate the logical structure of its own claims and incoming propositions.

## Gem Info

- **Gem name**: `lex-argument-mapping`
- **Version**: `0.1.0`
- **Module**: `Legion::Extensions::ArgumentMapping`
- **Ruby**: `>= 3.4`
- **License**: MIT

## File Structure

```
lib/legion/extensions/argument_mapping/
  argument_mapping.rb        # Main extension module
  version.rb                 # VERSION = '0.1.0'
  client.rb                  # Client wrapper
  helpers/
    constants.rb             # Weights, limits, strength/rebuttal labels
    argument.rb              # Argument value object (Toulmin components)
    argument_engine.rb       # ArgumentEngine — manages arguments, scoring, decay
  runners/
    argument_mapping.rb      # Runner module with 10 public methods
spec/
  (spec files)
```

## Key Constants

```ruby
ARGUMENT_STRENGTHS = {
  (0.8..) => :compelling, (0.6...0.8) => :strong,
  (0.4...0.6) => :moderate, (0.2...0.4) => :weak, (..0.2) => :fallacious
}
QUALIFIER_TYPES    = %i[certainly presumably probably possibly apparently]
MAX_ARGUMENTS      = 200
MAX_HISTORY        = 500
DEFAULT_STRENGTH   = 0.5
GROUND_WEIGHT      = 0.3    # contribution of grounds to overall strength
WARRANT_WEIGHT     = 0.3    # contribution of warrant
BACKING_WEIGHT     = 0.2    # contribution of backing
REBUTTAL_PENALTY   = 0.2    # reduction per rebuttal with > 0.5 impact
DECAY_RATE         = 0.02
REBUTTAL_IMPACT_LABELS = {
  (0.8..) => :devastating, ... (..0.2) => :negligible
}
```

## Runners

### `Runners::ArgumentMapping`

All methods delegate to a private `@engine` (`Helpers::ArgumentEngine` instance).

- `create_argument(claim:, domain: :general, warrant: nil, qualifier: :presumably)` — create a Toulmin argument with claim, domain, warrant, and qualifier
- `add_argument_ground(argument_id:, ground:)` — add a factual ground supporting the claim
- `add_argument_backing(argument_id:, backing:)` — add backing evidence for the warrant
- `add_argument_rebuttal(argument_id:, content:, impact: 0.5)` — add a rebuttal to the argument; high-impact rebuttals reduce strength
- `assess_argument_strength(argument_id:)` — compute strength: weighted sum of grounds, warrant, backing minus rebuttal penalties
- `sound_arguments_report` — arguments with no high-impact rebuttals
- `rebutted_arguments_report` — arguments with at least one rebuttal
- `strongest_arguments_report(limit: 5)` — top arguments by strength score
- `update_argument_mapping` — decay all argument strengths
- `argument_mapping_stats` — stats hash

## Helpers

### `Helpers::ArgumentEngine`
Core engine managing `@arguments` hash. `assess_argument` computes weighted score from grounds count, warrant presence, backing count, minus rebuttal penalties. `sound_arguments` filters where no rebuttal has impact > 0.5. `decay_all` reduces strength of all arguments.

### `Helpers::Argument`
Toulmin argument value object. Stores claim, domain, warrant, qualifier, grounds array, backing array, and rebuttals array. Strength is computed on demand from the component weights.

## Integration Points

No actor defined — callers drive decay via `update_argument_mapping`. This extension enables structured deliberation: before taking action, the agent can construct a formal argument for the action's justification, assess its strength, and check for rebuttals. Integrates with lex-tick's `action_selection` phase. `sound_arguments_report` feeds into governance (`lex-governance`) when the agent needs to justify proposals to the council.

## Development Notes

- Strength computation uses number of grounds and backing items, not their content quality — calibration must come from the caller
- Rebuttals with `impact > 0.5` are the threshold for `sound_arguments` filtering (not a constant, embedded in engine logic)
- `decay_all` returns the count of processed arguments, not the count that changed significantly
- No capacity prune on history — `MAX_HISTORY = 500` is defined but enforcement logic should be verified in the engine
