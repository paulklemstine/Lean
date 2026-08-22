/-
# Optimal mixed precision: the water-filling law for bit allocation

The NET-52 round closes with the question of *tail-aware mixed precision*: given a fixed total
bit budget spread over tensors of differing amplitude, how should the bits be allocated?

For absmax round-to-nearest, the worst-case `ℓ¹` damage of tensor `i` is proportional to its
amplitude `A i` times `2 ^ (−b i)`, so the natural objective is

`bitCost A b = ∑ i, A i · 2 ^ (−b i)`,  subject to  `∑ i, b i = B`.

We prove the exact optimum:

* `bitCost_ge_geometric` — for *every* allocation with total budget `B`,
  `bitCost A b ≥ n · (∏ A i)^(1/n) · 2 ^ (−B/n)`.  The bound is the arithmetic–geometric mean
  inequality applied to the per-tensor damages, so the geometric mean of the amplitudes — not
  their maximum or their sum — is the invariant that governs a memory budget.
* `bitCost_waterfilling` — the explicit allocation `b i = B/n + log₂ (A i) − mean log₂ A`
  spends exactly `B` bits and *attains* the bound: the optimum is achieved by giving each
  tensor a number of extra bits equal to its log-amplitude excess.
* `uniform_not_optimal` — a concrete two-tensor witness (`A = (1,4)`, `B = 0`) where the
  optimal allocation costs `4` and the uniform allocation costs `5`: uniform precision is
  strictly suboptimal as soon as amplitudes are unequal, which is the formal reason the
  measured group-wise and depth-split arms differ.
-/
import Mathlib

namespace Catalog.NumberTheory.QuantMixedPrecision

open Finset

/-- Worst-case damage proxy of a mixed-precision allocation `b` for tensor amplitudes `A`. -/
noncomputable def bitCost {n : ℕ} (A b : Fin n → ℝ) : ℝ := ∑ i, A i * (2:ℝ) ^ (-(b i))

/-- **Water-filling lower bound.**  No allocation of `B` bits can beat
`n · geom-mean(A) · 2 ^ (−B/n)`. -/
theorem bitCost_ge_geometric {n : ℕ} (hn : 0 < n) {A b : Fin n → ℝ} (hA : ∀ i, 0 < A i) :
    (n : ℝ) * ((∏ i, A i) ^ ((1:ℝ)/n) * (2:ℝ) ^ (-(∑ i, b i) / n)) ≤ bitCost A b := by
  have hnR : (0:ℝ) < n := by exact_mod_cast hn
  set z : Fin n → ℝ := fun i => A i * (2:ℝ) ^ (-(b i)) with hz
  have hzpos : ∀ i, 0 < z i := fun i => mul_pos (hA i) (Real.rpow_pos_of_pos (by norm_num) _)
  have hw : ∑ _i : Fin n, (1:ℝ)/n = 1 := by
    rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    field_simp
  have hamgm := Real.geom_mean_le_arith_mean_weighted Finset.univ (fun _ => (1:ℝ)/n) z
    (fun i _ => by positivity) hw (fun i _ => (hzpos i).le)
  have hprodz : ∏ i, z i = (∏ i, A i) * (2:ℝ) ^ (-(∑ i, b i)) := by
    have h1 : (2:ℝ) ^ (-(∑ i, b i)) = ∏ i, (2:ℝ) ^ (-(b i)) := by
      rw [← Real.rpow_sum_of_pos (by norm_num : (0:ℝ) < 2)]
      congr 1
      simp
    rw [hz, Finset.prod_mul_distrib, h1]
  have hgeom : ∏ i, z i ^ ((1:ℝ)/n)
      = (∏ i, A i) ^ ((1:ℝ)/n) * (2:ℝ) ^ (-(∑ i, b i) / n) := by
    rw [Real.finset_prod_rpow _ _ (fun i _ => (hzpos i).le), hprodz,
      Real.mul_rpow (Finset.prod_nonneg fun i _ => (hA i).le)
        (Real.rpow_nonneg (by norm_num) _)]
    congr 1
    rw [← Real.rpow_mul (by norm_num : (0:ℝ) ≤ 2)]
    congr 1
    field_simp
  rw [hgeom] at hamgm
  have hsum : ∑ i, (1:ℝ)/n * z i = bitCost A b / n := by
    rw [bitCost, Finset.sum_div]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [hz]
    field_simp
  rw [hsum] at hamgm
  have hcancel : (n:ℝ) * (bitCost A b / n) = bitCost A b := by field_simp
  have hmul := mul_le_mul_of_nonneg_left hamgm hnR.le
  linarith [hcancel, hmul]

