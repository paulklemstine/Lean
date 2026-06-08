/-
# Fiber Graph Theorems

Core theorems about fiber graphs in Hamming spaces, including the
Bridge Duality Theorem, fiber partition properties, and connectivity criteria.
-/
import Mathlib
import Novelty.FiberGraph.Defs

open Finset BigOperators Function

namespace FiberGraph

variable {n q : ℕ} {G : Type*} [AddCommGroup G] [DecidableEq G] [DecidableEq (Fin q)]

/-! ## Score Decomposition -/

/-
The score of a modified configuration decomposes as the original score
    plus the score delta at the modified position.
-/
theorem score_modify (w : WeightSystem n q G) (x : Config n q) (i : Fin n) (a : Fin q) :
    additiveScore w (modify x i a) = additiveScore w x + scoreDelta w i (x i) a := by
  unfold additiveScore scoreDelta modify;
  rw [ Finset.sum_eq_add_sum_diff_singleton ( Finset.mem_univ i ) ];
  rw [ Finset.sum_congr rfl fun j hj => by rw [ Function.update_of_ne ( by aesop ) ] ] ; simp +decide [ add_comm, add_left_comm, add_assoc ];
  abel1

/-! ## Bridge Duality -/

/-
**Bridge Duality Theorem**: For two configurations with equal additive score
    that differ at exactly two positions i and j, the existence of a score-preserving
    bridge through position i is equivalent to a bridge through position j.

    This is the central result: fiber disconnection in additive scoring is not
    a local phenomenon at one position, but a global constraint linking all
    differing positions symmetrically.
-/
theorem bridge_duality (w : WeightSystem n q G) (x y : Config n q)
    (i j : Fin n) (hij : i ≠ j)
    (hdiff : diffPositions x y = {i, j})
    (hscore : additiveScore w x = additiveScore w y) :
    bridgeThrough w x y i ↔ bridgeThrough w x y j := by
  constructor <;> rintro ⟨ z, hz₁, hz₂, hz₃ ⟩;
  · -- By score_modify, additiveScore w z = additiveScore w x + scoreDelta w i (x i) (y i). So bridgeThrough w x y i ↔ scoreDelta w i (x i) (y i) = 0 ↔ w i (y i) = w i (x i).
    have h_score_delta_i : w i (y i) = w i (x i) := by
      have h_score_delta_i : additiveScore w z = additiveScore w x + (w i (z i) - w i (x i)) := by
        convert score_modify w x i ( z i ) using 1;
        exact congr_arg _ ( funext fun k => if hk : k = i then hk.symm ▸ by simp +decide [ modify ] else hz₁ k hk ▸ by simp +decide [ modify, hk ] );
      grind +locals;
    refine' ⟨ Function.update x j ( y j ), _, _, _ ⟩ <;> simp_all +decide [ Finset.ext_iff ];
    convert score_modify w x j ( y j ) using 1;
    simp +decide [ scoreDelta, hscore ];
    have h_score_delta_j : ∑ k ∈ Finset.univ \ {i, j}, w k (x k) = ∑ k ∈ Finset.univ \ {i, j}, w k (y k) := by
      exact Finset.sum_congr rfl fun k hk => by specialize hdiff k; unfold diffPositions at hdiff; aesop;
    simp_all +decide [ Finset.sum_pair hij, additiveScore ];
  · -- By definition of `scoreDelta`, we know that `scoreDelta w j (x j) (y j) = 0`.
    have h_scoreDelta_j : scoreDelta w j (x j) (y j) = 0 := by
      have h_scoreDelta_j : additiveScore w z = additiveScore w x + scoreDelta w j (x j) (z j) := by
        convert score_modify w x j ( z j ) using 1;
        congr ; ext k ; by_cases hk : k = j <;> simp +decide [ * ];
        · simp +decide [ modify ];
        · unfold modify; aesop;
      aesop;
    -- By definition of `scoreDelta`, we know that `scoreDelta w i (x i) (y i) = 0`.
    have h_scoreDelta_i : scoreDelta w i (x i) (y i) = 0 := by
      unfold scoreDelta at *; simp_all +decide [ Finset.ext_iff, diffPositions ] ;
      have h_scoreDelta_i : ∑ k ∈ Finset.univ \ {i, j}, w k (x k) = ∑ k ∈ Finset.univ \ {i, j}, w k (y k) := by
        exact Finset.sum_congr rfl fun k hk => by specialize hdiff k; aesop;
      simp_all +decide [ additiveScore, Finset.sum_sub_distrib, sub_eq_zero ];
    refine' ⟨ Function.update x i ( y i ), _, _, _ ⟩ <;> simp_all +decide [ Function.update_apply ];
    convert score_modify w x i ( y i ) using 1;
    rw [ hscore, h_scoreDelta_i, add_zero ]

/-! ## Fiber Partition -/

/-
Fibers are pairwise disjoint: no configuration belongs to two distinct fibers.
-/
omit [DecidableEq G] [DecidableEq (Fin q)] in
theorem fiber_disjoint (w : WeightSystem n q G) (v₁ v₂ : G) (hne : v₁ ≠ v₂) :
    Disjoint (fiber w v₁) (fiber w v₂) := by
  exact Set.disjoint_left.mpr fun x hx₁ hx₂ => hne <| hx₁.symm.trans hx₂

