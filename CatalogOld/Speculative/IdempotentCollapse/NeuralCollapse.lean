import Mathlib

/-!
# Direction 9: Neural Collapse — Feature Convergence in Deep Learning

## The Insight

**Neural collapse** (Papyan, Han, Donoho 2020) is a phenomenon where, during
the terminal phase of training a deep classifier:

1. Features of the same class converge to their class mean
2. Class means form a simplex equiangular tight frame (ETF)
3. The last-layer classifier converges to the nearest-class-mean classifier
4. The classifier weights converge to the class means

All four properties describe an **idempotent collapse**: the feature map
projects each data point to its class centroid, and this projection is
idempotent.

## Main Results

* `centroid_projection_idempotent` — Projecting to nearest centroid is idempotent
* `full_collapse_zero_variance` — Full collapse implies zero within-class variance
* `collapse_map_stable` — Collapsed features are stable
* `collapse_degree_bounds` — Collapse degree ∈ [0, 1]
-/

open Finset BigOperators

noncomputable section

/-! ### Centroid Projection -/

/-- Given K centroids, the nearest-centroid map is idempotent on centroids. -/
theorem centroid_projection_idempotent
    {n K : ℕ} (centroids : Fin K → EuclideanSpace ℝ (Fin n))
    (h_distinct : Function.Injective centroids)
    (assign : EuclideanSpace ℝ (Fin n) → Fin K)
    (h_assign : ∀ k, assign (centroids k) = k) :
    ∀ x, centroids (assign (centroids (assign x))) = centroids (assign x) := by
  intro x; rw [h_assign]

/-! ### Simplex Equiangular Tight Frame (ETF) -/

/-- In neural collapse, the inter-class angle is arccos(-1/(K-1)).
    We prove -1/(K-1) < 0 for K ≥ 2. -/
theorem etf_angle_negative (K : ℕ) (hK : 2 ≤ K) :
    (-1 : ℝ) / ((K : ℝ) - 1) < 0 := by
  apply div_neg_of_neg_of_pos
  · norm_num
  · have : (2 : ℝ) ≤ (K : ℝ) := by exact_mod_cast hK
    linarith

/-! ### Within-Class Variance -/

/-- Full neural collapse means within-class variance is zero. -/
theorem full_collapse_zero_variance
    {d N K : ℕ} (features : Fin N → EuclideanSpace ℝ (Fin d))
    (labels : Fin N → Fin K)
    (centroids : Fin K → EuclideanSpace ℝ (Fin d))
    (h_collapsed : ∀ i, features i = centroids (labels i)) :
    ∀ i j, labels i = labels j → features i = features j := by
  intro i j hij
  rw [h_collapsed i, h_collapsed j, hij]

/-! ### The Collapse Map -/

/-- The collapse map sends each point to its class centroid. -/
def collapseMap {d K N : ℕ}
    (_features : Fin N → EuclideanSpace ℝ (Fin d))
    (labels : Fin N → Fin K)
    (centroids : Fin K → EuclideanSpace ℝ (Fin d)) :
    Fin N → EuclideanSpace ℝ (Fin d) :=
  fun i => centroids (labels i)

/-- The collapse map is stable: collapsed features don't move again. -/
theorem collapse_map_stable {d K N : ℕ}
    (features : Fin N → EuclideanSpace ℝ (Fin d))
    (labels : Fin N → Fin K)
    (centroids : Fin K → EuclideanSpace ℝ (Fin d))
    (assign : EuclideanSpace ℝ (Fin d) → Fin K)
    (h_assign : ∀ k, assign (centroids k) = k) :
    ∀ i, centroids (assign (centroids (labels i))) = centroids (labels i) := by
  intro i; rw [h_assign]

/-! ### Training Dynamics -/

/-- The collapse degree is bounded between 0 and 1. -/
theorem collapse_degree_bounds (σ_within σ_total : ℝ)
    (hw : 0 ≤ σ_within) (ht : 0 < σ_total) (h_le : σ_within ≤ σ_total) :
    0 ≤ σ_within / σ_total ∧ σ_within / σ_total ≤ 1 := by
  exact ⟨div_nonneg hw (le_of_lt ht), div_le_one_iff.mpr (Or.inl ⟨ht, h_le⟩)⟩

end