/-- The water-filling allocation: base budget plus log-amplitude excess. -/
noncomputable def waterfill {n : ℕ} (A : Fin n → ℝ) (B : ℝ) : Fin n → ℝ :=
  fun i => B / n + Real.logb 2 (A i) - (∑ j, Real.logb 2 (A j)) / n

/-- The water-filling allocation spends exactly the budget. -/
lemma sum_waterfill {n : ℕ} (hn : 0 < n) (A : Fin n → ℝ) (B : ℝ) :
    ∑ i, waterfill A B i = B := by
  have hnR : (0:ℝ) < n := by exact_mod_cast hn
  unfold waterfill
  rw [Finset.sum_sub_distrib, Finset.sum_add_distrib, Finset.sum_const, Finset.sum_const,
    Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, nsmul_eq_mul]
  field_simp
  ring

/-- **The water-filling allocation attains the bound.** -/
theorem bitCost_waterfilling {n : ℕ} (hn : 0 < n) {A : Fin n → ℝ} (hA : ∀ i, 0 < A i) (B : ℝ) :
    bitCost A (waterfill A B)
      = (n : ℝ) * ((∏ i, A i) ^ ((1:ℝ)/n) * (2:ℝ) ^ (-B / n)) := by
  have hnR : (0:ℝ) < n := by exact_mod_cast hn
  have hterm : ∀ i, A i * (2:ℝ) ^ (-(waterfill A B i))
      = (∏ j, A j) ^ ((1:ℝ)/n) * (2:ℝ) ^ (-B / n) := by
    intro i
    have hsplit : -(waterfill A B i)
        = -B / n - Real.logb 2 (A i) + (∑ j, Real.logb 2 (A j)) / n := by
      rw [waterfill]; ring
    rw [hsplit, Real.rpow_add (by norm_num), Real.rpow_sub (by norm_num)]
    have hAi : (2:ℝ) ^ (Real.logb 2 (A i)) = A i :=
      Real.rpow_logb (by norm_num) (by norm_num) (hA i)
    have hsumlog : (2:ℝ) ^ ((∑ j, Real.logb 2 (A j)) / n) = (∏ j, A j) ^ ((1:ℝ)/n) := by
      have h1 : (2:ℝ) ^ (∑ j, Real.logb 2 (A j)) = ∏ j, A j := by
        rw [Real.rpow_sum_of_pos (by norm_num : (0:ℝ) < 2)]
        exact Finset.prod_congr rfl fun j _ =>
          Real.rpow_logb (by norm_num) (by norm_num) (hA j)
      calc (2:ℝ) ^ ((∑ j, Real.logb 2 (A j)) / n)
          = ((2:ℝ) ^ (∑ j, Real.logb 2 (A j))) ^ ((1:ℝ)/n) := by
            rw [← Real.rpow_mul (by norm_num)]
            congr 1
            field_simp
        _ = (∏ j, A j) ^ ((1:ℝ)/n) := by rw [h1]
    have hAi0 : A i ≠ 0 := (hA i).ne'
    rw [hAi, hsumlog]
    field_simp
  rw [bitCost, Finset.sum_congr rfl fun i _ => hterm i, Finset.sum_const, Finset.card_univ,
    Fintype.card_fin, nsmul_eq_mul]

/-- **Uniform precision is strictly suboptimal when amplitudes differ.**  With two tensors of
amplitudes `1` and `4` and a zero net budget, shifting one bit from the small tensor to the
large one lowers the worst-case damage from `5` to `4`. -/
theorem uniform_not_optimal :
    ∃ A b : Fin 2 → ℝ, (∀ i, 0 < A i) ∧ ∑ i, b i = 0 ∧
      bitCost A b < bitCost A (fun _ => 0) := by
  refine ⟨![1, 4], ![-1, 1], ?_, ?_, ?_⟩
  · intro i
    fin_cases i <;> norm_num
  · simp [Fin.sum_univ_two]
  · have h1 : (2:ℝ) ^ (-(-1 : ℝ)) = 2 := by
      rw [neg_neg, Real.rpow_one]
    have h2 : (2:ℝ) ^ (-(1 : ℝ)) = 1 / 2 := by
      rw [Real.rpow_neg_one]
      norm_num
    have h3 : (2:ℝ) ^ (-(0 : ℝ)) = 1 := by
      rw [neg_zero, Real.rpow_zero]
    simp only [bitCost, Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one,
      h1, h2, h3]
    norm_num

end Catalog.NumberTheory.QuantMixedPrecision