/-
# Generalized mean and variance identities for the digits of `1/p` in base `b`

This file develops, from first principles, exact closed-form identities for the
sum `S`, the sum of squares `T`, and hence the variance of the *repetend digits*
of `1/p` written in an integer base `b`.

## Setup

For `p b : ℕ` we define the remainder orbit and the digit sequence by the
standard long-division recurrence:

* `rem p b 0 = 1`, `rem p b (n+1) = (b * rem p b n) % p`,
* `digit p b n = (b * rem p b n) / p`.

The single Euclidean identity `b * rem p b n = p * digit p b n + rem p b (n+1)`
drives everything.  Writing
`S = Σ digit`, `R = Σ rem`, `Q = Σ rem²`, `C = Σ rem_k·rem_{k+1}`,
`T = Σ digit²` over one period (any `n` with `rem p b n = rem p b 0`), we prove:

* `sum_digits_formula` :   `b·R = p·S + R`      (equivalently `p·S = (b-1)·R`);
* `sum_squares_formula` :  `p²·T + 2b·C = (b²+1)·Q`;
* `variance_numerator` :   `p²·(l·T − S²) = l·((b²+1)Q − 2bC) − (b−1)²R²`,
  a completely explicit closed form for the (scaled) variance
  `V = T/l − (S/l)²` valid for **arbitrary** repetend length `l`.

These are the elementary, character-free skeleton of the generalized variance
theory: the "generalized Bernoulli number" reformulation of the conjecture is
exactly the statement that `R`, `Q`, `C` decompose along Dirichlet characters of
`(ℤ/pℤ)ˣ` whose order divides `d = (p−1)/l`.

We also record:

* `midy_pairing` : a Midy-type complementarity `digit n + digit (n+m) + 1 = b`
  whenever the orbit reflects (`rem (n+m) + rem n = p`, likewise at the successor);
* `mean_full_reptend` : the classical mean value `2·S = (b−1)(p−1)` for full
  reptend primes (orbit summing to `p(p−1)/2`), recovering mean `= (b−1)/2`;
* `mean_not_always_half` : a **disproof** of the bold (false) conjecture that the
  digit mean is always `(b−1)/2`; the base-`2` expansion of `1/7` is a witness.

Nothing here assumes `p` is prime; primality only enters when identifying the
orbit sums `R, Q, C` with subgroup sums, which is where character theory lives.
-/
import Mathlib

open Finset

namespace DigitVarianceGeneral

/-- The remainder orbit of `1/p` in base `b`: `rem 0 = 1`,
`rem (n+1) = (b * rem n) mod p`. -/
def rem (p b : ℕ) : ℕ → ℕ
  | 0 => 1
  | (n + 1) => (b * rem p b n) % p

/-- The `n`-th repetend digit of `1/p` in base `b`. -/
def digit (p b : ℕ) (n : ℕ) : ℕ := b * rem p b n / p

/-- The Euclidean division identity underlying the whole theory. -/
lemma euclid (p b n : ℕ) :
    b * rem p b n = p * digit p b n + rem p b (n + 1) := by
  simpa [digit, rem] using (Nat.div_add_mod (b * rem p b n) p).symm

/-- Integer-cast form of `euclid`. -/
lemma euclidZ (p b n : ℕ) :
    (b : ℤ) * rem p b n = p * digit p b n + rem p b (n + 1) := by
  exact_mod_cast euclid p b n

/-- `S = Σ_{k<n} digit k`, the sum of the first `n` digits. -/
noncomputable def S (p b n : ℕ) : ℤ := ∑ k ∈ range n, (digit p b k : ℤ)

/-- `R = Σ_{k<n} rem k`, the sum of the first `n` remainders. -/
noncomputable def R (p b n : ℕ) : ℤ := ∑ k ∈ range n, (rem p b k : ℤ)

/-- `Q = Σ_{k<n} rem k ²`. -/
noncomputable def Q (p b n : ℕ) : ℤ := ∑ k ∈ range n, ((rem p b k : ℤ)) ^ 2

/-- `C = Σ_{k<n} rem k · rem (k+1)`, the "cross" sum. -/
noncomputable def C (p b n : ℕ) : ℤ :=
  ∑ k ∈ range n, (rem p b k : ℤ) * (rem p b (k + 1) : ℤ)

