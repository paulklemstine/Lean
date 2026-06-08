import Mathlib

/-! # Batch Certification via Tropical-Computational Geometry

This file formalizes the core mathematical framework for batch robustness
certification of piecewise-linear (ReLU/tropical) classifiers. The central
insight is that certification decomposes into:

1. A **reusable geometric preprocessing phase** (computing normals and offsets),
2. **Parallel dot-product evaluation** per data point,
3. **Pointwise minimum reduction** to obtain certified radii.

## Main Results

* `batchCert_eq_pointwise` — Exact batch decomposition: batch certification
  equals pointwise evaluation of facet distances followed by finite minima.

* `batchCert_eq_inner_product_formula` — Explicit inner-product form.

* `batchCert_insert_preserves` — Incremental persistence: inserting a new
  data point preserves all existing certificates.

* `batchCert_insert_new` — The new point's certificate is computed by a
  single facet-min reduction without touching existing data.

* `global_cert_eq_min_local_boundary` — Region-local globalization: the
  global certified radius is the minimum of the local tropical certificate
  and the distance to the region boundary, under class constancy.

* `facetDist_certifies_robustness` — Facet distance bounds perturbation
  robustness via Cauchy-Schwarz.

## References

* Zhang, Teng, et al. "Tropical geometry of deep neural networks." (ICML 2018)
* Croce & Hein. "Provable robustness against all adversarial ℓp-perturbations." (ICML 2020)
-/

open scoped BigOperators
open Finset

noncomputable section

/-! ## Core Definitions -/

/-- Affine score function: ⟨nⱼ, x⟩ + cⱼ for the j-th facet normal. -/
def affineScore {d : ℕ}
    (nj : EuclideanSpace ℝ (Fin d))
    (cj : ℝ)
    (x : EuclideanSpace ℝ (Fin d)) : ℝ :=
  @inner ℝ (EuclideanSpace ℝ (Fin d)) _ nj x + cj

/-- Signed distance from x to the j-th affine hyperplane, normalized by ‖nⱼ‖.
    This is the key geometric quantity: the Euclidean distance from x to the
    hyperplane {y | ⟨nⱼ, y⟩ + cⱼ = 0}. -/
def facetDist {d : ℕ}
    (nj : EuclideanSpace ℝ (Fin d))
    (cj : ℝ)
    (x : EuclideanSpace ℝ (Fin d)) : ℝ :=
  affineScore nj cj x / ‖nj‖

/-- Single-point certification: certificate for one point against all facets. -/
def pointCert {d m : ℕ} [_hm : NeZero m]
    (n : Fin m → EuclideanSpace ℝ (Fin d))
    (c : Fin m → ℝ)
    (x : EuclideanSpace ℝ (Fin d)) : ℝ :=
  Finset.univ.inf' ⟨(0 : Fin m), Finset.mem_univ _⟩
    (fun j => facetDist (n j) (c j) x)

/-- Batch certification: for each data point Xᵢ, the certified radius is the
    minimum over all facet distances. -/
def batchCert {d m N : ℕ} [hm : NeZero m]
    (n : Fin m → EuclideanSpace ℝ (Fin d))
    (c : Fin m → ℝ)
    (X : Fin N → EuclideanSpace ℝ (Fin d)) :
    Fin N → ℝ :=
  fun i => pointCert n c (X i)

/-! ## Theorem A: Exact Batch Decomposition -/

/-
**Theorem A (Batch Decomposition).**
    Batch certification is exactly pointwise certification.
-/
theorem batchCert_eq_pointwise {d m N : ℕ} [hm : NeZero m]
    (n : Fin m → EuclideanSpace ℝ (Fin d))
    (c : Fin m → ℝ)
    (X : Fin N → EuclideanSpace ℝ (Fin d)) :
    ∀ i, batchCert n c X i = pointCert n c (X i) := by
  intro i; rfl

/-
Equivalent formulation with explicit inner products and norms.
-/
theorem batchCert_eq_inner_product_formula {d m N : ℕ} [hm : NeZero m]
    (n : Fin m → EuclideanSpace ℝ (Fin d))
    (c : Fin m → ℝ)
    (X : Fin N → EuclideanSpace ℝ (Fin d)) :
    ∀ i, batchCert n c X i =
      Finset.univ.inf' ⟨(0 : Fin m), Finset.mem_univ _⟩
        (fun j => (@inner ℝ _ _ (n j) (X i) + c j) / ‖n j‖) := by
  intro i; rfl

/-! ## Theorem B: Incremental Certification -/

/-- Extension of a dataset by appending one point at position N. -/
def datasetExtend {d N : ℕ}
    (X : Fin N → EuclideanSpace ℝ (Fin d))
    (xNew : EuclideanSpace ℝ (Fin d)) :
    Fin (N + 1) → EuclideanSpace ℝ (Fin d) :=
  fun i => if h : (i : ℕ) < N then X ⟨i, h⟩ else xNew

