/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Mutually Orthogonal Latin Squares, Reticulations, and Cooperative Systems

This file develops the combinatorial theory surrounding *mutually orthogonal Latin squares*
(MOLS), the objects that sit at the heart of the study of nets, orthogonal arrays, and their
common generalizations (reticulations and cooperative systems).

A **Latin square** of order `n` is an `n × n` array whose entries lie in an `n`-element symbol
set and in which every symbol occurs exactly once in each row and exactly once in each column.
Two Latin squares `L` and `M` are **orthogonal** when the `n²` ordered pairs
`(L i j, M i j)` are pairwise distinct — equivalently, every possible pair of symbols occurs
exactly once as one ranges over all cells.  A family of Latin squares that are pairwise
orthogonal is called a set of **mutually orthogonal Latin squares** (MOLS).

The central classical theorem, and the flagship result of this file, is the sharp upper bound

  `main_MOLS_bound` :  a set of MOLS of order `n ≥ 2` contains at most `n - 1` squares.

We also record:

  * `cyclicLatin_isLatin`   : the addition table `L i j = i + j` of the cyclic group `Fin n` is
    a Latin square, giving existence in every positive order;
  * `Orthogonal` / `IsLatin` : clean predicate-level definitions matching the "cooperative system"
    viewpoint (row-Latin ⟂ column-Latin);
  * `orthogonal_relabel` and `latin_relabel` : the symmetry of the theory under relabeling of
    symbols, which is exactly the freedom used to normalize a net.

-- !-- Lab Notes -- !--
HYPOTHESIS.  For a set of MOLS of order `n ≥ 2`, the cell `(1,0)` (second row, first column)
carries just enough information to injectively tag each square with a *nonzero* column index of the
first row; hence there can be at most `n - 1` squares.

EXPERIMENTAL PLAN.
  (1) Encode Latin squares as `L : Fin n → Fin n → Fin n` with both rows and columns bijective,
      and orthogonality of `L, M` as bijectivity of `(i,j) ↦ (L i j, M i j)`.
  (2) For each square `s`, invert its first row (a permutation of symbols) to obtain
      `cornerTag s`, the column of the first row whose symbol equals the `(1,0)`-entry.
  (3) Show `cornerTag s ≠ 0` (else column `0` repeats a symbol — contradicts column-Latin), and
  (4) show `s ↦ cornerTag s` is injective (else two cells produce the same ordered pair —
      contradicts orthogonality), forcing the index set into an `(n-1)`-element set.

ANALYSIS.  Both steps (3) and (4) are pure consequences of injectivity — of a *column* in step (3)
and of the *pairing map* in step (4).  The corner `(1,0)` is the unique off-diagonal cell whose
row differs from row `0`; that single fact drives the whole argument, since the produced witness
cell `(0, cornerTag s)` always lies in row `0` and therefore differs from `(1,0)`.

CRITIQUE.  The bound `n - 1` (rather than the trivial `n`) hinges entirely on `cornerTag s ≠ 0`;
without step (3) one only recovers `k ≤ n`.  The statement is not vacuous: `cyclicLatin_isLatin`
provides genuine Latin squares, and complete MOLS families attaining `n - 1` exist for every
prime-power order, so the bound is sharp.

INSIGHT.  Normalization by relabeling is *not* needed: inverting the first row on the fly turns
the classical "standardize then read the corner" proof into two short pigeonhole steps.  This is
the same freedom a reticulation enjoys when one of its line families is permuted, recorded here as
`latin_relabel` and `orthogonal_relabel`.
-- !-- End Lab Notes -- !--
-/

import Mathlib

namespace Catalog.Computation.ReticulationMOLS

open Function

/-! ## Latin squares and orthogonality -/

/-- `L : Fin n → Fin n → Fin n` is a **Latin square** when every row and every column is a
bijection of the symbol set `Fin n`. -/
def IsLatin (n : ℕ) (L : Fin n → Fin n → Fin n) : Prop :=
  (∀ i, Bijective fun j => L i j) ∧ (∀ j, Bijective fun i => L i j)