/-- `T = Σ_{k<n} digit k ²`, the sum of squares of the first `n` digits. -/
noncomputable def T (p b n : ℕ) : ℤ := ∑ k ∈ range n, ((digit p b k : ℤ)) ^ 2

/-- Telescoping identity: shifting the index of a finite sum. -/
lemma shift_sum (f : ℕ → ℤ) (n : ℕ) :
    ∑ k ∈ range n, f (k + 1) = (∑ k ∈ range n, f k) + f n - f 0 := by
  have h := Finset.sum_range_sub f n
  rw [Finset.sum_sub_distrib] at h
  linarith [h]

/-- Pointwise quadratic identity relating one digit to two consecutive
remainders (a squared form of `euclid`). -/
lemma sq_pointwise (p b n : ℕ) :
    (p : ℤ) ^ 2 * (digit p b n : ℤ) ^ 2
        + 2 * b * (rem p b n : ℤ) * (rem p b (n + 1) : ℤ)
        + (rem p b (n + 1) : ℤ) ^ 2
      = (b : ℤ) ^ 2 * (rem p b n : ℤ) ^ 2 + 2 * (rem p b (n + 1) : ℤ) ^ 2 := by
  linear_combination
    ((rem p b (n + 1) : ℤ) - (p : ℤ) * digit p b n - (b : ℤ) * rem p b n)
      * euclidZ p b n

/-- **Digit-sum formula.**  Over one full period (`rem p b n = rem p b 0`),
`b·R = p·S + R`, equivalently `p·S = (b−1)·R`. -/
theorem sum_digits_formula (p b n : ℕ) (h : rem p b n = rem p b 0) :
    (b : ℤ) * R p b n = p * S p b n + R p b n := by
  have key : (b : ℤ) * R p b n
      = p * S p b n + ∑ k ∈ range n, (rem p b (k + 1) : ℤ) := by
    unfold R S
    rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl (fun k _ => euclidZ p b k)
  have hs := shift_sum (fun k => (rem p b k : ℤ)) n
  simp only at hs
  rw [key, hs]
  have hr : (rem p b n : ℤ) = (rem p b 0 : ℤ) := by rw [h]
  rw [hr]; unfold R; ring

/-- Immediate reformulation `p·S = (b−1)·R`. -/
theorem digit_sum_eq (p b n : ℕ) (h : rem p b n = rem p b 0) :
    (p : ℤ) * S p b n = ((b : ℤ) - 1) * R p b n := by
  have := sum_digits_formula p b n h; ring_nf; ring_nf at this; linarith [this]

/-- **Digit sum-of-squares formula.**  Over one full period,
`p²·T + 2b·C = (b²+1)·Q`. -/
theorem sum_squares_formula (p b n : ℕ) (h : rem p b n = rem p b 0) :
    (p : ℤ) ^ 2 * T p b n + 2 * b * C p b n = ((b : ℤ) ^ 2 + 1) * Q p b n := by
  have hpt : (p : ℤ) ^ 2 * T p b n + 2 * b * C p b n
      + ∑ k ∈ range n, (rem p b (k + 1) : ℤ) ^ 2
      = (b : ℤ) ^ 2 * Q p b n + 2 * ∑ k ∈ range n, (rem p b (k + 1) : ℤ) ^ 2 := by
    unfold T C Q
    rw [Finset.mul_sum, Finset.mul_sum, Finset.mul_sum, Finset.mul_sum,
      ← Finset.sum_add_distrib, ← Finset.sum_add_distrib, ← Finset.sum_add_distrib]
    refine Finset.sum_congr rfl (fun k _ => ?_)
    linear_combination
      ((rem p b (k + 1) : ℤ) - (p : ℤ) * digit p b k - (b : ℤ) * rem p b k)
        * euclidZ p b k
  have hs := shift_sum (fun k => (rem p b k : ℤ) ^ 2) n
  simp only at hs
  have hr : (rem p b n : ℤ) = (rem p b 0 : ℤ) := by rw [h]
  rw [hs, hr] at hpt
  have hQ : (∑ k ∈ range n, (rem p b k : ℤ) ^ 2) = Q p b n := rfl
  rw [hQ] at hpt
  nlinarith [hpt]

