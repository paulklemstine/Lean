# Future Directions: Policy-Gradient Geometry & Variance Reduction

## Synthesis

This cycle built a self-contained, sorry-free Lean 4 formalization of the
*differential geometry of softmax policy gradients* and the *variance-reduction
theory of baselines*, living in `Catalog/MachineLearning/PolicyGradient/`
(`Foundations.lean` and `VarianceReduction.lean`). A reality check on the catalog
was decisive: the lemmas earlier concept notes *assumed* already existed
(`variance_shift_invariant`, `baseline_objective_quadratic`) do **not** exist
anywhere in the project — they were aspirational, as was the `PolicyGradient`
directory itself. So rather than "extend" phantom results, we built the missing
foundation from scratch, in the same finite-action spirit (`Fin n`, real sums,
an `expectVal` over a probability vector), so the next cycle has genuine objects
to build on. This complements the catalog's existing softmax/KL material
(`Catalog/MachineLearning/UltrametricKLDivergence.lean`, the Gaussian PAC-Bayes
KL in `Catalog/MachineLearning/Gaussian.lean`) and its information-geometry
threads, but is deliberately measure-theory-free.

The structural insight that emerged is that the entire first-order theory of
softmax PG is *purely algebraic over a finite probability vector*: the score
`ψ_j(a) = δ_{aj} − π_j`, the log-derivative identity `E_π[ψ_j] = 0`, the Fisher
closed form `F = diag(π) − π πᵀ`, its PSD-ness as a genuine variance
`vᵀ F v = E_π[(⟨v, ψ⟩)²]`, and the optimal-baseline quadratic
`M(b) = A b² − 2B b + C` are all finite-sum facts. The single reusable engine is
"expand the square/product, push constants through `Finset.mul_sum`, collapse
indicators with `Finset.sum_ite_eq'`, and reduce to the sum-to-one law". This is
exactly why the optimal-baseline results dropped out of one lemma
(`variance_reduction_amount`, the completed square `M(b) − M(b⋆) = A·(b − b⋆)²`):
minimization, uniqueness, and the strict inequality are corollaries, not new
work. The friction signal was the Fisher PSD identity, which required an explicit
triple-sum reordering (`Finset.sum_comm`) and a realization as
`E_π[(∑_j v_j ψ_j)²]` rather than a one-shot `simp`. That is precisely where the
next hard theorems live: the matrix-level facts want a clean `Finset`-indexed
quadratic-form API.

## Results Summary

