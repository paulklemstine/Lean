# Summary of changes
# Diophantine Equation Solver — Complete Formalization

## What was built

A comprehensive Diophantine equation-solving pipeline, formalized in Lean 4 with 20 machine-verified theorems, Python demos, visualizations, and written documentation.

## Lean 4 Formalizations (zero sorry — all proofs complete)

### `Diophantine/LinearDiophantine.lean` — 7 theorems
- **Bézout's identity**: ∃ x y, ax + by = gcd(a,b)
- **Solvability criterion**: ax + by = c solvable ↔ gcd(a,b) | c
- **Solution family**: all solutions form an affine lattice
- **Homogeneous equation**: ab + b(−a) = 0
- **Solution difference**: two solutions differ by a homogeneous solution
- **Coprime case**: gcd = 1 always solvable
- **Zero case**: 0x + 0y = c ↔ c = 0

### `Diophantine/QuadraticDiophantine.lean` — 7 theorems
- **√2 irrationality**: x² ≠ 2y² for positive integers
- **Pythagorean parametrization**: (m²−n², 2mn, m²+n²) is always a Pythagorean triple
- **Mod-4 obstruction**: n ≡ 3 (mod 4) → n is NOT a sum of two squares
- **FLT for n=4**: x⁴ + y⁴ ≠ z⁴ (Fermat's Last Theorem, exponent 4)
- **Pell base solution**: 3² − 2·2² = 1
- **Pell recurrence**: solution-generating recurrence for x² − 2y² = 1
- **Pell composition**: Brahmagupta–Fibonacci identity (solutions form a group)

### `Diophantine/Pipeline.lean` — 6+ theorems
- **Idempotent composition**: f²=f ∧ g²=g ∧ fg=gf → (fg)²=fg
- **Fixed-point characterization**: fixed points of idempotent = its range
- **Stereographic projection**: t ↦ ((1−t²)/(1+t²), 2t/(1+t²)) lies on the unit circle
- **Berggren A/B/C invariance**: all three Berggren matrices preserve the Pythagorean equation
- **Pipeline soundness**: verified solutions are correct by construction

All proofs use only standard axioms (propext, Classical.choice, Quot.sound).

## Python Demos

### `Diophantine/demos/diophantine_solver.py`
Interactive solver implementing all seven pipeline stages: solves linear equations, generates Pythagorean triples via Berggren tree, solves Pell's equation via continued fractions, finds sum-of-two-squares decompositions, and verifies all answers. Run with `python3 diophantine_solver.py`.

### `Diophantine/demos/visualize.py`
ASCII art visualizations: Berggren tree structure, stereographic projection mapping ℚ → S¹, Pell equation solution spirals, linear solution lattices, sum-of-two-squares mod-4 heatmap, and the full seven-stage pipeline diagram. Run with `python3 visualize.py`.

## Documentation

- **`Diophantine/RESEARCH_PAPER.md`**: Formal research paper with abstract, complete theorem index, mathematical exposition of all 20 results, and related work.
- **`Diophantine/SCIENTIFIC_AMERICAN.md`**: Popular science article ("The Equation That Cannot Lie") explaining the pipeline for a general audience.
- **`Diophantine/NOTES.md`**: Research notes documenting the oracle council process, key decisions, what was included/excluded, mathematical background, and the axiom audit.