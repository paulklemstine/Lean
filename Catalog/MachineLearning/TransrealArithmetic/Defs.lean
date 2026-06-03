/-
# Transreal Arithmetic: Core Definitions

Anderson's transreal number system extends ℝ with three distinguished elements:
- `posInf` (+∞): positive infinity
- `negInf` (-∞): negative infinity
- `nullity` (Φ): the result of 0/0, representing an indeterminate form

The key insight is that making division total (every number has a reciprocal)
forces the abandonment of ring structure. What emerges instead is a "wheel-like"
algebraic structure where nullity acts as an absorbing element.

Reference: J.A.D.W. Anderson, "Perspex Machine IX: Transreal Analysis" (2007)
-/
import Mathlib

open Classical in

/-- The transreal numbers: ℝ extended with +∞, -∞, and nullity (Φ = 0/0). -/
inductive Transreal where
  | ofReal : ℝ → Transreal
  | posInf : Transreal
  | negInf : Transreal
  | nullity : Transreal

namespace Transreal

noncomputable instance : DecidableEq Transreal := Classical.decEq _

instance : Inhabited Transreal := ⟨ofReal 0⟩

/-- Coercion from ℝ to Transreal. -/
instance : Coe ℝ Transreal := ⟨ofReal⟩

/-- Zero in the transreals. -/
instance : Zero Transreal := ⟨ofReal 0⟩

/-- One in the transreals. -/
instance : One Transreal := ⟨ofReal 1⟩

@[simp] theorem zero_def : (0 : Transreal) = ofReal 0 := rfl
@[simp] theorem one_def : (1 : Transreal) = ofReal 1 := rfl

/-- The nullity element Φ = 0/0. -/
def phi : Transreal := nullity

/-- Negation on transreals. -/
def neg : Transreal → Transreal
  | ofReal r => ofReal (-r)
  | posInf => negInf
  | negInf => posInf
  | nullity => nullity

instance : Neg Transreal := ⟨neg⟩

@[simp] theorem neg_ofReal (r : ℝ) : -(ofReal r) = ofReal (-r) := rfl
@[simp] theorem neg_posInf : -(posInf : Transreal) = negInf := rfl
@[simp] theorem neg_negInf : -(negInf : Transreal) = posInf := rfl
@[simp] theorem neg_nullity : -(nullity : Transreal) = nullity := rfl

/-- Addition on transreals following Anderson's rules. -/
noncomputable def add : Transreal → Transreal → Transreal
  | ofReal a, ofReal b => ofReal (a + b)
  | ofReal _, posInf => posInf
  | ofReal _, negInf => negInf
  | posInf, ofReal _ => posInf
  | negInf, ofReal _ => negInf
  | posInf, posInf => posInf
  | negInf, negInf => negInf
  | posInf, negInf => nullity
  | negInf, posInf => nullity
  | nullity, _ => nullity
  | _, nullity => nullity

noncomputable instance : Add Transreal := ⟨add⟩

@[simp] theorem add_ofReal (a b : ℝ) : ofReal a + ofReal b = ofReal (a + b) := rfl
@[simp] theorem add_posInf_posInf : (posInf : Transreal) + posInf = posInf := rfl
@[simp] theorem add_negInf_negInf : (negInf : Transreal) + negInf = negInf := rfl
@[simp] theorem add_posInf_negInf : (posInf : Transreal) + negInf = nullity := rfl
@[simp] theorem add_negInf_posInf : (negInf : Transreal) + posInf = nullity := rfl

@[simp] theorem nullity_add (x : Transreal) : nullity + x = nullity := by
  cases x <;> rfl

@[simp] theorem add_nullity (x : Transreal) : x + nullity = nullity := by
  cases x <;> rfl

@[simp] theorem ofReal_add_posInf (r : ℝ) : ofReal r + posInf = posInf := rfl
@[simp] theorem ofReal_add_negInf (r : ℝ) : ofReal r + negInf = negInf := rfl
@[simp] theorem posInf_add_ofReal (r : ℝ) : posInf + ofReal r = posInf := rfl
@[simp] theorem negInf_add_ofReal (r : ℝ) : negInf + ofReal r = negInf := rfl

/-- Multiplication on transreals following Anderson's rules. -/
noncomputable def mul : Transreal → Transreal → Transreal
  | ofReal a, ofReal b => ofReal (a * b)
  | ofReal a, posInf => if a > 0 then posInf else if a < 0 then negInf else nullity
  | ofReal a, negInf => if a > 0 then negInf else if a < 0 then posInf else nullity
  | posInf, ofReal b => if b > 0 then posInf else if b < 0 then negInf else nullity
  | negInf, ofReal b => if b > 0 then negInf else if b < 0 then posInf else nullity
  | posInf, posInf => posInf
  | posInf, negInf => negInf
  | negInf, posInf => negInf
  | negInf, negInf => posInf
  | nullity, _ => nullity
  | _, nullity => nullity

noncomputable instance : Mul Transreal := ⟨mul⟩

@[simp] theorem mul_ofReal (a b : ℝ) : ofReal a * ofReal b = ofReal (a * b) := rfl
@[simp] theorem mul_posInf_posInf : (posInf : Transreal) * posInf = posInf := rfl
@[simp] theorem mul_negInf_negInf : (negInf : Transreal) * negInf = posInf := rfl
@[simp] theorem mul_posInf_negInf : (posInf : Transreal) * negInf = negInf := rfl
@[simp] theorem mul_negInf_posInf : (negInf : Transreal) * posInf = negInf := rfl