/-- Two order-`n` arrays are **orthogonal** when the pairing map `(i,j) ↦ (L i j, M i j)`
is a bijection of `Fin n × Fin n`; i.e. every ordered pair of symbols occurs exactly once. -/
def Orthogonal (n : ℕ) (L M : Fin n → Fin n → Fin n) : Prop :=
  Bijective fun p : Fin n × Fin n => (L p.1 p.2, M p.1 p.2)

/-- A set of **mutually orthogonal Latin squares** of order `n`: a `k`-indexed family of Latin
squares that are pairwise orthogonal. -/
structure MOLS (n k : ℕ) where
  /-- The indexed family of arrays. -/
  L : Fin k → Fin n → Fin n → Fin n
  /-- Each member is a Latin square. -/
  latin : ∀ s, IsLatin n (L s)
  /-- Distinct members are orthogonal. -/
  ortho : ∀ s t, s ≠ t → Orthogonal n (L s) (L t)

/-! ## Relabeling symmetry -/

/-- Relabeling the symbols of a Latin square by a bijection yields a Latin square. -/
theorem latin_relabel {n : ℕ} {L : Fin n → Fin n → Fin n} (hL : IsLatin n L)
    {σ : Fin n → Fin n} (hσ : Bijective σ) :
    IsLatin n (fun i j => σ (L i j)) :=
  ⟨fun i => hσ.comp (hL.1 i), fun j => hσ.comp (hL.2 j)⟩

/-- Relabeling the symbols of two arrays (independently) preserves orthogonality. -/
theorem orthogonal_relabel {n : ℕ} {L M : Fin n → Fin n → Fin n} (h : Orthogonal n L M)
    {σ τ : Fin n → Fin n} (hσ : Bijective σ) (hτ : Bijective τ) :
    Orthogonal n (fun i j => σ (L i j)) (fun i j => τ (M i j)) :=
  (hσ.prodMap hτ).comp h

/-! ## Existence: the cyclic Latin square -/

/-- The addition table `L i j = i + j` of the cyclic group `Fin n` is a Latin square of order
`n`.  This exhibits a Latin square in every positive order. -/
theorem cyclicLatin_isLatin (n : ℕ) [NeZero n] :
    IsLatin n (fun i j => i + j) :=
  ⟨fun i => (Equiv.addLeft i).bijective, fun j => (Equiv.addRight j).bijective⟩

/-! ## The MOLS bound -/

/-- **Key tag.**  Given a set of MOLS of order `n ≥ 2`, invert the first row of square `s`
(a permutation of symbols since rows are bijective) and read off the column whose first-row
symbol matches the `(1,0)`-entry of `s`. -/
noncomputable def cornerTag {n k : ℕ} (hn : 2 ≤ n) (S : MOLS n k) (s : Fin k) : Fin n :=
  (Equiv.ofBijective (fun j => S.L s ⟨0, by omega⟩ j) ((S.latin s).1 ⟨0, by omega⟩)).symm
    (S.L s ⟨1, by omega⟩ ⟨0, by omega⟩)

/-- The corner tag is never the first column `0`: otherwise column `0` would contain the same
symbol in rows `0` and `1`, contradicting the column-Latin property. -/
theorem cornerTag_ne_zero {n k : ℕ} (hn : 2 ≤ n) (S : MOLS n k) (s : Fin k) :
    cornerTag hn S s ≠ ⟨0, by omega⟩ := by
  intro h
  have hrow := ((S.latin s).1 ⟨0, by omega⟩)
  set e := Equiv.ofBijective (fun j => S.L s ⟨0, by omega⟩ j) hrow with he
  have h1 : e.symm (S.L s ⟨1, by omega⟩ ⟨0, by omega⟩) = ⟨0, by omega⟩ := h
  have h2 : S.L s ⟨1, by omega⟩ ⟨0, by omega⟩ = e ⟨0, by omega⟩ := by
    rw [← e.apply_symm_apply (S.L s ⟨1, by omega⟩ ⟨0, by omega⟩), h1]
  have h3 : e ⟨0, by omega⟩ = S.L s ⟨0, by omega⟩ ⟨0, by omega⟩ := rfl
  have h4 : S.L s ⟨1, by omega⟩ ⟨0, by omega⟩ = S.L s ⟨0, by omega⟩ ⟨0, by omega⟩ := by
    rw [h2, h3]
  have hcontra := ((S.latin s).2 ⟨0, by omega⟩).1 h4
  simp only [Fin.mk.injEq] at hcontra
  omega

