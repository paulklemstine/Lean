import Mathlib
import Shared.PoleOrderObstruction
import Shared.PoleOrderObstructionDeep
import Cryptography.PoleOrderThirdOrder

/-!
# Cycle 8: the fourth-order identity — where the cross terms come back

Under the moonshine normalization `T_g = q⁻¹ + O(q)` the Laurent coefficients of a
product of `m` normalized series obey, degree by degree:

| degree | value | cycle |
|--------|-------|-------|
| `-m`   | `1` | 1 |
| `1-m`  | `0` | 1 |
| `2-m`  | `∑ᵢ aᵢ(1)` | 2 |
| `3-m`  | `∑ᵢ aᵢ(2)` | 6 |
| `4-m`  | `∑ᵢ aᵢ(3) + e₂(a(1))` | **this file** |

Degree `4 - m` is the first place where the factors genuinely interact: the corrected
factors are `q·Tᵢ = 1 + aᵢ(1) q² + ⋯`, so the first cross term is `aᵢ(1)aⱼ(1) q⁴`.  The
second elementary symmetric function `e₂` of the *linear* moonshine coefficients therefore
appears, written division-free as `((∑ aᵢ(1))² - ∑ aᵢ(1)²)/2`.

Main results:

* `PoleOrderFourthOrder.coeff_four_mul` — the degree-4 coefficient of a product of two
  power series.
* `PoleOrderFourthOrder.coeff_four_prod_of_linear_zero` — the quartic coefficient of a
  finite product of power series with constant term `1` and vanishing linear term.
* `PoleOrderFourthOrder.coeff_prod_normalized_fourth` — the Laurent form at degree `4 - m`.
* `PoleOrderFourthOrder.coeff_prod_traceLaurent_194_fourth` — the Monster case, degree
  `-190`.
* `PoleOrderFourthOrder.coeff_one_prod_J_T2A_T3A` — a Lean-verified numerical instance:
  the triple product `T_1A · T_2A · T_3A` has coefficient `1883965635` at degree `1`,
  matching `865605339 + e₂(196884, 4372, 783)`.
-/

namespace PoleOrderFourthOrder

open HahnSeries Finset PoleOrderObstruction PoleOrderThirdOrder

variable {ι : Type*}

/-! ## 1. Power-series level -/

/-- The degree-4 coefficient of a product of two power series. -/
theorem coeff_four_mul (a b : PowerSeries ℂ) :
    PowerSeries.coeff 4 (a * b) =
      PowerSeries.constantCoeff a * PowerSeries.coeff 4 b
        + PowerSeries.coeff 1 a * PowerSeries.coeff 3 b
        + PowerSeries.coeff 2 a * PowerSeries.coeff 2 b
        + PowerSeries.coeff 3 a * PowerSeries.coeff 1 b
        + PowerSeries.coeff 4 a * PowerSeries.constantCoeff b := by
  have hanti : Finset.antidiagonal (4 : ℕ) = {(0, 4), (1, 3), (2, 2), (3, 1), (4, 0)} := rfl
  rw [PowerSeries.coeff_mul, hanti]
  rw [Finset.sum_insert (by decide), Finset.sum_insert (by decide),
    Finset.sum_insert (by decide), Finset.sum_insert (by decide), Finset.sum_singleton]
  simp [PowerSeries.coeff_zero_eq_constantCoeff]
  ring

/-- Auxiliary: with constant term `1` and vanishing linear term the quadratic coefficient
of a product is the sum of the quadratic coefficients. -/
theorem coeff_two_prod_of_linear_zero (s : Finset ι) (g : ι → PowerSeries ℂ)
    (h1 : ∀ i ∈ s, PowerSeries.constantCoeff (g i) = 1)
    (h2 : ∀ i ∈ s, PowerSeries.coeff 1 (g i) = 0) :
    PowerSeries.coeff 2 (∏ i ∈ s, g i) = ∑ i ∈ s, PowerSeries.coeff 2 (g i) := by
  have key := coeff_two_prod_of_constantCoeff_one s g h1
  rw [Finset.sum_congr rfl h2] at key
  have hz : ∑ i ∈ s, (PowerSeries.coeff 1 (g i)) ^ 2 = 0 :=
    Finset.sum_eq_zero (fun i hi => by rw [h2 i hi]; ring)
  rw [hz] at key
  simp only [Finset.sum_const_zero] at key
  apply mul_left_cancel₀ (a := (2 : ℂ)) two_ne_zero
  linear_combination key

