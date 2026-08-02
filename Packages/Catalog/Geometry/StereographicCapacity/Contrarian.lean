import Mathlib

/-!
# Contrarian results for stereographic capacity on `S²`

This self-contained file separates the area argument from the proposed stereographic
correction and tests the claimed calibrations.  Caps of geodesic radius `r` have
area `2π(1-cos r)`.  Pairwise disjoint caps therefore satisfy the stronger direct
area bound `card ≤ 2/(1-cos r)`.

The proposed correction `(2/cos r)^2` does not tend to one: at `r = 0` it equals
four.  Moreover, four caps of radius `π/3` cannot be packed.  Their centers would
be unit vectors with every mutual inner product at most `cos(2π/3) = -1/2`, which
contradicts nonnegativity of the squared norm of their sum.  Thus the advertised
"tetrahedral" calibration is false for caps of that radius.
-/

open scoped ENNReal
open MeasureTheory Set Finset Real

namespace StereographicCapacityContrarian

noncomputable section

/-- Surface area of the unit two-sphere. -/
def sphereArea : ℝ := 4 * Real.pi

/-- Area of a geodesic cap of radius `r` on the unit two-sphere. -/
def capArea (r : ℝ) : ℝ := 2 * Real.pi * (1 - Real.cos r)

/-- The conjectured two-dimensional stereographic correction factor. -/
def proposedCorrection (r : ℝ) : ℝ := (2 / Real.cos r) ^ 2

/-- Finite additivity gives the fundamental packing inequality. -/
theorem finite_disjoint_packing
    {α ι : Type*} [MeasurableSpace α] (μ : Measure α)
    (s : Finset ι) (caps : ι → Set α) (ambient : Set α)
    (hmeas : ∀ i ∈ s, MeasurableSet (caps i))
    (hsub : ∀ i ∈ s, caps i ⊆ ambient)
    (hdisj : Set.PairwiseDisjoint (s : Set ι) caps)
    (v : ENNReal) (hvol : ∀ i ∈ s, v ≤ μ (caps i)) :
    s.card * v ≤ μ ambient := by
  calc (↑s.card : ENNReal) * v
      = ∑ _i ∈ s, v := by simp [Finset.sum_const]
    _ ≤ ∑ i ∈ s, μ (caps i) := by
        apply Finset.sum_le_sum fun i hi => hvol i hi
    _ = μ (⋃ i ∈ s, caps i) := by
        rw [MeasureTheory.measure_biUnion_finset hdisj hmeas]
    _ ≤ μ ambient := by
        apply MeasureTheory.measure_mono
        intro x hx
        obtain ⟨i, hi, hx_i⟩ := Set.mem_iUnion₂.mp hx
        exact hsub i hi hx_i

/-- Direct area comparison on `S²`, stated for any measure model of disjoint caps. -/
theorem s2_cap_packing_area_bound
    {α ι : Type*} [MeasurableSpace α] (μ : Measure α)
    (s : Finset ι) (caps : ι → Set α) (ambient : Set α)
    (r : ℝ) (hr : 0 < r) (hrpi : r < Real.pi)
    (hmeas : ∀ i ∈ s, MeasurableSet (caps i))
    (hsub : ∀ i ∈ s, caps i ⊆ ambient)
    (hdisj : Set.PairwiseDisjoint (s : Set ι) caps)
    (hsphere : μ ambient = ENNReal.ofReal sphereArea)
    (hcaps : ∀ i ∈ s, μ (caps i) = ENNReal.ofReal (capArea r)) :
    (s.card : ℝ) ≤ 2 / (1 - Real.cos r) := by
  have hcap_pos : 0 < capArea r := by
    simp [capArea]
    apply mul_pos (mul_pos two_pos Real.pi_pos)
    have hc : Real.cos r < 1 := by
      rw [← Real.cos_zero]
      exact Real.cos_lt_cos_of_nonneg_of_le_pi (by linarith : (0 : ℝ) ≤ 0) (by linarith : r ≤ Real.pi) hr
    exact sub_pos.mpr hc
  have hpacking := finite_disjoint_packing μ s caps ambient hmeas hsub hdisj _ (fun i hi => le_of_eq (hcaps i hi).symm)
  rw [hsphere] at hpacking
  have hsphere_nonneg : 0 ≤ sphereArea := by simp [sphereArea]; exact Real.pi_pos.le
  have hpacked_real : (s.card : ℝ) * capArea r ≤ sphereArea := by
    have h1 : ((s.card : ℕ) * ENNReal.ofReal (capArea r)).toReal ≤ (ENNReal.ofReal sphereArea).toReal := by
      apply ENNReal.toReal_mono
      · exact ne_of_lt (ENNReal.ofReal_lt_top)
      · exact hpacking
    rwa [ENNReal.toReal_mul, ENNReal.toReal_natCast, ENNReal.toReal_ofReal (le_of_lt hcap_pos),
         ENNReal.toReal_ofReal hsphere_nonneg] at h1
  simp [capArea, sphereArea] at hpacked_real
  rw [le_div_iff₀ (sub_pos.mpr (by rw [← Real.cos_zero]; exact Real.cos_lt_cos_of_nonneg_of_le_pi (by linarith : (0 : ℝ) ≤ 0) (by linarith : r ≤ Real.pi) hr))]
  have hpi : 0 < Real.pi := Real.pi_pos
  nlinarith [sq_nonneg Real.pi]

