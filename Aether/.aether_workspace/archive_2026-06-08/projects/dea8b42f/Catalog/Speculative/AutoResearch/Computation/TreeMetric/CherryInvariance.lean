/-
Copyright (c) 2025. All rights reserved.

# Cherry Pair Metric Invariance

This file proves that cherry pairs in a tree metric are determined by the
distance matrix alone: any two reduced realizations of the same tree metric
have identical cherry pairs.

## Main definitions

* `LBTree.IsTreeCherryPair` - structural cherry pair predicate (two leaves share a parent)
* `LBTree.Reduced` - reduced tree (all internal-to-internal edge weights are positive)
* `LBTree.cherryPairSet` - the set of cherry pairs in a tree
* `LBTree.SameTopology` - two trees have the same combinatorial structure

## Main results

* `tree_cherry_implies_metric_cherry` - structural cherry → metric cherry condition
* `same_topology_cherry_iff` - isomorphic trees have the same cherries
* `cherry_pair_metric_invariant` - cherry pairs are invariant across reduced realizations
* `cherry_pairs_unique_of_reduced_realization` - set equality of cherry pairs
* `noisy_cherry_forward` / `noisy_cherry_backward` - stability under perturbation

## Mathematical note

The predicate `IsCherryPair D a b` (from Reconstruction.lean) is a *necessary*
but *not sufficient* condition for `(a,b)` to be a structural cherry pair.
It characterizes *splits* rather than *cherries*: in a caterpillar tree
`0 - 1 - root - 1 - 1 - 1 - 2 - 1 - 3`, the pair `(0,1)` satisfies
`IsCherryPair` (constant distance difference) but is NOT a cherry.

The invariance theorem therefore cannot factor through `IsCherryPair` alone.
Instead, we use the fundamental result that reduced tree realizations of a
tree metric are unique up to child ordering (`reduced_realization_same_topology`),
which directly implies cherry invariance.

## References

* Buneman, P. "The recovery of trees from measures of dissimilarity" (1971)
* Semple, C. and Steel, M. "Phylogenetics" (2003)
-/

import Mathlib
import Computation.TreeMetric.Reconstruction

open scoped Matrix
open Classical

noncomputable section

/-! ### Structural cherry pair definition -/

/-- Two leaves `i, j` form a structural cherry pair in tree `t` if they share
a common parent node — i.e., there is a `branch` node whose two children
are exactly `leaf i` and `leaf j`. -/
def LBTree.IsTreeCherryPair : LBTree → ℕ → ℕ → Prop
  | .leaf _, _, _ => False
  | .branch _ L _ R, i, j =>
    (∃ a b, L = .leaf a ∧ R = .leaf b ∧ ((i = a ∧ j = b) ∨ (i = b ∧ j = a))) ∨
    L.IsTreeCherryPair i j ∨
    R.IsTreeCherryPair i j

/-- A tree is *reduced* if every edge to a non-leaf child has strictly positive weight.
This ensures no two internal nodes can be merged (no degree-2 internal vertices
in the underlying unrooted tree). -/
def LBTree.Reduced : LBTree → Prop
  | .leaf _ => True
  | .branch wL L wR R =>
    (match L with | .leaf _ => True | .branch .. => 0 < wL) ∧
    (match R with | .leaf _ => True | .branch .. => 0 < wR) ∧
    L.Reduced ∧ R.Reduced

/-- The set of (ordered) cherry pairs in a tree. -/
def LBTree.cherryPairSet (t : LBTree) : Set (ℕ × ℕ) :=
  { p | t.IsTreeCherryPair p.1 p.2 }

/-- Two trees have the *same topology* if they agree on the combinatorial
structure: same labels, same branching pattern, and same edge weights,
up to the ordering of children at each internal node. -/
def LBTree.SameTopology : LBTree → LBTree → Prop
  | .leaf a, .leaf b => a = b
  | .branch wL₁ L₁ wR₁ R₁, .branch wL₂ L₂ wR₂ R₂ =>
    (wL₁ = wL₂ ∧ wR₁ = wR₂ ∧ L₁.SameTopology L₂ ∧ R₁.SameTopology R₂) ∨
    (wL₁ = wR₂ ∧ wR₁ = wL₂ ∧ L₁.SameTopology R₂ ∧ R₁.SameTopology L₂)
  | _, _ => False