/-- **Generalized variance formula.**  For any period length `l`
(`rem p b l = rem p b 0`), the scaled variance numerator has the closed form
`p²·(l·T − S²) = l·((b²+1)·Q − 2b·C) − (b−1)²·R²`, expressed purely in the orbit
sums `R, Q, C`.  Since the variance is `V = T/l − (S/l)² = (l·T − S²)/l²`, this
is an exact closed form for `V` valid for arbitrary repetend length. -/
theorem variance_numerator (p b l : ℕ) (h : rem p b l = rem p b 0) :
    (p : ℤ) ^ 2 * ((l : ℤ) * T p b l - S p b l ^ 2)
      = (l : ℤ) * (((b : ℤ) ^ 2 + 1) * Q p b l - 2 * b * C p b l)
        - ((b : ℤ) - 1) ^ 2 * R p b l ^ 2 := by
  have h1 := digit_sum_eq p b l h
  have h2 := sum_squares_formula p b l h
  linear_combination (l : ℤ) * h2 - ((p : ℤ) * S p b l + ((b : ℤ) - 1) * R p b l) * h1

/-- **Midy-type complementarity.**  If the remainder orbit reflects with offset
`m` (i.e. `rem (n+m) + rem n = p` and the same at the successor index), then the
paired digits are complementary: `digit n + digit (n+m) + 1 = b`.  For `l` even
and `p` prime this holds with `m = l/2`, giving the classical Midy theorem
`digit n + digit (n+l/2) = b − 1`. -/
theorem midy_pairing (p b n m : ℕ) (hp : 0 < p)
    (h1 : rem p b (n + m) + rem p b n = p)
    (h2 : rem p b (n + m + 1) + rem p b (n + 1) = p) :
    digit p b n + digit p b (n + m) + 1 = b := by
  have e1 := euclid p b n
  have e2 := euclid p b (n + m)
  have expand : b * p = b * rem p b (n + m) + b * rem p b n := by
    rw [← Nat.mul_add, h1]
  have hbp : b * p = p * (digit p b n + digit p b (n + m) + 1) := by
    rw [expand, e1, e2]; linarith [h2]
  have hbp' : p * b = p * (digit p b n + digit p b (n + m) + 1) := by
    rw [Nat.mul_comm]; exact hbp
  have hb := Nat.eq_of_mul_eq_mul_left hp hbp'
  omega

/-- **Full-reptend mean value.**  If the orbit over the period `l` sums to
`p(p−1)/2` (as for a base that is a primitive root mod a prime `p`), then
`2·S = (b−1)(p−1)`, i.e. the mean digit is exactly `(b−1)/2`. -/
theorem mean_full_reptend (p b l : ℕ) (hp : (p : ℤ) ≠ 0)
    (h : rem p b l = rem p b 0) (hR : 2 * R p b l = (p : ℤ) * ((p : ℤ) - 1)) :
    2 * S p b l = ((b : ℤ) - 1) * ((p : ℤ) - 1) := by
  have hPS := digit_sum_eq p b l h
  have hmain : (p : ℤ) * (2 * S p b l) = (p : ℤ) * (((b : ℤ) - 1) * ((p : ℤ) - 1)) := by
    linear_combination 2 * hPS + ((b : ℤ) - 1) * hR
  exact mul_left_cancel₀ hp hmain

/-- **Disproof of a bold conjecture.**  The digit mean of `1/p` in base `b` is
*not* always `(b−1)/2`.  The (repetend length `3`) base-`2` expansion of `1/7`
is `0.\overline{001}`, whose digit sum is `1`, while `(b−1)·l/2 = 3/2`; equivalently
`2·S ≠ (b−1)·l`.  This shows the "always `(b−1)/2`" conjecture fails precisely
when the base is not a primitive root (here `ord_7(2) = 3 < 6`). -/
theorem mean_not_always_half :
    ¬ (∀ p b l : ℕ, rem p b l = rem p b 0 → 0 < l →
        2 * S p b l = ((b : ℤ) - 1) * l) := by
  intro H
  have hper : rem 7 2 3 = rem 7 2 0 := by decide
  have := H 7 2 3 hper (by norm_num)
  simp only [S, Finset.sum_range_succ, Finset.sum_range_zero, digit, rem] at this
  norm_num at this

end DigitVarianceGeneral