/-- The corner tag is injective across the family: if two squares share a corner tag `c`, then the
cells `(0, c)` and `(1, 0)` produce the same ordered pair under the two squares, contradicting
their orthogonality. -/
theorem cornerTag_injective {n k : ℕ} (hn : 2 ≤ n) (S : MOLS n k) :
    Injective (cornerTag hn S) := by
  intro s t hst
  by_contra hne
  have hortho := S.ortho s t hne
  have hrows := ((S.latin s).1 ⟨0, by omega⟩)
  have hrowt := ((S.latin t).1 ⟨0, by omega⟩)
  set es := Equiv.ofBijective (fun j => S.L s ⟨0, by omega⟩ j) hrows with hes
  set et := Equiv.ofBijective (fun j => S.L t ⟨0, by omega⟩ j) hrowt with het
  set c : Fin n := cornerTag hn S s with hc
  have hct : cornerTag hn S t = c := hst.symm
  have hs1 : S.L s ⟨0, by omega⟩ c = S.L s ⟨1, by omega⟩ ⟨0, by omega⟩ := by
    have : es c = S.L s ⟨1, by omega⟩ ⟨0, by omega⟩ := by rw [hc]; exact es.apply_symm_apply _
    exact this
  have ht1 : S.L t ⟨0, by omega⟩ c = S.L t ⟨1, by omega⟩ ⟨0, by omega⟩ := by
    have : et c = S.L t ⟨1, by omega⟩ ⟨0, by omega⟩ := by rw [← hct]; exact et.apply_symm_apply _
    exact this
  have hpair : (S.L s ⟨0, by omega⟩ c, S.L t ⟨0, by omega⟩ c)
      = (S.L s ⟨1, by omega⟩ ⟨0, by omega⟩, S.L t ⟨1, by omega⟩ ⟨0, by omega⟩) := by
    rw [hs1, ht1]
  have hpos := hortho.1 (a₁ := (⟨0, by omega⟩, c)) (a₂ := (⟨1, by omega⟩, ⟨0, by omega⟩)) hpair
  rw [Prod.mk.injEq] at hpos
  have hcontra := hpos.1
  simp only [Fin.mk.injEq] at hcontra
  omega

/-- **Main theorem.**  A set of mutually orthogonal Latin squares of order `n ≥ 2` has at most
`n - 1` members.  The corner tag injects the index set into the `(n-1)`-element set of nonzero
first-row columns. -/
theorem main_MOLS_bound {n k : ℕ} (hn : 2 ≤ n) (S : MOLS n k) : k ≤ n - 1 := by
  let f : Fin k → {x : Fin n // x ≠ (⟨0, by omega⟩ : Fin n)} :=
    fun s => ⟨cornerTag hn S s, cornerTag_ne_zero hn S s⟩
  have hfinj : Injective f := fun a b hab => cornerTag_injective hn S (Subtype.ext_iff.mp hab)
  have hcard := Fintype.card_le_of_injective f hfinj
  rw [Fintype.card_fin] at hcard
  have hsub : Fintype.card {x : Fin n // x ≠ (⟨0, by omega⟩ : Fin n)} = n - 1 := by
    rw [Fintype.card_subtype_compl]; simp
  omega

end Catalog.Computation.ReticulationMOLS