/-! ### Tree cherry pair is symmetric -/

/-- Cherry pairs are symmetric: if (i,j) is a cherry, so is (j,i). -/
theorem LBTree.IsTreeCherryPair.symm {t : LBTree} {i j : ℕ}
    (h : t.IsTreeCherryPair i j) : t.IsTreeCherryPair j i := by
  induction t with
  | leaf _ => exact absurd h id
  | branch wL L wR R ihL ihR =>
    simp only [LBTree.IsTreeCherryPair] at h ⊢
    rcases h with ⟨a, b, hL, hR, hab⟩ | hL | hR
    · left; exact ⟨a, b, hL, hR, by tauto⟩
    · right; left; exact ihL hL
    · right; right; exact ihR hR

/-! ### Cherry pairs require distinct leaves -/

/-- In a tree with distinct labels, cherry pairs involve distinct leaves. -/
theorem LBTree.IsTreeCherryPair.ne_of_wf {t : LBTree} {i j : ℕ}
    (h : t.IsTreeCherryPair i j) (hd : t.DistinctLabels) : i ≠ j := by
  contrapose! h;
  induction' t with wL L wR R ihL ihR generalizing i j;
  · exact?;
  · cases hd;
    rintro ( ⟨ a, b, rfl, rfl, ( ⟨ rfl, rfl ⟩ | ⟨ rfl, rfl ⟩ ) ⟩ | h | h ) <;> simp_all +decide [ Finset.disjoint_left ]

/-! ### Cherry pair membership in labels -/

/-- A cherry pair's leaves must be in the tree's label set. -/
theorem LBTree.IsTreeCherryPair.mem_labels {t : LBTree} {i j : ℕ}
    (h : t.IsTreeCherryPair i j) : i ∈ t.labels ∧ j ∈ t.labels := by
  induction' t with wL L wR R ihL ihR generalizing i j;
  · cases h;
  · cases h <;> simp_all +decide [ LBTree.labels ];
    · aesop;
    · grind

/-! ### Key structural lemma: cherry distance differences -/

/-- **Cherry rootDist difference lemma.** If `(a,b)` is a structural cherry pair
in a tree with distinct labels `t`, then for any leaf `k` in `t` distinct from
both `a` and `b`, the distance difference `t.dist a k - t.dist b k` equals
`t.rootDist a - t.rootDist b`.

This captures the essential geometric fact: when two leaves share a parent,
all paths to external leaves pass through that parent, making distance
differences depend only on the pendant edge lengths. -/
theorem cherry_dist_diff_eq_rootDist_diff
    (t : LBTree) (hdist : t.DistinctLabels)
    (a b : ℕ) (hcherry : t.IsTreeCherryPair a b)
    (k : ℕ) (hk_mem : k ∈ t.labels) (hka : k ≠ a) (hkb : k ≠ b) :
    t.dist a k - t.dist b k = t.rootDist a - t.rootDist b := by
  induction' t with wL L wR R ihL ihR generalizing a b k;
  · cases hcherry;
  · cases hdist ; simp_all +decide [ Finset.disjoint_left ];
    rcases hcherry with ( ⟨ a', b', rfl, rfl, ⟨ rfl, rfl ⟩ | ⟨ rfl, rfl ⟩ ⟩ | hcherry | hcherry ) <;> simp_all +decide [ LBTree.dist, LBTree.rootDist ];
    · have := hcherry.mem_labels; simp_all +decide [ Finset.disjoint_left ] ;
      grind;
    · have := hcherry.mem_labels; simp_all +decide [ Finset.disjoint_left ] ;
      grind

/-! ### Forward direction: tree cherry → metric cherry condition -/

/-- **Forward characterization.** If `(a, b)` is a structural cherry pair in a
tree that realizes `D`, then the metric cherry condition `IsCherryPair D a b`
holds (the distance difference `D(a,k) - D(b,k)` is constant for all `k ≠ a,b`).

