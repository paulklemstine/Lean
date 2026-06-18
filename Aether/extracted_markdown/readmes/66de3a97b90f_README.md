# Gravitational Factoring: Open Questions Research

This directory contains new results addressing the open questions from the gravitational factoring research program.

## Contents

### Formal Verification (Lean 4)
- **`DensityAndChannels.lean`** — 24 formally verified theorems (all sorry-free)
  - Exact density formula for semiprimes
  - Congruence-of-squares factoring principle
  - Brahmagupta-Fibonacci identity
  - Cross-collision channel theory
  - Lattice-GCD connection
  - Channel amplification bounds
  - And more

### Computational Experiments
- **`demo_open_questions.py`** — 10 reproducible experiments
  1. Density formula verification (zero error)
  2. Cross-collision effectiveness (80% both channels)
  3. Sieve-augmented factoring (100% success up to N=1147)
  4. Octonionic non-associativity demonstration
  5. Parity filter analysis
  6. Statistical mechanics phase transition
  7. Balanced vs. unbalanced semiprimes
  8. Channel amplification scaling
  9. Quaternion norm factoring
  10. k-tuple tree descent verification

### Research Papers
- **`research_paper.md`** — Full technical paper with all results
- **`future_research_directions.md`** — 25 future research directions organized by difficulty
- **`scientific_american_article.md`** — Popular science article
- **`applications_brainstorm.md`** — 20+ application ideas across cryptography, physics, CS, and ML

### Visualizations
- **`visuals/density_formula.svg`** — Density scaling plot
- **`visuals/channel_hierarchy.svg`** — Channel count by dimension
- **`visuals/congruence_of_squares.svg`** — COS factoring pipeline
- **`visuals/octonionic_advantage.svg`** — Fano plane and non-associativity
- **`visuals/proof_map.svg`** — Theorem dependency graph
- **`visuals/sieve_pipeline.svg`** — Complete sieve-augmented pipeline

## Key Results

| Question | Status | Evidence |
|:---------|:------:|:---------|
| Density formula | **Proven** (corrected) | Lean proof + 16 empirical tests |
| Congruence of squares | **Proven** | Lean formal proof |
| Cross-collision channels | **Resolved** | 20 computational tests |
| Sieve framework | **Demonstrated** | 6 semiprimes factored |
| Octonionic advantage | **Confirmed** | Explicit computation |
| Channel marginal returns | **Proven** | Lean formal proof |
| Single-GCD sufficiency | **Proven** | Lean formal proof |
| Lattice-GCD connection | **Proven** | Lean formal proof |
| Grover speedup | **Corrected** | Original disproved, corrected version proven |
| Channel amplification | **Proven** | Lean formal proof |

## Running

```bash
# Run computational experiments
python3 demo_open_questions.py

# Build Lean proofs
lake build Pythagorean.OpenQuestions.NewResearch.DensityAndChannels

# Verify axioms
# Add to a Lean file: #print axioms congruence_of_squares_factor
```

## Axiom Check

All proofs use only the standard axioms:
- `propext`
- `Classical.choice`
- `Quot.sound`

No `sorry`, no custom axioms, no `@[implemented_by]`.
