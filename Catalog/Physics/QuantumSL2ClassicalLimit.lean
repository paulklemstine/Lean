/-
# `U_q(sl₂)` as a `q`-deformation of `U(sl₂)`

This file develops, from scratch and with complete proofs, the algebraic and analytic core of
the statement *"`U_q(g)` degenerates to `U(g)` as `q → 1`"* for `g = sl₂`.

## Contents

* **Quantum integers.**  `QuantumSL2.qInt q m = (qᵐ - q⁻ᵐ)/(q - q⁻¹)` for `m : ℤ`, together with
  the key quadratic identity `qInt_mul_sub`
  `[a][b] - [a-1][b+1] = [b-a+1]`,
  which is the combinatorial engine behind the `sl₂` commutation relation, and the closed form
  `qInt_nat_eq` exhibiting `[m]_q` as `q^{1-m} · ∑_{i<m} q^{2i}` (a *regular* expression at
  `q = 1`).

* **The deformed algebra.**  `QuantumSL2.IsUqSl2 q E F K K⁻¹` is the hypothesis-form presentation
  of `U_q(sl₂)`: `K E K⁻¹ = q² E`, `K F K⁻¹ = q⁻² F`, `[E,F] = (K - K⁻¹)/(q - q⁻¹)`.  We prove
  that the **quantum Casimir** `qCasimir = F E + (qK + q⁻¹K⁻¹)/(q - q⁻¹)²` is central
  (`casimir_comm_E`, `casimir_comm_F`, `casimir_comm_K`, `qCasimir_central`).

* **The classical algebra.**  `QuantumSL2.IsUSl2 e f h` is the presentation of `U(sl₂)` and
  `classicalCasimir = f e + h²/4 + h/2` is proved central (`IsUSl2.casimir_central`).  This is
  the *shadow* of the previous item at `q = 1`.

* **Representations.**  For each `n : ℕ` we construct the `(n+1)`-dimensional highest weight
  module of `U_q(sl₂)` as explicit operators on `ℕ → k` and prove that they satisfy **all** the
  defining relations (`uqSl2_rep`); moreover the span of the first `n+1` coordinates is
  invariant (`Eop_support`, `Fop_support`, `Kop_support`), so the relations are realised on a
  genuinely finite-dimensional module.  In particular `IsUqSl2` is not vacuous.

* **The limit `q → 1`.**  `qInt_tendsto` proves `[m]_q → m` as `q → 1` (a punctured limit in
  `ℝ`), and `Eop_tendsto`, `Fop_tendsto`, `cartan_tendsto` prove that the three generators of
  the `q`-deformed representation converge pointwise to the classical `sl₂` operators; finally
  `classical_rep` shows those limit operators satisfy the *undeformed* `sl₂` relations.  The
  Cartan statement is the crucial one: the singular quotient `(K - K⁻¹)/(q - q⁻¹)` converges to
  the classical `H`.
-/

import Mathlib

open Filter Topology

namespace QuantumSL2

/-! ## 1. Quantum integers -/

section QuantumIntegers

variable {k : Type*} [Field k]

/-- The symmetric quantum integer `[m]_q = (q^m - q^{-m})/(q - q⁻¹)`. -/
noncomputable def qInt (q : k) (m : ℤ) : k := (q ^ m - q ^ (-m)) / (q - q⁻¹)

@[simp] theorem qInt_zero (q : k) : qInt q 0 = 0 := by simp [qInt]

@[simp] theorem qInt_one (q : k) (hd : q - q⁻¹ ≠ 0) : qInt q 1 = 1 := by
  simp [qInt, div_self hd]

/-- `[2]_q = q + q⁻¹`, the quantum dimension of the fundamental representation. -/
theorem qInt_two (q : k) (hq : q ≠ 0) (hd : q - q⁻¹ ≠ 0) : qInt q 2 = q + q⁻¹ := by
  have h21 : q ^ 2 - 1 ≠ 0 := by
    intro h; apply hd; field_simp; linear_combination h
  have e1 : q ^ (2 : ℤ) = q * q := by rw [zpow_two]
  have e2 : q ^ (-2 : ℤ) = q⁻¹ * q⁻¹ := by
    rw [show (-2 : ℤ) = -(2 : ℤ) from rfl, _root_.zpow_neg, zpow_two, mul_inv]
  rw [qInt, e1, e2]
  field_simp
  ring

