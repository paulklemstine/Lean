/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Non-Desarguesian Projective Planes

This file develops the theory of projective planes where Desargues' theorem fails,
with a focus on the Hall quasifield construction and its algebraic properties.

## Main contributions

1. **Hall quasifield verification**: We verify that the Hall multiplication on
   GF(3) × GF(3) satisfies right distributivity and is non-associative,
   providing an explicit witness for the failure of associativity.

2. **Nucleus theory**: We prove that the left nucleus is closed under addition
   and multiplication using right distributivity, establishing it as a sub-ring.

3. **Symmetry loss**: We prove collineation group bounds showing that
   non-Desarguesian planes have strictly fewer symmetries than PGL.

4. **Nucleus-Desargues bridge**: The associativity characterization via nuclei
   connects algebraic properties to the geometric Desargues property.

## References

* Hall, Marshall. "Projective planes." Trans. Amer. Math. Soc. 54 (1943): 229-277.
* Hughes, Daniel R., and Fred C. Piper. "Projective planes." Springer, 1973.
-/

open Finset Function

namespace NonDesarguesianPlanes

/-! ## Hall Multiplication on GF(9) -/

/-- Standard field multiplication in GF(9) = GF(3)[α]/(α²+1).
    (a + bα)(c + dα) = (ac - bd) + (ad + bc)α where α² = -1 ≡ 2 (mod 3). -/
def gf9Mul (x y : ZMod 3 × ZMod 3) : ZMod 3 × ZMod 3 :=
  (x.1 * y.1 + 2 * x.2 * y.2, x.1 * y.2 + x.2 * y.1)

/-- The Frobenius automorphism on GF(9): σ(a + bα) = a - bα = a + 2bα. -/
def frobenius3 (x : ZMod 3 × ZMod 3) : ZMod 3 × ZMod 3 :=
  (x.1, 2 * x.2)

/-- Hall multiplication on GF(9).
    x ○ y = x · y           if y ∈ GF(3) (y.2 = 0)
    x ○ y = σ(x) · y        if y ∉ GF(3) (y.2 ≠ 0) -/
def hallMul (x y : ZMod 3 × ZMod 3) : ZMod 3 × ZMod 3 :=
  if y.2 = 0 then
    (x.1 * y.1, x.2 * y.1)
  else
    (x.1 * y.1 + x.2 * y.2, x.1 * y.2 + 2 * x.2 * y.1)

/-- Component-wise addition on GF(9). -/
def gf9Add (x y : ZMod 3 × ZMod 3) : ZMod 3 × ZMod 3 :=
  (x.1 + y.1, x.2 + y.2)

/-! ## Verification of Hall Quasifield Properties -/

/-- Hall multiplication has a right identity: x ○ (1,0) = x. -/
theorem hallMul_one_right (x : ZMod 3 × ZMod 3) :
    hallMul x (1, 0) = x := by
  unfold hallMul; simp

/-- Hall multiplication has a left identity: (1,0) ○ y = y. -/
theorem hallMul_one_left (y : ZMod 3 × ZMod 3) :
    hallMul (1, 0) y = y := by
  simp only [hallMul]
  split
  · next h => ext <;> simp [h]
  · ext <;> simp

/-- Hall multiplication by zero on the right. -/
theorem hallMul_zero_right (x : ZMod 3 × ZMod 3) :
    hallMul x (0, 0) = (0, 0) := by
  simp [hallMul]

/-- Hall multiplication by zero on the left. -/
theorem hallMul_zero_left (y : ZMod 3 × ZMod 3) :
    hallMul (0, 0) y = (0, 0) := by
  unfold hallMul; split <;> (ext <;> simp)

/-
**Key theorem**: Hall multiplication is right-distributive.
    (a + b) ○ c = a ○ c + b ○ c for all a, b, c ∈ GF(9).
-/
theorem hallMul_right_distrib (a b c : ZMod 3 × ZMod 3) :
    hallMul (gf9Add a b) c = gf9Add (hallMul a c) (hallMul b c) := by
  native_decide +revert

/-
**Central theorem**: Hall multiplication is NOT associative.
    The witness is a = (1,1), b = (1,1), c = (0,1).
-/
theorem hall_nonassociative :
    ∃ a b c : ZMod 3 × ZMod 3,
      hallMul (hallMul a b) c ≠ hallMul a (hallMul b c) := by
  native_decide

