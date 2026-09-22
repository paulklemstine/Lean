import Computation.CyclicTypeDeterminism
import Computation.ReproducibilityAudit

/-!
# From a four-row record to a law: the 2-adic tower of type entropies

The recorded type-entropy rows for the cyclic 2-groups are
`HT 2 = 1`, `HT 4 = 3/2`, `HT 8 = 7/4`, `HT 16 = 15/8`.
An audit can only confirm that these four numbers re-run to themselves.  This file replaces the
four data points by a theorem covering the whole tower:

* `CyclicType.Audit.HT_two_pow` : `H(T) (ℤ/2^k) = 2 - 2^{1-k}` for every `k`, proved from the
  Euler-φ entropy law `CyclicType.HT_divisor_formula` together with the closed form
  `Σ_{i<k} i·2^i = (k-2)2^k + 2`;
* `CyclicType.Audit.HT_two_pow_recorded` : the four stored rows are exactly the `k = 1,2,3,4`
  instances of the law — the audit's consistency check, now a proof;
* `CyclicType.Audit.HT_two_pow_strictMono`, `CyclicType.Audit.HT_two_pow_lt_two`,
  `CyclicType.Audit.HT_two_pow_tendsto` : the tower is strictly increasing, stays below `2` bits
  and converges to `2` — the 2-adic type channel has a hard two-bit ceiling;
* `CyclicType.Audit.HT_two_pow_certified` : because `HT (2^k) = (2^k-1)/2^{k-1}` is dyadic with a
  small denominator, for `k ≤ 7` a four-decimal re-run agreeing with the record *proves* exact
  reproduction, via `CyclicType.Audit.eq_of_agree_four_decimals`.

This is the strongest form of the audit's verdict for this family: the record is not merely
re-runnable, it is a specialisation of a closed-form law.
-/

namespace CyclicType.Audit

open scoped BigOperators

/-- The arithmetic-geometric sum `Σ_{i<k} i·2^i = (k-2)·2^k + 2`. -/
lemma sum_range_mul_two_pow (k : ℕ) :
    ∑ i ∈ Finset.range k, (i : ℝ) * 2 ^ i = ((k : ℝ) - 2) * 2 ^ k + 2 := by
  induction k with
  | zero => simp
  | succ m ih =>
      rw [Finset.sum_range_succ, ih]
      push_cast
      ring

