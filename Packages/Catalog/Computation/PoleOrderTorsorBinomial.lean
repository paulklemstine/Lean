import Mathlib
import Shared.PoleOrderObstruction
import Shared.PoleOrderObstructionDeep
import Computation.PoleOrderTorsor
import Computation.PoleOrderTorsorOrbits
import Computation.PoleOrderTorsorRigidity

/-!
# Second-order growth of the orbit invariants

Cycle 2 proved that the *first* surviving invariant of a normalized `q`-series grows linearly
along a corrected-product orbit: if `f` is `k`-deep then `coeffAt k (f^{⋆n}) = n · coeffAt k f`.
The numerical experiments in `ComputationalEvidence.md` suggested that the next relevant level,
`2k`, grows *quadratically*, with the binomial coefficient `binom(n,2)` as the leading term.

This file proves that:

`coeffAt (2k) (f^{⋆n}) = n · coeffAt (2k) f + binom(n,2) · (coeffAt k f)²`
(`PoleOrderTorsor.Norm.coeffAt_two_mul_pow_of_mem_deepSubgroup`).

The proof rests on a second splitting lemma for products of `k`-deep series
(`PoleOrderTorsor.coeff_mul_split_two`): at level `2k` the coefficient of a product picks up the
extra *Newton* term `a_k b_k`, exactly the quadratic correction appearing in
`PoleOrderObstruction.coeff_prod_normalized_subsubleading`.

Specialising to Monstrous Moonshine gives a closed formula for the `q³`-coefficient of every
corrected-product iterate of a McKay–Thompson series
(`PoleOrderTorsor.Norm.coeffAt_four_pow_moonshine`); for the class `1A` series
`J = q⁻¹ + 196884 q + 21493760 q² + 864299970 q³ + ⋯` it reads
`864299970 n + binom(n,2) · 196884²`.
-/

namespace PoleOrderTorsor

open HahnSeries PoleOrderObstruction PowerSeries

/-! ## Splitting a product at twice the depth -/

/-- **Newton splitting at level `2k`.**  For two `k`-deep power series the coefficient of the
product at level `2k` is the sum of the level-`2k` coefficients plus the product of the level-`k`
coefficients. -/
theorem coeff_mul_split_two {a b : PowerSeries ℂ} {k : ℕ} (hk : 0 < k)
    (ha0 : constantCoeff a = 1) (hb0 : constantCoeff b = 1)
    (ha : LowVanish k a) (hb : LowVanish k b) :
    coeff (2 * k) (a * b) = coeff (2 * k) a + coeff (2 * k) b + coeff k a * coeff k b := by
  classical
  set F : ℕ × ℕ → ℂ := fun p => coeff p.1 a * coeff p.2 b with hF
  have hsub : ({(0, 2 * k), (k, k), (2 * k, 0)} : Finset (ℕ × ℕ)) ⊆ Finset.antidiagonal (2 * k) := by
    intro p hp
    simp only [Finset.mem_insert, Finset.mem_singleton] at hp
    rw [Finset.mem_antidiagonal]
    rcases hp with rfl | rfl | rfl <;> omega
  have hzero : ∀ p ∈ Finset.antidiagonal (2 * k),
      p ∉ ({(0, 2 * k), (k, k), (2 * k, 0)} : Finset (ℕ × ℕ)) → F p = 0 := by
    rintro ⟨x, y⟩ hxy hnot
    rw [Finset.mem_antidiagonal] at hxy
    simp only [Finset.mem_insert, Finset.mem_singleton, Prod.mk.injEq, not_or] at hnot
    have hx0 : ¬ (x = 0) := by
      intro h; exact hnot.1 ⟨h, by omega⟩
    have hxk : ¬ (x = k) := by
      intro h; exact hnot.2.1 ⟨h, by omega⟩
    have hx2k : ¬ (x = 2 * k) := by
      intro h; exact hnot.2.2 ⟨h, by omega⟩
    rcases Nat.lt_or_ge x k with hlt | hge
    · rw [hF]
      simp only
      rw [ha x (by omega) hlt, zero_mul]
    · rw [hF]
      simp only
      rw [hb y (by omega) (by omega), mul_zero]
  have hcard : ((0, 2 * k) : ℕ × ℕ) ≠ (k, k) := by
    simp only [ne_eq, Prod.mk.injEq, not_and]
    intro h
    omega
  have hcard2 : ((0, 2 * k) : ℕ × ℕ) ≠ (2 * k, 0) := by
    simp only [ne_eq, Prod.mk.injEq, not_and]
    intro h
    omega
  have hcard3 : ((k, k) : ℕ × ℕ) ≠ (2 * k, 0) := by
    simp only [ne_eq, Prod.mk.injEq, not_and]
    intro h
    omega
  rw [PowerSeries.coeff_mul, ← Finset.sum_subset hsub hzero]
  rw [Finset.sum_insert (by simp [hcard, hcard2]), Finset.sum_insert (by simp [hcard3]),
    Finset.sum_singleton]
  simp only [hF]
  rw [PowerSeries.coeff_zero_eq_constantCoeff_apply, ha0,
    PowerSeries.coeff_zero_eq_constantCoeff_apply, hb0, one_mul, mul_one]
  ring

