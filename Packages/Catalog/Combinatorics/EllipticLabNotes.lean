/-
# Lab notes: kernel-verified numerical experiments

Every statement in this file is checked by the Lean **kernel** (`decide`, no
`native_decide`), and each one is a concrete instance of, or a finite test of, the general
theorems in

* `Combinatorics.EllipticPointCount`,
* `Combinatorics.EllipticModP`,
* `Combinatorics.EllipticSecondMoment`,
* `Combinatorics.EllipticVerticalMoment`.

Two of the experiments test statements we do **not** prove in general:

* `hasse_F13` and friends verify the Hasse bound `a_p^2 ≤ 4p` for *every* curve in the
  family over `F_5, F_7, F_11, F_13`.  Hasse's theorem is far beyond the elementary
  character-sum toolkit developed here, so these are genuine experimental checks.
* `second_moment_F5` / `second_moment_F7` confirm the exact second moment `q^3 - q^2`
  proved in `EllipticSecondMoment.second_moment_charSum`.
-/
import Mathlib
import Combinatorics.EllipticPointCount

namespace EllipticModCount

open Finset

instance : Fact (Nat.Prime 5) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 7) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 11) := ⟨by norm_num⟩
instance : Fact (Nat.Prime 13) := ⟨by norm_num⟩

/-! ### Hasse's bound, verified exhaustively for small primes -/

theorem hasse_F5 : ∀ a b : ZMod 5, (frobTrace a b) ^ 2 ≤ 4 * 5 := by decide

theorem hasse_F7 : ∀ a b : ZMod 7, (frobTrace a b) ^ 2 ≤ 4 * 7 := by decide

theorem hasse_F11 : ∀ a b : ZMod 11, (frobTrace a b) ^ 2 ≤ 4 * 11 := by decide

theorem hasse_F13 : ∀ a b : ZMod 13, (frobTrace a b) ^ 2 ≤ 4 * 13 := by decide

/-! ### The exact second moment `∑_{a,b} a(a,b)^2 = q^3 - q^2` -/

theorem second_moment_F5 : ∑ a : ZMod 5, ∑ b : ZMod 5, (frobTrace a b) ^ 2 = 5 ^ 3 - 5 ^ 2 := by
  decide

theorem second_moment_F7 : ∑ a : ZMod 7, ∑ b : ZMod 7, (frobTrace a b) ^ 2 = 7 ^ 3 - 7 ^ 2 := by
  decide

/-! ### The supersingular families -/

/-- `11 % 3 = 2`: every curve `y^2 = x^3 + b` over `F_11` has exactly `12` points. -/
theorem supersingular_cube_F11 : ∀ b : ZMod 11, cardPoints 0 b = 12 := by decide

/-- `11 % 4 = 3`: every curve `y^2 = x^3 + a*x` over `F_11` has exactly `12` points. -/
theorem supersingular_linear_F11 : ∀ a : ZMod 11, cardPoints a 0 = 12 := by decide

/-- By contrast `13 % 3 = 1` and `13 % 4 = 1`, and the counts genuinely vary. -/
theorem not_supersingular_F13 : cardPoints (0 : ZMod 13) 1 ≠ cardPoints (0 : ZMod 13) 2 := by
  decide

/-! ### The parity / 2-torsion criterion -/

/-- `y^2 = x^3 + 1` over `F_5`: the cubic has the root `x = -1`, and the point count `6`
is even, as `two_dvd_cardPoints_iff` predicts. -/
theorem torsion_example_F5 :
    (∃ x : ZMod 5, x ^ 3 + 0 * x + 1 = 0) ∧ 2 ∣ cardPoints (0 : ZMod 5) 1 := by decide

/-- `y^2 = x^3 + x + 1` over `F_5` has `9` points, an odd number, and indeed the cubic has
no root in `F_5`. -/
theorem torsion_example_F5' :
    (¬ ∃ x : ZMod 5, x ^ 3 + 1 * x + 1 = 0) ∧ cardPoints (1 : ZMod 5) 1 = 9 := by decide

/-- **Sharpness of the nonsingularity hypothesis.** The *singular* curve
`y^2 = x^3 + 2x + 2 = (x-1)^2 (x+2)` over `F_5` has discriminant `0`, has a root, has
exactly two distinct roots, and has an **odd** number of points (`7`).  So the hypothesis
`disc a b ≠ 0` in `two_dvd_cardPoints_iff` and in `rootSet_card_cases` cannot be dropped. -/
theorem singular_counterexample_F5 :
    disc (2 : ZMod 5) 2 = 0 ∧ (∃ x : ZMod 5, x ^ 3 + 2 * x + 2 = 0)
      ∧ (rootSet (2 : ZMod 5) 2).card = 2 ∧ ¬ (2 ∣ cardPoints (2 : ZMod 5) 2) := by decide

/-! ### Quadratic twisting -/

/-- `2` is a nonsquare mod `5`; the curve `y^2 = x^3+x+1` and its quadratic twist by `2`
have `9` and `3` points, summing to `2 * 5 + 2 = 12`. -/
theorem twist_example_F5 :
    cardPoints (1 : ZMod 5) 1 + cardPoints (1 * 2 ^ 2 : ZMod 5) (1 * 2 ^ 3) = 2 * 5 + 2 := by
  decide

end EllipticModCount