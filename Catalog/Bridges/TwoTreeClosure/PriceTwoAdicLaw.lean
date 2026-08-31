import Mathlib

/-!
# The Price two-adic law and its provable death at position 2

Part of the *Two-Tree Closure* (Berggren / Price trees of primitive Pythagorean triples).

Setting: an odd number `N` presented as a product of two odd factors `N = p * q`
(the semiprime case is the one of interest).  The *Price two-adic mechanism* reads
the ascent letters of `N` off the two-adic valuation of the factor sum `p + q`:

* `priceLetter p q i = true`  ("letter A")  iff  `¬ (2 ^ (i + 2) ∣ p + q)`.

The results below are exact, not statistical:

* `priceLetter_zero_iff` : letter 0 is `A` iff `N ≡ 1 [MOD 4]`;
* `priceLetter_one_iff`  : letter 1 is `A` iff `N % 8 ≠ 7`;
* `mod_eight_three_iff_v2_two`, `mod_eight_seven_iff_eight_dvd` : the full
  `N mod 8` dictionary for the mechanism;
* `priceWord_determined_by_mod_eight` and `priceWord_injOn_odd` : the first two
  letters are a *residue dial* on `N mod 8`, and they see all of `N mod 8`
  (bijection with the four odd classes, three of which are letter-distinguishable);
* `priceLetter_two_not_function_of_N` : **death at position 2** — there is an
  infinite family of odd `N` admitting two odd factorisations whose letters at
  position `2` disagree, so no letter past position `1` is a function of `N` at all.