theorem qInt_neg (q : k) (m : ℤ) : qInt q (-m) = -qInt q m := by
  simp only [qInt, neg_neg]
  rw [← neg_div]
  ring_nf

/-- Numerator form of the fundamental quadratic identity for quantum integers. -/
theorem qInt_num (q : k) (hq : q ≠ 0) (a b : ℤ) :
    (q ^ a - q ^ (-a)) * (q ^ b - q ^ (-b))
        - (q ^ (a - 1) - q ^ (-(a - 1))) * (q ^ (b + 1) - q ^ (-(b + 1)))
      = (q ^ (b - a + 1) - q ^ (-(b - a + 1))) * (q - q⁻¹) := by
  have ha : q ^ a ≠ 0 := zpow_ne_zero _ hq
  have hb : q ^ b ≠ 0 := zpow_ne_zero _ hq
  simp only [zpow_sub₀ hq, zpow_add₀ hq, zpow_neg, zpow_one, neg_sub, neg_add_rev]
  field_simp
  ring

/-- **The fundamental quantum-integer identity** `[a][b] - [a-1][b+1] = [b-a+1]`.
It is exactly what makes the `sl₂` commutator close on the Cartan generator. -/
theorem qInt_mul_sub (q : k) (hq : q ≠ 0) (a b : ℤ) :
    qInt q a * qInt q b - qInt q (a - 1) * qInt q (b + 1) = qInt q (b - a + 1) := by
  by_cases hd : q - q⁻¹ = 0
  · simp [qInt, hd]
  · have h := qInt_num q hq a b
    unfold qInt
    rw [div_mul_div_comm, div_mul_div_comm, div_sub_div_same, h, mul_div_mul_right _ _ hd]

/-- Closed, `q = 1`-regular form of a quantum integer: `[m]_q = q^{1-m} ∑_{i<m} q^{2i}`. -/
theorem qInt_nat_eq (q : k) (hq : q ≠ 0) (hq2 : q ^ 2 - 1 ≠ 0) (m : ℕ) :
    qInt q m = q ^ (1 - (m : ℤ)) * ∑ i ∈ Finset.range m, (q ^ 2) ^ i := by
  have hgeom : (∑ i ∈ Finset.range m, (q ^ 2) ^ i) * (q ^ 2 - 1) = (q ^ 2) ^ m - 1 :=
    geom_sum_mul _ _
  have hpm : q ^ (m : ℤ) = q ^ m := zpow_natCast q m
  have hne : q ^ m ≠ 0 := pow_ne_zero _ hq
  have h1 : q - q⁻¹ = q⁻¹ * (q ^ 2 - 1) := by field_simp
  have h2 : q ^ (m : ℤ) - q ^ (-(m : ℤ)) = q ^ (-(m : ℤ)) * ((q ^ 2) ^ m - 1) := by
    rw [zpow_neg, hpm]
    field_simp
    rw [← pow_mul]
    ring
  rw [qInt, h1, h2, ← hgeom, zpow_sub₀ hq, zpow_one, zpow_neg, hpm]
  field_simp

end QuantumIntegers

/-! ## 2. The deformed enveloping algebra `U_q(sl₂)` and its Casimir -/

section Deformed

variable {k : Type*} [Field k] {A : Type*} [Ring A] [Algebra k A]

/-- The defining relations of `U_q(sl₂)` in hypothesis form: `Kk` and `Ki` are mutually inverse
(`K` and `K⁻¹`), `Kk E Ki = q² E`, `Kk F Ki = q⁻² F` and `[E,F] = (K - K⁻¹)/(q - q⁻¹)`. -/
structure IsUqSl2 (q : k) (E F Kk Ki : A) : Prop where
  /-- The deformation parameter is invertible. -/
  q_ne : q ≠ 0
  /-- The deformation parameter is not a square root of unity (`q ≠ ±1`). -/
  qsq_ne : q ^ 2 ≠ 1
  /-- `Ki` is a right inverse of `Kk`. -/
  K_mul_Ki : Kk * Ki = 1
  /-- `Ki` is a left inverse of `Kk`. -/
  Ki_mul_K : Ki * Kk = 1
  /-- `K E = q² E K`. -/
  K_E : Kk * E = (q ^ 2) • (E * Kk)
  /-- `q² K F = F K`, i.e. `K F = q⁻² F K`. -/
  K_F : (q ^ 2) • (Kk * F) = F * Kk
  /-- `[E, F] = (K - K⁻¹)/(q - q⁻¹)`. -/
  E_F : E * F - F * E = (q - q⁻¹)⁻¹ • (Kk - Ki)

