import Mathlib
import Shared.PoleOrderObstruction
import Shared.PoleOrderObstructionDeep
import Cryptography.PoleOrderSplitting

/-!
# Cycle 6: the third-order Newton identity and verified moonshine data

Cycle 1 computed the subleading Laurent coefficient of a product of `m`
normalized series (degree `1 - m`), cycle 2 the sub-subleading one (degree
`2 - m`), and cycle 3 gave the general convolution formula in every degree.
This cycle extracts from that hierarchy the *third* order term in closed form
under the standard moonshine normalization `T_g = q⁻¹ + O(q)` (vanishing constant
term), and checks it against genuine McKay–Thompson data.

Main results:

* `PoleOrderThirdOrder.coeff_three_mul` — the degree-3 coefficient of a product
  of two power series.
* `PoleOrderThirdOrder.coeff_three_prod_of_linear_zero` — for power series with
  constant term `1` and vanishing linear term, the cubic coefficient of a finite
  product is simply the *sum* of the cubic coefficients: all cross terms are
  blocked by the vanishing linear coefficient.
* `PoleOrderThirdOrder.coeff_prod_normalized_third` — consequently, for a product
  of `m` moonshine-normalized series the Laurent coefficient at degree `3 - m` is
  `∑ᵢ fᵢ.coeff 2`, with no correction terms.  Contrast with degree `2 - m`
  (cycle 2), where an elementary symmetric function appears.
* `PoleOrderThirdOrder.coeff_prod_traceLaurent_194_third` — the Monster case:
  the coefficient at degree `-191`.

## Lab notes: verified numerical instance

The McKay–Thompson series `T_{1A} = J`, `T_{2A}`, `T_{3A}` begin

```
J     = q⁻¹ + 196884 q + 21493760 q² + ⋯
T_2A  = q⁻¹ +   4372 q +    96256 q² + ⋯
T_3A  = q⁻¹ +    783 q +     8672 q² + ⋯
```

`PoleOrderThirdOrder.coeff_zero_prod_J_T2A_T3A` verifies in Lean that their
triple product — which has a pole of order `3` — has constant Laurent
coefficient `21493760 + 96256 + 8672 = 21598688`, exactly as the third-order
identity predicts, while
`PoleOrderThirdOrder.coeff_neg_one_prod_J_T2A_T3A` verifies the second-order
prediction `196884 + 4372 + 783 = 202039` at degree `-1`.
-/

namespace PoleOrderThirdOrder

open HahnSeries Finset PoleOrderObstruction

variable {ι : Type*}

/-! ## 1. Degree-3 coefficient of a product -/

/-- The degree-3 coefficient of a product of two power series. -/
theorem coeff_three_mul (a b : PowerSeries ℂ) :
    PowerSeries.coeff 3 (a * b) =
      PowerSeries.constantCoeff a * PowerSeries.coeff 3 b
        + PowerSeries.coeff 1 a * PowerSeries.coeff 2 b
        + PowerSeries.coeff 2 a * PowerSeries.coeff 1 b
        + PowerSeries.coeff 3 a * PowerSeries.constantCoeff b := by
  have hanti : Finset.antidiagonal (3 : ℕ) = {(0, 3), (1, 2), (2, 1), (3, 0)} := rfl
  rw [PowerSeries.coeff_mul, hanti]
  rw [Finset.sum_insert (by decide), Finset.sum_insert (by decide),
    Finset.sum_insert (by decide), Finset.sum_singleton]
  simp [PowerSeries.coeff_zero_eq_constantCoeff]
  ring

/-- **Third-order Newton identity.**  For power series with constant term `1` and
*vanishing linear term* the cubic coefficient of a finite product is the sum of
the cubic coefficients: every cross term needs a linear factor and dies. -/
theorem coeff_three_prod_of_linear_zero (s : Finset ι) (g : ι → PowerSeries ℂ)
    (h1 : ∀ i ∈ s, PowerSeries.constantCoeff (g i) = 1)
    (h2 : ∀ i ∈ s, PowerSeries.coeff 1 (g i) = 0) :
    PowerSeries.coeff 3 (∏ i ∈ s, g i) = ∑ i ∈ s, PowerSeries.coeff 3 (g i) := by
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
      rw [Finset.prod_insert ha, coeff_three_mul, hconst, hlin,
        h1 a (Finset.mem_insert_self a s), h2 a (Finset.mem_insert_self a s),
        ih h1s h2s, Finset.sum_insert ha]
      ring

