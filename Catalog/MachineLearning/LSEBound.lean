import Mathlib
import MachineLearning.TropicalAttention.Defs

/-!
# Theorem A: Log-Sum-Exp Approximates Tropical Matrix Product

The core quantitative bound: for any matrices X, Y and temperature τ > 0,
  tropMul(X,Y)_{ij} ≤ lseMul_τ(X,Y)_{ij} ≤ tropMul(X,Y)_{ij} + τ * log(n).

This is the algebraic heart of tropical attention theory.
-/

noncomputable section

open Finset BigOperators Real

/-! ## Scalar log-sum-exp bounds

The key fact: if `M = max_k a_k`, then `M ≤ log(∑_k exp(a_k)) ≤ M + log(n)`.
We prove this for a finite collection of reals indexed by `Fin n`.
-/

/-
The log of a sum of exponentials is at least the maximum exponent.
-/
theorem log_sum_exp_ge_sup' {n : ℕ} [Nonempty (Fin n)]
    (a : Fin n → ℝ) :
    Finset.univ.sup' Finset.univ_nonempty a ≤
      Real.log (∑ k : Fin n, Real.exp (a k)) := by
  rw [ Real.le_log_iff_exp_le ];
  · exact le_trans ( by aesop ) ( Finset.single_le_sum ( fun k _ => Real.exp_nonneg ( a k ) ) ( Finset.mem_univ ( Classical.choose ( Finset.exists_max_image Finset.univ ( fun k => a k ) ( Finset.univ_nonempty ) ) ) ) );
  · exact Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty

/-
The log of a sum of exponentials is at most the maximum exponent plus log(n).
-/
theorem log_sum_exp_le_sup'_add_log {n : ℕ} [Nonempty (Fin n)]
    (a : Fin n → ℝ) :
    Real.log (∑ k : Fin n, Real.exp (a k)) ≤
      Finset.univ.sup' Finset.univ_nonempty a + Real.log (Fintype.card (Fin n)) := by
  -- Let M = sup' a. For each k, a k ≤ M, so exp(a k) ≤ exp(M).
  have h_exp_le_exp_M : ∀ k : Fin n, Real.exp (a k) ≤ Real.exp (Finset.univ.sup' Finset.univ_nonempty a) := by
    exact fun k => Real.exp_le_exp.mpr ( Finset.le_sup' ( fun x => a x ) ( Finset.mem_univ k ) );
  rw [ Real.log_le_iff_le_exp ];
  · rw [ Real.exp_add, Real.exp_log ( Nat.cast_pos.mpr <| Fintype.card_pos ) ];
    simpa [ mul_comm ] using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => h_exp_le_exp_M i;
  · exact Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty

/-! ## Main LSE-Tropical bound -/

/-
**Theorem A (uniform log-sum-exp to tropical bound).**
    For all finite matrices X, Y, and τ > 0:
    `tropMul(X,Y)_{ij} ≤ lseMul_τ(X,Y)_{ij} ≤ tropMul(X,Y)_{ij} + τ * log(n)`.
-/
theorem lseMul_tropMul_bound
    {m n p : ℕ} [Nonempty (Fin n)]
    (τ : ℝ) (hτ : 0 < τ)
    (X : Matrix (Fin m) (Fin n) ℝ)
    (Y : Matrix (Fin n) (Fin p) ℝ) :
    ∀ i j,
      tropMul X Y i j ≤ lseMul τ X Y i j ∧
      lseMul τ X Y i j ≤ tropMul X Y i j + τ * Real.log (Fintype.card (Fin n)) := by
  unfold tropMul lseMul;
  intro i j;
  constructor;
  · convert mul_le_mul_of_nonneg_left ( log_sum_exp_ge_sup' fun k => ( X i k + Y k j ) / τ ) hτ.le using 1;
    simp +decide [ Finset.sup'_eq_csSup_image, mul_div_cancel₀ _ hτ.ne' ];
    rw [ ← smul_eq_mul, ← Real.sSup_smul_of_nonneg hτ.le ] ; congr ; ext ; simp +decide [ div_eq_inv_mul ];
    simp +decide [ Set.mem_smul_set, hτ.ne' ];
  · have := log_sum_exp_le_sup'_add_log ( fun k => ( X i k + Y k j ) / τ );
    convert mul_le_mul_of_nonneg_left this hτ.le using 1;
    simp +decide [ mul_add, mul_div_cancel₀ _ hτ.ne', Finset.sup'_eq_csSup_image ];
    rw [ ← smul_eq_mul, ← Real.sSup_smul_of_nonneg hτ.le ] ; congr ; ext ; simp +decide [ div_eq_inv_mul, mul_assoc, mul_comm, mul_left_comm, hτ.ne' ];
    simp +decide [ Set.mem_smul_set, mul_comm τ, hτ.ne' ]

/-
**Corollary: uniform sup-norm bound.**
    `|lseMul_τ(X,Y)_{ij} - tropMul(X,Y)_{ij}| ≤ τ * log(n)` for all i, j.
-/
theorem lseMul_tropMul_abs_le
    {m n p : ℕ} [Nonempty (Fin n)]
    (τ : ℝ) (hτ : 0 < τ)
    (X : Matrix (Fin m) (Fin n) ℝ)
    (Y : Matrix (Fin n) (Fin p) ℝ) :
    ∀ i j, |lseMul τ X Y i j - tropMul X Y i j| ≤ τ * Real.log (Fintype.card (Fin n)) := by
  exact fun i j => abs_sub_le_iff.mpr ⟨ by linarith [ lseMul_tropMul_bound τ hτ X Y i j ], by linarith [ lseMul_tropMul_bound τ hτ X Y i j ] ⟩

end