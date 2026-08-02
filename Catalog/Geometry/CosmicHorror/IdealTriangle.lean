import Mathlib

/-!
# Ideal triangles and maximal hyperbolic area

For constant curvature `-κ` with `κ > 0`, Gauss--Bonnet gives the area of a
hyperbolic triangle with angles `α, β, γ` as

`(π - (α + β + γ)) / κ`.

This file isolates that invariant and proves its extremal rigidity: among
triangles whose angles are nonnegative, the maximal area `π / κ` is attained
exactly when all three angles vanish. Thus a triangle whose angle sum is zero
is naturally an *ideal* triangle (its vertices lie at infinity), rather than an
ordinary finite-vertex triangle.
-/

namespace CosmicHorrorGeometry

/-- The Gauss--Bonnet area determined by curvature magnitude `κ` and three
interior angles. -/
noncomputable def hyperbolicArea (κ α β γ : ℝ) : ℝ :=
  (Real.pi - (α + β + γ)) / κ

/-- An angle triple is admissible when its entries are nonnegative and its sum
is at most `π`. -/
def AdmissibleAngles (α β γ : ℝ) : Prop :=
  0 ≤ α ∧ 0 ≤ β ∧ 0 ≤ γ ∧ α + β + γ ≤ Real.pi

/-- Vanishing of a sum of three nonnegative angles is rigid. -/
theorem angle_sum_eq_zero_iff {α β γ : ℝ}
    (hα : 0 ≤ α) (hβ : 0 ≤ β) (hγ : 0 ≤ γ) :
    α + β + γ = 0 ↔ α = 0 ∧ β = 0 ∧ γ = 0 := by
  constructor
  · intro h
    constructor
    · linarith
    constructor <;> linarith
  · rintro ⟨rfl, rfl, rfl⟩
    norm_num

/-- Gauss--Bonnet area is nonnegative for an admissible angle triple. -/
theorem hyperbolicArea_nonneg {κ α β γ : ℝ} (hκ : 0 < κ)
    (h : AdmissibleAngles α β γ) :
    0 ≤ hyperbolicArea κ α β γ := by
  rcases h with ⟨hα, hβ, hγ, hsum⟩
  unfold hyperbolicArea
  exact div_nonneg (by linarith) (le_of_lt hκ)

/-- Every admissible hyperbolic triangle has area at most `π / κ`. -/
theorem hyperbolicArea_le_max {κ α β γ : ℝ} (hκ : 0 < κ)
    (h : AdmissibleAngles α β γ) :
    hyperbolicArea κ α β γ ≤ Real.pi / κ := by
  rcases h with ⟨hα, hβ, hγ, hsum⟩
  unfold hyperbolicArea
  apply (div_le_div_iff_of_pos_right hκ).2
  linarith

