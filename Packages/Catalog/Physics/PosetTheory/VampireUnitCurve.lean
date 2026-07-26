import Mathlib

/-!
# Vampire factorizations lie on a finite unit curve

A base-`b` fang pair is defined only by the exact digit-multiset condition.  The
main theorem turns that combinatorial condition into the equation
`(x - 1)(y - 1) = 1` in `ZMod (b - 1)`.  Thus each decremented fang is a unit.
For decimal prime fangs the six points of this curve reduce to three, and their
product is always `4` modulo `9`.
-/

namespace VampireBestiary

/-- The digits of `x` and `y`, with multiplicity, are precisely the digits of
`x*y`.  Lists of digits are little-endian, but permutation forgets order. -/
def FangPair (b x y : ℕ) : Prop :=
  (Nat.digits b (x * y)).Perm (Nat.digits b x ++ Nat.digits b y)

/-
Every number is congruent to its base-`b` digit sum modulo `b-1`.
-/
theorem digits_sum_modEq (b n : ℕ) (hb : 2 ≤ b) :
    n ≡ (Nat.digits b n).sum [MOD (b - 1)] := by
  rcases b with ( _ | _ | b ) <;> simp_all +decide [ Nat.ModEq ];
  conv_lhs => rw [ ← Nat.ofDigits_digits ( b + 1 + 1 ) n ] ; norm_num [ Nat.ofDigits_mod, Nat.ofDigits_one ] ;
  cases b <;> simp_all +decide [ Nat.ofDigits_one ];
  grind

/-
The digit permutation defining fangs forces `xy ≡ x+y (mod b-1)`.
-/
theorem fangPair_modEq (b x y : ℕ) (hb : 2 ≤ b) (h : FangPair b x y) :
    x * y ≡ x + y [MOD (b - 1)] := by
  refine Nat.ModEq.trans ( digits_sum_modEq _ _ hb ) ?_;
  rw [ h.sum_eq, List.sum_append ];
  exact Nat.ModEq.add ( digits_sum_modEq _ _ hb |> Nat.ModEq.symm ) ( digits_sum_modEq _ _ hb |> Nat.ModEq.symm )

/-
**Unit-curve theorem.**  A fang pair lies on the modular hyperbola
`(X-1)(Y-1)=1`; in particular both decremented fangs are units.
-/
theorem fangPair_unit_curve (b x y : ℕ) (hb : 2 ≤ b) (h : FangPair b x y) :
    (((x : ZMod (b - 1)) - 1) * ((y : ZMod (b - 1)) - 1) = 1) ∧
    IsUnit ((x : ZMod (b - 1)) - 1) ∧
    IsUnit ((y : ZMod (b - 1)) - 1) := by
  convert VampireBestiary.fangPair_modEq b x y hb h using 1;
  rcases b with ( _ | _ | b ) <;> simp_all +decide [ ← ZMod.natCast_eq_natCast_iff ];
  constructor <;> intro h <;> simp_all +decide [ sub_mul, mul_sub, isUnit_iff_exists_inv ];
  · linear_combination' h.1;
  · exact ⟨ ⟨ y - 1, by linear_combination' h ⟩, ⟨ x - 1, by linear_combination' h ⟩ ⟩

/-
For positive fangs, each decremented fang is coprime to the casting-out
modulus `b-1`.  This is the ordinary-natural-number content of being a unit on
the modular curve.
-/
theorem decremented_fangs_coprime (b x y : ℕ) (hb : 2 ≤ b)
    (hx : 1 ≤ x) (hy : 1 ≤ y) (h : FangPair b x y) :
    Nat.Coprime (x - 1) (b - 1) ∧ Nat.Coprime (y - 1) (b - 1) := by
  rw [ ← ZMod.isUnit_iff_coprime, ← ZMod.isUnit_iff_coprime ];
  have := VampireBestiary.fangPair_unit_curve b x y hb h; aesop;

/-
Every prime divisor of `b-1` forbids residue `1` for either positive fang.
Thus a single digit-permutation identity yields simultaneous congruence
obstructions at every prime dividing the casting-out modulus.
-/
theorem fang_not_one_mod_prime_divisor (b x y p : ℕ) (hb : 2 ≤ b)
    (hx : 1 ≤ x) (hy : 1 ≤ y) (h : FangPair b x y)
    (hp : p.Prime) (hpb : p ∣ b - 1) :
    x % p ≠ 1 ∧ y % p ≠ 1 := by
  constructor <;> intro H <;> have := Nat.mod_lt x hp.pos <;> have := Nat.mod_lt y hp.pos <;> simp_all +decide;
  · have := decremented_fangs_coprime b x y hb hx hy h; simp_all +decide [hp.dvd_iff_not_coprime, Nat.Coprime] ;
    exact hpb <| Nat.Coprime.coprime_dvd_left ( show p ∣ x - 1 from Nat.dvd_of_mod_eq_zero <| by rw [ ← Nat.mod_add_div x p, H ] ; norm_num [ Nat.add_mod, Nat.mul_mod, Nat.mod_eq_of_lt ‹1 < p› ] ) this.1;
  · have := decremented_fangs_coprime b x y hb hx hy h;
    exact absurd ( this.2.gcd_eq_one ▸ Nat.dvd_gcd ( show p ∣ y - 1 from Nat.dvd_of_mod_eq_zero ( by rw [ ← Nat.mod_add_div y p, H ] ; norm_num [ Nat.mod_eq_of_lt ‹1 < p› ] ) ) hpb ) ( by aesop )