/-- The Euler-φ weighted log-sum over the divisors of `2^k`. -/
lemma totient_logb_sum_two_pow (k : ℕ) :
    ∑ d ∈ ((2 : ℕ) ^ k).divisors, (Nat.totient d : ℝ) * Real.logb 2 (Nat.totient d)
      = ((k : ℝ) - 2) * 2 ^ k + 2 := by
  rw [Nat.sum_divisors_prime_pow (by norm_num : Nat.Prime 2)]
  rw [Finset.sum_range_succ']
  have hzero : (Nat.totient ((2 : ℕ) ^ 0) : ℝ) * Real.logb 2 (Nat.totient ((2 : ℕ) ^ 0)) = 0 := by
    norm_num
  have hstep : ∀ i ∈ Finset.range k,
      (Nat.totient ((2 : ℕ) ^ (i + 1)) : ℝ) * Real.logb 2 (Nat.totient ((2 : ℕ) ^ (i + 1)))
        = (i : ℝ) * 2 ^ i := by
    intro i _
    have hphi : Nat.totient ((2 : ℕ) ^ (i + 1)) = 2 ^ i := by
      rw [Nat.totient_prime_pow (by norm_num : Nat.Prime 2) (Nat.succ_pos i)]
      simp
    rw [hphi]
    have : Real.logb 2 (((2 : ℕ) ^ i : ℕ) : ℝ) = (i : ℝ) := by
      push_cast
      rw [Real.logb_pow, Real.logb_self_eq_one (by norm_num : (1 : ℝ) < 2)]
      ring
    rw [this]
    push_cast
    ring
  rw [Finset.sum_congr rfl hstep, hzero, sum_range_mul_two_pow k]
  ring

/-- **The 2-adic entropy law.**  For every `k ≥ 1` the type entropy of the cyclic group of order
`2^k` is `2 - 2^{1-k}`.  The four recorded rows are the cases `k = 1,2,3,4`. -/
theorem HT_two_pow (k : ℕ) : HT (2 ^ k) = 2 - 2 / 2 ^ k := by
  have hn : 0 < (2 : ℕ) ^ k := Nat.two_pow_pos k
  have hpow : (0 : ℝ) < 2 ^ k := by positivity
  have hlog : Real.logb 2 (((2 : ℕ) ^ k : ℕ) : ℝ) = (k : ℝ) := by
    push_cast
    rw [Real.logb_pow, Real.logb_self_eq_one (by norm_num : (1 : ℝ) < 2)]
    ring
  rw [HT_divisor_formula hn, hlog, totient_logb_sum_two_pow k]
  have hcast : (((2 : ℕ) ^ k : ℕ) : ℝ) = 2 ^ k := by push_cast; ring
  rw [hcast]
  field_simp
  ring

/-- **Audit consistency.**  The four stored rows of the 2-adic tower are precisely the law's
values at `k = 1, 2, 3, 4`; re-deriving them from the law reproduces the record exactly. -/
theorem HT_two_pow_recorded :
    HT 2 = 2 - 2 / 2 ^ 1 ∧ HT 4 = 2 - 2 / 2 ^ 2 ∧ HT 8 = 2 - 2 / 2 ^ 3
      ∧ HT 16 = 2 - 2 / 2 ^ 4 := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · have := HT_two_pow 1; norm_num at this ⊢; exact this
  · have := HT_two_pow 2; norm_num at this ⊢; exact this
  · have := HT_two_pow 3; norm_num at this ⊢; exact this
  · have := HT_two_pow 4; norm_num at this ⊢; exact this

/-- The 2-adic tower of type entropies is strictly increasing. -/
theorem HT_two_pow_strictMono (k : ℕ) : HT (2 ^ k) < HT (2 ^ (k + 1)) := by
  rw [HT_two_pow k, HT_two_pow (k + 1)]
  have hpow : (0 : ℝ) < 2 ^ k := by positivity
  have : (2 : ℝ) ^ (k + 1) = 2 * 2 ^ k := by ring
  rw [this]
  have h1 : (2 : ℝ) / (2 * 2 ^ k) < 2 / 2 ^ k := by
    apply div_lt_div_of_pos_left (by norm_num) hpow
    linarith
  linarith

/-- The tower never reaches two bits. -/
theorem HT_two_pow_lt_two (k : ℕ) : HT (2 ^ k) < 2 := by
  rw [HT_two_pow k]
  have hpow : (0 : ℝ) < 2 ^ k := by positivity
  have : (0 : ℝ) < 2 / 2 ^ k := by positivity
  linarith

/-- **The two-bit ceiling.**  The 2-adic type entropies converge to exactly `2` bits. -/
theorem HT_two_pow_tendsto :
    Filter.Tendsto (fun k : ℕ => 2 - 2 / (2 : ℝ) ^ k) Filter.atTop (nhds 2) := by
  have h : Filter.Tendsto (fun k : ℕ => (2 : ℝ) / 2 ^ k) Filter.atTop (nhds 0) := by
    have hbase : Filter.Tendsto (fun k : ℕ => ((1 : ℝ) / 2) ^ k) Filter.atTop (nhds 0) :=
      tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num) (by norm_num)
    have heq : (fun k : ℕ => (2 : ℝ) / 2 ^ k) = fun k : ℕ => 2 * ((1 : ℝ) / 2) ^ k := by
      funext k
      rw [div_pow, one_pow]
      ring
    rw [heq]
    simpa using hbase.const_mul (2 : ℝ)
  simpa using (tendsto_const_nhds (x := (2 : ℝ)) (f := Filter.atTop (α := ℕ))).sub h

/-- The law exhibits `HT (2^k)` as a dyadic rational with denominator `2^{k-1}`. -/
theorem HT_two_pow_as_fraction {k : ℕ} (hk : 1 ≤ k) :
    HT (2 ^ k) = ((2 ^ k - 1 : ℤ) : ℝ) / ((2 ^ (k - 1) : ℕ) : ℝ) := by
  obtain ⟨m, rfl⟩ : ∃ m, k = m + 1 := ⟨k - 1, by omega⟩
  rw [HT_two_pow (m + 1)]
  have hpow : (0 : ℝ) < 2 ^ m := by positivity
  push_cast
  field_simp
  ring