All theorems are proved with `sorry = 0` (verified via the LSP against the
project's Mathlib).

- `softmaxPolicy_pos` — the softmax policy is strictly positive, so `log π` and
  KL divergences are everywhere finite (no `log 0`).
- `softmaxPolicy_sum_one` — softmax is a genuine probability distribution (needs
  a nonempty action set `[NeZero n]`; the unguarded version is *false* at
  `n = 0` and was disproved before fixing).
- `softmaxScore_expect_zero` — the log-derivative / REINFORCE identity
  `E_π[ψ_j] = 0`; the algebraic heart of every unbiased PG estimator.
- `fisherInfo_eq` — closed form `F_{jk} = π_j δ_{jk} − π_j π_k`.
- `fisherInfo_symm` — the Fisher matrix is symmetric.
- `fisherInfo_psd` — `F` is positive semidefinite, realized as the variance
  `vᵀ F v = E_π[(⟨v, ψ(·)⟩)²] ≥ 0`.
- `baseline_unbiased` — subtracting any constant baseline preserves the gradient
  mean (`E_π[(R − b)s] = E_π[R s]`), needing only `E_π[s] = 0`.
- `secondMoment_quadratic` — the estimator's second moment is exactly
  `A b² − 2B b + C` with `A = E_π[s²]`, `B = E_π[R s²]`, `C = E_π[R² s²]`.
- `variance_reduction_amount` — the exact gain `M(b) − M(b⋆) = A·(b − b⋆)²`.
- `optimal_baseline_min` — `b⋆ = E_π[R s²]/E_π[s²]` minimizes the second moment
  (hence variance, by `baseline_unbiased`).
- `optimal_baseline_strict` — `b⋆` is the *unique* minimizer; any other baseline
  is strictly worse.

## Research Directions

### Direction 1: The optimal-baseline variance ratio is `1 − ρ²`

The folklore control-variate bound says a baseline reduces variance by exactly
the squared correlation between the return and the squared score. Concretely,
with `A = E_π[s²]`, `B = E_π[R s²]`, `C = E_π[R² s²]`, define the centered
variance `V(b) = secondMoment p R s b − (E_π[R s])²`. The conjecture is
`V(b⋆) = C − B²/A − (E_π[R s])²` and, when `V(0) ≠ 0`,
`V(b⋆) / V(0) = 1 − ρ²` with `ρ² = B² / (A · C)`. The key insight is that the
*numerator* of this ratio is already in hand: `variance_reduction_amount` gives
the exact gain `A·(b − b⋆)²`, so only the normalization and the Cauchy–Schwarz
inequality `B² ≤ A · C` remain — and `B² ≤ A · C` is itself a sum-of-squares
fact provable by the same `fisherInfo_psd`-style realization (apply PSD-ness to
the two-vector Gram matrix of `s` and `R·s` against weights `p`). A falsifying
test is a finite `(p, R, s)` example where the measured ratio exceeds `1 − ρ²`;
a disproof would pinpoint exactly which centering hypothesis the folklore
silently assumes. Why now: the completed square and a PSD/Cauchy–Schwarz lemma
are the only two ingredients, and the first already exists in this file.

### Direction 2: State-dependent baselines and `b⋆(s) = V^π(s)`

In actor–critic the *value function* is the optimal baseline. Stratify the
estimator by state with conditional scores `ψ(·|s)` satisfying `E[ψ|s] = 0`; the
conjecture is that the per-state optimal baseline is independent across states
and, under compatible features, collapses to `V^π(s)`. The key insight is that
`optimal_baseline_min` and `optimal_baseline_strict` are already stated for an
*arbitrary* distribution `p` and arbitrary `R, s`, so instantiating `p` as a
conditional slice over a product index `State × Action` is immediate; the new
content is only a tensorized total-variance decomposition
`Var = E[Var(·|s)] + Var(E[·|s])`. Test: generalize `expectVal` to the product
index, prove the conditional `baseline_unbiased` and `optimal_baseline_min` per
state, then assemble the decomposition; a counterexample with shared parameters
across states (coupling) that breaks separable optimality would be a sharp,
publishable boundary. Why now: the optimality lemmas are already
distribution-generic, so the conditional case needs no new optimization theory —
only the product-index plumbing.

### Direction 3: Natural gradient is gauge-projection — `𝟙 ∈ ker F`

Natural policy gradient preconditions by `F⁺`. Using the closed form
`F = diag(π) − π πᵀ` from `fisherInfo_eq`, the conjecture is that the all-ones
vector lies in the kernel of `F` (the softmax gauge direction), so that
`F⁺ F = I − projection onto 𝟙` on the tangent space and the natural-gradient
update is invariant under the reparameterization `z ↦ z + c·𝟙`. The key insight
is that `𝟙 ∈ ker F` is *not* a new computation: it is a direct corollary of
`softmaxScore_expect_zero` (rows of `F` sum to zero because each row is a
score-weighted expectation, and `E_π[ψ_j] = 0`). Test: lift `fisherInfo` into
`Matrix (Fin n) (Fin n) ℝ`, prove `F.mulVec 1 = 0`, characterize
`range F = 𝟙ᗮ`, and show gauge-invariance of the update; a degeneracy (a
boundary policy with a zero coordinate) would falsify it, but
`softmaxPolicy_pos` is exactly the hypothesis that rules that out. Why now:
`fisherInfo_eq` and `fisherInfo_psd` hand over the matrix, its symmetry, and its
nullspace direction for free, and Mathlib's `Matrix.PosSemidef` is ready to
connect to.

### Direction 4: Bellman γ-contraction ⇒ unique fixed point at geometric rate

The discounted Bellman operator `T` on `Fin S → ℝ` with the sup norm is a
`γ`-contraction for `γ < 1`, giving `Tᵏ V → V⋆` with
`‖Tᵏ V − V⋆‖∞ ≤ γᵏ ‖V − V⋆‖∞` and uniqueness of `V⋆`. The key insight is that
finite `S` makes `Fin S → ℝ` a *complete* normed space off the shelf
(`Pi.normedAddCommGroup`, sup norm), so the entire fixed-point story reduces to
supplying one Lipschitz estimate `dist (T u) (T v) ≤ γ · dist u v` and then
reading off `ContractingWith.efixedPoint` and
`apriori_dist_iterate_efixedPoint_le` from Mathlib. Test: package the operator,
prove the contraction bound (max-of-expectations is nonexpansive, discount
scales by `γ`), and instantiate `ContractingWith γ T`; a non-expansive but
non-contractive averaged operator (`γ = 1`) would falsify uniqueness, sharpening
exactly which discounting is needed. Why now: `ContractingWith` already exists in
Mathlib and the completeness is automatic for finite `S`, so only the one-line
metric bound is missing — this upgrades any residual-decay story to a genuine
fixed-point-uniqueness + geometric-rate story.

### Direction 5: Pinsker + softmax positivity ⇒ KL trust-region monotonicity

For two softmax policies `π_old, π_new`, the KL
`KL(π_old‖π_new) = ∑_a π_old(a)(log π_old(a) − log π_new(a))` is well-defined and
nonnegative (Gibbs), and Pinsker `‖π_old − π_new‖₁² ≤ 2·KL` converts a KL trust
region into a total-variation bound that, with an advantage bound, yields
monotone improvement under `δ ≤ ε²(1−γ)³/(8γ)`. The key insight is that
`softmaxPolicy_pos` already discharges the well-definedness obligation that
blocks *every* finite KL formalization — there is no `log 0`, so `KL ≥ 0` and
`KL = 0 ↔ π_old = π_new` follow purely from strict convexity of `x ↦ x log x` on
the finite simplex. Test: prove `KL ≥ 0` and the equality case from
`softmaxPolicy_pos` and convexity, then formalize finite-distribution Pinsker as
a sum-of-squares / inner-product inequality; a counterexample to the specific
`δ` threshold would calibrate the trust-region constant rather than refute the
mechanism. Why now: positivity (the usual blocker) is already proved here, and
the catalog's KL/convexity tooling (`UltrametricKLDivergence`, the Gaussian KL
in `Gaussian.lean`) shows the surrounding machinery is in hand.
