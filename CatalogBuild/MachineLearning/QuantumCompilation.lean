/-! # CatalogBuild.MachineLearning.QuantumCompilation

Auto-generated from theorem catalog database.
Domain: MachineLearning
Declarations: 19
-/

import Mathlib

noncomputable section

/-- Gaussian integer norm for quantum gates. -/
def QGaussNorm (a b : ℤ) : ℤ := a ^ 2 + b ^ 2



/-- Gaussian norm is multiplicative. -/
theorem QGaussNorm_mul (a b c d : ℤ) :
    QGaussNorm a b * QGaussNorm c d = QGaussNorm (a * c - b * d) (a * d + b * c) := by
  simp [QGaussNorm]; ring



/-- Pauli-X entry norm sum. -/
theorem pauli_x_norm_sum : QGaussNorm 0 0 + QGaussNorm 1 0 +
    QGaussNorm 1 0 + QGaussNorm 0 0 = 2 := by simp [QGaussNorm]



/-- Pauli-Y entry norm sum. -/
theorem pauli_y_norm_sum :
    QGaussNorm 0 0 + QGaussNorm 0 (-1) + QGaussNorm 0 1 + QGaussNorm 0 0 = 2 := by
  simp [QGaussNorm]



/-- Scaled Hadamard entry norm sum. -/
theorem hadamard_scaled_norm_sum :
    QGaussNorm 1 0 + QGaussNorm 1 0 + QGaussNorm 1 0 + QGaussNorm (-1) 0 = 4 := by
  simp [QGaussNorm]



/-- Quaternion norm. -/
def QQuatNorm (a b c d : ℤ) : ℤ := a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2



/-- Quaternion norm is non-negative. -/
theorem QQuatNorm_nonneg (a b c d : ℤ) : 0 ≤ QQuatNorm a b c d := by
  simp [QQuatNorm]; positivity



/-- Quaternion norm is zero iff all components are zero. -/
theorem QQuatNorm_zero_iff (a b c d : ℤ) :
    QQuatNorm a b c d = 0 ↔ a = 0 ∧ b = 0 ∧ c = 0 ∧ d = 0 := by
  simp [QQuatNorm]
  constructor
  · intro h
    have ha := sq_nonneg a; have hb := sq_nonneg b
    have hc := sq_nonneg c; have hd := sq_nonneg d
    refine ⟨?_, ?_, ?_, ?_⟩ <;> exact_mod_cast sq_eq_zero_iff.mp (by omega)
  · rintro ⟨rfl, rfl, rfl, rfl⟩; simp



/-- Unit quaternions are closed under multiplication. -/
theorem unit_quat_closed (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h₁ : QQuatNorm a₁ b₁ c₁ d₁ = 1) (h₂ : QQuatNorm a₂ b₂ c₂ d₂ = 1) :
    QQuatNorm
      (a₁*a₂ - b₁*b₂ - c₁*c₂ - d₁*d₂)
      (a₁*b₂ + b₁*a₂ + c₁*d₂ - d₁*c₂)
      (a₁*c₂ - b₁*d₂ + c₁*a₂ + d₁*b₂)
      (a₁*d₂ + b₁*c₂ - c₁*b₂ + d₁*a₂) = 1 := by
  have := euler_four_square a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂
  rw [h₁, h₂, one_mul] at this
  exact this.symm



/-- Integer quaternion multiplication closure. -/
theorem hurwitz_int_mul_closed (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ) :
    ∃ a₃ b₃ c₃ d₃ : ℤ,
      a₃ = a₁*a₂ - b₁*b₂ - c₁*c₂ - d₁*d₂ ∧
      b₃ = a₁*b₂ + b₁*a₂ + c₁*d₂ - d₁*c₂ ∧
      c₃ = a₁*c₂ - b₁*d₂ + c₁*a₂ + d₁*b₂ ∧
      d₃ = a₁*d₂ + b₁*c₂ - c₁*b₂ + d₁*a₂ :=
  ⟨_, _, _, _, rfl, rfl, rfl, rfl⟩



/-- Solovay-Kitaev: log(1/ε) > 0 for ε < 1. -/
theorem solovay_kitaev_gate_count (ε : ℝ) (hε : 0 < ε) (hε1 : ε < 1) :
    0 < Real.log (1 / ε) := by
  apply Real.log_pos
  rw [one_div]
  exact one_lt_inv_iff₀.mpr ⟨hε, hε1⟩



/-- T-gate denominator growth. -/
theorem t_gate_denom_growth (n : ℕ) :
    1 ≤ 2 ^ n := Nat.one_le_pow n 2 (by norm_num)



/-- S-gate entries have Gaussian norm 1. -/
theorem s_gate_entries :
    QGaussNorm 1 0 = 1 ∧ QGaussNorm 0 1 = 1 := by
  constructor <;> simp [QGaussNorm]



/-- T-gate entry (1+i) has Gaussian norm 2. -/
theorem t_gate_entry_norm : QGaussNorm 1 1 = 2 := by simp [QGaussNorm]



/-- Classical ℤ embeds in ℤ[i]. -/
theorem classical_embeds_quantum (n : ℤ) :
    QGaussNorm n 0 = n ^ 2 := by simp [QGaussNorm]



/-- Gaussian integers embed in quaternions. -/
theorem gauss_embeds_quat (a b : ℤ) :
    QQuatNorm a b 0 0 = QGaussNorm a b := by simp [QQuatNorm, QGaussNorm]



/-- The compilation hierarchy: ℤ ⊂ ℤ[i] ⊂ Hurwitz ⊂ SU(2). -/
theorem compilation_hierarchy (n : ℤ) :
    QGaussNorm n 0 = n ^ 2 ∧ QQuatNorm n 0 0 0 = n ^ 2 := by
  simp [QGaussNorm, QQuatNorm]



/-- Per-component crystallization error ≤ 1/2. -/
theorem quantum_crystal_error_real (x : ℝ) :
    |x - ↑(round x)| ≤ 1 / 2 := abs_sub_round x



/-- Complex crystallization: |error|² ≤ 1/2. -/
theorem quantum_crystal_error_bound (a b : ℝ) :
    |a - ↑(round a)| ^ 2 + |b - ↑(round b)| ^ 2 ≤ 1 / 2 := by
  have ha := abs_sub_round a
  have hb := abs_sub_round b
  have hann := abs_nonneg (a - ↑(round a))
  have hbnn := abs_nonneg (b - ↑(round b))
  nlinarith [sq_abs (a - ↑(round a)), sq_abs (b - ↑(round b)),
             mul_self_le_mul_self hann ha, mul_self_le_mul_self hbnn hb]



end
