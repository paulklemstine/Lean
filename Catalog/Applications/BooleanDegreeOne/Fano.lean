/-
Copyright (c) 2025. All rights reserved.

# A Concrete Instance: the Fano Plane `PG(2,2) = J_2(3,2)`

The smallest projective plane, the Fano plane `PG(2,2)`, is exactly the Grassmann
scheme `J_2(3,2)`: its `7` points are the `1`-dimensional subspaces of `F_2^3`
and its `7` lines are the `2`-dimensional subspaces, each carrying `q + 1 = 3`
points, with any two points on a unique line.  It is the smallest nondegenerate
instance of the abstract `LinearSpace` set up in `Core.lean`, and the only one
small enough to settle every incidence axiom by `decide`.

We verify the Fano plane satisfies the structural hypotheses of `Core.lean` and
specialise the existence theorem: there are at least `7 + 2 = 9` Boolean degree
one functions on `J_2(3,2)`.

-- !-- Lab Notes -- !--
-- EXPERIMENT.  Encode the standard `7`-line Fano incidence on `Fin 7` and let
--   `decide` check: uniform line size `3`, the unique-line axiom, and the three
--   separation hypotheses.  All pass by `decide` (kernel-checked, no `native`).
-- OUTCOME.  `fano_exists_many_BDO` instantiates `exists_many_BDO`, certifying
--   `9` pairwise-distinct Boolean degree one functions for `q = 2`, `n = 3`.
-- INSIGHT / CONTRAST.  `q = 2` is the *exceptional* regime: it is precisely here
--   that genuinely non-trivial Boolean degree one functions are known to appear
--   on Grassmann schemes, in contrast with the conjectured rigidity for `q ≥ 3`.
--   The Fano instance is thus the natural smallest laboratory and the boundary
--   case against which the `q ≥ 3` non-existence conjecture must be tested.
-- !-- end Lab Notes -- !--
-/
import Catalog.Applications.BooleanDegreeOne.Core

namespace Catalog.Applications.BooleanDegreeOne.Fano

open Catalog.Applications.BooleanDegreeOne

/-- The 7 lines of the Fano plane, each a 3-element subset of the 7 points
`Fin 7`, in the standard labelling. -/
def lines : Fin 7 → Finset (Fin 7) :=
  ![{0, 1, 2}, {0, 3, 4}, {0, 5, 6}, {1, 3, 5}, {1, 4, 6}, {2, 3, 6}, {2, 4, 5}]

/-- Every Fano line has `q + 1 = 3` points. -/
theorem lines_card : ∀ ℓ : Fin 7, (lines ℓ).card = 2 + 1 := by decide

/-- Any two distinct points of the Fano plane lie on a unique common line. -/
theorem lines_two_points :
    ∀ p₁ p₂ : Fin 7, p₁ ≠ p₂ → ∃! ℓ : Fin 7, p₁ ∈ lines ℓ ∧ p₂ ∈ lines ℓ := by
  simp only [ExistsUnique]; decide

/-- Every point lies on some Fano line. -/
theorem lines_through : ∀ p : Fin 7, ∃ ℓ, p ∈ lines ℓ := by decide

/-- Every point is avoided by some Fano line. -/
theorem lines_avoiding : ∀ p : Fin 7, ∃ ℓ, p ∉ lines ℓ := by decide

/-- Distinct points of the Fano plane can be separated by a line. -/
theorem lines_separating :
    ∀ p p' : Fin 7, p ≠ p' → ∃ ℓ, p ∈ lines ℓ ∧ p' ∉ lines ℓ := by decide

/-- **At least `9` Boolean degree one functions on `J_2(3,2)`.**  Specialising
`exists_many_BDO` to the Fano plane yields an injection `Fin 7 ⊕ Bool ↪
{functions}` (the `7` point-pencils together with the two constants) all of whose
images are Boolean degree one. -/
theorem fano_exists_many_BDO :
    ∃ g : Fin 7 ⊕ Bool → (Fin 7 → ℝ),
      Function.Injective g ∧ ∀ x, BooleanDegOne lines (g x) :=
  exists_many_BDO lines lines_through lines_avoiding lines_separating

/-- The sum of two distinct point-pencils on the Fano plane is degree one but not
Boolean (it equals `2` on the unique line through the two points). -/
theorem fano_two_pencils_not_boolean (p p' : Fin 7) (hpp : p ≠ p') :
    ¬ IsBoolean (fun ℓ => ind lines p ℓ + ind lines p' ℓ) :=
  two_pencils_not_boolean lines p p' hpp lines_two_points

end Catalog.Applications.BooleanDegreeOne.Fano