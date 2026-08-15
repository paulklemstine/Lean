import Cryptography.MordellDenominators.Basic

/-!
# A counterexample machine

Both the numerical counterexample (`Counterexample.lean`) and the infinite
family (`Family.lean`) are instances of one criterion, proved here.

**Criterion.**  Let `P = (x, y)` be an *integral* point of `E_N : y² = x³ + N`
with `y ≠ 0`, and let `ℓ` be a prime with `ℓ ∣ y` and `ℓ ∤ 6N`.  Then `ℓ`
divides the denominator of `x(2P)`, so the "only bad primes" conjecture fails
for `(N, P)`.

The proof is a two-line valuation computation once the duplication formula is
written over `ℤ`: the denominator of `x(2P)` is (a divisor of) `4y²`, which `ℓ`
divides, while the numerator `x⁴ - 8Nx = x(y² - 9N)` is prime to `ℓ` precisely
because `ℓ ∤ 6N`.  Thus **every** integral point whose `y`-coordinate has a
prime factor of good reduction refutes the conjecture — such points are
ubiquitous, which is why the conjecture fails 100% of the time in experiments.
-/

namespace MordellDenominators

/-- Duplication of an integral point, as an explicit fraction of integers. -/
theorem dblX_intPoint {N x y : ℤ} (h : y ^ 2 = x ^ 3 + N) :
    dblX N (x : ℚ) = ((x ^ 4 - 8 * N * x : ℤ) : ℚ) / ((4 * y ^ 2 : ℤ) : ℚ) := by
  have hQ : ((x : ℚ)) ^ 3 + (N : ℚ) = ((y : ℚ)) ^ 2 := by
    have := congrArg (fun z : ℤ => (z : ℚ)) h
    push_cast at this
    linarith
  unfold dblX
  rw [hQ]
  push_cast
  ring

/-- **The counterexample machine.**  If an integral point `(x, y)` on
`E_N : y² = x³ + N` has `y ≠ 0` and some prime `ℓ` divides `y` but not `6N`,
then that prime — a prime of good reduction — divides the denominator of
`x(2P)`. -/
theorem good_prime_dvd_den_dblX {N x y : ℤ} (h : y ^ 2 = x ^ 3 + N) (hy : y ≠ 0)
    {l : ℕ} (hl : l.Prime) (hly : (l : ℤ) ∣ y) (hlN : ¬ ((l : ℤ) ∣ 6 * N)) :
    l ∣ (dblX N (x : ℚ)).den := by
  have hlp : Prime (l : ℤ) := Nat.prime_iff_prime_int.mp hl
  have hl6 : ¬ ((l : ℤ) ∣ 6) := fun hc => hlN (Dvd.dvd.mul_right hc N)
  have hlNN : ¬ ((l : ℤ) ∣ N) := fun hc => hlN (Dvd.dvd.mul_left hc 6)
  have hl3 : ¬ ((l : ℤ) ∣ 3) := fun hc => hl6 (hc.trans (by norm_num))
  have hly2 : (l : ℤ) ∣ y ^ 2 := Dvd.dvd.trans hly (dvd_pow_self y (by norm_num))
  -- `ℓ` does not divide `x`
  have hlx : ¬ ((l : ℤ) ∣ x) := by
    intro hc
    have hx3 : (l : ℤ) ∣ x ^ 3 := Dvd.dvd.trans hc (dvd_pow_self x (by norm_num))
    exact hlNN (by
      have : (l : ℤ) ∣ y ^ 2 - x ^ 3 := dvd_sub hly2 hx3
      simpa [h] using this)
  -- the numerator `x⁴ - 8Nx = x (y² - 9N)` is prime to `ℓ`
  have hnum : ¬ ((l : ℤ) ∣ x ^ 4 - 8 * N * x) := by
    intro hc
    have hfact : x ^ 4 - 8 * N * x = x * (y ^ 2 - 9 * N) := by
      have : x ^ 3 = y ^ 2 - N := by linarith
      calc x ^ 4 - 8 * N * x = x * (x ^ 3 - 8 * N) := by ring
        _ = x * ((y ^ 2 - N) - 8 * N) := by rw [this]
        _ = x * (y ^ 2 - 9 * N) := by ring
    rw [hfact] at hc
    rcases hlp.dvd_mul.mp hc with hcx | hcy
    · exact hlx hcx
    · have h9N : (l : ℤ) ∣ 9 * N := by
        have := dvd_sub hly2 hcy
        simpa using this
      rcases hlp.dvd_mul.mp h9N with h9 | hN
      · refine hl3 (hlp.dvd_of_dvd_pow (n := 2) ?_)
        rw [show ((3 : ℤ) ^ 2) = 9 by norm_num]
        exact h9
      · exact hlNN hN
  refine prime_dvd_den_of_eq_div (A := x ^ 4 - 8 * N * x) (B := 4 * y ^ 2)
    (by positivity) (dblX_intPoint h) hl ?_ hnum
  exact Dvd.dvd.mul_left hly2 4

/-- **Every integral point with a good prime in its `y`-coordinate refutes the
conjecture.** -/
theorem not_onlyBadPrimes_of_intPoint {N x y : ℤ} (h : y ^ 2 = x ^ 3 + N)
    (hy : y ≠ 0) {l : ℕ} (hl : l.Prime) (hly : (l : ℤ) ∣ y)
    (hlN : ¬ ((l : ℤ) ∣ 6 * N)) :
    ¬ OnlyBadPrimes N ((x : ℚ), (y : ℚ)) := by
  intro hcon
  refine hlN (hcon 1 l hl ?_)
  rw [dblIter_one_fst]
  exact good_prime_dvd_den_dblX h hy hl hly hlN

/-- The integral point is indeed a point of the curve, so the criterion
applies to genuine rational points. -/
theorem onCurve_of_intPoint {N x y : ℤ} (h : y ^ 2 = x ^ 3 + N) :
    OnCurve N (x : ℚ) (y : ℚ) := by
  unfold OnCurve
  have := congrArg (fun z : ℤ => (z : ℚ)) h
  push_cast at this
  linarith

end MordellDenominators