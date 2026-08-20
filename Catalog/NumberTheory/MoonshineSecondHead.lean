import Mathlib
import NumberTheory.MoonshineHeadTable
import NumberTheory.MoonshineFiniteReduction

/-!
# The second head coefficient `c_g(2)` of an eta-quotient McKay–Thompson series

Cycle 6 of the thread
`Shared.PoleOrderObstruction` → `Shared.PoleOrderObstructionDeep` →
`NumberTheory.MoonshineHeadTable` → `NumberTheory.MoonshineFiniteReduction`.

`NumberTheory.MoonshineHeadTable` computed the *first* head coefficient of the eta
quotient attached to a frame shape,

`c_g(1) = a₁(a₁+3)/2 + a₂`.

This file pushes the jet calculus one order further and computes the *second*:

`6 · c_g(2) = b₁(b₁+1)(b₁+2) + 6 b₁ b₂ + 6 b₃`,  `b m = ∑_{k ∣ m} a k`,

see `MoonshineSecondHead.six_mul_coeff_three_etaPartial`.  Two structural ingredients
make the computation short:

* `MoonshineSecondHead.jet3_zpow` — the `3`-jet of an integer power of a unit power
  series, the order-`3` analogue of `MoonshineHeadTable.jet_zpow`;
* the observation that *every factor except the first* of
  `∏_m (1 - q^m)^(-b m)` is `≡ 1 mod q²`, so the stable-range additivity theorem
  `MoonshineFiniteReduction.coeff_prod_of_isOneMod` applies to the tail and only the
  single factor `(1 - q)^(-b₁)` needs the full jet calculus.

The resulting *derived* second column of the head table is
`-2048, -76, 0, 10, 8, 5, 2, 0`, with sum `-2099`
(`MoonshineSecondHead.etaSecondHeadTable_values`,
`MoonshineSecondHead.sum_etaSecondHeadTable`), and it feeds into the Laurent product
through `MoonshineFiniteReduction.coeff_prod_mtSeries_head_two`:
the eight-fold product has coefficient `-2099` in degree `-5`
(`MoonshineSecondHead.coeff_prod_etaClasses_second`).
-/

namespace MoonshineSecondHead

open PowerSeries Finset MoonshineHeadTable MoonshineFiniteReduction

/-! ## 1. The `3`-jet of an integer power -/

section Jets

variable {R : Type*} [CommRing R]

/-- The cubic coefficient of a product of two power series. -/
theorem coeff_three_mul (a b : R⟦X⟧) :
    coeff 3 (a * b) =
      constantCoeff a * coeff 3 b + coeff 1 a * coeff 2 b
        + coeff 2 a * coeff 1 b + coeff 3 a * constantCoeff b := by
  have hanti : Finset.antidiagonal (3 : ℕ) = {(0, 3), (1, 2), (2, 1), (3, 0)} := rfl
  rw [PowerSeries.coeff_mul, hanti]
  rw [Finset.sum_insert (by decide), Finset.sum_insert (by decide),
    Finset.sum_insert (by decide), Finset.sum_singleton]
  simp only [coeff_zero_eq_constantCoeff]
  ring

