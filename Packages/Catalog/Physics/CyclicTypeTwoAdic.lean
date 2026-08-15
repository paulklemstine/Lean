import Catalog.Physics.CyclicTypeFactorization

/-!
# The 2-adic type tower saturates at exactly two bits

The Sylow decomposition `CyclicType.HT_eq_sum_primePow` reduces the splitting-type channel of a
cyclic order to its prime-power parts.  This file computes the 2-primary part in closed form.

For the cyclic order `2^k` — the Galois group of the maximal `2`-elementary layer — the
Euler-φ type law is `P(T = 2^j) = φ(2^j)/2^k`, and the resulting entropy has the exact closed
form

`H(T)(2^k) = 2 − 2^{1−k}`.

In particular the whole 2-adic tower is bounded by two bits, and converges to exactly two bits:
adding another power of `2` to the Galois group buys geometrically less and less splitting
information, in sharp contrast with the unbounded growth `H(T)(p) ~ log₂ p` along primes.

## Main results

* `CyclicType.HT_two_pow` : `H(T)(2^k) = 2 − 2/2^k`.
* `CyclicType.HT_two_pow_lt_two` : the tower never reaches two bits.
* `CyclicType.HT_two_pow_strictMono` : it increases strictly along the tower.
* `CyclicType.HT_two_pow_tendsto` : it converges to two bits.
-/

set_option maxHeartbeats 1000000

namespace CyclicType

open Finset

/-- The Euler-φ log-sum along the 2-adic tower: `Σ_{j≤k} φ(2^j) log₂ φ(2^j) = (k−2)2^k + 2`. -/
private lemma sum_two_adic (k : ℕ) :
    ∑ j ∈ Finset.range (k + 1),
      ((Nat.totient (2 ^ j) : ℝ) * Real.logb 2 (Nat.totient (2 ^ j)))
      = ((k : ℝ) - 2) * 2 ^ k + 2 := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [Finset.sum_range_succ, ih]
    have htot : (Nat.totient (2 ^ (k + 1)) : ℝ) = 2 ^ k := by
      rw [Nat.totient_prime_pow Nat.prime_two (Nat.succ_pos k)]
      simp
    rw [htot]
    have hlog : Real.logb 2 ((2 : ℝ) ^ k) = (k : ℝ) := by
      rw [Real.logb_pow, Real.logb_self_eq_one (by norm_num : (1 : ℝ) < 2)]
      ring
    rw [hlog]
    push_cast
    ring

/-- **The 2-adic closed form.**  The splitting-type entropy of the cyclic order `2^k` is exactly
`2 − 2^{1−k}`. -/
theorem HT_two_pow (k : ℕ) : HT (2 ^ k) = 2 - 2 / 2 ^ k := by
  have hpos : 0 < 2 ^ k := Nat.two_pow_pos k
  have hposR : (0 : ℝ) < 2 ^ k := by positivity
  rw [HT_divisor_formula hpos, Nat.sum_divisors_prime_pow Nat.prime_two, sum_two_adic k]
  have hcast : ((2 ^ k : ℕ) : ℝ) = (2 : ℝ) ^ k := by push_cast; ring
  rw [hcast]
  have hlog : Real.logb 2 ((2 : ℝ) ^ k) = (k : ℝ) := by
    rw [Real.logb_pow, Real.logb_self_eq_one (by norm_num : (1 : ℝ) < 2)]
    ring
  rw [hlog]
  field_simp
  ring

/-- The 2-adic tower never reaches two bits. -/
theorem HT_two_pow_lt_two (k : ℕ) : HT (2 ^ k) < 2 := by
  rw [HT_two_pow]
  have : (0 : ℝ) < 2 / 2 ^ k := by positivity
  linarith

/-- Each extra power of `2` in the Galois group strictly increases the type entropy. -/
theorem HT_two_pow_strictMono {j k : ℕ} (h : j < k) : HT (2 ^ j) < HT (2 ^ k) := by
  rw [HT_two_pow, HT_two_pow]
  have hj : (0 : ℝ) < 2 ^ j := by positivity
  have hk : (0 : ℝ) < 2 ^ k := by positivity
  have hlt : (2 : ℝ) ^ j < 2 ^ k := by
    exact pow_lt_pow_right₀ (by norm_num) h
  have := div_lt_div_of_pos_left (by norm_num : (0:ℝ) < 2) hj hlt
  linarith

/-- **Saturation.**  Along the 2-adic tower the type channel converges to exactly two bits. -/
theorem HT_two_pow_tendsto :
    Filter.Tendsto (fun k : ℕ => HT (2 ^ k)) Filter.atTop (nhds 2) := by
  have hfun : (fun k : ℕ => HT (2 ^ k)) = fun k : ℕ => 2 - 2 * (1 / 2 : ℝ) ^ k := by
    funext k
    rw [HT_two_pow, div_pow, one_pow]
    field_simp
  rw [hfun]
  have h0 : Filter.Tendsto (fun k : ℕ => ((1 : ℝ) / 2) ^ k) Filter.atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num) (by norm_num)
  have h1 : Filter.Tendsto (fun k : ℕ => 2 * ((1 : ℝ) / 2) ^ k) Filter.atTop (nhds 0) := by
    simpa using h0.const_mul (2 : ℝ)
  simpa using (tendsto_const_nhds (x := (2 : ℝ)) (f := Filter.atTop (α := ℕ))).sub h1

end CyclicType