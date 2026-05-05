/-
# Boolean Rings and the Algebra of Idempotents

This module develops the theory of Boolean rings — rings where every element is
idempotent (x² = x for all x). The central result is the surprising theorem that
**every Boolean ring is commutative**, proved purely from the idempotent axiom.

## Main Results

* `BooleanRing'.add_self_eq_zero` — In a Boolean ring, every element has additive order 2
* `BooleanRing'.mul_comm` — Every Boolean ring is commutative
* `idempotent_complement` — If e is idempotent, so is 1 - e
* `idempotent_product` — The product of commuting idempotents is idempotent
* `orthogonal_idempotent_sum` — The sum of orthogonal idempotents is idempotent

## Mathematical Significance

The commutativity theorem is remarkable because it derives a strong structural
property (commutativity) from a seemingly unrelated condition (idempotency).
The proof uses a clever algebraic trick: expand (x + y)² = x + y using the
Boolean axiom, then use the characteristic 2 property (also derived from
idempotency) to conclude xy = yx.

Boolean rings are intimately connected to Boolean algebras and have applications
in digital circuit design, set theory, and logic.
-/

import Mathlib

/-! ## Section 1: Idempotent Elements in General Rings -/

variable {R : Type*} [Ring R]

/-- An element e of a ring is idempotent if e * e = e. -/
def IsIdempotent' (e : R) : Prop := e * e = e

/-
If e is idempotent, then 1 - e is also idempotent. This gives rise to
    complementary orthogonal decompositions of the ring.
-/
theorem idempotent_complement {e : R} (h : IsIdempotent' e) :
    IsIdempotent' (1 - e) := by
      unfold IsIdempotent' at *;
      simp +decide [ sub_mul, mul_sub, h ]

/-
The product of two commuting idempotents is idempotent.
-/
theorem idempotent_product {e f : R} (he : IsIdempotent' e) (hf : IsIdempotent' f)
    (hc : e * f = f * e) : IsIdempotent' (e * f) := by
      unfold IsIdempotent' at *;
      grind +splitImp

/-
If e and f are orthogonal idempotents (ef = 0 and fe = 0), their sum
    is also idempotent.
-/
theorem orthogonal_idempotent_sum {e f : R}
    (he : IsIdempotent' e) (hf : IsIdempotent' f)
    (h1 : e * f = 0) (h2 : f * e = 0) :
    IsIdempotent' (e + f) := by
      unfold IsIdempotent' at *; simp_all +decide [ add_mul, mul_add ] ;

/-
An idempotent element e and its complement 1 - e are orthogonal.
-/
theorem idempotent_orthogonal_complement {e : R} (h : IsIdempotent' e) :
    e * (1 - e) = 0 ∧ (1 - e) * e = 0 := by
      simp_all +decide [ mul_sub, sub_mul, IsIdempotent' ]

/-
In any ring, 0 and 1 are always idempotent.
-/
theorem zero_one_idempotent : IsIdempotent' (0 : R) ∧ IsIdempotent' (1 : R) := by
  exact ⟨ mul_zero 0, one_mul 1 ⟩

/-! ## Section 2: Boolean Rings — Characteristic 2 and Commutativity -/

/-- The Boolean ring axiom: every element is idempotent. -/
def IsBooleanRing' (R : Type*) [Ring R] : Prop := ∀ x : R, x * x = x

/-
**Key Lemma**: In a Boolean ring, every element is its own additive inverse.
    Proof: x + x = (x + x)² = x² + x² + x² + x² = x + x + x + x,
    so x + x = 0, meaning x = -x.
-/
theorem BooleanRing'.add_self_eq_zero (hB : IsBooleanRing' R) (x : R) :
    x + x = 0 := by
      have := hB ( x + x );
      simp_all +decide [ add_mul, mul_add ];
      have := hB x; simp_all +decide [ ← add_assoc ] ;

/-
In a Boolean ring, x = -x for every element.
-/
theorem BooleanRing'.neg_eq_self (hB : IsBooleanRing' R) (x : R) :
    -x = x := by
      rw [ neg_eq_of_add_eq_zero_right ( BooleanRing'.add_self_eq_zero hB x ) ]

/-
**Main Theorem**: Every Boolean ring is commutative.

    Proof sketch: By `add_self_eq_zero`, every element satisfies a = -a.
    Now expand (x + y)² = x + y using the Boolean axiom:
      x² + xy + yx + y² = x + y
      x + xy + yx + y = x + y
    So xy + yx = 0, which means xy = -(yx) = yx.
-/
theorem BooleanRing'.mul_comm (hB : IsBooleanRing' R) (x y : R) :
    x * y = y * x := by
      -- Applying the Boolean ring axiom to $(x + y)$, we have $(x + y)^2 = x + y$.
      have h_sum_sq : (x + y) * (x + y) = x + y := by
        exact hB _;
      simp_all +decide [ mul_add, add_mul, add_assoc ];
      have h_cancel : x * y + y * x = 0 := by
        simp_all +decide [ ← add_assoc, IsBooleanRing' ];
        grind;
      rw [ eq_neg_of_add_eq_zero_left h_cancel, BooleanRing'.neg_eq_self hB ]

/-! ## Section 3: The Boolean Ring Partial Order -/

/-- In a Boolean ring, we can define a partial order: a ≤ b iff a * b = a.
    This is the first step toward the Boolean algebra structure. -/
def booleanLe (a b : R) : Prop := a * b = a

/-- The Boolean ring order is reflexive (since a * a = a). -/
theorem booleanLe_refl (hB : IsBooleanRing' R) (a : R) : booleanLe a a :=
  hB a

/-
The Boolean ring order is antisymmetric.
    If a * b = a and b * a = b, then using commutativity, a = a * b = b * a = b.
-/
theorem booleanLe_antisymm (hB : IsBooleanRing' R) {a b : R}
    (h1 : booleanLe a b) (h2 : booleanLe b a) : a = b := by
      have := hB ( a + b );
      simp_all +decide [ add_mul, mul_add ];
      simp_all +decide [ ← add_assoc, booleanLe ];
      simp_all +decide [ add_comm, add_left_comm, add_assoc, IsBooleanRing' ];
      simp_all +decide [ ← add_assoc, ← eq_sub_iff_add_eq ]

/-
The Boolean ring order is transitive.
    If a * b = a and b * c = b, then a * c = (a * b) * c = a * (b * c) = a * b = a.
-/
theorem booleanLe_trans (_hB : IsBooleanRing' R) {a b c : R}
    (h1 : booleanLe a b) (h2 : booleanLe b c) :
    booleanLe a c := by
      grind +locals

/-! ## Section 4: Concrete Examples -/

/-
ℤ/2ℤ is a Boolean ring.
-/
theorem ZMod2_is_boolean : IsBooleanRing' (ZMod 2) := by
  exact fun x => by fin_cases x <;> rfl;