/-- **Ideal-triangle rigidity.** For nonnegative angles on a surface of
constant curvature `-κ`, maximal Gauss--Bonnet area is equivalent to all three
angles vanishing. -/
theorem maximal_area_iff_ideal {κ α β γ : ℝ} (hκ : 0 < κ)
    (hα : 0 ≤ α) (hβ : 0 ≤ β) (hγ : 0 ≤ γ) :
    hyperbolicArea κ α β γ = Real.pi / κ ↔
      α = 0 ∧ β = 0 ∧ γ = 0 := by
  constructor
  · intro h
    apply (angle_sum_eq_zero_iff hα hβ hγ).mp
    unfold hyperbolicArea at h
    have hc := (div_left_inj' (ne_of_gt hκ)).mp h
    linarith
  · rintro ⟨rfl, rfl, rfl⟩
    simp [hyperbolicArea]

/-- The Lovecraftian condition “the interior angles sum to zero” is equivalent
to attaining the universal area maximum. -/
theorem angle_sum_zero_iff_maximal_area {κ α β γ : ℝ} (hκ : 0 < κ)
    (hα : 0 ≤ α) (hβ : 0 ≤ β) (hγ : 0 ≤ γ) :
    α + β + γ = 0 ↔ hyperbolicArea κ α β γ = Real.pi / κ := by
  rw [angle_sum_eq_zero_iff hα hβ hγ, maximal_area_iff_ideal hκ hα hβ hγ]

/-- A triangle has zero Gauss--Bonnet area exactly when its angle sum is
Euclidean (`π`). -/
theorem hyperbolicArea_eq_zero_iff {κ α β γ : ℝ} (hκ : 0 < κ) :
    hyperbolicArea κ α β γ = 0 ↔ α + β + γ = Real.pi := by
  unfold hyperbolicArea
  rw [div_eq_zero_iff]
  simp [ne_of_gt hκ]
  constructor <;> intro h <;> linarith

/-- Positive hyperbolic area is exactly positive angular defect. -/
theorem hyperbolicArea_pos_iff {κ α β γ : ℝ} (hκ : 0 < κ) :
    0 < hyperbolicArea κ α β γ ↔ α + β + γ < Real.pi := by
  unfold hyperbolicArea
  constructor
  · intro h
    rcases (div_pos_iff.mp h) with h | h
    · linarith [h.1]
    · linarith [hκ, h.2]
  · intro h
    exact div_pos (by linarith) hκ

/-- Increasing any one interior angle strictly decreases area. -/
theorem hyperbolicArea_strictAnti_first {κ α₁ α₂ β γ : ℝ}
    (hκ : 0 < κ) (hα : α₁ < α₂) :
    hyperbolicArea κ α₂ β γ < hyperbolicArea κ α₁ β γ := by
  unfold hyperbolicArea
  apply (div_lt_div_iff_of_pos_right hκ).2
  linarith

/-- Changing the angles changes area by exactly the negative change in their
sum, scaled by curvature. -/
theorem hyperbolicArea_difference (κ α₁ β₁ γ₁ α₂ β₂ γ₂ : ℝ) :
    hyperbolicArea κ α₁ β₁ γ₁ - hyperbolicArea κ α₂ β₂ γ₂ =
      ((α₂ + β₂ + γ₂) - (α₁ + β₁ + γ₁)) / κ := by
  unfold hyperbolicArea
  ring

/-- Curvature scaling law: multiplying curvature magnitude by `c` divides the
area by `c`. -/
theorem hyperbolicArea_scale_curvature (κ c α β γ : ℝ) :
    hyperbolicArea (c * κ) α β γ = hyperbolicArea κ α β γ / c := by
  unfold hyperbolicArea
  ring

/-- Ordinary triangles with at least one positive angle cannot attain ideal
area.  In particular, zero angle sum belongs to the ideal boundary of the
space of finite triangles. -/
theorem positive_angle_area_lt_max {κ α β γ : ℝ} (hκ : 0 < κ)
    (hα : 0 < α) (hβ : 0 ≤ β) (hγ : 0 ≤ γ) :
    hyperbolicArea κ α β γ < Real.pi / κ := by
  unfold hyperbolicArea
  apply (div_lt_div_iff_of_pos_right hκ).2
  linarith

/-- At fixed nonzero curvature, the area is a complete invariant of the total
angle: two triples have equal area exactly when their angle sums agree. -/
theorem hyperbolicArea_eq_iff_angleSum_eq {κ α₁ β₁ γ₁ α₂ β₂ γ₂ : ℝ}
    (hκ : κ ≠ 0) :
    hyperbolicArea κ α₁ β₁ γ₁ = hyperbolicArea κ α₂ β₂ γ₂ ↔
      α₁ + β₁ + γ₁ = α₂ + β₂ + γ₂ := by
  unfold hyperbolicArea
  rw [div_left_inj' hκ]
  constructor <;> intro h <;> linarith

/-- The standard curvature `-1` ideal triangle has area exactly `π`. -/
theorem standard_ideal_triangle_area :
    hyperbolicArea 1 0 0 0 = Real.pi := by
  simp [hyperbolicArea]

/-- An exact sample with angle sum `π/2`: its area at curvature `-1` is `π/2`. -/
theorem right_defect_sample :
    hyperbolicArea 1 (Real.pi / 2) 0 0 = Real.pi / 2 := by
  simp [hyperbolicArea]
  ring

end CosmicHorrorGeometry