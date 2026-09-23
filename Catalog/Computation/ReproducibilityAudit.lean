import Computation.CyclicTypeChannelValues

/-!
# Reproducibility audit: when does a rounded record certify an exact value?

A reproducibility audit compares a *recorded* headline number with the value produced by a
fresh re-run of the same pipeline and declares "identical to four decimals".  This file asks
the mathematical question hiding behind that practice: **when does agreement of two records to
`k` decimals actually force the two numbers to be equal?**

The answer splits the recorded quantities of the cyclic splitting-type channel
(`Catalog.Computation.CyclicTypeChannel`) into two strata.

* **Rational stratum (certifiable).**  Two rationals with denominators bounded by `Q` are either
  equal or at least `1/Q²` apart (`Audit.eq_of_close_rat`).  Hence for `Q ≤ 70` a four-decimal
  agreement *proves* bit-for-bit equality (`Audit.eq_of_agree_four_decimals`), and the dyadic
  keystones `Ipair 4 = 5/4`, `Ipair 8 = 21/16`, `Ipair 16 = 85/64` are certified by their
  rounded records alone (`Audit.Ipair_eight_certified` and friends).
  The denominator bound is essentially sharp: `1/100` and `1/101` agree to four decimals
  (`Audit.four_decimal_certificate_sharp`).

* **Irrational stratum (not certifiable).**  `Ipair 6 = log₂ 3 - 1/9` is irrational
  (`Audit.irrational_logb_two_three`, `Audit.irrational_Ipair_six`), so *no* rounded record and
  no rational re-run value can ever equal it: agreement to any number of decimals is evidence of
  the pipeline being deterministic, never a proof of the value.  What is reproducible there is the
  closed form, together with the explicit enclosure
  `1.58496 < log₂ 3 < 1.58497` (`Audit.logb_two_three_bounds`) obtained from the convergents
  `2^1054 < 3^665` and `3^306 < 2^485`, which pins the record `Ipair 6 ≈ 1.4738`
  (`Audit.Ipair_six_matches_record`).

The moral of the audit: *four-decimal agreement is a theorem about bounded denominators, not
about pipelines.*
-/

namespace CyclicType.Audit

open Real

/-! ## 1. The rational stratum: rounding certificates -/

/-- **Separation of bounded-denominator rationals.**  Two rationals `a/q` and `b/r` that are
closer than `1/(q·r)` are equal.  This is the exact statement that underlies every
"identical to `k` decimals" audit verdict. -/
theorem eq_of_close_rat (a b : ℤ) (q r : ℕ) (hq : 0 < q) (hr : 0 < r)
    (h : |(a : ℝ) / q - (b : ℝ) / r| < 1 / ((q : ℝ) * r)) :
    (a : ℝ) / q = (b : ℝ) / r := by
  have hq0 : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq
  have hr0 : (0 : ℝ) < (r : ℝ) := by exact_mod_cast hr
  have hrewrite : ((a * r - b * q : ℤ) : ℝ) = ((a : ℝ) / q - (b : ℝ) / r) * ((q : ℝ) * r) := by
    push_cast
    field_simp
  have key : |((a * r - b * q : ℤ) : ℝ)| < 1 := by
    rw [hrewrite, abs_mul, abs_of_pos (by positivity : (0 : ℝ) < (q : ℝ) * r)]
    have := mul_lt_mul_of_pos_right h (by positivity : (0 : ℝ) < (q : ℝ) * r)
    calc |(a : ℝ) / q - (b : ℝ) / r| * ((q : ℝ) * r)
        < 1 / ((q : ℝ) * r) * ((q : ℝ) * r) := this
      _ = 1 := by field_simp
  have hab : a * r = b * q := by
    have habs : |a * r - b * q| < 1 := by exact_mod_cast key
    have := abs_lt.mp habs
    omega
  rw [div_eq_div_iff (ne_of_gt hq0) (ne_of_gt hr0)]
  exact_mod_cast hab

