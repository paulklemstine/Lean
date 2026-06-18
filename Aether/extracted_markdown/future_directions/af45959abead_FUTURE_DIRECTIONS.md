# Future Directions — Information-Geometric Bridge

This cycle added `Catalog/Bridges/FisherGeometryBridge.lean`, which upgrades the
Fisher information form from a *positive-definite* bilinear form (already in
`Speculative.AutoResearch.FisherInformationMetric`) to a *genuine inner product*
satisfying Cauchy–Schwarz, and harvests three statistical payoffs: the
total-variation bound `tv_sq_le_fisher` (`TV² ≤ χ² = Fisher`), the complete
divergence sandwich `divergence_sandwich` (`½·TV² ≤ KL ≤ Fisher`), the Jeffreys
(symmetrized KL) bounds, and the **Cramér–Rao bound** `cramer_rao`
(`1 ≤ Var(T)·Fisher`) on the parametric `StatModel` of
`Bridges.FisherInformationRiemannian`. The following directions extend this work;
each is stated so that it can be falsified by a single counterexample or settled by
a single Lean proof.

## 1. Matrix Cramér–Rao for multi-parameter models (`d ≥ 2`)

Our `cramer_rao` is the scalar (`d = 1`) case. The full theorem states that for an
unbiased estimator vector `T : Fin n → (Fin d → ℝ)` of the parameter `θ ∈ ℝ^d`, the
covariance matrix `Σ(T)` and the Fisher matrix `G = fisher M θ` satisfy the
Loewner-order inequality `Σ(T) ⪰ G⁻¹`, equivalently `vᵀ Σ v · vᵀ G v ≥ (vᵀ v)²` for
every direction `v`, with equality iff `T` is an efficient (score-proportional)
estimator. **The key insight is** that the scalar bound is exactly the `v`-directional
slice of the matrix bound, so the matrix statement follows by applying
`weighted_cauchy_schwarz` to the *projected* statistic `⟨v, T⟩` and the *projected*
score `∑ᵢ vᵢ · scoreᵢ` — no new analytic input is needed, only a clean Loewner-order
wrapper. **Why now?** The directional scalar inequality and the weighted CS engine
are already proven and reusable verbatim; the only missing piece is the linear-algebra
packaging (`Matrix.PosSemidef` and the Schur-complement characterization of
`Σ ⪰ G⁻¹`), all of which exists in Mathlib.

## 2. The χ²-to-KL gap is governed by the Fisher curvature, not just bounded by it

We proved `KL ≤ χ² = Fisher`. The conjecture is the sharper *reverse-and-remainder*
statement: `χ²(p‖q) − KL(p‖q) = ½·∑ᵢ (pᵢ−qᵢ)²/qᵢ · O(‖p−q‖)` and, more precisely,
that along any line `qₜ = q + t(p−q)` the function `t ↦ KL(qₜ‖q)` has second derivative
at `t = 0` exactly equal to `fisherForm q (p−q) (p−q)` — i.e. the Fisher form is
*literally* the Hessian of KL, upgrading the global sandwich to a local identity.
**The key insight is** that `divergence_sandwich` already pins `KL` between `½·TV²` and
`χ²`, both of which are second-order in `p−q`, so the second derivative of `KL` is
trapped between two computable quadratic forms that coincide — forcing the Hessian to
equal the Fisher form by squeeze. **Why now?** `FisherInformationRiemannian` already
contains `fisher_eq_neg_expected_hessian` (the "two forms of Fisher information"
identity); combining it with our quadratic sandwich turns an infinitesimal heuristic
into a provable `deriv`/`iteratedDeriv` statement using Mathlib's one-variable calculus.

## 3. A data-processing (monotonicity) inequality for the Fisher quadratic form

For any Markov kernel / stochastic matrix `K` (columns are probability vectors),
push-forward `p ↦ K·p` contracts every f-divergence; the conjecture isolates the
Fisher/χ² case: `fisherForm (K·q) (K·p − K·q) (K·p − K·q) ≤ fisherForm q (p−q) (p−q)`.
**The key insight is** that `K·v / √(K·q)` is a conditional expectation of `v/√q` in the
`q`-weighted inner product, so the contraction is *exactly* the operator-norm-≤-1
property of conditional expectation — which is itself a Cauchy–Schwarz statement, the
very tool `weighted_cauchy_schwarz` already encapsulates. **Why now?** The existing
`Bridges/FisherMonotonicity.lean` already targets monotonicity phenomena; expressing
the kernel action with `Matrix.mulVec` and reusing `weighted_cauchy_schwarz` per output
coordinate gives a fully finite, `Fintype`-level proof with no measure theory.

## 4. Efficiency / equality characterization in Cauchy–Schwarz ⇒ exponential families

`fisherForm_cauchy_schwarz` is an inequality; the conjecture is its *equality case*:
`g(v,w)² = g(v,v)·g(w,w)` iff `v` and `w` are parallel as score vectors, and—pulled
back to statistics—the Cramér–Rao bound `cramer_rao` is attained with equality iff the
estimator `T` is an affine function of the score, i.e. iff the model is a
one-parameter **exponential family** at `θ`. **The key insight is** that
`sum_mul_sq_le_sq_mul_sq` attains equality exactly when the two vectors `√pᵢ·aᵢ` and
`√pᵢ·bᵢ` are linearly dependent, which translates directly into `T − E[T] ∝ score`, the
defining first-order condition of efficiency. **Why now?** Mathlib's
`inner_mul_le_norm_mul_norm` equality lemmas (and `sum_mul_sq_le_sq_mul_sq` equality
analysis) make the parallelism condition formalizable, turning a textbook remark into a
sharp iff and connecting our metric file to the catalog's exponential-family algebra.

## 5. Rényi/α-divergence interpolation between the sandwich endpoints

The Rényi divergence `D_α(p‖q)` interpolates: `D_{1/2}` is governed by squared Hellinger
(hence by `TV`), `D_1 = KL`, and `D_2 = log(1 + χ²)`. The conjecture is a *monotone
interpolation theorem*: `α ↦ D_α(p‖q)` is nondecreasing and our sandwich
`½·TV² ≤ KL ≤ χ²` is the `α ∈ {1/2, 1, 2}` shadow of the single inequality
`D_{1/2} ≤ D_1 ≤ D_2`. **The key insight is** that monotonicity of `D_α` in `α` is
itself a Hölder/Cauchy–Schwarz statement on the moments `∑ pᵢ (pᵢ/qᵢ)^{α−1}`, so the
same `sum_mul_sq_le_sq_mul_sq` (with Hölder for general exponents) that proved the
endpoints proves the whole monotone family. **Why now?** Defining `D_α` for finite
`Fintype` models needs only `Real.rpow` (already in Mathlib), and the endpoint cases are
already discharged in `FisherInformationMetric` and this file, giving immediate sanity
checks for the interpolating statement.
