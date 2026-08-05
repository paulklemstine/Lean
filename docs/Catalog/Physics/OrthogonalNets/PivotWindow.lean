/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The pivot window: displacement permutations of a MOLS family

This file generalizes the *pivot argument* of
`Catalog.Computation.ReticulationMOLS` (which inspects the single corner cell
`(1,0)` of each square) to an arbitrary two-cell window of the coordinate grid.

Fix a family `S` of mutually orthogonal Latin squares of order `n` and two
distinct rows `i₁ ≠ i₂`.  For each member `s` of the family we build the
**displacement permutation**

  `shift S s i₁ i₂ : Fin n ≃ Fin n`,  `S.L s i₂ (shift S s i₁ i₂ j) = S.L s i₁ j`,

which sends a column `j` to the unique column in row `i₂` carrying the symbol
that `s` places at `(i₁, j)`.  Two facts drive everything:

* `shift_ne_self`      : `shift S s i₁ i₂ j ≠ j` (column-Latin property);
* `shift_ne_of_ne`     : `s ≠ t → shift S s i₁ i₂ j ≠ shift S t i₁ i₂ j`
                         (orthogonality of the two squares).

Together they inject the index set of the family into the `(n-1)`-element set of
columns different from `j`, giving `pivot_window_bound : k ≤ n - 1` **at every
window** `(i₁, i₂, j)`, not just at the distinguished corner.

When the family is *saturated*, `k = n - 1`, the injection is forced to be a
bijection (`shift_surjective_of_saturated`), and this yields the key positive
statement `saturated_join`: any two grid cells in different rows *and* different
columns receive a common symbol from some member of the family.  This is exactly
the ingredient needed to turn a complete MOLS family into an affine plane.
-/

import Computation.PosetTheory.ReticulationMOLS

namespace Catalog.Physics.OrthogonalNets

open Function
open Catalog.Computation.ReticulationMOLS

variable {n k : ℕ}

/-! ## Rows as permutations -/

/-- Row `i` of the `s`-th square of a MOLS family, packaged as a permutation of the
symbol set. -/
noncomputable def rowEquiv (S : MOLS n k) (s : Fin k) (i : Fin n) : Fin n ≃ Fin n :=
  Equiv.ofBijective (fun j => S.L s i j) ((S.latin s).1 i)

@[simp] theorem rowEquiv_apply (S : MOLS n k) (s : Fin k) (i j : Fin n) :
    rowEquiv S s i j = S.L s i j := rfl

@[simp] theorem rowEquiv_symm_apply_eq (S : MOLS n k) (s : Fin k) (i j : Fin n) :
    S.L s i ((rowEquiv S s i).symm j) = j :=
  (rowEquiv S s i).apply_symm_apply j

/-- Column `j` of the `s`-th square of a MOLS family, packaged as a permutation of the
symbol set. -/
noncomputable def colEquiv (S : MOLS n k) (s : Fin k) (j : Fin n) : Fin n ≃ Fin n :=
  Equiv.ofBijective (fun i => S.L s i j) ((S.latin s).2 j)

@[simp] theorem colEquiv_apply (S : MOLS n k) (s : Fin k) (i j : Fin n) :
    colEquiv S s j i = S.L s i j := rfl

@[simp] theorem colEquiv_symm_apply_eq (S : MOLS n k) (s : Fin k) (i j : Fin n) :
    S.L s ((colEquiv S s j).symm i) j = i :=
  (colEquiv S s j).apply_symm_apply i

/-! ## Displacement permutations -/

/-- The **displacement permutation** attached to a member `s` of a MOLS family and a pair
of rows `i₁, i₂`: it sends a column `j` to the unique column of row `i₂` carrying the
symbol `S.L s i₁ j`. -/
noncomputable def shift (S : MOLS n k) (s : Fin k) (i₁ i₂ : Fin n) : Fin n ≃ Fin n :=
  (rowEquiv S s i₁).trans (rowEquiv S s i₂).symm

/-- Defining property of the displacement permutation. -/
@[simp] theorem shift_spec (S : MOLS n k) (s : Fin k) (i₁ i₂ j : Fin n) :
    S.L s i₂ (shift S s i₁ i₂ j) = S.L s i₁ j := by
  simp only [shift, Equiv.trans_apply, rowEquiv_apply, rowEquiv_symm_apply_eq]

/-- A displacement permutation between two *distinct* rows has no fixed point: this is the
column-Latin property. -/
theorem shift_ne_self {S : MOLS n k} {s : Fin k} {i₁ i₂ : Fin n} (h : i₁ ≠ i₂) (j : Fin n) :
    shift S s i₁ i₂ j ≠ j := by
  intro hj
  have h1 := shift_spec S s i₁ i₂ j
  rw [hj] at h1
  exact h (((S.latin s).2 j).1 h1).symm

