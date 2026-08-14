import Novelty.ShorOrderFactoring
import Novelty.ShorQFTOutput

/-! # From one ideal QFT sample to a factor of `N`

`ShorQFTOutput` shows that the ideal output distribution of Shor's algorithm is
uniform on the `r` frequencies `y = k · m`, `k < r`, of a register of size
`Q = r · m`.  This file closes the loop: **each such sample determines a divisor
of the order, and determines the order exactly when `gcd(k, r) = 1`**; together
with `ShorOrderFactoring` this turns one ideal sample into a nontrivial factor
of `N`.

Because the peaks of the ideal distribution are *exact* rationals `y / Q = k / r`
(no continued-fraction approximation is needed at this level of idealization),
the reduction is purely arithmetic:

* `denominator_of_peak` : `Q / gcd(y, Q) = r / gcd(k, r)` for `y = k · m`;
* `denominator_of_peak_dvd` : the recovered denominator always divides `r`;
* `denominator_of_peak_eq` : it equals `r` exactly when `gcd(k, r) = 1`;
* `exists_factor_of_peak_sample` : the full chain
  *sample → order → nontrivial factor of `N`*.

This is the formal content of the statement that a polynomial-time classical
sampler of Shor's output distribution would be a polynomial-time factoring
algorithm: nothing quantum remains in the post-processing.
-/

namespace ShorIrreducible

/-- **The denominator recovered from a peak sample.**  For a frequency
`y = k · m` of a register of size `Q = r · m`, the reduced denominator of
`y / Q` is `r / gcd(k, r)`. -/
theorem denominator_of_peak {r m k : ℕ} (hm : 0 < m) :
    (r * m) / Nat.gcd (k * m) (r * m) = r / Nat.gcd k r := by
  rw [Nat.gcd_mul_right, Nat.mul_div_mul_right _ _ hm, Nat.gcd_comm]

/-- Every peak sample recovers a divisor of the order. -/
theorem denominator_of_peak_dvd {r m k : ℕ} (hm : 0 < m) :
    (r * m) / Nat.gcd (k * m) (r * m) ∣ r := by
  rw [denominator_of_peak hm]
  exact Nat.div_dvd_of_dvd (Nat.gcd_dvd_right k r)

/-- **A peak sample with `gcd(k, r) = 1` recovers the order exactly.**  Since a
uniformly random `k < r` is coprime to `r` with probability `φ(r)/r`, a constant
number of samples suffices. -/
theorem denominator_of_peak_eq {r m k : ℕ} (hm : 0 < m) (hcop : Nat.Coprime k r) :
    (r * m) / Nat.gcd (k * m) (r * m) = r := by
  rw [denominator_of_peak hm, hcop, Nat.div_one]

/-- **One ideal sample factors `N`.**  Given a peak frequency `y = k·m` of the
Shor register with `gcd(k, r) = 1`, the order `r` of `a` is recovered exactly
from `y`, and if `r` is even with `a^{r/2} ≢ -1` this yields a nontrivial
divisor of `N`.  Hence a polynomial-time classical sampler for the output
distribution of Shor's algorithm is a polynomial-time factoring algorithm. -/
theorem exists_factor_of_peak_sample {N : ℕ} (hN : 1 < N) (a : ZMod N) {m k : ℕ}
    (hm : 0 < m) (hpos : 0 < orderOf a) (heven : Even (orderOf a))
    (hne : a ^ (orderOf a / 2) ≠ -1) (hcop : Nat.Coprime k (orderOf a)) :
    (orderOf a * m) / Nat.gcd (k * m) (orderOf a * m) = orderOf a ∧
      ∃ d : ℕ, d ∣ N ∧ 1 < d ∧ d < N :=
  ⟨denominator_of_peak_eq hm hcop, exists_factor_of_orderOf_even hN a hpos heven hne⟩

/-- The peak frequencies really are the multiples of `m`: this is the link
between `denominator_of_peak` and the output distribution computed in
`ShorQFTOutput`. -/
theorem qftCombProb_ne_zero_iff {r m y : ℕ} (hr : 0 < r) :
    qftCombProb r m y ≠ 0 ↔ m ∣ y := by
  constructor
  · intro h
    by_contra hdvd
    exact h (by simp [qftCombProb, hdvd])
  · intro hdvd
    have hrne : (r : ℝ) ≠ 0 := by
      have : (0 : ℝ) < r := by exact_mod_cast hr
      exact this.ne'
    simp [qftCombProb, hdvd, hrne]

end ShorIrreducible