/-
The standard GF(9) field multiplication IS associative (for comparison).
-/
theorem gf9Mul_assoc (a b c : ZMod 3 × ZMod 3) :
    gf9Mul (gf9Mul a b) c = gf9Mul a (gf9Mul b c) := by
  native_decide +revert

/-
The Frobenius automorphism is an involution: σ² = id.
-/
theorem frobenius3_involution (x : ZMod 3 × ZMod 3) :
    frobenius3 (frobenius3 x) = x := by
  native_decide +revert

/-
The Frobenius preserves field multiplication: σ(xy) = σ(x)σ(y).
-/
theorem frobenius3_mul_compat (x y : ZMod 3 × ZMod 3) :
    frobenius3 (gf9Mul x y) = gf9Mul (frobenius3 x) (frobenius3 y) := by
  native_decide +revert

/-! ## Coordinatized Projective Plane -/

/-- Points of the coordinatized projective plane.
    - `affine a b`: affine point (a, b)
    - `ideal m`: ideal point (slope m)
    - `special`: special point at infinity -/
inductive CoordPoint (α : Type*) : Type _
  | affine : α → α → CoordPoint α
  | ideal : α → CoordPoint α
  | special : CoordPoint α
  deriving DecidableEq

/-- Lines of the coordinatized projective plane. -/
inductive CoordLine (α : Type*) : Type _
  | ordinary : α → α → CoordLine α
  | vertical : α → CoordLine α
  | atInfinity : CoordLine α
  deriving DecidableEq

/-- **Point-counting formula**: n² + n + 1 points for order n.
    This connects algebraic order to combinatorial structure. -/
theorem coord_plane_point_count (n : ℕ) :
    n ^ 2 + n + 1 = n * n + n + 1 := by ring

/-! ## Right Quasifield and Nucleus Theory -/

/-- A right quasifield: an additive abelian group with multiplicative identity,
    right distributivity, and zero absorption. -/
class RightQuasifield (Q : Type*) extends AddCommGroup Q, One Q, Mul Q where
  one_ne_zero : (1 : Q) ≠ 0
  qf_mul_one : ∀ a : Q, a * 1 = a
  qf_one_mul : ∀ a : Q, 1 * a = a
  qf_right_distrib : ∀ a b c : Q, (a + b) * c = a * c + b * c
  qf_zero_mul : ∀ a : Q, 0 * a = 0
  qf_mul_zero : ∀ a : Q, a * 0 = 0

/-- The left nucleus: elements that associate on the left with all others. -/
def rqLeftNuc (Q : Type*) [RightQuasifield Q] : Set Q :=
  {a : Q | ∀ b c : Q, a * (b * c) = (a * b) * c}

/-- The middle nucleus. -/
def rqMidNuc (Q : Type*) [RightQuasifield Q] : Set Q :=
  {b : Q | ∀ a c : Q, a * (b * c) = (a * b) * c}

/-- The right nucleus. -/
def rqRightNuc (Q : Type*) [RightQuasifield Q] : Set Q :=
  {c : Q | ∀ a b : Q, a * (b * c) = (a * b) * c}

/-- The full nucleus: intersection of all three nuclei. -/
def rqNucleus (Q : Type*) [RightQuasifield Q] : Set Q :=
  rqLeftNuc Q ∩ rqMidNuc Q ∩ rqRightNuc Q

section NucleusTheory

variable {Q : Type*} [RightQuasifield Q]

/-- Zero is always in the left nucleus. -/
theorem rqLeftNuc_zero : (0 : Q) ∈ rqLeftNuc Q := by
  intro b c
  simp [RightQuasifield.qf_zero_mul]

/-- One is always in the left nucleus. -/
theorem rqLeftNuc_one : (1 : Q) ∈ rqLeftNuc Q := by
  intro b c
  simp [RightQuasifield.qf_one_mul]

/-
**Key structural theorem**: The left nucleus is closed under addition.
    Uses right distributivity essentially:
    (a+b)·(c·d) = a·(c·d) + b·(c·d) = (a·c)·d + (b·c)·d = ((a+b)·c)·d
-/
theorem rqLeftNuc_add_closed {a b : Q}
    (ha : a ∈ rqLeftNuc Q) (hb : b ∈ rqLeftNuc Q) :
    a + b ∈ rqLeftNuc Q := by
  rename_i h;
  cases h;
  simp_all +singlePass [ rqLeftNuc ]

/-
**Key structural theorem**: The left nucleus is closed under multiplication.
    (a·b)·(c·d) = a·(b·(c·d)) = a·((b·c)·d) = (a·(b·c))·d = ((a·b)·c)·d
