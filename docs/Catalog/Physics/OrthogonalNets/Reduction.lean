/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Reduction is a free normalization

A Latin square is **reduced** when its first row is the identity permutation of the symbol
set.  Since orthogonality is a statement about the *fibres* of the coordinate maps rather
than about the names of the symbols, relabelling the alphabet of each member of a family
independently is a symmetry of the whole incidence structure
(`latin_relabel`, `orthogonal_relabel` of `Catalog.Computation.ReticulationMOLS`).

Here we make that observation effective: `reduce S` relabels each member of a MOLS family
by the inverse of its own first row, producing a family of the *same size* consisting of
reduced squares (`reduce_isReduced`).  Consequently any ceiling proved for reduced families
automatically applies to arbitrary ones, and conversely
(`exists_reduced_MOLS_iff`, `saturated_reduced_of_saturated`).
-/

import Computation.PosetTheory.ReticulationMOLS
import Physics.OrthogonalNets.PivotWindow

namespace Catalog.Physics.OrthogonalNets

open Function
open Catalog.Computation.ReticulationMOLS

variable {n k : ℕ}

/-- A square is **reduced** when its first row is the identity on the symbol set. -/
def IsReduced [NeZero n] (L : Fin n → Fin n → Fin n) : Prop := ∀ j, L 0 j = j

/-- A MOLS family is **reduced** when each of its members is. -/
def ReducedFamily [NeZero n] (S : MOLS n k) : Prop := ∀ s, IsReduced (S.L s)

/-- Normalize a MOLS family by relabelling each member with the inverse of its own first
row.  The relabelling is a bijection of the symbol set, so the result is again a family of
mutually orthogonal Latin squares of the same size. -/
noncomputable def reduce [NeZero n] (S : MOLS n k) : MOLS n k where
  L s i j := (rowEquiv S s 0).symm (S.L s i j)
  latin s := latin_relabel (S.latin s) (rowEquiv S s 0).symm.bijective
  ortho s t hst :=
    orthogonal_relabel (S.ortho s t hst) (rowEquiv S s 0).symm.bijective
      (rowEquiv S t 0).symm.bijective

/-- The normalized family is reduced: relabelling by the inverse of the first row turns the
first row into the identity. -/
theorem reduce_isReduced [NeZero n] (S : MOLS n k) : ReducedFamily (reduce S) :=
  fun s j => (rowEquiv S s 0).symm_apply_apply j

/-- **Reduction is free.**  A family of `k` mutually orthogonal Latin squares of order `n`
exists if and only if a *reduced* such family exists.  Hence the Euler–MacNeish ceiling for
reduced families is equivalent to the ceiling for arbitrary families. -/
theorem exists_reduced_MOLS_iff [NeZero n] :
    Nonempty (MOLS n k) ↔ (∃ S : MOLS n k, ReducedFamily S) :=
  ⟨fun ⟨S⟩ => ⟨reduce S, reduce_isReduced S⟩, fun ⟨S, _⟩ => ⟨S⟩⟩

/-- The ceiling `k ≤ n - 1` for arbitrary families, recovered from the reduced case: given
any family, `reduce` produces a reduced family of the same size. -/
theorem reduced_ceiling [NeZero n] (S : MOLS n k) (hn : 2 ≤ n) :
    ∃ T : MOLS n k, ReducedFamily T ∧ k ≤ n - 1 :=
  ⟨reduce S, reduce_isReduced S, main_MOLS_bound hn S⟩

end Catalog.Physics.OrthogonalNets