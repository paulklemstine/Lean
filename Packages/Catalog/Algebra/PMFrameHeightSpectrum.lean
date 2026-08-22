/-
# The height of a `±`-frame is a function of its odd radical, and it takes at least three values

Height reduction (`Algebra/PMFrameHeightReduction.lean`) says that `FrameBoundedBy n B` depends on
`n` only through `oddRad n`.  This file records the two structural consequences.

* **The height is an invariant of the odd radical.**  Two orders with the same odd radical have the
  same set of coefficient bounds, hence the same least bound (`isLeast_height_congr_oddRad`);
  contrapositively, two orders of different height have different odd radicals
  (`oddRad_ne_of_isLeast_ne`).
* **The height is at least one, and equals one exactly for the flat orders**
  (`isLeast_height_one_iff_flatFrame`), because a cyclotomic polynomial is monic.

Combining these with the three explicit computations of the catalog — `Φ₂₃₁` flat
(`Algebra/PMFrame231Flat.lean`), `Φ₁₀₅` of height `2` (`Algebra/PMFrame105Explicit.lean`) and
`Φ₃₈₅` of height `3` (`Algebra/PMFrame385Height3.lean`) — gives three infinite families of orders,
pairwise separated by their heights, all of them with exactly three odd prime divisors
(`ternary_height_trichotomy`).  So the number of odd prime divisors does not determine the height,
while the odd radical does.
-/
import Mathlib
import Shared.PMFrameTwoParameter
import Algebra.PMFrameFlatFamilies
import Algebra.PMFrameHeightReduction
import Algebra.PMFrame105Explicit
import Algebra.PMFrame231Flat
import Algebra.PMFrame385Height3

namespace PMFrameSpectrum

open Polynomial Finset PMFrame PMFrameFlat PMFrameHeight

/-! ## 1. The height is an invariant of the odd radical -/

/-- Two orders with the same odd radical admit exactly the same coefficient bounds. -/
theorem frameBoundedBy_congr_oddRad {m n : ℕ} (hm : m ≠ 0) (hn : n ≠ 0)
    (h : oddRad m = oddRad n) (B : ℤ) : FrameBoundedBy m B ↔ FrameBoundedBy n B := by
  rw [frameBoundedBy_iff_oddRad m hm B, frameBoundedBy_iff_oddRad n hn B, h]

/-- Consequently the least coefficient bound — the height — is an invariant of the odd radical. -/
theorem isLeast_height_congr_oddRad {m n : ℕ} (hm : m ≠ 0) (hn : n ≠ 0)
    (h : oddRad m = oddRad n) (B : ℤ) :
    IsLeast {C : ℤ | FrameBoundedBy m C} B ↔ IsLeast {C : ℤ | FrameBoundedBy n C} B := by
  have hset : {C : ℤ | FrameBoundedBy m C} = {C : ℤ | FrameBoundedBy n C} := by
    ext C
    exact frameBoundedBy_congr_oddRad hm hn h C
  rw [hset]

/-- Contrapositive form: orders of different height have different odd radicals. -/
theorem oddRad_ne_of_isLeast_ne {m n : ℕ} (hm : m ≠ 0) (hn : n ≠ 0) {B C : ℤ}
    (hB : IsLeast {D : ℤ | FrameBoundedBy m D} B) (hC : IsLeast {D : ℤ | FrameBoundedBy n D} C)
    (hBC : B ≠ C) : oddRad m ≠ oddRad n := by
  intro h
  exact hBC (IsLeast.unique ((isLeast_height_congr_oddRad hm hn h B).mp hB) hC)

/-! ## 2. Height one is exactly flatness -/

/-- Every frame has a coefficient of absolute value `1` (the leading one), so no order has
height `0`. -/
theorem one_le_of_frameBoundedBy {n : ℕ} {B : ℤ} (h : FrameBoundedBy n B) : 1 ≤ B := by
  have hmonic : (pmFrame n).Monic := Polynomial.cyclotomic.monic n ℤ
  have hlead : (pmFrame n).coeff (pmFrame n).natDegree = 1 := hmonic.coeff_natDegree
  have := h (pmFrame n).natDegree
  rw [hlead] at this
  simpa using this

/-- **Height one is flatness.**  The least coefficient bound of `Φ_n` is `1` exactly when `Φ_n`
is flat. -/
theorem isLeast_height_one_iff_flatFrame {n : ℕ} :
    IsLeast {B : ℤ | FrameBoundedBy n B} 1 ↔ FlatFrame n := by
  constructor
  · intro h
    exact h.1
  · intro h
    exact ⟨h, fun _ hB => one_le_of_frameBoundedBy hB⟩

/-! ## 3. Three ternary height classes -/

theorem isLeast_height_231 : IsLeast {B : ℤ | FrameBoundedBy 231 B} 1 :=
  isLeast_height_one_iff_flatFrame.mpr PMFrame231.flatFrame_231

theorem isLeast_height_105 : IsLeast {B : ℤ | FrameBoundedBy 105 B} 2 :=
  PMFrame105.isLeast_height_pmFrame_105

theorem isLeast_height_385 : IsLeast {B : ℤ | FrameBoundedBy 385 B} 3 :=
  PMFrame385.isLeast_height_pmFrame_385

/-- **The ternary trichotomy.**  Each of `231 = 3·7·11`, `105 = 3·5·7` and `385 = 5·7·11` has
exactly three odd prime divisors, yet their heights are `1`, `2` and `3`.  The number of odd prime
divisors therefore does not determine the height; moreover the property propagates to every order
with the same odd radical, so each of the three heights is realised by an infinite family. -/
theorem ternary_height_trichotomy :
    ((231 : ℕ).primeFactors.erase 2).card = 3 ∧ ((105 : ℕ).primeFactors.erase 2).card = 3 ∧
      ((385 : ℕ).primeFactors.erase 2).card = 3 ∧
      IsLeast {B : ℤ | FrameBoundedBy 231 B} 1 ∧ IsLeast {B : ℤ | FrameBoundedBy 105 B} 2 ∧
      IsLeast {B : ℤ | FrameBoundedBy 385 B} 3 := by
  refine ⟨?_, ?_, ?_, isLeast_height_231, isLeast_height_105, isLeast_height_385⟩
  · rw [PMFrame231.primeFactors_231]; decide
  · rw [PMFrameFlat.primeFactors_105]; decide
  · rw [PMFrame385.primeFactors_385]; decide

/-- Each of the three heights persists along the whole odd-radical class, so `1`, `2` and `3` are
each realised by infinitely many orders. -/
theorem height_of_oddRad_class {n : ℕ} (hn : n ≠ 0) :
    (oddRad n = 231 → IsLeast {B : ℤ | FrameBoundedBy n B} 1) ∧
      (oddRad n = 105 → IsLeast {B : ℤ | FrameBoundedBy n B} 2) ∧
      (oddRad n = 385 → IsLeast {B : ℤ | FrameBoundedBy n B} 3) := by
  refine ⟨fun h => ?_, fun h => ?_, fun h => ?_⟩
  · exact (isLeast_height_congr_oddRad hn (by norm_num)
      (by rw [h, PMFrame231.oddRad_231]) 1).mpr isLeast_height_231
  · exact (isLeast_height_congr_oddRad hn (by norm_num)
      (by rw [h, PMFrameHeight.oddRad_105]) 2).mpr isLeast_height_105
  · exact (isLeast_height_congr_oddRad hn (by norm_num)
      (by rw [h, PMFrame385.oddRad_385]) 3).mpr isLeast_height_385

end PMFrameSpectrum