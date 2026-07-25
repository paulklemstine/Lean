/-
Copyright (c) 2026 Harmonic. All rights reserved.

# Periodic Orbit Classification via Tropical Fixed-Point Constraints

This file proves that the set of period-p configurations for a min-plus
cellular automaton is definable by a finite system of min-plus equalities.

## Main results

* `fixed_periodic_all` — fixed points have all periods
* `min_plus_ca_periodic_definable` — periodic points are min-plus definable
* `periodic_point_with_constraint` — joint periodicity + constraint definability
-/
import Tropical.CA.MinPlusExpr

namespace TropicalCA

/-! ## Periodic Points -/

/-- The set of period-p points: points where f^p(x) = x. -/
def periodicPoints {α : Type*} (f : α → α) (p : ℕ) : Set α :=
  {x | f^[p] x = x}

/-- Fixed points are periodic with any period. -/
theorem fixed_periodic_all {α : Type*} (f : α → α) (x : α)
    (hx : f x = x) (p : ℕ) :
    x ∈ periodicPoints f p := by
  simp only [periodicPoints, Set.mem_setOf_eq]
  induction p with
  | zero => simp
  | succ p ih => rw [Function.iterate_succ_apply']; rw [ih]; exact hx

/-! ## Min-Plus CA -/

abbrev MinPlusCA (m n : ℕ) := MinPlusMap (m * n)

/-! ## Main Definability Theorem -/

/-
**Periodic points of a min-plus CA are defined by min-plus constraints.**

    For a min-plus CA with update rule F, the period-p points satisfy
    F^p(x)_i = x_i for each coordinate i. Since F^p is a min-plus map
    (built by iterated composition), each constraint is a min-plus equality.
    The set of period-p points is therefore a tropical prevariety.
-/
theorem min_plus_ca_periodic_definable {m n : ℕ} (F : MinPlusCA m n) (p : ℕ) :
    ∃ (constraints : List (MinPlusConstraint (m * n))),
      periodicPoints (MinPlusMap.eval F) p = solutionSet constraints := by
  -- By definition of $periodicPoints$, we know that $x \in periodicPoints (MinPlusMap.eval F) p$ if and only if $(F.eval^[p] x) = x$.
  unfold periodicPoints;
  use List.map (fun i => MinPlusConstraint.mk (F.iterate p i) (MinPlusExpr.var i)) (List.finRange (m * n));
  ext; simp +decide [ funext_iff, solutionSet ] ;
  unfold MinPlusConstraint.satisfies; simp +decide [ ← MinPlusMap.eval_iterate ] ;
  rfl

/-- Period-1 (fixed) points are also min-plus definable. -/
theorem min_plus_ca_fixed_definable {m n : ℕ} (F : MinPlusCA m n) :
    ∃ (constraints : List (MinPlusConstraint (m * n))),
      periodicPoints (MinPlusMap.eval F) 1 = solutionSet constraints :=
  min_plus_ca_periodic_definable F 1

/-
Joint periodicity and additional constraints are definable by concatenation.
-/
theorem periodic_point_with_constraint {m n : ℕ} (F : MinPlusCA m n) (p : ℕ)
    (extra : List (MinPlusConstraint (m * n))) :
    ∃ (all : List (MinPlusConstraint (m * n))),
      {v | v ∈ periodicPoints (MinPlusMap.eval F) p ∧ v ∈ solutionSet extra} =
        solutionSet all := by
  -- Use min_plus_ca_periodic_definable to get periodic constraints, then concatenate with extra. The solution set of the concatenated list equals the intersection of the two solution sets.
  obtain ⟨periodic, periodic_eq⟩ := min_plus_ca_periodic_definable F p;
  use periodic ++ extra;
  simp [periodic_eq, solutionSet];
  exact Set.ext fun x => ⟨ fun hx c hc => by cases hc <;> aesop, fun hx => ⟨ fun c hc => hx c <| Or.inl hc, fun c hc => hx c <| Or.inr hc ⟩ ⟩

end TropicalCA