# Future Directions — Information-Geometric Bridge: The Fisher Metric on the Simplex

## Synthesis

This cycle deepened the catalog's information-geometry programme by closing the
gap between the *abstract* `fisherMatrix` of `Geometry.InformationGeometry.Defs`
and the *concrete* Fisher–Rao metric of the probability simplex. The new file
`Catalog/Geometry/InformationGeometry/FisherSimplexMetric.lean` establishes that
the abstract object really behaves like a Riemannian metric — it is symmetric
(`fisherMatrix_isSymm`), its quadratic form is the second moment of the
directional score (`fisherMatrix_quadForm`), and it is positive semidefinite
(`fisherMatrix_quadForm_nonneg`). It then connects two pre-existing but
previously unlinked catalog definitions, proving that for an exponential family
the Fisher matrix is exactly the covariance of the sufficient statistic
(`fisherMatrix_expFamily_eq_cov`: `I(θ) = Cov_θ(T) = Hess ψ(θ)`). Finally, the
centerpiece `fisherMatrix_simplex_diagonal` computes the metric in probability
coordinates as the diagonal Shahshahani / Fisher–Rao metric `g_{ij} = δ_{ij}/p_i`,
with determinant `∏_i 1/p_i` (`fisherMatrix_simplex_det`), the squared volume
density of the Fisher–Rao volume form.

These results dovetail with `Bridges.FisherMonotonicity` (Chentsov monotonicity /
data-processing for the Fisher quadratic form): the quadratic-form lemma proved
here is the same Cauchy–Schwarz core that powers the Cramér–Rao bound there,
making `fisherMatrix_quadForm` an architectural hub between the inference side and
the geometry side of the programme.

## Results Summary

- `fisherMatrix_isSymm` — Fisher matrix is symmetric.
- `fisherMatrix_quadForm` — `vᵀ G v = E_θ[(v·score)²]`.
- `fisherMatrix_quadForm_nonneg` — Fisher matrix is positive semidefinite.
- `fisherMatrix_expFamily_eq_cov` — for exponential families, `I(θ) = Cov_θ(T)`.
- `fisherMatrix_simplex_diagonal` — Fisher–Rao metric of `Δⁿ⁻¹` is `diag(1/p_i)`.
- `fisherMatrix_simplex_det` — its determinant is `∏_i 1/p_i`.

All six are proven with no `sorry` and depend only on the standard axioms
`propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. Positive definiteness and the metric/inner-product packaging

Strengthen positive *semi*definiteness to genuine positive definiteness on the
simplex tangent space `{v : ∑_i v_i = 0}` and bundle the result as a Mathlib
`InnerProductSpace`-style structure on the simplex chart. The key insight is that
`fisherMatrix_quadForm` already exhibits the quadratic form as `E_θ[(v·score)²]`,
so nondegeneracy is exactly the statement that the scores `{s_i}` are linearly
independent as random variables modulo the affine constraint — a purely linear
fact about the simplex score `δ_{ωi}/p_i`. **Why now?** The semidefinite and
diagonal results are already in place, so definiteness on the constrained tangent
space is the immediate, falsifiable next step (it would be falsified by exhibiting
a nonzero constraint-respecting `v` with `vᵀ G v = 0`), and it upgrades the file
from "metric tensor" to "Riemannian metric" in the formal Mathlib sense.

### 2. The √-embedding: Fisher–Rao as the pulled-back round sphere metric

Prove that the map `p ↦ 2√p` is an isometry from the simplex with the Fisher–Rao
metric onto the positive orthant of the radius-2 sphere with its round metric,
i.e. that the diagonal metric `diag(1/p_i)` is the pullback of the Euclidean
metric under `Φ(p)_i = 2√p_i`. The key insight is that `∂Φ_i/∂p_j = δ_{ij}/√p_i`,
so the Jacobian-transported Euclidean metric `JᵀJ` has entries `δ_{ij}/p_i` — which
is *literally* the matrix computed in `fisherMatrix_simplex_diagonal`. **Why now?**
With the diagonal form proven, the isometry reduces to an elementary Jacobian
computation, and it would immediately import the round sphere's constant positive
curvature into the catalog, connecting `FisherSimplexMetric` to the curvature/
geodesic files (`Pythagorean.CurvatureFlow`, `Bridges.SplitGeometry`).

### 3. Hessian-of-log-partition identity and Fisher = Hess ψ for exponential families

Extend `fisherMatrix_expFamily_eq_cov` to the full second-order statement that the
Fisher matrix equals the Hessian of the log-partition function,
`I(θ)_{ij} = ∂²ψ/∂θ_i∂θ_j`, where `ψ = logPartition` is already defined in
`Geometry.InformationGeometry.Defs`. The key insight is that the covariance of the
sufficient statistic — which we have *already* shown equals the Fisher matrix — is
classically the Hessian of `ψ`, so the chain `I = Cov(T) = Hess ψ` only needs its
last link formalized via Mathlib's `fderiv`/`iteratedFDeriv` calculus. **Why now?**
The covariance equality is the hard combinatorial half and it is done; the
remaining step is a differentiation lemma about `Real.log (∑ exp …)`, and closing
it makes `logPartition` convex (Hessian PSD) for free, seeding a convexity/duality
sub-programme.

### 4. Quantitative Chentsov: the information-loss gap of a coarse-graining

`Bridges.FisherMonotonicity` proves the *inequality* `Q^{T_*M}(v) ≤ Q^M(v)`. The
next step is to compute the *gap* exactly as a conditional variance:
`Q^M(v) − Q^{T_*M}(v) = E_y[ Var(v·score | T = y) ]`. The key insight is that the
fibrewise Cauchy–Schwarz used in `fisher_monotone_coarsegrain` is tight precisely
by the within-fiber variance, so the deficit is the expected conditional variance
of the directional score — an equality, not a bound. **Why now?** The monotonicity
machinery (`fiberMass`, `coarseScore`, `pushModel`) already exists, so the gap
formula is a refinement of an existing proof rather than new infrastructure, and
it is sharply falsifiable: any coarse-graining with zero within-fiber score
variance must lose *zero* information.

### 5. Bregman / dual-flat geometry of the simplex from the diagonal metric

Use the diagonal Fisher metric together with `alphaChristoffel` (already in
`Defs.lean`) to prove that the simplex is *dually flat*: the `+1`-connection
(`PlusOneFlat`) vanishes in the natural exponential coordinates while the
`−1`-connection vanishes in the expectation (mean) coordinates, with the
KL-divergence appearing as the associated Bregman divergence of `−∑ p log p`. The
key insight is that on the simplex the Amari–Chentsov tensor `C_{ijk}` computed
from `simplexScore` is itself diagonal (`C_{iii} = 1/p_i²`, off-diagonal zero),
which makes the `α`-Christoffel symbols completely explicit and the flatness
checks finite computations. **Why now?** Both the metric (`fisherMatrix_simplex_
diagonal`) and the connection scaffolding (`amariChentsovTensor`,
`alphaChristoffel`, `PlusOneFlat`) are now in the catalog, so dual flatness is the
natural capstone bridging the metric, the divergence files
(`MachineLearning.UltrametricKLDivergence`), and the α-connection geometry.
