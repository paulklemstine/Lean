/-
# Higher commutators in `U_q(sl₂)`: the `[E, Fᵐ]` formula

This file proves the fundamental higher commutation relation of `U_q(sl₂)`,

`E Fᵐ − Fᵐ E = [m]_q · F^{m−1} · (q^{−(m−1)}K − q^{m−1}K⁻¹)/(q − q⁻¹)`,

for the hypothesis-form presentation `QuantumSL2.IsUqSl2` of `Physics.QuantumSL2ClassicalLimit`.
It is the identity that controls Verma modules, the singular vectors that cut out the
finite-dimensional representations, and Lusztig's divided powers; at `q = 1` it degenerates to the
classical `sl₂` formula `[e, fᵐ] = m f^{m−1}(h − (m−1))`.

## Contents

* `QuantumSerre.K_mul_F_pow`, `QuantumSerre.Ki_mul_F_pow`: the Cartan generator moves past `Fᵐ`
  at the cost of `q^{∓2m}`.
* `QuantumSerre.E_mul_F_pow_commutator`: the higher commutator formula (proved by induction on
  `m`, with the two scalar recursions `[m+1]q^{m+2} + 1 = [m+2]q^{m+1}` and its `q ↦ q⁻¹`
  companion as the arithmetic engine).
* `QuantumSerre.qInt_succ_rec`, `QuantumSerre.qInt_succ_rec_inv`: those two scalar recursions,
  proved directly from the definition of the quantum integer.
* `QuantumSerre.E_mul_F_sq`: the `m = 2` instance, written out.
-/

import Mathlib
import Physics.QuantumSL2ClassicalLimit

namespace QuantumSerre

open QuantumSL2

/-! ## 1. The scalar recursions -/

section Scalars

variable {k : Type*} [Field k]

@[simp] theorem qInt_one (q : k) (hd : q - q⁻¹ ≠ 0) : qInt q 1 = 1 := by
  rw [qInt]
  simp [div_self hd]

/-- `[m+1]_q · q^{m+2} + 1 = [m+2]_q · q^{m+1}`. -/
theorem qInt_succ_rec (q : k) (hq : q ≠ 0) (hd : q - q⁻¹ ≠ 0) (m : ℕ) :
    qInt q ((m : ℤ) + 1) * q ^ (m + 2) + 1 = qInt q ((m : ℤ) + 2) * q ^ (m + 1) := by
  have hm : q ^ (m : ℤ) = q ^ m := zpow_natCast q m
  have hmne : q ^ m ≠ 0 := pow_ne_zero _ hq
  have hq2 : q ^ 2 - 1 ≠ 0 := by
    intro hc
    apply hd
    field_simp
    linear_combination hc
  have e1 : q ^ ((m : ℤ) + 1) = q ^ m * q := by
    rw [zpow_add₀ hq, hm, zpow_one]
  have e2 : q ^ (-((m : ℤ) + 1)) = (q ^ m * q)⁻¹ := by rw [zpow_neg, e1]
  have e3 : q ^ ((m : ℤ) + 2) = q ^ m * q ^ 2 := by
    rw [zpow_add₀ hq, hm]
    congr 1
    rw [show ((2 : ℤ)) = ((2 : ℕ) : ℤ) from rfl, zpow_natCast]
  have e4 : q ^ (-((m : ℤ) + 2)) = (q ^ m * q ^ 2)⁻¹ := by rw [zpow_neg, e3]
  rw [qInt, qInt, e1, e2, e3, e4]
  field_simp
  ring

/-- The `q ↦ q⁻¹` companion: `[m+1]_q · q^{−(m+2)} + 1 = [m+2]_q · q^{−(m+1)}`. -/
theorem qInt_succ_rec_inv (q : k) (hq : q ≠ 0) (hd : q - q⁻¹ ≠ 0) (m : ℕ) :
    qInt q ((m : ℤ) + 1) * (q⁻¹) ^ (m + 2) + 1 = qInt q ((m : ℤ) + 2) * (q⁻¹) ^ (m + 1) := by
  have hm : q ^ (m : ℤ) = q ^ m := zpow_natCast q m
  have hmne : q ^ m ≠ 0 := pow_ne_zero _ hq
  have hq2 : q ^ 2 - 1 ≠ 0 := by
    intro hc
    apply hd
    field_simp
    linear_combination hc
  have e1 : q ^ ((m : ℤ) + 1) = q ^ m * q := by
    rw [zpow_add₀ hq, hm, zpow_one]
  have e2 : q ^ (-((m : ℤ) + 1)) = (q ^ m * q)⁻¹ := by rw [zpow_neg, e1]
  have e3 : q ^ ((m : ℤ) + 2) = q ^ m * q ^ 2 := by
    rw [zpow_add₀ hq, hm]
    congr 1
    rw [show ((2 : ℤ)) = ((2 : ℕ) : ℤ) from rfl, zpow_natCast]
  have e4 : q ^ (-((m : ℤ) + 2)) = (q ^ m * q ^ 2)⁻¹ := by rw [zpow_neg, e3]
  rw [qInt, qInt, e1, e2, e3, e4, inv_pow, inv_pow]
  field_simp
  ring

