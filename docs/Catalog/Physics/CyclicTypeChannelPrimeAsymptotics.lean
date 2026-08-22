import Physics.CyclicTypeChannelPrime

/-!
# Quadratic decay of the prime-order cyclic type-pair channel

Using the exact closed form `CyclicType.Ipair_prime`, we prove sharp two-sided bounds for the
semiprime type-pair channel of a prime cyclic order:

`1 / (p² log 2)  ≤  I_pair(p)  ≤  (log₂ p + 5) / p²`   for every odd prime `p`.

Both sides are `p^{-2}` up to a logarithm, so the prime-order channel closes *quadratically*
in the order of the group — much faster than the `O(1/p)` envelope of
`CyclicType.Ipair_prime_decay` — and it is never exactly silent.

The engine is the algebraic split

`I_pair(p) = (log₂ p - log₂ (p-1)) + log₂ (p-1)/p² - ((p-1)(p-2)/p²)(log₂ (p-1) - log₂ (p-2))`

together with the elementary two-sided estimate `(x-y)/x ≤ log (x/y) ≤ (x-y)/y`.

## Main results

* `CyclicType.Ipair_prime_split` : the algebraic split above.
* `CyclicType.Ipair_prime_lower` : `1/(p² log 2) ≤ I_pair(p)` for odd primes.
* `CyclicType.Ipair_prime_pos` : `0 < I_pair(p)` — the channel never closes completely.
* `CyclicType.Ipair_prime_upper_sq` : `I_pair(p) ≤ (log₂ p + 5)/p²` for every prime.
-/

set_option maxHeartbeats 1000000

namespace CyclicType

variable {p : ℕ}

/-! ## Elementary two-sided logarithm bounds -/

lemma log_div_le {x y : ℝ} (hy : 0 < y) (hxy : y ≤ x) : Real.log x - Real.log y ≤ (x - y) / y := by
  have hx : 0 < x := lt_of_lt_of_le hy hxy
  have h := Real.log_le_sub_one_of_pos (x := x / y) (by positivity)
  rw [Real.log_div (ne_of_gt hx) (ne_of_gt hy)] at h
  have hfrac : x / y - 1 = (x - y) / y := by field_simp
  linarith [hfrac ▸ h]

lemma le_log_div {x y : ℝ} (hy : 0 < y) (hxy : y ≤ x) : (x - y) / x ≤ Real.log x - Real.log y := by
  have hx : 0 < x := lt_of_lt_of_le hy hxy
  have h := Real.log_le_sub_one_of_pos (x := y / x) (by positivity)
  rw [Real.log_div (ne_of_gt hy) (ne_of_gt hx)] at h
  have hfrac : y / x - 1 = -((x - y) / x) := by field_simp; ring
  rw [hfrac] at h
  linarith

lemma logb_diff_le {x y : ℝ} (hy : 0 < y) (hxy : y ≤ x) :
    Real.logb 2 x - Real.logb 2 y ≤ (x - y) / y / Real.log 2 := by
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  rw [Real.logb, Real.logb, div_sub_div_same]
  exact (div_le_div_iff_of_pos_right hlog2).2 (log_div_le hy hxy)

lemma le_logb_diff {x y : ℝ} (hy : 0 < y) (hxy : y ≤ x) :
    (x - y) / x / Real.log 2 ≤ Real.logb 2 x - Real.logb 2 y := by
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  rw [Real.logb, Real.logb, div_sub_div_same]
  exact (div_le_div_iff_of_pos_right hlog2).2 (le_log_div hy hxy)

/-! ## The algebraic split of the exact closed form -/

/-- Rewriting of `Ipair_prime` that isolates the two consecutive logarithm increments. -/
theorem Ipair_prime_split (hp : p.Prime) :
    Ipair p = (Real.logb 2 p - Real.logb 2 ((p : ℝ) - 1))
      + Real.logb 2 ((p : ℝ) - 1) / (p : ℝ) ^ 2
      - (((p : ℝ) - 1) * ((p : ℝ) - 2) / (p : ℝ) ^ 2)
        * (Real.logb 2 ((p : ℝ) - 1) - Real.logb 2 ((p : ℝ) - 2)) := by
  have hppos : (0 : ℝ) < (p : ℝ) := by exact_mod_cast hp.pos
  rw [Ipair_prime hp]
  field_simp
  ring

/-! ## The two-sided quadratic law -/

