import Mathlib

/-!
# Generating-tree isomorphisms ⟹ refined equinumerosity (reusable engine)

This file develops a small, rigorous, reusable theory of **generating trees** and
their isomorphisms, in service of the research direction

*"Recursive decomposition isomorphism for general `m`-Tamari intervals and planar
`(m+1)`-constellations."*

A **generating tree** is a *root label* together with a *succession rule*
`succ : L → List L` giving the ordered list of labels of the children of a node.
Unfolding the rule level by level produces, at depth `k`, the ordered list of
labels of the nodes at that depth (`levelLabels`); the *counting sequence*
(`levelCount`) is the sequence of level sizes — in applications, the number of
objects of each size.

The core principle: two families with **isomorphic** generating trees (equal
succession rule up to a relabelling `φ` of labels) are equinumerous, and in fact
*equinumerous refined by every statistic carried by the labels*.  We prove:

* `GenTreeM.levelLabels_map`   — level-by-level correspondence through `φ`;
* `GenTreeM.levelCount_eq`     — the counting sequences coincide;
* `GenTreeM.refined_count_eq`  — refined counts coincide, level by level.

The concrete general-`m` succession rules and the isomorphism are developed in
`GeneralM.lean`, which proves the corresponding statements directly for the
concrete `m`-rules, mirroring this reusable engine.

-- !-- Lab Notes -- !--
HYPOTHESIS (framework).  "Isomorphism of generating trees" should be defined so it
*automatically* yields refined equinumerosity, without touching the combinatorial
objects.  The right datum is a label map `φ` intertwining the two succession rules
(`succ₂ ∘ φ = List.map φ ∘ succ₁`) and matching the roots (`φ root₁ = root₂`).

EXPERIMENT.  Define `levelLabels` by the two-line recursion (`level 0 = [root]`,
`level (k+1) = flatMap succ (level k)`).  The single non-trivial ingredient is the
interchange lemma `(xs.map φ).flatMap succ₂ = (xs.flatMap succ₁).map φ`, proved by
induction on `xs` from the intertwining hypothesis.  An induction on `k` then gives
`levelLabels succ₂ root₂ k = (levelLabels succ₁ root₁ k).map φ`.

ANALYSIS.  Everything downstream (equal counts, equal refined counts) follows by
`List.length_map` / `List.countP_map`.  The refined statement uses that statistics
`w₁, w₂` with `w₂ ∘ φ = w₁` have equal `countP` profiles.

CRITIQUE.  Non-vacuous: `levelLabels_map` is a genuine list identity proved by
nested induction, and `refined_count_eq` fails without the intertwining hypothesis
(a bare bijection of label *types* is insufficient).  No `rfl`/`native_decide`.

SYNTHESIS.  Reusable engine: to prove two families refined-equinumerous, exhibit a
label map intertwining their generating-tree succession rules.
-/

namespace GenTreeM

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

/-- The number of nodes at depth `k`: the size-`k` term of the counting sequence. -/
def levelCount (succ : L → List L) (root : L) (k : ℕ) : ℕ :=
  (levelLabels succ root k).length

/-- **List interchange lemma.**  If `succ₂` intertwines with `succ₁` through `φ`,
then mapping and expanding one level commute. -/
theorem map_flatMap_of_intertwine {succ₁ : L → List L} {succ₂ : M → List M}
    (φ : L → M) (h : ∀ a, succ₂ (φ a) = (succ₁ a).map φ) (xs : List L) :
    (xs.map φ).flatMap succ₂ = (xs.flatMap succ₁).map φ := by
  induction xs with
  | nil => simp
  | cons a t ih => simp [List.flatMap_cons, h, ih, List.map_append]

/-- **Generating-tree isomorphism, level correspondence.**  If `φ` sends root to
root and intertwines the succession rules, then at every depth the label list of
the second tree is the `φ`-image of that of the first. -/
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

/-- **Refined equinumerosity.**  Under a generating-tree isomorphism, for statistics
`w₁` on source and `w₂` on target labels that agree through `φ`, the number of
depth-`k` nodes whose statistic satisfies `P` is the same in both trees. -/
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

end GenTreeM