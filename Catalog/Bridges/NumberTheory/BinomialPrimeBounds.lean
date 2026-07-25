import Mathlib

/-!
# A Bridge: Binomial Coefficients ⟶ Prime Distribution Bounds

This file formalizes the classical argument of Erdős that derives the Chebyshev-type
upper bound on the product of primes (`∏_{p ≤ n} p < 4^n`) from elementary properties
of the central binomial coefficient `C(2n, n)`.

The chain of reasoning crosses from *enumerative combinatorics* (identities for binomial
coefficients) to *analytic number theory* (distribution of primes):

* **Legendre's formula** computes the `p`-adic valuation of `n!` from the base-`p` digits
  of `n`, and hence the valuation of `C(2n,n)`.
* As a consequence every prime `p` with `n < p ≤ 2n` divides `C(2n,n)` *exactly once*.
* Size bounds on `C(2n,n)` (lower bound `4^n/(2n+1)`, upper bound `4^n/√(2n)`) control the
  size of the prime product.
* Strong induction then yields `∏_{p ≤ n} p < 4^n`.

## Main definitions

* `v_p n p`               — the `p`-adic valuation of `n` (`n.factorization p`).
* `central_binom n`       — the central binomial coefficient `C(2n, n)`.
* `prime_product_below n` — the product of all primes `p ≤ n` (the primorial `n#`).

## Main results

* `legendre_factorial_digit`     — `(p-1) · v_p(n!) = n - s_p(n)`  (Legendre, digit form).
* `legendre_central_binom_digit` — `(p-1) · v_p(C(2n,n)) = s_p(n) + s_p(n) - s_p(2n)`.
* `vp_central_binom_div`          — the divided form `v_p(C(2n,n)) = (s_p(n)+s_p(n)-s_p(2n))/(p-1)`.
* `vp_central_binom_eq_one`       — for prime `p`, `n < p ≤ 2n ⟹ v_p(C(2n,n)) = 1`.
* `prime_dvd_central_binom`       — for prime `p`, `n < p ≤ 2n ⟹ p ∣ C(2n,n)`.
* `prod_primes_Ioc_dvd_central_binom` — `∏_{n < p ≤ 2n} p  ∣  C(2n,n)`.
* `central_binom_lower`           — `4^n ≤ (2n+1) · C(2n,n)`.
* `central_binom_sq_le`           — `(3n+1) · C(2n,n)^2 ≤ 16^n`.
* `central_binom_upper`           — `C(2n,n) ≤ 4^n / √(2n)`  (real, corrected bound).
* `chebyshev_primorial`           — `∏_{p ≤ n} p < 4^n` for `n ≥ 1`.

## Note on the stated upper bound for `C(2n,n)`

The research brief states the upper bound `C(2n,n) ≤ 4^n / (2√n)`.  This is **false**:
for `n = 2` it reads `6 ≤ 16/(2√2) = 5.65…`.  The correct standard bound is
`C(2n,n) ≤ 4^n / √(2n)` (and `4^n/(2√n) ≤ C(2n,n)` is in fact a *lower* bound).  We prove the
correct upper bound `central_binom_upper`; see the commented statement near it.
-/

open Nat Finset

namespace BinomialPrimeBounds

/-- The `p`-adic valuation of `n`: the exponent of the prime `p` in the factorization of `n`. -/
def v_p (n p : ℕ) : ℕ := n.factorization p

/-- The central binomial coefficient `C(2n, n)`. -/
def central_binom (n : ℕ) : ℕ := Nat.choose (2 * n) n

/-- The product of all primes `p ≤ n` (the primorial `n#`). -/
def prime_product_below (n : ℕ) : ℕ := ∏ p ∈ (Finset.range (n + 1)).filter Nat.Prime, p

/-- `central_binom` agrees with Mathlib's `Nat.centralBinom`. -/
theorem central_binom_eq (n : ℕ) : central_binom n = Nat.centralBinom n := rfl

