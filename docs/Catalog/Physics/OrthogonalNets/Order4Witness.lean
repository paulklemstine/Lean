/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# An explicit saturated family of order four

Order `4 = 2²` is the smallest order that is a prime power but not a prime, so it is the
smallest case in which the abstract Galois-field construction of
`Physics.OrthogonalNets.FieldMOLS` is genuinely needed (the cyclic table `a * i + j` over
`ZMod 4` is not Latin for `a = 2`).

This file records a *concrete, kernel-checked* witness: the three squares below are Latin
and pairwise orthogonal, so they saturate the Euler–MacNeish ceiling `n - 1 = 3` at order
four, and — by `existsUnique_line_join` — they coordinatize an affine plane of order four
with `20` lines of `4` points each.  All verifications are by `decide`, i.e. by kernel
evaluation of the finite predicates involved.
-/

import Physics.OrthogonalNets.AffinePlane

namespace Catalog.Physics.OrthogonalNets

open Catalog.Computation.ReticulationMOLS

/-- Three explicit order-four squares, the multiplication-by-`a` tables of `GF(4)`. -/
def sq4 : Fin 3 → Fin 4 → Fin 4 → Fin 4
  | 0 => ![![0, 1, 2, 3], ![1, 0, 3, 2], ![2, 3, 0, 1], ![3, 2, 1, 0]]
  | 1 => ![![0, 2, 3, 1], ![1, 3, 2, 0], ![2, 0, 1, 3], ![3, 1, 0, 2]]
  | 2 => ![![0, 3, 1, 2], ![1, 2, 0, 3], ![2, 1, 3, 0], ![3, 0, 2, 1]]

/-- The three explicit squares form a saturated family of mutually orthogonal Latin squares
of order four. -/
def mols4 : MOLS 4 3 where
  L := sq4
  latin := by
    unfold IsLatin
    decide
  ortho := by
    unfold Orthogonal
    decide

/-- The maximum number of mutually orthogonal Latin squares of order four is exactly
`3`: the explicit family attains the Euler–MacNeish ceiling `n - 1`. -/
theorem mols4_isGreatest : IsGreatest {k : ℕ | Nonempty (MOLS 4 k)} 3 :=
  ⟨⟨mols4⟩, fun _ hk => by simpa using main_MOLS_bound (by norm_num) hk.some⟩

/-- The explicit family coordinatizes an affine plane of order four: two distinct cells of
the `4 × 4` grid lie on exactly one line. -/
theorem mols4_affinePlane (p q : Fin 4 × Fin 4) (hpq : p ≠ q) :
    ∃! ℓ : Line 4 3, OnLine mols4 ℓ p ∧ OnLine mols4 ℓ q :=
  existsUnique_line_join rfl hpq

/-- The plane of order four has `20 = 4² + 4` lines. -/
theorem mols4_card_lines : Fintype.card (Line 4 3) = 4 ^ 2 + 4 :=
  card_Line_saturated rfl (by norm_num)

/-- Every one of its lines has exactly `4` points. -/
theorem mols4_card_line (ℓ : Line 4 3) : Nat.card {p : Fin 4 × Fin 4 // OnLine mols4 ℓ p} = 4 :=
  card_line mols4 ℓ

end Catalog.Physics.OrthogonalNets