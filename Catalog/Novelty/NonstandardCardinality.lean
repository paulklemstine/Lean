/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The size of the nonstandard model

Building on `Novelty.NonstandardArithmetic` and `Novelty.NonstandardInternalSets`
we determine the cardinality of the ultrapower `HyperNat` of `ℕ` modulo the
hyperfilter.

The upper bound `#HyperNat ≤ 𝔠` is immediate (a quotient of `ℕ → ℕ`).  For the
lower bound we exhibit a continuum-sized family of hypernaturals with an
analytic construction: the germ of the sequence `n ↦ ⌊n · r⌋` for a positive
real `r`.  Two different slopes eventually separate, hence give different germs.
This yields

* `mk_hyperNat` : `#HyperNat = 𝔠`,
* `mk_unlimited` : even the (external) set of unlimited elements has size `𝔠`,
* `not_countable_hyperNat`, `hyperNat_not_equiv_nat` : the nonstandard model is
  not countable, so no first-order transfer principle can pin down `ℕ` up to
  isomorphism through this construction.
-/

import Novelty.NonstandardInternalSets
import Mathlib.SetTheory.Cardinal.Continuum
import Mathlib.SetTheory.Cardinal.Order
import Mathlib.Tactic

open Filter Cardinal Set

namespace NonstandardArithmetic

/-- The hypernatural given by the germ of the "slope `r` staircase"
`n ↦ ⌊n · r⌋`. -/
noncomputable def floorSlope (r : ℝ) : HyperNat :=
  ((fun n : ℕ => ⌊(n : ℝ) * r⌋₊ : ℕ → ℕ) : HyperNat)

/-- For a positive slope the staircase eventually passes every level. -/
theorem eventually_lt_floorSlope {r : ℝ} (hr : 0 < r) (c : ℕ) :
    ∀ᶠ (i : ℕ) in (hyperfilter ℕ : Filter ℕ), c < ⌊(i : ℝ) * r⌋₊ := by
  obtain ⟨N, hN⟩ := exists_nat_gt (((c : ℝ) + 1) / r)
  filter_upwards [eventually_ge_hyperfilter N] with i hi
  have h2 : ((c : ℝ) + 1) < (N : ℝ) * r := by
    rw [div_lt_iff₀ hr] at hN; exact hN
  have h3 : (N : ℝ) * r ≤ (i : ℝ) * r :=
    mul_le_mul_of_nonneg_right (by exact_mod_cast hi) hr.le
  have h4 : ((c + 1 : ℕ) : ℝ) ≤ (i : ℝ) * r := by push_cast; linarith
  have := Nat.le_floor h4
  omega

/-- Every positive slope produces an unlimited hypernatural. -/
theorem isUnlimited_floorSlope {r : ℝ} (hr : 0 < r) : IsUnlimited (floorSlope r) := by
  rw [floorSlope, isUnlimited_coe]
  exact fun n => eventually_lt_floorSlope hr n

/-- Distinct positive slopes give strictly ordered, hence distinct, germs. -/
theorem floorSlope_lt {r s : ℝ} (hr : 0 < r) (hrs : r < s) : floorSlope r < floorSlope s := by
  rw [floorSlope, floorSlope, Filter.Germ.coe_lt]
  obtain ⟨N, hN⟩ := exists_nat_gt (1 / (s - r))
  have hsr : 0 < s - r := by linarith
  filter_upwards [eventually_ge_hyperfilter N] with i hi
  have h1 : 1 < (N : ℝ) * (s - r) := by
    rw [div_lt_iff₀ hsr] at hN; linarith
  have h2 : (N : ℝ) * (s - r) ≤ (i : ℝ) * (s - r) :=
    mul_le_mul_of_nonneg_right (by exact_mod_cast hi) hsr.le
  have hfl : (⌊(i : ℝ) * r⌋₊ : ℝ) ≤ (i : ℝ) * r :=
    Nat.floor_le (by positivity)
  have h4 : ((⌊(i : ℝ) * r⌋₊ + 1 : ℕ) : ℝ) ≤ (i : ℝ) * s := by
    push_cast
    nlinarith
  have := Nat.le_floor h4
  omega

