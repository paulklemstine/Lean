# Future Directions — Information-Geometric Bridge (Fisher metric, deepened)

This cycle deepened the catalog's `Bridges.FisherInformationRiemannian` (Fisher
metric = Riemannian metric + KL bridge) and `FisherInformationMetric` (categorical
Fisher form + KL sandwich) into a full inference-geometry package in
`Catalog/Bridges/FisherCramerRao.lean`:

- generalized the statistical model from sample space `Fin n` to an arbitrary finite
  type `S` (`GenStatModel`), re-deriving the metric axioms (`gfisher_symm`,
  `gfisher_posSemidef`, `gfisher_posDef`);
- proved **tensorization / additivity** of Fisher information over independent data
  (`gfisher_prod_eq`, `gfisher_iid_two`);
- proved the **Cramér–Rao lower bound** (`cramer_rao`, `cramer_rao_unbiased`) via a
  weighted Cauchy–Schwarz inequality (`expect_mul_sq_le`);
- proved the **tensorial transformation law** `G' = Jᵀ G J` (`gfisher_reparam`),
  certifying `gfisher` is a genuine `(0,2)`-tensor;
- proved the **attainment / efficiency** equality case (`cramer_rao_equality_iff`):
  equality holds iff the centered statistic is proportional to the score.

The following conjectures extend this work. Each is stated so it can be written down
as a Lean theorem and either proved or refuted.

## 1. The multiparameter matrix Cramér–Rao bound

For a `GenStatModel S d` and a vector statistic `T : S → ℝ` with gradient-of-mean
`b : Fin d → ℝ` satisfying the regularity identities `b i = E_θ[T · score_i]`, the
scalar bound should upgrade to the **matrix inequality** `Var_θ(T) ≥ bᵀ G⁻¹ b`
whenever `G = gfisher M θ` is positive definite, with equality characterized exactly
as in `cramer_rao_equality_iff` but with the proportionality constant replaced by the
vector `G⁻¹ b`.

The key insight is that the single-parameter proof is just the rank-1 shadow of the
positive-semidefiniteness of the `(d+1)×(d+1)` Gram matrix of the family
`{T − E[T], score_1, …, score_d}` under the inner product `⟨f, g⟩ = E_θ[f g]`; the
matrix bound is the Schur-complement nonnegativity of that Gram matrix, so the whole
result reduces to `gfisher_posSemidef` applied to an augmented model. Why now?
`gfisher_posSemidef` and `expect_mul_sq_le` are already proved in full generality over
arbitrary finite `S`, and Mathlib's `Matrix.PosSemidef` plus Schur-complement API give
exactly the linear-algebra layer needed to glue them together.

## 2. Chain rule / monotonicity of Fisher information under coarse-graining

Let `κ : S → S'` be a deterministic statistic (data-processing map) and let `N` be
the pushforward model `N.p θ y = ∑_{x : κ x = y} M.p θ x`. Then the Fisher matrices
should satisfy the **monotonicity** `gfisher N θ ⪯ gfisher M θ` (Loewner order), with
equality iff `κ` is sufficient. This is the information-geometric form of the
data-processing inequality and the converse half of the Fisher–Rao characterization
of sufficiency.

The key insight is that the pushforward score is the conditional expectation of the
original score, `score_N(κ x) = E[score_M ∣ κ]`, so the gap `gfisher M − gfisher N` is
exactly the expected Fisher quadratic form of the *within-fiber* fluctuation of the
score — a conditional variance, hence positive semidefinite. Why now? The additivity
theorem `gfisher_prod_eq` already exercises the "sum over a product / factor the
expectation" machinery this needs, and the conditional-variance decomposition is a
finite-sum identity squarely in reach of the same `Finset.sum_comm` / `sum_mul_sum`
toolkit used there.

## 3. The KL Hessian equals the Fisher metric, made exact on a curve

The catalog records the *global* KL sandwich `0 ≤ KL ≤ χ² = Fisher quadratic form`.
The missing *infinitesimal* companion: along any smooth curve `t ↦ θ(t)` with
`θ(0) = θ₀`, the function `t ↦ KL(p_{θ₀} ‖ p_{θ(t)})` has a vanishing first derivative
and second derivative equal to `vᵀ G(θ₀) v` where `v = θ'(0)`, i.e. the Fisher metric
is *literally* the Hessian of KL at the diagonal.

The key insight is that the file's `gfisher_eq_neg_expected_hessian`-style identity
(`G = −E[∂² log p]`) is precisely the second-order Taylor coefficient of KL, so the
statement is a clean second-derivative computation once `p` is given `C²` regularity
hypotheses on a one-parameter family. Why now? With `gfisher_reparam` we can already
restrict any model to a one-parameter curve and read off the induced `1×1` Fisher
value, so the only new ingredient is Mathlib's `deriv`/`iteratedDeriv` calculus glued
to the existing finite-sum score identities.

## 4. Exponential families are exactly the Cramér–Rao-efficient models

`cramer_rao_equality_iff` shows equality at a single `θ` forces `T − E_θ[T] = c(θ)·S`.
Conjecture: a statistic `T` attains the Cramér–Rao bound *for all `θ` simultaneously*
iff the model is a **one-parameter exponential family** `p(x; θ) = h(x) exp(η(θ) T(x) −
A(θ))` with `T` its natural sufficient statistic, and then the efficient estimator's
variance is exactly `1 / G(θ)`.

The key insight is that the pointwise proportionality `score = c(θ)(T − E_θ[T])` is a
*differential equation in `θ`* for `log p`, whose integral is precisely the
exponential-family form; the existing equality lemma supplies the pointwise condition,
and integrating it is the only remaining step. Why now? The forward implication of
this characterization is already fully formalized (`cramer_rao_equality_iff`), so the
conjecture is reduced to a clean integrability/uniqueness statement rather than an
open-ended search.

## 5. Tensorization rate and the asymptotics of the i.i.d. Cramér–Rao bound

Combining `gfisher_iid_two` (information doubles for two copies) with `cramer_rao`,
the variance bound for `n` i.i.d. observations is `1 / (n · G(θ))`. Conjecture: define
the `n`-fold product model `prodModel^{[n]}` and prove `gfisher (prodModel^{[n]} M) θ =
n • gfisher M θ`, hence the **`1/n` Cramér–Rao decay** `Var ≥ 1/(n G)`, the quantitative
backbone of asymptotic efficiency and the `√n`-consistency of the MLE.

The key insight is that `gfisher_prod_eq` is *associative and commutative* as a binary
operation on Fisher matrices, so the `n`-fold statement is a one-line induction on the
already-proven two-fold additivity — no new analytic content, only the bookkeeping of
an indexed product sample space. Why now? `gfisher_prod_eq` is proved over arbitrary
finite `S` (so the product `S^n` is itself a legal sample space), making the inductive
step immediate; this turns the static "metric" result into a genuine large-sample
statement.
