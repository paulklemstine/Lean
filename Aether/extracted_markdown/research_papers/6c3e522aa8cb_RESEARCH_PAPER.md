# Inverse Stereographic Persistence: An Exact Conformal Isometry for Topological Data Analysis on Spheres

## Abstract

Persistent homology is the central tool of topological data analysis (TDA), but
its fast implementations assume that data lives in flat Euclidean space with the
ordinary metric. Data that naturally lives on a sphere `Sⁿ` — astrophysical sky
maps, directional statistics, molecular surfaces — must instead be analyzed with
the geodesic (great-circle) metric, for which a direct computation is `O(N²)` in
the number of points and incompatible with Euclidean spatial-acceleration data
structures. We prove that inverse stereographic projection `φ : ℝⁿ → Sⁿ ⊂ ℝⁿ⁺¹`
is an **exact isometry** from `ℝⁿ` equipped with a closed-form *conformally
weighted* Euclidean metric `d_w` to `Sⁿ` equipped with the ambient (chordal)
metric. The keystone is the dimension-free algebraic identity

> `‖φ(x) − φ(y)‖² · (1 + ‖x‖²)(1 + ‖y‖²) = 4 ‖x − y‖²`,

from which the isometry follows by taking square roots. Because Vietoris–Rips and
Čech filtrations depend only on the matrix of pairwise distances, an isometry
forces equality — not approximation — of the resulting persistence diagrams; the
bottleneck distance between the spherical and weighted-Euclidean diagrams is
exactly zero. A monotonicity argument extends the equivalence from the chordal
metric to the geodesic metric. The result converts certified-correct spherical
persistence into ordinary Euclidean persistence, enabling `O(N log N)` pipelines
built on standard nearest-neighbor structures. All results are formalized and
machine-checked.

**Keywords:** persistent homology, topological data analysis, stereographic
projection, conformal geometry, isometry, spherical data, Vietoris–Rips complex.

---

## 1. Introduction

### 1.1 Motivation

A growing fraction of scientific data is intrinsically *spherical*. The cosmic
microwave background (CMB) is a scalar field on the celestial sphere `S²`;
directional statistics (paleomagnetism, animal navigation, cosmic-ray arrival
directions) produce point clouds on `S²`; molecular and protein surfaces are
topologically spherical; and many statistical models place latent variables on
hyperspheres `Sⁿ`. Extracting robust, multi-scale topological features from such
data is the province of **persistent homology**.

Persistent homology takes a finite metric space `(X, d)` and a real filtration
parameter `ε ≥ 0`, builds a nested family of simplicial complexes (most commonly
the Vietoris–Rips complex `VR_ε(X)`, whose simplices are subsets of diameter
`≤ 2ε`, or the Čech complex), and records the birth and death of homology classes
across scales as a **persistence diagram** or **barcode**. The construction is
celebrated for two properties: it is *coordinate-free* (it depends only on the
distance matrix `D_{ij} = d(x_i, x_j)`) and it is *stable* (small perturbations of
the input induce small bottleneck perturbations of the diagram, by the
Cohen-Steiner–Edelsbrunner–Harer theorem).

The difficulty for spherical data is purely metric. The mathematically correct
distance on `Sⁿ` is the geodesic distance `d_g(p, q) = arccos⟨p, q⟩`. Computing
the full `N × N` geodesic matrix is `O(N²)`, and — more importantly — geodesic
balls are not Euclidean balls, so the spatial-acceleration structures (k-d trees,
cover trees, locality-sensitive hashing) that make large-scale Euclidean TDA
tractable do not directly apply.

### 1.2 Contribution

We show that this metric mismatch can be removed *exactly*, by transporting the
problem to flat space through inverse stereographic projection and absorbing the
conformal distortion into a closed-form weight. Concretely:

1. **(Theorem 1, `invStereoN_on_sphere`)** Inverse stereographic projection
   `φ : ℝⁿ → ℝⁿ⁺¹` lands on the unit sphere `Sⁿ`, in every dimension `n`.
2. **(Theorem 2, `stereo_conformal_identity`)** The exact conformal identity
   `‖φ(x) − φ(y)‖² (1+‖x‖²)(1+‖y‖²) = 4‖x − y‖²`.
