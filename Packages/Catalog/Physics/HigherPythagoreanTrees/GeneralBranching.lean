import Mathlib
import Catalog.Physics.HigherPythagoreanTrees.DescentComplex

/-!
# A universal lower bound for the branching of the `n`-dimensional Pythagorean graph

The descent complex of a Pythagorean `n`-tuple has all faces of size `≤ n − 2`
(`HigherPythagoreanDescent.DescendsOn.card_le`).  Dually, *every* sign pattern with at least
`n − 1` minus signs strictly raises the height: it is a **child**.  Counting these patterns
gives a bound valid in every dimension:

> a node of the `n`-dimensional Pythagorean graph with positive coordinates has at least
> `n + 1` children.

For `n = 2` this is exactly Berggren's ternary branching (`3 = 2 + 1`), which is therefore the
*minimal* possible branching, attained precisely because the descent complex is empty in
dimension two.  In dimension three the true value is `6` or `7`
(`Catalog.Physics.HigherPythagoreanTrees.ExactBranching`), comfortably above the universal
bound `4`.

Main results.

* `mem_children_of_card_compl_le_one` : patterns with at most one plus sign are children.
* `card_children_ge` : `n + 1 ≤ #children`.
-/

namespace HigherPythagoreanDescent

open Finset

variable {n : ℕ}

/-- The children of a node: the sign patterns whose reflection move strictly raises the
height. -/
def children (x : Fin n → ℤ) (d : ℤ) : Finset (Finset (Fin n)) :=
  Finset.univ.filter fun S => signedSum S x < d

/-- A set of coordinates of size at most one has sum at most the height. -/
lemma sum_le_height_of_card_le_one {x : Fin n → ℤ} {d : ℤ} (hd : 0 ≤ d) (h : IsPythTuple x d)
    {T : Finset (Fin n)} (hT : T.card ≤ 1) : ∑ i ∈ T, x i ≤ d := by
  by_contra hcon
  push_neg at hcon
  have := two_le_card_of_sum_gt hd h hcon
  omega

/-- **Patterns with at most one plus sign are children.** -/
theorem mem_children_of_card_compl_le_one {x : Fin n → ℤ} {d : ℤ} (hx : ∀ i, 0 < x i)
    (hd : 0 ≤ d) (h : IsPythTuple x d) {S : Finset (Fin n)} (hS : Sᶜ.card ≤ 1)
    (hne : S.Nonempty) : S ∈ children x d := by
  refine Finset.mem_filter.mpr ⟨Finset.mem_univ _, ?_⟩
  have hsplit : ∑ i ∈ S, x i + ∑ i ∈ Sᶜ, x i = ∑ i, x i := Finset.sum_add_sum_compl S x
  have hcompl : ∑ i ∈ Sᶜ, x i ≤ d := sum_le_height_of_card_le_one hd h hS
  have hpos : 0 < ∑ i ∈ S, x i :=
    Finset.sum_pos (fun i _ => hx i) hne
  rw [signedSum_eq_total_sub]
  linarith

/-- The `n + 1` patterns with at most one plus sign. -/
def bigPatterns (n : ℕ) : Finset (Finset (Fin n)) :=
  insert Finset.univ ((Finset.univ : Finset (Fin n)).image fun i => ({i}ᶜ : Finset (Fin n)))

theorem card_bigPatterns : (bigPatterns n).card = n + 1 := by
  have hinj : Function.Injective fun i : Fin n => ({i}ᶜ : Finset (Fin n)) := by
    intro i j hij
    have : ({i} : Finset (Fin n)) = {j} := by
      simpa using congrArg (fun S : Finset (Fin n) => Sᶜ) hij
    simpa using this
  have himg : ((Finset.univ : Finset (Fin n)).image
      fun i => ({i}ᶜ : Finset (Fin n))).card = n := by
    rw [Finset.card_image_of_injective _ hinj]
    simp
  have hnot : (Finset.univ : Finset (Fin n)) ∉
      (Finset.univ : Finset (Fin n)).image fun i => ({i}ᶜ : Finset (Fin n)) := by
    intro hmem
    obtain ⟨i, -, hi⟩ := Finset.mem_image.mp hmem
    have : i ∈ ({i}ᶜ : Finset (Fin n)) := by rw [hi]; exact Finset.mem_univ i
    simp at this
  rw [bigPatterns, Finset.card_insert_of_notMem hnot, himg]

/-- **Universal branching bound.**  In dimension `n ≥ 2` every node with positive coordinates
has at least `n + 1` children.  For `n = 2` this is Berggren's ternary branching, which is
therefore the smallest branching number possible in the whole family. -/
theorem card_children_ge {x : Fin n → ℤ} {d : ℤ} (hn : 2 ≤ n) (hx : ∀ i, 0 < x i) (hd : 0 ≤ d)
    (h : IsPythTuple x d) : n + 1 ≤ (children x d).card := by
  have hsub : bigPatterns n ⊆ children x d := by
    intro S hS
    rw [bigPatterns, Finset.mem_insert] at hS
    rcases hS with rfl | hS
    · refine mem_children_of_card_compl_le_one hx hd h (by simp) ?_
      exact Finset.univ_nonempty_iff.mpr (Fin.pos_iff_nonempty.mp (by omega))
    · obtain ⟨i, -, rfl⟩ := Finset.mem_image.mp hS
      refine mem_children_of_card_compl_le_one hx hd h (by simp) ?_
      -- the complement of a singleton is nonempty as soon as `n ≥ 2`
      have hcard : 1 < Fintype.card (Fin n) := by simpa using hn
      obtain ⟨j, hj⟩ := Fintype.exists_ne_of_one_lt_card hcard i
      exact ⟨j, by simpa using hj⟩
  calc n + 1 = (bigPatterns n).card := card_bigPatterns.symm
    _ ≤ (children x d).card := Finset.card_le_card hsub

/-- Dimension two: the Berggren bound `3`. -/
theorem card_children_ge_two {x : Fin 2 → ℤ} {d : ℤ} (hx : ∀ i, 0 < x i) (hd : 0 ≤ d)
    (h : IsPythTuple x d) : 3 ≤ (children x d).card :=
  card_children_ge (by norm_num) hx hd h

/-- Dimension three: at least `4` children (the exact values `6`, `7` are computed in
`Catalog.Physics.HigherPythagoreanTrees.ExactBranching`). -/
theorem card_children_ge_three {x : Fin 3 → ℤ} {d : ℤ} (hx : ∀ i, 0 < x i) (hd : 0 ≤ d)
    (h : IsPythTuple x d) : 4 ≤ (children x d).card :=
  card_children_ge (by norm_num) hx hd h

end HigherPythagoreanDescent