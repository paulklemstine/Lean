# Future Directions — Information-Geometric Bridge: Fisher Metric on the Simplex `S`

## Synthesis

This cycle opened a constructive, finite-alphabet bridge between the Fisher–Rao
information metric on the probability simplex `S = {p : Fin n → ℝ | p ≥ 0, ∑ p = 1}`
and three classical geometries. The unifying device is the **square-root chart**
`p ↦ 2√p` and its tangent-level shadow, the reweighting `v ↦ v/√p`. Four
theorems in `Catalog/MachineLearning/FisherSimplexBridge.lean` are now proved
with `sorry = 0` and only standard axioms:

- `fisher_sphere_embed` — `∑ (2√pᵢ)² = 4`: the simplex lands on the radius-2 sphere.
- `fisher_dominates_euclidean` — `∑ vᵢ² ≤ ∑ vᵢ²/pᵢ`: Fisher ⪰ Euclidean.
- `fisher_ge_tv_sq` — `(∑|vᵢ|)² ≤ ∑ vᵢ²/pᵢ`: Fisher ⪰ (total variation)², a
  discrete Cramér–Rao/Cauchy–Schwarz inequality.
- `kl_nonneg` — Gibbs' inequality: KL ≥ 0, the integrated form of Fisher positivity.

Together these say: the Fisher form is the *largest* of the natural quadratic
forms on tangent space, it is the round-sphere metric in disguise, and its global
potential (KL) is convex/nonnegative. The work is the Archimedean mirror of the
catalog's p-adic `UltrametricKLDivergence` and the Riemannian completion of the
tropical `TropicalInfoGeometry` seminorm story.

## Results Summary

| Theorem | Statement | Method |
|---|---|---|
| `fisher_sphere_embed` | `∑ (2√pᵢ)² = 4` | `Real.sq_sqrt` + `Finset.mul_sum` |
| `fisher_dominates_euclidean` | `∑ vᵢ² ≤ ∑ vᵢ²/pᵢ` | termwise, `1 ≤ 1/pᵢ` |
| `fisher_ge_tv_sq` | `(∑|vᵢ|)² ≤ ∑ vᵢ²/pᵢ` | `Finset.sum_mul_sq_le_sq_mul_sq` |
| `kl_nonneg` | `0 ≤ ∑ pᵢ log(pᵢ/qᵢ)` | `Real.log_le_sub_one_of_pos` |

## Research Directions

### 1. Pythagorean theorem for KL divergence (information projection)
For a linear/exponential family `E ⊆ S` and the I-projection `p* = argmin_{p∈E} KL(p‖q)`,
the conjecture is that `KL(p‖q) = KL(p‖p*) + KL(p*‖q)` for all `p ∈ E`. This is
falsifiable: a single `n = 3` numerical counterexample with mismatched families
would kill the equality, while the equality should hold *exactly* when `E` is an
affine subspace in the natural parameters. **The key insight is** that `kl_nonneg`
is precisely the degenerate (`E = {p}`) case of an orthogonal decomposition, and
the cross term vanishes exactly when the displacement `p − p*` is g-orthogonal to
`∇KL(·‖q)` — the same `1/p` reweighting that powers `fisher_ge_tv_sq`. **Why now?**
We already have Gibbs nonnegativity and the Cauchy–Schwarz inner-product machinery
in place; the projection theorem is the next structural layer and turns a single
inequality into an equality with geometric content.

### 2. Sharp Pinsker constant from the Fisher–TV bridge
Conjecture: integrating `fisher_ge_tv_sq` along the square-root geodesic yields the
discrete Pinsker inequality `KL(p‖q) ≥ 2·TV(p,q)²` with the constant `2` sharp, and
the deficit is controlled by a χ² term. This is falsifiable by exhibiting a pair with
`KL < 2·TV²` (which should be impossible) or by improving the constant for restricted
families. **The key insight is** that `fisher_ge_tv_sq` is the *infinitesimal* Pinsker
inequality, so the global statement is its line integral over the sphere chart from
`fisher_sphere_embed`. **Why now?** Both endpoints — the tangent-level TV bound and the
sphere embedding that linearizes geodesics — are now formal, so the integration step is
the only missing piece.

### 3. Cramér–Rao lower bound as a corollary of `fisher_ge_tv_sq`
Conjecture: for an unbiased estimator `T` of a parameter `θ` over `S`, the variance
obeys `Var(T) ≥ 1/I(θ)` where `I` is the Fisher information, and this follows from the
same `Finset.sum_mul_sq_le_sq_mul_sq` split with `uᵢ = (Tᵢ−θ)√pᵢ`, `wᵢ = (∂_θ log pᵢ)√pᵢ`.
Falsifiable: any biased construction violating the bound would refute the unbiasedness
hypothesis, not the inequality. **The key insight is** that `fisher_ge_tv_sq` and
Cramér–Rao are *the same Cauchy–Schwarz inequality* under two different choices of the
two vectors. **Why now?** The proof of `fisher_ge_tv_sq` already isolates the exact
Cauchy–Schwarz lemma and reweighting, so Cramér–Rao is a near-mechanical re-instantiation.

### 4. Geodesic distance on `S` equals great-circle distance on the sphere
Conjecture: the Fisher–Rao geodesic distance between `p, q ∈ S` equals
`2·arccos(∑ √(pᵢ qᵢ))` (the Bhattacharyya/Hellinger great-circle distance), i.e. the
embedding of `fisher_sphere_embed` is a genuine *isometry*, not merely a set inclusion.
Falsifiable by computing both sides for explicit triples and checking the triangle
inequality / curvature. **The key insight is** that `∑ √(pᵢ qᵢ)` is exactly the
Euclidean inner product of the two sphere images divided by 4, so the metric question
reduces to spherical trigonometry already implied by `∑ (2√pᵢ)² = 4`. **Why now?**
The sphere image is formalized; lifting from "lands on the sphere" to "distances agree"
is the natural and immediately testable strengthening.

### 5. α-divergence interpolation and the dually flat structure
Conjecture: the α-family `D_α(p‖q) = (1/(α(1−α)))(1 − ∑ pᵢ^α qᵢ^{1−α})` satisfies
`D_α ≥ 0` for all `α ∈ (0,1)`, with `D_α → KL` as `α → 1`, and all `D_α` induce the
*same* Fisher metric as their common Hessian at the diagonal `p = q`. Falsifiable: a
sign violation of `D_α` for some `α, p, q` (impossible by weighted AM–GM) or a Hessian
mismatch at `p = q` would refute the dually-flat claim. **The key insight is** that
`kl_nonneg` is the `α → 1` boundary of a one-parameter family whose nonnegativity is
uniformly governed by Jensen/AM–GM with the same `1/p` curvature. **Why now?** Gibbs
nonnegativity is proved and the `log x ≤ x − 1` toolchain generalizes verbatim to the
power-mean inequalities needed for general `α`.
