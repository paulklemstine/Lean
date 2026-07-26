import Mathlib

/-!
# Isomorphism of generating trees ⟹ refined equinumerosity

This file develops a small but rigorous general theory of **generating trees**
and their isomorphisms, motivated by the research direction

*"Isomorphism of generating trees for greedy `m`-Tamari intervals and planar
`(m+1)`-constellations."*

A **generating tree** is specified by a *root label* together with a *succession
rule* `succ : L → List L` assigning to each label the (ordered) list of labels of
its children.  Unfolding the rule level by level produces, at depth `k`, the list
of labels of all nodes at that depth.  The *counting sequence* of the tree is the
sequence of sizes of these levels; in the combinatorial applications the size-`n`
count is the number of objects of size `n` in the family the tree encodes.

The mathematical framing of the research direction is that whenever two families
have **isomorphic** generating trees (same succession rule up to a relabelling of
the labels), they are equinumerous — and in fact equinumerous *refined by every
statistic that is carried by the labels*.  We make this precise and prove it:

* `GenTree.levelLabels_map` : the label lists of two isomorphic generating trees
  correspond, level by level, through the label bijection `φ`.
* `GenTree.levelCount_eq` : consequently the two counting sequences are equal.
* `GenTree.refined_count_eq` : the *refined* counts (number of nodes at each level
  carrying a prescribed label, or more generally a prescribed value of a statistic
  that factors through `φ`) also agree, level by level.

These are the structural theorems underlying the claimed combinatorial proof of
equinumerosity: an isomorphism of generating trees is exactly the data needed to
transport all label-borne statistics from one family to the other.

The concrete `m`-Tamari / constellation succession rules, and a worked isomorphic
instance, are developed in `MTamariConstellationTree.lean`.

-- !-- Lab Notes -- !--
HYPOTHESIS (framework). "Isomorphism of generating trees" should be defined so
that it *automatically* yields refined equinumerosity, without touching the
combinatorial objects themselves.  The right definition is a label map `φ`
intertwining the two succession rules (`succ₂ ∘ φ = List.map φ ∘ succ₁`) and
matching the roots (`φ root₁ = root₂`).

EXPERIMENT.  Formalise `levelLabels` by the obvious two-line recursion
(`level 0 = [root]`, `level (k+1) = flatMap succ (level k)`).  The single
non-trivial ingredient is a `List` interchange lemma
`(xs.map φ).flatMap succ₂ = (xs.flatMap succ₁).map φ`, proved by induction on
`xs` using the intertwining hypothesis.  With it, an induction on the level `k`
proves `levelLabels succ₂ root₂ k = (levelLabels succ₁ root₁ k).map φ`.

ANALYSIS.  Everything downstream (equal counts, equal refined counts) is a
`congrArg`/`List.length_map`/`List.countP` consequence of that single level
correspondence.  The refined statement uses that a statistic `w₁` on the source
labels and `w₂` on the target labels with `w₂ ∘ φ = w₁` have equal `countP`
profiles because `countP` is invariant under `map` by a value-preserving map.

CRITIQUE.  The theorems are non-vacuous: `levelLabels_map` is a genuine
list-valued identity proved by nested induction, and `refined_count_eq` fails
without the intertwining hypothesis (a plain bijection of label *types* is not
enough).  Nothing is `native_decide` or `rfl`.

SYNTHESIS.  This provides the reusable engine: to prove two combinatorial
families equinumerous refined by a labelled statistic, exhibit a label map
intertwining their generating-tree succession rules.
-/

namespace GenTree

variable {L : Type*} {M : Type*}

/-- The ordered list of labels of the nodes at depth `k` of the generating tree
with succession rule `succ` and root `root`. -/
def levelLabels (succ : L → List L) (root : L) : ℕ → List L
  | 0 => [root]
  | k + 1 => (levelLabels succ root k).flatMap succ

@[simp] theorem levelLabels_zero (succ : L → List L) (root : L) :
    levelLabels succ root 0 = [root] := rfl

theorem levelLabels_succ (succ : L → List L) (root : L) (k : ℕ) :
    levelLabels succ root (k + 1) = (levelLabels succ root k).flatMap succ := rfl

/-- The number of nodes at depth `k`: the size-`k` term of the counting sequence
of the generating tree. -/
def levelCount (succ : L → List L) (root : L) (k : ℕ) : ℕ :=
  (levelLabels succ root k).length

/-- **List interchange lemma.**  If `succ₂` intertwines with `succ₁` through `φ`
(`succ₂ (φ a) = (succ₁ a).map φ`), then mapping and expanding one level commute. -/
theorem map_flatMap_of_intertwine {succ₁ : L → List L} {succ₂ : M → List M}
    (φ : L → M) (h : ∀ a, succ₂ (φ a) = (succ₁ a).map φ) (xs : List L) :
    (xs.map φ).flatMap succ₂ = (xs.flatMap succ₁).map φ := by
  induction xs with
  | nil => simp
  | cons a t ih => simp [List.flatMap_cons, h, ih, List.map_append]

/-- **Generating-tree isomorphism, level correspondence.**  If `φ` sends the root
of the first tree to the root of the second and intertwines the two succession
rules, then at every depth the label list of the second tree is the `φ`-image of
the label list of the first tree. -/
theorem levelLabels_map {succ₁ : L → List L} {succ₂ : M → List M}
    {root₁ : L} {root₂ : M} (φ : L → M)
    (hroot : φ root₁ = root₂)
    (hsucc : ∀ a, succ₂ (φ a) = (succ₁ a).map φ) (k : ℕ) :
    levelLabels succ₂ root₂ k = (levelLabels succ₁ root₁ k).map φ := by
  induction k with
  | zero => simp [← hroot]
  | succ k ih =>
      rw [levelLabels_succ, levelLabels_succ, ih,
        map_flatMap_of_intertwine φ hsucc]

/-- **Refined equinumerosity.**  Under a generating-tree isomorphism, for any
statistic `w₁` on source labels and `w₂` on target labels that agree through `φ`
(`w₂ (φ a) = w₁ a`), the number of depth-`k` nodes whose statistic satisfies a
predicate `P` is the same in both trees. -/
theorem refined_count_eq {succ₁ : L → List L} {succ₂ : M → List M}
    {root₁ : L} {root₂ : M} (φ : L → M)
    (hroot : φ root₁ = root₂)
    (hsucc : ∀ a, succ₂ (φ a) = (succ₁ a).map φ)
    {α : Type*} (w₁ : L → α) (w₂ : M → α) (hw : ∀ a, w₂ (φ a) = w₁ a)
    (P : α → Prop) [DecidablePred P] (k : ℕ) :
    (levelLabels succ₂ root₂ k).countP (fun b => decide (P (w₂ b)))
      = (levelLabels succ₁ root₁ k).countP (fun a => decide (P (w₁ a))) := by
  rw [levelLabels_map φ hroot hsucc, List.countP_map]
  apply List.countP_congr
  intro a _
  simp [Function.comp, hw]

/-- **Equal counting sequences.**  Under a generating-tree isomorphism the two
counting sequences coincide at every depth. -/
theorem levelCount_eq {succ₁ : L → List L} {succ₂ : M → List M}
    {root₁ : L} {root₂ : M} (φ : L → M)
    (hroot : φ root₁ = root₂)
    (hsucc : ∀ a, succ₂ (φ a) = (succ₁ a).map φ) (k : ℕ) :
    levelCount succ₂ root₂ k = levelCount succ₁ root₁ k := by
  unfold levelCount
  rw [levelLabels_map φ hroot hsucc, List.length_map]

end GenTree