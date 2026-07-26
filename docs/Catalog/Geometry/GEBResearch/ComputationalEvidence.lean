import Mathlib
import Geometry.GEBResearch.IsomorphismAcrossDomains

/-!
# Computational evidence for universal Boolean presentations

For `n` codes there are `n` rows in an evaluation table, but there are
`2^n` Boolean predicates on those codes.  The table below records the first
six pairs.  These finite checks motivated the general diagonal obstruction in
`no_boolean_universal_presentation`.
-/

namespace GEB.Evidence

/-- Number of rows available and Boolean predicates requiring representation. -/
def booleanPresentationCounts (n : ℕ) : ℕ × ℕ := (n, 2 ^ n)

#eval (List.range 7).map fun n => (n, booleanPresentationCounts n)

/-- The first seven computed pairs are explicit, reproducible evidence. -/
example : (List.range 7).map (fun n => (n, booleanPresentationCounts n)) =
    [(0, (0, 1)), (1, (1, 2)), (2, (2, 4)), (3, (3, 8)),
     (4, (4, 16)), (5, (5, 32)), (6, (6, 64))] := by
  native_decide

/-- Every tested positive size has fewer rows than Boolean predicates. -/
example : ∀ n ∈ List.range 7, 0 < n →
    (booleanPresentationCounts n).1 < (booleanPresentationCounts n).2 := by
  native_decide

/-- The exhaustive finite pattern is explained uniformly by diagonalization,
including infinite code types where counting is unavailable. -/
theorem counterexample_hunt_closes_for_every_type (A : Type*) :
    IsEmpty (Presentation A Bool) :=
  no_boolean_universal_presentation A

end GEB.Evidence