import Mathlib
import Pythagorean.TropicalAlgebra.TropicalSPB

/-! # CatalogBuild.Pythagorean.TropicalAssociativity

Associativity of the tropical special Pythagorean bracket
`tspb x y = max x y - max 0 (x + y)` (defined in
`Pythagorean.TropicalAlgebra.TropicalSPB`, which this file imports rather than
duplicating).

The classical bracket `spb x y = (x+y)/(1-xy)` is associative (it is the
addition law of `tan`), and the tropical shadow inherits this: `tspb` is an
associative, commutative operation on `ℝ` with `0` as an absorbing element.
-/

noncomputable section

/-- The stated counterexample (1,1,-1) is actually an equality. -/
theorem tspb_counterexample_wrong :
    tspb (tspb 1 1) (-1) = tspb 1 (tspb 1 (-1)) := by
  unfold tspb; norm_num

/-- Closed form of the tropical bracket in terms of absolute values. -/
theorem tspb_abs_formula (x y : ℝ) :
    tspb x y = (|x - y| - |x + y|) / 2 := by
  unfold tspb
  cases abs_cases (x - y) <;> cases abs_cases (x + y) <;> cases max_cases x y <;>
    cases max_cases (0:ℝ) (x + y) <;> linarith

set_option maxHeartbeats 2000000 in
/-- The tropical bracket is associative. -/
theorem tspb_assoc (x y z : ℝ) :
    tspb (tspb x y) z = tspb x (tspb y z) := by
  simp only [tspb, max_def]
  split_ifs <;> linarith

end