import Mathlib
import Algebra.SumThreeCubes.Defs

/-!
# Local-Global Implication for Sums of Three Cubes

This file proves that integral representability implies everywhere
local admissibility — the "easy direction" of the Hasse principle.

## Main Results

* `sumThreeCubesRep_implies_everywhereLocallyAdmissible` — global ⟹ local
* `not_sumThreeCubesRep_of_local_failure` — contrapositive obstruction principle
-/

/-
Global representability implies local admissibility at every modulus.
-/
theorem sumThreeCubesRep_implies_everywhereLocallyAdmissible
    (k : ℤ) (h : SumThreeCubesRep k) :
    EverywhereLocallyAdmissible k := by
  exact fun n hn => by obtain ⟨ x, y, z, rfl ⟩ := h; exact ⟨ x, y, z, by simp +decide ⟩ ;

/-- Contrapositive: if local admissibility fails at some modulus,
then k is not globally representable. -/
theorem not_sumThreeCubesRep_of_local_failure
    (k : ℤ) (n : ℕ) (hn : 0 < n)
    (hfail : ¬ ThreeCubeLocalAdmissible n (k : ZMod n)) :
    ¬ SumThreeCubesRep k := by
  intro hrep
  exact hfail (sumThreeCubesRep_implies_everywhereLocallyAdmissible k hrep n hn)