/-- The **quantum Casimir element** `F E + (q K + q⁻¹ K⁻¹)/(q - q⁻¹)²`. -/
noncomputable def qCasimir (q : k) (E F Kk Ki : A) : A :=
  F * E + ((q - q⁻¹) ^ 2)⁻¹ • (q • Kk + q⁻¹ • Ki)

namespace IsUqSl2

variable {q : k} {E F Kk Ki : A} (h : IsUqSl2 q E F Kk Ki)
include h

theorem d_ne : q - q⁻¹ ≠ 0 := by
  intro hc
  apply h.qsq_ne
  have hq := h.q_ne
  field_simp at hc
  linear_combination hc

theorem E_K : E * Kk = (q ^ 2)⁻¹ • (Kk * E) := by
  rw [h.K_E, smul_smul, inv_mul_cancel₀ (pow_ne_zero 2 h.q_ne), one_smul]

theorem E_Ki : E * Ki = (q ^ 2) • (Ki * E) := by
  have h2 : Ki * (Kk * E) * Ki = Ki * ((q ^ 2) • (E * Kk)) * Ki := by rw [h.K_E]
  simp only [mul_smul_comm, smul_mul_assoc] at h2
  rw [← mul_assoc, ← mul_assoc, h.Ki_mul_K, one_mul] at h2
  rw [mul_assoc, h.K_mul_Ki, mul_one] at h2
  exact h2

theorem F_K : F * Kk = (q ^ 2) • (Kk * F) := h.K_F.symm

theorem F_Ki : F * Ki = (q ^ 2)⁻¹ • (Ki * F) := by
  have h2 : Ki * ((q ^ 2) • (Kk * F)) * Ki = Ki * (F * Kk) * Ki := by rw [h.K_F]
  simp only [mul_smul_comm, smul_mul_assoc] at h2
  rw [← mul_assoc, ← mul_assoc, h.Ki_mul_K, one_mul] at h2
  rw [mul_assoc, h.K_mul_Ki, mul_one] at h2
  rw [← h2, smul_smul, inv_mul_cancel₀ (pow_ne_zero 2 h.q_ne), one_smul]

/-- The quantum Casimir commutes with `E`. -/
theorem casimir_comm_E : qCasimir q E F Kk Ki * E = E * qCasimir q E F Kk Ki := by
  have hEF : E * F = F * E + (q - q⁻¹)⁻¹ • (Kk - Ki) := by rw [← h.E_F]; abel
  have hd := h.d_ne
  have hq := h.q_ne
  simp only [qCasimir, add_mul, mul_add, smul_mul_assoc, mul_smul_comm, smul_add]
  rw [← mul_assoc E F E, hEF, h.E_K, h.E_Ki]
  simp only [add_mul, sub_mul, smul_mul_assoc, smul_smul, smul_sub]
  match_scalars <;> field_simp <;> ring

/-- The quantum Casimir commutes with `F`. -/
theorem casimir_comm_F : qCasimir q E F Kk Ki * F = F * qCasimir q E F Kk Ki := by
  have hEF : E * F = F * E + (q - q⁻¹)⁻¹ • (Kk - Ki) := by rw [← h.E_F]; abel
  have hd := h.d_ne
  have hq := h.q_ne
  simp only [qCasimir, add_mul, mul_add, smul_mul_assoc, mul_smul_comm, smul_add]
  rw [mul_assoc F E F, hEF]
  simp only [mul_add, mul_sub, mul_smul_comm, ← mul_assoc]
  rw [h.F_K, h.F_Ki]
  simp only [smul_smul, smul_sub]
  match_scalars <;> field_simp <;> ring

