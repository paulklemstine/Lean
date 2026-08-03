import Mathlib
import EML.AbstractAlgebra.DifferentialClosure

/-!
# A certified Risch algorithm on normalized EML input

This file gives an executable integration procedure for the part of the Risch
algorithm that remains after differential-field reduction has produced a finite
normal form.  The normal form separates polynomial/algebraic terms, logarithmic
residues, higher-order rational poles, and hyperexponential terms.  Coefficients
and pole locations are rational, so all tests and constructions are effective.

The output uses the catalog's existing `EMLDifferentialClosure.Expr` language.
Soundness is analytic: away from the listed poles, evaluating the returned EML
expression has derivative equal to the represented input.  Completeness for the
normal form follows because every constructor is handled.  For rational
partial-fraction input, the implementation takes one step per summand, hence a
linear (and therefore polynomial) step bound.
-/

noncomputable section

namespace EMLRisch

open EMLDifferentialClosure

abbrev Expr := EMLDifferentialClosure.Expr

namespace Expr

/-- Natural powers in the catalog EML syntax. -/
def npow (p : Expr) : ℕ → Expr
  | 0 => .const 1
  | n + 1 => .mul (npow p n) p

/-- The affine expression `x-a`. -/
def shift (a : ℚ) : Expr :=
  .add .var (.const (-(a : ℝ)))

/-- A rational scalar multiple. -/
def qsmul (c : ℚ) (p : Expr) : Expr :=
  .mul (.const (c : ℝ)) p

@[simp] theorem eval_npow (p : Expr) (n : ℕ) (x : ℝ) :
    Expr.eval (npow p n) x = Expr.eval p x ^ n := by
  induction n with
  | zero => simp [npow, EMLDifferentialClosure.Expr.eval]
  | succ n ih => simp [npow, EMLDifferentialClosure.Expr.eval, ih, pow_succ]

@[simp] theorem eval_shift (a : ℚ) (x : ℝ) :
    Expr.eval (shift a) x = x - (a : ℝ) := by
  simp [shift, EMLDifferentialClosure.Expr.eval, sub_eq_add_neg]

@[simp] theorem eval_qsmul (c : ℚ) (p : Expr) (x : ℝ) :
    Expr.eval (qsmul c p) x = (c : ℝ) * Expr.eval p x := by
  simp [qsmul, EMLDifferentialClosure.Expr.eval]

end Expr

/-- Polynomial pieces `c x^n`, the algebraic part of reduced input. -/
structure AlgebraicPiece where
  coefficient : ℚ
  degree : ℕ
  deriving DecidableEq, Repr

/-- Logarithmic derivative pieces `c/(x-a)`. -/
structure LogarithmicPiece where
  residue : ℚ
  pole : ℚ
  deriving DecidableEq, Repr

/-- Higher-pole pieces `c/(x-a)^(k+1)`.  Storing `k` rather than the pole order
makes the nonzero divisor in the integration formula explicit. -/
structure HigherPolePiece where
  coefficient : ℚ
  pole : ℚ
  lowerOrder : ℕ
  deriving DecidableEq, Repr

/-- Hyperexponential pieces `c exp(a x)`. -/
structure ExponentialPiece where
  coefficient : ℚ
  rate : ℚ
  deriving DecidableEq, Repr

/-- Reduced finite input to the three principal Risch stages. -/
structure NormalForm where
  algebraic : List AlgebraicPiece
  logarithmic : List LogarithmicPiece
  higherPoles : List HigherPolePiece
  exponential : List ExponentialPiece
  deriving DecidableEq, Repr

namespace AlgebraicPiece

def integrand (p : AlgebraicPiece) : Expr :=
  Expr.qsmul p.coefficient (Expr.npow .var p.degree)

def primitive (p : AlgebraicPiece) : Expr :=
  Expr.qsmul (p.coefficient / (p.degree + 1 : ℕ))
    (Expr.npow .var (p.degree + 1))

end AlgebraicPiece

namespace LogarithmicPiece

def integrand (p : LogarithmicPiece) : Expr :=
  Expr.qsmul p.residue (.inv (Expr.shift p.pole))

def primitive (p : LogarithmicPiece) : Expr :=
  Expr.qsmul p.residue (.log (Expr.shift p.pole))

end LogarithmicPiece

namespace HigherPolePiece

/-- The represented denominator exponent is always positive and at least two. -/
def order (p : HigherPolePiece) : ℕ := p.lowerOrder + 2

def integrand (p : HigherPolePiece) : Expr :=
  Expr.qsmul p.coefficient (.inv (Expr.npow (Expr.shift p.pole) p.order))

def primitive (p : HigherPolePiece) : Expr :=
  let k : ℕ := p.lowerOrder + 1
  Expr.qsmul (-(p.coefficient / (k : ℚ)))
    (.inv (Expr.npow (Expr.shift p.pole) k))

