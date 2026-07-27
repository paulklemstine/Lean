/-
# Square-lattice self-avoiding walks: a rigorous obstruction to the proposed value

The exact connective constant of the square lattice is not known.  In particular,
the expression `(2 + √2) / 2` in the research prompt cannot be its value: the
square-lattice connective constant is at least `2`, whereas that expression is
strictly less than `2`.

The Nienhuis value `√(2 + √2)` concerns the *hexagonal* lattice, not `ℤ²` with
its four nearest-neighbour edges.  This file proves the obstruction and then
builds a chain of exact algebraic facts about the Nienhuis value.
-/

import Tropical.SAW.ConnectiveConstant

open Real

namespace SAWResearch

/-- The value proposed in the prompt for the square-lattice connective constant. -/
noncomputable def proposedSquareValue : ℝ := (2 + Real.sqrt 2) / 2

/-- The elementary bounds on `√2` needed below. -/
theorem sqrt_two_strict_bounds : 0 < Real.sqrt 2 ∧ Real.sqrt 2 < 2 := by
  constructor
  · positivity
  · nlinarith [Real.sq_sqrt (show (0 : ℝ) ≤ 2 by norm_num)]

/-- Consequently the proposed value lies strictly between `1` and `2`. -/
theorem proposedSquareValue_bounds : 1 < proposedSquareValue ∧ proposedSquareValue < 2 := by
  rcases sqrt_two_strict_bounds with ⟨hpos, hlt⟩
  unfold proposedSquareValue
  constructor <;> linarith

/-- The proposed value is strictly below the actual square-lattice connective
constant, using the injection of north/east walks that gives `2 ≤ μ`. -/
theorem proposedSquareValue_lt_connectiveConstant :
    proposedSquareValue < SAW.connectiveConstant := by
  exact lt_of_lt_of_le proposedSquareValue_bounds.2 SAW.connectiveConstant_ge_two

/-- Thus `(2 + √2) / 2` is not the square-lattice connective constant. -/
theorem proposedSquareValue_ne_connectiveConstant :
    proposedSquareValue ≠ SAW.connectiveConstant := by
  exact ne_of_lt proposedSquareValue_lt_connectiveConstant

/-- Equivalently, the square-lattice connective constant cannot equal the value
suggested in the prompt. -/
theorem connectiveConstant_ne_proposedSquareValue :
    SAW.connectiveConstant ≠ proposedSquareValue := by
  exact proposedSquareValue_ne_connectiveConstant.symm

/-- Nienhuis's predicted (and now proved) connective constant for the hexagonal
lattice.  This definition alone does not identify it with a square-lattice count. -/
noncomputable def nienhuisHexValue : ℝ := Real.sqrt (2 + Real.sqrt 2)

/-- The square of the hexagonal-lattice value. -/
theorem nienhuisHexValue_sq : nienhuisHexValue ^ 2 = 2 + Real.sqrt 2 := by
  have hnonneg : (0 : ℝ) ≤ 2 + Real.sqrt 2 := by
    linarith [sqrt_two_strict_bounds.1]
  exact Real.sq_sqrt hnonneg

/-- The Nienhuis value is positive. -/
theorem nienhuisHexValue_pos : 0 < nienhuisHexValue := by
  have hsq := nienhuisHexValue_sq
  have hsqrt := sqrt_two_strict_bounds.1
  have hnonneg : 0 ≤ nienhuisHexValue := Real.sqrt_nonneg _
  nlinarith

/-- Its fourth power is `6 + 4√2`. -/
theorem nienhuisHexValue_fourth :
    nienhuisHexValue ^ 4 = 6 + 4 * Real.sqrt 2 := by
  rw [show nienhuisHexValue ^ 4 = (nienhuisHexValue ^ 2) ^ 2 by ring,
    nienhuisHexValue_sq]
  nlinarith [Real.sq_sqrt (show (0 : ℝ) ≤ 2 by norm_num)]

/-- Hence the Nienhuis value is a root of `X⁴ - 4X² + 2`. -/
theorem nienhuisHexValue_quartic :
    nienhuisHexValue ^ 4 - 4 * nienhuisHexValue ^ 2 + 2 = 0 := by
  rw [nienhuisHexValue_fourth, nienhuisHexValue_sq]
  ring

/-- The proposed square-lattice value and the Nienhuis hexagonal-lattice value
are distinct. -/
theorem proposedSquareValue_ne_nienhuisHexValue :
    proposedSquareValue ≠ nienhuisHexValue := by
  intro h
  have hprop := proposedSquareValue_bounds
  have hsq := nienhuisHexValue_sq
  have hsqrt := sqrt_two_strict_bounds
  rw [← h] at hsq
  unfold proposedSquareValue at hsq
  nlinarith [Real.sq_sqrt (show (0 : ℝ) ≤ 2 by norm_num)]

/-- Package the currently proved rigorous interval: the proposed value is below
`2`, while the square-lattice connective constant lies in `[2,4]`. -/
theorem square_connectiveConstant_verified_interval :
    proposedSquareValue < 2 ∧
      2 ≤ SAW.connectiveConstant ∧ SAW.connectiveConstant ≤ 4 := by
  exact ⟨proposedSquareValue_bounds.2, SAW.connectiveConstant_ge_two,
    SAW.connectiveConstant_le_four⟩

end SAWResearch