/-- **Fourth-order Newton identity.**  For power series with constant term `1` and
vanishing linear term, the quartic coefficient of a finite product is the sum of the
quartic coefficients plus the second elementary symmetric function of the quadratic
coefficients. -/
theorem coeff_four_prod_of_linear_zero (s : Finset ι) (g : ι → PowerSeries ℂ)
    (h1 : ∀ i ∈ s, PowerSeries.constantCoeff (g i) = 1)
    (h2 : ∀ i ∈ s, PowerSeries.coeff 1 (g i) = 0) :
    2 * PowerSeries.coeff 4 (∏ i ∈ s, g i) =
      2 * (∑ i ∈ s, PowerSeries.coeff 4 (g i))
        + (∑ i ∈ s, PowerSeries.coeff 2 (g i)) ^ 2
        - ∑ i ∈ s, (PowerSeries.coeff 2 (g i)) ^ 2 := by
  classical
  induction s using Finset.induction with
  | empty => simp
  | insert a s ha ih =>
      have h1s : ∀ i ∈ s, PowerSeries.constantCoeff (g i) = 1 :=
        fun i hi => h1 i (Finset.mem_insert_of_mem hi)
      have h2s : ∀ i ∈ s, PowerSeries.coeff 1 (g i) = 0 :=
        fun i hi => h2 i (Finset.mem_insert_of_mem hi)
      have hconst : PowerSeries.constantCoeff (∏ i ∈ s, g i) = 1 := by
        rw [map_prod, Finset.prod_congr rfl h1s, Finset.prod_const_one]
      have hlin : PowerSeries.coeff 1 (∏ i ∈ s, g i) = 0 := by
        rw [coeff_one_prod_of_constantCoeff_one s g h1s, Finset.sum_congr rfl h2s]
        simp
      have hquad : PowerSeries.coeff 2 (∏ i ∈ s, g i) = ∑ i ∈ s, PowerSeries.coeff 2 (g i) :=
        coeff_two_prod_of_linear_zero s g h1s h2s
      have hcub : PowerSeries.coeff 3 (∏ i ∈ s, g i) = ∑ i ∈ s, PowerSeries.coeff 3 (g i) :=
        coeff_three_prod_of_linear_zero s g h1s h2s
      have ihs := ih h1s h2s
      rw [Finset.prod_insert ha, coeff_four_mul, hconst, hlin, hquad,
        h1 a (Finset.mem_insert_self a s), h2 a (Finset.mem_insert_self a s),
        Finset.sum_insert ha, Finset.sum_insert ha, Finset.sum_insert ha]
      linear_combination ihs

/-! ## 2. Laurent level -/

/-- **Fourth-order coefficient of a moonshine-type product.**  For a product of `m`
normalized series with vanishing constant terms, the Laurent coefficient at degree
`4 - m` is `∑ᵢ fᵢ.coeff 3` plus the second elementary symmetric function of the
`fᵢ.coeff 1`. -/
theorem coeff_prod_normalized_fourth (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) (h0 : ∀ i ∈ s, (f i).coeff 0 = 0)
    (m : ℤ) (hm : (s.card : ℤ) = m) :
    2 * (∏ i ∈ s, f i).coeff (4 - m) =
      2 * (∑ i ∈ s, (f i).coeff 3)
        + (∑ i ∈ s, (f i).coeff 1) ^ 2
        - ∑ i ∈ s, ((f i).coeff 1) ^ 2 := by
  classical
  subst hm
  have hcoe : (HahnSeries.ofPowerSeries ℤ ℂ (∏ i ∈ s, normalizedPart (f i))).coeff (4 : ℤ)
      = PowerSeries.coeff 4 (∏ i ∈ s, normalizedPart (f i)) := by
    simpa using HahnSeries.ofPowerSeries_apply_coeff
      (Γ := ℤ) (∏ i ∈ s, normalizedPart (f i)) 4
  rw [ofPowerSeries_prod_normalizedPart s f h, qSeries_pow,
    HahnSeries.coeff_single_mul, one_mul] at hcoe
  have hlin : ∀ i ∈ s, PowerSeries.coeff 1 (normalizedPart (f i)) = 0 := by
    intro i hi
    rw [coeff_normalizedPart (h i hi) 1, show (((1 : ℕ) : ℤ) - 1) = (0 : ℤ) by norm_num]
    exact h0 i hi
  rw [hcoe, coeff_four_prod_of_linear_zero s _
    (fun i hi => constantCoeff_normalizedPart (f i) (h i hi)) hlin]
  have e4 : ∑ i ∈ s, PowerSeries.coeff 4 (normalizedPart (f i)) = ∑ i ∈ s, (f i).coeff 3 :=
    Finset.sum_congr rfl (fun i hi => by
      rw [coeff_normalizedPart (h i hi) 4]; norm_num)
  have e2 : ∑ i ∈ s, PowerSeries.coeff 2 (normalizedPart (f i)) = ∑ i ∈ s, (f i).coeff 1 :=
    Finset.sum_congr rfl (fun i hi => by
      rw [coeff_normalizedPart (h i hi) 2]; norm_num)
  have e2sq : ∑ i ∈ s, (PowerSeries.coeff 2 (normalizedPart (f i))) ^ 2
      = ∑ i ∈ s, ((f i).coeff 1) ^ 2 :=
    Finset.sum_congr rfl (fun i hi => by
      rw [coeff_normalizedPart (h i hi) 2]; norm_num)
  rw [e4, e2, e2sq]

