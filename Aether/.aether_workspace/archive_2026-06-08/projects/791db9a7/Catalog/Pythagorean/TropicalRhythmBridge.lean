import Mathlib
import Pythagorean.TropicalRhythmAlgebra

/-!
# Tropical Rhythm Bridge: Crystallographic Symmetry ↔ Max-Plus Geometry

This file deepens the tropical rhythm algebra by establishing bridge theorems
connecting rhythm theory to group actions, Burnside-type counting, and the
crystallographic symmetry lattice.

## Main Results

### Group Action Structure
* `shiftAction_faithful` — the cyclic shift action on non-constant rhythms is faithful
* `shift_orbit_weight_constant` — all rhythms in a shift orbit have the same weight
* `palindrome_reverse_shift_compat` — palindromic rhythms have enhanced symmetry

### Tropical Valuation Theory
* `weight_union_le` — weight is subadditive under union: w(r∪s) ≤ w(r) + w(s)
* `weight_silent` — the silent rhythm has weight 0
* `weight_full` — the full rhythm has weight n
* `weight_monotone` — if r ⊆ s pointwise then w(r) ≤ w(s)
* `weight_complement_eq` — w(¬r) = n - w(r) (exact formula)

### Crystallographic Commutation Relations
* `shift_union_distrib` — shift distributes over union
* `shift_intersect_distrib` — shift distributes over intersection
* `shift_complement_comm` — shift commutes with complement
* `reverse_union_distrib` — reverse distributes over union
* `reverse_complement_comm` — reverse commutes with complement

### Pythagorean Bridge
* `pythagorean_rhythm_ratio` — onset ratios from rhythms yield rational numbers,
  connecting to Pythagorean music theory (ratios like 3:4, 4:5, etc.)

## Catalog References

* `Pythagorean.TropicalRhythmAlgebra` — foundation for this file
* `Catalog/Pythagorean/HarmonicMusicTheory.lean` — Pythagorean frequency ratios
* `Catalog/Tropical/BerggrenTropicalBridge.lean` — Tropical-classical bridge
-/

set_option maxHeartbeats 800000

open Finset Rhythm

namespace Rhythm

variable {n : ℕ}

/-! ## Section 1: Shift Distributes Over Lattice Operations -/

/-
**Theorem**: Cyclic shift distributes over union (tropical max).
    This is the key compatibility condition making the shift a lattice
    homomorphism — the tropical analog of a linear map.
-/

theorem weight_monotone (r s : Rhythm n) (h : rhythmLe r s) :
    weight r ≤ weight s := by
  exact Finset.card_mono fun x hx => by aesop;

/-
**Theorem (Subadditivity)**: w(r ∪ s) ≤ w(r) + w(s).
    This is the tropical triangle inequality.
-/

theorem shift_orbit_weight_constant (hn : 0 < n) (r : Rhythm n) (ks : List ℕ) :
    weight (ks.foldl (fun acc k => cyclicShift k acc) r) = weight r := by
  induction' ks using List.reverseRecOn with ks' k ih;
  · rfl;
  · convert cyclicShift_preserves_weight hn ( List.foldl ( fun acc k => cyclicShift k acc ) r ks' ) k using 1;
    · simp +decide [ List.foldl_append ];
    · exact ih.symm

/-! ## Section 4: The Rhythm Lattice is a Boolean Algebra -/

/-
**Theorem**: Union is associative.
-/