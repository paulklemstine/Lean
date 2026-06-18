# Summary of changes for run c553107d-52e9-4688-a1b8-80f7bbc442d4
# Submultiplicative Growth Systems, Tropical Envelopes, and the Nienhuis Constant

## Overview

This research cycle established formal infrastructure connecting submultiplicative sequences to subadditive analysis (Fekete's lemma) and tropical algebra. All mathematical results are machine-verified in Lean 4 with zero sorries.

## Lean 4 Proofs (All Verified, Zero Sorries)

### `Pythagorean/SubadditiveGrowth.lean` — Novel Structure: `GrowthSystem`

Defines a **GrowthSystem** — a positive submultiplicative sequence packaged with its logarithmic transform, growth rate, and tropical envelope. This is the core novel mathematical object of the cycle.

**8 theorems proved:**
1. **`logSeq_subadditive`** — The logarithmic transform converts submultiplicative to subadditive (the fundamental bridge).
2. **`submult_power_bound`** — For k ≥ 1: a(kn) ≤ a(n)^k (induction on k; correctly handles the k=0 counterexample).
3. **`envelope_subadditive`** — The tropical envelope e(n) = log a(n) − nμ is itself subadditive.
4. **`envelope_nonneg`** — **Fekete–Tropical Bridge Theorem**: e(n) ≥ 0 for all n ≥ 1, using Subadditive.lim_le_div from Mathlib.
5. **`base_ge_one`** — a(0) ≥ 1 for any growth system (from a(0) ≤ a(0)² and positivity).
6. **`seq_le_base_pow`** — a(n) ≤ a(1)^n for n ≥ 1.
7. **`geometric_growthRate`** — Growth rate of r^n equals log(r) (exact computation).
8. **`growthRate_le_log_base`** — μ ≤ log(a(1)) (growth rate upper bound).

Also: product closure (GrowthSystem.prod), constant and geometric constructors.

### `Pythagorean/NienhuisIrrationality.lean` — Nienhuis Constant

**9 theorems proved:**
1. **`two_add_sqrt_two_pos`** — 2+√2 > 0.
2. **`irrational_two_add_sqrt_two`** — 2+√2 is irrational (cascade from √2).
3. **`irrational_nienhuis`** — √(2+√2) is irrational (if rational, squaring contradicts step 2).
4. **`nienhuis_pos`** — μ > 0.
5. **`nienhuis_sq`** — μ² = 2+√2.
6. **`nienhuis_minimal_poly`** — μ⁴ − 4μ² + 2 = 0 (the minimal polynomial identity).
7. **`nienhuis_lt_two`** — μ < 2.
8. **`nienhuis_gt_one`** — 1 < μ.
9. **`nienhuis_no_rational_root`** — x⁴ − 4x² + 2 has no rational roots (algebraic degree certificate).

## Other Deliverables

- **ARTICLE.md** — Popular science article ("The Hidden Architecture of Random Walks") about self-avoiding walks, the Nienhuis constant, and tropical envelopes. No mentions of proof assistants.
- **RESEARCH_PAPER.md** — Full research paper with definitions, theorem statements, proof sketches, PEGB analysis, and references.
- **FUTURE_DIRECTIONS.md** — 5 research directions with conjectures, tests, and proof strategies:
  1. Tropical spectral bounds for connective constants (grand challenge)
  2. Subadditive ergodic theory for random growth systems (grand challenge)
  3. Tropical envelope periodicity and algebraic growth rates (extension)
  4. Irreducibility certificates for connective constant polynomials (extension)
  5. Discrete holomorphicity and parafermionic observables (grand challenge)
- **demo.py** — Numerical demonstrations of all key results.
- **algorithms.py** — Type-hinted Python implementations of growth system algorithms.
- **visualize_growth.py** — Four-panel matplotlib visualization.
- **PACKAGE.json** — Complete package with 3 interactive HTML demos (Fekete-Tropical Bridge Explorer, Nienhuis Polynomial, Power Bound Visualizer).