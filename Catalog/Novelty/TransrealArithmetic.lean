/-
Copyright (c) 2024 Harmonic Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Transreal arithmetic: total computation beyond `±∞`

The *transreal numbers* extend the real line with two signed infinities `+∞`, `-∞`
and a fourth value `Φ` ("nullity"), the canonical result of the indeterminate
expression `0/0`.  The defining ambition of the system is **totality**: every
sum, product, and quotient — including `1/0`, `∞ - ∞`, and `0 · ∞` — returns a
value, with `Φ` acting as a global "error" element that, once produced, is never
escaped.

This file develops that arithmetic from scratch on the carrier

  `TReal = ℝ ⊎ {+∞, -∞, Φ}`

and settles precisely which algebraic laws survive the extension and which
collapse.

## What survives

* Both `(TReal, +, 0)` and `(TReal, ·, 1)` are **commutative monoids**
  (`TReal.add_comm`, `TReal.add_assoc`, `TReal.mul_comm`, `TReal.mul_assoc`,
  together with the identity laws).
* `Φ` is a **global absorbing element** for addition and multiplication
  (`TReal.phi_add`, `TReal.phi_mul`), and is a fixed point of `Φ + x`
  even against `x = ±∞`.
* The finite reals embed as a submonoid on which every classical identity
  is retained (`TReal.rl_add`, `TReal.rl_mul`).
* Division is **total**, and Anderson's defining identity `0/0 = Φ`
  holds on the nose (`TReal.zero_div_zero`).

## What collapses

* `TReal` is **not a ring**: `+∞` has no additive inverse
  (`TReal.no_add_inverse_pinf`), the annihilator law `0 · x = 0` fails at
  `x = ∞` (`TReal.zero_mul_pinf`), and distributivity fails outright
  (`TReal.distrib_fails`).
* `TReal` is **not a wheel** either: the wheel distributive law
  `(x + y)·z + 0·z = x·z + y·z` fails (`TReal.wheel_distrib_fails`), and the
  reciprocal is **not** an involution — `//(-∞) = +∞ ≠ -∞`
  (`TReal.recip_involution_fails`).  Thus the totalisation of `±∞` sits
  strictly *below* the wheel axioms that the single-point projective
  compactification satisfies.
* Real-analytic bookkeeping degrades: additive cancellation fails
  (`TReal.add_cancel_fails`).

-- !-- Lab Notes -- !--
Hypothesis (given): "The ring axioms fail but a wheel structure emerges."
Experiment: we formalised Anderson's total arithmetic verbatim and stress-tested
  each ring and each wheel axiom against the three singular values `±∞, Φ`.
Analysis:
  * The two commutative-monoid skeletons survive intact — associativity and
    commutativity are robust to the singular values because `Φ` is absorbing and
    the only "dangerous" sums (`+∞ + -∞`) and products (`0 · ±∞`) already land in
    `Φ`, which every subsequent operation preserves.
  * The ring half of the hypothesis is confirmed: distributivity and additive
    inverses genuinely fail.
  * The wheel half of the hypothesis is *refuted*.  The wheel distributive law
    `(x+y)z + 0z = xz + yz` needs `0·z` to be a benign correction term, but in
    the transreals `0 · ∞ = Φ` contaminates the whole left-hand side, so the law
    fails (take `x=2, y=3, z=+∞`: LHS `= Φ`, RHS `= +∞`).  Independently, the
    reciprocal is not an involution once `-∞` is present.
Critique: the collapse of the wheel law is not an artefact of a bad reciprocal
  choice — it is forced by the sign split of `±∞`, which is exactly the feature
  that distinguishes transreals from the single-infinity projective wheel.
Synthesis: transreals are precisely a *pair of commutative monoids sharing a
  global absorbing element, equipped with a total but non-involutive division* —
  strictly weaker than both a ring and a wheel.
-/

open Classical

/-- The transreal numbers: the reals together with `+∞`, `-∞`, and nullity `Φ`. -/
inductive TReal
  | /-- Nullity `Φ`, the value of `0/0`. -/ phi
  | /-- Positive infinity `+∞`. -/ pinf
  | /-- Negative infinity `-∞`. -/ ninf
  | /-- The embedding of a real number. -/ rl (r : ℝ)

