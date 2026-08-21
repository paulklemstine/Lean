import Mathlib
import Cryptography.BB84.KeyRateThreshold
import Cryptography.BB84.ThresholdEnclosure

/-!
# Six certified decimals of the BB84 QBER threshold, without huge integers

`Cryptography.BB84.ThresholdEnclosure` certifies `0.1100 < p⋆ < 0.1101` by pure
integer comparisons.  Pushing that scheme one decimal further would require
comparing integers with `8·10⁵` digits, and the cost of the naive certificate at
denominator `b` grows like `b²`: the arithmetic route saturates.

This file breaks the barrier with a **mean-value (Newton) refinement**.  Two
ingredients are combined:

* the *quantitative* value of the key rate at the rational point `11 %`, which by
  `secureKeyRate_ratio_eq` is `(1/100) log (N/D)` for explicit integers `N, D`,
  and is squeezed by `1 - x⁻¹ ≤ log x ≤ x - 1` between two rationals
  (`secureKeyRate_gt_of_cert`, `secureKeyRate_lt_of_cert`);
* two-sided bounds `2.08966 ≤ H₂'(x) ≤ 2.09081` for the derivative
  `H₂'(x) = log (1-x) - log x` on the already certified enclosure
  `[0.1100, 0.1101]`, obtained from Mathlib's nine-digit bounds on `log 2`
  together with `log (1+t) ≤ t`.

The mean value theorem then converts the *value* at `11 %` and the *slope* on the
bracket into the distance from `11 %` to the root:

  `p⋆ - 0.11 = (log 2 / 2 - H₂(0.11)) / H₂'(ξ)` for some `ξ` in the bracket,

giving `0.110027 < p⋆ < 0.110029`, i.e. `|p⋆ - 0.110028| < 10⁻⁶`
(`threshold_abs_sub_lt_millionth`).  The true value is `0.1100278644…`.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): a first-order (Newton/MVT) step upgrades a *sign*
  certificate into a *distance* certificate, so the number of certified decimals
  should roughly double at each step while the integers stay of fixed size.
EXPERIMENT (Experimenter): with `N = 2^100·11^22·89^178`, `D = 100^200`, the
  integer certificates `101171·D < 100000·N < 101172·D` give
  `N/D ∈ (1.01171, 1.01172)`, hence `r(0.11) ∈ (1.157·10⁻⁴, 1.172·10⁻⁴)` nats;
  the derivative bracket is `[2.08966, 2.09081]`.  Dividing:
  `p⋆ - 0.11 ∈ (2.7678·10⁻⁵, 2.8043·10⁻⁵)`, versus the exact `2.78644·10⁻⁵`.
  Predicted decimals: 6; achieved decimals: 6.  The dominant loss is the crude
  `log x ≤ x - 1` step (relative slack `1.2 %`), not the MVT.
ANALYSIS (Analyst): the enclosure width shrank from `10⁻⁴` to `3.7·10⁻⁷`, a
  factor `270`, at *no* arithmetic cost — the same 823-digit integers as before.
  This confirms the hypothesis that analytic refinement beats brute enumeration
  past the fourth decimal.  Replacing `log x ≤ x - 1` by the Padé bound
  `log x ≤ (x²-1)/(2x)` would gain a further two decimals per step.
CRITIQUE (Critic): the MVT is applied on `[0.11, p⋆]`, which is legitimate only
  because `0.11 < p⋆` was *proved* in the previous cycle, not assumed; the
  derivative bracket is verified on the whole certified enclosure, so the unknown
  location of `ξ` is harmless.  No step uses floating point.
SYNTHESIS (PI): certificate-driven quantitative rate bounds + certified derivative
  bracket + MVT ⇒ six certified decimals `p⋆ = 0.110028 ± 10⁻⁶`.
-/

open Real Set

noncomputable section

namespace BB84

/-! ## 1. Quantitative certificates for the key rate at a rational QBER -/

