import Mathlib
import Shared.PoleOrderObstruction
import Shared.PoleOrderObstructionDeep
import Cryptography.PoleOrderSplitting
import Cryptography.PoleOrderValuationRigidity

/-!
# Cycle 5: why the extension splits, additive robustness, and coefficient domination

Cycle 3 built an explicit splitting of `1 → ℂ⟦X⟧ˣ → ℂ⸨X⸩ˣ → ℤ → 1`, cycle 4 showed
that the resulting invariant is rigid, torsion-free and positivity-compatible.
This cycle answers three further questions.

1. **Why does it split at all?** (`PoleOrderRobustness.exists_section_of_surjective_toInt`)
   Not by accident: *every* surjection from a group onto `ℤ` admits a
   homomorphic section, because `ℤ` is free.  The `q ^ k`-correction of cycles
   1–3 is one instance.  Moreover the section is unique up to an element of the
   kernel (`PoleOrderRobustness.section_val_eq_qUnit_mul`): any monomial-type
   correction differs from `q` by a unit power series, so `q ^ 194` is the
   canonical Monster correction *up to blinding, and no further*.

2. **Additive robustness** (`PoleOrderRobustness.poleOrder_add_stable`): the pole
   survives *additive* masking as well as multiplicative blinding.  Adding to the
   Monster-sized product any Laurent series whose own order exceeds `-194` — in
   particular any power series, any polynomial in `q`, any finite sum of
   moonshine series — leaves the order at exactly `-194`
   (`PoleOrderRobustness.orderTop_monsterProd_add`).

3. **Coefficient domination** (`PoleOrderRobustness.coeff_prod_ge_coeff_factor`):
   for factors with non-negative real coefficients, the coefficient of the
   product at degree `n - m` dominates the degree-`(n-1)` coefficient of *every*
   individual factor.  So the corrected moonshine product grows at least as fast
   as the largest McKay–Thompson series; the pole-order correction never loses
   information about the individual graded dimensions.
-/

namespace PoleOrderRobustness

open HahnSeries Finset PoleOrderObstruction PoleOrderSplitting PoleOrderValuation

/-! ## 1. Freeness of `ℤ` forces the splitting -/

/-- **Every surjection onto `ℤ` splits.**  A group homomorphism onto
`Multiplicative ℤ` always admits a homomorphic section; the splitting of the
pole-order sequence is an instance, not a coincidence. -/
theorem exists_section_of_surjective_toInt {G : Type*} [Group G]
    (φ : G →* Multiplicative ℤ) (hφ : Function.Surjective φ) :
    ∃ σ : Multiplicative ℤ →* G, ∀ k, φ (σ k) = k := by
  obtain ⟨g, hg⟩ := hφ (Multiplicative.ofAdd (1 : ℤ))
  refine ⟨zpowersHom G g, fun k => ?_⟩
  have : φ ((zpowersHom G g) k) = (φ g) ^ (Multiplicative.toAdd k) := by
    simp [zpowersHom, map_zpow]
  rw [this, hg]
  apply Multiplicative.toAdd.injective
  simp