/-
Score modification is self-inverse: modifying position i twice returns to original.
-/
omit [DecidableEq G] [DecidableEq (Fin q)] in
theorem modify_modify_cancel (x : Config n q) (i : Fin n) (a : Fin q) :
    modify (modify x i a) i (x i) = x := by
  unfold modify; aesop;

/-! ## Score Delta Algebra -/

/-
Score deltas are antisymmetric: δ(a→b) = -δ(b→a).
-/
omit [DecidableEq G] [DecidableEq (Fin q)] in
theorem scoreDelta_antisymm (w : WeightSystem n q G) (i : Fin n) (a b : Fin q) :
    scoreDelta w i a b = -scoreDelta w i b a := by
  unfold scoreDelta; abel1;

/-
Score deltas are additive: δ(a→c) = δ(a→b) + δ(b→c).
-/
omit [DecidableEq G] [DecidableEq (Fin q)] in
theorem scoreDelta_add (w : WeightSystem n q G) (i : Fin n) (a b c : Fin q) :
    scoreDelta w i a c = scoreDelta w i a b + scoreDelta w i b c := by
  unfold scoreDelta; abel

/-
The identity delta is zero.
-/
omit [DecidableEq G] [DecidableEq (Fin q)] in
theorem scoreDelta_self (w : WeightSystem n q G) (i : Fin n) (a : Fin q) :
    scoreDelta w i a a = 0 := by
  exact sub_self _

/-! ## Bridge Characterization -/

/-
Fiber adjacency is symmetric.
-/
omit [DecidableEq G] [DecidableEq (Fin q)] in
theorem fiberAdj_symm (w : WeightSystem n q G) (x y : Config n q) :
    fiberAdj w x y → fiberAdj w y x := by
  unfold fiberAdj;
  simp +contextual [ hammingAdj, eq_comm ]

/-
The modify operation preserves scores when the delta is zero.
-/
theorem modify_preserves_score (w : WeightSystem n q G) (x : Config n q)
    (i : Fin n) (a : Fin q) (h : w i a = w i (x i)) :
    additiveScore w (modify x i a) = additiveScore w x := by
  -- Apply the score modification theorem and then use h to replace the delta with zero.
  rw [score_modify, scoreDelta]
  simp [h]

/-! ## Fiber Expansion -/

/-- Weight system is position-separating: at each position, distinct symbols
    have distinct weights. -/
def PositionSeparating (w : WeightSystem n q G) : Prop :=
  ∀ i : Fin n, Function.Injective (w i)

/-
For a position-separating weight system, if two configurations agree at all
    positions except i, they have the same score iff they are identical.
-/
omit [DecidableEq G] [DecidableEq (Fin q)] in
theorem eq_of_agree_except_one_same_score
    (w : WeightSystem n q G) (hsep : PositionSeparating w)
    (x y : Config n q) (i : Fin n)
    (hagree : ∀ k : Fin n, k ≠ i → x k = y k)
    (hscore : additiveScore w x = additiveScore w y) :
    x = y := by
  -- Since x and y agree at all positions except possibly i, their scores differ by w i (x i) vs w i (y i).
  have hscore_diff : ∑ k ∈ Finset.univ.erase i, w k (x k) = ∑ k ∈ Finset.univ.erase i, w k (y k) := by
    exact Finset.sum_congr rfl fun k hk => by aesop;
  unfold additiveScore at hscore; simp_all +decide ;
  exact funext fun k => if hk : k = i then hk.symm ▸ hsep i hscore_diff else hagree k hk

/-! ## Hamming Distance -/

/-- Hamming distance between two configurations. -/
noncomputable def hammingDist (x y : Config n q) : ℕ :=
  (diffPositions x y).card

/-
Hamming distance is symmetric.
-/
theorem hammingDist_symm (x y : Config n q) :
    hammingDist x y = hammingDist y x := by
  unfold hammingDist;
  unfold diffPositions; congr; ext; aesop;

/-
Hamming distance is zero iff configurations are equal.
-/
theorem hammingDist_eq_zero_iff (x y : Config n q) :
    hammingDist x y = 0 ↔ x = y := by
  simp +decide [ hammingDist, diffPositions ];
  exact ⟨ fun h => funext h, fun h => h ▸ fun _ => rfl ⟩

/-! ## Connectivity via Weight Overlap -/

/-- Weight overlap at position i: symbol a has a "match" if there exists
    another symbol b with the same weight. -/
def hasWeightMatch (w : WeightSystem n q G) (i : Fin n) (a : Fin q) : Prop :=
  ∃ b : Fin q, b ≠ a ∧ w i b = w i a

/-
**Score Swap Lemma**: If positions i and j have matching weights for
    the relevant symbols, then modifying at both positions with weight-preserving
    symbols preserves the score.
-/
omit [DecidableEq G] [DecidableEq (Fin q)] in
theorem score_swap_via_matches
    (w : WeightSystem n q G) (x : Config n q)
    (i j : Fin n) (_hij : i ≠ j)
    (ai : Fin q) (aj : Fin q)
    (hmi : w i ai = w i (x i))
    (hmj : w j aj = w j (x j)) :
    additiveScore w (modify (modify x i ai) j aj) = additiveScore w x := by
  unfold additiveScore modify at *;
  grind

end FiberGraph