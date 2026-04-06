/-
# Solovay-Kitaev Approximation Theory

## Overview

The Solovay-Kitaev theorem: any finite gate set generating a dense subgroup
of SU(2) can approximate any target unitary to precision ε using O(log^c(1/ε))
gates, c ≈ 3.97.
-/
import Mathlib

open Real

noncomputable section

/-! ## §1: Approximation Theory -/

theorem sk_recursion_convergence (ε : ℝ) (hε : 0 < ε) (hε1 : ε < 1) :
    ε ^ 2 < ε := by nlinarith [sq_abs ε]

theorem sk_precision_pos (ε : ℝ) (hε : 0 < ε) (n : ℕ) :
    ε ^ (2 ^ n) > 0 := by positivity

theorem sk_gate_count_bound (d : ℕ) : 5 ^ d ≥ 1 := Nat.one_le_pow d 5 (by omega)
theorem sk_exponent_bound : (5 : ℝ) > (3 / 2) ^ 3 := by norm_num
theorem sk_improved_bound : (5 : ℝ) > (3 / 2) ^ 2 := by norm_num

/-! ## §2: Group Commutator Structure -/

def skCommutator {G : Type*} [Group G] (u v : G) : G := u * v * u⁻¹ * v⁻¹

theorem skCommutator_one_left {G : Type*} [Group G] (v : G) :
    skCommutator 1 v = 1 := by simp [skCommutator]
theorem skCommutator_one_right {G : Type*} [Group G] (u : G) :
    skCommutator u 1 = 1 := by simp [skCommutator]
theorem skCommutator_self {G : Type*} [Group G] (u : G) :
    skCommutator u u = 1 := by simp [skCommutator, mul_inv_cancel]
theorem skCommutator_inv_right {G : Type*} [Group G] (u v : G) :
    skCommutator u v⁻¹ = u * v⁻¹ * u⁻¹ * v := by simp [skCommutator]

theorem skCommutator_conjugate {G : Type*} [Group G] (g u v : G) :
    skCommutator (g * u * g⁻¹) (g * v * g⁻¹) =
    g * skCommutator u v * g⁻¹ := by
  simp [skCommutator, mul_assoc]; group

/-! ## §3: Cayley Ball -/

def skCayleyBall {G : Type*} [Group G] (S : Set G) (n : ℕ) : Set G :=
  {g | ∃ (words : List G), (∀ w ∈ words, w ∈ S ∨ w⁻¹ ∈ S) ∧
    words.length ≤ n ∧ words.prod = g}

theorem skCayleyBall_mono {G : Type*} [Group G] (S : Set G) {m n : ℕ} (h : m ≤ n) :
    skCayleyBall S m ⊆ skCayleyBall S n := by
  intro g ⟨words, hwords, hlen, hprod⟩
  exact ⟨words, hwords, le_trans hlen h, hprod⟩

theorem sk_one_mem_cayleyBall {G : Type*} [Group G] (S : Set G) (n : ℕ) :
    (1 : G) ∈ skCayleyBall S n :=
  ⟨[], by simp, Nat.zero_le n, by simp⟩

/-! ## §4: Circuit Depth Bounds -/

theorem sk_log_inv_pos (ε : ℝ) (hε : 0 < ε) (hε1 : ε < 1) :
    Real.log (1 / ε) > 0 := by
  apply Real.log_pos; rw [one_div]; exact one_lt_inv_iff₀.mpr ⟨hε, hε1⟩

end