/-- **The `3`-jet of `u ^ z`.**  For a unit power series `u = 1 + c₁ q + c₂ q² + c₃ q³ + ⋯`
and any integer exponent `z`, the cubic coefficient of `u ^ z` is
`z c₃ + z(z-1) c₁ c₂ + C(z,3) c₁³`, written multiplied by `6` to stay in the ring. -/
theorem jet3_zpow (u : (R⟦X⟧)ˣ) (hu : constantCoeff (u : R⟦X⟧) = 1) (z : ℤ) :
    6 * coeff 3 (((u ^ z : (R⟦X⟧)ˣ)) : R⟦X⟧) =
      6 * (z : R) * coeff 3 (u : R⟦X⟧)
        + 6 * (z : R) * ((z : R) - 1) * coeff 1 (u : R⟦X⟧) * coeff 2 (u : R⟦X⟧)
        + (z : R) * ((z : R) - 1) * ((z : R) - 2) * (coeff 1 (u : R⟦X⟧)) ^ 3 := by
  have hinv : constantCoeff ((u⁻¹ : (R⟦X⟧)ˣ) : R⟦X⟧) = 1 := constantCoeff_inv_units u hu
  have hmul : (u : R⟦X⟧) * ((u⁻¹ : (R⟦X⟧)ˣ) : R⟦X⟧) = 1 := by
    rw [← Units.val_mul, mul_inv_cancel, Units.val_one]
  have hi1 : coeff 1 ((u⁻¹ : (R⟦X⟧)ˣ) : R⟦X⟧) = - coeff 1 (u : R⟦X⟧) := by
    have h := congrArg (coeff (R := R) 1) hmul
    rw [PowerSeries.coeff_one_mul, hu, hinv] at h
    simp only [mul_one, PowerSeries.coeff_one] at h
    norm_num at h
    linear_combination h
  have hi2 : coeff 2 ((u⁻¹ : (R⟦X⟧)ˣ) : R⟦X⟧)
      = - coeff 2 (u : R⟦X⟧) + (coeff 1 (u : R⟦X⟧)) ^ 2 := by
    have h := congrArg (coeff (R := R) 2) hmul
    rw [MoonshineHeadTable.coeff_two_mul, hu, hinv, hi1] at h
    simp only [mul_one, one_mul, PowerSeries.coeff_one] at h
    norm_num at h
    linear_combination h
  have hi3 : coeff 3 ((u⁻¹ : (R⟦X⟧)ˣ) : R⟦X⟧)
      = - coeff 3 (u : R⟦X⟧) + 2 * coeff 1 (u : R⟦X⟧) * coeff 2 (u : R⟦X⟧)
        - (coeff 1 (u : R⟦X⟧)) ^ 3 := by
    have h := congrArg (coeff (R := R) 3) hmul
    rw [coeff_three_mul, hu, hinv, hi1, hi2] at h
    simp only [mul_one, one_mul, PowerSeries.coeff_one] at h
    norm_num at h
    linear_combination h
  induction z using Int.induction_on with
  | zero => simp
  | succ n ih =>
      have hjet := MoonshineHeadTable.jet_zpow u hu (n : ℤ)
      obtain ⟨h0, h1, h2⟩ := hjet
      have hpow : ((u ^ ((n : ℤ) + 1) : (R⟦X⟧)ˣ) : R⟦X⟧)
          = ((u ^ (n : ℤ) : (R⟦X⟧)ˣ) : R⟦X⟧) * (u : R⟦X⟧) := by
        rw [zpow_add_one, Units.val_mul]
      rw [hpow, coeff_three_mul, h0, h1, hu]
      push_cast at ih h2 ⊢
      linear_combination ih + 3 * coeff 1 (u : R⟦X⟧) * h2
  | pred n ih =>
      have hjet := MoonshineHeadTable.jet_zpow u hu (-(n : ℤ))
      obtain ⟨h0, h1, h2⟩ := hjet
      have hpow : ((u ^ (-(n : ℤ) - 1) : (R⟦X⟧)ˣ) : R⟦X⟧)
          = ((u ^ (-(n : ℤ)) : (R⟦X⟧)ˣ) : R⟦X⟧) * ((u⁻¹ : (R⟦X⟧)ˣ) : R⟦X⟧) := by
        rw [sub_eq_add_neg, zpow_add, zpow_neg_one, Units.val_mul]
      rw [hpow, coeff_three_mul, h0, h1, hinv, hi1, hi2, hi3]
      push_cast at ih h2 ⊢
      linear_combination ih - 3 * coeff 1 (u : R⟦X⟧) * h2

end Jets

/-! ## 2. Cubic coefficients of the eta factors -/

theorem coeff_three_oneSubXPowUnit (m : ℕ) :
    coeff 3 ((oneSubXPowUnit ℤ m : (ℤ⟦X⟧)ˣ) : ℤ⟦X⟧) = if m = 2 then -1 else 0 := by
  rw [val_oneSubXPowUnit]
  by_cases hm : m = 2
  · subst hm; norm_num
  · rw [if_neg hm]
    simp only [map_sub, PowerSeries.coeff_one, PowerSeries.coeff_X_pow]
    rw [if_neg (by omega : ¬(3 : ℕ) = 0), if_neg (by omega : ¬(3 : ℕ) = m + 1)]
    ring

