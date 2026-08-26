import Mathlib
import Shared.PoleOrderObstruction
import Shared.PoleOrderObstructionDeep
import Shared.MoonshineHeadTable

/-!
# Completeness of the finite check: the 194-fold product knows the head table

`Shared.MoonshineHeadTable` reduced a moonshine head-coefficient statement to a
decidable equation between two integers, `∑_g c_g(1) = S`.  That reduction is
*sound* but a priori lossy: a single Laurent coefficient sees only one symmetric
function of the table.  This file shows that the whole product loses **nothing**.

* `MoonshineHeadRigidity.coeff_headProduct_esymm` — the Laurent coefficient of
  the `194`-fold product in degree `2k - 194` is exactly the `k`-th elementary
  symmetric function of the head table.  For `k = 0, 1` this recovers the
  leading coefficient `1` and the known degree `-192` coefficient `∑_g c_g(1)`.
* `MoonshineHeadRigidity.head_rigidity` — **the product determines the table up
  to relabelling**: two integral head tables give the same `194`-fold product if
  and only if they agree as multisets.  Hence the reduction to arithmetic is a
  complete invariant, not merely a necessary condition, and the finite check
  cannot be fooled by a rearranged or perturbed table.
* `MoonshineHeadRigidity.head_table_ne_of_sum_ne` — the contrapositive used in
  practice: a candidate table whose entries sum differently already yields a
  different product.

The proof runs through Vieta's formulas: `q^{194} ∏_g T_g` is the image of the
polynomial `∏_g (1 + c_g(1) q²)`, whose even coefficients are the elementary
symmetric functions of the table, and a multiset of complex numbers is
determined by its elementary symmetric functions (roots of `∏ (X + c_g(1))`).
-/

set_option maxRecDepth 8000

namespace MoonshineHeadRigidity

open Finset PowerSeries PoleOrderObstruction MoonshineHeadTable

/-! ## 1. The normalized part of a head series -/

/-- Coefficients of a trace series in non-negative degrees. -/
theorem coeff_traceLaurent_natCast (c : ℕ → ℂ) (n : ℕ) :
    (traceLaurent c).coeff (n : ℤ) = c n := by
  have h1 : (HahnSeries.ofPowerSeries ℤ ℂ (PowerSeries.mk c)).coeff (n : ℤ) = c n := by
    rw [HahnSeries.ofPowerSeries_apply_coeff, PowerSeries.coeff_mk]
  have h2 : (n : ℤ) ≠ (-1 : ℤ) := by omega
  simp [traceLaurent, h1, h2]

/-- `q · (q⁻¹ + t q) = 1 + t q²`. -/
theorem normalizedPart_headSeries (t : ℤ) :
    normalizedPart (traceLaurent (headSeries t)) = 1 + PowerSeries.C ((t : ℂ)) * X ^ 2 := by
  have hRHS : ∀ n : ℕ, PowerSeries.coeff n (1 + PowerSeries.C ((t : ℂ)) * X ^ 2)
      = (if n = 0 then (1 : ℂ) else 0) + (if n = 2 then (t : ℂ) else 0) := by
    intro n
    rw [map_add, PowerSeries.coeff_one, PowerSeries.coeff_C_mul, PowerSeries.coeff_X_pow]
    by_cases h : n = 2 <;> simp [h]
  ext n
  rw [coeff_normalizedPart (isNormalized_traceLaurent _) n, hRHS]
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · have h : ((0 : ℕ) : ℤ) - 1 = (-1 : ℤ) := by norm_num
    rw [h, (isNormalized_traceLaurent (headSeries t)).coeff_neg_one]
    norm_num
  · obtain ⟨p, rfl⟩ : ∃ p, n = p + 1 := ⟨n - 1, by omega⟩
    have h : ((p + 1 : ℕ) : ℤ) - 1 = (p : ℤ) := by push_cast; ring
    rw [h, coeff_traceLaurent_natCast]
    rcases eq_or_ne p 1 with rfl | hp
    · norm_num [headSeries]
    · have h1 : p + 1 ≠ 2 := by omega
      simp [headSeries, hp, h1]

/-! ## 2. Elementary symmetric functions of the head table -/

