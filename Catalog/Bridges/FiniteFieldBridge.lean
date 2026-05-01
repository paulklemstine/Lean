import Mathlib

/-! # Finite Field Bridge

Proves fundamental results about finite fields and ZMod p:
1. Freshman's Dream: (x + y)^p = x^p + y^p in characteristic p
2. Frobenius endomorphism properties
3. Fermat's Little Theorem via field theory: x^p = x in ZMod p
4. Wilson's Theorem via field theory

Finite fields are central to modern cryptography (AES, Diffie-Hellman)
and coding theory (Reed-Solomon, BCH codes).
-/

namespace FiniteFieldBridge

/-! ## Section 1: Freshman's Dream -/

/-- **Freshman's Dream**: (x + y)^p = x^p + y^p in characteristic p.
    In characteristic p, the binomial coefficients C(p,k) are divisible
    by p for 0 < k < p, so all middle terms vanish. This makes the
    Frobenius map x ↦ x^p a ring homomorphism. -/
theorem freshman_dream (p : ℕ) [hp : Fact (Nat.Prime p)]
    {R : Type*} [CommSemiring R] [CharP R p] (x y : R) :
    (x + y) ^ p = x ^ p + y ^ p :=
  add_pow_char x y p

/-! ## Section 2: Frobenius Properties -/

/-- Frobenius preserves multiplication: (x * y)^p = x^p * y^p. -/
theorem frob_mul {R : Type*} [CommMonoid R] (p : ℕ) (x y : R) :
    (x * y) ^ p = x ^ p * y ^ p :=
  mul_pow x y p

/-- Frobenius preserves 1: 1^p = 1. -/
theorem frob_one {R : Type*} [MonoidWithZero R] (p : ℕ) :
    (1 : R) ^ p = 1 :=
  one_pow p

/-- Frobenius sends 0 to 0: 0^p = 0 for p ≠ 0. -/
theorem frob_zero {R : Type*} [Semiring R] {p : ℕ} (hp : p ≠ 0) :
    (0 : R) ^ p = 0 :=
  zero_pow hp

/-! ## Section 3: Fermat via Field Theory -/

/-- **Fermat's Little Theorem** (field form): x^p = x in ZMod p.
    Every element of ZMod p is a root of x^p - x. -/
theorem fermat_field (p : ℕ) [Fact (Nat.Prime p)] [Fintype (ZMod p)] (x : ZMod p) :
    x ^ p = x :=
  ZMod.pow_card x

/-- **Fermat's Little Theorem** (unit form): a^(p-1) = 1 for units in ZMod p. -/
theorem fermat_unit (p : ℕ) [Fact (Nat.Prime p)] (a : (ZMod p)ˣ) :
    a ^ (p - 1) = 1 :=
  ZMod.units_pow_card_sub_one_eq_one p a

/-- The cardinality of ZMod p is p. -/
theorem zmod_card (p : ℕ) [Fintype (ZMod p)] :
    Fintype.card (ZMod p) = p :=
  ZMod.card p

/-! ## Section 4: Wilson's Theorem -/

/-- **Wilson's Theorem**: (p-1)! ≡ -1 (mod p).
    Elements of (ZMod p)ˣ pair up with their inverses;
    only ±1 are their own inverses. -/
theorem wilson_field (p : ℕ) [Fact (Nat.Prime p)] :
    ((p - 1).factorial : ZMod p) = -1 :=
  ZMod.wilsons_lemma p

/-! ## Section 5: Frobenius is a Homomorphism -/

/-- The Frobenius map is a ring homomorphism in characteristic p:
    it preserves addition (Freshman's Dream), multiplication, 0, and 1.
    This is the key structural property of finite fields. -/
theorem frobenius_is_hom (p : ℕ) [hp : Fact (Nat.Prime p)]
    {R : Type*} [CommRing R] [CharP R p] :
    ∀ x y : R,
    (x + y) ^ p = x ^ p + y ^ p ∧
    (x * y) ^ p = x ^ p * y ^ p ∧
    (1 : R) ^ p = 1 ∧
    (0 : R) ^ p = 0 :=
  fun _ _ => ⟨add_pow_char _ _ p, mul_pow _ _ p, one_pow p, zero_pow (Nat.Prime.ne_zero hp.out)⟩

end FiniteFieldBridge