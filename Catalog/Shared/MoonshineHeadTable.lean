import Mathlib
import Shared.PoleOrderObstruction
import Shared.PoleOrderObstructionDeep
import Shared.MoonshineJExpansion

/-!
# The Monstrous-Moonshine head table as a finite arithmetic check

`Shared.PoleOrderObstruction` and `Shared.PoleOrderObstructionDeep` proved the
*reduction*: the `194`-fold product of McKay–Thompson-shaped series
`T_g = q⁻¹ + 0 + c_g(1) q + ⋯` has a pole of order exactly `194`, and its Laurent
coefficients just above the pole are elementary symmetric expressions in the
head data `c_g(0), c_g(1), c_g(2), …`.

This file completes the reduction into a genuinely **finite, decidable
arithmetic statement** about the head table, and pushes the symmetric-function
hierarchy one level deeper:

* `MoonshineHeadTable.coeff_three_prod_of_constantCoeff_one` — the level-`3`
  Newton identity for a finite product of power series with constant term `1`,
  featuring the third power sum, the mixed term `p₁p₂` and the cross term
  `∑ c₁ᵢc₂ᵢ`;
* `MoonshineHeadTable.coeff_prod_normalized_third` — the Laurent coefficient in
  degree `3 - m` of a product of `m` normalized series;
* `MoonshineHeadTable.coeff_prod_traceLaurent_194_third` — for honest
  McKay–Thompson normalization (`c_g(0) = 0`) the coefficient in degree `-191`
  of the Monster-sized product is exactly `∑_g c_g(2)`;
* `MoonshineHeadTable.head_check_iff` — **the reduction to arithmetic**: for an
  integral head table `t : Fin 194 → ℤ`, the transcendental-looking statement
  "the Laurent coefficient in degree `-192` of the `194`-fold product equals
  `S`" is *equivalent* to the decidable integer equation `∑ i, t i = S`;
* `MoonshineHeadTable.head_check_decide` — a worked instance discharged by
  `decide`, using the `1A` entry `196884` that was *computed and verified* in
  `Shared.MoonshineJExpansion` (rather than imported as data);
* `MoonshineHeadTable.head_sum_bound` — the a priori bound on the finite check
  coming from `|c_g(1) - 1| = |χ_{196883}(g)| ≤ 196883`.

The point of the last three items is methodological: after the reduction, a
moonshine head-coefficient conjecture is a statement about `194` integers, so it
is decidable — the only remaining ingredient is the table itself, entry by
entry, each of which must be *verified* rather than assumed.  The `1A` entry is
verified here; `Shared.MoonshineJExpansion` shows what such a verification
costs.
-/

namespace MoonshineHeadTable

open Finset PowerSeries PoleOrderObstruction

variable {ι : Type*}

/-! ## 1. The level-3 Newton identity -/

/-- Cubic coefficient of a product of two power series. -/
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

/-- **Newton identity at level 3.**  For power series with constant term `1`, the
cubic coefficient of a finite product is the sum of the cubic coefficients, plus
the "mixed" second elementary symmetric expression in the pairs
`(c₁ᵢ, c₂ᵢ)`, plus the third elementary symmetric function of the linear
coefficients, written without division as
`e₃ = (p₁³ - 3p₁p₂ + 2p₃)/6`. -/
theorem coeff_three_prod_of_constantCoeff_one (s : Finset ι) (g : ι → PowerSeries ℂ)
    (h : ∀ i ∈ s, PowerSeries.constantCoeff (g i) = 1) :
    6 * PowerSeries.coeff 3 (∏ i ∈ s, g i) =
      6 * (∑ i ∈ s, PowerSeries.coeff 3 (g i))
        + 6 * ((∑ i ∈ s, PowerSeries.coeff 1 (g i)) * (∑ i ∈ s, PowerSeries.coeff 2 (g i))
              - ∑ i ∈ s, PowerSeries.coeff 1 (g i) * PowerSeries.coeff 2 (g i))
        + ((∑ i ∈ s, PowerSeries.coeff 1 (g i)) ^ 3
            - 3 * (∑ i ∈ s, PowerSeries.coeff 1 (g i))
                * (∑ i ∈ s, (PowerSeries.coeff 1 (g i)) ^ 2)
            + 2 * ∑ i ∈ s, (PowerSeries.coeff 1 (g i)) ^ 3) := by
  classical
  induction s using Finset.induction with
  | empty => simp
  | insert a s ha ih =>
      have hsub : ∀ i ∈ s, PowerSeries.constantCoeff (g i) = 1 :=
        fun i hi => h i (Finset.mem_insert_of_mem hi)
      have hconst : PowerSeries.constantCoeff (∏ i ∈ s, g i) = 1 := by
        rw [map_prod, Finset.prod_congr rfl hsub, Finset.prod_const_one]
      have hlin : PowerSeries.coeff 1 (∏ i ∈ s, g i)
          = ∑ i ∈ s, PowerSeries.coeff 1 (g i) :=
        coeff_one_prod_of_constantCoeff_one s g hsub
      have hquad := coeff_two_prod_of_constantCoeff_one s g hsub
      have ih3 := ih hsub
      rw [Finset.prod_insert ha, coeff_three_mul, hconst,
        h a (Finset.mem_insert_self a s), hlin]
      simp only [Finset.sum_insert ha]
      linear_combination ih3 + 3 * (PowerSeries.coeff 1 (g a)) * hquad

