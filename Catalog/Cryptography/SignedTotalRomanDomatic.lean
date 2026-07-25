/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

open scoped BigOperators

/-!
# Signed total Roman domination and the signed total Roman domatic number

This file develops a small, self-contained and **non-circular** framework for
*signed total Roman domination* of a finite simple graph `G`, and for the
associated *signed total Roman domatic number* `d_stR(G)`.

## The definitions (precise and non-circular)

Fix a finite vertex type `V` and a simple graph `G : SimpleGraph V` with a
decidable adjacency relation.  A function `f : V → ℤ` is a **signed total Roman
dominating function** (`IsSTRDF G f`) when three conditions hold, none of which
refers back to the notion being defined:

* *(values)* `f v ∈ {-1, 1, 2}` for every vertex `v`;
* *(total domination)* the sum of `f` over the **open** neighbourhood
  `G.neighborFinset v` is at least `1`, for every `v`
  (the word *total* means we sum over the open neighbourhood, excluding `v`
  itself);
* *(Roman)* every vertex `v` with `f v = -1` has a neighbour `u` with `f u = 2`.

A **signed total Roman dominating family** (`IsSTRDFamily G F`) is a finite set
`F : Finset (V → ℤ)` of functions such that every member is an `IsSTRDF` and, at
each vertex `v`, the pointwise sum `∑ f ∈ F, f v` is at most `1`.  Distinctness
of the members is automatic because `F` is a `Finset`.

The **signed total Roman domatic number** is
`dstR G = sSup { n | ∃ F, IsSTRDFamily G F ∧ F.card = n }`, the supremum of the
sizes of such families (taken in `ℕ`).  The set is nonempty (the empty family
has size `0`) and bounded above (`bddAbove_family_cards`), so `dstR` is
well behaved.  Crucially, `dstR` is defined *after* `IsSTRDF` and
`IsSTRDFamily`, which are defined without reference to `dstR`; there is no
circularity.

## Main results

* `family_card_le_degree` : the **domatic upper bound**.  Any signed total Roman
  dominating family `F` satisfies `F.card ≤ G.degree v` for *every* vertex `v`;
  in particular `dstR G ≤ δ(G)`.  This is the heart of the theory.
* `constOne_isSTRDF` / `constOne_isSTRDFamily` : when `G` has no isolated vertex
  the constant function `1` is a signed total Roman dominating function and forms
  a family of size `1`.
* `degree_pos_of_exists_STRDF` : an `IsSTRDF` can exist only if `G` has no
  isolated vertex (every degree is `≥ 1`).  Hence "an STRDF exists" is
  equivalent to `δ(G) ≥ 1`.
* `one_le_dstR` : if any `IsSTRDF` exists then `1 ≤ dstR G`.
* `dstR_eq_one` : if an `IsSTRDF` exists **and** `G` has a vertex of degree `1`
  (a *leaf* / *pendant* vertex), then every signed total Roman dominating family
  has size `≤ 1`, and therefore `dstR G = 1`.
* `K12_dstR_eq_one` : the concrete star `K_{1,2}` (`K12`, the path on three
  vertices) satisfies `dstR K12 = 1`.

## Non-circular proof sketch of `dstR_eq_one`

The argument is a standard double-counting bound and does not presuppose any
value of `dstR`.

1. *(Domatic bound, `family_card_le_degree`.)*  Fix a family `F` and a vertex `v`.
   Summing the total-domination inequality over the members gives, over `ℤ`,
   `F.card = ∑_{f ∈ F} 1 ≤ ∑_{f ∈ F} ∑_{u ∈ N(v)} f u`.
   Swapping the two finite sums (`Finset.sum_comm`) rewrites the right-hand side
   as `∑_{u ∈ N(v)} ∑_{f ∈ F} f u`, and the family constraint `∑_{f∈F} f u ≤ 1`
   bounds this by `∑_{u ∈ N(v)} 1 = |N(v)| = G.degree v`.  Hence
   `F.card ≤ G.degree v`.