/-- **Lower bound.**  For every odd prime the channel carries at least `1/(p² log 2)` bits:
the prime-order type channel is never exactly silent. -/
theorem Ipair_prime_lower (hp : p.Prime) (hodd : p ≠ 2) :
    1 / ((p : ℝ) ^ 2 * Real.log 2) ≤ Ipair p := by
  have h3 : 3 ≤ p := by have := hp.two_le; omega
  have hp3 : (3 : ℝ) ≤ (p : ℝ) := by exact_mod_cast h3
  have hppos : (0 : ℝ) < (p : ℝ) := by linarith
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hp1 : (0 : ℝ) < (p : ℝ) - 1 := by linarith
  have hp2 : (0 : ℝ) < (p : ℝ) - 2 := by linarith
  have hA : (1 / (p : ℝ)) / Real.log 2 ≤ Real.logb 2 p - Real.logb 2 ((p : ℝ) - 1) := by
    have h := le_logb_diff (x := (p : ℝ)) (y := (p : ℝ) - 1) hp1 (by linarith)
    have heq : ((p : ℝ) - ((p : ℝ) - 1)) / (p : ℝ) = 1 / (p : ℝ) := by
      norm_num
    rwa [heq] at h
  have hB : Real.logb 2 ((p : ℝ) - 1) - Real.logb 2 ((p : ℝ) - 2)
      ≤ (1 / ((p : ℝ) - 2)) / Real.log 2 := by
    have h := logb_diff_le (x := (p : ℝ) - 1) (y := (p : ℝ) - 2) hp2 (by linarith)
    have heq : (((p : ℝ) - 1) - ((p : ℝ) - 2)) / ((p : ℝ) - 2) = 1 / ((p : ℝ) - 2) := by
      norm_num
    rwa [heq] at h
  have hcoef : (0 : ℝ) ≤ ((p : ℝ) - 1) * ((p : ℝ) - 2) / (p : ℝ) ^ 2 := by positivity
  have hprod : (((p : ℝ) - 1) * ((p : ℝ) - 2) / (p : ℝ) ^ 2) * ((1 / ((p : ℝ) - 2)) / Real.log 2)
      = (((p : ℝ) - 1) / (p : ℝ) ^ 2) / Real.log 2 := by
    field_simp
  have hstep : (((p : ℝ) - 1) * ((p : ℝ) - 2) / (p : ℝ) ^ 2)
      * (Real.logb 2 ((p : ℝ) - 1) - Real.logb 2 ((p : ℝ) - 2))
      ≤ (((p : ℝ) - 1) / (p : ℝ) ^ 2) / Real.log 2 := by
    rw [← hprod]
    exact mul_le_mul_of_nonneg_left hB hcoef
  have hgap : (1 / (p : ℝ)) / Real.log 2 - (((p : ℝ) - 1) / (p : ℝ) ^ 2) / Real.log 2
      = 1 / ((p : ℝ) ^ 2 * Real.log 2) := by
    field_simp
    ring
  have hlogb1 : (0 : ℝ) ≤ Real.logb 2 ((p : ℝ) - 1) / (p : ℝ) ^ 2 := by
    apply div_nonneg _ (by positivity)
    exact Real.logb_nonneg (by norm_num) (by linarith)
  rw [Ipair_prime_split hp]
  linarith [hA, hstep, hgap.le, hgap.ge, hlogb1]

/-- The prime-order channel is strictly positive: never exactly silent. -/
theorem Ipair_prime_pos (hp : p.Prime) : 0 < Ipair p := by
  rcases eq_or_ne p 2 with rfl | hodd
  · rw [Ipair_prime (by norm_num)]
    norm_num
  · have hlow := Ipair_prime_lower hp hodd
    have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
    have hppos : (0 : ℝ) < (p : ℝ) := by exact_mod_cast hp.pos
    have hpos : (0 : ℝ) < 1 / ((p : ℝ) ^ 2 * Real.log 2) := by positivity
    linarith