/-! ## 2. The Laurent-level statement -/

/-- **Third-order coefficient of a moonshine-type product.**  For a product of
`m` normalized series *all of whose constant terms vanish* — the standard
normalization `T_g = q⁻¹ + O(q)` — the Laurent coefficient at degree `3 - m` is
exactly the sum of the degree-2 coefficients of the factors. -/
theorem coeff_prod_normalized_third (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) (h0 : ∀ i ∈ s, (f i).coeff 0 = 0)
    (m : ℤ) (hm : (s.card : ℤ) = m) :
    (∏ i ∈ s, f i).coeff (3 - m) = ∑ i ∈ s, (f i).coeff 2 := by
  classical
  subst hm
  have hcoe : (HahnSeries.ofPowerSeries ℤ ℂ (∏ i ∈ s, normalizedPart (f i))).coeff (3 : ℤ)
      = PowerSeries.coeff 3 (∏ i ∈ s, normalizedPart (f i)) := by
    simpa using HahnSeries.ofPowerSeries_apply_coeff
      (Γ := ℤ) (∏ i ∈ s, normalizedPart (f i)) 3
  rw [ofPowerSeries_prod_normalizedPart s f h, qSeries_pow,
    HahnSeries.coeff_single_mul, one_mul] at hcoe
  rw [hcoe, coeff_three_prod_of_linear_zero s _
    (fun i hi => constantCoeff_normalizedPart (f i) (h i hi))
    (fun i hi => by
      rw [coeff_normalizedPart (h i hi) 1, show (((1 : ℕ) : ℤ) - 1) = (0 : ℤ) by norm_num]
      exact h0 i hi)]
  refine Finset.sum_congr rfl (fun i hi => ?_)
  rw [coeff_normalizedPart (h i hi) 3]
  norm_num

/-- Monster case: the Laurent coefficient at degree `-191` of the `194`-fold
moonshine product is the sum of the `194` degree-2 coefficients. -/
theorem coeff_prod_traceLaurent_194_third (c : Fin monsterClassCount → ℕ → ℂ)
    (hc : ∀ i, c i 0 = 0) :
    (∏ i, traceLaurent (c i)).coeff (-191 : ℤ) = ∑ i, c i 2 := by
  have hcoeff2 : ∀ i : Fin monsterClassCount, (traceLaurent (c i)).coeff (2 : ℤ) = c i 2 := by
    intro i
    have h1 : (HahnSeries.ofPowerSeries ℤ ℂ (PowerSeries.mk (c i))).coeff (2 : ℤ) = c i 2 := by
      have h := HahnSeries.ofPowerSeries_apply_coeff (Γ := ℤ) (PowerSeries.mk (c i)) 2
      simpa using h
    have h2 : ((2 : ℤ)) ≠ (-1 : ℤ) := by omega
    simp [traceLaurent, h1, h2]
  have h := coeff_prod_normalized_third Finset.univ (fun i => traceLaurent (c i))
    (fun i _ => isNormalized_traceLaurent (c i)) (fun i _ => by simpa using hc i)
    194 (by simp [monsterClassCount])
  rw [show ((3 : ℤ) - (194 : ℤ)) = (-191 : ℤ) by norm_num] at h
  rw [h]
  exact Finset.sum_congr rfl (fun i _ => hcoeff2 i)

/-! ## 3. Lab notes: verified McKay–Thompson instances -/

/-- The truncated McKay–Thompson coefficient sequences used below:
`T_{1A} = J`, `T_{2A}`, `T_{3A}`, each recorded to order `q²`. -/
noncomputable def mkT (a b : ℂ) : ℕ → ℂ := fun n => if n = 1 then a else if n = 2 then b else 0

@[simp] theorem mkT_zero (a b : ℂ) : mkT a b 0 = 0 := by simp [mkT]

@[simp] theorem mkT_one (a b : ℂ) : mkT a b 1 = a := by simp [mkT]