Two-adic valuation is handled by the elementary predicate `V2 n k` ("`n` has
two-adic valuation exactly `k`") so that every statement is a divisibility fact.
-/

namespace TwoTreeClosure

/-- `V2 n k` says the two-adic valuation of `n` equals `k`. -/
def V2 (n k : ℕ) : Prop := 2 ^ k ∣ n ∧ ¬ (2 ^ (k + 1) ∣ n)

/-- Product of two odd numbers, written out with an explicit remainder. -/
private lemma odd_mul_expand {p q a b : ℕ} (hp : p = 2 * a + 1) (hq : q = 2 * b + 1) :
    p * q = 4 * (a * b) + 2 * a + 2 * b + 1 := by
  subst hp; subst hq; ring

/-- If `a + b` is odd then `a * b` is even. -/
private lemma mul_even_of_add_odd {a b : ℕ} (h : (a + b) % 2 = 1) : a * b % 2 = 0 := by
  rcases Nat.even_or_odd a with ha | ha
  · obtain ⟨k, hk⟩ := ha; subst hk
    have : (k + k) * b = 2 * (k * b) := by ring
    omega
  · obtain ⟨k, hk⟩ := ha; subst hk
    have hb : b % 2 = 0 := by omega
    obtain ⟨j, hj⟩ : ∃ j, b = 2 * j := ⟨b / 2, by omega⟩
    subst hj
    have : (2 * k + 1) * (2 * j) = 2 * ((2 * k + 1) * j) := by ring
    omega

/-! ### The exact `N mod 8` dictionary of the two-adic mechanism -/

/-- **Two-adic law, position 0.** For odd `p, q`, the sum `p + q` has two-adic
valuation exactly one iff the product is `1` mod `4`. -/
theorem v2_one_iff_mod_four (p q : ℕ) (hp : p % 2 = 1) (hq : q % 2 = 1) :
    V2 (p + q) 1 ↔ p * q % 4 = 1 := by
  obtain ⟨a, ha⟩ : ∃ a, p = 2 * a + 1 := ⟨p / 2, by omega⟩
  obtain ⟨b, hb⟩ : ∃ b, q = 2 * b + 1 := ⟨q / 2, by omega⟩
  have hprod := odd_mul_expand ha hb
  constructor
  · rintro ⟨-, h2⟩
    have h4 : ¬ (4 ∣ p + q) := by simpa using h2
    omega
  · intro h
    refine ⟨by omega, ?_⟩
    have : ¬ (4 ∣ p + q) := by omega
    simpa using this

/-- **Two-adic law, position 1.** For odd `p, q`, the sum `p + q` has two-adic
valuation exactly two iff the product is `3` mod `8`. -/
theorem v2_two_iff_mod_eight_three (p q : ℕ) (hp : p % 2 = 1) (hq : q % 2 = 1) :
    V2 (p + q) 2 ↔ p * q % 8 = 3 := by
  obtain ⟨a, ha⟩ : ∃ a, p = 2 * a + 1 := ⟨p / 2, by omega⟩
  obtain ⟨b, hb⟩ : ∃ b, q = 2 * b + 1 := ⟨q / 2, by omega⟩
  have hprod := odd_mul_expand ha hb
  constructor
  · rintro ⟨h1, h2⟩
    have h4 : (4 : ℕ) ∣ p + q := by simpa using h1
    have h8 : ¬ ((8 : ℕ) ∣ p + q) := by simpa using h2
    -- `a + b` is odd, hence `a * b` is even
    have hodd : (a + b) % 2 = 1 := by omega
    have hab := mul_even_of_add_odd hodd
    omega
  · intro h
    have hodd : (a + b) % 2 = 1 := by
      by_contra hc
      have : (a + b) % 2 = 0 := by omega
      omega
    have hab := mul_even_of_add_odd hodd
    refine ⟨?_, ?_⟩
    · have : (4 : ℕ) ∣ p + q := by omega
      simpa using this
    · have : ¬ ((8 : ℕ) ∣ p + q) := by omega
      simpa using this

/-- **Two-adic law, the cap.** For odd `p, q`, the sum `p + q` is divisible by `8`
iff the product is `7` mod `8`.  Beyond this the residue of `N` says nothing:
see `priceLetter_two_not_function_of_N`. -/
theorem mod_eight_seven_iff_eight_dvd (p q : ℕ) (hp : p % 2 = 1) (hq : q % 2 = 1) :
    (8 : ℕ) ∣ p + q ↔ p * q % 8 = 7 := by
  obtain ⟨a, ha⟩ : ∃ a, p = 2 * a + 1 := ⟨p / 2, by omega⟩
  obtain ⟨b, hb⟩ : ∃ b, q = 2 * b + 1 := ⟨q / 2, by omega⟩
  have hprod := odd_mul_expand ha hb
  constructor
  · intro h8
    have hodd : (a + b) % 2 = 1 := by omega
    have hab := mul_even_of_add_odd hodd
    omega
  · intro h
    have hodd : (a + b) % 2 = 1 := by
      by_contra hc
      have : (a + b) % 2 = 0 := by omega
      omega
    have hab := mul_even_of_add_odd hodd
    omega

/-! ### The Price letters -/

/-- The `i`-th Price letter of the factorisation `N = p * q`: it is `A` (`true`)
exactly when the two-adic valuation of `p + q` does not reach `i + 2`. -/
def priceLetter (p q : ℕ) (i : ℕ) : Bool := ¬ (2 ^ (i + 2) ∣ p + q)

/-- Letter `0` is `A` exactly when `N ≡ 1 [MOD 4]`. -/
theorem priceLetter_zero_iff (p q : ℕ) (hp : p % 2 = 1) (hq : q % 2 = 1) :
    priceLetter p q 0 = true ↔ p * q % 4 = 1 := by
  obtain ⟨a, ha⟩ : ∃ a, p = 2 * a + 1 := ⟨p / 2, by omega⟩
  obtain ⟨b, hb⟩ : ∃ b, q = 2 * b + 1 := ⟨q / 2, by omega⟩
  have hprod := odd_mul_expand ha hb
  simp only [priceLetter, pow_succ, pow_zero, one_mul, decide_not,
    Bool.not_eq_true', decide_eq_false_iff_not]
  norm_num
  omega

/-- Letter `1` is `A` exactly when `N % 8 ≠ 7`. -/
theorem priceLetter_one_iff (p q : ℕ) (hp : p % 2 = 1) (hq : q % 2 = 1) :
    priceLetter p q 1 = true ↔ p * q % 8 ≠ 7 := by
  have h := mod_eight_seven_iff_eight_dvd p q hp hq
  simp only [priceLetter, decide_not, Bool.not_eq_true', decide_eq_false_iff_not]
  norm_num
  rw [show (8 : ℕ) = 2 ^ 3 by norm_num] at h
  norm_num at h
  tauto

/-- The two-letter Price word of an odd number, as a pure residue dial on `N mod 8`. -/
def priceWord (N : ℕ) : Bool × Bool := (N % 4 == 1, ¬ (N % 8 == 7))

/-- The mechanism-defined letters agree with the residue dial `priceWord (p * q)`:
the first two Price letters are a function of `N mod 8` only. -/
theorem priceWord_eq_mech (p q : ℕ) (hp : p % 2 = 1) (hq : q % 2 = 1) :
    priceWord (p * q) = (priceLetter p q 0, priceLetter p q 1) := by
  have h0 := priceLetter_zero_iff p q hp hq
  have h1 := priceLetter_one_iff p q hp hq
  ext <;> simp only [priceWord, beq_iff_eq] <;>
    [ (by_cases h : p * q % 4 = 1 <;> simp_all);
      (by_cases h : p * q % 8 = 7 <;> simp_all) ]

/-- **Residue-dial property.**  Equal residues mod `8` force equal Price words. -/
theorem priceWord_determined_by_mod_eight {N M : ℕ} (h : N % 8 = M % 8) :
    priceWord N = priceWord M := by
  have h4 : N % 4 = M % 4 := by omega
  simp [priceWord, h, h4]

/-- **The word sees all of `N mod 8` up to the cap.**  Two odd numbers have the
same Price word iff their residues mod `8` are equal *or* both lie in `{1,5}`
(the two classes that the capped mechanism cannot separate). -/
theorem priceWord_injOn_odd {N M : ℕ} (hN : N % 2 = 1) (hM : M % 2 = 1) :
    priceWord N = priceWord M ↔
      (N % 8 = M % 8 ∨ (N % 8 = 1 ∧ M % 8 = 5) ∨ (N % 8 = 5 ∧ M % 8 = 1)) := by
  have hN8 : N % 8 = 1 ∨ N % 8 = 3 ∨ N % 8 = 5 ∨ N % 8 = 7 := by omega
  have hM8 : M % 8 = 1 ∨ M % 8 = 3 ∨ M % 8 = 5 ∨ M % 8 = 7 := by omega
  have hN4 : N % 4 = N % 8 % 4 := by omega
  have hM4 : M % 4 = M % 8 % 4 := by omega
  simp only [priceWord, Prod.mk.injEq, beq_iff_eq]
  rcases hN8 with h | h | h | h <;> rcases hM8 with g | g | g | g <;>
    simp [h, g, hN4, hM4]

/-! ### Death at position 2

Letters `0` and `1` are functions of `N`.  Letter `2` is not: an odd `N` can have
two odd factorisations whose two-adic letters differ from position `2` on.  The
family below is infinite (`N = 9 * m` for every `m ≡ 7 [MOD 16]`). -/

/-- **Death at position 2 (infinite family).**  For every `m ≡ 7 [MOD 16]` the odd
number `N = 9 * m` has the two odd factorisations `9 * m` and `3 * (3 * m)` whose
Price letters at position `2` disagree, although letters `0` and `1` agree
(they must, being functions of `N`). -/
theorem priceLetter_two_not_function_of_N (m : ℕ) (hm : m % 16 = 7) :
    9 * m = 3 * (3 * m) ∧
      priceLetter 9 m 2 = false ∧ priceLetter 3 (3 * m) 2 = true ∧
      priceLetter 9 m 0 = priceLetter 3 (3 * m) 0 ∧
      priceLetter 9 m 1 = priceLetter 3 (3 * m) 1 := by
  have h16 : (16 : ℕ) ∣ 9 + m := by omega
  have h16' : ¬ ((16 : ℕ) ∣ 3 + 3 * m) := by omega
  have hd8 : (8 : ℕ) ∣ 3 + 3 * m := by omega
  refine ⟨by ring, ?_, ?_, ?_, ?_⟩
  · simp only [priceLetter, decide_not]
    norm_num
    exact h16
  · simp only [priceLetter, decide_not, Bool.not_eq_true', decide_eq_false_iff_not]
    norm_num
    exact h16'
  · simp only [priceLetter, decide_not]
    norm_num
    have e1 : (4 : ℕ) ∣ 9 + m := by omega
    have e2 : (4 : ℕ) ∣ 3 + 3 * m := by omega
    simp [e1, e2]
  · simp only [priceLetter, decide_not]
    norm_num
    have e1 : (8 : ℕ) ∣ 9 + m := by omega
    simp [e1, hd8]

/-- A concrete instance of the death family: `N = 63 = 9 * 7 = 3 * 21`, with
`v₂(9 + 7) = 4` but `v₂(3 + 21) = 3`. -/
example : (63 : ℕ) = 9 * 7 ∧ (16 : ℕ) ∣ 9 + 7 ∧ ¬ ((16 : ℕ) ∣ 3 + 21) := by norm_num

end TwoTreeClosure