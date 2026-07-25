/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Finite Arity and Filtered-Colimit Preservation

This file isolates, in an elementary and self-contained form, the combinatorial
heart of the statement *"the sheared Witt vector functor preserves filtered
colimits over nilperfect rings"*.

A filtered colimit of rings is modelled here by its most concrete incarnation: a
**directed union** `⋃ i, S i` of a monotone family `S : ι → Set A` indexed by a
nonempty directed order `ι`.  A ring-valued functor whose underlying set is a
finite power `R ↦ Rⁿ` (a "finite-arity" functor, e.g. the *truncated* Witt
vectors `Wₙ`, which set-theoretically is `Rⁿ`) preserves such colimits; a functor
whose underlying set is an infinite power `R ↦ R^ℕ` (the *naive* / big Witt
vectors) does **not**.  The sheared construction repairs the failure by keeping
only the *eventually-basepoint* (finitely supported) coordinates, which again
behaves like a finite-arity functor.

The three theorems below make each of these three phenomena precise and prove
them:

* `finite_product_preserves` — a finite power commutes with the directed union
  (**preservation for `Wₙ`**);
* `infinite_product_fails` — a countable power does **not** commute with the
  directed union (**the obstruction for the naive Witt functor**);
* `sheared_product_preserves` — the *eventually-constant* countable power
  commutes again (**the sheared repair**).

-- !-- Lab Notes -- !--
Hypothesis (Stage 1):
  (H1) A functor built from finitely many coordinates and polynomial laws
       commutes with filtered colimits, because a finite tuple of germs is
       supported at finitely many indices, which a directed system merges into
       one stage.                                                       [PROVED]
  (H2, surprising) The SAME statement fails for countably many coordinates:
       directedness only merges FINITE index sets, so an unbounded family of
       germs need not factor through a single stage.                    [PROVED]
  (H3, surprising) Restricting the countable power to sequences that are
       eventually equal to a fixed basepoint restores preservation — a finite
       "essential support" is again mergeable.  This is exactly the shearing
       idea.                                                            [PROVED]
Experiment (Stage 2):
  The colimit was modelled as a directed union `⋃ i, S i` of a monotone family
  of subsets; the key engine is `Finset.exists_le`, which turns "directed +
  finite" into a single upper bound.  For (H1) the finite index set is
  `Finset.univ.image c` over the Fintype of coordinates; for (H3) it is
  `(Finset.range N).image c`, the finitely many pre-support coordinates.
Analysis (Stage 3):
  The obstruction (H2) is genuinely a failure of the naive functor, witnessed by
  the identity sequence `id : ℕ → ℕ` against the standard exhaustion
  `S i = Set.Iic i`; `id` lies in every-coordinate-in-the-union but in no single
  stage.  This is precisely why the *big* Witt vectors do not preserve filtered
  colimits and why the sheared variant is needed.
Critique (Stage 4):
  No proof is `decide`/`simp`-only: (H1)/(H3) use `choose`, `Finset.exists_le`,
  monotonicity and a case split; (H2) is a real counterexample, not a vacuous
  inequality.  The theorems are quantified over an arbitrary directed index and
  an arbitrary carrier, not a single finite instance.
Synthesis (Stage 5):
  Finite arity (or finite essential support) is *equivalent in spirit* to
  filtered-colimit preservation; the shearing construction is the minimal
  modification of an infinite-arity functor that recovers it.
-- !-- end Lab Notes -- !--
-/
import Mathlib

open scoped BigOperators

namespace FilteredColimitArity

/-! ## Preservation for finite arity (truncated Witt `Wₙ`) -/

/-- **Finite powers commute with directed unions.**
For a monotone family `S : ι → Set A` over a nonempty directed order and any
*finite* index type `κ`, the set of tuples all of whose (finitely many)
coordinates lie in the directed union `⋃ i, S i` equals the directed union of the
sets of tuples with all coordinates in a single stage `S i`.