/-- **Quadratic growth of the level-`2k` invariant.**  For a `k`-deep one-unit the level-`2k`
coefficient of the `n`-th power is `n` times the level-`2k` coefficient plus `binom(n,2)` times the
square of the level-`k` coefficient. -/
theorem coeff_two_mul_pow_of_lowVanish {a : PowerSeries ℂ} {k : ℕ} (hk : 0 < k)
    (ha0 : constantCoeff a = 1) (ha : LowVanish k a) (n : ℕ) :
    coeff (2 * k) (a ^ n) = n * coeff (2 * k) a + (n.choose 2 : ℂ) * (coeff k a) ^ 2 := by
  induction n with
  | zero =>
      rw [pow_zero, PowerSeries.coeff_one, if_neg (by omega)]
      simp
  | succ n ih =>
      obtain ⟨hlow, hconst, hlin⟩ := coeff_pow_of_lowVanish hk ha0 ha n
      rw [pow_succ, coeff_mul_split_two hk hconst ha0 hlow ha, ih, hlin]
      have hchoose : ((n + 1).choose 2 : ℂ) = (n.choose 2 : ℂ) + n := by
        rw [Nat.choose_succ_succ' n 1, Nat.choose_one_right]
        push_cast
        ring
      rw [hchoose]
      push_cast
      ring

namespace Norm

/-- The same law for normalized series under the corrected product. -/
theorem coeffAt_two_mul_pow_of_mem_deepSubgroup {k : ℕ} (hk : 0 < k) {f : Norm}
    (hf : f ∈ deepSubgroup k) (n : ℕ) :
    coeffAt (2 * k) (f ^ n) = n * coeffAt (2 * k) f + (n.choose 2 : ℂ) * (coeffAt k f) ^ 2 := by
  rw [coeffAt_toOneUnit, toOneUnit_pow, OneUnit.val_pow,
    coeff_two_mul_pow_of_lowVanish hk (toOneUnit f).constantCoeff_val hf n,
    coeffAt_toOneUnit, coeffAt_toOneUnit]

/-! ## The Monstrous Moonshine instance -/

@[simp] theorem coeffAt_four_ofTrace (c : ℕ → ℂ) : coeffAt 4 (ofTrace c) = c 3 := by
  rw [coeffAt_eq_coeff]
  show (traceLaurent c).coeff (((4 : ℕ) : ℤ) - 1) = c 3
  have h1 : (HahnSeries.ofPowerSeries ℤ ℂ (PowerSeries.mk c)).coeff ((3 : ℕ) : ℤ) = c 3 := by
    simpa using HahnSeries.ofPowerSeries_apply_coeff (Γ := ℤ) (PowerSeries.mk c) 3
  rw [show (((4 : ℕ) : ℤ) - 1) = ((3 : ℕ) : ℤ) by norm_num, traceLaurent]
  rw [HahnSeries.coeff_add, h1, HahnSeries.coeff_single]
  norm_num

/-- **Closed formula for the `q³`-coefficient of a moonshine iterate.**  For a normalized trace
series with vanishing constant term, the `n`-th corrected-product iterate has
`coeffAt 4 = n · c₃ + binom(n,2) · c₁²`. -/
theorem coeffAt_four_pow_moonshine {c : ℕ → ℂ} (hc : c 0 = 0) (n : ℕ) :
    coeffAt 4 (ofTrace c ^ n) = n * c 3 + (n.choose 2 : ℂ) * (c 1) ^ 2 := by
  have h := coeffAt_two_mul_pow_of_mem_deepSubgroup (k := 2) (by omega)
    (ofTrace_mem_deepSubgroup_two hc) n
  rw [show 2 * 2 = 4 from rfl, coeffAt_four_ofTrace, coeffAt_two_ofTrace] at h
  exact h

/-- The class `1A` series `J = q⁻¹ + 196884 q + 21493760 q² + 864299970 q³ + ⋯`: its `n`-th
corrected-product iterate has `q³`-coefficient `864299970 n + binom(n,2) · 196884²`. -/
theorem coeffAt_four_pow_J (n : ℕ) :
    coeffAt 4 (ofTrace (fun m => if m = 1 then (196884 : ℂ) else
        if m = 2 then 21493760 else if m = 3 then 864299970 else 0) ^ n)
      = 864299970 * n + (n.choose 2 : ℂ) * 196884 ^ 2 := by
  rw [coeffAt_four_pow_moonshine (by norm_num) n]
  norm_num
  ring

/-- The `⋆`-square of `J`: its `q³`-coefficient is `2 · 864299970 + 196884² = 40491909396`. -/
theorem coeffAt_four_sq_J :
    coeffAt 4 (ofTrace (fun m => if m = 1 then (196884 : ℂ) else
        if m = 2 then 21493760 else if m = 3 then 864299970 else 0) ^ 2)
      = 40491909396 := by
  rw [coeffAt_four_pow_J 2]
  norm_num

end Norm

end PoleOrderTorsor