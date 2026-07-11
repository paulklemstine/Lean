/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Geometry.QuasifieldAffinePlane

/-!
# The Dickson Nearfield of Order 9 and its Non-Desarguesian Plane

We construct the (unique) proper finite **nearfield** of order `9` — a Dickson
nearfield built from the field `GF(9) = GF(3)[α]/(α²+1)` by twisting the field
multiplication with the Frobenius automorphism `σ : x ↦ x³` on non-square right
factors — and verify *explicitly* (by finite computation) that it satisfies the
axioms of a quasifield in the sense of
`Catalog.Geometry.QuasifieldAffinePlane`.

Consequently it coordinatizes a genuine affine plane of order `9` (all incidence
axioms hold, being instances of the general theorems for quasifields).  The key
point is that this quasifield is **not a division ring**:

* `dicksonQF_not_leftDistrib` — left distributivity fails;
* `dicksonQF_not_commutative` — multiplication is non-commutative;
* `dicksonQF_assoc` — yet multiplication *is* associative (it is a nearfield).

Because the coordinatizing ring is not a (two-sided) division ring, the
resulting plane is **non-Desarguesian**: this is the algebraic hallmark of the
classical coordinatization theorem (a projective/affine plane is Desarguesian
iff it is coordinatized by a division ring).  Here `q = 9 = 3²` gives the
smallest prime-power order at which a non-Desarguesian plane exists.

The additive group is the standard product group on `ZMod 3 × ZMod 3`; only the
multiplication is exotic.

## References
* Dickson, L. E. *Linear algebras with associativity not assumed.*
* Hughes, D. R. and Piper, F. C. *Projective Planes*, Springer 1973.
-/

namespace NearfieldPlaneOrder9

open QuasifieldPlane

/-- The carrier: the additive group underlying `GF(9)`, i.e. `GF(3)²`. -/
abbrev G : Type := ZMod 3 × ZMod 3

/-- Field multiplication of `GF(9) = GF(3)[α]`, `α² = -1 = 2`:
`(a + bα)(c + dα) = (ac + 2bd) + (ad + bc)α`. -/
def gf9Mul (x y : G) : G :=
  (x.1 * y.1 + 2 * x.2 * y.2, x.1 * y.2 + x.2 * y.1)

/-- The Frobenius automorphism `σ(a + bα) = a - bα = a + 2bα` of `GF(9)`. -/
def frob (x : G) : G := (x.1, 2 * x.2)

/-- `b` is a non-zero square in `GF(9)`. -/
def isSq (b : G) : Bool := decide (∃ c : G, c ≠ 0 ∧ gf9Mul c c = b)

/-- **Dickson nearfield multiplication.**  Multiply as in the field when the
right factor is a square (or zero); otherwise pre-apply Frobenius to the left
factor.  This is the standard Dickson twist producing the nearfield of order 9. -/
def dMul (a b : G) : G :=
  if isSq b then gf9Mul a b else gf9Mul (frob a) b

/-! ## Finite verification of the quasifield axioms

All of the following are closed statements over the 9-element type `G`, decided
by exhaustive computation. -/

theorem dMul_one_right : ∀ x : G, dMul x (1, 0) = x := by decide

theorem dMul_one_left : ∀ x : G, dMul (1, 0) x = x := by decide

theorem dMul_zero_right : ∀ x : G, dMul x 0 = 0 := by decide

theorem dMul_zero_left : ∀ x : G, dMul 0 x = 0 := by decide

theorem dMul_right_distrib : ∀ a b c : G, dMul (a + b) c = dMul a c + dMul b c := by
  decide

theorem dMul_left_div :
    ∀ a : G, a ≠ 0 → ∀ c : G, ∃ x, dMul a x = c ∧ ∀ y, dMul a y = c → y = x := by
  decide

theorem dMul_right_div :
    ∀ a : G, a ≠ 0 → ∀ c : G, ∃ x, dMul x a = c ∧ ∀ y, dMul y a = c → y = x := by
  decide

theorem dMul_planar :
    ∀ a b : G, a ≠ b → ∀ d : G,
      ∃ x, dMul x a = dMul x b + d ∧ ∀ y, dMul y a = dMul y b + d → y = x := by
  decide

