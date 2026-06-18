# Future Directions: Monotonicity and the Geometry of the Fisher Metric

The new module `Catalog/Bridges/FisherMonotonicity.lean` adds two deep pillars to
the catalog's information-geometry programme (`FisherInformationRiemannian.lean`,
`FisherCramerRao.lean`): the **directional / multiparameter Cramér–Rao bound**
(`cramer_rao_directional`) and **Chentsov monotonicity**, i.e. the data-processing
inequality for the Fisher metric (`fisher_monotone_coarsegrain`,
`gfisher_pushModel_le`). The latter packages the coarse-grained model `T_*M` as a
genuine `GenStatModel` (`pushModel`) carrying the conditional-expectation score
`E[score | T]`, and proves the Loewner inequality `G(T_*M) ⪯ G(M)`. These results
open several concrete, falsifiable next steps.

## 1. The Loewner matrix Cramér–Rao bound `Σ ⪰ A Gᵀ¹ Aᵀ`

The directional bound `cramer_rao_directional` gives, for every pair of vectors
`u, w`, the bilinear inequality `(uᵀ A w)² ≤ (uᵀ Σ u)(wᵀ G w)`, where `Σ` is the
covariance matrix of a vector statistic, `A` its sensitivity matrix, and `G` the
Fisher matrix. The conjecture is that optimizing over `w` yields the full matrix
(Loewner) bound `Σ - A G⁻¹ Aᵀ ⪰ 0` whenever `G` is positive definite, and that
equality holds exactly when the centered statistic lies in the span of the scores
(the vector efficiency case, extending `cramer_rao_equality_iff`).

**The key insight is** that the optimal direction is `w = G⁻¹ Aᵀ u`, which turns the
scalar bound into the Schur-complement positivity of the joint covariance matrix
`[[Σ, A], [Aᵀ, G]]` — so the matrix bound is *not* a new inequality but the
quadratic-form bound evaluated at its minimizer. **Why now?** `cramer_rao_directional`
already supplies the bilinear inequality for *all* `w`; the only missing ingredient
is finiteness/invertibility of `G` (available from `gfisher_posDef`), so the matrix
form is one quantifier-elimination step away rather than a fresh analytic argument.

## 2. Equality in monotonicity characterizes sufficient statistics

`gfisher_pushModel_le` says coarse-graining never increases Fisher information. The
conjecture is the equality case: `G(T_*M)(θ) = G(M)(θ)` for all `θ` (in the Loewner
sense) **iff** `T` is a *sufficient statistic* for the family `M` — equivalently,
iff the score `s(x)` is `T`-measurable, i.e. `s(x) = E[s | T](T x)` pointwise.

**The key insight is** that equality in the fibrewise Cauchy–Schwarz lemma
`fiber_cauchy_schwarz` forces the score to be constant on each fiber `T⁻¹(y)`, which
is precisely first-order (local) sufficiency; the global Fisher–Neyman factorization
is its integrated form. **Why now?** The proof of `fisher_monotone_coarsegrain`
already isolates the gap as a sum of per-fiber Cauchy–Schwarz defects, and the
catalog's `cramer_rao_equality_iff` shows the team can already handle equality cases
of Cauchy–Schwarz over finite sample spaces — the fiberwise version is the same
argument localized to `T⁻¹(y)`.

## 3. From deterministic statistics to Markov-kernel coarse-graining

`pushModel` handles a *deterministic* statistic `T : S → S'`. The conjecture is the
full data-processing inequality: for any **stochastic kernel** `K : S → (S' → ℝ)`
with `K x ≥ 0` and `∑_{y} K x y = 1`, the channel pushforward
`(K_*M).p θ y = ∑_x M.p θ x · K x y` again satisfies `G(K_*M) ⪯ G(M)`.

**The key insight is** that a Markov kernel is a convex combination of deterministic
maps (Birkhoff–von Neumann / the deterministic-extreme-point decomposition of the
transportation polytope), and the Fisher quadratic form is *jointly convex* in
`(p, p·score)` via the perspective function `(a,b) ↦ b²/a`; monotonicity under each
deterministic vertex (already proved here) plus convexity gives the kernel case.
**Why now?** `fiber_cauchy_schwarz` is exactly the statement that `b²/a` is convex
(its one-fiber instance), so the convexity engine needed for the kernel
generalization is already in the file — only the averaging over vertices is new.

## 4. Chentsov uniqueness: the Fisher metric is the *only* monotone metric

Chentsov's theorem states that, up to a positive scalar, the Fisher metric is the
unique Riemannian metric on statistical manifolds that is monotone under all Markov
morphisms. With monotonicity now formalized (Direction 3 supplying the morphism
side), the conjecture is the converse rigidity: any family of inner products
`g_θ(·,·)` on tangent spaces that contracts under every coarse-graining `T` must be
a scalar multiple of `gfisher`.

**The key insight is** that monotonicity under the *embeddings* `S ↪ S × S'` and the
*projections* `S × S' → S` pins the metric on the simplex up to scale, because the
symmetric group acting on a uniform refinement leaves only the Fisher form
invariant (a representation-theoretic rigidity on the permutation action). **Why
now?** The catalog already contains substantial finite-group and representation
machinery (e.g. the `ClassicalGroupExpanders` and Cayley-graph modules), so the
symmetry-reduction core of Chentsov's uniqueness can reuse existing group-action
lemmas rather than building them from scratch.

## 5. The dual-affine (α-connection) geometry and the KL Pythagorean theorem

`FisherInformationRiemannian.lean` already identifies the Fisher metric with the
Hessian of KL divergence at the diagonal. The conjecture promotes this to the full
**dually flat** structure: the exponential (`e`) and mixture (`m`) connections are
torsion-free, mutually dual with respect to `gfisher`, and KL is their canonical
divergence, yielding the **generalized Pythagorean theorem**
`KL(p‖r) = KL(p‖q) + KL(q‖r)` whenever the `m`-geodesic `p→q` meets the `e`-geodesic
`q→r` orthogonally in `gfisher`.

**The key insight is** that for finite sample spaces the `e`- and `m`-geodesics are
explicit one-parameter curves (log-linear and linear interpolations of the
probability vectors), so duality `∂g = ⟨∇^e ·, ·⟩ + ⟨·, ∇^m ·⟩` and the Pythagorean
identity reduce to the convexity/Bregman algebra of `KL_nonneg`, which is *already
proved* in the catalog. **Why now?** The hardest analytic obstacle — Gibbs'
inequality and the Hessian-of-KL identity — is already discharged in
`FisherInformationRiemannian.lean`; the remaining work is the (finite-dimensional,
purely algebraic) bookkeeping of two affine connections, which the team's
sum-manipulation tooling handles routinely.
