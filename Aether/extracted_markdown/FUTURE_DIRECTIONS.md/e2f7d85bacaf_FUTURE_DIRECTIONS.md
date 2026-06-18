# Future Directions — A Constructive, Finite-Alphabet Fisher–Rao Programme

## Synthesis

This cycle rebuilt the Fisher–Rao information geometry of the probability simplex
*from the ground up* over an arbitrary finite alphabet `ι`, with **zero** dependence
on measure theory, manifolds, or the (incomplete) `Bridges/FisherMonotonicity`
chain that ships broken in the catalog (its dependency `Bridges/FisherCramerRao`
does not exist in this snapshot). The new module
`Catalog/Logic/FisherSimplexBridge.lean` is fully self-contained on Mathlib and
proves five pillars with `sorry = 0` and only the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`):

- `fisherForm_self_nonneg` and `fisherForm_self_eq_zero_iff` — the Riemannian
  positivity and non-degeneracy of `Q_p(u) = ∑_i u_i²/p_i`;
- `fisherForm_cauchy_schwarz` — the inner-product (Cauchy–Schwarz) law
  `g_p(u,v)² ≤ g_p(u,u)·g_p(v,v)`;
- `fisherForm_self_eq_chiSq` — the exact identification of the Fisher quadratic
  form with the χ²-divergence of the displaced law `p + u`;
- `fisher_monotone_coarsegrain` — **Chentsov monotonicity / data processing**:
  every deterministic coarse-graining `T : ι → κ` contracts the Fisher form;
- `cramer_rao_finite` — the finite, directional Cramér–Rao bound coupling Fisher
  information to estimator variance.

The single structural engine behind all of them is one weighted Cauchy–Schwarz
(`Finset.sum_mul_sq_le_sq_mul_sq`) with weights `u_i/√p_i` and `√p_i`, plus
`Finset.sum_fiberwise` for the fiber decomposition. This unification is itself the
main qualitative discovery: positivity, the inner product, data processing, and
Cramér–Rao are *the same inequality* read on four different pairs of vectors.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `fisherForm_self_nonneg` | `0 ≤ Q_p(u)` | proved |
| `fisherForm_self_eq_zero_iff` | `Q_p(u) = 0 ↔ u ≡ 0` | proved |
| `fisherForm_cauchy_schwarz` | `g_p(u,v)² ≤ Q_p(u)·Q_p(v)` | proved |
| `fisherForm_self_eq_chiSq` | `Q_p(q−p) = χ²(q‖p)` | proved |
| `fisher_monotone_coarsegrain` | `∑_y (T_*u)_y²/(T_*p)_y ≤ Q_p(u)` | proved |
| `cramer_rao_finite` | `(∑_i u_i f_i)² ≤ Q_p(u)·Var_p(f)` | proved |

## Research Directions

### 1. Equality case of Chentsov monotonicity (sufficiency of a statistic)

Conjecture: `∑_y (T_*u)_y²/(T_*p)_y = Q_p(u)` if and only if the tangent vector `u`
is *fiberwise proportional to* `p`, i.e. there is a function `c : κ → ℝ` with
`u_i = c(T i) · p_i` for every `i`. This is the differential-geometric statement
that the coarse-graining `T` loses no Fisher information exactly when the deviation
lies along the conditional-mean direction (a sufficiency condition).
The key insight is that `fisher_monotone_coarsegrain` was proved by a *per-fiber*
Cauchy–Schwarz, and Cauchy–Schwarz is tight precisely when the two vectors
(`√p_i` and `u_i/√p_i` on each fiber) are proportional — so the equality classifier
is already latent in the existing proof and only needs the equality case of
`Finset.sum_mul_sq_le_sq_mul_sq` (or `inner_mul_le_norm_mul_norm`).
Why now? The monotonicity inequality is freshly formalized and its proof exposes the
exact fiber where slack is created; extracting the equality condition is the natural
and immediately falsifiable next step (a single small counterexample on `|ι| = 3`,
`|κ| = 2` would refute a wrong proportionality constant).

### 2. The Fisher metric as the literal Hessian of KL divergence

Conjecture: for the discrete relative entropy `D(p‖q) = ∑_i p_i log(p_i/q_i)`, the
second-order expansion along a tangent `u` (with `∑ u_i = 0`) satisfies
`D(p ‖ p + t·u) = (t²/2)·Q_p(u) + o(t²)` as `t → 0`, and more strongly the Hessian
of `q ↦ D(p‖q)` at `q = p` equals the Fisher form `g_p`.
The key insight is that `fisherForm_self_eq_chiSq` already pins `Q_p` to the χ²
divergence, and χ² is the leading quadratic term of *every* f-divergence including
KL; so the bridge to KL is a one-variable Taylor estimate of `t ↦ -log(1 + t·u_i/p_i)`
fed termwise into the existing χ² identity, not a new global argument.
Why now? Mathlib has `Real.add_pow_le_pow_mul_pow_of_sq_le_sq`-style and
`Real.log` convexity machinery, and the χ² identity is in hand this cycle, making the
quadratic-remainder bound a concrete, testable analytic lemma rather than open theory.

### 3. Uniqueness: monotone metrics on the finite simplex are scalar multiples of Fisher

Conjecture (finite Chentsov): any family of inner products `h_p` on the tangent
space `{u : ∑ u_i = 0}` that is *monotone* under all deterministic statistics `T`
(in the sense `h_{T_*p}(T_*u) ≤ h_p(u)`) and *invariant* under alphabet permutations
must equal `λ · g_p` for a single constant `λ ≥ 0`.
The key insight is that the data-processing inequality `fisher_monotone_coarsegrain`
plus the permutation symmetry of `fisherForm` are exactly the two hypotheses
Chentsov's theorem consumes; over a *finite* alphabet the Markov category is finite,
so the usual infinite-dimensional representation theory collapses to a finite linear
algebra computation about how monotone bilinear forms behave under the generating
2→1 merges.
Why now? The monotonicity pillar is proved constructively this cycle, so the
hardest analytic ingredient of the uniqueness theorem already exists; what remains is
a finite, mechanizable symmetry/extremality argument well within reach of the prover.

### 4. Geodesic distance via the sphere (Fisher–Rao = angle) isometry

Conjecture: the map `Φ(p) = (2√p_1, …, 2√p_n)` sends the open simplex isometrically
onto an open patch of the radius-2 sphere, so that the Fisher–Rao geodesic distance
is `d(p,q) = 2·arccos(∑_i √(p_i q_i))` (the Bhattacharyya angle), and this `d` is a
genuine metric (triangle inequality included).
The key insight is that the weights `√p_i` driving every proof in this module are
*literally* the sphere coordinates: `Q_p(u) = ∑ u_i²/p_i` is the pullback of the
round metric under `Φ`, which the existing `√p_i`-based Cauchy–Schwarz computations
already manipulate, so the isometry is a change-of-variables on the same expressions.
Why now? Mathlib's `Real.arccos`, inner-product-space, and `EuclideanSpace` API are
mature; combined with the explicit `√p` weights surfaced this cycle, the spherical
embedding gives a closed-form, testable distance whose metric axioms can be checked
directly rather than through abstract Riemannian length functionals.

### 5. Stochastic (non-deterministic) data processing

Conjecture: monotonicity strengthens from deterministic statistics to arbitrary
column-stochastic channels `K : κ → ι → ℝ` (with `K(·,i) ≥ 0`, `∑_y K(y,i) = 1`):
writing `(K_*p)_y = ∑_i K(y,i) p_i` and `(K_*u)_y = ∑_i K(y,i) u_i`, one still has
`∑_y (K_*u)_y²/(K_*p)_y ≤ Q_p(u)`.
The key insight is that a deterministic `T` is the special case `K(y,i) = [T i = y]`,
and the general proof is again *fiberwise* Cauchy–Schwarz but now with the weighted
vectors `√(K(y,i) p_i)` and `√(K(y,i))·u_i/√p_i` summed over `i` — structurally the
same one-inequality engine used in `fisher_monotone_coarsegrain`, only with `K(y,i)`
as an extra nonnegative weight.
Why now? The deterministic case is freshly closed and its proof isolates exactly the
weight that must be promoted from an indicator to a stochastic kernel; this is a
direct, falsifiable generalization (a single mass-non-conserving `K` would break it),
and it is the precise form of data processing used in modern information theory.