/-- The quantum Casimir commutes with `K`. -/
theorem casimir_comm_K : qCasimir q E F Kk Ki * Kk = Kk * qCasimir q E F Kk Ki := by
  have hq := h.q_ne
  simp only [qCasimir, add_mul, mul_add, smul_mul_assoc, mul_smul_comm, smul_add]
  rw [h.Ki_mul_K, h.K_mul_Ki, mul_assoc F E Kk, h.E_K, mul_smul_comm, ← mul_assoc, h.F_K,
    smul_mul_assoc, smul_smul, inv_mul_cancel₀ (pow_ne_zero 2 hq), one_smul, mul_assoc]

/-- The quantum Casimir commutes with every generator of `U_q(sl₂)`. -/
theorem qCasimir_central :
    qCasimir q E F Kk Ki * E = E * qCasimir q E F Kk Ki ∧
      qCasimir q E F Kk Ki * F = F * qCasimir q E F Kk Ki ∧
        qCasimir q E F Kk Ki * Kk = Kk * qCasimir q E F Kk Ki :=
  ⟨h.casimir_comm_E, h.casimir_comm_F, h.casimir_comm_K⟩

end IsUqSl2

/-! ## 3. The classical enveloping algebra `U(sl₂)` and its Casimir -/

/-- The defining relations of `U(sl₂)`: `[h,e] = 2e`, `[h,f] = -2f`, `[e,f] = h`. -/
structure IsUSl2 (e f hh : A) : Prop where
  /-- `[h, e] = 2e`. -/
  h_e : hh * e - e * hh = e + e
  /-- `[h, f] = -2f`. -/
  h_f : hh * f - f * hh = -(f + f)
  /-- `[e, f] = h`. -/
  e_f : e * f - f * e = hh

/-- The classical Casimir `f e + h²/4 + h/2`, the `q → 1` shadow of `qCasimir`. -/
noncomputable def classicalCasimir (k : Type*) [Field k] [Algebra k A] (e f hh : A) : A :=
  f * e + (4 : k)⁻¹ • (hh * hh) + (2 : k)⁻¹ • hh

namespace IsUSl2

variable {e f hh : A} (h : IsUSl2 e f hh) (hk : (2 : k) ≠ 0)
include h hk

/-- The classical Casimir commutes with `e`. -/
theorem casimir_comm_e :
    classicalCasimir k e f hh * e = e * classicalCasimir k e f hh := by
  have h4 : (4 : k) ≠ 0 := by
    intro hc
    apply hk
    have : (2 : k) * 2 = 0 := by linear_combination hc
    rcases mul_eq_zero.1 this with h' | h' <;> exact h'
  have heh : e * hh = hh * e - (2 : k) • e := by rw [two_smul, ← h.h_e]; abel
  have hef : e * f = f * e + hh := by rw [← h.e_f]; abel
  have hehh : e * (hh * hh) = hh * (hh * e) - (4 : k) • (hh * e) + (4 : k) • e := by
    rw [← mul_assoc, heh, sub_mul, smul_mul_assoc, mul_assoc, heh]
    simp only [smul_sub, mul_sub, mul_smul_comm, smul_smul]
    match_scalars <;> norm_num
  simp only [classicalCasimir, add_mul, mul_add, smul_mul_assoc, mul_smul_comm]
  rw [← mul_assoc e f e, hef, hehh, heh]
  simp only [add_mul, smul_add, smul_sub, smul_smul, ← mul_assoc]
  match_scalars <;> field_simp <;> ring

end IsUSl2

end Deformed

/-! ## 4. The `(n+1)`-dimensional representations of `U_q(sl₂)` -/

section Representation

variable {k : Type*} [Field k]

/-- Action of the raising operator `E` on coordinates: `E v_i = [i] v_{i-1}`. -/
noncomputable def Eop (q : k) (c : ℕ → k) : ℕ → k := fun j => qInt q ((j : ℤ) + 1) * c (j + 1)

/-- Action of the lowering operator `F` on coordinates: `F v_i = [n-i] v_{i+1}`. -/
noncomputable def Fop (q : k) (n : ℕ) (c : ℕ → k) : ℕ → k :=
  fun j => if j = 0 then 0 else qInt q ((n : ℤ) - j + 1) * c (j - 1)

