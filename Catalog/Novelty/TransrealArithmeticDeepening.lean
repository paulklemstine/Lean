/-
Copyright (c) 2024 Harmonic Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Transreal arithmetic, deepened: monoids, homomorphisms, reciprocal, and order

This file *deepens* the study of the transreal numbers
`TReal = ℝ ⊎ {+∞, -∞, Φ}` (Anderson's total arithmetic, with `Φ = 0/0`).
It is fully self-contained: the carrier, the total operations, and the basic
algebraic laws are reproved here, and then a chain of new structural results is
built on top of them.

The base layer (carrier, `+`, `·`, `neg`, `recip`, commutativity/associativity,
identities, the six-way sign split `cases6`) reproduces the core arithmetic.
Everything from the section **DEEPENING** onward is new.

## New results (each builds on the previous)

* **Surviving structure as bundled instances.**  `(TReal, +, 0)` and
  `(TReal, ·, 1)` are genuine `AddCommMonoid` / `CommMonoid` (`instAddCommMonoid`,
  `instCommMonoid`), so the entire commutative-monoid API of Mathlib applies.

* **Negation is a homomorphism of both structures.**  Negation distributes over
  the total sum and product even at the singular values (`neg_add`, `neg_mul`,
  `mul_neg`, `neg_mul_neg`), and is an involution.

* **The reals embed as monoid homomorphisms.**  `rlAddHom : ℝ →+ TReal` and
  `rlMulHom : ℝ →* TReal` exhibit `ℝ` as a sub-`AddCommMonoid` and
  sub-`CommMonoid`.

* **Exact reach of the reciprocal involution.**  `recip ∘ recip = id`
  *everywhere except at `-∞`* (`recip_recip_eq_iff`): the failure of the wheel
  involution is pinned down to the single point `-∞`, sharpening the earlier
  blanket "not an involution".

* **Reciprocal vs. negation.**  `recip (-x) = -(recip x)` holds off `0`
  (`recip_neg_of_ne_zero`) but genuinely fails at `0`
  (`recip_neg_zero_fails`): `//(-0) = +∞` while `-(//0) = -∞`.

* **A partial order that is not linear.**  `TReal` carries a `PartialOrder`
  (`instPartialOrder`) with `-∞ < ℝ < +∞` and `Φ` incomparable to everything
  else.  It is provably not total (`not_total`), `ℝ` order-embeds
  (`rlOrderEmbedding`), and — because `Φ` floats free — the order has neither a
  greatest nor a least element (`no_greatest`, `no_least`), in stark contrast to
  the extended reals `[-∞, +∞]`.
-/

open Classical

/-- The transreal numbers: the reals together with `+∞`, `-∞`, and nullity `Φ`. -/
inductive TReal
  | /-- Nullity `Φ`, the value of `0/0`. -/ phi
  | /-- Positive infinity `+∞`. -/ pinf
  | /-- Negative infinity `-∞`. -/ ninf
  | /-- The embedding of a real number. -/ rl (r : ℝ)

namespace TReal

/-! ## Base layer (reproduced core arithmetic) -/

/-- Transreal addition.  `Φ` absorbs everything and `+∞ + -∞ = Φ`. -/
noncomputable def add : TReal → TReal → TReal
  | phi, _ => phi | _, phi => phi | pinf, ninf => phi | ninf, pinf => phi
  | pinf, pinf => pinf | pinf, rl _ => pinf | rl _, pinf => pinf
  | ninf, ninf => ninf | ninf, rl _ => ninf | rl _, ninf => ninf
  | rl a, rl b => rl (a + b)

/-- Transreal multiplication.  `Φ` absorbs everything and `0 · ±∞ = Φ`. -/
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

theorem add_def (x y : TReal) : x + y = add x y := rfl
theorem mul_def (x y : TReal) : x * y = mul x y := rfl
theorem neg_def (x : TReal) : -x = neg x := rfl
theorem zero_eq : (0 : TReal) = rl 0 := rfl
theorem one_eq : (1 : TReal) = rl 1 := rfl

@[simp] theorem rl_add (a b : ℝ) : rl a + rl b = rl (a + b) := rfl
@[simp] theorem rl_mul (a b : ℝ) : rl a * rl b = rl (a * b) := rfl
@[simp] theorem rl_neg (a : ℝ) : -(rl a) = rl (-a) := rfl

theorem add_comm (x y : TReal) : x + y = y + x := by
  cases x <;> cases y <;> simp only [add_def, add] <;> ring_nf

theorem add_assoc (x y z : TReal) : x + y + z = x + (y + z) := by
  cases x <;> cases y <;> cases z <;> simp only [add_def, add] <;> ring_nf

@[simp] theorem zero_add (x : TReal) : 0 + x = x := by
  cases x <;> simp only [add_def, add, zero_eq] <;> ring_nf

@[simp] theorem add_zero (x : TReal) : x + 0 = x := by
  cases x <;> simp only [add_def, add, zero_eq] <;> ring_nf

theorem mul_comm (x y : TReal) : x * y = y * x := by
  cases x <;> cases y <;> simp only [mul_def, mul] <;> ring_nf

/-! Nullity absorbs, and closed forms for products with the singular values. -/

@[simp] theorem phi_add (x : TReal) : phi + x = phi := by cases x <;> rfl
@[simp] theorem add_phi (x : TReal) : x + phi = phi := by cases x <;> rfl
@[simp] theorem phi_mul (x : TReal) : phi * x = phi := by cases x <;> rfl
@[simp] theorem mul_phi (x : TReal) : x * phi = phi := by cases x <;> rfl
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

/-- Every transreal is nullity, an infinity, or a real of definite sign. -/
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

theorem mul_assoc (x y z : TReal) : x * y * z = x * (y * z) := by
  obtain (rfl|rfl|rfl|⟨a,ha,rfl⟩|rfl|⟨a,ha,rfl⟩) := cases6 x <;>
  obtain (rfl|rfl|rfl|⟨b,hb,rfl⟩|rfl|⟨b,hb,rfl⟩) := cases6 y <;>
  obtain (rfl|rfl|rfl|⟨c,hc,rfl⟩|rfl|⟨c,hc,rfl⟩) := cases6 z <;>
  (try simp_all [mul_pos_iff, mul_neg_iff]) <;> (try ring)

@[simp] theorem one_mul (x : TReal) : 1 * x = x := by
  cases x <;> simp only [mul_def, mul, one_eq] <;> norm_num

@[simp] theorem mul_one (x : TReal) : x * 1 = x := by
  cases x <;> simp only [mul_def, mul, one_eq] <;> norm_num

@[simp] theorem neg_neg (x : TReal) : - -x = x := by
  cases x <;> simp only [neg_def, neg] <;> ring_nf

/-!
## DEEPENING

Everything below is new work built on the base layer above.
-/

/-! ### The surviving commutative monoids, as bundled instances -/

/-- `(TReal, +, 0)` is a commutative monoid: additive associativity, commutativity
and the identity laws all survive the singular values `±∞, Φ`. -/
noncomputable instance instAddCommMonoid : AddCommMonoid TReal where
  add := (· + ·)
  add_assoc := add_assoc
  zero := 0
  zero_add := zero_add
  add_zero := add_zero
  add_comm := add_comm
  nsmul := nsmulRec

/-- `(TReal, ·, 1)` is a commutative monoid: multiplicative associativity,
commutativity and the identity laws all survive the singular values. -/
noncomputable instance instCommMonoid : CommMonoid TReal where
  mul := (· * ·)
  mul_assoc := mul_assoc
  one := 1
  one_mul := one_mul
  mul_one := mul_one
  mul_comm := mul_comm
  npow := npowRec

/-! ### Negation is a homomorphism of both monoid structures -/

@[simp] theorem neg_phi : (-phi : TReal) = phi := rfl
theorem neg_pinf : (-pinf : TReal) = ninf := rfl
theorem neg_ninf : (-ninf : TReal) = pinf := rfl

@[simp] theorem neg_zero' : (-(0 : TReal)) = 0 := by
  simp only [zero_eq, neg_def, neg, neg_zero]

/-- Negation distributes over the total sum, even at `±∞`:
`-(x + y) = (-x) + (-y)`. -/
theorem neg_add (x y : TReal) : -(x + y) = -x + -y := by
  cases x <;> cases y <;> simp only [add_def, add, neg_def, neg] <;> ring_nf

/-- Negation moves through the total product on the left: `-(x·y) = (-x)·y`. -/
theorem neg_mul (x y : TReal) : -(x * y) = -x * y := by
  obtain (rfl|rfl|rfl|⟨a,ha,rfl⟩|rfl|⟨a,ha,rfl⟩) := cases6 x <;>
  obtain (rfl|rfl|rfl|⟨b,hb,rfl⟩|rfl|⟨b,hb,rfl⟩) := cases6 y <;>
  simp_all [neg_def, neg]

/-- Negation moves through the total product on the right: `-(x·y) = x·(-y)`. -/
theorem mul_neg (x y : TReal) : -(x * y) = x * -y := by
  rw [mul_comm x y, neg_mul, mul_comm]

/-- Two sign flips cancel in a product: `(-x)·(-y) = x·y`. -/
theorem neg_mul_neg (x y : TReal) : -x * -y = x * y := by
  rw [← neg_mul, ← mul_neg, neg_neg]

/-! ### The reals embed as monoid homomorphisms -/

theorem rl_injective : Function.Injective rl := by
  intro a b h; injection h

/-- `rl : ℝ → TReal` is an additive monoid homomorphism, exhibiting `ℝ` as a
sub-`AddCommMonoid` of `TReal`. -/
def rlAddHom : ℝ →+ TReal where
  toFun := rl
  map_zero' := rfl
  map_add' a b := (rl_add a b).symm

/-- `rl : ℝ → TReal` is a multiplicative monoid homomorphism, exhibiting `ℝ` as a
sub-`CommMonoid` of `TReal`. -/
def rlMulHom : ℝ →* TReal where
  toFun := rl
  map_one' := rfl
  map_mul' a b := (rl_mul a b).symm

@[simp] theorem rlAddHom_apply (a : ℝ) : rlAddHom a = rl a := rfl
@[simp] theorem rlMulHom_apply (a : ℝ) : rlMulHom a = rl a := rfl

/-! ### The exact reach of the reciprocal involution -/

@[simp] theorem recip_phi : recip phi = phi := rfl
@[simp] theorem recip_pinf : recip pinf = rl 0 := rfl
@[simp] theorem recip_ninf : recip ninf = rl 0 := rfl

theorem recip_rl_zero : recip (rl 0) = pinf := by simp [recip]
theorem recip_rl_ne {a : ℝ} (h : a ≠ 0) : recip (rl a) = rl a⁻¹ := by simp [recip, h]

/-- The reciprocal is an involution everywhere except at `-∞`:
`recip (recip x) = x` whenever `x ≠ -∞`. -/
theorem recip_recip_of_ne_ninf {x : TReal} (h : x ≠ ninf) : recip (recip x) = x := by
  cases x with
  | phi => rfl
  | pinf => simp [recip]
  | ninf => exact absurd rfl h
  | rl a =>
    by_cases ha : a = 0
    · subst ha; simp [recip]
    · simp [recip, ha, inv_ne_zero ha, inv_inv]

/-- **Sharp reach of the involution.**  `recip (recip x) = x` holds precisely
when `x ≠ -∞`; the sole failure is `recip (recip (-∞)) = 1/0 = +∞`. -/
theorem recip_recip_eq_iff (x : TReal) : recip (recip x) = x ↔ x ≠ ninf := by
  constructor
  · intro h hx; subst hx; simp [recip] at h
  · exact recip_recip_of_ne_ninf

/-- The reciprocal is not an involution: this is now a corollary of the sharp
characterization, located exactly at `-∞`. -/
theorem recip_involution_fails : recip (recip ninf) ≠ ninf := by
  rw [ne_eq, recip_recip_eq_iff]; simp

/-! ### Reciprocal versus negation: agreement off `0`, collapse at `0` -/

/-- Off `0`, the reciprocal commutes with negation: `recip (-x) = -(recip x)`. -/
theorem recip_neg_of_ne_zero {x : TReal} (h : x ≠ 0) : recip (-x) = -(recip x) := by
  cases x with
  | phi => rfl
  | pinf => simp [recip, neg_def, neg]
  | ninf => simp [recip, neg_def, neg]
  | rl a =>
    have ha : a ≠ 0 := fun h0 => h (by rw [zero_eq, h0])
    simp [recip, neg_def, neg, ha, inv_neg]

/-- At `0` the identity `recip (-x) = -(recip x)` genuinely fails:
`recip (-0) = recip 0 = +∞`, while `-(recip 0) = -∞`. -/
theorem recip_neg_zero_fails : recip (-(0 : TReal)) ≠ -(recip 0) := by
  simp only [zero_eq, neg_def, neg, neg_zero, recip_rl_zero]
  exact fun h => TReal.noConfusion h

/-! ### A partial order that is not linear -/

/-- The transreal order: `-∞ < ℝ < +∞`, with `Φ` incomparable to everything but
itself. -/
def le : TReal → TReal → Prop
  | phi, phi => True
  | phi, _ => False
  | _, phi => False
  | ninf, _ => True
  | pinf, pinf => True
  | pinf, _ => False
  | rl _, ninf => False
  | rl _, pinf => True
  | rl a, rl b => a ≤ b

theorem le_refl' (x : TReal) : le x x := by
  cases x <;> simp only [le] <;> exact le_rfl

theorem le_trans' : ∀ {x y z : TReal}, le x y → le y z → le x z := by
  rintro x y z hxy hyz
  cases x <;> cases y <;> cases z <;> simp_all only [le] <;>
    exact hxy.trans hyz

theorem le_antisymm' : ∀ {x y : TReal}, le x y → le y x → x = y := by
  rintro x y hxy hyx
  cases x <;> cases y <;> simp_all only [le] <;>
    first | rfl | (congr 1; exact le_antisymm hxy hyx)

/-- `TReal` is a partial order under `le`. -/
instance instPartialOrder : PartialOrder TReal where
  le := le
  le_refl := le_refl'
  le_trans _ _ _ := le_trans'
  le_antisymm _ _ := le_antisymm'

theorem le_iff (x y : TReal) : x ≤ y ↔ le x y := Iff.rfl

@[simp] theorem rl_le_rl {a b : ℝ} : (rl a ≤ rl b) ↔ a ≤ b := Iff.rfl

theorem ninf_le_of_ne_phi {x : TReal} (h : x ≠ phi) : ninf ≤ x := by
  cases x <;> simp_all [le_iff, le]

theorem le_pinf_of_ne_phi {x : TReal} (h : x ≠ phi) : x ≤ pinf := by
  cases x <;> simp_all [le_iff, le]

/-- `Φ` is incomparable with `+∞` (and hence with everything but itself). -/
theorem phi_incomparable_pinf : ¬ (phi ≤ pinf) ∧ ¬ (pinf ≤ phi) := by
  constructor <;> simp [le_iff, le]

/-- The transreal order is **not** total: `Φ` and `+∞` are incomparable. -/
theorem not_total : ¬ ∀ x y : TReal, x ≤ y ∨ y ≤ x := by
  intro h
  rcases h phi pinf with h1 | h1 <;> simp [le_iff, le] at h1

/-- `ℝ` order-embeds into `TReal` via `rl`. -/
def rlOrderEmbedding : ℝ ↪o TReal where
  toFun := rl
  inj' := rl_injective
  map_rel_iff' := rl_le_rl

/-- Because `Φ` floats free of the order, `TReal` has **no greatest element**,
unlike the extended reals `[-∞, +∞]`. -/
theorem no_greatest : ¬ ∃ g : TReal, ∀ x, x ≤ g := by
  rintro ⟨g, hg⟩
  have h1 := hg phi
  have h2 := hg pinf
  cases g <;> simp_all [le_iff, le]

/-- Dually, `TReal` has **no least element**. -/
theorem no_least : ¬ ∃ b : TReal, ∀ x, b ≤ x := by
  rintro ⟨b, hb⟩
  have h1 := hb phi
  have h2 := hb pinf
  cases b <;> simp_all [le_iff, le]

end TReal