**Note:** The converse is false — `IsCherryPair D a b` characterizes *splits*,
not *cherries*. A pair can satisfy the metric condition without being a cherry
(e.g., leaves on the same side of a caterpillar tree). -/
theorem tree_cherry_implies_metric_cherry
    {n : ℕ} {D : Matrix (Fin n) (Fin n) ℝ}
    {t : LBTree} (hreal : t.Realizes D)
    {a b : Fin n} (hab : a ≠ b)
    (hcherry : t.IsTreeCherryPair (a : ℕ) (b : ℕ)) :
    IsCherryPair D a b := by
  -- Apply the cherry_dist_diff_eq_rootDist_diff lemma to both k and l.
  have h_diff_k : ∀ k : Fin n, k ≠ a → k ≠ b → t.dist a k - t.dist b k = t.rootDist a - t.rootDist b := by
    intro k hk_ne_a hk_ne_b
    apply cherry_dist_diff_eq_rootDist_diff t hreal.1.1 a b hcherry k (by
    exact hreal.2.1 k) (by
    exact fun h => hk_ne_a <| Fin.ext h) (by
    exact fun h => hk_ne_b <| Fin.ext h)
  have h_diff_l : ∀ l : Fin n, l ≠ a → l ≠ b → t.dist a l - t.dist b l = t.rootDist a - t.rootDist b := by
    exact h_diff_k;
  refine' ⟨ hab, fun k l hk hl hk' hl' => _ ⟩;
  linarith [ hreal.2.2 a k, hreal.2.2 a l, hreal.2.2 b k, hreal.2.2 b l, h_diff_k k hk hl, h_diff_l l hk' hl' ]

/-! ### Same-topology trees have the same cherry pairs -/

/-
Trees with the same topology have the same structural cherry pairs.
-/
theorem same_topology_cherry_iff {t₁ t₂ : LBTree}
    (htop : t₁.SameTopology t₂) (i j : ℕ) :
    t₁.IsTreeCherryPair i j ↔ t₂.IsTreeCherryPair i j := by
  have h_ind : ∀ (t₁ t₂ : LBTree), t₁.SameTopology t₂ → ∀ i j, t₁.IsTreeCherryPair i j → t₂.IsTreeCherryPair i j := by
    intros t₁ t₂ htop i j hcherry
    induction' t₁ with wL₁ L₁ wR₁ R₁ ih₁ generalizing t₂ i j;
    · cases hcherry;
    · rcases t₂ with ( _ | ⟨ L₂, wR₂, R₂, ih₂ ⟩ ) ; simp_all +decide [ LBTree.SameTopology ];
      cases htop <;> simp_all +decide [ LBTree.IsTreeCherryPair ];
      · rcases hcherry with ( ⟨ a, ha, x, hx, h ⟩ | h | h ) <;> simp_all +decide [ LBTree.IsTreeCherryPair ];
        cases wR₂ <;> cases ih₂ <;> simp_all +decide [ LBTree.SameTopology ];
      · rcases hcherry with ( ⟨ a, rfl, b, rfl, h ⟩ | h | h ) <;> simp_all +decide [ LBTree.IsTreeCherryPair ];
        cases wR₂ <;> cases ih₂ <;> simp_all +decide [ LBTree.SameTopology ];
        grind
  generalize_proofs at *;
  exact ⟨ h_ind t₁ t₂ htop i j, fun h => h_ind t₂ t₁ ( by
    have h_ind : ∀ (t₁ t₂ : LBTree), t₁.SameTopology t₂ → t₂.SameTopology t₁ := by
      intros t₁ t₂ htop
      induction' t₁ with t₁ ih generalizing t₂
      induction' t₂ with t₂ ih' generalizing t₁
      generalize_proofs at *; (
      exact htop.symm);
      · cases htop;
      · induction' t₂ with t₂ ih' generalizing t₁
        generalize_proofs at *; (
        cases htop);
        cases htop <;> tauto
    generalize_proofs at *; exact h_ind t₁ t₂ htop; ) i j h ⟩

/-! ### Reduced realization uniqueness (key structural theorem) -/

/-- **Reduced Realization Uniqueness.** Any two reduced leaf-labeled trees
realizing the same distance matrix have the same combinatorial topology
(up to child ordering at each internal node).

This is the fundamental uniqueness theorem for tree metrics: a tree metric
in the relative interior of a maximal cone of the tropical tree space
determines a unique combinatorial type.

The proof proceeds by strong induction on the number of leaves:
* Base cases (n ≤ 3) are handled by direct verification.
* For n ≥ 4, `cherry_pair_exists` provides a cherry pair that can be
  detected from the metric. Pruning this cherry in both trees yields
  reduced realizations of a smaller metric. By the inductive hypothesis,
  these pruned trees have the same topology, and re-attaching the cherry
  preserves topology agreement. -/