/-
Decimal fangs can never be `1 mod 3`.
-/
theorem decimal_fangs_not_one_mod_three (x y : ℕ)
    (hx : 1 ≤ x) (hy : 1 ≤ y) (h : FangPair 10 x y) :
    x % 3 ≠ 1 ∧ y % 3 ≠ 1 := by
  exact fang_not_one_mod_prime_divisor 10 x y 3 ( by decide ) hx hy h ( by decide ) ( by decide )

/-
In decimal, the unit curve consists of exactly six ordered residue pairs.
-/
theorem decimal_residue_sieve (x y : ℕ) (h : FangPair 10 x y) :
    (x % 9, y % 9) = (0, 0) ∨
    (x % 9, y % 9) = (2, 2) ∨
    (x % 9, y % 9) = (3, 6) ∨
    (x % 9, y % 9) = (5, 8) ∨
    (x % 9, y % 9) = (6, 3) ∨
    (x % 9, y % 9) = (8, 5) := by
  have h_unit_curve : (x - 1 : ℤ) * (y - 1 : ℤ) ≡ 1 [ZMOD 9] := by
    convert fangPair_unit_curve 10 x y ( by decide ) h |> And.left using 1;
    erw [ ← ZMod.intCast_eq_intCast_iff ] ; norm_num;
  rw [ ← Nat.mod_add_div x 9, ← Nat.mod_add_div y 9 ] at *; norm_num [ Int.ModEq, Int.add_emod, Int.sub_emod, Int.mul_emod ] at *; norm_cast at *; have := Nat.mod_lt x ( by decide : 0 < 9 ) ; have := Nat.mod_lt y ( by decide : 0 < 9 ) ; interval_cases x % 9 <;> interval_cases y % 9 <;> simp +decide at h_unit_curve ⊢;

/-
**Prime-fang collapse.**  If both decimal fangs are prime, only three of the
six curve points survive.
-/
theorem prime_fang_residue_sieve (x y : ℕ) (h : FangPair 10 x y)
    (hx : x.Prime) (hy : y.Prime) :
    (x % 9, y % 9) = (2, 2) ∨
    (x % 9, y % 9) = (5, 8) ∨
    (x % 9, y % 9) = (8, 5) := by
  have := decimal_residue_sieve x y h; rcases this with ( h | h | h | h | h | h ) <;> simp_all +decide ;
  · simp_all +decide [ ← Nat.dvd_iff_mod_eq_zero, hx.dvd_iff_eq, hy.dvd_iff_eq ];
  · have := Nat.dvd_of_mod_eq_zero ( show y % 3 = 0 by omega ) ; rw [ hy.dvd_iff_eq ] at this <;> simp_all +decide ;
  · have := Nat.dvd_of_mod_eq_zero ( show x % 3 = 0 by omega ) ; rw [ hx.dvd_iff_eq ] at this <;> simp_all +decide ;

/-
Consequently every product of two prime decimal fangs is `4 mod 9`.
-/
theorem prime_fang_product_mod_nine (x y : ℕ) (h : FangPair 10 x y)
    (hx : x.Prime) (hy : y.Prime) :
    (x * y) % 9 = 4 := by
  obtain h | h | h := prime_fang_residue_sieve x y h hx hy <;> norm_num [ Nat.mul_mod, h ]; all_goals aesop

/-- Exact certification of the smallest classical vampire factorization. -/
theorem fangPair_1260 : FangPair 10 21 60 := by
  norm_num [FangPair]
  decide

/-- Exact digit-multiset certificates for the first seven standard vampire
numbers, supplying small-case evidence independently of the modular theorem. -/
theorem first_seven_vampire_factorizations :
    FangPair 10 21 60 ∧
    FangPair 10 15 93 ∧
    FangPair 10 35 41 ∧
    FangPair 10 30 51 ∧
    FangPair 10 21 87 ∧
    FangPair 10 27 81 ∧
    FangPair 10 80 86 := by
  norm_num [FangPair]
  all_goals decide

end VampireBestiary