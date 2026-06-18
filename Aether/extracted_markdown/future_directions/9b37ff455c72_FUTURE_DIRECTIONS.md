# Future Directions — p-adic NTK Oversmoothing Phase Transition

## Synthesis

The conjecture that motivated this cycle — a *noise-stability phase transition for
p-adic neural tangent kernels on Bruhat–Tits buildings* — is, at its analytic
heart, a statement about a single competition: the geometric contraction of a
subdominant spectral mode against the finite resolution of a growing quotient.
We isolated and **proved** that core in `PadicNTKPhaseTransition.lean`.

Modeling depth-`L` message passing as scalar contraction `lam^L` of a nontrivial
spherical Hecke eigenspace (`lam ∈ (0,1)` the subdominant Hecke eigenvalue), and
the spectral resolution of a quotient with `N` vertices as the floor `1/N`, we
established:

- **Asymptotic oversmoothing** (`oversmoothing_tendsto`): high-frequency Hecke
  mass `lam^L → 0`.
- **A sharp, exact crossing** (`heckeMass_eq_threshold_at_crit`): the retained
  mass equals the resolution floor `1/N` at a *single* depth
  `criticalDepth = criticalRatio·log_p N = -log N / log lam`.
- **The two-sided phase transition** (`subcritical_preserved`,
  `supercritical_oversmoothed`): below the critical depth the high-frequency
  eigenspace projection is strictly preserved (`> 1/N`); above it the kernel is
  strictly rank-deficient on that eigenspace (`< 1/N`).
- **A spectral ordering law** (`criticalDepth_strictMono_in_eigenvalue`): the
  critical depth is strictly increasing in the eigenvalue magnitude, so
  high-frequency (small-eigenvalue) Hecke modes oversmooth first and only the
  lowest-frequency modes survive to large depth.

This realizes the conjecture's qualitative claim — a sharp depth threshold
scaling like `c*(d,p)·log_p|V|` rather than a smooth decay — as fully verified
Lean theorems, and exhibits `c*` explicitly as `-log p / log lam`. It extends the
catalog's ultrametric/p-adic ML thread (`UltrametricKLDivergence.lean`,
`AdelicSync/Core.lean`) with the missing *quantitative spectral* layer.

## Results Summary

Five `sorry`-free theorems (axioms: `propext`, `Classical.choice`, `Quot.sound`
only) plus supporting positivity lemmas, all over `ℝ`, using `Real.rpow` for
continuous depth so the threshold is exact rather than rounding-limited.

## Bold, falsifiable directions

### 1. Multi-eigenvalue spectral cascade with explicit gap law
The single-eigenvalue model should be promoted to a finite Hecke spectrum
`lam_1 > lam_2 > ... > lam_k` (eigenvalues of the spherical Hecke algebra acting
on radius-`r` balls). Conjecture: as depth grows past each
`criticalDepth p lam_j N`, eigenspace `j` drops below the `1/N` floor in strict
order, producing a *staircase* of `k` distinct transitions whose spacings are
`log N·(1/log lam_{j+1} - 1/log lam_j)`.
**The key insight is** that `criticalDepth_strictMono_in_eigenvalue` already
proves the *ordering* of the cascade; what remains is to sum the surviving
eigenprojections and show the kernel rank equals `#{j : criticalDepth_j > L}`,
turning the ordering into an exact rank formula.
**Why now?** The monotonicity theorem is in hand and the rank count is a finite
`Finset.filter` cardinality — a direct, mechanizable next step rather than new
analysis.

### 2. Effective-resistance / Ramanujan instantiation of `lam`
Replace the abstract `lam` by the genuine subdominant eigenvalue of the
adjacency/Hecke operator on a Ramanujan complex, where the Ramanujan bound forces
`lam ≤ 2√(q)/(q+1)`-type estimates (`q = p^?`). Conjecture: the critical
depth-to-residue ratio obeys a closed-form bound `c*(d,p) ≥ g(d,p)` computable
from the Ramanujan spectral gap.
**The key insight is** that the optimal (Ramanujan) gap *maximizes* `c*` because
larger `lam` gives larger `criticalDepth` — so Ramanujan complexes are exactly the
architectures most resistant to p-adic oversmoothing.
**Why now?** The catalog already contains expander/Ramanujan machinery
(`Algebra/ClassicalGroupExpanders.lean`, `Algebra/ExpanderWalk/Amplification.lean`);
bridging those spectral-gap bounds into `criticalRatio` is a concrete cross-domain
link rather than a from-scratch build.

### 3. Width–depth trade-off: a second transition axis
Infinite width is idealized; at finite width `m` the NTK has `O(1/√m)` spectral
fluctuations. Conjecture: there is a *joint* phase boundary in `(L, m)` — the
high-frequency mass is recoverable iff `lam^L > max(1/N, C/√m)`, yielding a
critical width `m*(L) ≍ lam^{-2L}` below which depth cannot be compensated.
**The key insight is** that finite width replaces the single floor `1/N` by the
*larger* of two floors, so the proved one-sided comparisons generalize verbatim
once the noise floor `C/√m` is introduced as a second `resolutionThreshold`.
**Why now?** The current proofs are stated as comparisons against an abstract
threshold; swapping `1/N` for `max(1/N, C/√m)` reuses the existing inequality
skeleton almost unchanged.

### 4. Non-multiplicative activations break exactness — quantify the smearing
Polynomial activations make the depth map multiplicative (`lam^L`); analytic
non-polynomial activations introduce eigenvalue mixing so the per-step factor is
a matrix `A`, not a scalar. Conjecture: the transition remains sharp (a threshold,
not a smooth decay) iff the spectral gap of `A` exceeds an explicit constant; below
that gap the transition *smears* over a depth window of width `Θ(1/gap)`.
**The key insight is** that sharpness is governed by the *second* singular value of
the depth-step operator, so the scalar result is the gap`=1` extreme of a matrix
perturbation statement.
**Why now?** Mathlib's matrix spectral-radius and Gelfand-formula tooling make the
operator-norm version of `oversmoothing_tendsto` reachable, and a refutation
(smooth decay, no threshold) is exactly the falsification criterion in the
original conjecture.

### 5. Discrete-depth correction: from `rpow` to integer layers
Real depth gives an exact crossing; physical networks have `L ∈ ℕ`. Conjecture:
the integer-depth transition still occurs within one layer of the real threshold,
i.e. `⌈criticalDepth⌉` is the unique layer count at which preserved Hecke mass
flips sign relative to `1/N`, with a quantified one-layer "fuzzy band".
**The key insight is** that the real theorems pin the crossing to a point, so the
integer statement is a `Nat.floor`/`Nat.ceil` sandwich around it — converting a
continuous transition into a verified discrete decision rule for layer budgeting.
**Why now?** This directly produces an *architecture principle* (how many layers
before oversmoothing) from already-proved continuous facts, closing the loop from
representation theory to a usable design rule.