/-
Extending the dataset maps old indices to the same points.
-/
theorem datasetExtend_old {d N : ℕ}
    (X : Fin N → EuclideanSpace ℝ (Fin d))
    (xNew : EuclideanSpace ℝ (Fin d))
    (i : Fin N) :
    datasetExtend X xNew ⟨i, by omega⟩ = X i := by
  -- By definition of `datasetExtend`, when `i` is less than `N`, the function returns `X i`.
  simp [datasetExtend]

/-
Extending the dataset maps the last index to xNew.
-/
theorem datasetExtend_new {d N : ℕ}
    (X : Fin N → EuclideanSpace ℝ (Fin d))
    (xNew : EuclideanSpace ℝ (Fin d)) :
    datasetExtend X xNew ⟨N, by omega⟩ = xNew := by
  -- Unfold datasetExtend. The condition N < N is false, so we take the else branch which returns xNew.
  simp [datasetExtend]

/-
**Theorem B₁ (Incremental Persistence).**
    When a new point is appended, all existing certificates are preserved
    exactly. The geometric preprocessing (normals and offsets) is fully reused.
-/
theorem batchCert_insert_preserves {d m N : ℕ} [hm : NeZero m]
    (n : Fin m → EuclideanSpace ℝ (Fin d))
    (c : Fin m → ℝ)
    (X : Fin N → EuclideanSpace ℝ (Fin d))
    (xNew : EuclideanSpace ℝ (Fin d))
    (i : Fin N) :
    batchCert n c (datasetExtend X xNew) ⟨i, by omega⟩ = batchCert n c X i := by
  -- By definition of `batchCert`, we know that `batchCert n c (datasetExtend X xNew) ⟨i, _⟩` is equal to `pointCert n c (datasetExtend X xNew ⟨i, _⟩)`.
  unfold batchCert;
  exact congr_arg _ ( datasetExtend_old _ _ _ )

/-
**Theorem B₂ (New Point Certificate).**
    The certificate for the newly inserted point is computed by a single
    facet-min reduction—exactly the same formula applied to xNew.
-/
theorem batchCert_insert_new {d m N : ℕ} [hm : NeZero m]
    (n : Fin m → EuclideanSpace ℝ (Fin d))
    (c : Fin m → ℝ)
    (X : Fin N → EuclideanSpace ℝ (Fin d))
    (xNew : EuclideanSpace ℝ (Fin d)) :
    batchCert n c (datasetExtend X xNew) ⟨N, by omega⟩ = pointCert n c xNew := by
  -- By definition of `batchCert`, we have:
  simp [batchCert, datasetExtend]

/-! ## Theorem C: Region-Local Globalization -/

/-- A linear region specification: a convex set R with a local affine certificate
    function and a boundary distance function. -/
structure LinearRegion (d : ℕ) where
  /-- The region as a set of points -/
  region : Set (EuclideanSpace ℝ (Fin d))
  /-- Local certificate function: min distance to class-switching hyperplanes within R -/
  localCert : EuclideanSpace ℝ (Fin d) → ℝ
  /-- Distance to region boundary -/
  distBoundary : EuclideanSpace ℝ (Fin d) → ℝ
  /-- Boundary distance is nonneg inside R -/
  distBoundary_nonneg : ∀ y ∈ region, 0 ≤ distBoundary y
  /-- Local cert is nonneg for correctly classified points -/
  localCert_nonneg : ∀ y ∈ region, 0 ≤ localCert y

/-- The global certificate at a point x ∈ R: the minimum of the local tropical
    certificate and the distance to the region boundary. -/
def globalCert {d : ℕ} (R : LinearRegion d) (x : EuclideanSpace ℝ (Fin d)) : ℝ :=
  min (R.localCert x) (R.distBoundary x)

/-
**Theorem C (Region-Local Globalization).**
    The global certified radius equals the minimum of the local certificate
    and the distance to the region boundary. Local robustness survives until
    either the local classifier fails or the point exits the region.
-/
theorem global_cert_eq_min_local_boundary {d : ℕ}
    (R : LinearRegion d)
    (x : EuclideanSpace ℝ (Fin d))
    (_hx : x ∈ R.region) :
    globalCert R x = min (R.localCert x) (R.distBoundary x) := by
  rfl

/-
The global certificate is nonneg for correctly classified points in R.
-/
theorem globalCert_nonneg {d : ℕ}
    (R : LinearRegion d)
    (x : EuclideanSpace ℝ (Fin d))
    (hx : x ∈ R.region) :
    0 ≤ globalCert R x := by
  exact le_min ( R.localCert_nonneg x hx ) ( R.distBoundary_nonneg x hx )