@[simp] theorem mkT_two (a b : ℂ) : mkT a b 2 = b := by simp [mkT]

/-- The three-factor family `J · T_{2A} · T_{3A}`. -/
noncomputable def jT2AT3A : Fin 3 → ℕ → ℂ :=
  ![mkT 196884 21493760, mkT 4372 96256, mkT 783 8672]

@[simp] theorem jT2AT3A_apply_zero (i : Fin 3) : jT2AT3A i 0 = 0 := by
  fin_cases i <;> simp [jT2AT3A]

@[simp] theorem jT2AT3A_zero_one : jT2AT3A 0 1 = 196884 := by simp [jT2AT3A]

@[simp] theorem jT2AT3A_one_one : jT2AT3A 1 1 = 4372 := by simp [jT2AT3A]

@[simp] theorem jT2AT3A_two_one : jT2AT3A 2 1 = 783 := by simp [jT2AT3A]

@[simp] theorem jT2AT3A_zero_two : jT2AT3A 0 2 = 21493760 := by simp [jT2AT3A]

@[simp] theorem jT2AT3A_one_two : jT2AT3A 1 2 = 96256 := by simp [jT2AT3A]

@[simp] theorem jT2AT3A_two_two : jT2AT3A 2 2 = 8672 := by simp [jT2AT3A]

/-- **Second-order check.**  The triple product has a pole of order `3`, and its
coefficient at degree `-1` is `196884 + 4372 + 783 = 202039`. -/
theorem coeff_neg_one_prod_J_T2A_T3A :
    (∏ i, traceLaurent (jT2AT3A i)).coeff (-1 : ℤ) = 202039 := by
  have hnorm : ∀ i : Fin 3, IsNormalized (traceLaurent (jT2AT3A i)) :=
    fun i => isNormalized_traceLaurent _
  have key := coeff_prod_normalized_subsubleading (Finset.univ : Finset (Fin 3))
    (fun i => traceLaurent (jT2AT3A i)) (fun i _ => hnorm i)
  simp only [Finset.card_univ, Fintype.card_fin, coeff_zero_traceLaurent,
    coeff_one_traceLaurent, Fin.sum_univ_three] at key
  norm_num at key
  apply mul_left_cancel₀ (a := (2 : ℂ)) two_ne_zero
  rw [key]
  norm_num

/-- **Third-order check.**  The constant Laurent coefficient of the triple
product is `21493760 + 96256 + 8672 = 21598688`. -/
theorem coeff_zero_prod_J_T2A_T3A :
    (∏ i, traceLaurent (jT2AT3A i)).coeff (0 : ℤ) = 21598688 := by
  have hnorm : ∀ i : Fin 3, IsNormalized (traceLaurent (jT2AT3A i)) :=
    fun i => isNormalized_traceLaurent _
  have h0 : ∀ i : Fin 3, (traceLaurent (jT2AT3A i)).coeff 0 = 0 := by
    intro i
    simp
  have key := coeff_prod_normalized_third (Finset.univ : Finset (Fin 3))
    (fun i => traceLaurent (jT2AT3A i)) (fun i _ => hnorm i) (fun i _ => h0 i) 3 (by simp)
  rw [show ((3 : ℤ) - (3 : ℤ)) = (0 : ℤ) by norm_num] at key
  rw [key, Fin.sum_univ_three]
  have hc2 : ∀ i : Fin 3, (traceLaurent (jT2AT3A i)).coeff (2 : ℤ) = jT2AT3A i 2 := by
    intro i
    have h1 : (HahnSeries.ofPowerSeries ℤ ℂ (PowerSeries.mk (jT2AT3A i))).coeff (2 : ℤ)
        = jT2AT3A i 2 := by
      have h := HahnSeries.ofPowerSeries_apply_coeff (Γ := ℤ) (PowerSeries.mk (jT2AT3A i)) 2
      simpa using h
    have h2 : ((2 : ℤ)) ≠ (-1 : ℤ) := by omega
    simp [traceLaurent, h1, h2]
  rw [hc2 0, hc2 1, hc2 2]
  norm_num

end PoleOrderThirdOrder