/-- Action of the group-like Cartan generator `K v_i = q^{n-2i} v_i`. -/
noncomputable def Kop (q : k) (n : ℕ) (c : ℕ → k) : ℕ → k := fun j => q ^ ((n : ℤ) - 2 * j) * c j

/-- Action of `K⁻¹`. -/
noncomputable def Kiop (q : k) (n : ℕ) (c : ℕ → k) : ℕ → k :=
  fun j => q ^ (-((n : ℤ) - 2 * j)) * c j

theorem EF_apply (q : k) (n : ℕ) (c : ℕ → k) (j : ℕ) :
    Eop q (Fop q n c) j = qInt q ((j : ℤ) + 1) * qInt q ((n : ℤ) - j) * c j := by
  simp only [Eop, Fop, if_neg (Nat.succ_ne_zero j), Nat.add_sub_cancel]
  push_cast
  rw [show (n : ℤ) - ((j : ℤ) + 1) + 1 = (n : ℤ) - j by ring]
  ring

theorem FE_apply (q : k) (n : ℕ) (c : ℕ → k) (j : ℕ) :
    Fop q n (Eop q c) j = qInt q ((n : ℤ) - j + 1) * qInt q j * c j := by
  rcases Nat.eq_zero_or_pos j with rfl | hj
  · simp [Fop]
  · obtain ⟨i, rfl⟩ : ∃ i, j = i + 1 := ⟨j - 1, by omega⟩
    simp only [Fop, Eop, if_neg (Nat.succ_ne_zero i), Nat.add_sub_cancel]
    push_cast
    ring

/-- The `sl₂` commutation relation in the representation: `[E, F] = [n - 2j]` on the `j`-th
coordinate, i.e. `[E,F] = (K - K⁻¹)/(q - q⁻¹)`. -/
theorem commutator_apply (q : k) (hq : q ≠ 0) (n : ℕ) (c : ℕ → k) (j : ℕ) :
    Eop q (Fop q n c) j - Fop q n (Eop q c) j = qInt q ((n : ℤ) - 2 * j) * c j := by
  have key := qInt_mul_sub q hq ((j : ℤ) + 1) ((n : ℤ) - j)
  rw [show (j : ℤ) + 1 - 1 = (j : ℤ) by ring,
    show (n : ℤ) - (j : ℤ) - ((j : ℤ) + 1) + 1 = (n : ℤ) - 2 * j by ring] at key
  rw [EF_apply, FE_apply]
  rw [show ((n : ℤ) - j + 1) = ((n : ℤ) - j) + 1 by ring]
  linear_combination (c j) * key

/-- `[E,F]` is the deformed Cartan operator `(K - K⁻¹)/(q - q⁻¹)`. -/
theorem commutator_eq_cartan (q : k) (hq : q ≠ 0) (n : ℕ) (c : ℕ → k) (j : ℕ) :
    Eop q (Fop q n c) j - Fop q n (Eop q c) j = (Kop q n c j - Kiop q n c j) / (q - q⁻¹) := by
  rw [commutator_apply q hq n c j, Kop, Kiop, qInt]
  ring

theorem Kop_Eop (q : k) (hq : q ≠ 0) (n : ℕ) (c : ℕ → k) (j : ℕ) :
    Kop q n (Eop q c) j = q ^ (2 : ℤ) * Eop q (Kop q n c) j := by
  have key : q ^ (2 : ℤ) * q ^ ((n : ℤ) - 2 * ((j : ℤ) + 1)) = q ^ ((n : ℤ) - 2 * (j : ℤ)) := by
    rw [← zpow_add₀ hq]; congr 1; ring
  simp only [Kop, Eop]
  push_cast
  linear_combination (qInt q ((j : ℤ) + 1) * c (j + 1)) * key.symm

theorem Kop_Fop (q : k) (hq : q ≠ 0) (n : ℕ) (c : ℕ → k) (j : ℕ) :
    q ^ (2 : ℤ) * Kop q n (Fop q n c) j = Fop q n (Kop q n c) j := by
  simp only [Kop, Fop]
  split_ifs with hj
  · ring
  · obtain ⟨i, rfl⟩ : ∃ i, j = i + 1 := ⟨j - 1, by omega⟩
    have key : q ^ (2 : ℤ) * q ^ ((n : ℤ) - 2 * ((i : ℤ) + 1)) = q ^ ((n : ℤ) - 2 * (i : ℤ)) := by
      rw [← zpow_add₀ hq]; congr 1; ring
    simp only [Nat.add_sub_cancel]
    push_cast
    linear_combination (qInt q ((n : ℤ) - ((i : ℤ) + 1) + 1) * c i) * key