/-- Distinct members of the family have distinct displacements at every column: this is
orthogonality. -/
theorem shift_ne_of_ne {S : MOLS n k} {s t : Fin k} (hst : s ≠ t) {i₁ i₂ : Fin n}
    (h : i₁ ≠ i₂) (j : Fin n) :
    shift S s i₁ i₂ j ≠ shift S t i₁ i₂ j := by
  intro hj
  have h1 : S.L s i₂ (shift S s i₁ i₂ j) = S.L s i₁ j := shift_spec S s i₁ i₂ j
  have h2 : S.L t i₂ (shift S s i₁ i₂ j) = S.L t i₁ j := by
    rw [hj]; exact shift_spec S t i₁ i₂ j
  have hpair :
      (fun p : Fin n × Fin n => (S.L s p.1 p.2, S.L t p.1 p.2)) (i₂, shift S s i₁ i₂ j)
        = (fun p : Fin n × Fin n => (S.L s p.1 p.2, S.L t p.1 p.2)) (i₁, j) := by
    simp only [h1, h2]
  have hcell := (S.ortho s t hst).1 hpair
  exact h (congrArg Prod.fst hcell).symm

/-! ## The window bound -/

/-- The number of columns different from a fixed one. -/
theorem card_ne_subtype (j : Fin n) : Fintype.card {x : Fin n // x ≠ j} = n - 1 := by
  rw [Fintype.card_subtype_compl]; simp

/-- The displacement of a member of the family, tagged as a column different from `j`. -/
noncomputable def shiftTag (S : MOLS n k) {i₁ i₂ : Fin n} (h : i₁ ≠ i₂) (j : Fin n)
    (s : Fin k) : {x : Fin n // x ≠ j} :=
  ⟨shift S s i₁ i₂ j, shift_ne_self h j⟩

/-- **Pivot window bound.**  A family of mutually orthogonal Latin squares of order `n` has
at most `n - 1` members, and the obstruction is visible inside *any* two-cell window
`(i₁, j)`, `(i₂, ·)` with `i₁ ≠ i₂`.  The classical corner argument is the special case
`i₁ = 0`, `i₂ = 1`, `j = 0`. -/
theorem pivot_window_bound (S : MOLS n k) {i₁ i₂ : Fin n} (h : i₁ ≠ i₂) (j : Fin n) :
    k ≤ n - 1 := by
  have hinj : Injective (shiftTag S h j) := by
    intro s t hst
    by_contra hne
    exact shift_ne_of_ne hne h j (Subtype.ext_iff.mp hst)
  have hcard := Fintype.card_le_of_injective _ hinj
  rw [Fintype.card_fin, card_ne_subtype] at hcard
  exact hcard

/-! ## Saturated families -/

/-- In a **saturated** family (`k = n - 1`) the displacement map `s ↦ shift S s i₁ i₂ j`
hits every column different from `j`. -/
theorem shift_surjective_of_saturated {S : MOLS n k} (hk : k = n - 1) {i₁ i₂ : Fin n}
    (h : i₁ ≠ i₂) (j j' : Fin n) (hj : j' ≠ j) :
    ∃ s, shift S s i₁ i₂ j = j' := by
  have hinj : Injective (shiftTag S h j) := by
    intro s t hst
    by_contra hne
    exact shift_ne_of_ne hne h j (Subtype.ext_iff.mp hst)
  have hbij : Bijective (shiftTag S h j) :=
    (Fintype.bijective_iff_injective_and_card _).mpr
      ⟨hinj, by rw [Fintype.card_fin, card_ne_subtype, hk]⟩
  obtain ⟨s, hs⟩ := hbij.2 ⟨j', hj⟩
  exact ⟨s, congrArg Subtype.val hs⟩

/-- **Saturated join.**  In a family of `n - 1` mutually orthogonal Latin squares of order
`n`, any two cells lying in different rows and different columns carry a common symbol in
some member of the family. -/
theorem saturated_join {S : MOLS n k} (hk : k = n - 1) {i₁ i₂ j₁ j₂ : Fin n}
    (hi : i₁ ≠ i₂) (hj : j₁ ≠ j₂) :
    ∃ s, S.L s i₁ j₁ = S.L s i₂ j₂ := by
  obtain ⟨s, hs⟩ := shift_surjective_of_saturated hk hi j₁ j₂ (Ne.symm hj)
  exact ⟨s, by rw [← hs]; exact (shift_spec S s i₁ i₂ j₁).symm⟩

end Catalog.Physics.OrthogonalNets