/-- **Uniqueness of the correction up to blinding.**  Any section of the order
homomorphism sends the generator to `q` times a unit power series, and that unit
is unique. -/
theorem section_val_eq_qUnit_mul (σ : Multiplicative ℤ →* (LC)ˣ)
    (hσ : ∀ k, orderMonoidHom (σ k) = k) :
    ∃! p : (PowerSeries ℂ)ˣ, σ (Multiplicative.ofAdd (1 : ℤ)) = psUnitHom p * qUnit := by
  have hord : ((σ (Multiplicative.ofAdd (1 : ℤ)) : (LC)ˣ) : LC).order = 1 := by
    have := hσ (Multiplicative.ofAdd (1 : ℤ))
    simpa [orderMonoidHom_apply] using congrArg Multiplicative.toAdd this
  have hq : ((qUnit : (LC)ˣ) : LC).order = 1 := poleLeak_qUnit
  obtain ⟨p, hp⟩ := (exists_unitMul_iff_order_eq (σ (Multiplicative.ofAdd (1 : ℤ))) qUnit).mpr
    (by rw [hord, hq])
  refine ⟨p, hp, ?_⟩
  intro p' hp'
  have hpp : psUnitHom p' = psUnitHom p := by
    have : psUnitHom p' * qUnit = psUnitHom p * qUnit := by rw [← hp', ← hp]
    exact mul_right_cancel this
  have : (p' : PowerSeries ℂ) = (p : PowerSeries ℂ) := by
    apply HahnSeries.ofPowerSeries_injective (Γ := ℤ)
    have := congrArg (fun u : (LC)ˣ => (u : LC)) hpp
    simpa using this
  exact Units.ext this

/-! ## 2. Additive robustness of the pole -/

/-- **Additive masking cannot hide a pole.**  If `y` has strictly larger order
than `x`, the sum keeps the order of `x`. -/
theorem orderTop_add_of_lt {x y : LC} (h : x.orderTop < y.orderTop) :
    (x + y).orderTop = x.orderTop :=
  HahnSeries.orderTop_add_eq_left h

/-- The pole order of a product of `m` normalized series is stable under adding
anything of order `> -m`. -/
theorem poleOrder_add_stable {ι : Type*} (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i)) (m : ℤ) (hm : (s.card : ℤ) = m) (y : LC)
    (hy : ((-m : ℤ) : WithTop ℤ) < y.orderTop) :
    ((∏ i ∈ s, f i) + y).orderTop = ((-m : ℤ) : WithTop ℤ) := by
  subst hm
  rw [orderTop_add_of_lt (by rw [orderTop_prod_normalized s f h]; exact hy),
    orderTop_prod_normalized s f h]

/-- Adding anything of order `> -194` to a Monster-sized moonshine product leaves
the pole of order `194` untouched. -/
theorem orderTop_monsterProd_add (c : Fin monsterClassCount → ℕ → ℂ) (y : LC)
    (hy : ((-194 : ℤ) : WithTop ℤ) < y.orderTop) :
    ((∏ i, traceLaurent (c i)) + y).orderTop = ((-194 : ℤ) : WithTop ℤ) :=
  poleOrder_add_stable Finset.univ (fun i => traceLaurent (c i))
    (fun i _ => isNormalized_traceLaurent (c i)) 194 (by simp [monsterClassCount]) y hy

/-- In particular, additive masking by a genuine power series is useless. -/
theorem orderTop_monsterProd_add_powerSeries (c : Fin monsterClassCount → ℕ → ℂ)
    (g : PowerSeries ℂ) :
    ((∏ i, traceLaurent (c i)) + HahnSeries.ofPowerSeries ℤ ℂ g).orderTop
      = ((-194 : ℤ) : WithTop ℤ) := by
  refine orderTop_monsterProd_add c _ ?_
  rcases eq_or_ne (HahnSeries.ofPowerSeries ℤ ℂ g : LC) 0 with hg | hg
  · rw [hg, HahnSeries.orderTop_zero]
    exact WithTop.coe_lt_top _
  · have h0 : (0 : WithTop ℤ) ≤ (HahnSeries.ofPowerSeries ℤ ℂ g : LC).orderTop :=
      (mem_range_ofPowerSeries_iff _).mp ⟨g, rfl⟩
    refine lt_of_lt_of_le ?_ h0
    exact WithTop.coe_lt_coe.mpr (by norm_num)

/-! ## 3. Coefficient domination -/

theorem re_le_re_sum_of_isNonnegReal {ι : Type*} (s : Finset ι) (g : ι → ℂ)
    (hg : ∀ i ∈ s, IsNonnegReal (g i)) {a : ι} (ha : a ∈ s) :
    (g a).re ≤ (∑ i ∈ s, g i).re := by
  rw [Complex.re_sum]
  refine Finset.single_le_sum (f := fun i => (g i).re) (fun i hi => ?_) ha
  obtain ⟨r, hr, hri⟩ := hg i hi
  show (0 : ℝ) ≤ (g i).re
  rw [hri]
  simpa using hr

