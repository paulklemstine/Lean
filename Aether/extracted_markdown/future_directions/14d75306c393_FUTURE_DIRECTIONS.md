# Future Directions — Benford Renormalization for Rank-2 Cluster Dynamics

## Synthesis

This cycle established the rigorous **tropical / hyperbolic backbone** of the Benford
program for coefficient-free rank-2 cluster algebras with exchange matrix
`B = [[0,b],[-c,0]]`. The new file
`MachineLearning/BenfordRenormalization/ClusterDynamics.lean` proves, with zero
`sorry` on all results:

* `cluster_log_linear` — the multiplicative cluster recurrence
  `x_{n+2}·x_n = x_{n+1}^(k n)` is *exactly* the additive linear recurrence
  `ℓ_{n+2} = (k n)·ℓ_{n+1} − ℓ_n` on logarithms (no error term: the linearization
  is algebraic, not asymptotic).
* `transfer_product`, `transfer_trace`, `transfer_det` — the one-period monodromy
  `M(c)·M(b)` is an `SL₂` matrix with trace `bc − 2`, determinant `1`.
* `cluster_hyperbolic` (with `disc_pos`, `lam_gt_one`, `lam_mul_mu`, `lam_add_inv`,
  `lam_sq`, `mu_sq`) — the threshold `bc > 4` is *exactly* hyperbolicity: the
  discriminant `(bc−2)²−4 = bc(bc−4)` is positive, the eigenvalues `λ, λ⁻¹` are real
  reciprocal with `λ > 1`, and `λ` solves `λ² = (bc−2)λ − 1`.
* `traceSeq_closed_form` / `traceSeq_tendsto_atTop` — the Chebyshev trace sequence
  `tr((M(c)M(b))ⁿ) = λⁿ + λ⁻ⁿ` diverges, i.e. a strictly positive logarithmic
  Lyapunov exponent `log λ` per period.

This sharpens, and is cross-linked to, two existing catalog artifacts:
`BenfordRenormalization/Defs.lean` (generic integer dynamical maps, `IsBenford`,
`oscillation`, `HasRationalEigenObstruction`) and `Benford.lean`
(`logHeight_shadowing`, `benford_of_fractional_part_count`), where the doubling map
is the linear model. Here the linear model is a **hyperbolic toral automorphism**
with logarithmic slope `log λ`.

## Results Summary

| Result | Statement | Status |
|---|---|---|
| `cluster_log_linear` | log turns the cluster recurrence into a linear one | proved |
| `transfer_trace` / `transfer_det` | monodromy is `SL₂`, trace `bc−2` | proved |
| `cluster_hyperbolic` | `bc>4 ⇒ λ>1`, `λλ⁻¹=1`, `λ+λ⁻¹=bc−2` | proved |
| `traceSeq_closed_form` | `tr(Mⁿ) = λⁿ + λ⁻ⁿ` | proved |
| `traceSeq_tendsto_atTop` | exponential cluster growth (Lyapunov > 0) | proved |

## Direction 1 — Irrational slope forces parity-wise equidistribution

The next milestone is to upgrade `traceSeq_tendsto_atTop` to an equidistribution
statement: for `bc > 4` and a generic positive seed, the fractional parts
`frac(log₁₀ x_{2n})` and `frac(log₁₀ x_{2n+1})` are equidistributed mod 1, hence
each parity subsequence is Benford. **The key insight is** that the log-orbit is, up
to a bounded eigenvector-projection constant, the linear orbit `n ↦ A·λⁿ`, so by
Weyl's criterion equidistribution is equivalent to the single arithmetic condition
`log₁₀ λ ∉ ℚ` — exactly the `¬ HasRationalEigenObstruction` predicate already defined
in `Defs.lean`. **Why now?** The hyperbolic data (`lam_gt_one`, `lam_sq`) and the
closed form are now available in Lean, so the only missing analytic input is a Weyl
sum bound for the geometric sequence `λⁿ`; this is a finite, falsifiable lemma rather
than a vague conjecture. Falsifier: any hyperbolic `(b,c)` and positive seed whose
empirical digit discrepancy `digitDiscrepancy` (from `Defs.lean`) fails to tend to 0.

