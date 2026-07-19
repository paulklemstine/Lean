import Mathlib

/-!
# Point-cloud invariance under musical reordering

A persistent-homology computation on the unordered set of observed chords cannot detect the
order in which those chords occur.  This file makes that information-loss precise for arbitrary
chord representations, independently of the chosen metric or homology implementation.
-/

namespace PersistentHarmony

/-- The point cloud underlying a chord sequence: repetitions and temporal order are discarded. -/
def chordCloud {Chord : Type*} [DecidableEq Chord] (song : List Chord) : Finset Chord :=
  song.toFinset

/-
Reversing a song leaves its chord point cloud unchanged.
-/
theorem chordCloud_reverse {Chord : Type*} [DecidableEq Chord] (song : List Chord) :
    chordCloud song.reverse = chordCloud song := by
  unfold chordCloud
  ext chord
  simp

/-
Moving a prefix to the end (a cyclic rotation) leaves the chord point cloud unchanged.
-/
theorem chordCloud_rotate {Chord : Type*} [DecidableEq Chord] (xs ys : List Chord) :
    chordCloud (xs ++ ys) = chordCloud (ys ++ xs) := by
  simp +decide [chordCloud, List.toFinset_append]
  exact Finset.union_comm _ _

/-
Any invariant computed solely from the chord point cloud is unchanged by reversal.
-/
theorem pointCloudInvariant_reverse {Chord Result : Type*} [DecidableEq Chord]
    (invariant : Finset Chord → Result) (song : List Chord) :
    invariant (chordCloud song.reverse) = invariant (chordCloud song) := by
  exact congrArg invariant (chordCloud_reverse song)

/-
Any invariant computed solely from the chord point cloud is unchanged by cyclic rotation.
-/
theorem pointCloudInvariant_rotate {Chord Result : Type*} [DecidableEq Chord]
    (invariant : Finset Chord → Result) (xs ys : List Chord) :
    invariant (chordCloud (xs ++ ys)) =
      invariant (chordCloud (ys ++ xs)) := by
  rw [chordCloud_rotate xs ys]

/-
Combining the previous results, a point-cloud statistic assigns the same result to a song,
its reversal, and every decomposition-based cyclic rotation.
-/
theorem pointCloudInvariant_order_blind {Chord Result : Type*} [DecidableEq Chord]
    (invariant : Finset Chord → Result) (xs ys : List Chord) :
    invariant (chordCloud (xs ++ ys).reverse) =
      invariant (chordCloud (ys ++ xs)) := by
  rw [← pointCloudInvariant_rotate invariant xs ys,
    pointCloudInvariant_reverse invariant (xs ++ ys)]

end PersistentHarmony