theorem divSum_three (a : ℕ → ℤ) : divSum a 3 = a 1 + a 3 := by
  have h : (3 : ℕ).divisors = {1, 3} := by decide
  simp [divSum, h]

/-- Cubic coefficient of the `m`-th eta factor: only `m = 0` and `m = 2` contribute. -/
theorem six_mul_coeff_three_etaFactor (a : ℕ → ℤ) (m : ℕ) :
    6 * coeff 3 (etaFactor (R := ℤ) a m) =
      (if m = 0 then divSum a 1 * (divSum a 1 + 1) * (divSum a 1 + 2) else 0)
        + (if m = 2 then 6 * divSum a 3 else 0) := by
  have h := jet3_zpow (oneSubXPowUnit ℤ m) (constantCoeff_oneSubXPowUnit m)
    (-(divSum a (m + 1)))
  rw [etaFactor, h, coeff_one_oneSubXPowUnit, coeff_two_oneSubXPowUnit,
    coeff_three_oneSubXPowUnit]
  rcases Nat.eq_zero_or_pos m with rfl | hm
  · simp only [if_neg (by omega : ¬(0 : ℕ) = 1), if_neg (by omega : ¬(0 : ℕ) = 2)]
    push_cast
    ring
  · rcases eq_or_ne m 2 with rfl | hm2
    · simp only [if_neg (by omega : ¬(2 : ℕ) = 0), if_neg (by omega : ¬(2 : ℕ) = 1)]
      push_cast
      ring
    · have hm0 : ¬ m = 0 := by omega
      simp only [if_neg hm0, if_neg hm2]
      rcases eq_or_ne m 1 with rfl | hm1
      · ring
      · simp only [if_neg hm1]
        ring

/-- Quadratic coefficient of the `m`-th eta factor for `m ≥ 1`: only `m = 1`
contributes, with value `b₂`. -/
theorem coeff_two_etaFactor_tail (a : ℕ → ℤ) {m : ℕ} (hm : 1 ≤ m) :
    coeff 2 (etaFactor (R := ℤ) a m) = if m = 1 then divSum a 2 else 0 := by
  have h := two_mul_coeff_two_etaFactor (R := ℤ) a m
  rw [if_neg (by omega : ¬m = 0)] at h
  rcases eq_or_ne m 1 with rfl | hm1
  · rw [if_pos rfl] at h ⊢
    push_cast at h
    linarith
  · rw [if_neg hm1] at h ⊢
    push_cast at h
    linarith

/-- Cubic coefficient of the `m`-th eta factor for `m ≥ 1`: only `m = 2`
contributes, with value `b₃`. -/
theorem coeff_three_etaFactor_tail (a : ℕ → ℤ) {m : ℕ} (hm : 1 ≤ m) :
    coeff 3 (etaFactor (R := ℤ) a m) = if m = 2 then divSum a 3 else 0 := by
  have h := six_mul_coeff_three_etaFactor a m
  rw [if_neg (by omega : ¬m = 0)] at h
  rcases eq_or_ne m 2 with rfl | hm2
  · rw [if_pos rfl] at h ⊢
    linarith
  · rw [if_neg hm2] at h ⊢
    linarith

/-! ## 3. The cubic coefficient of the truncated eta quotient -/

theorem isOneMod_two_etaFactor (a : ℕ → ℤ) {m : ℕ} (hm : 1 ≤ m) :
    IsOneMod 2 (etaFactor (R := ℤ) a m) := by
  refine ⟨constantCoeff_etaFactor a m, ?_⟩
  intro j hj hj2
  rw [show j = 1 by omega, coeff_one_etaFactor, if_neg (by omega)]

