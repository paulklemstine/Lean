import Geometry.AbstractAlgebra.NonDesarguesianPlanes

/-!
# A proof chain for the Hall plane

This file turns the computed nucleus cardinality in
`Geometry.NonDesarguesianPlanes` into a structural proof of nonassociativity,
and then combines that defect with the strict collineation-order bound.
-/

open Finset Function

namespace NonDesarguesianPlanes

private abbrev HallPoint := ZMod 3 × ZMod 3

/-- The finite collection of elements that associate on the left under Hall
multiplication is a proper subset of all nine elements. -/
theorem hall_associating_finset_proper :
    Finset.univ.filter (fun x : HallPoint =>
      ∀ b c : HallPoint,
        hallMul x (hallMul b c) = hallMul (hallMul x b) c) ≠ Finset.univ := by
  intro h
  have hc := congrArg Finset.card h
  rw [hall_nucleus_card, Finset.card_univ, gf9_card] at hc
  omega

/-- Consequently, the set of left-associating elements is not the whole Hall
quasifield.  This is the set-level form of the nucleus defect. -/
theorem hall_associating_set_proper :
    {x : HallPoint | ∀ b c : HallPoint,
      hallMul x (hallMul b c) = hallMul (hallMul x b) c} ≠ Set.univ := by
  intro h
  apply hall_associating_finset_proper
  ext x
  simp only [Finset.mem_filter, Finset.mem_univ, true_and]
  have hx := Set.ext_iff.mp h x
  simpa only [Set.mem_setOf_eq, Set.mem_univ, iff_true] using hx

/-- A proper left nucleus supplies a concrete triple witnessing the failure of
associativity.  Unlike a direct finite check, this conclusion is obtained from
the preceding cardinality obstruction. -/
theorem hall_nonassociative_from_nucleus :
    ∃ a b c : HallPoint,
      hallMul (hallMul a b) c ≠ hallMul a (hallMul b c) := by
  by_contra h
  push_neg at h
  apply hall_associating_set_proper
  apply Set.eq_univ_iff_forall.mpr
  intro a b c
  exact (h a b c).symm

/-- For every parameter `q ≥ 3`, the Hall construction exhibits both an
algebraic associativity defect and a strict loss of collineation symmetry
relative to `PGL(3,q²)`. -/
theorem hall_algebraic_and_symmetry_defect (q : ℕ) (hq : 3 ≤ q) :
    (∃ a b c : HallPoint,
      hallMul (hallMul a b) c ≠ hallMul a (hallMul b c)) ∧
    hallCollineationOrder q < pglOrder (q ^ 2) := by
  exact ⟨hall_nonassociative_from_nucleus, hall_collineation_lt_pgl q hq⟩

end NonDesarguesianPlanes