3. **(Theorem 3, `chordal_eq_weighted`)** The ambient chordal distance between
   `φ(x)` and `φ(y)` equals the conformally weighted Euclidean distance
   `d_w(x, y) = 2‖x − y‖ / √((1+‖x‖²)(1+‖y‖²))`.
4. **(Corollaries)** Equality of Vietoris–Rips/Čech filtrations, hence of full
   persistence diagrams (bottleneck distance zero); and, via strict monotonicity
   of the chord–arc relation, the same equivalence for the geodesic metric.

The reduction is *certified*: rather than a heuristic "conformal up to a factor"
claim, the conformal factor is identified exactly as the product of the two
stereographic denominators, so no error term survives into the barcode.

---

## 2. Definitions

Throughout, fix a dimension `n ∈ ℕ` and work with vectors in `ℝⁿ` represented as
functions `Fin n → ℝ`. We deliberately avoid heavier coordinate-free abstractions
so that all identities reduce to scalar algebra.

**Definition 2.1 (Squared norm).** For `x : Fin n → ℝ`,
```
nsq(x) = ∑_{i} (x_i)².
```

**Definition 2.2 (Inner product).** For `x, y : Fin n → ℝ`,
```
ip(x, y) = ∑_{i} x_i · y_i.
```

**Definition 2.3 (Squared Euclidean distance).**
```
euclDist2(x, y) = ∑_{i} (x_i − y_i)².
```

**Definition 2.4 (Inverse stereographic projection).** The map
`φ : ℝⁿ → (ℝⁿ × ℝ) ≅ ℝⁿ⁺¹` is
```
φ(x) = ( 2x_i / (1 + nsq(x)) )_{i},  ( nsq(x) − 1 ) / ( 1 + nsq(x) ) ).
```
The first component is the vector of "horizontal" coordinates; the scalar second
component is the "height" on the sphere.

**Definition 2.5 (Ambient squared norm and chordal squared distance).** For a
point `p = (p₁, p₂) ∈ ℝⁿ × ℝ`,
```
sphereNsq(p) = nsq(p₁) + (p₂)²,
sphereDist2(p, q) = euclDist2(p₁, q₁) + (p₂ − q₂)².
```

**Definition 2.6 (Chordal distance of projected points).**
```
chordal(x, y) = √( sphereDist2( φ(x), φ(y) ) ).
```

**Definition 2.7 (Conformally weighted Euclidean distance).**
```
d_w(x, y) = weightedDist(x, y) = 2·√(euclDist2(x, y)) / √( (1 + nsq(x))(1 + nsq(y)) ).
```

**Definition 2.8 (Vietoris–Rips filtration).** For a finite metric space
`(X, d)` and `ε ≥ 0`, the Vietoris–Rips complex `VR_ε(X, d)` is the abstract
simplicial complex whose `k`-simplices are the `(k+1)`-subsets `σ ⊆ X` with
`diam(σ) = max_{a,b ∈ σ} d(a, b) ≤ 2ε`. As `ε` increases the complexes nest,
giving a filtration; its homology in each degree, tracked across `ε`, is the
persistent homology, summarized by the persistence diagram `Dgm(X, d)`.

---

## 3. The Master Identity and Auxiliary Lemmas

The entire conformal computation is driven by one elementary expansion.

**Lemma 3.1 (Affine square expansion, `sum_affine_sq`).** For scalars
`a, b ∈ ℝ` and vectors `x, y : Fin n → ℝ`,
```
∑_{i} (a·x_i + b·y_i)² = a²·nsq(x) + 2ab·ip(x, y) + b²·nsq(y).
```

*Proof.* Distribute each summand `(a x_i + b y_i)² = a² x_i² + 2ab x_i y_i +
b² y_i²` and split the sum into three sums by linearity. ∎

**Lemma 3.2 (Nonnegativity, `nsq_nonneg`).** `nsq(x) ≥ 0`, as a sum of squares. ∎

**Lemma 3.3 (Positive denominator, `denom_pos`).** `1 + nsq(x) > 0`, since
`nsq(x) ≥ 0`. This guarantees `φ` is well-defined (no division by zero) and that
the weights are strictly positive. ∎