/-- **Main computation.**  For every truncation `M ≥ 3` the cubic coefficient of
`∏_{m = 1}^{M} (1 - q^m)^(-b m)` equals `(b₁(b₁+1)(b₁+2) + 6 b₁ b₂ + 6 b₃) / 6`,
written without division.  In particular it is independent of `M`. -/
theorem six_mul_coeff_three_etaPartial (a : ℕ → ℤ) {M : ℕ} (hM : 3 ≤ M) :
    6 * coeff 3 ((etaPartial ℤ a M : (ℤ⟦X⟧)ˣ) : ℤ⟦X⟧) =
      divSum a 1 * (divSum a 1 + 1) * (divSum a 1 + 2)
        + 6 * divSum a 1 * divSum a 2 + 6 * divSum a 3 := by
  classical
  have hmem : (0 : ℕ) ∈ Finset.range M := Finset.mem_range.mpr (by omega)
  have hsplit : ∏ m ∈ Finset.range M, etaFactor (R := ℤ) a m
      = etaFactor (R := ℤ) a 0 * ∏ m ∈ (Finset.range M).erase 0, etaFactor (R := ℤ) a m :=
    (Finset.mul_prod_erase _ _ hmem).symm
  have htail : ∀ m ∈ (Finset.range M).erase 0, IsOneMod 2 (etaFactor (R := ℤ) a m) := by
    intro m hm
    exact isOneMod_two_etaFactor a (by
      have := Finset.ne_of_mem_erase hm
      omega)
  -- the tail is `≡ 1 mod q²`, so its low coefficients are plain sums
  have hP0 : constantCoeff (∏ m ∈ (Finset.range M).erase 0, etaFactor (R := ℤ) a m) = 1 :=
    (isOneMod_prod _ _ htail).const
  have hP1 : coeff 1 (∏ m ∈ (Finset.range M).erase 0, etaFactor (R := ℤ) a m) = 0 :=
    (isOneMod_prod _ _ htail).vanish 1 (by omega) (by omega)
  have hmem1 : (1 : ℕ) ∈ (Finset.range M).erase 0 :=
    Finset.mem_erase.mpr ⟨by omega, Finset.mem_range.mpr (by omega)⟩
  have hmem2 : (2 : ℕ) ∈ (Finset.range M).erase 0 :=
    Finset.mem_erase.mpr ⟨by omega, Finset.mem_range.mpr (by omega)⟩
  have hP2 : coeff 2 (∏ m ∈ (Finset.range M).erase 0, etaFactor (R := ℤ) a m)
      = divSum a 2 := by
    rw [coeff_prod_of_isOneMod (d := 2) _ _ htail (by omega) (by omega)]
    rw [Finset.sum_congr rfl (fun m hm => coeff_two_etaFactor_tail a
      (by have := Finset.ne_of_mem_erase hm; omega))]
    rw [Finset.sum_ite_eq' ((Finset.range M).erase 0) 1 (fun _ => divSum a 2), if_pos hmem1]
  have hP3 : coeff 3 (∏ m ∈ (Finset.range M).erase 0, etaFactor (R := ℤ) a m)
      = divSum a 3 := by
    rw [coeff_prod_of_isOneMod (d := 2) _ _ htail (by omega) (by omega)]
    rw [Finset.sum_congr rfl (fun m hm => coeff_three_etaFactor_tail a
      (by have := Finset.ne_of_mem_erase hm; omega))]
    rw [Finset.sum_ite_eq' ((Finset.range M).erase 0) 2 (fun _ => divSum a 3), if_pos hmem2]
  -- the head factor `(1 - q)^(-b₁)`
  have hf1 : coeff 1 (etaFactor (R := ℤ) a 0) = divSum a 1 := by
    rw [coeff_one_etaFactor, if_pos rfl, Int.cast_id]
  have hf2 : 2 * coeff 2 (etaFactor (R := ℤ) a 0) = divSum a 1 * (divSum a 1 + 1) := by
    have h := two_mul_coeff_two_etaFactor (R := ℤ) a 0
    rw [if_pos rfl, if_neg (by omega : ¬(0 : ℕ) = 1)] at h
    push_cast at h
    linarith
  have hf3 : 6 * coeff 3 (etaFactor (R := ℤ) a 0)
      = divSum a 1 * (divSum a 1 + 1) * (divSum a 1 + 2) := by
    have h := six_mul_coeff_three_etaFactor a 0
    rw [if_pos rfl, if_neg (by omega : ¬(0 : ℕ) = 2)] at h
    linarith
  rw [val_etaPartial, hsplit, coeff_three_mul, constantCoeff_etaFactor, hP0, hP1, hP2, hP3, hf1]
  linarith [hf2, hf3]

/-! ## 4. The derived second column of the head table -/

theorem six_dvd_mul_succ_mul_succ_succ (n : ℤ) : (6 : ℤ) ∣ n * (n + 1) * (n + 2) := by
  have h : ∀ m : ZMod 6, m * (m + 1) * (m + 2) = 0 := by decide
  have := (ZMod.intCast_zmod_eq_zero_iff_dvd (n * (n + 1) * (n + 2)) 6).mp (by
    push_cast
    exact h (n : ZMod 6))
  exact this

/-- The second head coefficient `c_g(2)` predicted by a frame shape. -/
def secondHeadCoeff (a : ℕ → ℤ) : ℤ :=
  (divSum a 1 * (divSum a 1 + 1) * (divSum a 1 + 2) + 6 * divSum a 1 * divSum a 2
    + 6 * divSum a 3) / 6

theorem six_mul_secondHeadCoeff (a : ℕ → ℤ) :
    6 * secondHeadCoeff a =
      divSum a 1 * (divSum a 1 + 1) * (divSum a 1 + 2)
        + 6 * divSum a 1 * divSum a 2 + 6 * divSum a 3 := by
  obtain ⟨k, hk⟩ := six_dvd_mul_succ_mul_succ_succ (divSum a 1)
  rw [secondHeadCoeff, hk,
    show 6 * k + 6 * divSum a 1 * divSum a 2 + 6 * divSum a 3
      = 6 * (k + divSum a 1 * divSum a 2 + divSum a 3) by ring,
    Int.mul_ediv_cancel_left _ (by norm_num)]

/-- **Closed formula for the second head coefficient.** -/
theorem coeff_three_etaPartial (a : ℕ → ℤ) {M : ℕ} (hM : 3 ≤ M) :
    coeff 3 ((etaPartial ℤ a M : (ℤ⟦X⟧)ˣ) : ℤ⟦X⟧) = secondHeadCoeff a := by
  have h := six_mul_coeff_three_etaPartial a hM
  have h6 := six_mul_secondHeadCoeff a
  linarith

/-- The derived second column of the head table. -/
def etaSecondHeadTable : Fin 8 → ℤ :=
  fun i => secondHeadCoeff (pmFrame (pmData i).1 (pmData i).2)

/-- **The derived second column.**  Its eight entries are
`-2048, -76, 0, 10, 8, 5, 2, 0`. -/
theorem etaSecondHeadTable_values :
    etaSecondHeadTable = ![-2048, -76, 0, 10, 8, 5, 2, 0] := by
  funext i
  fin_cases i <;>
    (simp only [etaSecondHeadTable, pmData, secondHeadCoeff, divSum, pmFrame]; decide)

theorem sum_etaSecondHeadTable : ∑ i, etaSecondHeadTable i = -2099 := by
  rw [etaSecondHeadTable_values]
  decide

/-- **Worked instance, one degree deeper.**  For any eight normalized McKay–Thompson
series whose second head coefficients are the frame-shape-derived values, the
eight-fold product has Laurent coefficient `-2099` in degree `-5`. -/
theorem coeff_prod_etaClasses_second (c : Fin 8 → ℕ → ℤ) (h0 : ∀ i, c i 0 = 0)
    (h2 : ∀ i, c i 2 = etaSecondHeadTable i) :
    (∏ i, mtSeries (c i)).coeff (-5 : ℤ) = (-2099 : ℂ) := by
  have h := coeff_prod_mtSeries_head_two 8 c h0
  norm_num at h
  have hsum : ∑ i, ((c i 2 : ℤ) : ℂ) = ((∑ i, c i 2 : ℤ) : ℂ) := by push_cast; ring
  rw [h, hsum, Finset.sum_congr rfl (fun i _ => h2 i), sum_etaSecondHeadTable]
  norm_num

end MoonshineSecondHead