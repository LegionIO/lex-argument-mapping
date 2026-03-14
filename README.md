# lex-argument-mapping

Toulmin-model argument mapping for LegionIO — structured claim construction, strength assessment, and soundness evaluation.

## What It Does

Models Stephen Toulmin's argumentation framework: claims supported by grounds, justified by warrants, reinforced by backing, hedged by qualifiers, and challenged by rebuttals. The agent can construct formal arguments for its decisions, assess their logical strength, and identify where rebuttals weaken the case.

## Core Concept: The Toulmin Model

An argument has six components:
- **Claim**: the conclusion being argued for
- **Grounds**: factual evidence supporting the claim
- **Warrant**: the logical principle connecting grounds to claim
- **Backing**: support for the warrant itself
- **Qualifier**: epistemic hedge (certainly/presumably/probably/possibly/apparently)
- **Rebuttal**: conditions under which the claim would not hold

```
strength = (grounds_count * 0.3) + (warrant_present * 0.3) + (backing_count * 0.2)
         - sum(rebuttal_penalties)
```

## Usage

```ruby
client = Legion::Extensions::ArgumentMapping::Client.new

# Build a Toulmin argument
arg = client.create_argument(
  claim: 'we should migrate to Vault for secrets management',
  domain: :architecture,
  warrant: 'centralized secrets reduce credential sprawl',
  qualifier: :presumably
)

# Add supporting components
client.add_argument_ground(argument_id: arg[:id], ground: 'current rotation is manual and error-prone')
client.add_argument_backing(argument_id: arg[:id], backing: 'CIS benchmark recommends centralized secrets')

# Add a rebuttal
client.add_argument_rebuttal(argument_id: arg[:id], content: 'Vault adds operational complexity', impact: 0.4)

# Assess strength
client.assess_argument_strength(argument_id: arg[:id])
# => { strength: 0.72, label: :strong, rebuttal_count: 1 }

# Find strongest arguments
client.strongest_arguments_report(limit: 3)
```

## Integration

Wire into lex-tick's `action_selection` phase to require formal justification before high-stakes actions. Feed `sound_arguments_report` into lex-governance proposals for council review.

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