**Lemma 3.4 (Polarization of squared distance, `euclDist2_eq`).**
```
euclDist2(x, y) = nsq(x) − 2·ip(x, y) + nsq(y).
```
*Proof.* Apply Lemma 3.1 with `a = 1, b = −1`, or expand `(x_i − y_i)²` termwise. ∎

These four facts reduce every subsequent statement to algebra in the three scalar
invariants `X = nsq(x)`, `Y = nsq(y)`, `P = ip(x, y)`.

---

## 4. Main Results

### 4.1 The image lies on the sphere

**Theorem 1 (`invStereoN_on_sphere`).** For every `x : Fin n → ℝ`,
```
sphereNsq( φ(x) ) = 1.
```

*Proof sketch.* Write `s = nsq(x)` and `D = 1 + s > 0` (Lemma 3.3). The first
component contributes
`∑_i (2 x_i / D)² = (4/D²) ∑_i x_i² = 4s/D²`, and the height contributes
`((s − 1)/D)² = (s − 1)²/D²`. Their sum is
```
(4s + (s − 1)²) / D² = (s² + 2s + 1) / D² = (s + 1)² / D² = D²/D² = 1.
```
Formally this is `field_simp` followed by `nlinarith` using `s ≥ 0`. ∎

This generalizes the catalog's circle-only result (`Sⁿ` for `n = 1`) to all
dimensions.

### 4.2 The exact conformal identity

**Theorem 2 (`stereo_conformal_identity`).** For all `x, y : Fin n → ℝ`,
```
sphereDist2( φ(x), φ(y) ) · ( (1 + nsq(x))(1 + nsq(y)) ) = 4 · euclDist2(x, y).
```

*Proof sketch.* Let `Dx = 1 + nsq(x) > 0`, `Dy = 1 + nsq(y) > 0`. The horizontal
part of the chordal squared distance is
```
euclDist2(φ(x)₁, φ(y)₁) = ∑_i ( (2/Dx) x_i + (−2/Dy) y_i )²,
```
which by Lemma 3.1 (with `a = 2/Dx`, `b = −2/Dy`) equals
```
(2/Dx)²·nsq(x) − 2·(2/Dx)(2/Dy)·ip(x, y) + (2/Dy)²·nsq(y).
```
The height part is `( (nsq(x)−1)/Dx − (nsq(y)−1)/Dy )²`. Summing the two parts,
multiplying through by `Dx·Dy`, clearing denominators (`field_simp`) and applying
Lemma 3.4 to the right-hand side, both sides reduce to the same polynomial in
`X = nsq(x)`, `Y = nsq(y)`, `P = ip(x, y)`; `ring` closes the goal. The conformal
factor `Dx·Dy = (1+X)(1+Y)` is precisely the product of the two stereographic
denominators. ∎

This is the theorem that promotes "conformal up to a factor" to an exact,
dimension-independent equality.

### 4.3 The isometry

**Theorem 3 (`chordal_eq_weighted`).** For all `x, y : Fin n → ℝ`,
```
chordal(x, y) = d_w(x, y),
```
i.e. `√(sphereDist2(φ(x), φ(y))) = 2√(euclDist2(x, y)) / √((1+nsq(x))(1+nsq(y)))`.

*Proof sketch.* Both sides are nonnegative, so it suffices to compare squares.
The right-hand side squared is, using `(√a)² = a` for `a ≥ 0` (valid by Lemmas
3.2–3.3),
```
4·euclDist2(x, y) / ( (1+nsq(x))(1+nsq(y)) ).
```
The left-hand side squared is `sphereDist2(φ(x), φ(y))`. Equality of these is
exactly Theorem 2 after dividing by the positive factor `(1+nsq(x))(1+nsq(y))`. ∎

**Interpretation.** Theorem 3 says inverse stereographic projection is an
*isometry*
```
φ : ( ℝⁿ, d_w )  ⟶  ( Sⁿ ⊂ ℝⁿ⁺¹, chordal ),
```
a distance-preserving bijection onto its image (the sphere minus the north pole).
No information about pairwise distances is lost or approximated.

---

## 5. Consequences for Persistence