/-! ## 2. The Laurent coefficient in degree `3 - m` -/

/-- **Third Laurent coefficient of a product of normalized series.**  For a
product of `m` normalized `q`-series the coefficient in degree `3 - m` is a
Newton-type expression in the head data `a₀(fᵢ) = fᵢ.coeff 0`,
`a₁(fᵢ) = fᵢ.coeff 1`, `a₂(fᵢ) = fᵢ.coeff 2`. -/
theorem coeff_prod_normalized_third (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) :
    6 * (∏ i ∈ s, f i).coeff (3 - (s.card : ℤ)) =
      6 * (∑ i ∈ s, (f i).coeff 2)
        + 6 * ((∑ i ∈ s, (f i).coeff 0) * (∑ i ∈ s, (f i).coeff 1)
              - ∑ i ∈ s, (f i).coeff 0 * (f i).coeff 1)
        + ((∑ i ∈ s, (f i).coeff 0) ^ 3
            - 3 * (∑ i ∈ s, (f i).coeff 0) * (∑ i ∈ s, ((f i).coeff 0) ^ 2)
            + 2 * ∑ i ∈ s, ((f i).coeff 0) ^ 3) := by
  classical
  have hcoe : (HahnSeries.ofPowerSeries ℤ ℂ (∏ i ∈ s, normalizedPart (f i))).coeff (3 : ℤ)
      = PowerSeries.coeff 3 (∏ i ∈ s, normalizedPart (f i)) := by
    simpa using HahnSeries.ofPowerSeries_apply_coeff
      (Γ := ℤ) (∏ i ∈ s, normalizedPart (f i)) 3
  rw [ofPowerSeries_prod_normalizedPart s f h, qSeries_pow,
    HahnSeries.coeff_single_mul, one_mul] at hcoe
  rw [hcoe, coeff_three_prod_of_constantCoeff_one s _
    (fun i hi => constantCoeff_normalizedPart (f i) (h i hi))]
  have h1 : ∀ i ∈ s, PowerSeries.coeff 1 (normalizedPart (f i)) = (f i).coeff 0 := by
    intro i hi; rw [coeff_normalizedPart (h i hi) 1]; norm_num
  have h2 : ∀ i ∈ s, PowerSeries.coeff 2 (normalizedPart (f i)) = (f i).coeff 1 := by
    intro i hi; rw [coeff_normalizedPart (h i hi) 2]; norm_num
  have h3 : ∀ i ∈ s, PowerSeries.coeff 3 (normalizedPart (f i)) = (f i).coeff 2 := by
    intro i hi; rw [coeff_normalizedPart (h i hi) 3]; norm_num
  rw [Finset.sum_congr rfl h3, Finset.sum_congr rfl h1, Finset.sum_congr rfl h2,
    Finset.sum_congr rfl (fun i hi => by rw [h1 i hi, h2 i hi] :
      ∀ i ∈ s, PowerSeries.coeff 1 (normalizedPart (f i))
        * PowerSeries.coeff 2 (normalizedPart (f i)) = (f i).coeff 0 * (f i).coeff 1),
    Finset.sum_congr rfl (fun i hi => by rw [h1 i hi] :
      ∀ i ∈ s, PowerSeries.coeff 1 (normalizedPart (f i)) ^ 2 = ((f i).coeff 0) ^ 2),
    Finset.sum_congr rfl (fun i hi => by rw [h1 i hi] :
      ∀ i ∈ s, PowerSeries.coeff 1 (normalizedPart (f i)) ^ 3 = ((f i).coeff 0) ^ 3)]