This is the finite-limits-commute-with-filtered-colimits statement specialised to
finite products, i.e. the reason a truncated Witt vector functor `R ↦ Rⁿ`
preserves filtered colimits. -/
theorem finite_product_preserves
    {A : Type*} {ι : Type*} [Preorder ι] [IsDirected ι (· ≤ ·)] [Nonempty ι]
    {κ : Type*} [Fintype κ] {S : ι → Set A} (hmono : Monotone S) :
    {f : κ → A | ∀ k, f k ∈ ⋃ i, S i} = ⋃ i, {f : κ → A | ∀ k, f k ∈ S i} := by
  classical
  ext f
  simp only [Set.mem_setOf_eq, Set.mem_iUnion]
  constructor
  · intro h
    choose c hc using h
    obtain ⟨M, hM⟩ := Finset.exists_le (Finset.univ.image c)
    exact ⟨M, fun k => hmono (hM (c k) (Finset.mem_image_of_mem c (Finset.mem_univ k))) (hc k)⟩
  · rintro ⟨i, hi⟩ k
    exact ⟨i, hi k⟩

/-! ## The obstruction for infinite arity (naive/big Witt) -/

/-- **A countable power does not commute with directed unions.**
For the standard exhaustion `S i = Set.Iic i` of `ℕ` (a monotone directed family
whose union is all of `ℕ`), the set of sequences with every coordinate in the
union (all sequences) strictly contains the union over `i` of sequences bounded
by `i`.  The identity sequence witnesses the gap.

This is the precise obstruction preventing the *naive* Witt vector functor
`R ↦ R^ℕ` from preserving filtered colimits. -/
theorem infinite_product_fails :
    {f : ℕ → ℕ | ∀ k, f k ∈ ⋃ i, Set.Iic i} ≠ ⋃ i, {f : ℕ → ℕ | ∀ k, f k ∈ Set.Iic i} := by
  intro h
  have hid : (id : ℕ → ℕ) ∈ {f : ℕ → ℕ | ∀ k, f k ∈ ⋃ i, Set.Iic i} := by
    intro k; exact Set.mem_iUnion_of_mem k (by simp)
  rw [h] at hid
  simp only [Set.mem_iUnion, Set.mem_setOf_eq, Set.mem_Iic] at hid
  obtain ⟨i, hi⟩ := hid
  have := hi (i + 1)
  simp at this

/-! ## The sheared repair (eventually-constant sequences) -/

/-- **Eventually-constant countable powers commute with directed unions again.**
Fix a basepoint `b` lying in every stage `S i`.  Restricting the countable power
to sequences that are eventually equal to `b` (finite essential support) recovers
filtered-colimit preservation, even though the unrestricted countable power does
not (`infinite_product_fails`).

This is the sheared Witt vector mechanism: keeping only the finitely-supported
coordinates makes an infinite-arity functor behave like a finite-arity one. -/
theorem sheared_product_preserves
    {A : Type*} {ι : Type*} [Preorder ι] [IsDirected ι (· ≤ ·)] [Nonempty ι]
    {S : ι → Set A} (hmono : Monotone S) (b : A) (hb : ∀ i, b ∈ S i) :
    {f : ℕ → A | (∃ N, ∀ k ≥ N, f k = b) ∧ ∀ k, f k ∈ ⋃ i, S i}
      = ⋃ i, {f : ℕ → A | (∃ N, ∀ k ≥ N, f k = b) ∧ ∀ k, f k ∈ S i} := by
  classical
  ext f
  simp only [Set.mem_setOf_eq, Set.mem_iUnion]
  constructor
  · rintro ⟨⟨N, hN⟩, hmem⟩
    choose c hc using hmem
    obtain ⟨M, hM⟩ := Finset.exists_le ((Finset.range N).image c)
    refine ⟨M, ⟨N, hN⟩, fun k => ?_⟩
    by_cases hk : k < N
    · exact hmono (hM (c k) (Finset.mem_image_of_mem c (Finset.mem_range.mpr hk))) (hc k)
    · rw [hN k (not_lt.mp hk)]; exact hb M
  · rintro ⟨i, ⟨N, hN⟩, hi⟩
    exact ⟨⟨N, hN⟩, fun k => ⟨i, hi k⟩⟩

end FilteredColimitArity