@[simp] theorem nullity_mul (x : Transreal) : nullity * x = nullity := by
  cases x <;> rfl

@[simp] theorem mul_nullity (x : Transreal) : x * nullity = nullity := by
  cases x <;> rfl

/-- The reciprocal (multiplicative inverse) on transreals.
    Key feature: 1/0 = +∞, making division total. -/
noncomputable def recip : Transreal → Transreal
  | ofReal r => if r = 0 then posInf else ofReal (r⁻¹)
  | posInf => ofReal 0
  | negInf => ofReal 0
  | nullity => nullity

/-- Division as multiplication by reciprocal. -/
noncomputable def div (a b : Transreal) : Transreal := a * recip b

noncomputable instance : Div Transreal := ⟨div⟩

@[simp] theorem recip_zero : recip (ofReal 0) = posInf := by simp [recip]
@[simp] theorem recip_posInf : recip posInf = ofReal 0 := rfl
@[simp] theorem recip_negInf : recip negInf = ofReal 0 := rfl
@[simp] theorem recip_nullity : recip nullity = nullity := rfl

theorem recip_ofReal_ne_zero (r : ℝ) (hr : r ≠ 0) :
    recip (ofReal r) = ofReal (r⁻¹) := by
  simp [recip, hr]

/-- Partial order on transreals: -∞ ≤ r ≤ +∞ for all real r.
    Nullity is incomparable with everything. -/
def tle : Transreal → Transreal → Prop
  | ofReal a, ofReal b => a ≤ b
  | negInf, ofReal _ => True
  | negInf, posInf => True
  | negInf, negInf => True
  | ofReal _, posInf => True
  | posInf, posInf => True
  | _, _ => False

instance : LE Transreal := ⟨tle⟩

@[simp] theorem le_ofReal (a b : ℝ) : (ofReal a ≤ ofReal b) ↔ (a ≤ b) := Iff.rfl
@[simp] theorem negInf_le_ofReal (r : ℝ) : (negInf : Transreal) ≤ ofReal r := trivial
@[simp] theorem negInf_le_posInf : (negInf : Transreal) ≤ posInf := trivial
@[simp] theorem ofReal_le_posInf (r : ℝ) : ofReal r ≤ posInf := trivial

/-- Predicate: x is a finite transreal (i.e., a real number). -/
def IsFinite : Transreal → Prop
  | ofReal _ => True
  | _ => False

/-- Predicate: x is a "total" transreal (not nullity). -/
def IsTotal : Transreal → Prop
  | nullity => False
  | _ => True

/-- Extract the real value, or return a default. -/
noncomputable def toReal (default : ℝ) : Transreal → ℝ
  | ofReal r => r
  | _ => default

/-- Useful: ofReal is injective. -/
theorem ofReal_injective : Function.Injective ofReal := by
  intro a b h
  injection h

theorem ofReal_ne_posInf (r : ℝ) : ofReal r ≠ posInf := by
  intro h; injection h

theorem ofReal_ne_negInf (r : ℝ) : ofReal r ≠ negInf := by
  intro h; injection h

theorem ofReal_ne_nullity (r : ℝ) : ofReal r ≠ nullity := by
  intro h; injection h

theorem posInf_ne_negInf : (posInf : Transreal) ≠ negInf := by
  intro h; injection h

theorem posInf_ne_nullity : (posInf : Transreal) ≠ nullity := by
  intro h; injection h

theorem negInf_ne_nullity : (negInf : Transreal) ≠ nullity := by
  intro h; injection h

/-- Helper: 0 * ∞ = Φ -/
theorem zero_mul_posInf : (ofReal 0) * posInf = nullity := by
  show mul (ofReal 0) posInf = nullity
  simp [mul]

/-- Helper: 0 * (-∞) = Φ -/
theorem zero_mul_negInf : (ofReal 0) * negInf = nullity := by
  show mul (ofReal 0) negInf = nullity
  simp [mul]

/-- Helper for mul with positive real and posInf -/
theorem posReal_mul_posInf (r : ℝ) (hr : r > 0) :
    ofReal r * posInf = posInf := by
  show mul (ofReal r) posInf = posInf
  simp [mul]
  split <;> simp_all

/-- Helper for mul with negative real and posInf -/
theorem negReal_mul_posInf (r : ℝ) (hr : r < 0) :
    ofReal r * posInf = negInf := by
  show mul (ofReal r) posInf = negInf
  unfold mul
  have h1 : ¬(r > 0) := by linarith
  simp [h1, hr]

/-- Helper for posInf * positive real -/
theorem posInf_mul_posReal (r : ℝ) (hr : r > 0) :
    posInf * ofReal r = posInf := by
  show mul posInf (ofReal r) = posInf
  simp [mul]
  split <;> simp_all

/-- Helper for posInf * negative real -/
theorem posInf_mul_negReal (r : ℝ) (hr : r < 0) :
    posInf * ofReal r = negInf := by
  show mul posInf (ofReal r) = negInf
  unfold mul
  have h1 : ¬(r > 0) := by linarith
  simp [h1, hr]

end Transreal