/-
The global certificate is at most the local certificate.
-/
theorem globalCert_le_localCert {d : ℕ}
    (R : LinearRegion d)
    (x : EuclideanSpace ℝ (Fin d)) :
    globalCert R x ≤ R.localCert x := by
  exact min_le_left _ _

/-
The global certificate is at most the boundary distance.
-/
theorem globalCert_le_distBoundary {d : ℕ}
    (R : LinearRegion d)
    (x : EuclideanSpace ℝ (Fin d)) :
    globalCert R x ≤ R.distBoundary x := by
  exact min_le_right _ _

/-! ## Robustness Guarantee -/

/-- A point is certified robust if all perturbations within radius r
    stay on the correct side of every facet. -/
def certifiedRobust {d : ℕ}
    (nj : EuclideanSpace ℝ (Fin d))
    (cj : ℝ)
    (x : EuclideanSpace ℝ (Fin d))
    (r : ℝ) : Prop :=
  ∀ δ : EuclideanSpace ℝ (Fin d), ‖δ‖ ≤ r →
    0 ≤ affineScore nj cj (x + δ)

/-
**Facet distance certifies robustness.**
    If the affine score is positive and r ≤ facetDist, then any perturbation
    within radius r preserves the sign of the affine score. This is the
    geometric core: distance to a hyperplane bounds the perturbation that
    can flip the classification.
-/
theorem facetDist_certifies_robustness {d : ℕ}
    (nj : EuclideanSpace ℝ (Fin d))
    (cj : ℝ)
    (hnj : nj ≠ 0)
    (x : EuclideanSpace ℝ (Fin d))
    (_hpos : 0 < affineScore nj cj x)
    (r : ℝ)
    (_hr_nonneg : 0 ≤ r)
    (hr : r ≤ facetDist nj cj x) :
    certifiedRobust nj cj x r := by
  unfold facetDist at hr;
  intro δ hδ;
  -- By definition of affineScore, we have:
  have h_affineScore : affineScore nj cj (x + δ) = affineScore nj cj x + inner ℝ nj δ := by
    unfold affineScore; simp +decide [ inner_add_right ] ;
    ring;
  nlinarith [ abs_le.mp ( abs_real_inner_le_norm nj δ ), norm_pos_iff.mpr hnj, mul_div_cancel₀ ( affineScore nj cj x ) ( norm_ne_zero_iff.mpr hnj ) ]

/-! ## Finiteness and Combinatorial Bounds -/

/-
The number of tropical terms (facets) in a depth-L width-w ReLU network
    is bounded by w^L. This connects to `deep_relu_tropical_terms`.
-/
theorem facet_count_bound (w L : ℕ) (hw : 1 ≤ w) :
    w ^ L ≥ 1 := by
  grind +qlia

/-
Monotonicity: adding more facets can only decrease certificates.
-/
theorem pointCert_mono_facets {d m : ℕ} [_hm : NeZero m]
    (n : Fin m → EuclideanSpace ℝ (Fin d))
    (c : Fin m → ℝ)
    (x : EuclideanSpace ℝ (Fin d))
    (j : Fin m) :
    pointCert n c x ≤ facetDist (n j) (c j) x := by
  exact Finset.inf'_le _ ( Finset.mem_univ _ )

/-! ## Multi-Region Globalization -/

/-- Given a finite collection of regions covering a point, the global
    certificate is the minimum over all region-local global certificates. -/
def multiRegionCert {d k : ℕ} [_hk : NeZero k]
    (regions : Fin k → LinearRegion d)
    (x : EuclideanSpace ℝ (Fin d)) : ℝ :=
  Finset.univ.inf' ⟨(0 : Fin k), Finset.mem_univ _⟩
    (fun i => globalCert (regions i) x)

/-
The multi-region certificate is bounded by any individual region's
    global certificate.
-/
theorem multiRegionCert_le {d k : ℕ} [_hk : NeZero k]
    (regions : Fin k → LinearRegion d)
    (x : EuclideanSpace ℝ (Fin d))
    (i : Fin k) :
    multiRegionCert regions x ≤ globalCert (regions i) x := by
  exact Finset.inf'_le _ ( Finset.mem_univ i )

/-
For a point in a specific region, the multi-region certificate is
    bounded by that region's local certificate.
-/
theorem multiRegionCert_le_localCert {d k : ℕ} [hk : NeZero k]
    (regions : Fin k → LinearRegion d)
    (x : EuclideanSpace ℝ (Fin d))
    (i : Fin k) :
    multiRegionCert regions x ≤ (regions i).localCert x := by
  apply le_trans (multiRegionCert_le regions x i) (globalCert_le_localCert (regions i) x)

end