/-- **Domination.**  For a product of `m` normalized series with non-negative
real coefficients, the coefficient at degree `n - m` dominates the degree
`n - 1` coefficient of each individual factor. -/
theorem coeff_prod_ge_coeff_factor {ι : Type*} [DecidableEq ι] (s : Finset ι) (f : ι → LC)
    (h : ∀ i ∈ s, IsNormalized (f i))
    (hpos : ∀ i ∈ s, ∀ k : ℕ, IsNonnegReal ((f i).coeff (k : ℤ)))
    {j : ι} (hj : j ∈ s) (n : ℕ) :
    ((f j).coeff ((n : ℤ) - 1)).re ≤ ((∏ i ∈ s, f i).coeff ((n : ℤ) - (s.card : ℤ))).re := by
  classical
  rw [coeff_prod_normalized_general s f h n]
  have hmem : (Finsupp.single j n) ∈ s.finsuppAntidiag n := by
    rw [Finset.mem_finsuppAntidiag]
    refine ⟨?_, ?_⟩
    · rw [Finset.sum_eq_single j]
      · simp
      · intro b _ hb
        simp [Ne.symm hb]
      · intro hjs
        exact absurd hj hjs
    · exact Finsupp.support_single_subset.trans (by simpa using hj)
  have hterm : ∏ i ∈ s, (f i).coeff (((Finsupp.single j n) i : ℤ) - 1)
      = (f j).coeff ((n : ℤ) - 1) := by
    rw [Finset.prod_eq_single j]
    · simp
    · intro b hb hbj
      simp [Ne.symm hbj, (h b hb).coeff_neg_one]
    · intro hjs
      exact absurd hj hjs
  have hnn : ∀ l ∈ s.finsuppAntidiag n,
      IsNonnegReal (∏ i ∈ s, (f i).coeff ((l i : ℤ) - 1)) := by
    intro l _
    refine IsNonnegReal.prod _ _ (fun i hi => ?_)
    rcases Nat.eq_zero_or_pos (l i) with hli | hli
    · rw [hli]
      simpa [(h i hi).coeff_neg_one] using IsNonnegReal.one
    · obtain ⟨k, hk⟩ : ∃ k : ℕ, l i = k + 1 := ⟨l i - 1, by omega⟩
      rw [hk, show (((k + 1 : ℕ) : ℤ) - 1) = (k : ℤ) by push_cast; ring]
      exact hpos i hi k
  calc ((f j).coeff ((n : ℤ) - 1)).re
      = (∏ i ∈ s, (f i).coeff (((Finsupp.single j n) i : ℤ) - 1)).re := by rw [hterm]
    _ ≤ (∑ l ∈ s.finsuppAntidiag n, ∏ i ∈ s, (f i).coeff ((l i : ℤ) - 1)).re :=
        re_le_re_sum_of_isNonnegReal (s.finsuppAntidiag n)
          (fun l => ∏ i ∈ s, (f i).coeff ((l i : ℤ) - 1)) hnn hmem

/-- **Moonshine domination.**  Every coefficient of the `194`-fold moonshine
product dominates the corresponding coefficient of each McKay–Thompson factor,
provided the factors have non-negative real coefficients. -/
theorem coeff_prod_traceLaurent_194_ge (c : Fin monsterClassCount → ℕ → ℂ)
    (hc : ∀ i k, IsNonnegReal (c i k)) (j : Fin monsterClassCount) (n : ℕ) :
    (c j n).re ≤ ((∏ i, traceLaurent (c i)).coeff (((n : ℤ) + 1) - 194)).re := by
  have hcoeff : ∀ i : Fin monsterClassCount, ∀ k : ℕ,
      (traceLaurent (c i)).coeff (k : ℤ) = c i k := by
    intro i k
    have h1 : (HahnSeries.ofPowerSeries ℤ ℂ (PowerSeries.mk (c i))).coeff (k : ℤ) = c i k := by
      simp [HahnSeries.ofPowerSeries_apply_coeff (Γ := ℤ) (PowerSeries.mk (c i)) k]
    have h2 : ((k : ℤ)) ≠ (-1 : ℤ) := by omega
    simp [traceLaurent, h1, h2]
  have h := coeff_prod_ge_coeff_factor (Finset.univ : Finset (Fin monsterClassCount))
    (fun i => traceLaurent (c i)) (fun i _ => isNormalized_traceLaurent (c i))
    (fun i _ k => by rw [hcoeff i k]; exact hc i k) (Finset.mem_univ j) (n + 1)
  rw [show ((((n : ℕ) + 1 : ℕ) : ℤ) - 1) = (n : ℤ) by push_cast; ring, hcoeff j n] at h
  simpa [monsterClassCount] using h

end PoleOrderRobustness