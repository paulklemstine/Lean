import Mathlib
import EML.FixedPointConvergence

/-!
# Algebraic-independence reductions for special EML values

The proposed unconditional transcendence statements are not proved here: even the
one-variable assertion for `exp a * log (1 + a)` does not follow merely from knowing
that its two factors are transcendental.  In particular, Lindemann--Weierstrass and
Gelfond--Schneider do not currently supply the claimed product theorem.

Instead this file records fully proved consequences of the exact algebraic-
independence hypotheses that would suffice, together with unconditional positivity
and nonvanishing facts.  The EML values use the catalog definition `EMLIterOp`
rather than introducing another exp--log operator.
-/

noncomputable section

open scoped BigOperators

namespace EMLAlgebraicIndependence

/-- The requested specialization is already an instance of the catalog's `EMLIterOp`. -/
theorem specialValue_eq (a : ℝ) :
    EMLIterOp a 1 1 a = Real.exp a * Real.log (1 + a) := by
  simp [EMLIterOp, add_comm]

/-- On positive algebraic inputs, the special EML value is positive (independently
of any transcendence conjecture). -/
theorem specialValue_pos {a : ℝ} (ha : 0 < a) :
    0 < EMLIterOp a 1 1 a := by
  rw [specialValue_eq]
  exact mul_pos (Real.exp_pos a) (Real.log_pos (by linarith))

/-- Consequently the special EML value cannot vanish on a positive input. -/
theorem specialValue_ne_zero {a : ℝ} (ha : 0 < a) :
    EMLIterOp a 1 1 a ≠ 0 :=
  (specialValue_pos ha).ne'

/-- Algebraic independence of two real numbers implies transcendence of their
product.  This is the precise extra input missing from an argument that only proves
the two factors separately transcendental. -/
theorem transcendental_mul_of_algebraicIndependent_bool
    {x y : ℝ} (h : AlgebraicIndependent ℚ (fun b : Bool => cond b y x)) :
    Transcendental ℚ (x * y) := by
  rw [transcendental_iff]
  intro p hp
  let q : MvPolynomial Bool ℚ :=
    Polynomial.aeval (MvPolynomial.X false * MvPolynomial.X true) p
  have hcomp :
      (MvPolynomial.aeval (fun b : Bool => cond b y x)).comp
          (Polynomial.aeval (R := ℚ)
            (MvPolynomial.X false * MvPolynomial.X true : MvPolynomial Bool ℚ)) =
        Polynomial.aeval (x * y) := by
    ext
    simp
  have hqeval : MvPolynomial.aeval (fun b : Bool => cond b y x) q = 0 := by
    dsimp [q]
    rw [← AlgHom.comp_apply, hcomp]
    exact hp
  have hq : q = 0 := h.eq_zero_of_aeval_eq_zero q hqeval
  have hcomp' :
      (MvPolynomial.aeval
        (fun b : Bool => cond b (1 : Polynomial ℚ) Polynomial.X)).comp
          (Polynomial.aeval (R := ℚ)
            (MvPolynomial.X false * MvPolynomial.X true : MvPolynomial Bool ℚ)) =
        AlgHom.id ℚ (Polynomial ℚ) := by
    ext
    simp
  have hretract := congrArg
    (MvPolynomial.aeval
      (fun b : Bool => cond b (1 : Polynomial ℚ) Polynomial.X)) hq
  dsimp [q] at hretract
  rw [← AlgHom.comp_apply, hcomp'] at hretract
  simpa using hretract

/-- A rigorous conditional version of the proposed `n = 1` EML statement.
Algebraic independence of `exp a` and `log (1+a)` is sufficient for the desired
transcendence of their product. -/
theorem specialValue_transcendental_of_independent (a : ℝ)
    (h : AlgebraicIndependent ℚ
      (fun b : Bool => cond b (Real.log (1 + a)) (Real.exp a))) :
    Transcendental ℚ (EMLIterOp a 1 1 a) := by
  rw [specialValue_eq]
  exact transcendental_mul_of_algebraicIndependent_bool h

/-- The two concrete values singled out in the research question, expressed using
the existing catalog operator. -/
def sqrtPair : Bool → ℝ := fun b =>
  cond b
    (EMLIterOp (Real.sqrt 3) 1 1 (Real.sqrt 3))
    (EMLIterOp (Real.sqrt 2) 1 1 (Real.sqrt 2))

/-- Under the exact algebraic-independence hypothesis, every rational-coefficient
polynomial relation between the two concrete EML values is trivial.  The hypothesis
is open; the theorem makes the conjectural dependency explicit. -/
theorem sqrtPair_no_rational_polynomial_relation
    (h : AlgebraicIndependent ℚ sqrtPair) (p : MvPolynomial Bool ℚ)
    (hp : MvPolynomial.aeval sqrtPair p = 0) : p = 0 := by
  exact h.eq_zero_of_aeval_eq_zero p hp

/-- Both concrete EML values are strictly positive. -/
theorem sqrtPair_pos (b : Bool) : 0 < sqrtPair b := by
  cases b <;> simp [sqrtPair] <;>
    apply specialValue_pos <;> positivity

/-- In particular, neither concrete generator vanishes. -/
theorem sqrtPair_ne_zero (b : Bool) : sqrtPair b ≠ 0 :=
  (sqrtPair_pos b).ne'

end EMLAlgebraicIndependence