/-- The slope map is injective on the positive reals. -/
theorem floorSlope_injOn : InjOn floorSlope (Ioi (0 : ℝ)) := by
  intro r hr s hs h
  rcases lt_trichotomy r s with hlt | heq | hgt
  · exact absurd h (floorSlope_lt hr hlt).ne
  · exact heq
  · exact absurd h.symm (floorSlope_lt hs hgt).ne

/-- The ultrapower is a quotient of `ℕ → ℕ`, hence has at most continuum many
elements. -/
theorem mk_hyperNat_le : #HyperNat ≤ 𝔠 := by
  have h1 : #HyperNat ≤ #(ℕ → ℕ) := Cardinal.mk_quotient_le
  have h2 : #(ℕ → ℕ) = 𝔠 := by
    rw [Cardinal.mk_arrow]
    simp [Cardinal.aleph0_power_aleph0]
  exact h2 ▸ h1

/-- Continuum many hypernaturals, all of them unlimited. -/
theorem continuum_le_mk_unlimited : 𝔠 ≤ #{H : HyperNat // IsUnlimited H} := by
  have hIoi : #(Ioi (0 : ℝ)) = 𝔠 := Cardinal.mk_Ioi_real 0
  rw [← hIoi]
  refine Cardinal.mk_le_of_injective
    (f := fun r : Ioi (0 : ℝ) => (⟨floorSlope r.1, isUnlimited_floorSlope r.2⟩ :
      {H : HyperNat // IsUnlimited H})) ?_
  rintro ⟨r, hr⟩ ⟨s, hs⟩ h
  have : floorSlope r = floorSlope s := congrArg Subtype.val h
  exact Subtype.ext (floorSlope_injOn hr hs this)

/-- **The ultrapower has exactly the cardinality of the continuum.** -/
theorem mk_hyperNat : #HyperNat = 𝔠 := by
  refine le_antisymm mk_hyperNat_le ?_
  refine le_trans continuum_le_mk_unlimited ?_
  exact Cardinal.mk_set_le _

/-- **Even the external set of unlimited elements has size continuum**, while
the standard part is countable. -/
theorem mk_unlimited : #{H : HyperNat // IsUnlimited H} = 𝔠 :=
  le_antisymm (le_trans (Cardinal.mk_set_le _) (le_of_eq mk_hyperNat))
    continuum_le_mk_unlimited

/-- The standard part is countable. -/
theorem mk_standard : #{H : HyperNat // IsStandard H} = ℵ₀ := by
  have hsurj : Function.Surjective
      (fun n : ℕ => (⟨standard n, isStandard_standard n⟩ : {H : HyperNat // IsStandard H})) := by
    rintro ⟨H, n, rfl⟩
    exact ⟨n, rfl⟩
  have hinj : Function.Injective
      (fun n : ℕ => (⟨standard n, isStandard_standard n⟩ : {H : HyperNat // IsStandard H})) := by
    intro m n h
    exact standard_injective (congrArg Subtype.val h)
  have := Cardinal.mk_congr (Equiv.ofBijective _ ⟨hinj, hsurj⟩)
  rw [← this, Cardinal.mk_nat]

/-- The nonstandard model is uncountable. -/
theorem not_countable_hyperNat : ¬ Countable HyperNat := by
  intro h
  have : #HyperNat ≤ ℵ₀ := Cardinal.mk_le_aleph0
  rw [mk_hyperNat] at this
  exact absurd this (not_le.mpr Cardinal.aleph0_lt_continuum)

/-- In particular there is no bijection between the ultrapower and `ℕ`: the
ultrapower construction produces a genuinely new model. -/
theorem hyperNat_not_equiv_nat : IsEmpty (HyperNat ≃ ℕ) := by
  constructor
  intro e
  exact not_countable_hyperNat (Countable.of_equiv ℕ e.symm)

end NonstandardArithmetic