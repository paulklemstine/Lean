import Cryptography.DegreeTenCyclotomic.Semiprime

/-!
# Certified numerics for the degree-ten channels

Rigorous enclosures of `log₂ 5` and `log₂ 3` from integer power comparisons, giving
`1.7219 < I(p mod 11 ; T) < 1.72193`, `|I(N mod 11 ; pair) − 1.2027| < 3·10⁻⁵`, and the exact
semiprime attenuation `32/25 − (12/25) log₂ 3`.
-/

namespace DegreeTen

open TypeChannel Finset Real

/-- Lower bounds on `log₂ a` from integer power comparisons `2^m < a^n`. -/
lemma lt_logb_of_pow_lt {a m n : ℕ} (hn : 0 < n) (h : 2 ^ m < a ^ n) :
    (m : ℝ) / n < logb 2 a := by
  have ha : (0 : ℝ) < a := by
    rcases Nat.eq_zero_or_pos a with rfl | ha
    · simp [zero_pow hn.ne'] at h
    · exact_mod_cast ha
  have h' : ((2 : ℝ) ^ m) < (a : ℝ) ^ n := by exact_mod_cast h
  have hlog := Real.logb_lt_logb (b := 2) (by norm_num) (by positivity) h'
  rw [Real.logb_pow, Real.logb_pow, Real.logb_self_eq_one (by norm_num), mul_one] at hlog
  rw [div_lt_iff₀ (by exact_mod_cast hn)]
  linarith

/-- Upper bounds on `log₂ a` from integer power comparisons `a^n < 2^m`. -/
lemma logb_lt_of_pow_lt {a m n : ℕ} (hn : 0 < n) (ha : 0 < a) (h : a ^ n < 2 ^ m) :
    logb 2 a < (m : ℝ) / n := by
  have ha' : (0 : ℝ) < a := by exact_mod_cast ha
  have h' : (a : ℝ) ^ n < (2 : ℝ) ^ m := by exact_mod_cast h
  have hlog := Real.logb_lt_logb (b := 2) (by norm_num) (by positivity) h'
  rw [Real.logb_pow, Real.logb_pow, Real.logb_self_eq_one (by norm_num), mul_one] at hlog
  rw [lt_div_iff₀ (by exact_mod_cast hn)]
  linarith

lemma logb2_five_bounds : 23219 / 10000 < logb 2 (5:ℝ) ∧ logb 2 (5:ℝ) < 232193 / 100000 := by
  constructor
  · have := lt_logb_of_pow_lt (a := 5) (m := 23219) (n := 10000) (by norm_num)
      (by decide +kernel)
    exact_mod_cast this
  · have := logb_lt_of_pow_lt (a := 5) (m := 232193) (n := 100000) (by norm_num) (by norm_num)
      (by decide +kernel)
    exact_mod_cast this

lemma logb2_three_bounds :
    158496 / 100000 < logb 2 (3:ℝ) ∧ logb 2 (3:ℝ) < 158497 / 100000 := by
  constructor
  · have := lt_logb_of_pow_lt (a := 3) (m := 158496) (n := 100000) (by norm_num)
      (by decide +kernel)
    exact_mod_cast this
  · have := logb_lt_of_pow_lt (a := 3) (m := 158497) (n := 100000) (by norm_num) (by norm_num)
      (by decide +kernel)
    exact_mod_cast this

/-- The headline number: `1.7219 < I(p mod 11 ; T) = H(T) < 1.72193`. -/
theorem deg10_channel_numeric :
    1.7219 < mutualInfo (univ : Finset U11) resid frobType ∧
      mutualInfo (univ : Finset U11) resid frobType < 1.72193 := by
  rw [deg10_full_pinning.2]
  obtain ⟨h1, h2⟩ := logb2_five_bounds
  constructor <;> norm_num <;> linarith

/-- **The paper-78 anchor is the exact law**: `|I(N mod 11 ; pair) − 1.2027| < 3·10⁻⁵`, and the
exact law strictly exceeds the "fresh enumeration" value `1.1999` (and the measured `1.2002`):
the enumeration figure is a finite-sample estimate, not the law. -/
theorem semi_channel_numeric :
    1.20268 < mutualInfo SP semiN semiPair ∧ mutualInfo SP semiN semiPair < 1.20272 ∧
      |mutualInfo SP semiN semiPair - 1.2027| < 0.00003 ∧
      1.2002 < mutualInfo SP semiN semiPair := by
  rw [semi_channel]
  obtain ⟨h1, h2⟩ := logb2_five_bounds
  obtain ⟨h3, h4⟩ := logb2_three_bounds
  refine ⟨by norm_num; linarith, by norm_num; linarith, ?_, by norm_num; linarith⟩
  rw [abs_lt]; constructor <;> norm_num <;> linarith

/-- **Semiprime attenuation**: at degree ten the semiprime channel is strictly weaker than
the single-prime channel, by exactly `32/25 − (12/25) log₂ 3 ≈ 0.519` bits. -/
theorem semi_lt_single :
    mutualInfo SP semiN semiPair < mutualInfo (univ : Finset U11) resid frobType ∧
      mutualInfo (univ : Finset U11) resid frobType - mutualInfo SP semiN semiPair
        = 32/25 - 12/25 * logb 2 3 := by
  rw [semi_channel, deg10_full_pinning.2]
  obtain ⟨h3, h4⟩ := logb2_three_bounds
  constructor
  · linarith
  · ring

end DegreeTen