/-- The `k`-th elementary symmetric function of a head table. -/
def esymmTable (k : ℕ) (t : Fin monsterClassCount → ℤ) : ℤ :=
  ∑ T ∈ Finset.univ.powersetCard k, ∏ i ∈ T, t i

/-- Expansion of `∏ (1 + aᵢ q²)`: the coefficient in degree `2k` is the `k`-th
elementary symmetric function of the `aᵢ`. -/
theorem coeff_prod_one_add_C_X_sq {ι : Type*} [Fintype ι] [DecidableEq ι] (a : ι → ℂ) (k : ℕ) :
    PowerSeries.coeff (2 * k) (∏ i, (1 + PowerSeries.C (a i) * X ^ 2))
      = ∑ T ∈ Finset.univ.powersetCard k, ∏ i ∈ T, a i := by
  classical
  have hcomm : ∀ i : ι, (1 : PowerSeries ℂ) + PowerSeries.C (a i) * X ^ 2
      = PowerSeries.C (a i) * X ^ 2 + 1 := fun i => add_comm _ _
  rw [Finset.prod_congr rfl (fun i _ => hcomm i),
    Finset.prod_add (fun i => PowerSeries.C (a i) * X ^ 2) (fun _ => (1 : PowerSeries ℂ))]
  have hterm : ∀ T ∈ (Finset.univ : Finset ι).powerset,
      (∏ i ∈ T, PowerSeries.C (a i) * X ^ 2) * ∏ _i ∈ Finset.univ \ T, (1 : PowerSeries ℂ)
        = PowerSeries.C (∏ i ∈ T, a i) * X ^ (2 * T.card) := by
    intro T _
    rw [Finset.prod_const_one, mul_one, Finset.prod_mul_distrib, Finset.prod_const,
      ← map_prod, ← pow_mul, mul_comm 2 T.card]
  rw [Finset.sum_congr rfl hterm, map_sum]
  have hcoeff : ∀ T ∈ (Finset.univ : Finset ι).powerset,
      PowerSeries.coeff (2 * k) (PowerSeries.C (∏ i ∈ T, a i) * X ^ (2 * T.card))
        = if T.card = k then ∏ i ∈ T, a i else 0 := by
    intro T _
    rw [PowerSeries.coeff_C_mul, PowerSeries.coeff_X_pow]
    by_cases h : T.card = k
    · simp [h]
    · have : 2 * k ≠ 2 * T.card := by omega
      simp [this, h]
  rw [Finset.sum_congr rfl hcoeff, ← Finset.sum_filter, ← Finset.powersetCard_eq_filter]

/-- The `q^{194}`-corrected product is the image of the polynomial
`∏_g (1 + c_g(1) q²)`. -/
theorem ofPowerSeries_headProduct (t : Fin monsterClassCount → ℤ) :
    HahnSeries.ofPowerSeries ℤ ℂ (∏ i, (1 + PowerSeries.C ((t i : ℂ)) * X ^ 2))
      = qSeries ^ 194 * headProduct t := by
  have h := ofPowerSeries_prod_normalizedPart Finset.univ
    (fun i => traceLaurent (headSeries (t i)))
    (fun i _ => isNormalized_traceLaurent (headSeries (t i)))
  simp only [] at h
  rw [Finset.prod_congr rfl (fun i (_ : i ∈ Finset.univ) => normalizedPart_headSeries (t i))] at h
  have hcard : (Finset.univ : Finset (Fin monsterClassCount)).card = 194 := by
    simp [monsterClassCount]
  rw [hcard] at h
  rw [headProduct_def]
  exact h

/-- **Vieta for the moonshine product.**  The Laurent coefficient of the
`194`-fold product in degree `2k - 194` is the `k`-th elementary symmetric
function of the head table. -/
theorem coeff_headProduct_esymm (t : Fin monsterClassCount → ℤ) (k : ℕ) :
    (headProduct t).coeff (2 * (k : ℤ) - 194) = ((esymmTable k t : ℤ) : ℂ) := by
  classical
  have hcoe := HahnSeries.ofPowerSeries_apply_coeff
      (Γ := ℤ) (∏ i, (1 + PowerSeries.C ((t i : ℂ)) * X ^ 2)) (2 * k)
  rw [ofPowerSeries_headProduct t, qSeries_pow, HahnSeries.coeff_single_mul, one_mul] at hcoe
  have hindex : ((2 * k : ℕ) : ℤ) - (194 : ℕ) = 2 * (k : ℤ) - 194 := by push_cast; ring
  rw [hindex] at hcoe
  rw [hcoe, coeff_prod_one_add_C_X_sq (fun i => ((t i : ℤ) : ℂ)) k, esymmTable]
  push_cast
  rfl