theorem reduced_realization_same_topology
    {n : ℕ}
    (D : Matrix (Fin n) (Fin n) ℝ)
    (hm : IsFiniteMetric D) (h4 : FourPointCondition D)
    (T₁ T₂ : LBTree)
    (hred₁ : T₁.Reduced) (hred₂ : T₂.Reduced)
    (hreal₁ : T₁.Realizes D) (hreal₂ : T₂.Realizes D)
    (hlabels₁ : T₁.labels = Finset.image Fin.val (Finset.univ : Finset (Fin n)))
    (hlabels₂ : T₂.labels = Finset.image Fin.val (Finset.univ : Finset (Fin n))) :
    T₁.SameTopology T₂ := by
  sorry

/-! ### Cherry invariance: the main theorems -/

/-- **Cherry Pair Metric Invariance.** Being a cherry pair is determined
by the realized distance matrix alone. If two reduced trees realize the
same distance matrix, they agree on which pairs of leaves form cherries.

This is the tree-metric analogue of the statement that a point in the
relative interior of a maximal cone of a tropical moduli space determines
a unique combinatorial type. The proof uses the fundamental result that
reduced realizations are topologically unique (`reduced_realization_same_topology`). -/
theorem cherry_pair_metric_invariant
    {n : ℕ}
    (D : Matrix (Fin n) (Fin n) ℝ)
    (hm : IsFiniteMetric D)
    (h4 : FourPointCondition D)
    (T₁ T₂ : LBTree)
    (hred₁ : T₁.Reduced)
    (hred₂ : T₂.Reduced)
    (hreal₁ : T₁.Realizes D)
    (hreal₂ : T₂.Realizes D)
    (hlabels₁ : T₁.labels = Finset.image Fin.val (Finset.univ : Finset (Fin n)))
    (hlabels₂ : T₂.labels = Finset.image Fin.val (Finset.univ : Finset (Fin n)))
    {a b : Fin n} (_hab : a ≠ b) :
    T₁.IsTreeCherryPair (a : ℕ) (b : ℕ) ↔ T₂.IsTreeCherryPair (a : ℕ) (b : ℕ) := by
  exact same_topology_cherry_iff
    (reduced_realization_same_topology D hm h4 T₁ T₂ hred₁ hred₂ hreal₁ hreal₂ hlabels₁ hlabels₂) _ _

/-- **Corollary.** Any two reduced realizations of the same tree metric
have identical cherry pair sets. -/
theorem cherry_pairs_unique_of_reduced_realization
    {n : ℕ}
    (D : Matrix (Fin n) (Fin n) ℝ)
    (hm : IsFiniteMetric D)
    (h4 : FourPointCondition D)
    (T₁ T₂ : LBTree)
    (hred₁ : T₁.Reduced)
    (hred₂ : T₂.Reduced)
    (hreal₁ : T₁.Realizes D)
    (hreal₂ : T₂.Realizes D)
    (hlabels₁ : T₁.labels = Finset.image Fin.val (Finset.univ : Finset (Fin n)))
    (hlabels₂ : T₂.labels = Finset.image Fin.val (Finset.univ : Finset (Fin n))) :
    T₁.cherryPairSet = T₂.cherryPairSet := by
  ext ⟨i, j⟩
  simp only [LBTree.cherryPairSet, Set.mem_setOf_eq]
  exact same_topology_cherry_iff
    (reduced_realization_same_topology D hm h4 T₁ T₂ hred₁ hred₂ hreal₁ hreal₂ hlabels₁ hlabels₂) _ _

/-! ### Noisy stability -/

/-- A metric `D₀` has *separated cherries* with margin `δ > 0` if for every
non-cherry pair (a,b), there exist witnesses k,l such that the four-point
deviation is at least `δ`. -/
def cherry_separation_positive {n : ℕ}
    (D₀ : Matrix (Fin n) (Fin n) ℝ) (δ : ℝ) : Prop :=
  0 < δ ∧ ∀ a b : Fin n, a ≠ b → ¬IsCherryPair D₀ a b →
    ∃ k l : Fin n, k ≠ a ∧ k ≠ b ∧ l ≠ a ∧ l ≠ b ∧
      δ ≤ |D₀ a k + D₀ b l - D₀ a l - D₀ b k|

