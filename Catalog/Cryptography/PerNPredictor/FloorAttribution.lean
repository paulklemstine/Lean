import Cryptography.PerNPredictor.TransferRegression

/-!
# Floor attribution: the pure-error floor of any feature-only predictor

Exp 476 reports a *floor attribution*: the residual of the adopted dial is
`1.31×` the floor at `u = 2.5` ("real structure remains") and `1.05×` at
`u = 3.5` ("noise-bound").  The feature `QR(≤100)` is integer valued, so the
data fall into finitely many groups (one per feature value).  This file proves
the exact floor that *no* predictor reading only the feature can go below.

* `sse_const_decomp` — one-group identity: `Σ (yᵢ − c)² = Σ (yᵢ − ȳ)² + n(ȳ − c)²`.
* `feature_sse_decomp` — **floor decomposition**: for *any* function `g` of the
  feature, `Σ (yᵢ − g(xᵢ))² = pureError + Σ (m(xᵢ) − g(xᵢ))²`, where `m` is the
  group-mean predictor.
* `pureError_le_feature_sse` — the pure-error sum is a floor for every
  feature-only predictor (so every "residual/floor" ratio is `≥ 1`).
* `feature_sse_eq_floor_iff` — the floor is attained exactly by predictors that
  agree with the group means on the data.
* `affine_sse_ge_floor` — in particular the adopted affine dial, and its OLS
  refit, sit above the floor; the excess `1.31× − 1` is lack-of-fit plus
  whatever the feature cannot see.
-/

namespace PerNPredictor

open Finset

variable {ι : Type*} (s : Finset ι) (x y : ι → ℝ)

/-- One-group identity: the squared error around a constant splits into the
within-group spread and the bias of the constant. -/
theorem sse_const_decomp (hs : s.Nonempty) (c : ℝ) :
    ∑ i ∈ s, (y i - c) ^ 2 = Sxx s y + s.card * (mean s y - c) ^ 2 := by
  have h := sse_decomp s y y hs c 0
  simp only [sse, zero_mul, add_zero, zero_pow two_ne_zero] at h
  rw [h]; ring

/-- The group-mean predictor: average of `y` over the data points sharing the
feature value of `i`. -/
noncomputable def groupMean (i : ι) : ℝ := mean (s.filter fun j => x j = x i) y

/-- Pure-error sum of squares: the spread of `y` inside each feature group. -/
noncomputable def pureError : ℝ := ∑ i ∈ s, (y i - groupMean s x y i) ^ 2

/-- **Floor decomposition.** For any predictor `g` reading only the feature,
`SSE(g) = pureError + Σ (groupMean − g)²`. -/
theorem feature_sse_decomp (g : ℝ → ℝ) :
    ∑ i ∈ s, (y i - g (x i)) ^ 2
      = pureError s x y + ∑ i ∈ s, (groupMean s x y i - g (x i)) ^ 2 := by
  classical
  rw [pureError, ← sum_add_distrib]
  rw [← sum_fiberwise_of_maps_to (g := x) (t := s.image x) (fun i hi => mem_image_of_mem x hi),
    ← sum_fiberwise_of_maps_to (g := x) (t := s.image x) (fun i hi => mem_image_of_mem x hi)]
  apply sum_congr rfl
  intro v hv
  obtain ⟨i₀, hi₀, rfl⟩ := mem_image.mp hv
  set t := s.filter fun j => x j = x i₀ with ht
  have htne : t.Nonempty := ⟨i₀, mem_filter.mpr ⟨hi₀, rfl⟩⟩
  have hgm : ∀ i ∈ t, groupMean s x y i = mean t y := by
    intro i hi
    have hxi : x i = x i₀ := (mem_filter.mp hi).2
    simp only [groupMean, hxi, ht]
  have hg : ∀ i ∈ t, g (x i) = g (x i₀) := fun i hi => by rw [(mem_filter.mp hi).2]
  have hL : ∑ i ∈ t, (y i - g (x i)) ^ 2 = ∑ i ∈ t, (y i - g (x i₀)) ^ 2 :=
    sum_congr rfl (fun i hi => by rw [hg i hi])
  have hR : ∑ i ∈ t, ((y i - groupMean s x y i) ^ 2 + (groupMean s x y i - g (x i)) ^ 2)
      = ∑ i ∈ t, ((y i - mean t y) ^ 2 + (mean t y - g (x i₀)) ^ 2) :=
    sum_congr rfl (fun i hi => by rw [hgm i hi, hg i hi])
  rw [hL, hR, sse_const_decomp t y htne, sum_add_distrib, Sxx, sum_const, nsmul_eq_mul]

/-- The pure-error sum is a floor for every feature-only predictor. -/
theorem pureError_le_feature_sse (g : ℝ → ℝ) :
    pureError s x y ≤ ∑ i ∈ s, (y i - g (x i)) ^ 2 := by
  rw [feature_sse_decomp s x y g]
  have : 0 ≤ ∑ i ∈ s, (groupMean s x y i - g (x i)) ^ 2 := sum_nonneg fun _ _ => sq_nonneg _
  linarith

/-- The floor is attained exactly by the predictors that reproduce the group
means on the data. -/
theorem feature_sse_eq_floor_iff (g : ℝ → ℝ) :
    ∑ i ∈ s, (y i - g (x i)) ^ 2 = pureError s x y ↔ ∀ i ∈ s, g (x i) = groupMean s x y i := by
  rw [feature_sse_decomp s x y g, add_eq_left,
    sum_eq_zero_iff_of_nonneg (fun _ _ => sq_nonneg _)]
  refine forall₂_congr fun i _ => ?_
  rw [sq_eq_zero_iff, sub_eq_zero, eq_comm]

/-- Every affine dial `a + b·QR` sits on or above the pure-error floor. -/
theorem affine_sse_ge_floor (a b : ℝ) : pureError s x y ≤ sse s x y a b :=
  pureError_le_feature_sse s x y (fun v => a + b * v)

/-- The floor is at most the total spread (the constant predictor at the global
mean is feature-only), so `pureError ≤ Syy`. -/
theorem pureError_le_total (hs : s.Nonempty) : pureError s x y ≤ Sxx s y := by
  have h := pureError_le_feature_sse s x y (fun _ => mean s y)
  have h2 := sse_const_decomp s y hs (mean s y)
  simp only [sub_self, ne_eq, OfNat.ofNat_ne_zero, not_false_eq_true, zero_pow, mul_zero,
    add_zero] at h2
  linarith

end PerNPredictor