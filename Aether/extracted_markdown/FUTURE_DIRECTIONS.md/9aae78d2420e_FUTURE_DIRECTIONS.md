# Future Directions: Policy Gradient Geometry & Variance Reduction

## Synthesis

This cycle built a self-contained, sorry-free Lean 4 formalization of the
*differential geometry of softmax policy gradients* and the *variance-reduction
theory of baselines*, living in `Catalog/MachineLearning/PolicyGradient/`. The
research direction proposed combining the catalog's softmax infrastructure
(`Tropical/NeuralNetworks/SoftMaxConvergence.lean`, the scalar
`softmax_jacobian_diag` in `Tropical/TropicalMoonshots.lean`) and Bellman/MDP
machinery (`MachineLearning/FactoredBellmanResidual.lean`) into new convergence
statements. A reality check on the catalog was decisive: the lemmas the concept
note *assumed* already existed (`variance_shift_invariant`,
`baseline_objective_quadratic`) do **not** exist anywhere in the project — they
were aspirational. So rather than "extend" phantom results, we built the missing
foundation from scratch, in the same spirit (finite action set `Fin n`, real
sums, `expectVal`), so the next cycle has genuine objects to build on.

The structural insight that emerged is that the entire first-order theory of
softmax PG is *purely algebraic over a finite probability vector* and needs no
measure theory: the score `ψ_j(a) = 1_{a=j} − π_j`, the log-derivative identity
`E_π[ψ_j] = 0`, the Fisher closed form `F = diag(π) − π πᵀ`, its PSD-ness as a
genuine variance `vᵀ F v = E_π[(⟨v,ψ⟩)²]`, and the optimal-baseline quadratic
`M(b) = A b² − 2B b + C` are all finite-sum facts. The single reusable engine is
"expand the square / product, push constants through `Finset.mul_sum`, collapse
indicators with `Finset.sum_ite_eq'`, and reduce to the sum-to-one law". This is
exactly why the optimal-baseline results dropped out of one lemma
(`variance_reduction_amount`, the completed square `M(b) − M(b⋆) = A·(b − b⋆)²`):
minimization, uniqueness, and the strict inequality are corollaries, not new work.

What did *not* go through cheaply: the Fisher PSD identity required a careful
triple-sum reordering (`Finset.sum_comm` twice with explicit `f :=` annotations)
rather than a one-shot `simp` — the automation found a proof but left an `exact?`
and a redundant `∀` wrapper, which we replaced with an explicit
`E_π[(∑_j v_j ψ_j)²]` realization. That friction is the signal: the matrix-level
(as opposed to scalar) facts are where the next hard theorems live, and they
want a clean `Finset`-indexed quadratic-form API.

## Results Summary

- `softmaxPolicy_pos`: proved — the softmax policy is strictly positive, so
  `log π` and KL divergences are everywhere finite (no `log 0`).
- `softmaxPolicy_sum_one`: proved — softmax is a genuine probability distribution.
- `softmaxScore_expect_zero`: proved — the log-derivative/REINFORCE identity
  `E_π[ψ_j] = 0`; the algebraic heart of every unbiased PG estimator.
- `fisherInfo_eq`: proved — closed form `F_{jk} = π_j δ_{jk} − π_j π_k`,
  generalizing the catalog's 2-action `softmax_jacobian_diag` to all `n` and to
  off-diagonal entries.
- `fisherInfo_symm`: proved — the Fisher matrix is symmetric.
- `fisherInfo_psd`: proved — `F` is positive semidefinite, realized as the
  variance `vᵀ F v = E_π[(⟨v, ψ(·)⟩)²] ≥ 0`; the rigorous license for the
  Fisher–Rao metric of natural PG.
- `baseline_unbiased`: proved — subtracting any constant baseline preserves the
  gradient mean (`E_π[(R − b)s] = E_π[R s]`), needing only `E_π[s] = 0`.
- `secondMoment_quadratic`: proved — the estimator's second moment is exactly
  `A b² − 2B b + C` with `A = E_π[s²], B = E_π[R s²], C = E_π[R² s²]`.
- `variance_reduction_amount`: proved — the exact gain `M(b) − M(b⋆) = A·(b−b⋆)²`.
- `optimal_baseline_min`: proved — `b⋆ = E_π[R s²]/E_π[s²]` minimizes the second
  moment (hence variance, by `baseline_unbiased`).
- `optimal_baseline_strict`: proved — `b⋆` is the *unique* minimizer; any other
  baseline is strictly worse.

## Research Directions

### Direction 1: The optimal-baseline variance ratio is `1 − ρ²`
**Hypothesis**: With `A = E_π[s²]`, `B = E_π[R s²]`, `C = E_π[R² s²]` and the
centered estimator's variance `V(b) = E_π[ĝ_b²] − (E_π[R s])²`, the optimal
baseline achieves `V(b⋆) / V(0) = 1 − ρ²`, where `ρ² = B² / (A·C')` is the
squared correlation between the return `R` and `s²`-weighted score mass
(`C'` the appropriate second moment). Equivalently `V(b⋆) = C − B²/A − (E_π[Rs])²`.
**Test**: State `variance b := secondMoment ... − (E_π[R s])²` and prove
`variance b⋆ = variance 0 · (1 − ρ²)` by substituting the completed square from
`variance_reduction_amount` and dividing (guarding `V(0) ≠ 0`). A disproof would
be a finite `(p, R, s)` example where the ratio exceeds `1 − ρ²`.
**Why now**: `variance_reduction_amount` already gives the exact numerator gain
`A(b−b⋆)²`; only the normalization and a Cauchy–Schwarz bound (`B² ≤ A·C`,
provable from `fisherInfo_psd`-style sum-of-squares) remain.
**If true**: it ports the textbook control-variate bound into Lean with an exact
constant, closing the loop on "how much does a baseline help".
**If false**: the failure pinpoints exactly which independence/centering
hypothesis the `1 − ρ²` folklore silently assumes.