/-- **The separation bound is attained.**  The strict inequality in `eq_of_close_rat` cannot be
weakened to `≤`: for every denominator bound `Q ≥ 1` the distinct rationals `1/Q` and `0/1` are
exactly `1/(Q·1)` apart. -/
theorem eq_of_close_rat_sharp (Q : ℕ) (hQ : 0 < Q) :
    |((1 : ℤ) : ℝ) / Q - ((0 : ℤ) : ℝ) / 1| = 1 / ((Q : ℝ) * 1)
      ∧ ((1 : ℤ) : ℝ) / Q ≠ ((0 : ℤ) : ℝ) / 1 := by
  have hQ0 : (0 : ℝ) < (Q : ℝ) := by exact_mod_cast hQ
  constructor
  · have hval : ((1 : ℤ) : ℝ) / Q - ((0 : ℤ) : ℝ) / 1 = 1 / (Q : ℝ) := by
      push_cast
      ring
    rw [hval, abs_of_pos (by positivity)]
    field_simp
  · have hval : ((1 : ℤ) : ℝ) / Q - ((0 : ℤ) : ℝ) / 1 = 1 / (Q : ℝ) := by
      push_cast
      ring
    intro hcon
    have hzero : (1 : ℝ) / (Q : ℝ) = 0 := by
      rw [← hval, hcon]
      norm_num
    have hpos : (0 : ℝ) < 1 / (Q : ℝ) := by positivity
    linarith