/-- On the range where it is defined, the proposed bound follows from the stronger
area bound; stereographic projection is not needed for this implication. -/
theorem s2_proposed_bound_of_area_bound (r card : ℝ)
    (hr : 0 < r) (hrhalf : r < Real.pi / 2)
    (harea : card ≤ 2 / (1 - Real.cos r)) :
    card ≤ proposedCorrection r * (sphereArea / capArea r) := by
  rw [proposedCorrection, sphereArea, capArea]
  -- Simplify the fraction 4π / (2π(1 - cos r)) = 2 / (1 - cos r)
  have hpi_pos : 0 < Real.pi := Real.pi_pos
  have hcos_pos : 0 < Real.cos r := Real.cos_pos_of_mem_Ioo ⟨by linarith, by linarith⟩
  have hcos_lt_one : Real.cos r < 1 := by
    rw [← Real.cos_zero]
    exact Real.cos_lt_cos_of_nonneg_of_le_pi (by linarith) (by linarith) (by linarith)
  have h_one_minus_cos_pos : 0 < 1 - Real.cos r := by linarith
  have h_frac : 4 * Real.pi / (2 * Real.pi * (1 - Real.cos r)) = 2 / (1 - Real.cos r) := by
    field_simp
    ring
  rw [h_frac]
  -- Since (2 / cos r)^2 ≥ 1, we have (2/cos r)^2 * (2/(1-cos r)) ≥ 2/(1-cos r)
  have h_one_le : 1 ≤ (2 / Real.cos r) ^ 2 := by
    have hcos_le_one : Real.cos r ≤ 1 := Real.cos_le_one r
    have : 2 / Real.cos r ≥ 1 := by
      have h1 : 2 ≥ Real.cos r := by linarith
      exact (one_le_div hcos_pos).mpr (by linarith)
    nlinarith [sq_nonneg (2 / Real.cos r - 1)]
  calc card ≤ 2 / (1 - Real.cos r) := harea
    _ = 1 * (2 / (1 - Real.cos r)) := by ring
    _ ≤ (2 / Real.cos r) ^ 2 * (2 / (1 - Real.cos r)) := by gcongr

/-- Contrary to the claimed `1 + O(r²)` normalization, the proposed correction is
already four at radius zero. -/
theorem proposedCorrection_at_zero : proposedCorrection 0 = 4 := by
  simp [proposedCorrection, Real.cos_zero]
  norm_num

/-- In particular, the proposed correction is not normalized to one at zero. -/
theorem proposedCorrection_at_zero_ne_one : proposedCorrection 0 ≠ 1 := by
  rw [proposedCorrection_at_zero]
  norm_num

/-- Four unit vectors cannot all have mutual inner product at most `-1/2`.
This is the Gram-matrix obstruction behind the failure of the `π/3` tetrahedral test. -/
theorem no_four_unit_vectors_at_angle_two_pi_over_three
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (a b c d : E)
    (ha : ‖a‖ = 1) (hb : ‖b‖ = 1) (hc : ‖c‖ = 1) (hd : ‖d‖ = 1)
    (hab : inner ℝ a b ≤ -(1 / 2 : ℝ))
    (hac : inner ℝ a c ≤ -(1 / 2 : ℝ))
    (had : inner ℝ a d ≤ -(1 / 2 : ℝ))
    (hbc : inner ℝ b c ≤ -(1 / 2 : ℝ))
    (hbd : inner ℝ b d ≤ -(1 / 2 : ℝ))
    (hcd : inner ℝ c d ≤ -(1 / 2 : ℝ)) : False := by
  -- Consider the squared norm of a + b + c + d, which must be non-negative
  have h_sum_sq : ‖a + b + c + d‖ ^ 2 = ‖a‖ ^ 2 + ‖b‖ ^ 2 + ‖c‖ ^ 2 + ‖d‖ ^ 2 +
    2 * inner ℝ a b + 2 * inner ℝ a c + 2 * inner ℝ a d +
    2 * inner ℝ b c + 2 * inner ℝ b d + 2 * inner ℝ c d := by
    have h1 : ‖a + b + c + d‖ ^ 2 = inner ℝ (a + b + c + d) (a + b + c + d) := by
      rw [real_inner_self_eq_norm_sq]
    rw [h1]
    simp only [inner_add_left, inner_add_right]
    rw [real_inner_self_eq_norm_sq a, real_inner_self_eq_norm_sq b, real_inner_self_eq_norm_sq c, real_inner_self_eq_norm_sq d]
    rw [real_inner_comm b a, real_inner_comm c a, real_inner_comm d a,
        real_inner_comm c b, real_inner_comm d b, real_inner_comm d c]
    ring
  -- Now derive contradiction: the squared norm must be nonnegative, but is at most -2
  have h_bound : ‖a + b + c + d‖ ^ 2 ≤ -2 := by
    rw [h_sum_sq]
    simp [ha, hb, hc, hd]
    linarith
  have h_nonneg : 0 ≤ ‖a + b + c + d‖ ^ 2 := sq_nonneg _
  linarith

/-- The trigonometric threshold corresponding to cap radius `π/3`. -/
theorem cos_twice_pi_div_three : Real.cos (2 * (Real.pi / 3)) = -(1 / 2 : ℝ) := by
  rw [show 2 * (Real.pi / 3) = Real.pi - Real.pi / 3 by ring]
  rw [Real.cos_pi_sub]
  rw [Real.cos_pi_div_three]

/-- A regular tetrahedron has center inner product `-1/3`, which is too large for
non-overlapping caps of radius `π/3` (which require at most `-1/2`). -/
theorem tetrahedral_inner_product_fails_pi_third :
    ¬ ((-(1 / 3 : ℝ)) ≤ Real.cos (2 * (Real.pi / 3))) := by
  rw [cos_twice_pi_div_three]
  norm_num

end

end StereographicCapacityContrarian