## Direction 2 — Algebraicity of `λ` gives an unconditional irrationality dichotomy

`λ` is a root of `t² − (bc−2)t + 1 = 0`, a monic integer quadratic, so `λ` is a real
quadratic algebraic unit. **The key insight is** that `log₁₀ λ` is rational iff `λ`
is an integer power of `10^{p/q}`, which for a quadratic unit happens only in a
classifiable degenerate family; by Baker's theorem on linear forms in logarithms,
`log₁₀ λ` is irrational for all but an explicitly describable finite set of `(b,c)`.
**Why now?** With `lam_sq` proved, `λ` is pinned to an explicit minimal polynomial,
turning the equidistribution hypothesis of Direction 1 into a *decidable* Diophantine
question about `bc`. Conjecture: `log₁₀ λ(bc)` is irrational for every integer
`bc > 4`. Falsifier: an integer `bc > 4` with `λ(bc)` a rational power of 10.

## Direction 3 — The parabolic boundary `bc = 4` is the unique non-Benford locus

`disc_pos` requires the strict inequality `bc > 4`; at `bc = 4` the discriminant
vanishes and `λ = 1` (parabolic, affine type `Ã₁`). **The key insight is** that the
clean trichotomy `bc < 4` (periodic/finite type), `bc = 4` (linear growth, affine
type), `bc > 4` (exponential, wild type) should correspond *exactly* to the digit
trichotomy: eventually periodic digits, polynomially-failing equidistribution, and
full Benford. **Why now?** The Lyapunov computation `traceSeq_closed_form` makes the
boundary case `λ = 1 ⇒ tr ≡ 2` explicit and provable, so one can formally prove that
`bc = 4` orbits have `log x_n` growing *linearly*, hence fractional parts that are NOT
equidistributed unless the linear slope is irrational. Falsifier: an affine-type
`bc = 4` orbit that is nonetheless Benford with the predicted frequencies.

## Direction 4 — Cross-domain bridge: cluster monodromy ⟷ continued fractions of `λ`

Because `M(c)·M(b)` is a hyperbolic `SL₂(ℤ)` matrix, its action encodes the continued
fraction expansion of the fixed slope of the corresponding torus automorphism.
**The key insight is** that the discrepancy rate in Direction 1 is governed by the
continued-fraction partial quotients of `log₁₀ λ`, linking cluster digit statistics to
the metric theory of continued fractions (Khinchin / three-distance theorems).
**Why now?** The explicit `SL₂` form from `transfer_product` lets one transport the
Ostrowski/three-gap machinery directly onto the cluster orbit, predicting a *quantitative*
discrepancy bound `O((log N)/N)` for badly-approximable slopes. Falsifier: a hyperbolic
`(b,c)` whose measured digit discrepancy decays slower than any `(log N)^k / N`.

## Direction 5 — Higher-rank generalization via spectral radius of the exchange monodromy

For rank-`r` cluster algebras the analogue of `M(c)·M(b)` is a longer product of
`SL_r`-type transfer matrices, and hyperbolicity should be controlled by the spectral
radius exceeding 1. **The key insight is** that the rank-2 condition `bc > 4`
generalizes to "the Coxeter/monodromy matrix of the seed is not of finite or affine
type", i.e. the exchange graph is of *wild* representation type — the same trichotomy
that classifies cluster algebras. **Why now?** The rank-2 file gives a fully proved
template (`transfer`, `traceSeq`, Lyapunov divergence) that can be re-instantiated for
the `Ã`, `D̃`, and wild diagrams, making "Benford ⟺ wild type" a concrete, testable
program rather than a slogan. Falsifier: a wild-type higher-rank seed whose cluster
variables are provably non-Benford, or a finite/affine-type seed that is Benford.
