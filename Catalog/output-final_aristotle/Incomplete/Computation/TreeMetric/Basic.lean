/-
Copyright (c) 2025. All rights reserved.

# Tree Metric Reconstruction: Basic Properties

Fundamental properties of finite metrics, the four-point condition,
and the LBTree distance function.

## Main results

* `pendantLength_nonneg` - pendant lengths are nonneg under metric axioms
* `pendantLength_symm` - pendant length is symmetric in j,k
* `pendantLength_sum` - sum of two pendant lengths = distance
* `LBTree.dist_self` - tree distance from a leaf to itself is 0
* `LBTree.dist_symm` - tree distance is symmetric (for well-formed trees)
* `LBTree.rootDist_nonneg` - root distances are nonneg for nonneg-weight trees
* `LBTree.numVerts_eq` - numVerts = 2 * numLeaves - 1

## References

* Buneman, P. (1971). The recovery of trees from measures of dissimilarity.
-/

import Logic.Defs

open scoped Matrix
open Classical

noncomputable section

variable {n : ℕ} {D : Matrix (Fin n) (Fin n) ℝ}

/-! ### Basic consequences of IsFiniteMetric -/

theorem IsFiniteMetric.zero_diag (h : IsFiniteMetric D) : ∀ i, D i i = 0 := h.1

theorem IsFiniteMetric.nonneg (h : IsFiniteMetric D) : ∀ i j, 0 ≤ D i j := h.2.1

theorem IsFiniteMetric.symm (h : IsFiniteMetric D) : ∀ i j, D i j = D j i := h.2.2.1

theorem IsFiniteMetric.triangle (h : IsFiniteMetric D) : ∀ i j k, D i k ≤ D i j + D j k :=
  h.2.2.2

/-! ### Pendant length properties -/

/-
The pendant length `(D i j + D i k - D j k) / 2` is nonneg for any finite metric.
-/
theorem pendantLength_nonneg (hm : IsFiniteMetric D) (i j k : Fin n) :
    0 ≤ pendantLength D i j k := by
  exact div_nonneg ( by linarith [ hm.2.2.1 j i, hm.2.2.2 j i k ] ) zero_le_two

/-
The pendant length is symmetric in j and k.
-/
theorem pendantLength_symm (hm : IsFiniteMetric D) (i j k : Fin n) :
    pendantLength D i j k = pendantLength D i k j := by
  -- Rewrite the expression for the pendant length in terms of the symmetric distances.
  unfold pendantLength;
  rw [ hm.2.2.1 j k ] ; ring;

/-
Sum of pendant lengths at two points equals the distance between them.
-/
theorem pendantLength_sum (hm : IsFiniteMetric D) (i j k : Fin n) :
    pendantLength D i j k + pendantLength D j i k = D i j := by
  unfold pendantLength;
  linarith [ hm.2.2.1 i j ]

/-! ### LBTree basic properties -/

namespace LBTree

/-
The number of vertices equals 2 * numLeaves - 1 for any LBTree.
-/
theorem numVerts_eq (t : LBTree) : t.numVerts = 2 * t.numLeaves - 1 := by
  induction' t with wL L wR R ihL ihR <;> simp_all +decide [ LBTree.numLeaves, LBTree.numVerts ];
  have h_numLeaves_pos : ∀ t : LBTree, 0 < t.numLeaves := by
    intro t; induction' t with wL L wR R ihL ihR <;> simp_all +decide [ LBTree.numLeaves ] ;
  exact eq_tsub_of_add_eq ( by linarith [ Nat.sub_add_cancel ( show 1 ≤ 2 * wR.numLeaves from by linarith [ h_numLeaves_pos wR ] ), Nat.sub_add_cancel ( show 1 ≤ 2 * ihL.numLeaves from by linarith [ h_numLeaves_pos ihL ] ) ] )

/-- labels of a leaf is a singleton. -/
@[simp]
theorem labels_leaf (i : ℕ) : (leaf i).labels = {i} := rfl

/-- labels of a branch is the union. -/
@[simp]
theorem labels_branch (wL : ℝ) (L : LBTree) (wR : ℝ) (R : LBTree) :
    (branch wL L wR R).labels = L.labels ∪ R.labels := rfl

/-
rootDist of a leaf at its own label is 0.
-/
theorem rootDist_leaf_self (i : ℕ) : (leaf i).rootDist i = 0 := by
  exact if_pos rfl

/-
rootDist in a branch for a label in the left subtree.
-/
theorem rootDist_branch_left {wL : ℝ} {L : LBTree} {wR : ℝ} {R : LBTree}
    {i : ℕ} (hi : i ∈ L.labels) :
    (branch wL L wR R).rootDist i = L.rootDist i + wL := by
  exact if_pos hi