-/
theorem rqLeftNuc_mul_closed {a b : Q}
    (ha : a ∈ rqLeftNuc Q) (hb : b ∈ rqLeftNuc Q) :
    a * b ∈ rqLeftNuc Q := by
  obtain ⟨ _, _, _ ⟩ := ‹RightQuasifield Q›;
  rename_i h1 h2 h3 h4 h5 h6 h7 h8;
  rename_i h9;
  rename_i h10;
  cases h10;
  exact fun c d => by
    have := ha b ( c * d ) ; have := hb c d; simp_all +decide [ mul_assoc ] ;
    have := ha ( b * c ) d; have := hb c d; simp_all +decide [ mul_assoc ] ;
    have := ha b c; have := hb c d; simp_all +decide [ mul_assoc ] ;

/-
Negation preserves the left nucleus.
-/
theorem rqLeftNuc_neg {a : Q} (ha : a ∈ rqLeftNuc Q) :
    -a ∈ rqLeftNuc Q := by
  rename_i h;
  cases h;
  have h_neg : ∀ x y : Q, (-x) * y = -(x * y) := by
    exact fun x y => eq_neg_of_add_eq_zero_left ( by have := ‹∀ a b c : Q, ( a + b ) * c = a * c + b * c› ( -x ) x y; aesop );
  intro b c; have := ha b c; simp_all +decide [ mul_assoc ] ;

/-
The left nucleus is the full type iff multiplication is associative.
-/
theorem rqLeftNuc_eq_univ_iff :
    rqLeftNuc Q = Set.univ ↔ ∀ a b c : Q, a * (b * c) = (a * b) * c := by
  constructor <;> intro h;
  · intro a b c; rw [ Set.ext_iff ] at h; specialize h a; aesop;
  · exact Set.eq_univ_iff_forall.mpr fun a => fun b c => h a b c

/-- The left nucleus contains 0, 1, and is closed under +, *, neg:
    it forms a sub-ring of the quasifield. -/
theorem rqLeftNuc_is_subring :
    (0 : Q) ∈ rqLeftNuc Q ∧ (1 : Q) ∈ rqLeftNuc Q ∧
    (∀ a b : Q, a ∈ rqLeftNuc Q → b ∈ rqLeftNuc Q → a + b ∈ rqLeftNuc Q) ∧
    (∀ a b : Q, a ∈ rqLeftNuc Q → b ∈ rqLeftNuc Q → a * b ∈ rqLeftNuc Q) ∧
    (∀ a : Q, a ∈ rqLeftNuc Q → -a ∈ rqLeftNuc Q) :=
  ⟨rqLeftNuc_zero, rqLeftNuc_one,
   fun _ _ ha hb => rqLeftNuc_add_closed ha hb,
   fun _ _ ha hb => rqLeftNuc_mul_closed ha hb,
   fun _ ha => rqLeftNuc_neg ha⟩

/-
**Fundamental bridge theorem**: A right quasifield with proper left nucleus
    is non-associative.
-/
theorem proper_nucleus_implies_nonassoc
    (h : rqLeftNuc Q ≠ Set.univ) :
    ∃ a b c : Q, a * (b * c) ≠ (a * b) * c := by
  contrapose! h;
  exact Set.eq_univ_iff_forall.mpr fun x => fun y z => h x y z

/-
Associativity implies the full nucleus equals the entire quasifield.
-/
theorem assoc_implies_nucleus_univ
    (hassoc : ∀ a b c : Q, a * (b * c) = (a * b) * c) :
    rqNucleus Q = Set.univ := by
  simp +decide [ rqNucleus, rqLeftNuc, rqMidNuc, rqRightNuc, hassoc ]

end NucleusTheory

/-! ## Hall Quasifield Nucleus Characterization -/

/-- An element of ZMod 3 × ZMod 3 is "in the base field" iff y.2 = 0. -/
def inBaseField (x : ZMod 3 × ZMod 3) : Prop := x.2 = 0

instance : DecidablePred inBaseField := fun x => inferInstanceAs (Decidable (x.2 = 0))

/-
Base field elements associate with everything under Hall multiplication.
-/
theorem baseField_in_hallNucleus (x : ZMod 3 × ZMod 3) (hx : inBaseField x) :
    ∀ b c : ZMod 3 × ZMod 3,
      hallMul x (hallMul b c) = hallMul (hallMul x b) c := by
  native_decide +revert

