/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Completeness: internal versus external

`ℕ` has the property that every nonempty bounded set has a greatest element.
In the ultrapower this splits into a survival and a failure.

* `internal_bddAbove_has_max` — **survives for internal sets**: a nonempty
  internal set that is bounded above has a greatest element (in particular a
  least upper bound).
* `standard_cut_no_lub` — **fails externally**: the set of standard naturals is
  bounded above (by `ω`) but has no least upper bound at all.

The proof of the first result also isolates a useful transfer step
(`eventually_subset_of_bddAbove`): a bound on all germs in an internal set is a
pointwise bound on almost all coordinates.
-/

import Novelty.NonstandardTransfer
import Mathlib.Tactic

open Filter

namespace NonstandardArithmetic

/-- If every hypernatural in the internal set `A` is at most `[b]`, then almost
every coordinate of `A` is pointwise bounded by `b`. -/
theorem eventually_subset_of_bddAbove (A : ℕ → Set ℕ) (b : ℕ → ℕ)
    (hbd : ∀ H : HyperNat, H ∈* (A : InternalSet) → H ≤ (b : HyperNat)) :
    ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), ∀ x ∈ A i, x ≤ b i := by
  by_contra hc
  rw [← Ultrafilter.eventually_not] at hc
  have hne : ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), {x | x ∈ A i ∧ b i < x}.Nonempty := by
    filter_upwards [hc] with i hi
    push_neg at hi
    obtain ⟨x, hx1, hx2⟩ := hi
    exact ⟨x, hx1, by omega⟩
  obtain ⟨H, hH⟩ := (exists_internalMem_iff (fun i => {x | x ∈ A i ∧ b i < x})).mpr hne
  refine Filter.Germ.inductionOn H (fun g hg => ?_) hH
  rw [internalMem_coe] at hg
  have hmem : (g : HyperNat) ∈* (A : InternalSet) := by
    rw [internalMem_coe]
    filter_upwards [hg] with i hi using hi.1
  have hle := hbd _ hmem
  rw [Filter.Germ.coe_le] at hle
  have hfalse : ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), False := by
    filter_upwards [hg, hle] with i h1 h2
    exact absurd h1.2 (by omega)
  rw [Filter.eventually_false_iff_eq_bot] at hfalse
  exact Filter.NeBot.ne inferInstance hfalse

/-- **Completeness survives for internal sets.**  A nonempty internal set that
is bounded above has a greatest element, which is therefore its least upper
bound. -/
theorem internal_bddAbove_has_max (A : InternalSet) (hne : ∃ H : HyperNat, H ∈* A)
    (hbd : ∃ B : HyperNat, ∀ H : HyperNat, H ∈* A → H ≤ B) :
    ∃ S : HyperNat, S ∈* A ∧ (∀ H : HyperNat, H ∈* A → H ≤ S) ∧
      ∀ T : HyperNat, (∀ H : HyperNat, H ∈* A → H ≤ T) → S ≤ T := by
  classical
  obtain ⟨B, hB⟩ := hbd
  obtain ⟨H₀, hH₀⟩ := hne
  refine Filter.Germ.inductionOn A (fun A => Filter.Germ.inductionOn B (fun b =>
    Filter.Germ.inductionOn H₀ (fun g hB hH₀ => ?_))) hB hH₀
  rw [internalMem_coe] at hH₀
  have hsub := eventually_subset_of_bddAbove A b hB
  set s : ℕ → ℕ := fun i => Nat.findGreatest (fun x => x ∈ A i) (b i) with hs
  have hsmem : ∀ᶠ i in (hyperfilter ℕ : Filter ℕ), s i ∈ A i := by
    filter_upwards [hH₀, hsub] with i h1 h2
    exact Nat.findGreatest_spec (P := fun x => x ∈ A i) (h2 _ h1) h1
  have hSmem : (s : HyperNat) ∈* (A : InternalSet) := (internalMem_coe s A).mpr hsmem
  refine ⟨(s : HyperNat), hSmem, ?_, ?_⟩
  · intro H hH
    refine Filter.Germ.inductionOn H (fun h hh => ?_) hH
    rw [internalMem_coe] at hh
    rw [Filter.Germ.coe_le]
    filter_upwards [hh, hsub] with i h1 h2
    exact Nat.le_findGreatest (h2 _ h1) h1
  · intro T hT
    exact hT _ hSmem

/-- **Completeness fails externally.**  The standard cut is bounded above by
`ω`, yet it has no least upper bound: any upper bound is unlimited, and
unlimited elements admit strictly smaller unlimited ones. -/
theorem standard_cut_no_lub :
    (∀ n : ℕ, standard n ≤ omega) ∧
      ¬ ∃ S : HyperNat, (∀ n : ℕ, standard n ≤ S) ∧
        ∀ T : HyperNat, (∀ n : ℕ, standard n ≤ T) → S ≤ T := by
  refine ⟨fun n => (standard_lt_omega n).le, ?_⟩
  rintro ⟨S, hub, hleast⟩
  have hSU : IsUnlimited S := by
    intro n
    have hlt : standard n < standard (n + 1) := by
      simp [standard]
    exact lt_of_lt_of_le hlt (hub (n + 1))
  obtain ⟨K, hK, hKS⟩ := no_least_unlimited S hSU
  exact absurd (hleast K (fun n => (hK n).le)) (not_le.mpr hKS)

end NonstandardArithmetic