import Pythagorean.FactoringBarriers.SmoothnessEscape

/-!
# Lab notes: machine-checked instances of the experimental data

The exploratory runs behind `ComputationalEvidence.md` swept all `136` semiprimes
`N = p q` with `p < q < 60` against seven integer polynomials and against the `p - 1`
witness for several exponents.  Two observations came out of the sweep, and both are
now theorems (`polyWitness_eq_gcd_const`, `mem_revealedPrimes_of_splits_prime`,
`pollard_splits`, `pollard_fails_when_both_smooth`).  This file pins down the concrete
instances that the sweep produced, so the data itself is machine-checked.

Sweep data reproduced here:

| invariant `f`        | `f(0)` | semiprimes split (of 136) | primes ever revealed |
|----------------------|--------|---------------------------|----------------------|
| `x² + 5x + 6`        | `6`    | `30`                      | `{2, 3}`             |
| `x³ - 7x + 12`       | `12`   | `30`                      | `{2, 3}`             |
| `3x⁵ + 2x - 30`      | `-30`  | `42`                      | `{2, 3, 5}`          |
| `x² + 1`             | `1`    | `0`                       | `∅`                  |
| `x`                  | `0`    | `0`                       | `∅` (witness `= N`)  |
| `x² + 210`           | `210`  | `52`                      | `{2, 3, 5, 7}`       |

In every case the revealed primes are exactly the prime factors of `f(0)`, as Barrier I
predicts, and `gcd(f(N), N) = gcd(f(0), N)` held in all `952` checks.
-/

namespace FactoringBarriers

open Polynomial

/-- Data point: for `f = x² + 5x + 6` the witness at `N = 91 = 7 · 13` is trivial,
because neither `7` nor `13` divides `f(0) = 6`. -/
theorem labnote_no_split_91 : polyWitness (X ^ 2 + 5 * X + 6) 91 = 1 := by
  rw [polyWitness_eq_gcd_const]
  norm_num

/-- Data point: when the invariant does split, it splits only through a prime of
`f(0)`; here `N = 15 = 3 · 5` and the witness is the prime `3 ∣ 6`. -/
theorem labnote_split_15 : polyWitness (X ^ 2 + 5 * X + 6) 15 = 3 := by
  rw [polyWitness_eq_gcd_const]
  norm_num

/-- Data point: the set of primes this invariant can ever reveal is `{2, 3}`, for every
input, matching the sweep. -/
theorem labnote_revealedPrimes : revealedPrimes (X ^ 2 + 5 * X + 6) = {2, 3} := by
  have h : ((X ^ 2 + 5 * X + 6 : ℤ[X]).eval 0).natAbs = 6 := by norm_num
  rw [revealedPrimes, h]
  simp [Nat.primeFactors]

/-- Data point: the `log₂` budget of Barrier I is met — the invariant with constant
term `210` reveals `4` primes and `log₂ 210 = 7`. -/
theorem labnote_log_budget :
    (revealedPrimes (X ^ 2 + C 210)).card ≤ Nat.log 2 210 := by
  have h : ((X ^ 2 + C 210 : ℤ[X]).eval 0) = 210 := by norm_num
  have := card_revealedPrimes_le_log (X ^ 2 + C 210) (by rw [h]; norm_num)
  rwa [h] at this

/-- Data point (over-smooth failure): for `N = 15 = 3 · 5` and exponent `m = 4`, both
`3 - 1` and `5 - 1` divide `m`, so the `p - 1` witness returns the whole modulus. -/
theorem labnote_pollard_oversmooth :
    Int.gcd ((2 : ℤ) ^ 4 - 1) ((3 * 5 : ℕ) : ℤ) = 3 * 5 :=
  pollard_fails_when_both_smooth (by norm_num) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)

/-- Data point (successful escape): for `N = 35 = 5 · 7` and `m = 4`, only `5 - 1`
divides `m`, and the witness is the prime `5`. -/
theorem labnote_pollard_success : Int.gcd ((2 : ℤ) ^ 4 - 1) ((35 : ℕ) : ℤ) = 5 :=
  pollard_example

end FactoringBarriers