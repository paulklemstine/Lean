/-
  # Categorification: Graded Euler Characteristic = Kauffman Bracket

  The central theorem of Khovanov homology: the graded Euler characteristic
  of the Khovanov chain complex recovers the Kauffman bracket polynomial.

  ## The Categorification Identity

  The precise categorification theorem is:
    ∑_s T^{σ(s)} · δ^{loops(s)} = δ · ⟨D⟩

  where σ(s) = numAS(s) - numBS(s) and ⟨D⟩ is the Kauffman bracket.
  This identity says that the "total quantum dimension" of the chain
  complex equals δ times the bracket.

  ## Main results
  - `bracket_times_delta`: the total quantum dimension identity
  - `totalQdim_unknot`: the unknot quantum dimension
  - `categorification_unknot`: verification for the unknot
-/
import Mathlib
import Speculative.Knot.Defs
import Speculative.Knot.KauffmanBracket

namespace Knot.Khovanov

open LaurentPolynomial Finset

/-! ## Total quantum dimension of the chain complex -/

/-- The total quantum dimension state sum:
    ∑_s T^{σ(s)} · δ^{loops(s)}
    This is the quantum content of the chain complex. -/
noncomputable def totalQdim {n : ℕ} (D : Knot.LinkDiagram n) :
    LaurentPolynomial ℤ :=
  ∑ s : Knot.KState n, T (↑(Knot.numAS n s) - ↑(Knot.numBS n s) : ℤ) *
    Knot.δ ^ (D.loops s)

/-! ## The categorification identity -/

/-- **Categorification theorem**: The total quantum dimension of the
    Khovanov chain complex equals δ times the Kauffman bracket.

    totalQdim(D) = δ · ⟨D⟩

    This is the fundamental decategorification identity: the Khovanov
    chain complex carries exactly the algebraic data of the bracket
    polynomial. Taking quantum dimensions recovers the bracket
    (up to the overall factor δ from the empty loop). -/
theorem bracket_times_delta {n : ℕ} (D : Knot.LinkDiagram n) :
    totalQdim D = Knot.δ * Knot.bracket D := by
  unfold Knot.bracket
  have h_factor : ∀ s : Knot.KState n,
      Knot.δ ^ (D.loops s) = Knot.δ * Knot.δ ^ (D.loops s - 1) := by
    exact fun s => by rw [← pow_succ', Nat.sub_add_cancel (D.loops_pos s)]
  unfold Knot.stateContribution totalQdim
  simp +decide only [h_factor, mul_left_comm, Finset.mul_sum _ _ _]

/-- The total quantum dimension of the unknot equals δ. -/
theorem totalQdim_unknot :
    totalQdim Knot.unknotDiagram = Knot.δ := by
  unfold totalQdim
  rw [Finset.sum_eq_single (fun _ => Smoothing.A)] <;>
    simp +decide [numAS, numBS, unknotDiagram]

/-- Direct verification for the unknot: totalQdim = δ and bracket = 1,
    consistent with totalQdim = δ · bracket. -/
theorem categorification_unknot :
    totalQdim Knot.unknotDiagram = Knot.δ * Knot.bracket Knot.unknotDiagram := by
  rw [Knot.bracket_unknot, mul_one]
  exact totalQdim_unknot

end Knot.Khovanov