/-
  # Kauffman Bracket Polynomial

  The Kauffman bracket ⟨D⟩ is a Laurent polynomial invariant defined as
  a state sum:
    ⟨D⟩ = ∑_s A^(#A(s) - #B(s)) · δ^(loops(s) - 1)
  where δ = -A² - A⁻².
-/
import Mathlib
import Speculative.Knot.Defs

namespace Knot

open LaurentPolynomial Finset

/-- The loop value δ = -A² - A⁻² in ℤ[A, A⁻¹] -/
noncomputable def δ : LaurentPolynomial ℤ := -(T 2) - T (-2)

/-- The contribution of a single state to the Kauffman bracket -/
noncomputable def stateContribution {n : ℕ} (D : LinkDiagram n) (s : KState n) :
    LaurentPolynomial ℤ :=
  T (↑(numAS n s) - ↑(numBS n s) : ℤ) * δ ^ (D.loops s - 1)

/-- The Kauffman bracket of a link diagram -/
noncomputable def bracket {n : ℕ} (D : LinkDiagram n) : LaurentPolynomial ℤ :=
  ∑ s : KState n, stateContribution D s

/-- The Kauffman bracket of the unknot is 1. -/
theorem bracket_unknot : bracket unknotDiagram = 1 := by
  simp only [bracket, unknotDiagram, stateContribution, numAS, numBS, δ]
  simp

end Knot