/-- **Third Laurent coefficient of the Monster-sized product.**  With honest
McKay–Thompson normalization `c_g(0) = 0`, the coefficient in degree `-191` of
the `194`-fold product is exactly `∑_g c_g(2)`. -/
theorem coeff_prod_traceLaurent_194_third (c : Fin monsterClassCount → ℕ → ℂ)
    (hc : ∀ i, c i 0 = 0) :
    (∏ i, traceLaurent (c i)).coeff (-191 : ℤ) = ∑ i, c i 2 := by
  have key := coeff_prod_normalized_third Finset.univ (fun i => traceLaurent (c i))
    (fun i _ => isNormalized_traceLaurent (c i))
  have hcard : (Finset.univ : Finset (Fin monsterClassCount)).card = 194 := by
    simp [monsterClassCount]
  rw [hcard] at key
  simp only [coeff_zero_traceLaurent, hc] at key
  norm_num at key
  have hcoeff2 : ∀ i, (traceLaurent (c i)).coeff (2 : ℤ) = c i 2 := by
    intro i
    have h1 : (HahnSeries.ofPowerSeries ℤ ℂ (PowerSeries.mk (c i))).coeff (2 : ℤ) = c i 2 := by
      simpa using HahnSeries.ofPowerSeries_apply_coeff (Γ := ℤ) (PowerSeries.mk (c i)) 2
    simp [traceLaurent, h1]
  simp only [hcoeff2] at key
  exact key

/-! ## 3. The head table and the finite arithmetic check -/

/-- The McKay–Thompson-shaped series attached to a single head value `t`:
`q⁻¹ + t·q`.  Its constant term vanishes, as moonshine normalization demands. -/
noncomputable def headSeries (t : ℤ) : ℕ → ℂ := fun n => if n = 1 then (t : ℂ) else 0

@[simp] theorem headSeries_zero (t : ℤ) : headSeries t 0 = 0 := by simp [headSeries]

@[simp] theorem headSeries_one (t : ℤ) : headSeries t 1 = (t : ℂ) := by simp [headSeries]

/-- The Monster-sized product built from an integral head table. -/
noncomputable def headProduct (t : Fin monsterClassCount → ℤ) : LC :=
  ∏ i, traceLaurent (headSeries (t i))

theorem headProduct_def (t : Fin monsterClassCount → ℤ) :
    headProduct t = ∏ i, traceLaurent (headSeries (t i)) := rfl

/-- **The reduction, in coefficient form.**  The Laurent coefficient in degree
`-192` of the `194`-fold product built from an integral head table is the
integer `∑_g c_g(1)`, viewed in `ℂ`. -/
theorem coeff_headProduct (t : Fin monsterClassCount → ℤ) :
    (headProduct t).coeff (-192 : ℤ) = ((∑ i, t i : ℤ) : ℂ) := by
  rw [headProduct,
    coeff_prod_traceLaurent_194_subsubleading_of_normalized _ (fun i => headSeries_zero (t i))]
  push_cast
  exact Finset.sum_congr rfl (fun i _ => headSeries_one (t i))

/-- **The moonshine head conjecture is a finite arithmetic statement.**  For an
integral head table, the Laurent-series assertion is *equivalent* to a decidable
equation between two integers. -/
theorem head_check_iff (t : Fin monsterClassCount → ℤ) (S : ℤ) :
    (headProduct t).coeff (-192 : ℤ) = (S : ℂ) ↔ ∑ i, t i = S := by
  rw [coeff_headProduct]
  constructor
  · intro h; exact_mod_cast h
  · intro h; rw [h]

/-- The same statement at the next level: with vanishing constant terms the
degree `-191` coefficient of the product built from the *second* head column
`c_g(2)` is again a plain integer sum. -/
theorem head_check_iff_third (t : Fin monsterClassCount → ℤ) (S : ℤ) :
    (∏ i, traceLaurent (fun n => if n = 2 then ((t i : ℤ) : ℂ) else 0)).coeff (-191 : ℤ)
        = (S : ℂ) ↔ ∑ i, t i = S := by
  have h0 : ∀ i : Fin monsterClassCount,
      (fun n => if n = 2 then ((t i : ℤ) : ℂ) else 0) 0 = 0 := by intro i; norm_num
  rw [coeff_prod_traceLaurent_194_third _ h0]
  have hval : ∀ i : Fin monsterClassCount,
      (fun n => if n = 2 then ((t i : ℤ) : ℂ) else 0) 2 = ((t i : ℤ) : ℂ) := by
    intro i; norm_num
  rw [Finset.sum_congr rfl (fun i _ => hval i)]
  have hcast : ∑ i, ((t i : ℤ) : ℂ) = ((∑ i, t i : ℤ) : ℂ) := by push_cast; ring
  rw [hcast]
  constructor
  · intro h; exact_mod_cast h
  · intro h; rw [h]

