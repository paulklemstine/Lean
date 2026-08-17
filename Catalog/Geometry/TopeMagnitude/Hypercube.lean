import Mathlib
import Geometry.RamseyTheory.FlagComplex

/-!
# Sign vectors, hyperplane separation, and the coordinate tope graph

A chamber of the coordinate hyperplane arrangement is a sign vector.  Crossing a
wall changes one sign, so its tope graph is the Boolean hypercube.  The results
below isolate two structural ingredients used in magnitude-homological
computations: wall separation gives the graph metric, and metric spheres are
counted by the Boolean face numbers.

-- !-- Lab Notes -- !--
Hypothesis: the distance between two coordinate chambers is exactly the number of
hyperplanes separating them, and the chambers at distance `k` are naturally the
`k`-faces of the Boolean simplex.
Experiment: encode chambers by Boolean sign vectors and wall sets by finite subsets.
The flip operation was tested in dimensions zero through five; sphere rows are
`[1]`, `[1,1]`, `[1,2,1]`, `[1,3,3,1]`, `[1,4,6,4,1]`, and
`[1,5,10,10,5,1]`.
Analysis: every changed coordinate forces a crossing, while flipping precisely the
separating coordinates realizes the lower bound.  Thus geometric distance and
Boolean rank coincide.
Critique: this proves the complete coordinate-arrangement case, not the general
Edelman--Walker or Alexander-duality step.  No realizability assumption is hidden:
all statements concern the explicitly defined coordinate arrangement.
Synthesis: `hamming_triangle`, `flip_hamming`, and `sphere_card` provide a reusable
metric-enumerative bridge.  The imported flag-complex theory identifies the full
simplex as the clique complex of its complete one-skeleton.
-- !-- Lab Notes -- !--
-/

open Finset

namespace TopeMagnitude

/-- The set of coordinate hyperplanes separating two sign vectors. -/
def separatingWalls {n : ℕ} (x y : Fin n → Bool) : Finset (Fin n) :=
  Finset.univ.filter fun i => x i ≠ y i

/-- Hamming distance, interpreted as the number of separating hyperplanes. -/
def hamming {n : ℕ} (x y : Fin n → Bool) : ℕ := (separatingWalls x y).card

@[simp] theorem separatingWalls_self {n : ℕ} (x : Fin n → Bool) :
    separatingWalls x x = ∅ := by
  ext i
  simp [separatingWalls]

@[simp] theorem hamming_self {n : ℕ} (x : Fin n → Bool) : hamming x x = 0 := by
  rw [hamming, separatingWalls_self]
  rfl

/-
Separation is symmetric in the two chambers.
-/
theorem hamming_comm {n : ℕ} (x y : Fin n → Bool) : hamming x y = hamming y x := by
  exact congr_arg Finset.card ( Finset.filter_congr fun i _ => by simp +decide [ ne_comm ] )

/-
A wall separating the endpoints separates at least one of the two successive
pairs.  This is the coordinate form of the wall-crossing lower bound.
-/
theorem separatingWalls_subset_union {n : ℕ} (x y z : Fin n → Bool) :
    separatingWalls x z ⊆ separatingWalls x y ∪ separatingWalls y z := by
  intro i hi; by_cases hi' : x i = y i <;> by_cases hi'' : y i = z i <;> simp_all +decide [ separatingWalls ] ;

/-
The number of separating hyperplanes satisfies the triangle inequality.
-/
theorem hamming_triangle {n : ℕ} (x y z : Fin n → Bool) :
    hamming x z ≤ hamming x y + hamming y z := by
  exact Finset.card_le_card ( separatingWalls_subset_union x y z ) |> le_trans <| Finset.card_union_le _ _

/-- Flip exactly the signs indexed by `s`. -/
def flip {n : ℕ} (x : Fin n → Bool) (s : Finset (Fin n)) : Fin n → Bool :=
  fun i => if i ∈ s then !x i else x i

/-- Flipping signs records exactly the chosen separating walls. -/
theorem separatingWalls_flip {n : ℕ} (x : Fin n → Bool) (s : Finset (Fin n)) :
    separatingWalls x (flip x s) = s := by
  ext i
  simp [separatingWalls, flip]

/-
The wall-set map reconstructs every chamber from a fixed base chamber.
-/
theorem flip_separatingWalls {n : ℕ} (x y : Fin n → Bool) :
    flip x (separatingWalls x y) = y := by
  ext i; by_cases hi : x i = y i <;> simp_all +decide [ flip, separatingWalls ] ;
  cases h : x i <;> cases h' : y i <;> simp_all +decide only

/-- Distance from a chamber after flipping a wall set is the cardinality of that
wall set. -/
theorem flip_hamming {n : ℕ} (x : Fin n → Bool) (s : Finset (Fin n)) :
    hamming x (flip x s) = s.card := by
  rw [hamming, separatingWalls_flip]

/-- Sign vectors are canonically equivalent to their sets of separating walls from
any chosen base chamber. -/
noncomputable def chamberWallEquiv {n : ℕ} (x : Fin n → Bool) :
    (Fin n → Bool) ≃ Finset (Fin n) where
  toFun := separatingWalls x
  invFun := flip x
  left_inv := flip_separatingWalls x
  right_inv := separatingWalls_flip x

/-- A metric sphere in the coordinate tope graph. -/
def sphere {n : ℕ} (x : Fin n → Bool) (k : ℕ) :=
  {y : Fin n → Bool // hamming x y = k}

noncomputable instance sphereFintype {n : ℕ} (x : Fin n → Bool) (k : ℕ) :
    Fintype (sphere x k) := by
  classical
  unfold sphere
  infer_instance

/-
**Boolean sphere theorem.**  There are `n choose k` chambers separated from a
fixed chamber by exactly `k` coordinate hyperplanes.
-/
theorem sphere_card {n k : ℕ} (x : Fin n → Bool) :
    Fintype.card (sphere x k) = n.choose k := by
  rw [ Fintype.card_eq_nat_card ];
  have h_card : Nat.card {y : Fin n → Bool | hamming x y = k} = Nat.choose n k := by
    rw [ show { y : Fin n → Bool | hamming x y = k } = ( Finset.image ( fun s : Finset ( Fin n ) => flip x s ) ( Finset.powersetCard k Finset.univ ) ) from ?_, Nat.card_eq_fintype_card ];
    · erw [ Fintype.card_coe, Finset.card_image_of_injective ];
      · simp +decide [ Finset.card_univ ];
      · intro s t h; have := congr_fun h; simp_all +decide [ funext_iff, flip ] ;
        grind;
    · ext y; simp [hamming];
      constructor;
      · exact fun h => ⟨ separatingWalls x y, h, flip_separatingWalls x y ⟩;
      · rintro ⟨ s, rfl, rfl ⟩ ; simp +decide [ separatingWalls_flip ] ;
  convert h_card using 1

/-- The distance distribution of the coordinate tope graph is independent of the
base chamber. -/
theorem sphere_card_base_independent {n k : ℕ} (x y : Fin n → Bool) :
    Fintype.card (sphere x k) = Fintype.card (sphere y k) := by
  rw [sphere_card, sphere_card]

/-
The total number of coordinate chambers is recovered by summing its metric
spheres.
-/
theorem sum_sphere_card {n : ℕ} (x : Fin n → Bool) :
    ∑ k ∈ Finset.range (n + 1), Fintype.card (sphere x k) = 2 ^ n := by
  rw [ Finset.sum_congr rfl fun k hk => by rw [ sphere_card ] ];
  rw [ ← Nat.sum_range_choose ]

end TopeMagnitude