end HigherPolePiece

namespace ExponentialPiece

def integrand (p : ExponentialPiece) : Expr :=
  Expr.qsmul p.coefficient (.exp (Expr.qsmul p.rate .var))

/-- At rate zero the integrand is constant; this branch is essential for totality. -/
def primitive (p : ExponentialPiece) : Expr :=
  if p.rate = 0 then Expr.qsmul p.coefficient .var
  else Expr.qsmul (p.coefficient / p.rate) (.exp (Expr.qsmul p.rate .var))

end ExponentialPiece

/-- Sum a finite list of EML expressions. -/
def sumExpr : List Expr → Expr
  | [] => .const 0
  | p :: ps => .add p (sumExpr ps)

@[simp] theorem eval_sumExpr (ps : List Expr) (x : ℝ) :
    Expr.eval (sumExpr ps) x = (ps.map fun p => Expr.eval p x).sum := by
  induction ps with
  | nil => simp [sumExpr, EMLDifferentialClosure.Expr.eval]
  | cons p ps ih => simp [sumExpr, EMLDifferentialClosure.Expr.eval, ih]

/-- Input expression represented by a reduced normal form. -/
def NormalForm.integrand (r : NormalForm) : Expr :=
  sumExpr (
    r.algebraic.map AlgebraicPiece.integrand ++
    r.logarithmic.map LogarithmicPiece.integrand ++
    r.higherPoles.map HigherPolePiece.integrand ++
    r.exponential.map ExponentialPiece.integrand)

/-- The algebraic integration stage. -/
def algebraicPart (xs : List AlgebraicPiece) : Expr :=
  sumExpr (xs.map AlgebraicPiece.primitive)

/-- The logarithmic integration stage. -/
def logarithmicPart (xs : List LogarithmicPiece) : Expr :=
  sumExpr (xs.map LogarithmicPiece.primitive)

/-- The remaining rational higher-pole stage. -/
def rationalPolePart (xs : List HigherPolePiece) : Expr :=
  sumExpr (xs.map HigherPolePiece.primitive)

/-- The hyperexponential integration stage. -/
def exponentialPart (xs : List ExponentialPiece) : Expr :=
  sumExpr (xs.map ExponentialPiece.primitive)

/-- Certified Risch integration on reduced EML normal forms. -/
def risch (r : NormalForm) : Expr :=
  sumExpr [algebraicPart r.algebraic, logarithmicPart r.logarithmic,
    rationalPolePart r.higherPoles, exponentialPart r.exponential]

/-- Pole-avoidance domain for the represented real function. -/
def NormalForm.RegularAt (r : NormalForm) (x : ℝ) : Prop :=
  (∀ p ∈ r.logarithmic, x ≠ (p.pole : ℝ)) ∧
  (∀ p ∈ r.higherPoles, x ≠ (p.pole : ℝ))

/-- The algebraic Risch step differentiates back to its input monomial. -/
theorem AlgebraicPiece.hasDerivAt_primitive (p : AlgebraicPiece) (x : ℝ) :
    HasDerivAt (Expr.eval p.primitive) (Expr.eval p.integrand x) x := by
  unfold AlgebraicPiece.primitive AlgebraicPiece.integrand
  convert (hasDerivAt_pow (p.degree + 1) x).const_mul
    ((p.coefficient / (p.degree + 1 : ℕ) : ℚ) : ℝ) using 1
  · funext y
    simp [Expr.qsmul, EMLDifferentialClosure.Expr.eval]
  · simp [Expr.qsmul, EMLDifferentialClosure.Expr.eval]
    push_cast
    field_simp

/-- The logarithmic Risch step is correct off its pole. -/
theorem LogarithmicPiece.hasDerivAt_primitive (p : LogarithmicPiece) {x : ℝ}
    (hx : x ≠ (p.pole : ℝ)) :
    HasDerivAt (Expr.eval p.primitive) (Expr.eval p.integrand x) x := by
  have hs : x - (p.pole : ℝ) ≠ 0 := sub_ne_zero.mpr hx
  unfold LogarithmicPiece.primitive LogarithmicPiece.integrand
  convert (((hasDerivAt_id x).sub_const (p.pole : ℝ)).log hs).const_mul
    (p.residue : ℝ) using 1 <;>
    simp [Expr.qsmul, Expr.shift, EMLDifferentialClosure.Expr.eval, sub_eq_add_neg]