/-! ## 4. A verified entry, and a decided instance

The `1A` entry of the head table is `c_{1A}(1) = 196884`, and it is *not*
assumed here: it is the number produced by the verified `q`-expansion of
`j = E₄³/Δ` in `Shared.MoonshineJExpansion` (`MoonshineJ.j_head_coefficient`).
The remaining `193` entries of the illustrative table below are placeholders
equal to `1` — the value `c_g(1)` would take if the corresponding character
value `χ_{196883}(g)` vanished — so the instance demonstrates the *mechanism*,
not the Monster's actual character table. -/

/-- The index of the identity class `1A` in the table. -/
def idxOneA : Fin monsterClassCount := ⟨0, by norm_num [monsterClassCount]⟩

/-- An illustrative head table: the verified `1A` entry, and `1` elsewhere. -/
def demoTable : Fin monsterClassCount → ℤ :=
  fun i => if (i : ℕ) = 0 then MoonshineJ.cf MoonshineJ.jT 2 else 1

/-- The `1A` entry of the illustrative table is the verified `j`-coefficient. -/
theorem demoTable_oneA : demoTable idxOneA = 196884 := by decide

set_option maxRecDepth 200000 in
/-- The finite check for the illustrative table, discharged by the kernel. -/
theorem demoTable_sum : ∑ i, demoTable i = 197077 := by decide

/-- **A decided instance of the reduction.**  The Laurent coefficient of the
`194`-fold product in degree `-192` is computed by a `decide`-checked integer
sum. -/
theorem head_check_demo : (headProduct demoTable).coeff (-192 : ℤ) = (197077 : ℂ) := by
  have := (head_check_iff demoTable 197077).mpr demoTable_sum
  simpa using this

/-! ## 5. A priori bounds on the finite check

Moonshine predicts `c_g(1) = 1 + χ(g)` for the `196883`-dimensional irreducible
character `χ`, whence `|c_g(1) - 1| ≤ 196883`.  Under that constraint alone, the
value of the finite check is confined to an explicit interval — so a proposed
head table failing the bound is refuted without any modular input. -/

/-- If every head entry differs from `1` by at most `B`, the finite check is
pinned to `194 ± 194·B`. -/
theorem head_sum_bound (t : Fin monsterClassCount → ℤ) (B : ℤ)
    (hB : ∀ i, |t i - 1| ≤ B) : |(∑ i, t i) - 194| ≤ 194 * B := by
  have hsum : (∑ i, t i) - 194 = ∑ i, (t i - 1) := by
    rw [Finset.sum_sub_distrib]
    simp [monsterClassCount]
  rw [hsum]
  calc |∑ i, (t i - 1)| ≤ ∑ i, |t i - 1| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _i : Fin monsterClassCount, B := Finset.sum_le_sum (fun i _ => hB i)
    _ = 194 * B := by simp [monsterClassCount, mul_comm]

/-- The moonshine bound: with `|χ_{196883}(g)| ≤ 196883` the finite check lies in
`[194 - 194·196883, 194 + 194·196883]`. -/
theorem head_sum_bound_moonshine (t : Fin monsterClassCount → ℤ)
    (hB : ∀ i, |t i - 1| ≤ 196883) :
    194 - 38195302 ≤ ∑ i, t i ∧ ∑ i, t i ≤ 194 + 38195302 := by
  have h := head_sum_bound t 196883 hB
  rw [abs_le] at h
  constructor <;> [linarith [h.1]; linarith [h.2]]

/-- The verified `1A` entry saturates nothing: it is `1 + 196883`, exactly the
extreme allowed by the character bound, which is the numerical fingerprint of
the fact that `1A` is the identity class. -/
theorem head_1A_extremal : |MoonshineJ.cf MoonshineJ.jT 2 - 1| = 196883 := by decide

end MoonshineHeadTable