/-! ## 3. Rigidity: the product is a complete invariant -/

/-- Equal head tables up to permutation give equal products. -/
theorem headProduct_eq_of_multiset_eq {t u : Fin monsterClassCount → ℤ}
    (h : Multiset.map t Finset.univ.val = Multiset.map u Finset.univ.val) :
    headProduct t = headProduct u := by
  have ht : headProduct t
      = (Multiset.map (fun x : ℤ => traceLaurent (headSeries x))
          (Multiset.map t Finset.univ.val)).prod := by
    rw [headProduct, Finset.prod_eq_multiset_prod, Multiset.map_map]
    rfl
  have hu : headProduct u
      = (Multiset.map (fun x : ℤ => traceLaurent (headSeries x))
          (Multiset.map u Finset.univ.val)).prod := by
    rw [headProduct, Finset.prod_eq_multiset_prod, Multiset.map_map]
    rfl
  rw [ht, hu, h]

/-- Equal products force equal elementary symmetric functions. -/
theorem esymmTable_eq_of_headProduct_eq {t u : Fin monsterClassCount → ℤ}
    (h : headProduct t = headProduct u) (k : ℕ) : esymmTable k t = esymmTable k u := by
  have := congrArg (fun f : LC => f.coeff (2 * (k : ℤ) - 194)) h
  simp only [coeff_headProduct_esymm] at this
  exact_mod_cast this

/-- Vieta: the monic polynomial with roots `-c_g(1)` has the elementary symmetric
functions of the head table as its coefficients. -/
theorem coeff_prod_X_add_C (t : Fin monsterClassCount → ℤ) {k : ℕ} (hk : k ≤ 194) :
    (∏ i, (Polynomial.X + Polynomial.C ((t i : ℤ) : ℂ))).coeff k
      = ((esymmTable (194 - k) t : ℤ) : ℂ) := by
  classical
  have hcard : (Finset.univ : Finset (Fin monsterClassCount)).card = 194 := by
    simp [monsterClassCount]
  have h := Finset.prod_X_add_C_coeff (Finset.univ : Finset (Fin monsterClassCount))
    (fun i => ((t i : ℤ) : ℂ)) (k := k) (by rw [hcard]; exact hk)
  rw [h, hcard, esymmTable]
  push_cast
  rfl