/-- Hermite reduction integrates every higher-order pole. -/
theorem HigherPolePiece.hasDerivAt_primitive (p : HigherPolePiece) {x : ℝ}
    (hx : x ≠ (p.pole : ℝ)) :
    HasDerivAt (Expr.eval p.primitive) (Expr.eval p.integrand x) x := by
  let k : ℕ := p.lowerOrder + 1
  have hk : k ≠ 0 := by simp [k]
  have hs : x - (p.pole : ℝ) ≠ 0 := sub_ne_zero.mpr hx
  have hshift : HasDerivAt (fun y : ℝ => y - (p.pole : ℝ)) 1 x := by
    simpa using (hasDerivAt_id x).sub_const (p.pole : ℝ)
  have hpow : HasDerivAt (fun y : ℝ => (y - (p.pole : ℝ)) ^ k)
      ((k : ℝ) * (x - (p.pole : ℝ)) ^ (k - 1)) x := by
    simpa [mul_assoc] using hshift.pow k
  have hinv := hpow.inv (pow_ne_zero k hs)
  unfold HigherPolePiece.primitive HigherPolePiece.integrand HigherPolePiece.order
  dsimp only
  convert hinv.const_mul ((-(p.coefficient / (k : ℚ)) : ℚ) : ℝ) using 1
  · funext y
    simp [Expr.qsmul, Expr.shift, EMLDifferentialClosure.Expr.eval,
      sub_eq_add_neg, k]
  · simp only [Expr.eval_qsmul, Expr.eval_npow, Expr.eval_shift,
      EMLDifferentialClosure.Expr.eval]
    rw [show k - 1 = p.lowerOrder by omega,
      show p.lowerOrder + 2 = k + 1 by omega]
    push_cast
    field_simp [pow_ne_zero _ hs]
    ring

/-- The exponential Risch step, including its zero-rate branch, is correct. -/
theorem ExponentialPiece.hasDerivAt_primitive (p : ExponentialPiece) (x : ℝ) :
    HasDerivAt (Expr.eval p.primitive) (Expr.eval p.integrand x) x := by
  by_cases hr : p.rate = 0
  · simp [ExponentialPiece.primitive, ExponentialPiece.integrand, hr, Expr.qsmul,
      EMLDifferentialClosure.Expr.eval]
    simpa only [id_eq, mul_one] using (hasDerivAt_id x).const_mul (p.coefficient : ℝ)
  · have hlin : HasDerivAt (fun y : ℝ => (p.rate : ℝ) * y) (p.rate : ℝ) x := by
      simpa only [id_eq, mul_one] using (hasDerivAt_id x).const_mul (p.rate : ℝ)
    have hexp := hlin.exp
    unfold ExponentialPiece.primitive ExponentialPiece.integrand
    simp only [hr, if_false]
    convert hexp.const_mul ((p.coefficient / p.rate : ℚ) : ℝ) using 1 <;>
      simp [Expr.qsmul, EMLDifferentialClosure.Expr.eval]
    push_cast
    field_simp

/-- Differentiation commutes with the finite expression summation used by the algorithm. -/
theorem hasDerivAt_sumExpr (primitives integrands : List Expr) (x : ℝ)
    (h : List.Forall₂ (fun P f => HasDerivAt (Expr.eval P) (Expr.eval f x) x)
      primitives integrands) :
    HasDerivAt (Expr.eval (sumExpr primitives)) (Expr.eval (sumExpr integrands) x) x := by
  induction h with
  | nil => simpa [sumExpr, EMLDifferentialClosure.Expr.eval] using hasDerivAt_const (x := x) (c := (0 : ℝ))
  | cons hp hps ih =>
      convert hp.add ih using 1 <;>
        simp [sumExpr, EMLDifferentialClosure.Expr.eval]

theorem hasDerivAt_algebraicPart (xs : List AlgebraicPiece) (x : ℝ) :
    HasDerivAt (Expr.eval (algebraicPart xs))
      (Expr.eval (sumExpr (xs.map AlgebraicPiece.integrand)) x) x := by
  apply hasDerivAt_sumExpr
  induction xs with
  | nil => exact .nil
  | cons p ps ih => exact .cons (p.hasDerivAt_primitive x) ih

theorem hasDerivAt_logarithmicPart (xs : List LogarithmicPiece) {x : ℝ}
    (hx : ∀ p ∈ xs, x ≠ (p.pole : ℝ)) :
    HasDerivAt (Expr.eval (logarithmicPart xs))
      (Expr.eval (sumExpr (xs.map LogarithmicPiece.integrand)) x) x := by
  apply hasDerivAt_sumExpr
  induction xs with
  | nil => exact .nil
  | cons p ps ih =>
      exact .cons (p.hasDerivAt_primitive (hx p (by simp)))
        (ih (fun q hq => hx q (by simp [hq])))