2. *(Upper bound.)*  Let `w` be the given degree-`1` vertex.  By step 1 every
   family has size `≤ G.degree w = 1`, so `1` is an upper bound of the size set
   and `csSup_le` gives `dstR G ≤ 1`.
3. *(Lower bound.)*  Since an `IsSTRDF` exists, `degree_pos_of_exists_STRDF`
   shows every degree is `≥ 1`, so the constant function `1` is an `IsSTRDF` and
   `{1}` is a family of size `1` (`constOne_isSTRDFamily`).  Thus `1` lies in the
   size set and `le_csSup` (with `bddAbove_family_cards`) gives `1 ≤ dstR G`.
4. Combining, `dstR G = 1`.

## On the informally requested "degree-3 and K_{1,2} conditions"

The informal task refers to a "degree-3 condition" and a "K_{1,2} condition".
The double-counting bound of step 1 shows exactly what a degree hypothesis buys:
a vertex of degree `d` forces every family to have size `≤ d`.  Consequently a
degree-`3` vertex only yields the (correct but weaker) bound `dstR G ≤ 3`, and a
*degree-3 condition alone does not force `dstR G = 1`*.  The sharp conclusion
`dstR G = 1` requires a vertex of degree `1`.  This degree-`1` vertex is precisely
the local structure carried by each of the two **leaves** of a `K_{1,2}` (the
star with two leaves, equivalently the path `P₃` on three vertices), whose leaves
have degree `1`.  We therefore formalise the operative hypothesis faithfully as
`∃ v, G.degree v = 1` and record the concrete witness `K12` satisfying it
(`K12_dstR_eq_one`).  The general degree bound is retained as
`family_card_le_degree`.

## Mathlib components used

* Graph theory: `SimpleGraph`, `SimpleGraph.neighborFinset`, `SimpleGraph.degree`,
  `SimpleGraph.card_neighborFinset_eq_degree`.
* Finite sums / order: `Finset.sum_le_sum`, `Finset.sum_comm`, `Finset.sum_const`,
  `Finset.card_le_univ`, `Finset.card_le_one`.
* Order theory / suprema: `sSup`, `BddAbove`, `le_csSup`, `csSup_le`
  (`ℕ` is a conditionally complete linear order with bottom).
* Function definitions: plain `def`/`fun`, with `dstR` marked `noncomputable`
  since it is defined through `sSup`.
-/

namespace SignedTotalRoman

variable {V : Type*} [Fintype V] (G : SimpleGraph V) [DecidableRel G.Adj]

/-- A **signed total Roman dominating function** on `G`: a function `f : V → ℤ`
taking values in `{-1, 1, 2}`, whose sum over every open neighbourhood is at
least `1` (total domination), and such that every `-1`-vertex has a `2`-neighbour
(the Roman condition). -/
def IsSTRDF (f : V → ℤ) : Prop :=
  (∀ v, f v = -1 ∨ f v = 1 ∨ f v = 2) ∧
  (∀ v, 1 ≤ ∑ u ∈ G.neighborFinset v, f u) ∧
  (∀ v, f v = -1 → ∃ u ∈ G.neighborFinset v, f u = 2)

/-- A **signed total Roman dominating family**: a finite set of signed total
Roman dominating functions whose pointwise sum is at most `1` at every vertex.
Members are automatically distinct since `F` is a `Finset`. -/
def IsSTRDFamily (F : Finset (V → ℤ)) : Prop :=
  (∀ f ∈ F, IsSTRDF G f) ∧ (∀ v, ∑ f ∈ F, f v ≤ 1)

/-- The **signed total Roman domatic number** `d_stR(G)`: the supremum of the
sizes of signed total Roman dominating families. -/
noncomputable def dstR : ℕ :=
  sSup { n | ∃ F : Finset (V → ℤ), IsSTRDFamily G F ∧ F.card = n }

