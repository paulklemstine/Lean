import Physics.StackSquareCoreBasic

/-!
# Stack polyominoes with a square core: the generating function

This file records the formal power series identities behind the counting formula of
`Physics.StackSquareCoreBasic`.

## Main results

* `pbSeries_mul_prod` : `(∑_m p_{≤b}(m) x^m) · ∏_{i=1}^{b} (1 - x^i) = 1`, i.e. Euler's
  product formula for partitions with bounded parts;
* `layerSeries_mul_prod_sq` : the `k`-th layer satisfies
  `(∑_m p_{≤k-1}(m) x^m)² x^{k²} · (∏_{i=1}^{k-1}(1 - x^i))² = x^{k²}`, so that layer is
  `x^{k²} / ∏_{i=1}^{k-1}(1 - x^i)²`;
* `stackSC_coeff` : the coefficients of `∑_{k ≤ N} x^{k²} (∑_m p_{≤k-1}(m) x^m)²` in
  degrees `≤ N` are exactly the numbers `a(n)`.

Together these give the generating function `Σ_n a(n) x^n = Σ_k x^{k²} / ∏_{i=1}^{k-1}(1-x^i)²`.
-/

namespace Physics.StackSquareCore
open Finset PowerSeries

/-- The generating series `∑_m p_{≤b}(m) x^m` of partitions with parts of size `≤ b`. -/
noncomputable def pbSeries (b : ℕ) : PowerSeries ℤ := PowerSeries.mk fun m => (pb b m : ℤ)

@[simp] lemma coeff_pbSeries (b m : ℕ) : PowerSeries.coeff m (pbSeries b) = (pb b m : ℤ) := by
  simp [pbSeries]

lemma pbSeries_step (b : ℕ) :
    pbSeries (b + 1) * (1 - (X : PowerSeries ℤ) ^ (b + 1)) = pbSeries b := by
  ext n
  rw [mul_sub, map_sub, mul_one, PowerSeries.coeff_mul_X_pow']
  by_cases h : b + 1 ≤ n
  · rw [if_pos h]
    simp only [coeff_pbSeries]
    have := pb_rec b n h
    push_cast [this]
    ring
  · rw [if_neg h]
    simp only [coeff_pbSeries]
    have := pb_rec_of_lt b n (by omega)
    simp [this]

theorem pbSeries_mul_prod (b : ℕ) :
    pbSeries b * ∏ i ∈ Finset.Icc 1 b, (1 - (X : PowerSeries ℤ) ^ i) = 1 := by
  induction b with
  | zero =>
    rw [Finset.Icc_eq_empty (by omega), Finset.prod_empty, mul_one]
    ext n
    rw [coeff_pbSeries, PowerSeries.coeff_one]
    by_cases h : n = 0 <;> simp [h]
  | succ b ih =>
    rw [Finset.prod_Icc_succ_top (by omega), ← mul_assoc]
    calc pbSeries (b+1) * (∏ i ∈ Finset.Icc 1 b, (1 - (X : PowerSeries ℤ) ^ i))
          * (1 - (X : PowerSeries ℤ) ^ (b+1))
        = (pbSeries (b+1) * (1 - (X : PowerSeries ℤ) ^ (b+1)))
          * ∏ i ∈ Finset.Icc 1 b, (1 - (X : PowerSeries ℤ) ^ i) := by ring
      _ = pbSeries b * ∏ i ∈ Finset.Icc 1 b, (1 - (X : PowerSeries ℤ) ^ i) := by
          rw [pbSeries_step]
      _ = 1 := ih


lemma coeff_pbSeries_sq (b m : ℕ) :
    PowerSeries.coeff m ((pbSeries b) ^ 2) = (conv b m : ℤ) := by
  rw [sq, PowerSeries.coeff_mul, Finset.Nat.sum_antidiagonal_eq_sum_range_succ_mk, conv]
  push_cast
  exact Finset.sum_congr rfl (fun j _ => by simp)

theorem stackSC_coeff (N n : ℕ) (hn : n ≤ N) :
    PowerSeries.coeff n
        (∑ k ∈ Finset.range (N + 1), (pbSeries (k - 1)) ^ 2 * (X : PowerSeries ℤ) ^ (k * k))
      = (stackSC n : ℤ) := by
  rw [map_sum, stackSC]
  push_cast
  have hterm : ∀ k : ℕ, PowerSeries.coeff n ((pbSeries (k - 1)) ^ 2 * (X : PowerSeries ℤ) ^ (k * k))
      = if k * k ≤ n then (conv (k - 1) (n - k * k) : ℤ) else 0 := by
    intro k
    rw [PowerSeries.coeff_mul_X_pow']
    split_ifs with h
    · exact coeff_pbSeries_sq _ _
    · rfl
  simp only [hterm]
  refine (Finset.sum_subset (by intro x hx; simp only [Finset.mem_range] at *; omega) ?_).symm
  intro x hx hx'
  simp only [Finset.mem_range] at hx hx'
  rw [if_neg (by nlinarith)]

/-- The `k`-th layer of the generating function is `x^{k²} / ∏_{i=1}^{k-1} (1 - x^i)²`. -/
theorem layerSeries_mul_prod_sq (k : ℕ) :
    ((pbSeries (k - 1)) ^ 2 * (X : PowerSeries ℤ) ^ (k * k))
        * (∏ i ∈ Finset.Icc 1 (k - 1), (1 - (X : PowerSeries ℤ) ^ i)) ^ 2
      = (X : PowerSeries ℤ) ^ (k * k) := by
  have h := pbSeries_mul_prod (k - 1)
  calc ((pbSeries (k - 1)) ^ 2 * (X : PowerSeries ℤ) ^ (k * k))
        * (∏ i ∈ Finset.Icc 1 (k - 1), (1 - (X : PowerSeries ℤ) ^ i)) ^ 2
      = (pbSeries (k - 1) * ∏ i ∈ Finset.Icc 1 (k - 1), (1 - (X : PowerSeries ℤ) ^ i)) ^ 2
        * (X : PowerSeries ℤ) ^ (k * k) := by ring
    _ = (X : PowerSeries ℤ) ^ (k * k) := by rw [h, one_pow, one_mul]

end Physics.StackSquareCore