### Direction 2: State-dependent baselines and `b⋆(s) = V^π(s)`
**Hypothesis**: For an estimator stratified by state `s` with conditional scores
`ψ(·|s)` satisfying `E[ψ|s] = 0`, the per-state optimal baseline is independent
across states and equals the conditional second-moment ratio; under compatible
features this collapses to the value function `V^π(s)`.
**Test**: Generalize `expectVal` to a product index `State × Action`, prove a
conditional version of `baseline_unbiased` and `optimal_baseline_min` per state,
then a tensorized total-variance decomposition `Var = E[Var(·|s)] + Var(E[·|s])`.
**Why now**: `optimal_baseline_min/strict` are already stated for an *arbitrary*
distribution `p` and arbitrary `R, s`; instantiating `p` as a conditional slice
is immediate, and `FactoredBellmanResidual.finSupNorm` shows the product-index
`Finset` machinery is in hand.
**If true**: it yields the first Lean proof that the value baseline is optimal,
the cornerstone of actor-critic.
**If false**: reveals that cross-state coupling (shared parameters) breaks
separable optimality — itself a sharp, publishable boundary.

### Direction 3: Natural gradient = preconditioning, with `F⁺ F` a projection
**Hypothesis**: Using the closed form `F = diag(π) − π πᵀ`, the Moore–Penrose
pseudoinverse `F⁺` satisfies `F⁺ F = I − (1/n)·𝟙𝟙ᵀ` on the tangent space
`{v : ⟨π·,v⟩ structure}`, so the natural gradient `F⁺ ∇J` is the Euclidean
gradient projected orthogonally to the all-ones direction (softmax gauge).
**Test**: Work in `Matrix (Fin n) (Fin n) ℝ`; prove `F = diag π − π ⬝ πᵀ`,
that `𝟙` is in `ker F` (since rows sum to zero — a direct corollary of
`softmaxScore_expect_zero`), and characterize `range F = 𝟙^⊥`. Then show the
natural-gradient update is gauge-invariant under `z ↦ z + c·𝟙`.
**Why now**: `fisherInfo_eq` and `fisherInfo_psd` give the matrix and its
nullspace direction for free; Mathlib has `Matrix.PosSemidef` and pseudoinverse
support to connect to.
**If true**: it formalizes the central claim of natural PG — that it is a
reparameterization-invariant steepest descent — at the matrix level.
**If false**: the nullspace/rank computation would expose a degeneracy (e.g. a
boundary policy with a zero coordinate) that the strict-positivity
`softmaxPolicy_pos` is supposed to rule out.

### Direction 4: Bellman γ-contraction ⇒ unique fixed point, geometric rate
**Hypothesis**: The discounted Bellman operator `T` on `(Fin S → ℝ)` with the
sup norm is a `γ`-contraction (`γ < 1`), hence `Tᵏ V → V⋆` with
`‖Tᵏ V − V⋆‖∞ ≤ γᵏ ‖V − V⋆‖∞`, and `V⋆` is unique.
**Test**: Equip `Fin S → ℝ` with `Pi.normedAddCommGroup` (sup norm), package the
contraction as Mathlib `ContractingWith γ T`, and read off `efixedPoint`,
`apriori_dist_iterate_efixedPoint_le`. The catalog's `bellmanOp_monotone`
(`Tropical/TropicalMoonshots.lean`) and `FactoredBellmanResidual`'s residual
decay are the warm-up; the missing piece is the metric contraction bound.
**Why now**: finite `S` makes `Fin S → ℝ` a complete normed space off the shelf,
and `ContractingWith` exists in Mathlib — only the `dist (T u) (T v) ≤ γ dist u v`
lemma must be supplied.
**If true**: it upgrades the catalog's *residual-decay* story to a *fixed-point
uniqueness + geometric-rate* story, enabling certified value iteration.
**If false** (e.g. for a non-expansive but non-contractive averaged operator):
it sharpens exactly which discounting is needed for uniqueness.

### Direction 5: Pinsker + softmax positivity ⇒ KL trust-region monotonicity
**Hypothesis**: For two softmax policies `π_old, π_new`, the KL
`KL(π_old‖π_new) = ∑_a π_old(a)(log π_old(a) − log π_new(a))` is well-defined and
nonnegative (Gibbs' inequality), and Pinsker `‖π_old − π_new‖₁² ≤ 2·KL` gives a
total-variation bound that, combined with an advantage bound, yields monotone
improvement under a tight KL constraint `δ ≤ ε²(1−γ)³/(8γ)`.
**Test**: First prove `KL ≥ 0` and `KL = 0 ↔ π_old = π_new` from
`softmaxPolicy_pos` (finiteness) and convexity of `x log x`; then formalize
Pinsker for finite distributions (sum-of-squares / `inner_mul_le_norm_mul_norm`).
**Why now**: `softmaxPolicy_pos` already discharges the "no `log 0`"
well-definedness obligation that blocks every KL formalization; the catalog's
`klBernoulli` and `max_entropy_is_uniform` show the convexity tooling is present.
**If true**: provides the analytic backbone for a TRPO monotonic-improvement
proof.
**If false**: a counterexample to the specific `δ` threshold would calibrate the
constant in the trust-region bound.