/-- **General precision certificate.**  Two rationals whose denominators are bounded by `Q` and
which agree to within `1/Q²` are equal.  The precision `1/Q²` is the natural resolution of the
Farey dissection at level `Q`. -/
theorem eq_of_agree_of_den_le {Q : ℕ} (a b : ℤ) (q r : ℕ) (hq : 0 < q) (hq' : q ≤ Q)
    (hr : 0 < r) (hr' : r ≤ Q) (h : |(a : ℝ) / q - (b : ℝ) / r| < 1 / (Q : ℝ) ^ 2) :
    (a : ℝ) / q = (b : ℝ) / r := by
  have hq0 : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq
  have hr0 : (0 : ℝ) < (r : ℝ) := by exact_mod_cast hr
  have hqR : (q : ℝ) ≤ (Q : ℝ) := by exact_mod_cast hq'
  have hrR : (r : ℝ) ≤ (Q : ℝ) := by exact_mod_cast hr'
  refine eq_of_close_rat a b q r hq hr (lt_of_lt_of_le h ?_)
  have hprod : (q : ℝ) * r ≤ (Q : ℝ) ^ 2 := by nlinarith
  exact one_div_le_one_div_of_le (by positivity) hprod

/-- **Four-decimal certificate.**  If the recorded value and the re-run value are rationals with
denominators at most `70`, then agreeing to within `10⁻⁴` forces them to be *exactly* equal. -/
theorem eq_of_agree_four_decimals (a b : ℤ) (q r : ℕ) (hq : 0 < q) (hq' : q ≤ 70)
    (hr : 0 < r) (hr' : r ≤ 70) (h : |(a : ℝ) / q - (b : ℝ) / r| < 1 / 10000) :
    (a : ℝ) / q = (b : ℝ) / r := by
  refine eq_of_agree_of_den_le (Q := 70) a b q r hq hq' hr hr' (lt_of_lt_of_le h ?_)
  norm_num

/-- **Sharpness of the denominator bound.**  With denominators `100` and `101` the four-decimal
certificate already fails: `1/100` and `1/101` agree to four decimals but are distinct.  So the
bound `70` in `eq_of_agree_four_decimals` cannot be relaxed past `100`. -/
theorem four_decimal_certificate_sharp :
    |(1 : ℝ) / 100 - 1 / 101| < 1 / 10000 ∧ (1 : ℝ) / 100 ≠ 1 / 101 := by
  constructor
  · rw [abs_of_pos (by norm_num)]
    norm_num
  · norm_num

/-! ## 2. Certified keystones of the type-channel record -/

/-- Auxiliary form of the certificate for a *recorded* value presented as a rational. -/
theorem certified_of_record {v : ℝ} (a b : ℤ) (q r : ℕ) (hq : 0 < q) (hq' : q ≤ 70)
    (hr : 0 < r) (hr' : r ≤ 70) (hv : v = (a : ℝ) / q)
    (h : |(b : ℝ) / r - v| < 1 / 10000) : (b : ℝ) / r = v := by
  subst hv
  exact (eq_of_agree_four_decimals a b q r hq hq' hr hr' (by rwa [abs_sub_comm] at h)).symm

/-- **Keystone 1 (paper-80 row `C₄`-type entry).**  Any re-run value that is a rational with
denominator at most `70` and lands within `10⁻⁴` of the recorded `Ipair 4 = 1.2500` *is*
`Ipair 4`. -/
theorem Ipair_four_certified (b : ℤ) (r : ℕ) (hr : 0 < r) (hr' : r ≤ 70)
    (h : |(b : ℝ) / r - Ipair 4| < 1 / 10000) : (b : ℝ) / r = Ipair 4 :=
  certified_of_record 5 b 4 r (by norm_num) (by norm_num) hr hr'
    (by rw [Ipair_four]; norm_num) h

/-- **Keystone 2.**  The recorded `Ipair 8 = 1.3125` is certified by four-decimal agreement. -/
theorem Ipair_eight_certified (b : ℤ) (r : ℕ) (hr : 0 < r) (hr' : r ≤ 70)
    (h : |(b : ℝ) / r - Ipair 8| < 1 / 10000) : (b : ℝ) / r = Ipair 8 :=
  certified_of_record 21 b 16 r (by norm_num) (by norm_num) hr hr'
    (by rw [Ipair_eight]; norm_num) h

/-- **Keystone 3.**  The recorded `Ipair 16 = 1.328125` is certified by four-decimal agreement;
here the denominator `64` is within a hair of the sharpness threshold. -/
theorem Ipair_sixteen_certified (b : ℤ) (r : ℕ) (hr : 0 < r) (hr' : r ≤ 70)
    (h : |(b : ℝ) / r - Ipair 16| < 1 / 10000) : (b : ℝ) / r = Ipair 16 :=
  certified_of_record 85 b 64 r (by norm_num) (by norm_num) hr hr'
    (by rw [Ipair_sixteen]; norm_num) h

/-- **Keystone 4 (type entropy).**  `HT 4 = 1.5000` is certified as well. -/
theorem HT_four_certified (b : ℤ) (r : ℕ) (hr : 0 < r) (hr' : r ≤ 70)
    (h : |(b : ℝ) / r - HT 4| < 1 / 10000) : (b : ℝ) / r = HT 4 :=
  certified_of_record 3 b 2 r (by norm_num) (by norm_num) hr hr'
    (by rw [HT_four]; norm_num) h

/-! ## 3. The irrational stratum: no record can certify `Ipair 6` -/

/-- Comparing integer powers gives lower bounds on `log₂ 3`. -/
theorem logb_two_three_gt {p q : ℕ} (hq : 0 < q) (h : (2 : ℕ) ^ p < 3 ^ q) :
    (p : ℝ) / q < Real.logb 2 3 := by
  have hq0 : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq
  have hR : ((2 : ℝ)) ^ p < (3 : ℝ) ^ q := by exact_mod_cast h
  have hlt : Real.logb 2 ((2 : ℝ) ^ p) < Real.logb 2 ((3 : ℝ) ^ q) :=
    Real.logb_lt_logb (by norm_num) (by positivity) hR
  rw [Real.logb_pow, Real.logb_pow, Real.logb_self_eq_one (by norm_num : (1:ℝ) < 2)] at hlt
  rw [div_lt_iff₀ hq0]
  nlinarith

/-- Comparing integer powers gives upper bounds on `log₂ 3`. -/
theorem logb_two_three_lt {p q : ℕ} (hq : 0 < q) (h : (3 : ℕ) ^ q < 2 ^ p) :
    Real.logb 2 3 < (p : ℝ) / q := by
  have hq0 : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq
  have hR : ((3 : ℝ)) ^ q < (2 : ℝ) ^ p := by exact_mod_cast h
  have hlt : Real.logb 2 ((3 : ℝ) ^ q) < Real.logb 2 ((2 : ℝ) ^ p) :=
    Real.logb_lt_logb (by norm_num) (by positivity) hR
  rw [Real.logb_pow, Real.logb_pow, Real.logb_self_eq_one (by norm_num : (1:ℝ) < 2)] at hlt
  rw [lt_div_iff₀ hq0]
  nlinarith

/-- **Four-decimal enclosure of `log₂ 3`** from the continued-fraction convergents
`1054/665` and `485/306`, verified as the integer inequalities `2^1054 < 3^665` and
`3^306 < 2^485`. -/
theorem logb_two_three_bounds :
    (158496 : ℝ) / 100000 < Real.logb 2 3 ∧ Real.logb 2 3 < (158497 : ℝ) / 100000 := by
  constructor
  · have hlow : (1054 : ℝ) / 665 < Real.logb 2 3 := by
      have := logb_two_three_gt (p := 1054) (q := 665) (by norm_num) (by decide +kernel)
      simpa using this
    have : (158496 : ℝ) / 100000 < (1054 : ℝ) / 665 := by norm_num
    linarith
  · have hhigh : Real.logb 2 3 < (485 : ℝ) / 306 := by
      have := logb_two_three_lt (p := 485) (q := 306) (by norm_num) (by decide +kernel)
      simpa using this
    have : (485 : ℝ) / 306 < (158497 : ℝ) / 100000 := by norm_num
    linarith

/-- No quotient of naturals equals `log₂ 3`: such an equality would force `2^m = 3^q`, which
is impossible because `3` divides the right side but not the left. -/
theorem logb_two_three_ne_nat_div (m q : ℕ) (hq : 0 < q) : Real.logb 2 3 ≠ (m : ℝ) / q := by
  intro h
  have h1 : ¬ ((2 : ℕ) ^ m < 3 ^ q) := by
    intro hlt
    have := logb_two_three_gt (p := m) (q := q) hq hlt
    rw [← h] at this
    exact lt_irrefl _ this
  have h2 : ¬ ((3 : ℕ) ^ q < 2 ^ m) := by
    intro hlt
    have := logb_two_three_lt (p := m) (q := q) hq hlt
    rw [← h] at this
    exact lt_irrefl _ this
  have heq : (2 : ℕ) ^ m = 3 ^ q := le_antisymm (not_lt.mp h2) (not_lt.mp h1)
  have hdvd : (3 : ℕ) ∣ 2 ^ m := by
    rw [heq]
    exact dvd_pow_self 3 hq.ne'
  have := (Nat.Prime.dvd_of_dvd_pow (by norm_num) hdvd)
  omega

/-- **`log₂ 3` is irrational.**  Consequently no rounded record, of any precision, can *equal*
a channel value living in this stratum: reproducibility there is a statement about the closed
form, not about digits. -/
theorem irrational_logb_two_three : Irrational (Real.logb 2 3) := by
  rintro ⟨r, hr⟩
  have hpos : 0 < Real.logb 2 3 := Real.logb_pos (by norm_num) (by norm_num)
  have hrpos : 0 < r := by
    have : (0 : ℝ) < (r : ℝ) := by rw [hr]; exact hpos
    exact_mod_cast this
  have hnum : 0 < r.num := Rat.num_pos.mpr hrpos
  have hden : 0 < r.den := r.pos
  have hcast : ((r.num.toNat : ℕ) : ℝ) / (r.den : ℕ) = (r : ℝ) := by
    rw [Rat.cast_def]
    congr 1
    exact_mod_cast congrArg (fun z : ℤ => (z : ℝ)) (Int.toNat_of_nonneg hnum.le)
  exact logb_two_three_ne_nat_div r.num.toNat r.den hden (by rw [hcast, hr])

/-- **The irrational stratum.**  The recorded keystone `Ipair 6 = log₂ 3 - 1/9` is irrational. -/
theorem irrational_Ipair_six : Irrational (Ipair 6) := by
  rw [Ipair_six]
  have := irrational_logb_two_three.ratCast_add (-(1 / 9) : ℚ)
  simpa using this

/-- **No rational re-run value reproduces `Ipair 6`.**  Whatever the precision of the record,
the stored decimal is never the value itself. -/
theorem Ipair_six_ne_rat (a : ℤ) (q : ℕ) : Ipair 6 ≠ (a : ℝ) / q := by
  intro h
  refine irrational_Ipair_six ⟨(a : ℚ) / (q : ℚ), ?_⟩
  rw [h]
  push_cast
  ring

/-- **What the record does pin down.**  Even in the irrational stratum the audit is meaningful:
the stored four-decimal value `1.4738` encloses `Ipair 6` to within `10⁻⁴`. -/
theorem Ipair_six_matches_record : |Ipair 6 - 14738 / 10000| < 1 / 10000 := by
  obtain ⟨hlo, hhi⟩ := logb_two_three_bounds
  rw [Ipair_six, abs_lt]
  constructor <;> linarith

end CyclicType.Audit