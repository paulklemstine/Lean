# Computational Evidence — LWE Worst-Case Hardness Reductions

This note records small-case computational checks performed before formalizing
the worst-case-to-average-case reduction parameters for Learning with Errors
(Regev 2005 / Peikert 2009).

## 1. Minimum distance of the integer lattice ℤⁿ

For the standard integer lattice ℤⁿ ⊂ ℝⁿ, the squared Euclidean length of a
nonzero integer vector is a sum of squares of integers, at least one of which
is ≥ 1. Small cases:

| vector            | ∑ vᵢ²  | ‖v‖    |
|-------------------|--------|--------|
| (1,0,0)           | 1      | 1      |
| (1,1,0)           | 2      | √2     |
| (2,0,0)           | 4      | 2      |
| (1,1,1)           | 3      | √3     |
| (-1,0,0)          | 1      | 1      |

Minimum over nonzero vectors is exactly **1**, attained by any ± standard basis
vector. This grounds λ₁(ℤⁿ) = 1.

## 2. GapSVP gap monotonicity

GapSVP_γ at threshold d declares YES if λ₁ ≤ d, NO if λ₁ > γ·d. For fixed
λ₁ = 5, d = 1:

| γ   | γ·d | NO needs λ₁ > γ·d | instance |
|-----|-----|-------------------|----------|
| 2   | 2   | λ₁ > 2  (5>2 ✓)   | NO       |
| 4   | 4   | λ₁ > 4  (5>4 ✓)   | NO       |
| 6   | 6   | λ₁ > 6  (5>6 ✗)   | gap-violated |

Observation: a valid NO instance for a *larger* γ is automatically a valid NO
instance for any *smaller* γ. Hence GapSVP_γ becomes EASIER as γ grows — a
correct but counter-intuitive fact verified here numerically and proved in
`WorstCaseLattice.lean`.

## 3. Regev parameter regime  αq ≥ 2√n  and  γ = n/α

Regev's theorem: decision-LWE_{n,q,α} is at least as hard as quantumly solving
GapSVP_γ / SIVP_γ with γ = Õ(n/α), under αq ≥ 2√n. Sample feasibility checks
of the derived bound γ ≤ q√n / 2:

| n   | q     | α (min = 2√n/q) | γ = n/α     | q√n/2   | γ ≤ q√n/2 |
|-----|-------|-----------------|-------------|---------|-----------|
| 4   | 16    | 0.25            | 16          | 16      | ✓ (eq)    |
| 9   | 64    | 0.09375         | 96          | 96      | ✓ (eq)    |
| 16  | 256   | 0.03125         | 512         | 512     | ✓ (eq)    |

At the boundary α = 2√n/q the bound is tight (equality); for larger α it is
strict. This confirms the algebraic identity γ = q√n/2 at the boundary and the
inequality γ ≤ q√n/2 in general, both formalized in `ReductionParameters.lean`.

## 4. Counterexample hunt

- "λ₁(ℤⁿ) could be < 1": tested all vectors with entries in {-2..2} for n ≤ 3;
  no nonzero vector has length < 1. No counterexample.
- "GapSVP monotonicity might fail when d < 0": indeed if d < 0 the promise
  algebra flips; the formal theorem therefore carries the hypothesis 0 ≤ d.
  Boundary recorded as an explicit hypothesis.
- "γ ≤ q√n/2 might fail for n = 0": √0 = 0 makes αq ≥ 0 vacuous and γ = n/α = 0;
  the formal theorem assumes 1 ≤ n to stay in the meaningful regime.

All universal claims that survived are the ones formalized; every failed corner
case became an explicit hypothesis on the Lean statement.