/-- **The Dickson nearfield of order 9 as a quasifield.**  Its additive group is
the standard `GF(3)²`; the multiplication is `dMul`.  Every axiom is verified by
the finite computations above. -/
def dicksonQF : Quasifield G where
  one := (1, 0)
  mul := dMul
  one_ne_zero := by decide
  mul_one := dMul_one_right
  one_mul := dMul_one_left
  mul_zero := dMul_zero_right
  zero_mul := dMul_zero_left
  right_distrib := dMul_right_distrib
  left_div := dMul_left_div
  right_div := dMul_right_div
  planar := dMul_planar

/-! ## The plane is non-Desarguesian: the coordinate ring is not a division ring -/

/-- Multiplication in the Dickson nearfield **is associative** (this is what makes
it a *nearfield* rather than a mere quasifield). -/
theorem dicksonQF_assoc : dicksonQF.IsAssociative := by
  intro a b c; exact (by decide : ∀ a b c : G, dMul (dMul a b) c = dMul a (dMul b c)) a b c

/-- Multiplication in the Dickson nearfield **fails left distributivity**.  This
is the algebraic signature of a non-Desarguesian plane: only one of the two
distributive laws holds. -/
theorem dicksonQF_not_leftDistrib : ¬ dicksonQF.IsLeftDistrib := by
  intro h
  have : ∀ a b c : G, dMul a (b + c) = dMul a b + dMul a c := h
  revert this
  decide

/-- Multiplication in the Dickson nearfield **is non-commutative**. -/
theorem dicksonQF_not_commutative : ¬ dicksonQF.IsCommutative := by
  intro h
  have : ∀ a b : G, dMul a b = dMul b a := h
  revert this
  decide

/-- An **explicit associativity–distributivity gap**: there are elements whose
left-distributor is non-zero, exhibiting concretely why no field/division-ring
structure on `GF(9)` induces this multiplication. -/
theorem dicksonQF_leftDistrib_witness :
    ∃ a b c : G, dMul a (b + c) ≠ dMul a b + dMul a c := by decide

/-! ## The coordinatized affine plane of order 9 -/

/-- Any two distinct points of the Dickson plane lie on a unique line
(specialisation of the general quasifield theorem). -/
theorem dickson_two_points_unique_line {p q : G × G} (hpq : p ≠ q) :
    ∃! L : Line G, dicksonQF.onLine p L ∧ dicksonQF.onLine q L :=
  dicksonQF.two_points_unique_line hpq

/-- Playfair's axiom holds in the Dickson plane. -/
theorem dickson_playfair (L : Line G) (p : G × G) :
    ∃! M : Line G, dicksonQF.onLine p M ∧ dicksonQF.Parallel L M :=
  dicksonQF.parallel_playfair L p

/-- The Dickson plane is non-degenerate (contains a quadrangle). -/
theorem dickson_nondegenerate :
    ∃ a b c d : G × G,
      ¬ dicksonQF.Collinear a b c ∧ ¬ dicksonQF.Collinear a b d ∧
      ¬ dicksonQF.Collinear a c d ∧ ¬ dicksonQF.Collinear b c d :=
  dicksonQF.exists_four_general_position

/-! ## Combinatorics: order, points and lines -/

/-- The point set is `G × G` with exactly `81 = 9²` points. -/
theorem dickson_point_count : Fintype.card (G × G) = 81 := by decide

/-- Explicit `Fintype` structure on lines via the bijection
`Line G ≃ (G × G) ⊕ G` (ordinary lines ↔ slope/intercept pairs, vertical lines
↔ their `x`-coordinate). -/
def lineEquiv : Line G ≃ (G × G) ⊕ G where
  toFun := fun L => match L with
    | Line.ordinary m b => Sum.inl (m, b)
    | Line.vertical c => Sum.inr c
  invFun := fun s => match s with
    | Sum.inl (m, b) => Line.ordinary m b
    | Sum.inr c => Line.vertical c
  left_inv := by rintro (_ | _) <;> rfl
  right_inv := by rintro (_ | _) <;> rfl

instance : Fintype (Line G) := Fintype.ofEquiv _ lineEquiv.symm

/-- The line set has exactly `90 = 9² + 9` lines, as required for an affine
plane of order `9`. -/
theorem dickson_line_count : Fintype.card (Line G) = 90 := by
  rw [Fintype.card_congr lineEquiv]
  decide

end NearfieldPlaneOrder9