/-- **Upper bound: quadratic decay.**  For every prime `p`, `I_pair(p) ≤ (log₂ p + 5)/p²`.
Together with `Ipair_prime_lower` this shows that the prime-order type-pair channel decays
like `p^{-2}` up to a logarithmic factor. -/
theorem Ipair_prime_upper_sq (hp : p.Prime) :
    Ipair p ≤ (Real.logb 2 p + 5) / (p : ℝ) ^ 2 := by
  have hlog2 : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  have hlog2pos : (0 : ℝ) < Real.log 2 := by linarith
  rcases eq_or_ne p 2 with rfl | h2
  · rw [Ipair_prime (by norm_num)]
    norm_num
  rcases eq_or_ne p 3 with rfl | h3
  · rw [Ipair_prime (by norm_num)]
    have hub := lb3_upper
    norm_num
    linarith
  have h5 : 5 ≤ p := by
    have hle := hp.two_le
    by_contra hlt
    push_neg at hlt
    interval_cases p
    · exact h2 rfl
    · exact h3 rfl
    · norm_num at hp
  have hp5 : (5 : ℝ) ≤ (p : ℝ) := by exact_mod_cast h5
  have hppos : (0 : ℝ) < (p : ℝ) := by linarith
  have hp1 : (0 : ℝ) < (p : ℝ) - 1 := by linarith
  have hp2 : (0 : ℝ) < (p : ℝ) - 2 := by linarith
  have hA : Real.logb 2 p - Real.logb 2 ((p : ℝ) - 1) ≤ (1 / ((p : ℝ) - 1)) / Real.log 2 := by
    have h := logb_diff_le (x := (p : ℝ)) (y := (p : ℝ) - 1) hp1 (by linarith)
    have heq : ((p : ℝ) - ((p : ℝ) - 1)) / ((p : ℝ) - 1) = 1 / ((p : ℝ) - 1) := by
      norm_num
    rwa [heq] at h
  have hB : (1 / ((p : ℝ) - 1)) / Real.log 2
      ≤ Real.logb 2 ((p : ℝ) - 1) - Real.logb 2 ((p : ℝ) - 2) := by
    have h := le_logb_diff (x := (p : ℝ) - 1) (y := (p : ℝ) - 2) hp2 (by linarith)
    have heq : (((p : ℝ) - 1) - ((p : ℝ) - 2)) / ((p : ℝ) - 1) = 1 / ((p : ℝ) - 1) := by
      norm_num
    rwa [heq] at h
  have hcoef : (0 : ℝ) ≤ ((p : ℝ) - 1) * ((p : ℝ) - 2) / (p : ℝ) ^ 2 := by positivity
  have hprod : (((p : ℝ) - 1) * ((p : ℝ) - 2) / (p : ℝ) ^ 2) * ((1 / ((p : ℝ) - 1)) / Real.log 2)
      = (((p : ℝ) - 2) / (p : ℝ) ^ 2) / Real.log 2 := by
    field_simp
  have hstep : (((p : ℝ) - 2) / (p : ℝ) ^ 2) / Real.log 2
      ≤ (((p : ℝ) - 1) * ((p : ℝ) - 2) / (p : ℝ) ^ 2)
        * (Real.logb 2 ((p : ℝ) - 1) - Real.logb 2 ((p : ℝ) - 2)) := by
    rw [← hprod]
    exact mul_le_mul_of_nonneg_left hB hcoef
  have hmono : Real.logb 2 ((p : ℝ) - 1) ≤ Real.logb 2 p :=
    Real.logb_le_logb_of_le (by norm_num) (by linarith) (by linarith)
  have hcombine : (1 / ((p : ℝ) - 1)) / Real.log 2 - (((p : ℝ) - 2) / (p : ℝ) ^ 2) / Real.log 2
      ≤ 5 / (p : ℝ) ^ 2 := by
    have heq : (1 / ((p : ℝ) - 1)) / Real.log 2 - (((p : ℝ) - 2) / (p : ℝ) ^ 2) / Real.log 2
        = (3 * (p : ℝ) - 2) / ((p : ℝ) ^ 2 * ((p : ℝ) - 1) * Real.log 2) := by
      field_simp
      ring
    rw [heq, div_le_div_iff₀ (by positivity) (by positivity)]
    have hmul : ((p : ℝ) - 1) * 0.6931471803 ≤ ((p : ℝ) - 1) * Real.log 2 := by nlinarith
    have hkey : 3 * (p : ℝ) - 2 ≤ 5 * (((p : ℝ) - 1) * Real.log 2) := by linarith
    have hsq : (0 : ℝ) ≤ (p : ℝ) ^ 2 := by positivity
    nlinarith [mul_le_mul_of_nonneg_left hkey hsq]
  have hsplit : Real.logb 2 ((p : ℝ) - 1) / (p : ℝ) ^ 2 ≤ Real.logb 2 p / (p : ℝ) ^ 2 :=
    (div_le_div_iff_of_pos_right (by positivity)).2 hmono
  rw [Ipair_prime_split hp, show (Real.logb 2 p + 5) / (p : ℝ) ^ 2
    = Real.logb 2 p / (p : ℝ) ^ 2 + 5 / (p : ℝ) ^ 2 by ring]
  linarith [hA, hstep, hcombine, hsplit]

end CyclicType