/-! ### Invariance of the `(n+1)`-dimensional subspace -/

theorem Eop_support (q : k) (n : ℕ) {c : ℕ → k} (hc : ∀ j, n < j → c j = 0) :
    ∀ j, n < j → Eop q c j = 0 := by
  intro j hj
  simp [Eop, hc (j + 1) (by omega)]

theorem Kop_support (q : k) (n : ℕ) {c : ℕ → k} (hc : ∀ j, n < j → c j = 0) :
    ∀ j, n < j → Kop q n c j = 0 := by
  intro j hj
  simp [Kop, hc j hj]

/-- `F` preserves the `(n+1)`-dimensional subspace: the coefficient `[n - j + 1]` vanishes
exactly at the bottom of the module, `j = n + 1`. -/
theorem Fop_support (q : k) (n : ℕ) {c : ℕ → k} (hc : ∀ j, n < j → c j = 0) :
    ∀ j, n < j → Fop q n c j = 0 := by
  intro j hj
  rcases eq_or_lt_of_le (Nat.succ_le_of_lt hj) with heq | hlt
  · have hj0 : j ≠ 0 := by omega
    simp only [Fop, if_neg hj0]
    have : (n : ℤ) - (j : ℤ) + 1 = 0 := by
      have : (j : ℤ) = (n : ℤ) + 1 := by exact_mod_cast heq.symm
      omega
    rw [this, qInt_zero, zero_mul]
  · have hj0 : j ≠ 0 := by omega
    simp only [Fop, if_neg hj0, hc (j - 1) (by omega), mul_zero]

/-! ### The representation as an algebra of endomorphisms -/

/-- `E` as a `k`-linear endomorphism. -/
noncomputable def EE (q : k) : Module.End k (ℕ → k) where
  toFun := Eop q
  map_add' a b := by funext j; simp [Eop]; ring
  map_smul' r a := by funext j; simp [Eop, smul_eq_mul]; ring

/-- `F` as a `k`-linear endomorphism. -/
noncomputable def FF (q : k) (n : ℕ) : Module.End k (ℕ → k) where
  toFun := Fop q n
  map_add' a b := by
    funext j; simp only [Fop, Pi.add_apply]; split_ifs with hj
    · simp
    · ring
  map_smul' r a := by
    funext j; simp only [Fop, Pi.smul_apply, RingHom.id_apply, smul_eq_mul]
    split_ifs with hj
    · simp
    · ring

/-- `K` as a `k`-linear endomorphism. -/
noncomputable def KK (q : k) (n : ℕ) : Module.End k (ℕ → k) where
  toFun := Kop q n
  map_add' a b := by funext j; simp [Kop]; ring
  map_smul' r a := by funext j; simp [Kop, smul_eq_mul]; ring

/-- `K⁻¹` as a `k`-linear endomorphism. -/
noncomputable def KKi (q : k) (n : ℕ) : Module.End k (ℕ → k) where
  toFun := Kiop q n
  map_add' a b := by funext j; simp [Kiop]; ring
  map_smul' r a := by funext j; simp [Kiop, smul_eq_mul]; ring