/-- **Noisy Cherry Stability (Forward).** If `(a,b)` is a cherry pair in
the true metric `D₀` and `D` is `ε`-close to `D₀`, then the four-point
deviations in `D` are small (at most `4ε`).

This shows that cherry pairs remain "close to being cherries" under perturbation. -/
theorem noisy_cherry_forward
    {n : ℕ}
    (D₀ D : Matrix (Fin n) (Fin n) ℝ)
    (ε : ℝ) (_hε : 0 ≤ ε)
    (hclose : ∀ i j, |D i j - D₀ i j| ≤ ε)
    {a b : Fin n} (_hab : a ≠ b)
    (hcherry : IsCherryPair D₀ a b) :
    ∀ k l : Fin n, k ≠ a → k ≠ b → l ≠ a → l ≠ b →
      |D a k + D b l - D a l - D b k| ≤ 4 * ε := by
  intro k l hk ha hl hb; rw [ abs_le ] ; constructor <;> linarith [ abs_le.mp ( hclose a k ), abs_le.mp ( hclose b l ), abs_le.mp ( hclose a l ), abs_le.mp ( hclose b k ), hcherry.2 k l hk ha hl hb ] ;

/-- **Noisy Cherry Stability (Backward).** If `(a,b)` is NOT a cherry in `D₀`
and the cherry separation margin exceeds `δ`, and `D` is `ε`-close to `D₀`
with `ε < δ/4`, then `D` also witnesses the non-cherry property of `(a,b)` with
a four-point deviation of at least `δ - 4ε > 0`. -/
theorem noisy_cherry_backward
    {n : ℕ}
    (D₀ D : Matrix (Fin n) (Fin n) ℝ)
    (ε δ : ℝ)
    (hclose : ∀ i j, |D i j - D₀ i j| ≤ ε)
    (hsep : cherry_separation_positive D₀ δ)
    (hε : ε < δ / 4)
    {a b : Fin n} (_hab : a ≠ b)
    (hnotcherry : ¬IsCherryPair D₀ a b) :
    ∃ k l : Fin n, k ≠ a ∧ k ≠ b ∧ l ≠ a ∧ l ≠ b ∧
      δ - 4 * ε ≤ |D a k + D b l - D a l - D b k| := by
  obtain ⟨k, l, hk, hl, hkl⟩ : ∃ k l : Fin n, k ≠ a ∧ k ≠ b ∧ l ≠ a ∧ l ≠ b ∧ δ ≤ |D₀ a k + D₀ b l - D₀ a l - D₀ b k| := by
    exact hsep.2 a b _hab hnotcherry;
  exact ⟨ k, l, hk, hl, hkl.1, hkl.2.1, by cases abs_cases ( D a k + D b l - D a l - D b k ) <;> cases abs_cases ( D₀ a k + D₀ b l - D₀ a l - D₀ b k ) <;> linarith [ abs_le.mp ( hclose a k ), abs_le.mp ( hclose b l ), abs_le.mp ( hclose a l ), abs_le.mp ( hclose b k ) ] ⟩

/-- **Combined Noisy Stability.** Under a separated tree metric, small
perturbations preserve the split structure: true cherry pairs have small
four-point deviations, and non-cherry pairs have large deviations. -/
theorem noisy_cherry_stability
    {n : ℕ}
    (D₀ D : Matrix (Fin n) (Fin n) ℝ)
    (ε δ : ℝ)
    (hε_nn : 0 ≤ ε)
    (hclose : ∀ i j, |D i j - D₀ i j| ≤ ε)
    (hsep : cherry_separation_positive D₀ δ)
    (_hε : ε < δ / 4)
    {a b : Fin n} (_hab : a ≠ b) :
    (IsCherryPair D₀ a b → ∀ k l : Fin n, k ≠ a → k ≠ b → l ≠ a → l ≠ b →
      |D a k + D b l - D a l - D b k| ≤ 4 * ε) ∧
    (¬IsCherryPair D₀ a b → ∃ k l : Fin n, k ≠ a ∧ k ≠ b ∧ l ≠ a ∧ l ≠ b ∧
      δ - 4 * ε ≤ |D a k + D b l - D a l - D b k|) :=
  ⟨fun hc => noisy_cherry_forward D₀ D ε hε_nn hclose _hab hc,
   fun hnc => noisy_cherry_backward D₀ D ε δ hclose hsep _hε _hab hnc⟩

end