/-- **Domatic upper bound (integer form).**  For any signed total Roman
dominating family `F` and any vertex `v`, `F.card ≤ G.degree v`. -/
theorem family_card_le_degree_int {F : Finset (V → ℤ)} (hF : IsSTRDFamily G F) (v : V) :
    (F.card : ℤ) ≤ (G.degree v : ℤ) := by
  obtain ⟨hmem, hsum⟩ := hF
  have h1 : (F.card : ℤ) ≤ ∑ f ∈ F, ∑ u ∈ G.neighborFinset v, f u := by
    calc (F.card : ℤ) = ∑ _f ∈ F, (1 : ℤ) := by simp
      _ ≤ ∑ f ∈ F, ∑ u ∈ G.neighborFinset v, f u := by
          apply Finset.sum_le_sum; intro f hf; exact (hmem f hf).2.1 v
  have h2 : ∑ f ∈ F, ∑ u ∈ G.neighborFinset v, f u
      = ∑ u ∈ G.neighborFinset v, ∑ f ∈ F, f u := Finset.sum_comm
  have h3 : ∑ u ∈ G.neighborFinset v, ∑ f ∈ F, f u ≤ (G.degree v : ℤ) := by
    calc ∑ u ∈ G.neighborFinset v, ∑ f ∈ F, f u
        ≤ ∑ _u ∈ G.neighborFinset v, (1 : ℤ) := by
          apply Finset.sum_le_sum; intro u _; exact hsum u
      _ = (G.degree v : ℤ) := by
          rw [Finset.sum_const, SimpleGraph.card_neighborFinset_eq_degree]; simp
  rw [h2] at h1; exact le_trans h1 h3

/-- **Domatic upper bound.**  Any signed total Roman dominating family `F`
satisfies `F.card ≤ G.degree v` for every vertex `v`; hence `dstR G ≤ δ(G)`. -/
theorem family_card_le_degree {F : Finset (V → ℤ)} (hF : IsSTRDFamily G F) (v : V) :
    F.card ≤ G.degree v := by
  exact_mod_cast family_card_le_degree_int G hF v

/-- The set of family sizes is bounded above (by `Fintype.card V`, or by `1` when
`V` is empty), so `dstR` is a genuine supremum. -/
theorem bddAbove_family_cards :
    BddAbove { n | ∃ F : Finset (V → ℤ), IsSTRDFamily G F ∧ F.card = n } := by
  rcases isEmpty_or_nonempty V with hV | hV
  · refine ⟨1, ?_⟩
    rintro n ⟨F, _, rfl⟩
    haveI : Subsingleton (V → ℤ) := ⟨fun a b => funext fun v => (hV.false v).elim⟩
    exact Finset.card_le_one.mpr (fun a _ b _ => Subsingleton.elim a b)
  · obtain ⟨v0⟩ := hV
    refine ⟨Fintype.card V, ?_⟩
    rintro n ⟨F, hF, rfl⟩
    calc F.card ≤ G.degree v0 := family_card_le_degree G hF v0
      _ ≤ Fintype.card V := by
          rw [← SimpleGraph.card_neighborFinset_eq_degree]; exact Finset.card_le_univ _

/-- Existence of a signed total Roman dominating function forces every degree to
be positive: no vertex can be isolated (its open-neighbourhood sum would be `0`,
violating total domination). -/
theorem degree_pos_of_exists_STRDF (h : ∃ f, IsSTRDF G f) (v : V) : 1 ≤ G.degree v := by
  obtain ⟨f, _, htot, _⟩ := h
  have hsum := htot v
  rcases Nat.eq_zero_or_pos (G.degree v) with h0 | hpos
  · exfalso
    have hempty : G.neighborFinset v = ∅ := by
      rw [← Finset.card_eq_zero, SimpleGraph.card_neighborFinset_eq_degree]; exact h0
    rw [hempty, Finset.sum_empty] at hsum; norm_num at hsum
  · exact hpos