/-- **Certified reproduction for the whole low tower.**  For `1 ≤ k ≤ 7` the recorded entropy has
denominator at most `64`, so a re-run value that is a rational with denominator at most `70` and
agrees to four decimals is *exactly* `HT (2^k)`. -/
theorem HT_two_pow_certified {k : ℕ} (hk : 1 ≤ k) (hk7 : k ≤ 7) (b : ℤ) (r : ℕ)
    (hr : 0 < r) (hr' : r ≤ 70) (h : |(b : ℝ) / r - HT (2 ^ k)| < 1 / 10000) :
    (b : ℝ) / r = HT (2 ^ k) := by
  refine certified_of_record (2 ^ k - 1 : ℤ) b (2 ^ (k - 1)) r ?_ ?_ hr hr' ?_ h
  · exact Nat.two_pow_pos _
  · interval_cases k <;> norm_num
  · exact HT_two_pow_as_fraction hk

/-! ## Gap certification: structure beats denominator size -/

/-- **Gap estimate for the tower.**  Two distinct rows of the 2-adic tower are separated by at
least `2^{-j}`, where `2^j` is the *smaller* order. -/
theorem HT_two_pow_gap {j k : ℕ} (hjk : j < k) :
    (1 : ℝ) / 2 ^ j ≤ HT (2 ^ k) - HT (2 ^ j) := by
  rw [HT_two_pow k, HT_two_pow j]
  have hj : (0 : ℝ) < 2 ^ j := by positivity
  have hstep : (2 : ℝ) ^ (j + 1) ≤ 2 ^ k := pow_le_pow_right₀ (by norm_num) (by omega)
  have hle : (2 : ℝ) / 2 ^ k ≤ 2 / 2 ^ (j + 1) :=
    div_le_div_of_nonneg_left (by norm_num) (by positivity) hstep
  have hhalf : (2 : ℝ) / 2 ^ (j + 1) = 1 / 2 ^ j := by
    rw [pow_succ]
    field_simp
  rw [hhalf] at hle
  have htwo : (2 : ℝ) / 2 ^ j = 2 * (1 / 2 ^ j) := by ring
  rw [htwo]
  linarith

/-- **Isolation of the recorded rows.**  A member of the tower that agrees with the recorded
`HT (2^k)` to better than `2^{-k}` *is* that row. -/
theorem HT_two_pow_isolated {j k : ℕ} (h : |HT (2 ^ j) - HT (2 ^ k)| < 1 / 2 ^ k) : j = k := by
  by_contra hne
  have habs := abs_lt.mp h
  rcases lt_or_gt_of_ne hne with hlt | hgt
  · have hgap := HT_two_pow_gap hlt
    have hmono : (1 : ℝ) / 2 ^ k ≤ 1 / 2 ^ j :=
      one_div_le_one_div_of_le (by positivity) (pow_le_pow_right₀ (by norm_num) (by omega))
    linarith [habs.1]
  · have hgap := HT_two_pow_gap hgt
    linarith [habs.2]

/-- **Gap-based four-decimal certification.**  Because the rows of the tower are `2^{-k}` apart, a
four-decimal record identifies the row for every `k ≤ 13` — far beyond the generic
denominator bound of `CyclicType.Audit.eq_of_agree_four_decimals`. -/
theorem HT_two_pow_certified_gap {j k : ℕ} (hk : k ≤ 13)
    (h : |HT (2 ^ j) - HT (2 ^ k)| < 1 / 10000) : j = k := by
  refine HT_two_pow_isolated (lt_of_lt_of_le h ?_)
  have hpow : (2 : ℝ) ^ k ≤ 2 ^ 13 := pow_le_pow_right₀ (by norm_num) hk
  have hbound : (2 : ℝ) ^ k ≤ 10000 := by
    norm_num at hpow
    linarith
  exact one_div_le_one_div_of_le (by positivity) hbound

end CyclicType.Audit