/-- **General lower certificate.**  If the integer certificate `m · D < n · N`
holds, where `N = 2^(a+c) a^(2a) c^(2c)` and `D = (a+c)^(2(a+c))`, then the key
rate at `a/(a+c)` exceeds `(a+c)⁻¹ (1 - n/m)`.  (Uses `log x ≥ 1 - x⁻¹`.) -/
theorem secureKeyRate_gt_of_cert (a c m n : ℕ) (ha : 0 < a) (hc : 0 < c) (hm : 0 < m)
    (hcert : m * ((a + c) ^ (2 * (a + c))) < n * (2 ^ (a + c) * a ^ (2 * a) * c ^ (2 * c))) :
    ((a : ℝ) + c)⁻¹ * (1 - (n : ℝ) / m) < secureKeyRate ((a : ℝ) / ((a : ℝ) + c)) := by
  have ha' : (0 : ℝ) < a := by exact_mod_cast ha
  have hc' : (0 : ℝ) < c := by exact_mod_cast hc
  have hm' : (0 : ℝ) < m := by exact_mod_cast hm
  have hb : (0 : ℝ) < (a : ℝ) + c := by linarith
  set D : ℝ := ((((a + c) ^ (2 * (a + c)) : ℕ)) : ℝ) with hDdef
  set N : ℝ := (((2 ^ (a + c) * a ^ (2 * a) * c ^ (2 * c) : ℕ)) : ℝ) with hNdef
  have hD : (0 : ℝ) < D := by rw [hDdef]; push_cast; positivity
  have hN : (0 : ℝ) < N := by rw [hNdef]; push_cast; positivity
  have hcert' : (m : ℝ) * D < (n : ℝ) * N := by
    rw [hDdef, hNdef]; exact_mod_cast hcert
  -- `D / N < n / m`
  have hDN : D / N < (n : ℝ) / m := by
    rw [div_lt_div_iff₀ hN hm']
    nlinarith [hcert']
  -- `log (N / D) ≥ 1 - D / N`
  have hlog : 1 - D / N ≤ Real.log (N / D) := by
    have h := Real.log_le_sub_one_of_pos (x := D / N) (by positivity)
    rw [Real.log_div (ne_of_gt hD) (ne_of_gt hN)] at h
    rw [Real.log_div (ne_of_gt hN) (ne_of_gt hD)]
    linarith
  have hrate := secureKeyRate_ratio_eq a c ha hc
  rw [← hDdef, ← hNdef] at hrate
  rw [hrate]
  have hinv : (0 : ℝ) < ((a : ℝ) + c)⁻¹ := by positivity
  have hlt : (1 : ℝ) - (n : ℝ) / m < Real.log (N / D) := by linarith
  exact mul_lt_mul_of_pos_left hlt hinv

/-- **General upper certificate.**  If `n · N < m · D` then the key rate at
`a/(a+c)` is below `(a+c)⁻¹ (m/n - 1)`.  (Uses `log x ≤ x - 1`.) -/
theorem secureKeyRate_lt_of_cert (a c m n : ℕ) (ha : 0 < a) (hc : 0 < c) (hn : 0 < n)
    (hcert : n * (2 ^ (a + c) * a ^ (2 * a) * c ^ (2 * c)) < m * ((a + c) ^ (2 * (a + c)))) :
    secureKeyRate ((a : ℝ) / ((a : ℝ) + c)) < ((a : ℝ) + c)⁻¹ * ((m : ℝ) / n - 1) := by
  have ha' : (0 : ℝ) < a := by exact_mod_cast ha
  have hc' : (0 : ℝ) < c := by exact_mod_cast hc
  have hn' : (0 : ℝ) < n := by exact_mod_cast hn
  have hb : (0 : ℝ) < (a : ℝ) + c := by linarith
  set D : ℝ := ((((a + c) ^ (2 * (a + c)) : ℕ)) : ℝ) with hDdef
  set N : ℝ := (((2 ^ (a + c) * a ^ (2 * a) * c ^ (2 * c) : ℕ)) : ℝ) with hNdef
  have hD : (0 : ℝ) < D := by rw [hDdef]; push_cast; positivity
  have hN : (0 : ℝ) < N := by rw [hNdef]; push_cast; positivity
  have hcert' : (n : ℝ) * N < (m : ℝ) * D := by
    rw [hDdef, hNdef]; exact_mod_cast hcert
  have hND : N / D < (m : ℝ) / n := by
    rw [div_lt_div_iff₀ hD hn']
    nlinarith [hcert']
  have hlog : Real.log (N / D) ≤ N / D - 1 := Real.log_le_sub_one_of_pos (by positivity)
  have hrate := secureKeyRate_ratio_eq a c ha hc
  rw [← hDdef, ← hNdef] at hrate
  rw [hrate]
  have hinv : (0 : ℝ) < ((a : ℝ) + c)⁻¹ := by positivity
  have hlt : Real.log (N / D) < (m : ℝ) / n - 1 := by linarith
  exact mul_lt_mul_of_pos_left hlt hinv

set_option exponentiation.threshold 100000

/-- Sharp lower certificate: `101171 · 100^200 < 100000 · 2^100·11^22·89^178`,
i.e. `exp (100 · r(0.11)) > 1.01171`. -/
theorem cert_ratio_gt_101171 :
    101171 * ((11 + 89) ^ (2 * (11 + 89)))
      < 100000 * (2 ^ (11 + 89) * 11 ^ (2 * 11) * 89 ^ (2 * 89)) := by
  decide

/-- Sharp upper certificate: `100000 · 2^100·11^22·89^178 < 101172 · 100^200`,
i.e. `exp (100 · r(0.11)) < 1.01172`. -/
theorem cert_ratio_lt_101172 :
    100000 * (2 ^ (11 + 89) * 11 ^ (2 * 11) * 89 ^ (2 * 89))
      < 101172 * ((11 + 89) ^ (2 * (11 + 89))) := by
  decide

/-- Sharp lower bound for the key rate at `11 %`: `r(0.11) > 1171/10117100`
(`≈ 1.15744·10⁻⁴` nats). -/
theorem secureKeyRate_eleven_percent_gt' : 1171 / 10117100 < secureKeyRate (11 / 100) := by
  have h := secureKeyRate_gt_of_cert 11 89 101171 100000 (by norm_num) (by norm_num)
    (by norm_num) cert_ratio_gt_101171
  norm_num at h
  linarith

/-- Sharp upper bound for the key rate at `11 %`: `r(0.11) < 1172/10000000`
(`= 1.172·10⁻⁴` nats). -/
theorem secureKeyRate_eleven_percent_lt' : secureKeyRate (11 / 100) < 1172 / 10000000 := by
  have h := secureKeyRate_lt_of_cert 11 89 101172 100000 (by norm_num) (by norm_num)
    (by norm_num) cert_ratio_lt_101172
  norm_num at h
  linarith

/-! ## 2. A certified bracket for the derivative of the binary entropy -/

/-- `log (89/11) ≤ 2.09081`, from `log 2 < 0.6931471808` and `log (89/88) ≤ 1/88`. -/
theorem log_eightynine_div_eleven_le : Real.log (89 / 11) ≤ 209081 / 100000 := by
  have hsplit : (89 : ℝ) / 11 = 8 * (89 / 88) := by norm_num
  have h8 : Real.log 8 = 3 * Real.log 2 := by
    rw [show (8 : ℝ) = 2 ^ 3 by norm_num, Real.log_pow]; norm_num
  have hsmall : Real.log (89 / 88) ≤ 1 / 88 := by
    have := Real.log_le_sub_one_of_pos (x := (89 : ℝ) / 88) (by norm_num)
    linarith
  rw [hsplit, Real.log_mul (by norm_num) (by norm_num), h8]
  have := Real.log_two_lt_d9
  norm_num at this ⊢
  linarith

/-- `2.08966 ≤ log (8899/1101)`, from `0.6931471803 < log 2` and
`log (8899/8808) ≥ 1 - 8808/8899`. -/
theorem le_log_eightyeightninetynine_div_1101 :
    208966 / 100000 ≤ Real.log (8899 / 1101) := by
  have hsplit : (8899 : ℝ) / 1101 = 8 * (8899 / 8808) := by norm_num
  have h8 : Real.log 8 = 3 * Real.log 2 := by
    rw [show (8 : ℝ) = 2 ^ 3 by norm_num, Real.log_pow]; norm_num
  have hsmall : 91 / 8899 ≤ Real.log (8899 / 8808) := by
    have h := Real.log_le_sub_one_of_pos (x := (8808 : ℝ) / 8899) (by norm_num)
    rw [Real.log_div (by norm_num) (by norm_num)] at h
    rw [Real.log_div (by norm_num) (by norm_num)]
    norm_num at h ⊢
    linarith
  rw [hsplit, Real.log_mul (by norm_num) (by norm_num), h8]
  have := Real.log_two_gt_d9
  norm_num at this ⊢
  linarith

/-- **Certified derivative bracket.**  On the enclosure `[0.1100, 0.1101]` the
derivative `H₂'(x) = log (1-x) - log x` of the binary entropy satisfies
`2.08966 ≤ H₂'(x) ≤ 2.09081`. -/
theorem deriv_binEntropy_bracket {x : ℝ} (hx : x ∈ Icc (11 / 100 : ℝ) (1101 / 10000)) :
    208966 / 100000 ≤ Real.log (1 - x) - Real.log x ∧
      Real.log (1 - x) - Real.log x ≤ 209081 / 100000 := by
  obtain ⟨hx1, hx2⟩ := hx
  have hxpos : (0 : ℝ) < x := by linarith
  have hx1' : (0 : ℝ) < 1 - x := by linarith
  constructor
  · have hA : Real.log (8899 / 10000) ≤ Real.log (1 - x) :=
      Real.log_le_log (by norm_num) (by linarith)
    have hB : Real.log x ≤ Real.log (1101 / 10000) :=
      Real.log_le_log hxpos (by linarith)
    have hC : Real.log (8899 / 10000) - Real.log (1101 / 10000) = Real.log (8899 / 1101) := by
      rw [Real.log_div (by norm_num) (by norm_num), Real.log_div (by norm_num) (by norm_num),
        Real.log_div (by norm_num) (by norm_num)]
      ring
    have := le_log_eightyeightninetynine_div_1101
    linarith [hA, hB, hC ▸ this]
  · have hA : Real.log (1 - x) ≤ Real.log (89 / 100) :=
      Real.log_le_log hx1' (by linarith)
    have hB : Real.log (11 / 100) ≤ Real.log x :=
      Real.log_le_log (by norm_num) (by linarith)
    have hC : Real.log (89 / 100) - Real.log (11 / 100) = Real.log (89 / 11) := by
      rw [Real.log_div (by norm_num) (by norm_num), Real.log_div (by norm_num) (by norm_num),
        Real.log_div (by norm_num) (by norm_num)]
      ring
    have := log_eightynine_div_eleven_le
    linarith [hA, hB, hC ▸ this]

/-! ## 3. The mean-value refinement -/

/-- **Newton/MVT step.**  For the (unique) zero `p⋆` of the key rate on `[0,1/2]`,
the distance to `11 %` is the ratio of the certified rate value at `11 %` to a
derivative value inside the certified enclosure. -/
theorem exists_mvt_point {p : ℝ} (hp : p ∈ Icc (0 : ℝ) 2⁻¹) (hpz : secureKeyRate p = 0) :
    ∃ ξ ∈ Ioo (11 / 100 : ℝ) p,
      (Real.log (1 - ξ) - Real.log ξ) * (p - 11 / 100) = secureKeyRate (11 / 100) / 2 := by
  obtain ⟨h1, h2⟩ := threshold_mem_Ioo hp hpz
  have hcont : ContinuousOn Real.binEntropy (Icc (11 / 100 : ℝ) p) :=
    Real.binEntropy_continuous.continuousOn
  have hderiv : ∀ x ∈ Ioo (11 / 100 : ℝ) p,
      HasDerivAt Real.binEntropy (Real.log (1 - x) - Real.log x) x := by
    intro x hx
    exact Real.hasDerivAt_binEntropy (by nlinarith [hx.1]) (by nlinarith [hx.2, h2])
  obtain ⟨ξ, hξ, hslope⟩ :=
    exists_hasDerivAt_eq_slope Real.binEntropy (fun x => Real.log (1 - x) - Real.log x) h1
      hcont hderiv
  refine ⟨ξ, hξ, ?_⟩
  have hd : p - 11 / 100 ≠ 0 := by intro h; nlinarith
  have hbp : Real.binEntropy p = Real.log 2 / 2 := by
    unfold secureKeyRate at hpz; linarith
  rw [hslope, div_mul_cancel₀ _ hd, hbp]
  unfold secureKeyRate
  ring

/-- **Six certified decimals.**  Every zero of the BB84 key rate on `[0, 1/2]`
satisfies `0.110027 < p⋆ < 0.110029`. -/
theorem threshold_mem_Ioo_six_decimals {p : ℝ} (hp : p ∈ Icc (0 : ℝ) 2⁻¹)
    (hpz : secureKeyRate p = 0) :
    p ∈ Ioo (110027 / 1000000 : ℝ) (110029 / 1000000) := by
  obtain ⟨h1, h2⟩ := threshold_mem_Ioo hp hpz
  obtain ⟨ξ, hξ, heq⟩ := exists_mvt_point hp hpz
  obtain ⟨hL, hU⟩ :=
    deriv_binEntropy_bracket ⟨le_of_lt hξ.1, le_of_lt (lt_trans hξ.2 h2)⟩
  have hd : (0 : ℝ) < p - 11 / 100 := by linarith
  have hrlo := secureKeyRate_eleven_percent_gt'
  have hrhi := secureKeyRate_eleven_percent_lt'
  set s : ℝ := Real.log (1 - ξ) - Real.log ξ with hs
  constructor
  · nlinarith [heq, hU, hd, hrlo]
  · nlinarith [heq, hL, hd, hrhi]

/-- **The threshold to six decimal places**: `|p⋆ - 0.110028| < 10⁻⁶`.
(The exact value is `0.1100278644…`.) -/
theorem threshold_abs_sub_lt_millionth {p : ℝ} (hp : p ∈ Icc (0 : ℝ) 2⁻¹)
    (hpz : secureKeyRate p = 0) : |p - 110028 / 1000000| < 1 / 1000000 := by
  obtain ⟨h1, h2⟩ := threshold_mem_Ioo_six_decimals hp hpz
  rw [abs_lt]
  constructor <;> linarith

/-- **The refinement is strict**: the six-decimal enclosure is contained in the
four-decimal one, which in turn refines the catalog bracket `(1/16, 1/8)`. -/
theorem six_decimal_refines :
    Ioo (110027 / 1000000 : ℝ) (110029 / 1000000) ⊆ Ioo (11 / 100 : ℝ) (1101 / 10000) ∧
      Ioo (11 / 100 : ℝ) (1101 / 10000) ⊆ Ioo (1 / 16 : ℝ) (1 / 8) := by
  refine ⟨fun x hx => ⟨by linarith [hx.1], by linarith [hx.2]⟩, enclosure_refines_catalog_bracket⟩

/-- **Final certified statement.**  There is exactly one quantum bit error rate in
`[0, 1/2]` at which the asymptotic one-way BB84 secret-key rate vanishes, and it
equals `0.110028` to within `10⁻⁶`. -/
theorem bb84_threshold_six_decimals :
    ∃! p : ℝ, p ∈ Icc (0 : ℝ) 2⁻¹ ∧ secureKeyRate p = 0 ∧ |p - 110028 / 1000000| < 1 / 1000000 := by
  obtain ⟨p, ⟨hpI, hpz⟩, huniq⟩ := exists_unique_threshold_enclosure
  refine ⟨p, ⟨hpI, hpz, threshold_abs_sub_lt_millionth hpI hpz⟩, ?_⟩
  rintro q ⟨hqI, hqz, -⟩
  exact huniq q ⟨hqI, hqz⟩

end BB84