namespace TReal

/-- Transreal addition.  `Φ` absorbs everything and `+∞ + -∞ = Φ`. -/
noncomputable def add : TReal → TReal → TReal
  | phi, _ => phi | _, phi => phi | pinf, ninf => phi | ninf, pinf => phi
  | pinf, pinf => pinf | pinf, rl _ => pinf | rl _, pinf => pinf
  | ninf, ninf => ninf | ninf, rl _ => ninf | rl _, ninf => ninf
  | rl a, rl b => rl (a + b)

/-- Transreal multiplication.  `Φ` absorbs everything and `0 · ±∞ = Φ`.
The real factor's sign is tested against zero first, so that `0 · (±∞) = Φ`. -/
noncomputable def mul : TReal → TReal → TReal
  | phi, _ => phi | _, phi => phi | pinf, pinf => pinf | pinf, ninf => ninf
  | ninf, pinf => ninf | ninf, ninf => pinf
  | pinf, rl b => if b = 0 then phi else if 0 < b then pinf else ninf
  | rl a, pinf => if a = 0 then phi else if 0 < a then pinf else ninf
  | ninf, rl b => if b = 0 then phi else if 0 < b then ninf else pinf
  | rl a, ninf => if a = 0 then phi else if 0 < a then ninf else pinf
  | rl a, rl b => rl (a * b)

/-- Transreal negation. -/
def neg : TReal → TReal
  | phi => phi | pinf => ninf | ninf => pinf | rl a => rl (-a)

/-- Transreal reciprocal: `1/0 = +∞`, `1/(±∞) = 0`, `1/Φ = Φ`. -/
noncomputable def recip : TReal → TReal
  | phi => phi | pinf => rl 0 | ninf => rl 0
  | rl a => if a = 0 then pinf else rl a⁻¹

noncomputable instance : Add TReal := ⟨add⟩
noncomputable instance : Mul TReal := ⟨mul⟩
instance : Neg TReal := ⟨neg⟩
instance : Zero TReal := ⟨rl 0⟩
instance : One TReal := ⟨rl 1⟩

/-- Total transreal division, `x / y = x · (1/y)`. -/
noncomputable def div (x y : TReal) : TReal := x * recip y

theorem add_def (x y : TReal) : x + y = add x y := rfl
theorem mul_def (x y : TReal) : x * y = mul x y := rfl
theorem neg_def (x : TReal) : -x = neg x := rfl
theorem zero_eq : (0 : TReal) = rl 0 := rfl
theorem one_eq : (1 : TReal) = rl 1 := rfl

/-! ### The embedding of the reals -/

/-- Addition of finite values is ordinary real addition. -/
@[simp] theorem rl_add (a b : ℝ) : rl a + rl b = rl (a + b) := rfl
/-- Multiplication of finite values is ordinary real multiplication. -/
@[simp] theorem rl_mul (a b : ℝ) : rl a * rl b = rl (a * b) := rfl
/-- Negation of a finite value is ordinary real negation. -/
@[simp] theorem rl_neg (a : ℝ) : -(rl a) = rl (-a) := rfl

/-! ### Nullity is a global absorbing element -/

@[simp] theorem phi_add (x : TReal) : phi + x = phi := by cases x <;> rfl
@[simp] theorem add_phi (x : TReal) : x + phi = phi := by cases x <;> rfl
@[simp] theorem phi_mul (x : TReal) : phi * x = phi := by cases x <;> rfl
@[simp] theorem mul_phi (x : TReal) : x * phi = phi := by cases x <;> rfl
@[simp] theorem phi_recip : recip phi = phi := rfl

/-- Nullity is even stable under the singular sum `Φ + (±∞)`. -/
theorem phi_add_pinf : phi + pinf = phi := rfl

/-! ### Additive commutative monoid -/

theorem add_comm (x y : TReal) : x + y = y + x := by
  cases x <;> cases y <;> simp only [add_def, add]
  all_goals ring_nf

theorem add_assoc (x y z : TReal) : x + y + z = x + (y + z) := by
  cases x <;> cases y <;> cases z <;> simp only [add_def, add]
  all_goals ring_nf

