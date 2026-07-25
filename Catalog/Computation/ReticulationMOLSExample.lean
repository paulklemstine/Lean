/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Sharpness of the MOLS bound at order three

The general theorem `main_MOLS_bound` shows that a set of mutually orthogonal Latin squares of
order `n ≥ 2` has at most `n - 1` members.  This companion file certifies that the bound is
**attained** at order `3`: we exhibit an explicit pair of mutually orthogonal Latin squares of
order `3`, namely the two affine tables

  `A i j = i + j`      and      `B i j = 2·i + j`      (arithmetic in `Fin 3`),

and assemble them into a `MOLS 3 2` witness.  Since `3 - 1 = 2`, this shows the family size `2`
is achievable, so `main_MOLS_bound` is sharp for `n = 3`.

-- !-- Lab Notes -- !--
HYPOTHESIS.  Over the field structure of `Fin 3`, the affine maps `x ↦ a·x + j` for distinct
slopes `a` are pairwise orthogonal; taking slopes `1` and `2` (the two nonzero elements) yields a
complete set of `n - 1 = 2` MOLS.

EXPERIMENT.  The Latin property of each table reduces to bijectivity of `+`-translations and of
multiplication by the unit `2`; orthogonality is a finite bijectivity check on the `9`-cell grid,
discharged by exhaustive evaluation (`Finite.injective_iff_bijective` turns bijectivity of the
pairing map into a decidable injectivity statement).

ANALYSIS.  Combined with `main_MOLS_bound hn (order 3) : k ≤ 2`, the witness `MOLS 3 2` pins the
maximum family size at order `3` to exactly `2`.  This is the smallest nontrivial confirmation that
the "-1" in the bound is essential and not an artifact.
-- !-- End Lab Notes -- !--
-/

import Mathlib
import Computation.ReticulationMOLS

namespace Catalog.Computation.ReticulationMOLS

open Function

/-- The second affine square `B i j = 2·i + j` over `Fin 3` is a Latin square. -/
theorem affine_two_isLatin : IsLatin 3 (fun i j => 2 * i + j) := by
  have hrow : ∀ i : Fin 3, Injective (fun j : Fin 3 => 2 * i + j) := by decide
  have hcol : ∀ j : Fin 3, Injective (fun i : Fin 3 => 2 * i + j) := by decide
  exact ⟨fun i => (Finite.injective_iff_bijective).mp (hrow i),
         fun j => (Finite.injective_iff_bijective).mp (hcol j)⟩

/-- The tables `A i j = i + j` and `B i j = 2·i + j` are orthogonal over `Fin 3`. -/
theorem affine_orthogonal : Orthogonal 3 (fun i j => i + j) (fun i j => 2 * i + j) := by
  rw [Orthogonal, ← Finite.injective_iff_bijective]
  decide

/-- An explicit set of two mutually orthogonal Latin squares of order `3`. -/
noncomputable def mols3 : MOLS 3 2 where
  L := ![(fun i j => i + j), (fun i j => 2 * i + j)]
  latin := by
    intro s
    fin_cases s
    · exact cyclicLatin_isLatin 3
    · exact affine_two_isLatin
  ortho := by
    intro s t hst
    have hBA : Orthogonal 3 (fun i j => 2 * i + j) (fun i j => i + j) := by
      have hAB := affine_orthogonal
      rw [Orthogonal, ← Finite.injective_iff_bijective] at hAB ⊢
      exact fun a b hab => hAB (Prod.ext (congrArg Prod.snd hab) (congrArg Prod.fst hab))
    fin_cases s <;> fin_cases t <;> simp_all
    exact affine_orthogonal

/-- **Sharpness at order 3.**  The maximum size of a set of MOLS of order `3` is exactly `2`:
a family of size `2` exists (`mols3`), and every family has size at most `2`
(`main_MOLS_bound`). -/
theorem mols_order3_sharp : Nonempty (MOLS 3 2) ∧ ∀ k, MOLS 3 k → k ≤ 2 :=
  ⟨⟨mols3⟩, fun _ S => by have := main_MOLS_bound (n := 3) (by norm_num) S; omega⟩

end Catalog.Computation.ReticulationMOLS