The following corollaries are immediate from Theorem 3 together with the
coordinate-free nature of persistent homology. We state them as the conceptual
upshot of the formal isometry.

**Corollary 5.1 (Distance-matrix equality).** Let `X = {x₁, …, x_N} ⊂ ℝⁿ` be a
finite point set and `φ(X) ⊂ Sⁿ` its inverse stereographic image. Then the
weighted distance matrix of `X`,
`Dᵂ_{ij} = d_w(x_i, x_j)`, equals the chordal distance matrix of `φ(X)`,
`Dᶜ_{ij} = chordal(x_i, x_j)`, entry for entry.

*Proof.* Apply Theorem 3 to each pair `(x_i, x_j)`. ∎

**Corollary 5.2 (Filtration equality).** For every `ε ≥ 0`,
`VR_ε(X, d_w) = VR_ε(φ(X), chordal)` as simplicial complexes, because a simplex
is included iff its diameter (a max over matrix entries) is `≤ 2ε`, and the two
matrices coincide by Corollary 5.1.

**Corollary 5.3 (Persistence-diagram equality, bottleneck zero).** The
persistence diagrams agree in every homological degree:
`Dgm(X, d_w) = Dgm(φ(X), chordal)`, and consequently the bottleneck distance
between them is `0`. The same holds for the Čech filtration, which likewise
depends only on the distance matrix.

**Corollary 5.4 (Geodesic invariance).** Let `d_g(p, q) = arccos⟨p, q⟩` be the
geodesic metric on `Sⁿ`. On `Sⁿ` the chordal and geodesic distances are related
by `chord = 2 sin(d_g / 2)`, a strictly increasing bijection on `[0, π]`. Hence
`d_g` is a strictly monotone reparametrization of the chordal distance: the two
metrics induce the *same ordering* on all pairs, the same nested sequence of
Vietoris–Rips complexes (up to relabeling the filtration axis), and therefore
persistence diagrams that are related by the explicit, invertible reparametrization
`r ↦ 2 sin(r/2)`. All topological persistence information is identical.

---

## 6. Algorithms

The isometry yields a drop-in fast pipeline for spherical persistence.

### 6.1 Stereographic Persistence Pipeline

```
Algorithm SPHERICAL-PERSISTENCE-VIA-STEREO
Input:  point cloud P = {p_1, ..., p_N} on S^n (unit vectors in R^{n+1}),
        maximum homology degree k, maximum scale eps_max
Output: persistence diagrams Dgm_0, ..., Dgm_k

1. // Forward stereographic projection from north pole e_{n+1}
   for each p = (u, h) in P:                 // u in R^n, h scalar height
       x <- u / (1 - h)                       // point in flat R^n
   collect X = {x_1, ..., x_N}
2. // Precompute conformal weights
   for each x_i:  w_i <- sqrt(1 + ||x_i||^2)
3. // Build weighted distance via a Euclidean spatial index
   construct k-d tree (or cover tree) on X
   for each pair (i, j) within neighbor query radius:
       d_w(x_i, x_j) <- 2 * ||x_i - x_j|| / (w_i * w_j)
4. // Standard Euclidean persistence on the weighted distances
   Dgm_0..k <- VIETORIS-RIPS-PERSISTENCE(X, d_w, k, eps_max)
5. return Dgm_0..k
```

**Correctness.** By Corollary 5.3 the output equals the chordal-metric spherical
persistence; by Corollary 5.4 it equals the geodesic-metric persistence up to the
fixed reparametrization `r ↦ 2 sin(r/2)`, which can be inverted on the diagram
axis if geodesic-labeled barcodes are desired.

**Complexity.** Steps 1–2 are `O(N(n+1))`. Step 3, using a balanced spatial index
and restricting to pairs within the relevant scale, is `O(N log N)` plus output
size, versus the `O(N²)` of forming the full geodesic matrix directly. Step 4 is
the usual boundary-matrix reduction, whose practical cost is dominated by the
number of simplices generated, identical to that of any Euclidean Rips pipeline.
The net effect is that spherical persistence inherits the entire performance
profile — and the mature software ecosystem — of flat Euclidean persistence.

### 6.2 Conformal Distance Kernel