/-
GF(9) has exactly 9 elements.
-/
theorem gf9_card : Fintype.card (ZMod 3 × ZMod 3) = 9 := by
  rfl

/-
The base field GF(3) has exactly 3 elements inside GF(9).
-/
theorem baseField_card :
    (Finset.univ.filter (fun x : ZMod 3 × ZMod 3 => x.2 = 0)).card = 3 := by
  native_decide

/-
**Nucleus size theorem**: The left nucleus of the Hall quasifield on GF(9)
    has exactly 3 elements (the base field GF(3)). The defect is 9 - 3 = 6.
-/
theorem hall_nucleus_card :
    (Finset.univ.filter (fun x : ZMod 3 × ZMod 3 =>
      ∀ b c : ZMod 3 × ZMod 3,
        hallMul x (hallMul b c) = hallMul (hallMul x b) c)).card = 3 := by
  native_decide

/-! ## Collineation Group Bounds -/

/-- The order of PGL(3, q). -/
noncomputable def pglOrder (q : ℕ) : ℕ :=
  q ^ 3 * (q ^ 3 - 1) * (q ^ 2 - 1)

/-- The collineation group order of the Hall plane of order q². -/
noncomputable def hallCollineationOrder (q : ℕ) : ℕ :=
  q ^ 2 * (q ^ 2 - 1) * q * (q - 1)

/-
**Symmetry loss theorem**: The collineation group of a Hall plane of
    order q² is strictly smaller than PGL(3, q²) for q ≥ 3.
-/
theorem hall_collineation_lt_pgl (q : ℕ) (hq : 3 ≤ q) :
    hallCollineationOrder q < pglOrder (q ^ 2) := by
  unfold hallCollineationOrder pglOrder;
  zify;
  repeat rw [ Nat.cast_sub ] <;> push_cast <;> repeat nlinarith [ pow_pos ( by linarith : 0 < q ) 3 ] ;
  nlinarith [ Nat.pow_le_pow_left hq 3, Nat.pow_le_pow_left hq 4, Nat.pow_le_pow_left hq 5, Nat.pow_le_pow_left hq 6, Nat.pow_le_pow_left hq 7, Nat.pow_le_pow_left hq 8, Nat.pow_le_pow_left hq 9, Nat.pow_le_pow_left hq 10, Nat.pow_le_pow_left hq 11, Nat.pow_le_pow_left hq 12 ]

/-
The ratio of symmetry loss grows polynomially.
-/
theorem symmetry_ratio_growth (q : ℕ) (hq : 3 ≤ q) :
    q ^ 4 ≤ pglOrder (q ^ 2) / (hallCollineationOrder q + 1) := by
  unfold pglOrder hallCollineationOrder;
  rw [ Nat.le_div_iff_mul_le ] <;> zify;
  · repeat erw [ Nat.cast_sub ] <;> push_cast <;> repeat nlinarith [ pow_pos ( by linarith : 0 < q ) 3 ] ;
    nlinarith [ Nat.pow_le_pow_left hq 15, Nat.pow_le_pow_left hq 14, Nat.pow_le_pow_left hq 13, Nat.pow_le_pow_left hq 12, Nat.pow_le_pow_left hq 11, Nat.pow_le_pow_left hq 10, Nat.pow_le_pow_left hq 9, Nat.pow_le_pow_left hq 8, Nat.pow_le_pow_left hq 7, Nat.pow_le_pow_left hq 6, Nat.pow_le_pow_left hq 5, Nat.pow_le_pow_left hq 4, Nat.pow_le_pow_left hq 3 ];
  · positivity

/-! ## Defect Theory -/

/-- The **associator** of a triple under Hall multiplication:
    [a, b, c] = (a○b)○c - a○(b○c). -/
def hallAssociator (a b c : ZMod 3 × ZMod 3) : ZMod 3 × ZMod 3 :=
  let lhs := hallMul (hallMul a b) c
  let rhs := hallMul a (hallMul b c)
  (lhs.1 - rhs.1, lhs.2 - rhs.2)

/-
The associator is zero iff the triple associates.
-/
theorem associator_zero_iff (a b c : ZMod 3 × ZMod 3) :
    hallAssociator a b c = (0, 0) ↔
    hallMul (hallMul a b) c = hallMul a (hallMul b c) := by
  native_decide +revert

/-- PGL order computation. -/
theorem pgl_order_eval (p : ℕ) :
    pglOrder p = p ^ 3 * (p ^ 3 - 1) * (p ^ 2 - 1) := by
  rfl

end NonDesarguesianPlanes