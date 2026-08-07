/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Sheared Witt Vectors and Filtered Colimits of Rings

This file specialises the abstract finite-arity preservation results of
`Probability.FilteredColimitArity` to genuine **filtered colimits of rings**,
realised as directed unions of a monotone family of subrings `S : ι → Subring R`
whose colimit is the subring `⨆ i, S i`.

The two corollaries below are the ring-theoretic payoff:

* `subring_finiteTuple_lifts` — every finite tuple of elements of the colimit
  ring already lies in a single stage `S i`.  This is the statement that a
  *truncated* Witt vector functor `R ↦ Wₙ(R)` (set-theoretically `Rⁿ`) preserves
  the filtered colimit `⨆ i, S i`.
* `subring_shearedSequence_lifts` — every *eventually-zero* sequence of elements
  of the colimit ring lies in a single stage.  This is the sheared repair for the
  countable-arity (big Witt) functor, whose unrestricted form fails to preserve
  the colimit (`FilteredColimitArity.infinite_product_fails`).

-- !-- Lab Notes -- !--
Hypothesis (Stage 1):
  (H4) The abstract directed-union lemmas transport verbatim to subrings, because
       the colimit of a directed diagram of subrings of a fixed ring is exactly
       their directed union `⨆ i, S i`, and membership in it is `∃ i, · ∈ S i`.
                                                                        [PROVED]
Experiment (Stage 2):
  The bridge is `Subring.mem_iSup_of_directed`, which turns membership in the
  categorical colimit `⨆ i, S i` into membership in some stage.  Monotonicity of
  `S` gives `Monotone (fun i => (S i : Set R))` by `exact_mod_cast`, feeding the
  abstract `finite_product_preserves` / `sheared_product_preserves`.
Analysis (Stage 3):
  The basepoint for the sheared corollary is `0`, which lies in every subring
  (`Subring.zero_mem`); this is why "eventually zero" is the correct finite
  essential-support condition in the ring setting.
Critique (Stage 4):
  These are honest applications, not restatements: each discharges a real
  coercion between the categorical `⨆` and the set-level `⋃`, and each invokes an
  imported catalog theorem (`FilteredColimitArity.*`).  Neither is provable by
  `simp`/`decide` alone.
Synthesis (Stage 5):
  Over any commutative ring, finite-arity and finitely-supported functors detect
  no more of a filtered colimit of subrings than a single stage does — the
  categorical content of "sheared Witt preserves filtered colimits".
-- !-- end Lab Notes -- !--
-/
import Mathlib
import Probability.FilteredColimitArity

open scoped BigOperators

namespace ShearedWittColimit

/-- **Finite arity preserves the filtered colimit of subrings.**
For a monotone directed family of subrings `S : ι → Subring R` with colimit
`⨆ i, S i`, any finite tuple `g : Fin n → R` whose entries all lie in the colimit
already has all its entries in a single stage `S i`. -/
theorem subring_finiteTuple_lifts
    {R : Type*} [CommRing R] {ι : Type*} [Preorder ι] [IsDirected ι (· ≤ ·)] [Nonempty ι]
    {n : ℕ} {S : ι → Subring R} (hmono : Monotone S)
    (g : Fin n → R) (hg : ∀ k, g k ∈ ⨆ i, S i) :
    ∃ i, ∀ k, g k ∈ S i := by
  have hmono' : Monotone (fun i => (S i : Set R)) := fun a b h => by exact_mod_cast hmono h
  have hmem : ∀ k, g k ∈ ⋃ i, (S i : Set R) := by
    intro k
    obtain ⟨i, hi⟩ := (Subring.mem_iSup_of_directed hmono.directed_le).mp (hg k)
    exact Set.mem_iUnion_of_mem i hi
  have hg2 : g ∈ {f : Fin n → R | ∀ k, f k ∈ ⋃ i, (S i : Set R)} := hmem
  rw [FilteredColimitArity.finite_product_preserves hmono'] at hg2
  simpa [Set.mem_iUnion] using hg2

/-- **The sheared (finitely supported) functor preserves the filtered colimit of
subrings.**  Any *eventually-zero* sequence `g : ℕ → R` whose entries all lie in
the colimit `⨆ i, S i` already has all its entries in a single stage `S i`, even
though the analogous statement for arbitrary sequences fails
(`FilteredColimitArity.infinite_product_fails`). -/
theorem subring_shearedSequence_lifts
    {R : Type*} [CommRing R] {ι : Type*} [Preorder ι] [IsDirected ι (· ≤ ·)] [Nonempty ι]
    {S : ι → Subring R} (hmono : Monotone S)
    (g : ℕ → R) (hsupp : ∃ N, ∀ k ≥ N, g k = 0) (hg : ∀ k, g k ∈ ⨆ i, S i) :
    ∃ i, ∀ k, g k ∈ S i := by
  have hmono' : Monotone (fun i => (S i : Set R)) := fun a b h => by exact_mod_cast hmono h
  have hmem : ∀ k, g k ∈ ⋃ i, (S i : Set R) := by
    intro k
    obtain ⟨i, hi⟩ := (Subring.mem_iSup_of_directed hmono.directed_le).mp (hg k)
    exact Set.mem_iUnion_of_mem i hi
  have hg2 : g ∈ {f : ℕ → R | (∃ N, ∀ k ≥ N, f k = 0) ∧ ∀ k, f k ∈ ⋃ i, (S i : Set R)} :=
    ⟨hsupp, hmem⟩
  rw [FilteredColimitArity.sheared_product_preserves hmono' 0 (fun i => (S i).zero_mem)] at hg2
  obtain ⟨i, _, hi⟩ := Set.mem_iUnion.mp hg2
  exact ⟨i, hi⟩

end ShearedWittColimit