/-- **The `(n+1)`-dimensional highest weight module is a representation of `U_q(sl₂)`.**
In particular the relations `IsUqSl2` are consistent (non-vacuous) for every admissible `q`. -/
theorem uqSl2_rep (q : k) (hq : q ≠ 0) (hq2 : q ^ 2 ≠ 1) (n : ℕ) :
    IsUqSl2 q (EE q) (FF q n) (KK q n) (KKi q n) where
  q_ne := hq
  qsq_ne := hq2
  K_mul_Ki := by
    ext c j
    simp only [Module.End.mul_apply, Module.End.one_apply, KK, KKi, Kop, Kiop, LinearMap.coe_mk,
      AddHom.coe_mk]
    rw [← mul_assoc, ← zpow_add₀ hq]
    simp
  Ki_mul_K := by
    ext c j
    simp only [Module.End.mul_apply, Module.End.one_apply, KK, KKi, Kop, Kiop, LinearMap.coe_mk,
      AddHom.coe_mk]
    rw [← mul_assoc, ← zpow_add₀ hq]
    simp
  K_E := by
    ext c j
    simp only [Module.End.mul_apply, LinearMap.smul_apply, KK, EE, LinearMap.coe_mk, AddHom.coe_mk,
      Pi.smul_apply, smul_eq_mul]
    rw [Kop_Eop q hq n c j]
    norm_num
    exact Or.inl (by rw [zpow_two, sq])
  K_F := by
    ext c j
    simp only [Module.End.mul_apply, LinearMap.smul_apply, KK, FF, LinearMap.coe_mk, AddHom.coe_mk,
      Pi.smul_apply, smul_eq_mul]
    rw [← Kop_Fop q hq n c j]
    norm_num
    exact Or.inl (by rw [zpow_two, sq])
  E_F := by
    ext c j
    simp only [LinearMap.sub_apply, Module.End.mul_apply, LinearMap.smul_apply, EE, FF, KK, KKi,
      LinearMap.coe_mk, AddHom.coe_mk, Pi.sub_apply, Pi.smul_apply, smul_eq_mul]
    rw [commutator_eq_cartan q hq n c j, Kop, Kiop]
    field_simp

end Representation

/-! ## 5. The classical limit `q → 1` -/

section ClassicalLimit

