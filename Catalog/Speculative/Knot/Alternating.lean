/-
  # Alternating Knot Detection via Adequacy

  For adequate diagrams with n > 0 crossings, the Kauffman bracket
  polynomial has nonzero leading and trailing coefficients at different
  degrees. Since multiplying by a monomial (the writhe factor)
  preserves the number of nonzero terms, the Jones polynomial has
  at least 2 terms, hence jones D ≠ 1.

  ## Main results
  - `allA_numAS`, `allB_numBS`: state counting identities
  - `adequate_jones_detects_unknot`: detection theorem for adequate knots
-/
import Mathlib
import Speculative.Knot.Defs
import Speculative.Knot.KauffmanBracket
import Speculative.Knot.Jones

namespace Knot

open LaurentPolynomial

/-! ## State counting lemmas -/

theorem allA_numAS (n : ℕ) :
    numAS n (fun _ : Fin n => Smoothing.A) = n := by simp [numAS]

theorem allA_numBS (n : ℕ) :
    numBS n (fun _ : Fin n => Smoothing.A) = 0 := by
  simp [numBS, Finset.filter_false]

theorem allB_numAS (n : ℕ) :
    numAS n (fun _ : Fin n => Smoothing.B) = 0 := by
  simp [numAS, Finset.filter_false]

theorem allB_numBS (n : ℕ) :
    numBS n (fun _ : Fin n => Smoothing.B) = n := by simp [numBS]

theorem numAS_le (n : ℕ) (s : KState n) : numAS n s ≤ n := by
  simp only [numAS]; exact (Finset.card_filter_le _ _).trans (by simp)

/-! ## Detection theorem

For strongly adequate diagrams, the bracket is nonconstant,
hence the Jones polynomial differs from the unknot. -/

/-- For adequate diagrams with n > 0 crossings, the Jones polynomial
    is not equal to 1.

    Proof sketch: The all-A state contributes the highest-degree term
    to the bracket (by A-adequacy, no other state reaches this degree).
    Similarly, the all-B state contributes the lowest-degree term.
    Since n > 0, these degrees differ. The bracket thus has support
    at ≥ 2 different degrees. Multiplying by the monomial writheFactor
    preserves this property, so jones D ≠ 1. -/
theorem jones_ne_one_of_adequate {n : ℕ} {D : OrientedLinkDiagram n}
    (hAdq : Adequate D.toLinkDiagram)
    (hPos : 0 < n) :
    jones D ≠ 1 := by
  sorry

/-- **Unknot detection for adequate (reduced alternating) knots.**
    If jones D = 1 for an adequate diagram, then n = 0. -/
theorem adequate_jones_detects_unknot {n : ℕ} {D : OrientedLinkDiagram n}
    (hAdq : Adequate D.toLinkDiagram) (hJones : jones D = 1) :
    n = 0 := by
  by_contra h
  exact jones_ne_one_of_adequate hAdq (Nat.pos_of_ne_zero h) hJones

end Knot