import Mathlib
import Logic.StrangeLoops.Core
import Bridges.SPBBridge.AlgebraicIdentities
import Pythagorean.TropicalAlgebra.TropicalSPB

/-!
# Tropical SPB: Structure and Properties

The tropicalization of spb(x,y) = (x+y)/(1-xy) gives
tspb(x,y) = max(x,y) - max(0, x+y).

## Main Results
- Commutativity of tropical SPB
- For nonneg inputs: tspb = -min
- For nonpos inputs: tspb = max
- Partial idempotency for nonpositive inputs
- No global identity element exists
- tspb(x, 0) = 0 for all x ≥ 0 (so 0 is NOT a global identity)
-/

noncomputable section
open Real SPBResearch

namespace TropicalSPBResults

/-- Tropical SPB is commutative. -/
theorem tspb_comm (x y : ℝ) : tspb x y = tspb y x := by
  unfold tspb; simp [max_comm, add_comm]

/-- tspb for non-negative inputs: tspb(x,y) = -min(x,y) when x,y ≥ 0. -/
theorem tspb_nonneg (x y : ℝ) (hx : 0 ≤ x) (hy : 0 ≤ y) :
    tspb x y = -min x y := by
  unfold tspb; cases le_total x y <;> simp +decide [ * ] ;
  · rw [ max_eq_right ] <;> linarith;
  · rw [ max_eq_right ] <;> linarith

/-- tspb for non-positive inputs: tspb(x,y) = max(x,y). -/
theorem tspb_nonpos (x y : ℝ) (hx : x ≤ 0) (hy : y ≤ 0) :
    tspb x y = max x y := by
  unfold tspb; cases max_cases x y <;> simp +decide [ * ] ;
  · linarith;
  · linarith

/-- tspb(x, 0) = 0 for x ≥ 0 (0 absorbs nonnegative inputs). -/
theorem tspb_zero_nonneg (x : ℝ) (hx : 0 ≤ x) : tspb x 0 = 0 := by
  unfold tspb; grind

/-
tspb(x, 0) = 0 for ALL x. So 0 is an absorbing element, not an identity.
-/
theorem tspb_zero_absorb (x : ℝ) : tspb x 0 = 0 := by
  unfold tspb;
  grind

/-
No global identity element exists for tspb.
    Proof: For any e, tspb(1, e) ≠ 1 for most e since
    tspb is bounded above by max(1, e) which would need to equal 1
    but also requires max(0, 1+e) subtracted.
-/
theorem tspb_no_global_identity :
    ¬ ∃ e : ℝ, ∀ x : ℝ, tspb x e = x := by
  simp +zetaDelta at *;
  intro x;
  by_cases hx : x ≤ 0;
  · unfold tspb;
    exact ⟨ x - 1, by cases max_cases ( x - 1 ) x <;> cases max_cases 0 ( x - 1 + x ) <;> linarith ⟩;
  · exact ⟨ 1, by unfold tspb; cases max_cases ( 1 : ℝ ) x <;> cases max_cases ( 0 : ℝ ) ( 1 + x ) <;> linarith ⟩

/-
tspb partial idempotency: tspb(x,x) = x for x ≤ 0.
-/
theorem tspb_idempotent_nonpos (x : ℝ) (hx : x ≤ 0) : tspb x x = x := by
  unfold tspb; norm_num; cases max_cases x x <;> cases max_cases 0 ( 2 * x ) <;> linarith;

/-
tspb(x,x) = -x for x ≥ 0.
-/
theorem tspb_self_nonneg (x : ℝ) (hx : 0 ≤ x) : tspb x x = -x := by
  unfold tspb
  simp [max_self, hx]

/-- Specific computation: tspb(1,1) = -1. -/
theorem tspb_one_one : tspb 1 1 = -1 := by
  unfold tspb; norm_num [max_def]

end TropicalSPBResults
end