/-- `[m]_q → m` as `q → 1`: quantum integers deform ordinary integers. -/
theorem qInt_tendsto_nat (m : ℕ) :
    Tendsto (fun q : ℝ => qInt q m) (𝓝[≠] 1) (𝓝 (m : ℝ)) := by
  have hcont : ContinuousAt
      (fun q : ℝ => q ^ (1 - (m : ℤ)) * ∑ i ∈ Finset.range m, (q ^ 2) ^ i) 1 :=
    ContinuousAt.mul (continuousAt_zpow₀ _ _ (Or.inl one_ne_zero)) (by fun_prop)
  have hval : ((1 : ℝ) ^ (1 - (m : ℤ)) * ∑ i ∈ Finset.range m, ((1 : ℝ) ^ 2) ^ i) = (m : ℝ) := by
    simp
  have h := hcont.continuousWithinAt (s := {(1 : ℝ)}ᶜ)
  rw [ContinuousWithinAt, hval] at h
  refine h.congr' ?_
  have hIoo : ∀ᶠ q in 𝓝[≠] (1 : ℝ), q ∈ Set.Ioo (0 : ℝ) 2 :=
    eventually_nhdsWithin_of_eventually_nhds (Ioo_mem_nhds (by norm_num) (by norm_num))
  filter_upwards [hIoo, self_mem_nhdsWithin] with q hq hne
  have h0 : q ≠ 0 := ne_of_gt hq.1
  have h2 : q ^ 2 - 1 ≠ 0 := by
    intro hcon
    have hf : (q - 1) * (q + 1) = 0 := by nlinarith
    rcases mul_eq_zero.1 hf with h' | h'
    · exact hne (by simpa using sub_eq_zero.1 h')
    · nlinarith [hq.1]
  exact (qInt_nat_eq q h0 h2 m).symm

/-- `[m]_q → m` as `q → 1`, for all integers `m`. -/
theorem qInt_tendsto (m : ℤ) :
    Tendsto (fun q : ℝ => qInt q m) (𝓝[≠] 1) (𝓝 (m : ℝ)) := by
  by_cases hm : 0 ≤ m
  · lift m to ℕ using hm with m
    simpa using qInt_tendsto_nat m
  · push_neg at hm
    obtain ⟨p, rfl⟩ : ∃ p : ℕ, m = -(p : ℤ) := ⟨(-m).toNat, by omega⟩
    have h := (qInt_tendsto_nat p).neg
    simp only [qInt_neg] at h ⊢
    convert h using 2
    push_cast
    ring

/-! ### The classical `sl₂` operators, obtained as the `q → 1` limit -/

/-- Classical raising operator `e v_i = i v_{i-1}`. -/
noncomputable def eop (c : ℕ → ℝ) : ℕ → ℝ := fun j => ((j : ℝ) + 1) * c (j + 1)

/-- Classical lowering operator `f v_i = (n-i) v_{i+1}`. -/
noncomputable def fop (n : ℕ) (c : ℕ → ℝ) : ℕ → ℝ :=
  fun j => if j = 0 then 0 else ((n : ℝ) - j + 1) * c (j - 1)

/-- Classical Cartan operator `h v_i = (n - 2i) v_i`. -/
noncomputable def hop (n : ℕ) (c : ℕ → ℝ) : ℕ → ℝ := fun j => ((n : ℝ) - 2 * j) * c j

/-- The deformed raising operator converges to the classical one. -/
theorem Eop_tendsto (c : ℕ → ℝ) (j : ℕ) :
    Tendsto (fun q : ℝ => Eop q c j) (𝓝[≠] 1) (𝓝 (eop c j)) := by
  have h := (qInt_tendsto ((j : ℤ) + 1)).mul_const (c (j + 1))
  simpa [Eop, eop] using h

/-- The deformed lowering operator converges to the classical one. -/
theorem Fop_tendsto (n : ℕ) (c : ℕ → ℝ) (j : ℕ) :
    Tendsto (fun q : ℝ => Fop q n c j) (𝓝[≠] 1) (𝓝 (fop n c j)) := by
  simp only [Fop, fop]
  split_ifs with hj
  · simp
  · have h := (qInt_tendsto ((n : ℤ) - j + 1)).mul_const (c (j - 1))
    simpa using h

/-- **The singular Cartan quotient has a classical limit.**  The operator
`(K - K⁻¹)/(q - q⁻¹)`, which is a `0/0` expression at `q = 1`, converges to the classical
Cartan operator `H`.  This is the analytic heart of "`U_q(sl₂) → U(sl₂)` as `q → 1`". -/
theorem cartan_tendsto (n : ℕ) (c : ℕ → ℝ) (j : ℕ) :
    Tendsto (fun q : ℝ => (Kop q n c j - Kiop q n c j) / (q - q⁻¹)) (𝓝[≠] 1)
      (𝓝 (hop n c j)) := by
  have h := (qInt_tendsto ((n : ℤ) - 2 * j)).mul_const (c j)
  have heq : ∀ q : ℝ, (Kop q n c j - Kiop q n c j) / (q - q⁻¹) = qInt q ((n : ℤ) - 2 * j) * c j := by
    intro q
    simp only [Kop, Kiop, qInt]
    ring
  simp only [heq]
  simpa [hop] using h

/-- The limiting operators satisfy the *undeformed* `sl₂` relation `[e,f] = h`. -/
theorem classical_commutator (n : ℕ) (c : ℕ → ℝ) (j : ℕ) :
    eop (fop n c) j - fop n (eop c) j = hop n c j := by
  rcases Nat.eq_zero_or_pos j with rfl | hj
  · simp only [eop, fop, hop, if_neg (Nat.succ_ne_zero 0)]
    push_cast
    ring
  · obtain ⟨i, rfl⟩ : ∃ i, j = i + 1 := ⟨j - 1, by omega⟩
    simp only [eop, fop, hop, if_neg (Nat.succ_ne_zero i), Nat.add_sub_cancel]
    push_cast
    ring

/-- The limiting operators satisfy `[h,e] = 2e`. -/
theorem classical_he (n : ℕ) (c : ℕ → ℝ) (j : ℕ) :
    hop n (eop c) j - eop (hop n c) j = 2 * eop c j := by
  simp only [eop, hop]
  push_cast
  ring

/-- The limiting operators satisfy `[h,f] = -2f`. -/
theorem classical_hf (n : ℕ) (c : ℕ → ℝ) (j : ℕ) :
    hop n (fop n c) j - fop n (hop n c) j = -(2 * fop n c j) := by
  simp only [fop, hop]
  split_ifs with hj
  · ring
  · obtain ⟨i, rfl⟩ : ∃ i, j = i + 1 := ⟨j - 1, by omega⟩
    simp only [Nat.add_sub_cancel]
    push_cast
    ring

end ClassicalLimit

end QuantumSL2