/-- Equal elementary symmetric functions force equal multisets of head values. -/
theorem multiset_eq_of_esymmTable_eq {t u : Fin monsterClassCount → ℤ}
    (h : ∀ k, esymmTable k t = esymmTable k u) :
    Multiset.map t Finset.univ.val = Multiset.map u Finset.univ.val := by
  classical
  set Pt : Polynomial ℂ := ∏ i, (Polynomial.X + Polynomial.C ((t i : ℤ) : ℂ)) with hPt
  set Pu : Polynomial ℂ := ∏ i, (Polynomial.X + Polynomial.C ((u i : ℤ) : ℂ)) with hPu
  have hdeg : ∀ v : Fin monsterClassCount → ℤ,
      (∏ i, (Polynomial.X + Polynomial.C ((v i : ℤ) : ℂ))).natDegree ≤ 194 := by
    intro v
    refine le_trans (Polynomial.natDegree_prod_le _ _) ?_
    have hone : ∀ i : Fin monsterClassCount,
        (Polynomial.X + Polynomial.C ((v i : ℤ) : ℂ)).natDegree = 1 := by
      intro i; exact Polynomial.natDegree_X_add_C _
    rw [Finset.sum_congr rfl (fun i _ => hone i)]
    simp [monsterClassCount]
  have hpoly : Pt = Pu := by
    apply Polynomial.ext
    intro k
    by_cases hk : k ≤ 194
    · rw [hPt, hPu, coeff_prod_X_add_C t hk, coeff_prod_X_add_C u hk, h]
    · push_neg at hk
      rw [Polynomial.coeff_eq_zero_of_natDegree_lt (lt_of_le_of_lt (hdeg t) hk),
        Polynomial.coeff_eq_zero_of_natDegree_lt (lt_of_le_of_lt (hdeg u) hk)]
  have hroots : ∀ v : Fin monsterClassCount → ℤ,
      (∏ i, (Polynomial.X + Polynomial.C ((v i : ℤ) : ℂ))).roots
        = Multiset.map (fun i => -((v i : ℤ) : ℂ)) Finset.univ.val := by
    intro v
    have hrew : (∏ i, (Polynomial.X + Polynomial.C ((v i : ℤ) : ℂ)))
        = (Multiset.map (fun a : ℂ => Polynomial.X - Polynomial.C a)
            (Multiset.map (fun i => -((v i : ℤ) : ℂ)) Finset.univ.val)).prod := by
      rw [Multiset.map_map, Finset.prod_eq_multiset_prod]
      refine congrArg Multiset.prod (Multiset.map_congr rfl ?_)
      intro i _
      simp only [Function.comp_apply]
      rw [Polynomial.C_neg, sub_neg_eq_add]
    rw [hrew, Polynomial.roots_multiset_prod_X_sub_C]
  have hmul : Multiset.map (fun i => -((t i : ℤ) : ℂ)) Finset.univ.val
      = Multiset.map (fun i => -((u i : ℤ) : ℂ)) Finset.univ.val := by
    rw [← hroots t, ← hroots u, ← hPt, ← hPu, hpoly]
  have hcast : Multiset.map (fun i => ((t i : ℤ) : ℂ)) Finset.univ.val
      = Multiset.map (fun i => ((u i : ℤ) : ℂ)) Finset.univ.val := by
    have hneg := congrArg (Multiset.map (fun z : ℂ => -z)) hmul
    rw [Multiset.map_map, Multiset.map_map] at hneg
    simp only [Function.comp_def, neg_neg] at hneg
    exact hneg
  have hcast' : Multiset.map (fun z : ℤ => (z : ℂ)) (Multiset.map t Finset.univ.val)
      = Multiset.map (fun z : ℤ => (z : ℂ)) (Multiset.map u Finset.univ.val) := by
    rw [Multiset.map_map, Multiset.map_map]
    exact hcast
  exact Multiset.map_injective (fun a b hab => by exact_mod_cast hab) hcast'

/-- **Rigidity of the head table.**  Two integral head tables produce the same
`194`-fold McKay–Thompson product exactly when they are rearrangements of each
other.  The finite arithmetic check is therefore a complete invariant. -/
theorem head_rigidity (t u : Fin monsterClassCount → ℤ) :
    headProduct t = headProduct u ↔
      Multiset.map t Finset.univ.val = Multiset.map u Finset.univ.val :=
  ⟨fun h => multiset_eq_of_esymmTable_eq (esymmTable_eq_of_headProduct_eq h),
   headProduct_eq_of_multiset_eq⟩

/-- Practical contrapositive: if two candidate tables have different sums, their
products differ. -/
theorem head_table_ne_of_sum_ne (t u : Fin monsterClassCount → ℤ)
    (h : ∑ i, t i ≠ ∑ i, u i) : headProduct t ≠ headProduct u := by
  intro hcontra
  apply h
  have h1 := esymmTable_eq_of_headProduct_eq hcontra 1
  simpa [esymmTable, Finset.powersetCard_one, Finset.sum_map] using h1

/-- **Decidability of the moonshine product equation.**  Because the product is a
complete invariant of the head table, equality of two Monster-sized Laurent
products reduces to equality of two multisets of integers, which is decidable. -/
instance decidableHeadProductEq (t u : Fin monsterClassCount → ℤ) :
    Decidable (headProduct t = headProduct u) :=
  decidable_of_iff _ (head_rigidity t u).symm

/-- The `k = 0` instance of Vieta: the product is monic at the pole. -/
theorem coeff_headProduct_pole (t : Fin monsterClassCount → ℤ) :
    (headProduct t).coeff (-194 : ℤ) = 1 := by
  have h := coeff_headProduct_esymm t 0
  norm_num [esymmTable] at h
  exact h

end MoonshineHeadRigidity