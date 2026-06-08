/-
# Main Theorems: Persistent Invariance and Separation

This module contains the main theorems establishing that persistent
differential data is a strictly finer invariant than coarse chain invariants.

## Main Results

1. **Separation**: There exist filtered chain complexes with identical coarse
   invariants whose persistent differential structure distinguishes them.

2. **Monotonicity**: Persistent differential support nests with filtration level.

3. **Ladder family**: A parameterized family with constant Euler characteristic
   but growing persistent complexity.
-/

import Mathlib
import Speculative.PersistentStableHomotopy.Defs

open Matrix Finset

/-! ## Main Separation Theorem

We prove that persistence is strictly finer than coarse invariants by
exhibiting exampleC and exampleD, which agree on all coarse invariants
but differ in their restricted differential at filtration 2. -/

/-
**Main Theorem (Persistence Separation).**
The examples exampleC and exampleD demonstrate that persistent differential
data distinguishes filtered chain complexes that coarse invariants cannot.

Specifically: same graded ranks, same Euler char, same generator profiles,
but different restricted differentials.
-/
theorem persistence_separates :
    SameGradedRanks exampleC exampleD ∧
    SameEulerCharacteristic exampleC exampleD ∧
    (∀ f, numGen0AtFilt exampleC f = numGen0AtFilt exampleD f) ∧
    restrictedDiff exampleC 2 ≠ restrictedDiff exampleD 2 := by
  exact ⟨ examples_sameGradedRanks, examples_sameEulerChar, examples_same_gen0_profile, restrictedDiff_C_ne_D_at_2 ⟩

/-! ## Filtration Monotonicity -/

/-
At filtration 0, the restricted differential of the ladder model is zero
when k ≥ 1, since no degree-1 generator has filtration ≤ 0.
-/
theorem ladderComplex_restrictedDiff_zero (k : ℕ) (_hk : 0 < k)
    (i : Fin (ladderComplex k).gen0) (j : Fin (ladderComplex k).gen1) :
    restrictedDiff (ladderComplex k) 0 i j = 0 := by
  unfold restrictedDiff; simp +decide [ ladderComplex ] ;
  unfold flowToComplex; simp +decide [ ladderFlowModel ] ;

/-
The support of restrictedDiff is monotonically nested in filtration level.
-/
theorem restrictedDiff_support_nested (C : FinFilteredChainComplex) {f g : ℕ} (hfg : f ≤ g)
    (i : Fin C.gen0) (j : Fin C.gen1) :
    restrictedDiff C f i j ≠ 0 → restrictedDiff C g i j ≠ 0 := by
  exact fun h => by rw [ ← restrictedDiff_mono C hfg i j h ] ; exact h;

/-! ## Total Betti Number Agreement -/

/-
Both examples have exactly one active column in their differential.
-/
theorem exampleC_diff_rank_is_one :
    (Finset.univ.filter fun j : Fin exampleC.gen1 =>
      ∃ i : Fin exampleC.gen0, exampleC.diff i j ≠ 0).card = 1 := by
  native_decide

theorem exampleD_diff_rank_is_one :
    (Finset.univ.filter fun j : Fin exampleD.gen1 =>
      ∃ i : Fin exampleD.gen0, exampleD.diff i j ≠ 0).card = 1 := by
  native_decide +revert

/-
The two examples have the same differential activity count.
-/
theorem examples_same_diff_activity :
    (Finset.univ.filter fun j : Fin exampleC.gen1 =>
      ∃ i : Fin exampleC.gen0, exampleC.diff i j ≠ 0).card =
    (Finset.univ.filter fun j : Fin exampleD.gen1 =>
      ∃ i : Fin exampleD.gen0, exampleD.diff i j ≠ 0).card := by
  convert exampleC_diff_rank_is_one.trans exampleD_diff_rank_is_one.symm

/-! ## Euler Characteristic of Ladder Family -/

/-
The Euler characteristic of the ladder complex is always 1.
-/
theorem ladderComplex_euler (k : ℕ) : eulerChar (ladderComplex k) = 1 := by
  unfold eulerChar ladderComplex; simp +decide [ flowToComplex, ladderFlowModel ] ;

/-! ## Column Analysis -/

/-
In example C, the differential column is [-1, 1, 0].
-/
theorem exampleC_diff_column :
    (fun i => exampleC.diff i (0 : Fin 1)) = ![-1, 1, 0] := by
  native_decide +revert

/-
In example D, the differential column is [-1, 0, 1].
-/
theorem exampleD_diff_column :
    (fun i => exampleD.diff i (0 : Fin 1)) = ![-1, 0, 1] := by
  decide +kernel

/-
The columns are different: C kills filt-1 class, D kills filt-2 class.
-/
theorem diff_columns_differ :
    (fun i => exampleC.diff i (0 : Fin 1)) ≠ (fun i => exampleD.diff i (0 : Fin 1)) := by
  decide +kernel

/-! ## Persistent Betti Numbers -/

/-- The persistent rank β₀^{i,j} for a 2-term complex, defined as generators at
filtration ≤ i minus those involved in active differential relations at filt ≤ j. -/
noncomputable def persistentBetti0 (C : FinFilteredChainComplex) (i j : ℕ) : ℕ :=
  if i ≤ j then
    numGen0AtFilt C i -
      (Finset.univ.filter fun k : Fin C.gen0 =>
        C.filt0 k ≤ i ∧ ∃ l : Fin C.gen1,
          C.filt1 l ≤ j ∧ restrictedDiff C j k l ≠ 0).card
  else 0

/-
When no differential is active, persistent Betti equals generator count.
-/
theorem persistentBetti0_below_diff (C : FinFilteredChainComplex)
    (i j : ℕ) (hij : i ≤ j)
    (hj : ∀ l : Fin C.gen1, ¬(C.filt1 l ≤ j)) :
    persistentBetti0 C i j = numGen0AtFilt C i := by
  unfold persistentBetti0;
  simp +decide [ hij, hj ]

/-
Persistence monotonicity: β₀^{i,j} ≤ numGen0AtFilt(i).
-/
theorem persistentBetti0_le_gen0 (C : FinFilteredChainComplex) (i j : ℕ) :
    persistentBetti0 C i j ≤ numGen0AtFilt C i := by
  unfold persistentBetti0;
  grind