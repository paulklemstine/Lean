# Aether: concept_quality optimization

## Objective
Generate novel, formally-verified mathematical theorems in Lean 4.
Each theorem must compile with 0 sorries via `lake build`.
Theorems should be deep, correct, and interesting. They need NOT bridge
multiple domains — pure results in a single domain are equally valuable.

## Metrics
- **Primary**: concept_quality (0-1, higher is better) — novelty, depth, correctness
- **Secondary**: verified_decls, verified_files, sorry_files

## How to Run
`bash autoresearch.sh` — checks compilation, counts theorems/sorries, reports metrics.

## Files in Scope
- `Catalog/Bridges/*.lean` — domain-specific theorems
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
- No overfitting to benchmark: don't create trivial variations or pad metrics
- No cheating: don't duplicate existing theorems or create degenerate cases
- Bridges across domains are valuable but NOT required — pure depth in one domain is equally good

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

## Session Progress (autoresearch runs 2-9)

### New Bridges Added
- **GronwallDiscreteBridge** (8 thm): Discrete Gronwall inequalities connecting iterative bounds to GD convergence
  - Key: geometric_bound, affine_fixed_point, affine_geometric_decay, gd_geometric_convergence, resnet_growth_polynomial
- **HammingDistanceBridge** (7 thm): Coding theory ↔ certified robustness via metric spaces
  - Key: hamming_triangle (triangle inequality), minimum_distance_distinct (error detection ↔ certified margin)
- **TopologicalRobustnessBridge** (8 thm): Continuous on compact → bounded (worst-case analysis foundation)
  - Key: compact_attains_sup/inf, norm_bounded_on_compact, lipschitz_bounded
- **CombinatorialBridge** (6 thm): Pigeonhole ←→ certified margin bounds
  - Key: pigeonhole, union_card_le, no_injection_when_card_lt
- **NeuralCompositionBridge** (7 thm): THE composition laws for neural network robustness
  - Key: lipschitz_comp (Lip(f∘g) ≤ Kf·Kg), lipschitz_add (Lip ≤ 1+K for ResNet), lipschitz_max
- **IntermediateValueBridge** (6 thm): IVT ↔ adversarial examples exist at decision boundaries
  - Key: strict_zero_crossing, sign_change_implies_adversarial

### Notable Theorem Chains
1. GronwallDiscrete → BanachFixedPoint: GD convergence via geometric decay
2. TopologicalRobustness → MultiClassCertification: compact → bounded → certified radius
3. NeuralComposition → ResNetLipschitz: composition laws explain polynomial vs exponential growth
4. IntermediateValue → certified robustness: IVT → adversarial examples exist at boundary
5. ExponentialBound → ConvexTropical: log(x)≤x−1 gives AM-GM
6. TropicalSatakeGL3 (Aristotle): extends SatakeIsomorphism from GL₂ to GL₃

### Diminishing Returns Assessment
- 30 verified files, ~248 theorems, 0 sorries
- Each new bridge adds ~6-8 theorems but with decreasing novelty (saturation in certified robustness)
- Future work should focus on: (a) closing the Carmichael sorry, (b) strengthening existing bridges, (c) waiting for Aristotle results

### Aristotle Pipeline
- KnowledgeExtractor operational: Pi→Aristotle→Pi→Aether pipeline working
- Aristotle project 95ba9fc7: tropical_langlands GL3 Satake (in progress)
- Key principle: Aristotle has creative freedom (outcomes, not filenames)

### What's Still Saturated
- Tropical/LSE/softmax: fully explored
- Certified robustness/Lipschitz: diminishing (NeuralComposition is the final piece)
- Contraction mapping/GD: complete (GronwallDiscrete completes it)
- Convex analysis: complete
- Norm inequalities: complete
- Number theory (Carmichael): 1 sorry remaining (requires LTE, hard)
