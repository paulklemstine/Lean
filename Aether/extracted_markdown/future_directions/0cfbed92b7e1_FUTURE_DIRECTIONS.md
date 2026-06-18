# Future Directions — Information-Geometric Bridge: Fisher Metric on Statistical Manifolds

The module `Catalog/Bridges/FisherInformationRiemannian.lean` constructs the Fisher
information matrix of a finite-sample-space statistical model *from* its probability
densities and *derives* the Riemannian-metric axioms (symmetry, positive
semidefiniteness, and positive definiteness under score nondegeneracy). It then bridges
to statistical inference and differential geometry: Fisher equals the covariance of the
zero-mean score, Fisher equals the negative expected Hessian of the log-likelihood (the
"two forms of Fisher information"), and the Kullback–Leibler divergence is shown to be
nonnegative (Gibbs) and to vanish on the diagonal. The worked Bernoulli instance pins
the abstraction to a closed-form computation `G(θ) = dσ²/(σ(1−σ))`. This extends the
axiomatic `MetricTensor`/Bregman picture of `Bridges.InformationGeometryOptimization`,
which *assumes* a positive-definite Fisher tensor rather than building one.

Below are five testable, falsifiable directions that the next cycle should pursue.

## 1. The Fisher metric is exactly the local Hessian of KL (analytic, not just algebraic)

Our `fisher_eq_neg_expected_hessian` encodes the curvature–information identity through
hypothesized first- and second-order score fields. The natural strengthening is to
replace those hypotheses by genuine Mathlib `deriv`/`fderiv` objects: take a model
`p : ℝ → Fin n → ℝ` smooth in θ, define `KL θ θ' = ∑ x, p θ x * log (p θ x / p θ' x)`,
and prove `deriv (deriv (fun s => KL θ s)) θ = ∑ x, p θ x * (∂ log p)²`, i.e. the second
derivative of `θ' ↦ KL(θ‖θ')` at the diagonal equals the Fisher quadratic form.
**The key insight is** that the two regularity hypotheses we currently *assume*
(`chain` and `secondReg`) are precisely the statements `∂² log p = ∂²p/p − (∂ log p)²`
and `∑_x ∂² p = 0`, both of which are *theorems* once `∑_x p = 1` is differentiated twice
under the finite sum — so the analytic version is fully within reach of Mathlib's
`deriv_sum` and `Real.deriv_log`. **Why now?** Mathlib v4.28 has mature one-variable
calculus (`deriv`, `HasDerivAt`, chain rule, `deriv_log`), and the sample space is finite,
so no measure-theoretic dominated-convergence machinery is needed — the entire argument is
a finite sum of elementary derivatives.

## 2. Cramér–Rao from positive definiteness: the variance lower bound

We have proved `fisher_posDef`; the canonical payoff is the Cramér–Rao inequality:
for any unbiased estimator `T : Fin n → ℝ` of a scalar functional, the variance is bounded
below by the inverse Fisher information, `Var_θ(T) ≥ 1 / G(θ)`. **The key insight is** that
Cramér–Rao is nothing more than the Cauchy–Schwarz inequality between the centered
estimator `T − E_θ[T]` and the score `s` in the `p θ`-weighted inner product, combined with
the unbiasedness identity `E_θ[(T − E[T])·s] = 1`; both factors already live in our
`StatModel` vocabulary. **Why now?** This connects directly to the existing
`MachineLearning/PadicCramerRao.lean` (a p-adic/ultrametric Cramér–Rao theory) and would
give the *real-analytic* Archimedean counterpart in the same catalog, turning two isolated
files into a genuine cross-domain bridge (estimation theory ↔ Riemannian geometry ↔
non-Archimedean analysis).

## 3. Reparametrization covariance of the constructed metric

`InformationGeometryOptimization.transformed_metric_symmetric` shows an *abstract* tensor
transforms correctly; we should prove the analogous *constructed* statement: pushing a
`StatModel` through a diffeomorphic reparametrization `θ = φ(α)` transforms our `fisher`
by the Jacobian as `G^α_{kl} = ∑_{ij} J_{ik} J_{jl} G^θ_{ij}`, exhibiting the Fisher
matrix as a genuine `(0,2)`-tensor field. **The key insight is** that the score obeys the
chain rule `s^α_k = ∑_i J_{ik} s^θ_i`, so the transformation law for `fisher` is a pure
algebraic consequence of bilinearity of the defining sum — no new analysis is required,
only careful bookkeeping of the Jacobian. **Why now?** With `fisher` now defined
concretely (not axiomatically), this is the first opportunity in the catalog to *prove*
tensoriality rather than assume it, closing the gap between the abstract `MetricTensor`
structure and the model-derived metric.

## 4. KL equality case and the strict data-processing inequality

We proved `KL_nonneg` and `KL_self_zero`; the sharp companion is the equality
characterization `KL(p‖q) = 0 ↔ p = q`, followed by the *strict* data-processing
inequality: applying a stochastic map (Markov kernel) `M` cannot increase KL, and equality
forces sufficiency. **The key insight is** that the equality case of Gibbs follows from the
*strict* concavity of `log` (equality in `log t ≤ t − 1` holds only at `t = 1`), which
Mathlib exposes via `Real.add_one_le_exp` with its strict version; the data-processing
step is then convexity of the KL summand transported across the kernel. **Why now?** The
joint-convexity API for `Real.log`/`Real.exp` is well-developed in current Mathlib, and a
finite kernel is just a column-stochastic matrix, so the entire chain is finite linear
algebra plus one strict-convexity lemma — a self-contained, high-value addition.

## 5. The α-connection family and a provable dually-flat Pythagorean identity

`InformationGeometryOptimization` poses `ExpFamilyEFlat` as a conjecture. With the
concrete `StatModel` machinery we can instead *verify*, for the exponential family
`p(x;θ) ∝ exp(∑_i θ_i T_i(x) − A(θ))`, that the score is `s_i = T_i − ∂_i A`, that the
Fisher matrix equals the Hessian `∂²A` of the log-partition function, and that the induced
e-connection Christoffel symbols vanish in the natural parameters — establishing
e-flatness as a theorem. **The key insight is** that for exponential families the Fisher
metric *is* the Hessian of the convex potential `A`, which is exactly the Bregman/mirror
geometry already formalized in `InformationGeometryOptimization.BregmanDivergence`, so the
Amari dually-flat structure and the existing Bregman three-point identity are two views of
the same object. **Why now?** Unifying the (previously unconnected) Bregman file and this
Fisher file would let the next cycle prove the information-geometric Pythagorean theorem
`KL(p‖r) = KL(p‖q) + KL(q‖r)` for e-/m-geodesic triangles — a flagship cross-domain result
that is currently out of reach of either file alone.
