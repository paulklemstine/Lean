/-! # CatalogBuild.Physics.Quantum.QuantumMetaPhysics

Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 22
-/

import Mathlib

noncomputable section

theorem energy_time_positive {E t : ℝ} (hE : 0 < E) (ht : 0 < t) : 0 < E * t := by
  positivity


theorem energy_time_scaling {E t c : ℝ} (hc : 0 < c) (hE : 0 < E) (ht : 0 < t) :
    (c * E) * t = c * (E * t) := by
  ring


theorem energy_time_additive {E₁ E₂ t : ℝ} (hE₁ : 0 < E₁) (hE₂ : 0 < E₂) (ht : 0 < t) :
    (E₁ + E₂) * t = E₁ * t + E₂ * t := by
  ring


/-- The maximum number of orthogonal transitions in time t with energy E
is bounded by 2Et/(πℏ). We define the operation count abstractly. -/
noncomputable def maxOperations (E t hbar : ℝ) : ℝ := 2 * E * t / (Real.pi * hbar)


theorem maxOperations_pos {E t hbar : ℝ} (hE : 0 < E) (ht : 0 < t) (hh : 0 < hbar) :
    0 < maxOperations E t hbar := by
  exact div_pos ( mul_pos ( mul_pos two_pos hE ) ht ) ( mul_pos Real.pi_pos hh )


theorem maxOperations_double_energy {E t hbar : ℝ} (hE : 0 < E) (ht : 0 < t) (hh : 0 < hbar) :
    maxOperations (2 * E) t hbar = 2 * maxOperations E t hbar := by
  unfold maxOperations; ring;


theorem maxOperations_mono_energy {E₁ E₂ t hbar : ℝ}
    (hE : E₁ ≤ E₂) (ht : 0 < t) (hh : 0 < hbar) :
    maxOperations E₁ t hbar ≤ maxOperations E₂ t hbar := by
  unfold maxOperations; gcongr;


/-- A computational level is characterized by its available energy and time. -/
structure CompLevel where
  energy : ℝ
  time : ℝ
  energy_pos : 0 < energy
  time_pos : 0 < time


/-- One computational level is bounded by another if it has less energy. -/
def CompLevel.bounded_by (L₁ L₂ : CompLevel) : Prop :=
  L₁.energy ≤ L₂.energy ∧ L₁.time ≤ L₂.time


/-- The operational capacity of a level (proportional to max operations). -/
noncomputable def CompLevel.capacity (L : CompLevel) : ℝ :=
  L.energy * L.time


theorem capacity_monotone {L₁ L₂ : CompLevel} (h : L₁.bounded_by L₂) :
    L₁.capacity ≤ L₂.capacity := by
  exact mul_le_mul h.1 h.2 ( le_of_lt L₁.time_pos ) ( le_of_lt L₂.energy_pos )


theorem hierarchy_transitive {L₁ L₂ L₃ : CompLevel}
    (h₁₂ : L₂.bounded_by L₁) (h₂₃ : L₃.bounded_by L₂) :
    L₃.bounded_by L₁ := by
  exact ⟨ h₂₃.1.trans h₁₂.1, h₂₃.2.trans h₁₂.2 ⟩


theorem verifier_bounded_by_universe {univ simulator verifier : CompLevel}
    (h₁ : simulator.bounded_by univ) (h₂ : verifier.bounded_by simulator) :
    verifier.capacity ≤ univ.capacity := by
  exact le_trans ( capacity_monotone h₂ ) ( capacity_monotone h₁ )


theorem holographic_mono {A₁ A₂ lp : ℝ} (hA : A₁ ≤ A₂) (hlp : 0 < lp) :
    holographicBound A₁ lp ≤ holographicBound A₂ lp := by
  exact div_le_div_of_nonneg_right hA <| by positivity;


theorem lloyd_bound_structure {E t hbar A lp : ℝ}
    (hE : 0 < E) (ht : 0 < t) (hh : 0 < hbar) (hA : 0 < A) (hlp : 0 < lp) :
    0 < maxOperations E t hbar ∧ 0 < holographicBound A lp := by
  exact ⟨ maxOperations_pos hE ht hh, div_pos hA ( mul_pos zero_lt_four hlp ) ⟩


/-- The Fubini-Study distance between two unit vectors, abstracted as an angle. -/
noncomputable def fubiniStudyDist (cosθ : ℝ) (h : cosθ ∈ Set.Icc (0 : ℝ) 1) : ℝ :=
  Real.arccos cosθ


theorem orthogonal_max_distance :
    fubiniStudyDist 0 ⟨le_refl 0, zero_le_one⟩ = Real.pi / 2 := by
  -- By definition of fubiniStudyDist, we have fubiniStudyDist 0 ⟨by norm_num, by norm_num⟩ = Real.arccos 0.
  simp [fubiniStudyDist]


theorem fubiniStudy_nonneg (cosθ : ℝ) (h : cosθ ∈ Set.Icc (0 : ℝ) 1) :
    0 ≤ fubiniStudyDist cosθ h := by
  exact Real.arccos_nonneg _


theorem fubiniStudy_le_pi_half (cosθ : ℝ) (h : cosθ ∈ Set.Icc (0 : ℝ) 1) :
    fubiniStudyDist cosθ h ≤ Real.pi / 2 := by
  unfold fubiniStudyDist; aesop;


theorem verification_capacity_decay {r : ℝ} {C₀ : ℝ}
    (hr : 0 < r) (hr1 : r < 1) (hC : 0 < C₀) (n : ℕ) :
    C₀ * r ^ n > 0 := by
  positivity


theorem total_hierarchy_capacity_bound {r : ℝ} {C₀ : ℝ}
    (hr : 0 < r) (hr1 : r < 1) (hC : 0 < C₀) :
    HasSum (fun n => C₀ * r ^ n) (C₀ / (1 - r)) := by
  simpa only [ div_eq_mul_inv ] using HasSum.mul_left _ ( hasSum_geometric_of_lt_one hr.le hr1 )


theorem hierarchy_finite_capacity {r : ℝ} {C₀ : ℝ}
    (hr : 0 < r) (hr1 : r < 1) (hC : 0 < C₀) :
    C₀ / (1 - r) > 0 := by
  exact div_pos hC ( sub_pos.mpr hr1 )

end
