# Aether: concept_quality optimization

## Objective
Generate novel, formally-verified mathematical theorems in Lean 4 that bridge 
multiple domains (certified robustness, tropical geometry, convex analysis, 
contraction mapping, norm inequalities, etc.). Each theorem must compile with 
0 sorries via `lake build`.

## Metrics
- **Primary**: concept_quality (0-1, higher is better) — novelty, depth, bridge value
- **Secondary**: verified_decls, verified_files, bridge_count, sorry_files

## How to Run
`bash autoresearch.sh` — checks compilation, counts theorems/sorries, reports metrics.

## Files in Scope
- `Catalog/Bridges/*.lean` — cross-domain bridges (primary output)
- `Catalog/MachineLearning/*/*.lean` — ML theory
- `Catalog/Tropical/*/*.lean` — tropical geometry
- `Catalog/Shared/*.lean` — shared utilities
- `Catalog/Speculative/*/*.lean` — speculative results
- `Aether/*.py` — orchestration code
- `autoresearch.checks.sh` — validation checks

## Off Limits
- `Catalog/.lake/` — Lean build artifacts
- Any file not in Catalog/ or Aether/

## Constraints
- All new theorems must compile via `lake env lean <file>` with 0 sorries
- `bash autoresearch.checks.sh` must pass (24 verified file checks)
- No overfitting to benchmark: don't create trivial variations
- No cheating: don't duplicate existing theorems or create degenerate cases

## What's Been Tried
### Proven approaches (keep using these patterns):
- `nlinarith [sq_nonneg X]` for quadratic inequalities
- `positivity` for positivity goals
- `Real.exp_le_exp.mpr` for exp monotonicity
- `Real.log_le_log` for log inequalities (0 < x, x ≤ y → log x ≤ log y)
- `div_pos`, `div_le_div_of_nonneg_left` for division inequalities
- `pow_le_pow_right₀` for power monotonicity
- `Real.sqrt_le_iff` for sqrt inequalities
- `max_eq_left`, `max_eq_right` with `le_total`
- `add_le_add`, `mul_le_mul_of_nonneg_left` for additive/multiplicative bounds
- `bernoulli_resnet` (imported from ResNetLipschitz)
- `mul_self_lt_mul` does NOT exist (use `nlinarith [sq_nonneg]` instead)
- `by decide`/`by norm_num`/`native_decide` for decidable propositions
- `field_simp` for division (closes goals sometimes without `ring`)

### Saturated directions (diminishing returns):
- Tropical/LSE/softmax: 6+ files, fully explored
- Certified robustness/Lipschitz: 3 files, diminishing returns
- EML/Stone-Weierstrass: 1 file, prerequisites complete
- Contraction mapping/GD: 1 file, complete
- Convex analysis: 1 file (ConvexTropical), complete
- Norm inequalities: 1 file (NormInequality), complete

### Key verified files (24 total):
- ResNetTropicalCertified (9 thms): γ/(2(1+L)) certified robustness
- EMLStoneWeierstrassBridge (17 thms): Stone-Weierstrass prerequisites
- BanachFixedPointBridge (10 thms): contraction + GD convergence
- MultiClassCertificationBridge (9 thms): multi-class certified radius
- ConvexTropicalBridge (9 thms): AM-GM + LSE bounds
- NormInequalityBridge (12 thms): L∞≤L1≤√2L2 + Young's + AM-QM
- Plus 18 earlier files (tropical, Satake, Carmichael, etc.)

### Dead ends:
- Probability concentration: requires MeasureTheory, too heavy
- EMLUniversalApproximation: requires Subalgebra construction, too complex
- Fibonacci Cassini: algebraic manipulation in Lean too complex for quick fix
- Lp norm inequalities: complex API issues with Mathlib
