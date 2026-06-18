# Future Directions — Information-Geometric Bridge: the Fisher Metric on the Simplex `S`

## Synthesis

This cycle laid the *global*, constructive, finite-alphabet foundations of a bridge
between the Fisher–Rao information geometry on the probability simplex
`S = {p : Fin n → ℝ | p ≥ 0, ∑ p = 1}` and three classical geometries (round-sphere,
Euclidean, great-circle/Hellinger). The single unifying device is the **square-root
chart** `p ↦ 2√p`, together with its tangent-level shadow, the reweighting `v ↦ v/√p`.
Seven theorems are proved in `Catalog/MachineLearning/FisherSimplexBridge.lean` with
`sorry = 0` and only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`):

- `fisher_sphere_embed` — `∑ (2√pᵢ)² = 4`: the simplex lands on the radius-2 sphere.
- `fisher_dominates_euclidean` — `∑ vᵢ² ≤ ∑ vᵢ²/pᵢ`: Fisher ⪰ Euclidean.
- `fisher_ge_tv_sq` — `(∑|vᵢ|)² ≤ ∑ vᵢ²/pᵢ`: Fisher ⪰ (total variation)², the discrete
  infinitesimal Cramér–Rao / Cauchy–Schwarz inequality.
- `kl_nonneg` — Gibbs' inequality `KL ≥ 0`, the integrated form of Fisher positivity.
- `bhattacharyya_le_one` — `∑ √(pᵢqᵢ) ≤ 1`: the two sphere images make an acute angle.
- `renyi_affinity_le_one` — `∑ pᵢ^α qᵢ^{1-α} ≤ 1` for `α ∈ [0,1]`: the one-parameter
  α-affinity (Bhattacharyya at `α = 1/2`, KL nonnegativity in the `α → 1` boundary).
- `alpha_divergence_nonneg` — **(extension)** the Amari α-divergence
  `Dα(p‖q) = (1/(α(1-α)))(1 - ∑ pᵢ^α qᵢ^{1-α}) ≥ 0`.

Together these say: the Fisher form is the *largest* of the natural quadratic forms on
tangent space; it is the round-sphere metric in disguise; its global potential `KL` is
nonnegative; and the entire α-family of divergences sits above it through a single
weighted-AM–GM mechanism. This is the Archimedean mirror of the catalog's p-adic
`MachineLearning.UltrametricKLDivergence`, the Riemannian completion of the tropical
`MachineLearning.TropicalInfoGeometry` seminorm story, and the *global* companion to the
*differential* data-processing / Cramér–Rao layer in `Bridges.FisherMonotonicity` and
`Bridges.FisherCramerRao`.

## Results Summary

| Theorem | Statement | Method |
|---|---|---|
| `fisher_sphere_embed` | `∑ (2√pᵢ)² = 4` | `Real.sq_sqrt` + `Finset.mul_sum` |
| `fisher_dominates_euclidean` | `∑ vᵢ² ≤ ∑ vᵢ²/pᵢ` | termwise, `le_div_iff₀`, `pᵢ ≤ 1` |
| `fisher_ge_tv_sq` | `(∑\|vᵢ\|)² ≤ ∑ vᵢ²/pᵢ` | `Finset.sum_mul_sq_le_sq_mul_sq` |
| `kl_nonneg` | `0 ≤ ∑ pᵢ log(pᵢ/qᵢ)` | `Real.log_le_sub_one_of_pos` |
| `bhattacharyya_le_one` | `∑ √(pᵢqᵢ) ≤ 1` | Cauchy–Schwarz + nonnegativity |
| `renyi_affinity_le_one` | `∑ pᵢ^α qᵢ^{1-α} ≤ 1` | `Real.geom_mean_le_arith_mean2_weighted` |
| `alpha_divergence_nonneg` | `Dα(p‖q) ≥ 0` | rescale the affinity bound |

## Research Directions

### 1. A Pythagorean theorem for KL divergence (information projection)

For an affine/exponential family `E ⊆ S` and the I-projection
`p* = argmin_{p∈E} KL(p‖q)`, conjecture that `KL(p‖q) = KL(p‖p*) + KL(p*‖q)` for all
`p ∈ E`. This is falsifiable: a single `n = 3` numerical instance with a mismatched
(non-affine) family would break the equality, while the identity should hold *exactly*
when `E` is affine in the natural parameters. **The key insight is** that `kl_nonneg`
is precisely the degenerate (`E = {p}`) case of an orthogonal decomposition, and the
cross term vanishes exactly when the displacement `p − p*` is g-orthogonal to
`∇KL(·‖q)` under the same `1/p` reweighting that powers `fisher_ge_tv_sq`. **Why now?**
Gibbs nonnegativity and the Cauchy–Schwarz inner-product machinery are both formal; the
projection theorem is the next structural layer, turning a single inequality into an
equality with geometry.

### 2. A sharp discrete Pinsker inequality from `fisher_ge_tv_sq`

Conjecture: integrating the tangent-level bound `fisher_ge_tv_sq` along the square-root
geodesic yields `KL(p‖q) ≥ 2·TV(p,q)²` with the constant `2` sharp, the deficit being
controlled by a χ²-divergence term. Falsifiable by exhibiting a pair with `KL < 2·TV²`
(which should be impossible) or by sharpening the constant on a restricted family.
**The key insight is** that `fisher_ge_tv_sq` *is* the infinitesimal Pinsker inequality,
so the global statement is its line integral over the sphere chart certified by
`fisher_sphere_embed`. **Why now?** Both endpoints — the tangent TV bound and the sphere
embedding that linearises geodesics — are now formal, leaving only the integration step;
a finite (binary-reduction) proof avoiding integration is also within reach.

### 3. Cramér–Rao lower bound as a re-instantiation of `fisher_ge_tv_sq`

Conjecture: for an unbiased estimator `T` of a parameter `θ` over `S`, the variance
obeys `Var(T) ≥ 1/I(θ)`, and this follows from the *same*
`Finset.sum_mul_sq_le_sq_mul_sq` split used in `fisher_ge_tv_sq`, now with
`uᵢ = (Tᵢ − θ)√pᵢ` and `wᵢ = (∂_θ log pᵢ)√pᵢ`. Falsifiable: any biased construction that
appears to violate the bound refutes the unbiasedness hypothesis, not the inequality.
**The key insight is** that `fisher_ge_tv_sq` and Cramér–Rao are the identical
Cauchy–Schwarz inequality under two choices of the two vectors. **Why now?**
`fisher_ge_tv_sq` already isolates the exact Cauchy–Schwarz lemma and `1/√p` reweighting,
so Cramér–Rao is a near-mechanical re-instantiation that also dovetails with the
differential bound in `Bridges.FisherCramerRao`.

### 4. Great-circle isometry: `dₛ(p,q) = 2·arccos(∑√(pᵢqᵢ))`

Conjecture: the Fisher–Rao geodesic distance on `S` equals `2·arccos(∑√(pᵢqᵢ))` (the
Hellinger/Bhattacharyya great-circle distance), i.e. the embedding behind
`fisher_sphere_embed` is a genuine *isometry*, not merely a set inclusion. Falsifiable by
computing both sides on explicit triples and testing the triangle inequality.
**The key insight is** that `∑√(pᵢqᵢ)` is exactly the Euclidean inner product of the two
sphere images divided by 4, and `bhattacharyya_le_one` already certifies this inner
product lies in `[0,1]`, so the `arccos` is well-defined and the metric question reduces
to spherical trigonometry on the sphere of `fisher_sphere_embed`. **Why now?** The sphere
image and the `≤ 1` affinity bound are both formal; lifting "lands on the sphere" to
"distances agree" is the natural, immediately testable strengthening.

### 5. The full α-divergence family is nonnegative and shares one Fisher Hessian

Conjecture: with `Dα(p‖q) = (1/(α(1−α)))(1 − ∑ pᵢ^α qᵢ^{1-α})` (already proved
nonnegative this cycle), `Dα → KL` as `α → 1`, and every `Dα` induces the *same* Fisher
metric as its common Hessian at the diagonal `p = q` (the dually-flat structure).
Falsifiable: a Hessian mismatch at `p = q` for some `α`, or a failure of the `α → 1`
limit to recover `kl_nonneg`, would refute dual flatness. **The key insight is** that
`renyi_affinity_le_one` already gives `∑ pᵢ^α qᵢ^{1-α} ≤ 1`, which is *exactly*
`Dα ≥ 0` after dividing by the positive constant `α(1−α)` (now `alpha_divergence_nonneg`);
so the nonnegativity half is done, and `kl_nonneg` is the `α → 1` boundary of this same
family. **Why now?** Both the α-affinity bound and Gibbs nonnegativity are formal, and the
`log x ≤ x − 1` / weighted-AM–GM toolchain generalises verbatim to the power-mean
inequalities that govern the whole interpolation.