@[simp] theorem zero_add (x : TReal) : 0 + x = x := by
  cases x <;> simp only [add_def, add, zero_eq]
  all_goals ring_nf

@[simp] theorem add_zero (x : TReal) : x + 0 = x := by
  cases x <;> simp only [add_def, add, zero_eq]
  all_goals ring_nf

/-! ### Multiplicative commutative monoid -/

theorem mul_comm (x y : TReal) : x * y = y * x := by
  cases x <;> cases y <;> simp only [mul_def, mul]
  all_goals ring_nf

/-! #### Closed forms for products with the singular values.

These record the value of every product involving `±∞` in terms of the sign of
the real factor.  They are the computational engine behind associativity. -/

@[simp] theorem mul_pinf_pinf : (pinf * pinf : TReal) = pinf := rfl
@[simp] theorem mul_pinf_ninf : (pinf * ninf : TReal) = ninf := rfl
@[simp] theorem mul_ninf_pinf : (ninf * pinf : TReal) = ninf := rfl
@[simp] theorem mul_ninf_ninf : (ninf * ninf : TReal) = pinf := rfl
@[simp] theorem pinf_mul_rl_pos {b : ℝ} (h : 0 < b) : pinf * rl b = pinf := by
  rw [mul_def]; simp [mul, h.ne', h]
@[simp] theorem pinf_mul_rl_neg {b : ℝ} (h : b < 0) : pinf * rl b = ninf := by
  rw [mul_def]; simp [mul, h.ne, not_lt.2 h.le]
@[simp] theorem pinf_mul_rl_zero : pinf * rl 0 = phi := by rw [mul_def]; simp [mul]
@[simp] theorem ninf_mul_rl_pos {b : ℝ} (h : 0 < b) : ninf * rl b = ninf := by
  rw [mul_def]; simp [mul, h.ne', h]
@[simp] theorem ninf_mul_rl_neg {b : ℝ} (h : b < 0) : ninf * rl b = pinf := by
  rw [mul_def]; simp [mul, h.ne, not_lt.2 h.le]
@[simp] theorem ninf_mul_rl_zero : ninf * rl 0 = phi := by rw [mul_def]; simp [mul]
@[simp] theorem rl_mul_pinf_pos {a : ℝ} (h : 0 < a) : rl a * pinf = pinf := by
  rw [mul_def]; simp [mul, h.ne', h]
@[simp] theorem rl_mul_pinf_neg {a : ℝ} (h : a < 0) : rl a * pinf = ninf := by
  rw [mul_def]; simp [mul, h.ne, not_lt.2 h.le]
@[simp] theorem rl_mul_pinf_zero : rl 0 * pinf = phi := by rw [mul_def]; simp [mul]
@[simp] theorem rl_mul_ninf_pos {a : ℝ} (h : 0 < a) : rl a * ninf = ninf := by
  rw [mul_def]; simp [mul, h.ne', h]
@[simp] theorem rl_mul_ninf_neg {a : ℝ} (h : a < 0) : rl a * ninf = pinf := by
  rw [mul_def]; simp [mul, h.ne, not_lt.2 h.le]
@[simp] theorem rl_mul_ninf_zero : rl 0 * ninf = phi := by rw [mul_def]; simp [mul]

/-- Every transreal is nullity, an infinity, or a real of definite sign.
This six-way split drives the associativity case analysis. -/
theorem cases6 (t : TReal) :
    t = phi ∨ t = pinf ∨ t = ninf ∨ (∃ r, 0 < r ∧ t = rl r) ∨ t = rl 0 ∨
      (∃ r, r < 0 ∧ t = rl r) := by
  cases t with
  | phi => tauto
  | pinf => tauto
  | ninf => tauto
  | rl r =>
    rcases lt_trichotomy r 0 with h | h | h
    · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr ⟨r, h, rfl⟩))))
    · subst h; tauto
    · exact Or.inr (Or.inr (Or.inr (Or.inl ⟨r, h, rfl⟩)))

