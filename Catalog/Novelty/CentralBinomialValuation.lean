import Mathlib

/-!
# The `q`-adic valuation of `Aₜ = C(q^{t+1}, qᵗ) − q^{qᵗ}`

Fix a prime base `q`.  The Guedes–Machado construction of composite solutions
`n = qᵗ·p` to `C(qn, n) ≡ qⁿ (mod n)` is driven by the integer
`  Aₜ := C(q^{t+1}, qᵗ) − q^{qᵗ}, `
whose *odd* (prime `≠ q`) divisors `p` supply the second factor of `n`.

This file pins down the exact power of the base `q` itself that divides `Aₜ`.

## Main results

* `central_choose_factorization` : `v_q(C(q^{t+1}, qᵗ)) = 1` for every prime `q`
  and every `t`.  (Kummer/Legendre via
  `Nat.factorization_choose_prime_pow_add_factorization`: exactly one base-`q`
  carry occurs in `qᵗ + (q−1)qᵗ = q^{t+1}`.)
* `A_qadic_valuation` : for a prime `q` and `t ≥ 1`, the base `q` divides `Aₜ`
  exactly once: `q ∣ Aₜ` but `q² ∤ Aₜ`.

The point of `A_qadic_valuation` is structural: because `q ∥ Aₜ`, the base `q`
can never be the prime `p` used in `n = qᵗ·p`, and the "interesting" divisors of
`Aₜ` are precisely the primes `p ≠ q`.  This isolates exactly the search space of
the Guedes–Machado conjecture.

-- !-- Lab Notes -- !--
Hypothesis log / experimental record.

H1 (Hypothesizer). `v_q(C(q^{t+1}, qᵗ)) = 1` for all primes `q` and all `t`.
    EVIDENCE: `#eval ((2^3).choose (2^2)).factorization 2 = 1`,
    `#eval ((3^2).choose (3^1)).factorization 3 = 1`.  CONFIRMED.
    MECHANISM: `v_q(C(q^{t+1}, qᵗ)) + v_q(qᵗ) = t+1` (Kummer prime-power form),
    and `v_q(qᵗ) = t`, so the valuation is `(t+1) − t = 1`.

H2 (Experimenter). Hence `q ∥ Aₜ`.  Indeed `v_q(q^{qᵗ}) = qᵗ ≥ 2` for `t ≥ 1`,
    so `q² ∣ q^{qᵗ}` while `q² ∤ C(q^{t+1}, qᵗ)`; subtracting keeps `q ∣ Aₜ` and
    kills `q² ∣ Aₜ`.
    EVIDENCE: `A 2 1 = 2` (`= 2·1`), `A 2 2 = 54 = 2·27`, `A 3 1 = 57 = 3·19`;
    all are `q·(unit mod q)`.  CONFIRMED → `A_qadic_valuation`.

H3 (Analyst). Consequence: `p = q` is *never* a divisor supplying `n = qᵗ·p`, so
    the conjecture's requirement `p ≠ q` is automatic from arithmetic, not an
    extra genericity assumption.  The residual factor `Aₜ / q` (`= 1, 27, 19, …`)
    is where all candidate primes live; its factorisations seed
    `FUTURE_DIRECTIONS.md`.

FAILURE ANALYSIS: trying to compute `v_q(Aₜ)` directly via Kummer on `Aₜ` failed
(`Aₜ` is not a binomial coefficient).  The working route is the *difference*
argument: bound the two summands' valuations separately, which needs only
`t ≥ 1` to guarantee `qᵗ ≥ 2`.
-/

namespace CentralBinomialValuation

open Nat

/-- `Aₜ = C(q^{t+1}, qᵗ) − q^{qᵗ}`, as an integer (the subtraction may otherwise
truncate in `ℕ`). -/
def A (q t : ℕ) : ℤ := (Nat.choose (q ^ (t + 1)) (q ^ t) : ℤ) - (q : ℤ) ^ (q ^ t)

/-
**Central prime-power binomial valuation.** For every prime `q` and `t`,
the base `q` divides `C(q^{t+1}, qᵗ)` exactly once.
-/
theorem central_choose_factorization {q : ℕ} (hq : q.Prime) (t : ℕ) :
    ((q ^ (t + 1)).choose (q ^ t)).factorization q = 1 := by
  have := ( @Nat.factorization_choose_prime_pow_add_factorization q ( t + 1 ) ( q ^ t ) );
  simp_all +decide [ pow_succ' ];
  linarith [ this ( by nlinarith [ hq.two_le, pow_pos hq.pos t ] ) ( by aesop ) ]

/-
**`q`-adic valuation of `Aₜ`.** For a prime base `q` and `t ≥ 1`, the base `q`
divides `Aₜ` exactly once: `q ∣ Aₜ` but `q² ∤ Aₜ`.
-/
theorem A_qadic_valuation {q : ℕ} (hq : q.Prime) {t : ℕ} (ht : 1 ≤ t) :
    (q : ℤ) ∣ A q t ∧ ¬ (q : ℤ) ^ 2 ∣ A q t := by
  constructor;
  · refine' dvd_sub _ ( dvd_pow_self _ _ );
    · exact_mod_cast Nat.dvd_trans ( dvd_pow_self _ ( by linarith ) ) ( central_choose_factorization hq t ▸ Nat.ordProj_dvd _ _ );
    · aesop;
  · -- From `central_choose_factorization hq t` we have `C.factorization q = 1`. Since `q` is prime, `Nat.Prime.pow_dvd_iff_le_factorization` gives: `q^2 ∣ C ↔ 2 ≤ C.factorization q` (false), so `¬ q^2 ∣ C`.
    have hq2_C : ¬ (q : ℤ) ^ 2 ∣ (Nat.choose (q ^ (t + 1)) (q ^ t) : ℤ) := by
      norm_cast; intro h; have := Nat.factorization_le_iff_dvd ( by aesop ) ( Nat.ne_of_gt <| Nat.choose_pos <| Nat.pow_le_pow_right hq.pos <| Nat.le_succ _ ) |>.2 h; simp_all +decide [ Nat.factorization_pow ] ;
      exact absurd this ( by rw [ central_choose_factorization hq t ] ; norm_num );
    contrapose! hq2_C;
    convert dvd_add hq2_C ( pow_dvd_pow _ ( show 2 ≤ q ^ t from one_lt_pow₀ hq.one_lt ( by linarith ) ) ) using 1 ; simp +decide [ A ]

end CentralBinomialValuation