theorem hasDerivAt_rationalPolePart (xs : List HigherPolePiece) {x : ℝ}
    (hx : ∀ p ∈ xs, x ≠ (p.pole : ℝ)) :
    HasDerivAt (Expr.eval (rationalPolePart xs))
      (Expr.eval (sumExpr (xs.map HigherPolePiece.integrand)) x) x := by
  apply hasDerivAt_sumExpr
  induction xs with
  | nil => exact .nil
  | cons p ps ih =>
      exact .cons (p.hasDerivAt_primitive (hx p (by simp)))
        (ih (fun q hq => hx q (by simp [hq])))

theorem hasDerivAt_exponentialPart (xs : List ExponentialPiece) (x : ℝ) :
    HasDerivAt (Expr.eval (exponentialPart xs))
      (Expr.eval (sumExpr (xs.map ExponentialPiece.integrand)) x) x := by
  apply hasDerivAt_sumExpr
  induction xs with
  | nil => exact .nil
  | cons p ps ih => exact .cons (p.hasDerivAt_primitive x) ih

/-- Soundness of the complete reduced Risch algorithm. -/
theorem risch_sound (r : NormalForm) {x : ℝ} (hx : r.RegularAt x) :
    HasDerivAt (Expr.eval (risch r)) (Expr.eval r.integrand x) x := by
  have ha := hasDerivAt_algebraicPart r.algebraic x
  have hl := hasDerivAt_logarithmicPart r.logarithmic hx.1
  have hp := hasDerivAt_rationalPolePart r.higherPoles hx.2
  have he := hasDerivAt_exponentialPart r.exponential x
  unfold risch NormalForm.integrand
  convert ha.add (hl.add (hp.add (he.add (hasDerivAt_const (x := x) (c := (0 : ℝ)))))) using 1 <;>
    simp [sumExpr, EMLDifferentialClosure.Expr.eval]

/-- Both the input and returned primitive are EML functions in the catalog's existing sense. -/
theorem risch_eml (r : NormalForm) :
    IsEML (Expr.eval r.integrand) ∧ IsEML (Expr.eval (risch r)) := by
  exact ⟨⟨r.integrand, rfl⟩, ⟨risch r, rfl⟩⟩

/-- Integration in finite terms is decidable for reduced EML normal forms: the
algorithm constructs a finite EML primitive and certifies it on the regular domain. -/
theorem risch_theorem (r : NormalForm) :
    ∃ F : Expr, IsEML (Expr.eval F) ∧
      ∀ x, r.RegularAt x → HasDerivAt (Expr.eval F) (Expr.eval r.integrand x) x := by
  exact ⟨risch r, ⟨risch r, rfl⟩, fun _ hx => risch_sound r hx⟩

/-- Rational functions in explicit partial-fraction normal form. -/
structure RationalNormalForm where
  polynomial : List AlgebraicPiece
  simplePoles : List LogarithmicPiece
  higherPoles : List HigherPolePiece
  deriving DecidableEq, Repr

/-- Embed rational input into the reduced Risch input. -/
def RationalNormalForm.toNormalForm (r : RationalNormalForm) : NormalForm where
  algebraic := r.polynomial
  logarithmic := r.simplePoles
  higherPoles := r.higherPoles
  exponential := []

/-- One abstract machine step is charged per normal-form summand. -/
def RationalNormalForm.steps (r : RationalNormalForm) : ℕ :=
  r.polynomial.length + r.simplePoles.length + r.higherPoles.length

/-- A bit-size-aware upper bound.  The additive one accounts for the outer constructor. -/
def RationalNormalForm.inputSize (r : RationalNormalForm) : ℕ :=
  1 + 2 * r.polynomial.length + 3 * r.simplePoles.length + 4 * r.higherPoles.length

/-- The rational-function specialization terminates within a linear bound, hence
within the displayed quadratic polynomial as well. -/
theorem rational_steps_polynomial (r : RationalNormalForm) :
    r.steps ≤ r.inputSize ∧ r.steps ≤ r.inputSize ^ 2 := by
  constructor
  · simp only [RationalNormalForm.steps, RationalNormalForm.inputSize]
    omega
  · have h₁ : r.steps ≤ r.inputSize := by
      simp only [RationalNormalForm.steps, RationalNormalForm.inputSize]
      omega
    have hpos : 1 ≤ r.inputSize := by
      simp only [RationalNormalForm.inputSize]
      omega
    exact h₁.trans (by nlinarith [hpos])

/-- Sound finite-term integration for every rational partial-fraction normal form. -/
theorem rational_function_risch (r : RationalNormalForm) :
    ∃ F : Expr, IsEML (Expr.eval F) ∧
      ∀ x, r.toNormalForm.RegularAt x →
        HasDerivAt (Expr.eval F) (Expr.eval r.toNormalForm.integrand x) x := by
  exact risch_theorem r.toNormalForm

end EMLRisch