/-- Transreal multiplication is associative: `(TReal, ·)` is a commutative monoid. -/
theorem mul_assoc (x y z : TReal) : x * y * z = x * (y * z) := by
  obtain (rfl|rfl|rfl|⟨a,ha,rfl⟩|rfl|⟨a,ha,rfl⟩) := cases6 x <;>
  obtain (rfl|rfl|rfl|⟨b,hb,rfl⟩|rfl|⟨b,hb,rfl⟩) := cases6 y <;>
  obtain (rfl|rfl|rfl|⟨c,hc,rfl⟩|rfl|⟨c,hc,rfl⟩) := cases6 z <;>
  (try simp_all [mul_pos_iff, mul_neg_iff]) <;> (try ring)

@[simp] theorem one_mul (x : TReal) : 1 * x = x := by
  cases x <;> simp only [mul_def, mul, one_eq] <;> norm_num

@[simp] theorem mul_one (x : TReal) : x * 1 = x := by
  cases x <;> simp only [mul_def, mul, one_eq] <;> norm_num

/-! ### The ring axioms collapse -/

/-- `+∞` has no additive inverse, so `(TReal, +)` is not a group and `TReal`
is not a ring. -/
theorem no_add_inverse_pinf (y : TReal) : pinf + y ≠ 0 := by
  cases y <;> simp only [add_def, add, zero_eq] <;> exact fun h => TReal.noConfusion h

/-- The annihilator law `0 · x = 0` fails: `0 · ∞ = Φ`. -/
theorem zero_mul_pinf : (0 : TReal) * pinf = phi := by
  simp only [mul_def, mul, zero_eq]; norm_num

/-- Distributivity fails: `(2 + (-1))·∞ = +∞` but `2·∞ + (-1)·∞ = Φ`. -/
theorem distrib_fails :
    (rl 2 + rl (-1)) * pinf ≠ rl 2 * pinf + rl (-1) * pinf := by
  simp only [add_def, mul_def, add, mul]
  norm_num
  exact fun h => TReal.noConfusion h

/-- Additive cancellation fails: `+∞ + 1 = +∞ + 2` yet `1 ≠ 2`. -/
theorem add_cancel_fails : pinf + rl 1 = pinf + rl 2 ∧ (rl 1 : TReal) ≠ rl 2 := by
  refine ⟨rfl, ?_⟩
  intro h; injection h with h; norm_num at h

/-! ### The wheel axioms collapse too -/

/-- The wheel distributive law `(x+y)·z + 0·z = x·z + y·z` fails.
Take `x = 2, y = 3, z = +∞`: the left side is `Φ` (poisoned by `0·∞`), the
right side is `+∞`. -/
theorem wheel_distrib_fails :
    (rl 2 + rl 3) * pinf + (0 : TReal) * pinf ≠ rl 2 * pinf + rl 3 * pinf := by
  simp only [add_def, mul_def, add, mul, zero_eq]
  norm_num
  exact fun h => TReal.noConfusion h

/-- The reciprocal is not an involution: `//(-∞) = 1/0 = +∞ ≠ -∞`. -/
theorem recip_involution_fails : recip (recip ninf) ≠ ninf := by
  simp only [recip]; norm_num
  exact fun h => TReal.noConfusion h

/-! ### Total division and Anderson's defining identity -/

/-- The reciprocal of zero is `+∞`. -/
@[simp] theorem recip_zero : recip 0 = pinf := by
  simp [recip]

/-- Anderson's defining identity: `0 / 0 = Φ`. -/
theorem zero_div_zero : div 0 0 = phi := by
  simp [div, recip, mul_def, mul]

/-- `1 / 0 = +∞`. -/
theorem one_div_zero : div 1 0 = pinf := by
  simp [div, recip, one_eq, mul_def, mul]

/-- Nullity absorbs division on the left. -/
@[simp] theorem phi_div (y : TReal) : div phi y = phi := by
  simp only [div, phi_mul]

/-! ### Negation -/

@[simp] theorem neg_neg (x : TReal) : - -x = x := by
  cases x <;> simp only [neg_def, neg]
  all_goals ring_nf
@[simp] theorem neg_phi : -(phi) = phi := rfl
theorem neg_pinf : -(pinf) = ninf := rfl
theorem neg_ninf : -(ninf) = pinf := rfl

end TReal