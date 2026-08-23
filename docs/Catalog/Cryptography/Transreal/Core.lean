import Mathlib

/-!
# The four-constructor transreal carrier and its arithmetic

This file introduces the carrier used throughout the *guarded transfer principle*
development: the **transreals**, a four-constructor extension of `ℝ` by two
signed infinities and one exceptional element `null` (Anderson's *nullity* `Φ`).

```
Transreal ::= fin ℝ | pinf | ninf | null
```

Arithmetic is total: every pair of transreals has a sum, a product and a
quotient.  Totality is bought by the exceptional constructor, which absorbs all
the indeterminate forms `∞ - ∞`, `0 · ∞` and `0 / 0`.

The mathematical content of this file is the *exact conservativity* of the
finite fragment: `fin : ℝ → Transreal` is an injection that transports `+`, `*`,
`-` verbatim, and transports `/` verbatim **exactly when the denominator is
nonzero**.  At a vanishing denominator the value leaves the finite fragment, and
*which* exceptional constructor it lands on is dictated by the sign of the
numerator (`Transreal.div_fin_zero`).  That trichotomy is the sharp boundary
exploited by `Cryptography.Transreal.Topology` and
`Cryptography.Transreal.Transfer`.
-/

/-- The transreal carrier: the reals, two signed infinities, and nullity. -/
inductive Transreal : Type
  | fin (x : ℝ) : Transreal
  | pinf : Transreal
  | ninf : Transreal
  | null : Transreal

namespace Transreal

/-- `fin` is injective: the finite fragment is a faithful copy of `ℝ`. -/
theorem fin_injective : Function.Injective fin := by
  intro x y h
  cases h
  rfl

@[simp] theorem fin_inj {x y : ℝ} : fin x = fin y ↔ x = y :=
  ⟨fun h => fin_injective h, fun h => by rw [h]⟩

/-! ### Addition -/

/-- Transreal addition.  `null` is absorbing and `pinf + ninf = null`. -/
def add : Transreal → Transreal → Transreal
  | null, _ => null
  | _, null => null
  | fin x, fin y => fin (x + y)
  | fin _, pinf => pinf
  | fin _, ninf => ninf
  | pinf, fin _ => pinf
  | ninf, fin _ => ninf
  | pinf, pinf => pinf
  | ninf, ninf => ninf
  | pinf, ninf => null
  | ninf, pinf => null

instance : Add Transreal := ⟨add⟩

@[simp] theorem fin_add_fin (x y : ℝ) : fin x + fin y = fin (x + y) := rfl
@[simp] theorem null_add (a : Transreal) : null + a = null := by cases a <;> rfl
@[simp] theorem add_null (a : Transreal) : a + null = null := by cases a <;> rfl
@[simp] theorem fin_add_pinf (x : ℝ) : fin x + pinf = pinf := rfl
@[simp] theorem pinf_add_fin (x : ℝ) : pinf + fin x = pinf := rfl
@[simp] theorem fin_add_ninf (x : ℝ) : fin x + ninf = ninf := rfl
@[simp] theorem ninf_add_fin (x : ℝ) : ninf + fin x = ninf := rfl
@[simp] theorem pinf_add_ninf : pinf + ninf = null := rfl
@[simp] theorem ninf_add_pinf : ninf + pinf = null := rfl
@[simp] theorem pinf_add_pinf : pinf + pinf = pinf := rfl
@[simp] theorem ninf_add_ninf : ninf + ninf = ninf := rfl

theorem add_comm (a b : Transreal) : a + b = b + a := by
  cases a <;> cases b <;> simp [_root_.add_comm]

theorem add_assoc (a b c : Transreal) : a + b + c = a + (b + c) := by
  cases a <;> cases b <;> cases c <;> simp [_root_.add_assoc]

@[simp] theorem fin_zero_add (a : Transreal) : fin 0 + a = a := by
  cases a <;> simp

@[simp] theorem add_fin_zero (a : Transreal) : a + fin 0 = a := by
  cases a <;> simp

/-! ### Negation -/

/-- Transreal negation; it swaps the two infinities and fixes nullity. -/
def neg : Transreal → Transreal
  | fin x => fin (-x)
  | pinf => ninf
  | ninf => pinf
  | null => null

instance : Neg Transreal := ⟨neg⟩

@[simp] theorem neg_fin (x : ℝ) : -(fin x) = fin (-x) := rfl
@[simp] theorem neg_pinf : -pinf = ninf := rfl
@[simp] theorem neg_ninf : -ninf = pinf := rfl
@[simp] theorem neg_null : -null = null := rfl

theorem neg_neg_self (a : Transreal) : - -a = a := by cases a <;> simp

/-! ### Multiplication -/

open Classical in
/-- Transreal multiplication.  `null` is absorbing and `0 · ∞ = null`. -/
noncomputable def mul : Transreal → Transreal → Transreal
  | null, _ => null
  | _, null => null
  | fin x, fin y => fin (x * y)
  | fin x, pinf => if x = 0 then null else if 0 < x then pinf else ninf
  | fin x, ninf => if x = 0 then null else if 0 < x then ninf else pinf
  | pinf, fin y => if y = 0 then null else if 0 < y then pinf else ninf
  | ninf, fin y => if y = 0 then null else if 0 < y then ninf else pinf
  | pinf, pinf => pinf
  | pinf, ninf => ninf
  | ninf, pinf => ninf
  | ninf, ninf => pinf

noncomputable instance : Mul Transreal := ⟨mul⟩

@[simp] theorem fin_mul_fin (x y : ℝ) : fin x * fin y = fin (x * y) := rfl
@[simp] theorem null_mul (a : Transreal) : null * a = null := by cases a <;> rfl
@[simp] theorem mul_null (a : Transreal) : a * null = null := by cases a <;> rfl
@[simp] theorem pinf_mul_pinf : pinf * pinf = pinf := rfl
@[simp] theorem pinf_mul_ninf : pinf * ninf = ninf := rfl
@[simp] theorem ninf_mul_pinf : ninf * pinf = ninf := rfl
@[simp] theorem ninf_mul_ninf : ninf * ninf = pinf := rfl

@[simp] theorem fin_zero_mul_pinf : fin 0 * pinf = null := by
  show mul _ _ = _; simp [mul]

@[simp] theorem fin_zero_mul_ninf : fin 0 * ninf = null := by
  show mul _ _ = _; simp [mul]

theorem fin_mul_pinf_of_pos {x : ℝ} (hx : 0 < x) : fin x * pinf = pinf := by
  show mul _ _ = _; simp [mul, hx.ne', hx]

theorem fin_mul_pinf_of_neg {x : ℝ} (hx : x < 0) : fin x * pinf = ninf := by
  show mul _ _ = _; simp [mul, hx.ne, asymm hx]

theorem fin_mul_ninf_of_pos {x : ℝ} (hx : 0 < x) : fin x * ninf = ninf := by
  show mul _ _ = _; simp [mul, hx.ne', hx]

theorem fin_mul_ninf_of_neg {x : ℝ} (hx : x < 0) : fin x * ninf = pinf := by
  show mul _ _ = _; simp [mul, hx.ne, asymm hx]

theorem mul_comm (a b : Transreal) : a * b = b * a := by
  cases a <;> cases b <;> try rfl
  exact congrArg fin (_root_.mul_comm _ _)

@[simp] theorem fin_one_mul (a : Transreal) : fin 1 * a = a := by
  cases a with
  | fin x => exact congrArg fin (one_mul x)
  | pinf => show mul _ _ = _; simp [mul]
  | ninf => show mul _ _ = _; simp [mul]
  | null => rfl

@[simp] theorem mul_fin_one (a : Transreal) : a * fin 1 = a := by
  rw [mul_comm]; simp

/-! ### Reciprocal and division

The reciprocal of `0` is `pinf`; the reciprocal of either infinity is `0`.
Division is defined, as usual, as multiplication by the reciprocal.  The
resulting behaviour at a vanishing denominator is the trichotomy
`x / 0 = pinf, ninf, null` according as `x > 0`, `x < 0`, `x = 0`. -/

open Classical in
/-- Transreal reciprocal. -/
noncomputable def recip : Transreal → Transreal
  | fin x => if x = 0 then pinf else fin x⁻¹
  | pinf => fin 0
  | ninf => fin 0
  | null => null

/-- Transreal division. -/
noncomputable def div (a b : Transreal) : Transreal := a * recip b

noncomputable instance : Div Transreal := ⟨div⟩

theorem div_def (a b : Transreal) : a / b = a * recip b := rfl

@[simp] theorem recip_fin_zero : recip (fin 0) = pinf := by simp [recip]

theorem recip_fin_of_ne {x : ℝ} (hx : x ≠ 0) : recip (fin x) = fin x⁻¹ := by
  simp [recip, hx]

@[simp] theorem recip_pinf : recip pinf = fin 0 := rfl
@[simp] theorem recip_ninf : recip ninf = fin 0 := rfl
@[simp] theorem recip_null : recip null = null := rfl

/-- **Exact conservativity of guarded division.**  Away from a zero denominator
the transreal quotient of two finite values is the finite real quotient. -/
@[simp] theorem fin_div_fin_of_ne {x y : ℝ} (hy : y ≠ 0) :
    fin x / fin y = fin (x / y) := by
  rw [div_def, recip_fin_of_ne hy, fin_mul_fin, div_eq_mul_inv]

/-- **The division boundary.**  At a vanishing denominator the quotient leaves
the finite fragment, and *which* exceptional constructor it lands on is
determined by the sign of the numerator. -/
theorem div_fin_zero (x : ℝ) :
    fin x / fin 0 = if x = 0 then null else if 0 < x then pinf else ninf := by
  rw [div_def, recip_fin_zero]
  rcases lt_trichotomy x 0 with h | h | h
  · rw [fin_mul_pinf_of_neg h]; simp [h.ne, asymm h]
  · subst h; simp
  · rw [fin_mul_pinf_of_pos h]; simp [h.ne', h]

@[simp] theorem zero_div_zero : fin 0 / fin 0 = null := by simp [div_fin_zero]

theorem div_fin_zero_of_pos {x : ℝ} (hx : 0 < x) : fin x / fin 0 = pinf := by
  simp [div_fin_zero, hx.ne', hx]

theorem div_fin_zero_of_neg {x : ℝ} (hx : x < 0) : fin x / fin 0 = ninf := by
  simp [div_fin_zero, hx.ne, asymm hx]

/-- Self-division is the constant `1` on the punctured finite fragment, but
crashes into `null` at the origin.  This dichotomy is the source of every
discontinuity proved in `Cryptography.Transreal.Topology`. -/
theorem fin_div_self (x : ℝ) : fin x / fin x = if x = 0 then null else fin 1 := by
  by_cases hx : x = 0
  · subst hx; simp
  · rw [fin_div_fin_of_ne hx, div_self hx]; simp [hx]

/-! ### Structure of the finite fragment -/

/-- The finite fragment, i.e. the image of `ℝ`. -/
def Finite (a : Transreal) : Prop := ∃ x : ℝ, a = fin x

@[simp] theorem finite_fin (x : ℝ) : Finite (fin x) := ⟨x, rfl⟩

theorem not_finite_pinf : ¬ Finite pinf := by rintro ⟨x, h⟩; cases h
theorem not_finite_ninf : ¬ Finite ninf := by rintro ⟨x, h⟩; cases h
theorem not_finite_null : ¬ Finite null := by rintro ⟨x, h⟩; cases h

/-- The finite fragment is closed under addition. -/
theorem finite_add {a b : Transreal} (ha : Finite a) (hb : Finite b) :
    Finite (a + b) := by
  obtain ⟨x, rfl⟩ := ha; obtain ⟨y, rfl⟩ := hb; exact ⟨x + y, rfl⟩

/-- The finite fragment is closed under multiplication. -/
theorem finite_mul {a b : Transreal} (ha : Finite a) (hb : Finite b) :
    Finite (a * b) := by
  obtain ⟨x, rfl⟩ := ha; obtain ⟨y, rfl⟩ := hb; exact ⟨x * y, rfl⟩

/-- The finite fragment is closed under division by a nonzero denominator. -/
theorem finite_div {x y : ℝ} (hy : y ≠ 0) : Finite (fin x / fin y) :=
  ⟨x / y, fin_div_fin_of_ne hy⟩

/-- The finite fragment is *not* closed under unguarded division: this is the
exact failure of conservativity. -/
theorem not_finite_div_zero (x : ℝ) : ¬ Finite (fin x / fin 0) := by
  rcases lt_trichotomy x 0 with h | h | h
  · rw [div_fin_zero_of_neg h]; exact not_finite_ninf
  · subst h; rw [zero_div_zero]; exact not_finite_null
  · rw [div_fin_zero_of_pos h]; exact not_finite_pinf

/-! ### Lifting real functions -/

/-- The strict lift of a real function to the transreals: it acts as `f` on the
finite fragment and sends every exceptional element to `null`. -/
def lift (f : ℝ → ℝ) : Transreal → Transreal
  | fin x => fin (f x)
  | _ => null

@[simp] theorem lift_fin (f : ℝ → ℝ) (x : ℝ) : lift f (fin x) = fin (f x) := rfl
@[simp] theorem lift_pinf (f : ℝ → ℝ) : lift f pinf = null := rfl
@[simp] theorem lift_ninf (f : ℝ → ℝ) : lift f ninf = null := rfl
@[simp] theorem lift_null (f : ℝ → ℝ) : lift f null = null := rfl

/-- Lifting is functorial on the nose: strict lifts compose. -/
theorem lift_comp (f g : ℝ → ℝ) (a : Transreal) :
    lift f (lift g a) = lift (f ∘ g) a := by
  cases a <;> rfl

end Transreal