/-
rootDist in a branch for a label in the right subtree (disjoint from left).
-/
theorem rootDist_branch_right {wL : ℝ} {L : LBTree} {wR : ℝ} {R : LBTree}
    {i : ℕ} (hiL : i ∉ L.labels) (hiR : i ∈ R.labels) :
    (branch wL L wR R).rootDist i = R.rootDist i + wR := by
  exact if_neg hiL |> fun h => h.trans ( if_pos hiR )

/-
rootDist is nonneg for trees with nonneg weights.
-/
theorem rootDist_nonneg (t : LBTree) (hw : t.NonnegWeights) (i : ℕ) :
    0 ≤ t.rootDist i := by
  have h_ind : ∀ (t : LBTree) (i : ℕ), t.NonnegWeights → 0 ≤ t.rootDist i := by
    -- We proceed by induction on the structure of the tree.
    intro t i ht
    induction' t with wL L wR R ihL ihR generalizing i;
    · exact by unfold LBTree.rootDist; aesop;
    · by_cases hi : i ∈ wR.labels <;> simp_all +decide [ LBTree.rootDist ];
      · exact add_nonneg ( ihR i ht.2.2.1 ) ht.1;
      · split_ifs <;> simp_all +decide [ LBTree.NonnegWeights ];
        linarith [ ‹∀ i, 0 ≤ ihL.rootDist i› i ];
  exact h_ind t i hw

/-
Distance from a leaf to itself is 0.
-/
theorem dist_self_of_mem (t : LBTree) (hw : t.WellFormed) (i : ℕ)
    (_hi : i ∈ t.labels) : t.dist i i = 0 := by
  have hw : t.NonnegWeights := hw.2
  have h_dist_self : ∀ t : LBTree, t.NonnegWeights → ∀ i : ℕ, t.dist i i = 0 := by
    intro t hw i
    induction' t with t ih generalizing i;
    · rfl;
    · unfold LBTree.dist;
      cases hw ; aesop;
  exact h_dist_self t hw i

/-
Distance between labels in the left subtree equals left subtree distance.
-/
theorem dist_branch_left {wL : ℝ} {L : LBTree} {wR : ℝ} {R : LBTree}
    {i j : ℕ} (hi : i ∈ L.labels) (hj : j ∈ L.labels) :
    (branch wL L wR R).dist i j = L.dist i j := by
  exact if_pos ⟨ hi, hj ⟩

/-
Distance between labels in different subtrees (with disjointness).
-/
theorem dist_branch_cross {wL : ℝ} {L : LBTree} {wR : ℝ} {R : LBTree}
    {i j : ℕ} (hi : i ∈ L.labels) (hiR : i ∉ R.labels)
    (hjL : j ∉ L.labels) (hjR : j ∈ R.labels) :
    (branch wL L wR R).dist i j = L.rootDist i + wL + wR + R.rootDist j := by
  -- By definition of `dist`, the distance in a branch is the sum of the distances in the left and right subtrees plus the edge weights.
  simp [LBTree.dist, hi, hiR, hjL, hjR]

/-
Tree distance is nonneg for well-formed trees with nonneg weights.
-/
theorem dist_nonneg (t : LBTree) (hw : t.WellFormed) (i j : ℕ)
    (hi : i ∈ t.labels) (hj : j ∈ t.labels) :
    0 ≤ t.dist i j := by
  -- By definition of `LBTree.dist`, we know that `t.dist i j` is nonnegative if `t` is well-formed.
  have h_dist_nonneg : ∀ (t : LBTree) (hw : t.WellFormed) (i j : ℕ) (hi : i ∈ t.labels) (hj : j ∈ t.labels), 0 ≤ t.dist i j := by
    intros t ht i j hi hj
    induction' t with wL L wR R ihL ihR generalizing i j;
    · exact le_rfl;
    · cases ht ; simp_all +decide [ LBTree.labels ];
      cases ‹ ( branch L wR R ihL ).DistinctLabels › ; cases ‹ ( branch L wR R ihL ).NonnegWeights › ; simp_all +decide [ LBTree.dist ];
      split_ifs <;> simp_all +decide [ Finset.disjoint_left ];
      · exact ihR ⟨ by tauto, by tauto ⟩ i j ( by tauto ) ( by tauto );
      · exact ‹ihL.WellFormed → ∀ i j : ℕ, i ∈ ihL.labels → j ∈ ihL.labels → 0 ≤ ihL.dist i j› ⟨ by tauto, by tauto ⟩ i j ( by tauto ) ( by tauto );
      · exact add_nonneg ( add_nonneg ( add_nonneg ( rootDist_nonneg _ ( by tauto ) _ ) ( by linarith ) ) ( by linarith ) ) ( rootDist_nonneg _ ( by tauto ) _ );
      · exact add_nonneg ( add_nonneg ( add_nonneg ( rootDist_nonneg _ ( by tauto ) _ ) ( by linarith ) ) ( by linarith ) ) ( rootDist_nonneg _ ( by tauto ) _ );
  exact h_dist_nonneg t hw i j hi hj

end LBTree

end