end Scalars

/-! ## 2. Moving the Cartan generator past `Fᵐ` -/

section Algebra

variable {k : Type*} [Field k] {A : Type*} [Ring A] [Algebra k A]
variable {q : k} {E F Kk Ki : A}

/-- `K F = q⁻² F K`. -/
theorem K_mul_F (h : IsUqSl2 q E F Kk Ki) : Kk * F = ((q ^ 2)⁻¹) • (F * Kk) := by
  rw [← h.K_F, smul_smul, inv_mul_cancel₀ (pow_ne_zero 2 h.q_ne), one_smul]

/-- `K⁻¹ F = q² F K⁻¹`. -/
theorem Ki_mul_F (h : IsUqSl2 q E F Kk Ki) : Ki * F = (q ^ 2) • (F * Ki) := by
  rw [h.F_Ki, smul_smul, mul_inv_cancel₀ (pow_ne_zero 2 h.q_ne), one_smul]

/-- `K Fᵐ = q^{-2m} Fᵐ K`. -/
theorem K_mul_F_pow (h : IsUqSl2 q E F Kk Ki) (m : ℕ) :
    Kk * F ^ m = (((q ^ 2)⁻¹) ^ m) • (F ^ m * Kk) := by
  induction m with
  | zero => simp
  | succ m ih =>
      rw [pow_succ, ← mul_assoc, ih, smul_mul_assoc, mul_assoc, K_mul_F h, mul_smul_comm,
        smul_smul]
      simp only [mul_assoc]
      match_scalars
      ring

/-- `K⁻¹ Fᵐ = q^{2m} Fᵐ K⁻¹`. -/
theorem Ki_mul_F_pow (h : IsUqSl2 q E F Kk Ki) (m : ℕ) :
    Ki * F ^ m = ((q ^ 2) ^ m) • (F ^ m * Ki) := by
  induction m with
  | zero => simp
  | succ m ih =>
      rw [pow_succ, ← mul_assoc, ih, smul_mul_assoc, mul_assoc, Ki_mul_F h, mul_smul_comm,
        smul_smul]
      simp only [mul_assoc]
      match_scalars
      ring

/-! ## 3. The higher commutator -/

/-- **The `[E, Fᵐ]` formula in `U_q(sl₂)`.**
`E F^{m+1} − F^{m+1} E = [m+1]_q · F^m · (q^{−m}K − q^{m}K⁻¹)/(q − q⁻¹)`. -/
theorem E_mul_F_pow_commutator (h : IsUqSl2 q E F Kk Ki) (m : ℕ) :
    E * F ^ (m + 1) - F ^ (m + 1) * E
      = (qInt q ((m : ℤ) + 1) * (q - q⁻¹)⁻¹) • (F ^ m * ((q⁻¹) ^ m • Kk - q ^ m • Ki)) := by
  have hq := h.q_ne
  have hd := h.d_ne
  have hEF : F * E = E * F - (q - q⁻¹)⁻¹ • (Kk - Ki) := by rw [← h.E_F]; abel
  induction m with
  | zero =>
      have hc0 : ((0 : ℕ) : ℤ) + 1 = 1 := by norm_num
      rw [hc0, qInt_one q hd]
      simp only [pow_zero, pow_one, one_mul, one_smul, zero_add]
      rw [← h.E_F]
  | succ m ih =>
      have key : E * F ^ (m + 1 + 1) - F ^ (m + 1 + 1) * E
          = (E * F ^ (m + 1) - F ^ (m + 1) * E) * F
            + (q - q⁻¹)⁻¹ • (F ^ (m + 1) * (Kk - Ki)) := by
        rw [pow_succ, ← mul_assoc, mul_assoc (F ^ (m + 1)) F E, hEF]
        simp only [mul_sub, sub_mul, mul_smul_comm, mul_assoc]
        abel
      rw [key, ih]
      have hKF : Kk * F = ((q ^ 2)⁻¹) • (F * Kk) := K_mul_F h
      have hKiF : Ki * F = (q ^ 2) • (F * Ki) := Ki_mul_F h
      simp only [smul_mul_assoc, mul_smul_comm, sub_mul, mul_sub, smul_sub, smul_smul,
        mul_assoc, hKF, hKiF, pow_succ]
      have hrec := qInt_succ_rec q hq hd m
      have hrecinv := qInt_succ_rec_inv q hq hd m
      have hcast : (((m + 1 : ℕ) : ℤ) + 1) = ((m : ℤ) + 2) := by push_cast; ring
      rw [hcast]
      match_scalars
      · linear_combination (q - q⁻¹)⁻¹ * hrecinv
      · linear_combination (-(q - q⁻¹)⁻¹) * hrec