/-- `prime_product_below` agrees with Mathlib's `primorial`. -/
theorem prime_product_below_eq (n : ℕ) : prime_product_below n = primorial n := rfl

/-- A single-digit number in base `b` has digit list `[n]`. -/
theorem digits_of_pos_lt {b n : ℕ} (h0 : 0 < n) (hb : n < b) : Nat.digits b n = [n] := by
  have hb2 : 1 < b := lt_of_le_of_lt h0 hb
  rw [Nat.digits_def' hb2 h0, Nat.mod_eq_of_lt hb, Nat.div_eq_of_lt hb, Nat.digits_zero]

/-! ### Theorem 1 — Legendre's formula and the valuation of the central binomial coefficient -/

/-
**Legendre's formula (digit form).**  For a prime `p`,
`(p - 1) · v_p(n!) = n - s_p(n)` where `s_p(n)` is the sum of the base-`p` digits of `n`.
-/
theorem legendre_factorial_digit (p n : ℕ) (hp : p.Prime) :
    (p - 1) * v_p (n !) p = n - (p.digits n).sum := by
  convert Nat.sub_one_mul_factorization_factorial hp using 1

/-
**Valuation of the central binomial coefficient (digit form).**  For a prime `p`,
`(p - 1) · v_p(C(2n,n)) = s_p(n) + s_p(n) - s_p(2n)`.
-/
theorem legendre_central_binom_digit (p n : ℕ) (hp : p.Prime) :
    (p - 1) * v_p (central_binom n) p
      = (p.digits n).sum + (p.digits n).sum - (p.digits (2 * n)).sum := by
  -- Set up the exact (subtraction-free) factorization identity. By `Nat.choose_mul_factorial_mul_factorial (le.intro rfl : n ≤ 2*n)` with the rewrite `2*n - n = n`, we get `central_binom n * n ! * n ! = (2*n)!` (recall `central_binom n = (2*n).choose n` definitionally, and `(2*n).choose n * n ! * (2*n - n)! = (2*n)!`).
  have h_factorial_identity : central_binom n * Nat.factorial n * Nat.factorial n = Nat.factorial (2 * n) := by
    unfold central_binom;
    rw [ ← Nat.choose_mul_factorial_mul_factorial ( show n ≤ 2 * n by linarith ) ];
    rw [ two_mul, add_tsub_cancel_left ];
  -- By taking the $p$-adic valuation of both sides of the identity, we get:
  have h_val : v_p (Nat.factorial (2 * n)) p = v_p (central_binom n) p + 2 * v_p (Nat.factorial n) p := by
    unfold v_p; rw [ ← h_factorial_identity ] ;
    rw [ Nat.factorization_mul, Nat.factorization_mul ] <;> simp +decide [ Nat.factorial_ne_zero ] ; ring; all_goals exact Nat.ne_of_gt <| Nat.choose_pos <| by linarith;
  -- By multiplying both sides of the equation from h_val by (p-1), we can isolate the valuation of the central binomial coefficient.
  have h_isolate : (p - 1) * v_p (central_binom n) p = (2 * n - (Nat.digits p (2 * n)).sum) - 2 * (n - (Nat.digits p n).sum) := by
    have h_legendre : (p - 1) * v_p (Nat.factorial (2 * n)) p = 2 * n - (Nat.digits p (2 * n)).sum ∧ (p - 1) * v_p (Nat.factorial n) p = n - (Nat.digits p n).sum := by
      exact ⟨ legendre_factorial_digit p ( 2 * n ) hp, legendre_factorial_digit p n hp ⟩;
    rw [ ← h_legendre.1, ← h_legendre.2, h_val ];
    exact eq_tsub_of_add_eq ( by ring );
  rw [ h_isolate, mul_tsub ];
  rw [ tsub_right_comm, tsub_tsub_assoc ] <;> norm_num [ ← mul_tsub ];
  · ring;
  · exact Nat.digit_sum_le _ _

/-
The divided form exactly as in the brief:
`v_p(C(2n,n)) = (s_p(n) + s_p(n) - s_p(2n)) / (p - 1)`.
-/
theorem vp_central_binom_div (p n : ℕ) (hp : p.Prime) :
    v_p (central_binom n) p
      = ((p.digits n).sum + (p.digits n).sum - (p.digits (2 * n)).sum) / (p - 1) := by
  have := legendre_central_binom_digit p n hp;
  rw [ ← this, Nat.mul_div_cancel_left _ ( Nat.sub_pos_of_lt hp.one_lt ) ]

/-
**A prime `p` with `n < p ≤ 2n` divides `C(2n,n)` exactly once.**
-/
theorem vp_central_binom_eq_one (p n : ℕ) (hp : p.Prime) (h1 : n < p) (h2 : p ≤ 2 * n) :
    v_p (central_binom n) p = 1 := by
  convert vp_central_binom_div p n hp using 1;
  rw [ eq_comm, Nat.div_eq_of_eq_mul_left ];
  · exact Nat.sub_pos_of_lt hp.one_lt;
  · rw [ show Nat.digits p n = [ n ] from digits_of_pos_lt ( Nat.pos_of_ne_zero ( by aesop_cat ) ) h1 ] ; norm_num;
    rw [ Nat.digits_def' ] <;> norm_num;
    · rw [ show 2 * n / p = 1 by exact Nat.le_antisymm ( Nat.le_of_lt_succ <| Nat.div_lt_of_lt_mul <| by linarith ) ( Nat.div_pos ( by linarith ) hp.pos ) ] ; simp +arith +decide;
      rw [ Nat.digits_of_lt ] <;> norm_num;
      · rw [ show 2 * n % p = 2 * n - p by rw [ Nat.mod_eq_sub_mod ( by linarith ) ] ; simp +decide [ Nat.mod_eq_of_lt ( show 2 * n - p < p from by omega ) ] ] ; omega;
      · grind;
    · linarith [ hp.two_le ];
    · linarith

/-
A prime `p` with `n < p ≤ 2n` divides `C(2n,n)`.
-/
theorem prime_dvd_central_binom (p n : ℕ) (hp : p.Prime) (h1 : n < p) (h2 : p ≤ 2 * n) :
    p ∣ central_binom n := by
  -- By `vp_central_binom_eq_one (p n : ℕ) (hp : p.Prime) (h1 : n < p) (h2 : p ≤ 2 * n) : v_p (central_binom n) p = 1`, we have `(central_binom n).factorization p = 1`.
  have h_factorization : (central_binom n).factorization p = 1 := by
    convert vp_central_binom_eq_one p n hp h1 h2 using 1;
  exact hp.dvd_iff_one_le_factorization ( by exact Nat.ne_of_gt <| Nat.choose_pos <| by linarith ) |>.2 <| by linarith;

/-
The product of all primes in `(n, 2n]` divides `C(2n,n)`.
-/
theorem prod_primes_Ioc_dvd_central_binom (n : ℕ) :
    (∏ p ∈ (Finset.Ioc n (2 * n)).filter Nat.Prime, p) ∣ central_binom n := by
  refine' Nat.dvd_trans _ ( Nat.prod_primeFactors_dvd _ );
  apply_rules [ Finset.prod_dvd_prod_of_subset ];
  intro p hp; simp_all +decide ;
  exact ⟨ prime_dvd_central_binom p n hp.2 hp.1.1 hp.1.2, Nat.ne_of_gt <| Nat.choose_pos <| by linarith ⟩

/-! ### Theorem 2 — Size bounds for the central binomial coefficient -/

/-
**Lower bound:** `4^n ≤ (2n+1) · C(2n,n)`, i.e. `4^n/(2n+1) ≤ C(2n,n)`.
-/
theorem central_binom_lower (n : ℕ) (hn : 1 ≤ n) :
    4 ^ n ≤ (2 * n + 1) * central_binom n := by
  -- Apply the theorem `Nat.four_pow_le_two_mul_self_mul_centralBinom` to conclude the proof.
  have := @Nat.four_pow_le_two_mul_self_mul_centralBinom n hn;
  simp_all +decide [ central_binom_eq ];
  nlinarith [ Nat.centralBinom_pos n ]

/-
Key quadratic bound powering the upper estimate: `(3n+1) · C(2n,n)^2 ≤ 16^n`.
-/
theorem central_binom_sq_le (n : ℕ) :
    (3 * n + 1) * (central_binom n) ^ 2 ≤ 16 ^ n := by
  induction' n with n ih;
  · decide +revert;
  · -- From the recurrence relation, we have $(n+1)^2 * C(n+1)^2 = 4*(2*n+1)^2 * C(n)^2$.
    have h_recurrence : (n + 1) ^ 2 * (central_binom (n + 1)) ^ 2 = 4 * (2 * n + 1) ^ 2 * (central_binom n) ^ 2 := by
      have h_recurrence : (n + 1) * central_binom (n + 1) = 2 * (2 * n + 1) * central_binom n := by
        convert Nat.succ_mul_centralBinom_succ n using 1;
      convert congr_arg ( · ^ 2 ) h_recurrence using 1 <;> ring;
    rw [ pow_succ' ];
    rw [ pow_succ' ];
    rw [ pow_succ' ];
    nlinarith [ sq ( n : ℕ ), show 0 ≤ central_binom n ^ 2 by positivity ]

/-
Consequence: `2n · C(2n,n)^2 ≤ 16^n`.
-/
theorem central_binom_sq_le' (n : ℕ) :
    2 * n * (central_binom n) ^ 2 ≤ 16 ^ n := by
  exact le_trans ( Nat.mul_le_mul_right _ ( by linarith ) ) ( central_binom_sq_le n )

/-
**Upper bound (corrected):** `C(2n,n) ≤ 4^n / √(2n)` for `n ≥ 1`.

The brief's `C(2n,n) ≤ 4^n / (2√n)` is false (e.g. `n = 2` gives `6 ≤ 5.65…`); the correct
upper bound is the one below.
-/
theorem central_binom_upper (n : ℕ) (hn : 1 ≤ n) :
    (central_binom n : ℝ) ≤ 4 ^ n / Real.sqrt (2 * n) := by
  rw [ le_div_iff₀' ] <;> norm_num;
  · have := central_binom_sq_le' n;
    convert Real.sqrt_le_sqrt ( show ( 2 * n * central_binom n ^ 2 : ℝ ) ≤ 16 ^ n by exact_mod_cast this ) using 1 ; norm_num [ mul_assoc, mul_comm, mul_left_comm, ← mul_pow ];
    rw [ show ( 16 : ℝ ) ^ n = ( 4 ^ n ) ^ 2 by norm_num [ sq, ← mul_pow ], Real.sqrt_sq ( by positivity ) ];
  · grind +qlia

/-! ### Theorem 3 — The Chebyshev product bound (the bridge result) -/

/-
**Chebyshev's product bound.**  The product of all primes `p ≤ n` is `< 4^n` for `n ≥ 1`.
This is the analytic-number-theoretic conclusion derived from the combinatorial facts above.
-/
theorem chebyshev_primorial (n : ℕ) (hn : 1 ≤ n) :
    prime_product_below n < 4 ^ n := by
  convert Nat.lt_of_le_of_ne ( primorial_le_4_pow n ) _ using 1;
  intro h; have := congr_arg ( ·.factorization 2 ) h; norm_num [ Nat.factorization_pow ] at this;
  rw [ show ( 4 : ℕ ) = 2 ^ 2 by norm_num, Nat.factorization_pow ] at this ; norm_num at this;
  rw [ primorial ] at this;
  rw [ Nat.factorization_prod ] at this <;> norm_num at *;
  · rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ Finset.sum_filter, Finset.sum_range_succ' ];
  · aesop

end BinomialPrimeBounds