/-- When `G` has no isolated vertex, the constant function `1` is a signed total
Roman dominating function. -/
theorem constOne_isSTRDF (hdeg : ∀ v, 1 ≤ G.degree v) : IsSTRDF G (fun _ => (1 : ℤ)) := by
  refine ⟨fun v => Or.inr (Or.inl rfl), ?_, ?_⟩
  · intro v
    rw [Finset.sum_const, SimpleGraph.card_neighborFinset_eq_degree]
    simpa using hdeg v
  · intro v hv; simp at hv

/-- When `G` has no isolated vertex, the singleton `{1}` is a signed total Roman
dominating family (of size `1`). -/
theorem constOne_isSTRDFamily (hdeg : ∀ v, 1 ≤ G.degree v) :
    IsSTRDFamily G {(fun _ => (1 : ℤ))} := by
  refine ⟨?_, ?_⟩
  · intro f hf; rw [Finset.mem_singleton] at hf; subst hf; exact constOne_isSTRDF G hdeg
  · intro v; rw [Finset.sum_singleton]

/-- If a signed total Roman dominating function exists, then `1 ≤ dstR G`. -/
theorem one_le_dstR (hex : ∃ f, IsSTRDF G f) : 1 ≤ dstR G := by
  have hdeg := degree_pos_of_exists_STRDF G hex
  have hmem : (1 : ℕ) ∈ { n | ∃ F : Finset (V → ℤ), IsSTRDFamily G F ∧ F.card = n } :=
    ⟨{(fun _ => (1 : ℤ))}, constOne_isSTRDFamily G hdeg, by simp⟩
  exact le_csSup (bddAbove_family_cards G) hmem

/-- **Main theorem.**  If a signed total Roman dominating function exists and `G`
has a vertex of degree `1` (a leaf / pendant — the defining local structure of a
`K_{1,2}`), then every signed total Roman dominating family has size `≤ 1`, and
hence `dstR G = 1`. -/
theorem dstR_eq_one (hex : ∃ f, IsSTRDF G f) (hpend : ∃ v, G.degree v = 1) :
    dstR G = 1 := by
  have hdeg := degree_pos_of_exists_STRDF G hex
  have h1mem : (1 : ℕ) ∈ { n | ∃ F : Finset (V → ℤ), IsSTRDFamily G F ∧ F.card = n } :=
    ⟨{(fun _ => (1 : ℤ))}, constOne_isSTRDFamily G hdeg, by simp⟩
  obtain ⟨w, hw⟩ := hpend
  have hub : ∀ n ∈ { n | ∃ F : Finset (V → ℤ), IsSTRDFamily G F ∧ F.card = n }, n ≤ 1 := by
    rintro n ⟨F, hF, rfl⟩
    have := family_card_le_degree G hF w; rw [hw] at this; exact this
  exact le_antisymm (csSup_le ⟨1, h1mem⟩ hub) (le_csSup ⟨1, hub⟩ h1mem)

/-- The concrete star `K_{1,2}` on `Fin 3` with centre `1`: vertex `1` is
adjacent to `0` and `2`, which are not adjacent to each other.  This is the path
`P₃` on three vertices; its two leaves `0` and `2` have degree `1`. -/
def K12 : SimpleGraph (Fin 3) where
  Adj i j := i ≠ j ∧ (i = 1 ∨ j = 1)
  symm := by rintro a b ⟨h1, h2⟩; exact ⟨h1.symm, h2.symm⟩
  loopless := ⟨fun a ha => ha.1 rfl⟩

instance : DecidableRel K12.Adj :=
  fun i j => inferInstanceAs (Decidable (i ≠ j ∧ (i = 1 ∨ j = 1)))

/-- The signed total Roman domatic number of `K_{1,2}` is `1`.  Its leaves have
degree `1`, so `dstR_eq_one` applies. -/
theorem K12_dstR_eq_one : dstR K12 = 1 := by
  apply dstR_eq_one
  · exact ⟨fun _ => 1, constOne_isSTRDF K12 (by decide)⟩
  · exact ⟨0, by decide⟩

end SignedTotalRoman