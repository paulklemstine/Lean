import Mathlib

/-!
# One-hot pitch classes and Vietoris--Rips filtrations

This file isolates a limitation of the proposed 12-dimensional one-hot point-cloud model.
The proofs apply to any finite collection of pitch classes.  Distinct one-hot vectors are
all at the same squared Euclidean distance, so their Vietoris--Rips filtration jumps directly
from isolated vertices to a full simplex.  In particular, the order around the circle of
fifths cannot be recovered from a point cloud consisting only of one-hot pitch classes.
-/

namespace PersistentHarmony

/-- The one-hot integral vector representing an element of a finite pitch-class type. -/
def oneHot {ι : Type*} [DecidableEq ι] (i : ι) : ι → ℤ :=
  fun j => if i = j then 1 else 0

/-- Squared Euclidean distance, before taking a square root. -/
def squaredDistance {ι : Type*} [Fintype ι] (x y : ι → ℤ) : ℤ :=
  ∑ j, (x j - y j) ^ 2

/-
The squared distance from a one-hot pitch class to itself is zero.
-/
theorem squaredDistance_oneHot_self {ι : Type*} [Fintype ι] [DecidableEq ι]
    (i : ι) : squaredDistance (oneHot i) (oneHot i) = 0 := by
  simp +decide [ squaredDistance ]

/-
Distinct one-hot pitch classes have squared Euclidean distance exactly two.
-/
theorem squaredDistance_oneHot_of_ne {ι : Type*} [Fintype ι] [DecidableEq ι]
    {i j : ι} (hij : i ≠ j) : squaredDistance (oneHot i) (oneHot j) = 2 := by
  unfold oneHot squaredDistance
  rw [Finset.sum_eq_add i j] <;> simp +decide [hij, eq_comm]
  grind

/-
At scale `r`, two distinct one-hot pitch classes form a Rips edge exactly when `2 ≤ r`.
-/
theorem oneHot_ripsEdge_iff {ι : Type*} [Fintype ι] [DecidableEq ι]
    {i j : ι} (hij : i ≠ j) (r : ℤ) :
    squaredDistance (oneHot i) (oneHot j) ≤ r ↔ 2 ≤ r := by
  rw [ squaredDistance_oneHot_of_ne hij ]

/-
Once one edge between distinct one-hot points appears, every distinct pair is an edge.
-/
theorem oneHot_edge_forces_complete {ι : Type*} [Fintype ι] [DecidableEq ι]
    {i j : ι} (hij : i ≠ j) (r : ℤ)
    (hedge : squaredDistance (oneHot i) (oneHot j) ≤ r) :
    ∀ {k l : ι}, k ≠ l → squaredDistance (oneHot k) (oneHot l) ≤ r := by
  intro k l hkl
  have hr : 2 ≤ r := (oneHot_ripsEdge_iff hij r).mp hedge
  exact (oneHot_ripsEdge_iff hkl r).mpr hr

/-- A finite set is a simplex in the Vietoris--Rips complex when all its distinct pairs
are within the squared-distance threshold. -/
def IsRipsSimplex {ι : Type*} [Fintype ι] [DecidableEq ι]
    (r : ℤ) (s : Finset ι) : Prop :=
  ∀ ⦃i⦄, i ∈ s → ∀ ⦃j⦄, j ∈ s → i ≠ j →
    squaredDistance (oneHot i) (oneHot j) ≤ r

/-
Below squared scale two, the only Rips simplices of one-hot points are vertices and the
empty simplex.  At scale two and above, every finite set is a simplex.
-/
theorem oneHot_ripsSimplex_iff {ι : Type*} [Fintype ι] [DecidableEq ι]
    (r : ℤ) (s : Finset ι) :
    IsRipsSimplex r s ↔ s.card ≤ 1 ∨ 2 ≤ r := by
  constructor
  · contrapose!
    intro h
    obtain ⟨i, hi, j, hj, hij⟩ := Finset.one_lt_card.mp h.1
    exact fun H => by
      have := H hi hj hij
      linarith [squaredDistance_oneHot_of_ne hij]
  · rintro (h | h) i hi j hj hij
    · exact False.elim (hij (Finset.card_le_one.mp h i hi j hj))
    · exact le_trans (by rw [squaredDistance_oneHot_of_ne hij]) h

/-
Four distinct one-hot points cannot form an induced four-cycle at any Rips scale:
whenever the four cycle edges exist, both diagonals exist as well.
-/
theorem no_induced_four_cycle_oneHot {ι : Type*} [Fintype ι] [DecidableEq ι]
    {a b c d : ι} (hab : a ≠ b) (hac : a ≠ c) (r : ℤ)
    (habEdge : squaredDistance (oneHot a) (oneHot b) ≤ r)
    (_hbcEdge : squaredDistance (oneHot b) (oneHot c) ≤ r)
    (_hcdEdge : squaredDistance (oneHot c) (oneHot d) ≤ r)
    (_hdaEdge : squaredDistance (oneHot d) (oneHot a) ≤ r) :
    squaredDistance (oneHot a) (oneHot c) ≤ r := by
  apply oneHot_edge_forces_complete hab r habEdge
  exact hac

/-
Specialization to the chromatic pitch-class space: the Rips filtration on the twelve
one-hot pitch classes has only the two regimes described above.
-/
theorem chromatic_oneHot_filtration_dichotomy (r : ℤ) (s : Finset (Fin 12)) :
    IsRipsSimplex r s ↔ s.card ≤ 1 ∨ 2 ≤ r := by
  convert oneHot_ripsSimplex_iff r s using 1

end PersistentHarmony