/-- **Singular vectors.**  If `v` is a highest-weight vector of weight `n` in any `U_q(sl₂)`-module
(`E v = 0`, `K v = qⁿ v`, `K⁻¹ v = q^{-n} v`), then `F^{n+1} v` is again annihilated by `E`; it
therefore generates a submodule, whose quotient is the `(n+1)`-dimensional module constructed in
`Physics.QuantumSL2ClassicalLimit`.  The proof is the vanishing of the scalar
`q^{-n}·qⁿ − qⁿ·q^{-n}` in the `[E, F^{n+1}]` formula. -/
theorem highest_weight_singular (h : IsUqSl2 q E F Kk Ki) (n : ℕ)
    {M : Type*} [AddCommGroup M] [Module k M] [Module A M] [IsScalarTower k A M]
    {v : M} (hE : E • v = 0) (hK : Kk • v = (q ^ n) • v) (hKi : Ki • v = ((q⁻¹) ^ n) • v) :
    E • (F ^ (n + 1) • v) = 0 := by
  have hx := E_mul_F_pow_commutator h n
  have hsplit : (E * F ^ (n + 1)) • v
      = (F ^ (n + 1) * E) • v
        + ((qInt q ((n : ℤ) + 1) * (q - q⁻¹)⁻¹)
            • (F ^ n * ((q⁻¹) ^ n • Kk - q ^ n • Ki))) • v := by
    rw [← hx, sub_smul]
    abel
  have hzero : (((q⁻¹) ^ n • Kk - q ^ n • Ki) : A) • v = 0 := by
    rw [sub_smul, smul_assoc, smul_assoc, hK, hKi, smul_smul, smul_smul,
      mul_comm ((q⁻¹) ^ n) (q ^ n), sub_self]
  rw [← mul_smul, hsplit, mul_smul, hE, smul_zero, zero_add, smul_assoc]
  rw [mul_smul (F ^ n) ((q⁻¹) ^ n • Kk - q ^ n • Ki) v, hzero, smul_zero, smul_zero]

/-- The `m = 2` instance, written out: `E F² − F² E = (q+q⁻¹) F (q⁻¹K − qK⁻¹)/(q−q⁻¹)`. -/
theorem E_mul_F_sq (h : IsUqSl2 q E F Kk Ki) :
    E * F ^ 2 - F ^ 2 * E
      = ((q + q⁻¹) * (q - q⁻¹)⁻¹) • (F * (q⁻¹ • Kk - q • Ki)) := by
  have := E_mul_F_pow_commutator h 1
  have hc : ((1 : ℕ) : ℤ) + 1 = 2 := by norm_num
  rw [hc, qInt_two q h.q_ne h.d_ne] at this
  simpa using this

end Algebra

/-! ## 4. The classical shadow at `q = 1` -/

section Classical

variable {k : Type*} [Field k] {A : Type*} [Ring A] [Algebra k A] {e f hh : A}

/-- **The classical `[e, fᵐ]` formula in `U(sl₂)`**: `e f^{m+1} − f^{m+1} e = (m+1) f^m h −
m(m+1) f^m`.  This is the `q → 1` shadow of `E_mul_F_pow_commutator`: the quantum integer
`[m+1]_q` degenerates to `m+1` (`QuantumSL2.qInt_tendsto`) and the singular combination
`(q^{−m}K − q^{m}K⁻¹)/(q − q⁻¹)` degenerates to `h − m`. -/
theorem e_mul_f_pow_commutator (h : IsUSl2 e f hh) (m : ℕ) :
    e * f ^ (m + 1) - f ^ (m + 1) * e
      = ((m : k) + 1) • (f ^ m * hh) - (((m : k) + 1) * (m : k)) • f ^ m := by
  have hef : f * e = e * f - hh := by rw [← h.e_f]; abel
  have hhf : hh * f = f * hh - (2 : k) • f := by
    rw [two_smul]
    linear_combination (norm := abel) h.h_f
  induction m with
  | zero => simpa using h.e_f
  | succ m ih =>
      have key : e * f ^ (m + 1 + 1) - f ^ (m + 1 + 1) * e
          = (e * f ^ (m + 1) - f ^ (m + 1) * e) * f + f ^ (m + 1) * hh := by
        rw [pow_succ, ← mul_assoc, mul_assoc (f ^ (m + 1)) f e, hef]
        simp only [mul_sub, sub_mul, mul_assoc]
        abel
      rw [key, ih]
      simp only [smul_mul_assoc, mul_smul_comm, sub_mul, mul_sub, smul_sub, smul_smul,
        mul_assoc, hhf, pow_succ]
      push_cast
      match_scalars <;> ring

end Classical

end QuantumSerre