/-- The degree-3 coefficient of a trace series. -/
theorem coeff_three_traceLaurent (c : ℕ → ℂ) : (traceLaurent c).coeff (3 : ℤ) = c 3 := by
  have h1 : (HahnSeries.ofPowerSeries ℤ ℂ (PowerSeries.mk c)).coeff (3 : ℤ) = c 3 := by
    have h := HahnSeries.ofPowerSeries_apply_coeff (Γ := ℤ) (PowerSeries.mk c) 3
    simpa using h
  have h2 : ((3 : ℤ)) ≠ (-1 : ℤ) := by omega
  simp [traceLaurent, h1, h2]

/-- Monster case: the identity at degree `-190`. -/
theorem coeff_prod_traceLaurent_194_fourth (c : Fin monsterClassCount → ℕ → ℂ)
    (hc : ∀ i, c i 0 = 0) :
    2 * (∏ i, traceLaurent (c i)).coeff (-190 : ℤ) =
      2 * (∑ i, c i 3) + (∑ i, c i 1) ^ 2 - ∑ i, (c i 1) ^ 2 := by
  have h := coeff_prod_normalized_fourth Finset.univ (fun i => traceLaurent (c i))
    (fun i _ => isNormalized_traceLaurent (c i)) (fun i _ => by simpa using hc i)
    194 (by simp [monsterClassCount])
  rw [show ((4 : ℤ) - (194 : ℤ)) = (-190 : ℤ) by norm_num] at h
  rw [h]
  simp [coeff_three_traceLaurent]

/-! ## 3. Lab notes: a fourth-order McKay–Thompson check

`T_1A = q⁻¹ + 196884 q + 21493760 q² + 864299970 q³ + ⋯`,
`T_2A = q⁻¹ + 4372 q + 96256 q² + 1240002 q³ + ⋯`,
`T_3A = q⁻¹ + 783 q + 8672 q² + 65367 q³ + ⋯`.

Their triple product has coefficient
`864299970 + 1240002 + 65367 + (196884·4372 + 196884·783 + 4372·783) = 1883965635`
at degree `1`. -/

/-- Truncated trace-series data to order `q³`. -/
noncomputable def mkT3 (a b c : ℂ) : ℕ → ℂ :=
  fun n => if n = 1 then a else if n = 2 then b else if n = 3 then c else 0

/-- The three-factor family `T_1A · T_2A · T_3A`, recorded to order `q³`. -/
noncomputable def tri : Fin 3 → ℕ → ℂ :=
  ![mkT3 196884 21493760 864299970, mkT3 4372 96256 1240002, mkT3 783 8672 65367]

@[simp] theorem tri_apply_zero (i : Fin 3) : tri i 0 = 0 := by
  fin_cases i <;> simp [tri, mkT3]

@[simp] theorem tri_zero_one : tri 0 1 = 196884 := by simp [tri, mkT3]

@[simp] theorem tri_one_one : tri 1 1 = 4372 := by simp [tri, mkT3]

@[simp] theorem tri_two_one : tri 2 1 = 783 := by simp [tri, mkT3]

@[simp] theorem tri_zero_three : tri 0 3 = 864299970 := by simp [tri, mkT3]

@[simp] theorem tri_one_three : tri 1 3 = 1240002 := by simp [tri, mkT3]

@[simp] theorem tri_two_three : tri 2 3 = 65367 := by simp [tri, mkT3]

/-- **Fourth-order check.**  The coefficient of `T_1A · T_2A · T_3A` at degree `1` is
`1883965635`. -/
theorem coeff_one_prod_J_T2A_T3A :
    (∏ i, traceLaurent (tri i)).coeff (1 : ℤ) = 1883965635 := by
  have key := coeff_prod_normalized_fourth (Finset.univ : Finset (Fin 3))
    (fun i => traceLaurent (tri i)) (fun i _ => isNormalized_traceLaurent (tri i))
    (fun i _ => by simp) 3 (by simp)
  rw [show ((4 : ℤ) - (3 : ℤ)) = (1 : ℤ) by norm_num] at key
  simp only [Fin.sum_univ_three, coeff_three_traceLaurent, coeff_one_traceLaurent,
    tri_zero_one, tri_one_one, tri_two_one, tri_zero_three, tri_one_three,
    tri_two_three] at key
  apply mul_left_cancel₀ (a := (2 : ℂ)) two_ne_zero
  rw [key]
  norm_num

end PoleOrderFourthOrder