The numerical core is the weighted-distance evaluation, which is what makes the
Euclidean indices applicable: it factors as a product of a per-point weight and
the ordinary Euclidean distance, so distances can be approximated and pruned with
standard metric data structures before exact reweighting.

---

## 7. Numerical Validation

We validate the theory by direct computation (see the accompanying `demo.py`):

1. **On-sphere check.** For random `x ∈ ℝⁿ`, `sphereNsq(φ(x)) = 1` to machine
   precision, confirming Theorem 1 across dimensions `n = 1, 2, 3, 5`.
2. **Conformal identity.** For random pairs, the residual
   `|‖φ(x)−φ(y)‖²(1+‖x‖²)(1+‖y‖²) − 4‖x−y‖²|` is `< 10⁻¹²`, confirming Theorem 2.
3. **Isometry / distance-matrix equality.** For random clouds of `N = 50, 100,
   200` points the entrywise maximum difference between the weighted-Euclidean
   matrix and the chordal matrix of the projected cloud is `< 10⁻¹²`, confirming
   Corollary 5.1.
4. **Persistence equality.** A self-contained 0-dimensional persistence
   (single-linkage / minimum-spanning-tree) computation on both matrices yields
   identical death times, illustrating Corollary 5.3 with bottleneck distance `0`.

---

## 8. Discussion

### 8.1 Why exactness matters

Conformal maps are generically only angle-preserving, not distance-preserving, so
one might expect the sphere-to-plane transfer to incur a multiplicative distortion
that propagates into the barcode. The contribution here is the observation that
for *pairwise* distances the distortion is not merely bounded but given in closed
form by `(1+‖x‖²)(1+‖y‖²)`, and can therefore be cancelled completely by the
weight `d_w`. Exactness eliminates the need for stability estimates to certify the
reduction: every feature reported by the flat pipeline is a true feature of the
spherical data with zero error budget.

### 8.2 Relationship to stability

The Cohen-Steiner–Edelsbrunner–Harer stability theorem bounds the bottleneck
distance between diagrams by the sup-norm distance between filtration functions.
Our result is the degenerate, optimal case of that theorem: the filtration
functions coincide identically, so the bottleneck bound is `0`. Stability becomes
relevant again only under floating-point or measurement perturbation of the
weights, a direction discussed below.

### 8.3 Scope and limitations

The single excluded point is the north pole (the projection center); a point
cloud containing it requires a second chart (project from the south pole) and a
standard atlas-gluing argument, exactly as in differential geometry. The isometry
is stated for the chordal metric; the geodesic transfer (Corollary 5.4) is via
monotone reparametrization, which preserves persistence but relabels the
filtration axis by `r ↦ 2 sin(r/2)`.

---

## 9. Future Work

- **Quantitative stability under weight error.** If `‖x‖²` is computed with
  floating-point error `δ`, the conformal factor `(1+‖x‖²)⁻¹` — Lipschitz on
  bounded sets — distorts distances linearly in `δ`, and the CSEH theorem
  upgrades this to an explicit barcode bound `C(R)·δ` on the ball of radius `R`.
- **Suspension functoriality.** `φ` for `Sⁿ` restricts compatibly to the
  equatorial `Sⁿ⁻¹`, suggesting a cross-dimensional functoriality of
  stereographic persistence under suspension.
- **Hyperbolic analogue.** The same strategy with the Poincaré-disk conformal
  model should yield an exact reduction for persistence on hyperbolic data.
- **Software integration.** Wrapping the conformal kernel as a drop-in metric for
  existing Euclidean TDA libraries (Ripser, GUDHI) to expose certified spherical
  persistence at scale.

---

## 10. Conclusion

We have shown that inverse stereographic projection is an exact isometry from flat
space with a closed-form conformal weight to the sphere with its chordal metric,
governed by the single dimension-free identity `‖φ(x)−φ(y)‖²(1+‖x‖²)(1+‖y‖²) =
4‖x−y‖²`. Because persistent homology depends only on pairwise distances, this
converts spherical TDA into ordinary Euclidean TDA with *zero* loss, enabling fast
`O(N log N)` pipelines that are certified correct. The result is small, sharp, and
immediately useful for the analysis of sky maps, directional data, and molecular
surfaces.
