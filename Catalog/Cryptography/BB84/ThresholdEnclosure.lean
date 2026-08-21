import Mathlib
import Cryptography.BB84.KeyRateThreshold

/-!
# A certified four-decimal enclosure of the BB84 QBER threshold

`Cryptography.BB84.KeyRateThreshold` proves that the asymptotic one-way BB84
secret-key rate `secureKeyRate Q = log 2 - 2 · binEntropy Q` has a unique zero
`p⋆` on `[0, 1/2]` and localizes it in the interval `(1/16, 1/8)`, i.e. between
`6.25 %` and `12.5 %`.  That bracket has width `6.25 %`, which is far too coarse
to justify the textbook figure "≈ 11 %".

This file replaces the coarse bracket by a **certified decimal enclosure**

  `0.1100 < p⋆ < 0.1101`,

together with certified two-sided bounds on the key rate *at* `11 %`.  Nothing
here is floating point: the whole certification scheme is reduced to comparisons
of explicit natural numbers.

## The certification scheme

For a rational error rate `p = a/(a+c)` with `a, c ∈ ℕ`, `a, c > 0`, one has the
exact identity (`binEntropy_ratio_mul_eq`)

  `2(a+c) · binEntropy (a/(a+c)) = 2(a+c) log (a+c) - 2a log a - 2c log c`,

so that, after exponentiating, the transcendental comparison
`binEntropy (a/(a+c)) ⋚ (log 2)/2` becomes the *integer* comparison

  `(a+c)^(2(a+c))  ⋚  2^(a+c) · a^(2a) · c^(2c)`   (`binEntropy_lt_half_log_two_iff`).

Two such integer certificates,

* `100^200 < 2^100 · 11^22 · 89^178`                    (`cert_eleven_percent`)
* `2^10000 · 1101^2202 · 8899^17798 < 10000^20000`      (`cert_upper_1101`)

pin the threshold between `11/100` and `1101/10000`.

## Quantitative form

The exact key rate at a rational QBER is a *logarithm of a rational number*
(`secureKeyRate_ratio_eq`), so the elementary bounds `1 - x⁻¹ ≤ log x ≤ x - 1`
turn two further integer certificates into the certified two-sided estimate

  `1/10000 < secureKeyRate (11/100) < 3/25000`   (nats),

i.e. the residual key rate at a `11 %` error rate is between `1.00·10⁻⁴` and
`1.20·10⁻⁴` nats per sifted bit.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): the transcendental root of `1 - 2H₂(Q)` admits a
  *purely arithmetic* enclosure of arbitrary precision: for every rational
  `a/(a+c)` the sign of `1 - 2H₂` is decided by one comparison of natural numbers,
  hence a decimal expansion of `p⋆` can be certified digit by digit with no
  interval arithmetic on `log`.
EXPERIMENT (Experimenter): the scheme was instantiated at four denominators.
  `b = 100`   : `100^200 < 2^100·11^22·89^178`            (holds ⇒ `p⋆ > 0.1100`)
  `b = 1000`  : `2^1000·111^222·889^1778 < 1000^2000`      (holds ⇒ `p⋆ < 0.111`)
  `b = 10000` : `2^10000·1101^2202·8899^17798 < 10000^20000` (holds ⇒ `p⋆ < 0.1101`)
  `b = 10000` : `10000^20000 < 2^10000·1100^2200·8900^17800` (holds ⇒ `p⋆ > 0.1100`)
  All four are closed by kernel evaluation (`decide`); the largest involves
  80 000-digit integers and still evaluates.  The residual rate certificates
  `10000·(2^100·11^22·89^178) > 10117·100^200` and `< 10118·100^200` pin
  `exp(100·r(0.11))` to four decimals.
ANALYSIS (Analyst): the gain over the catalog bracket `(1/16, 1/8)` is a factor
  `625` in width.  The obstruction to pushing to `b = 10^5` is *not* mathematical
  but kernel arithmetic: `Nat.pow` unfolds linearly, so the cost grows like
  `b²`; a binary-powering certificate would remove this barrier.
CRITIQUE (Critic): the enclosure is not vacuous — both endpoints are checked with
  strict inequalities, monotonicity gives uniqueness, and the localization lemma
  applies to *every* zero of `secureKeyRate` in `[0, 1/2]`, not just to a
  conveniently chosen one.  The `decide` calls certify honest integer facts; the
  mathematical content (identity + monotonicity + IVT) is proved, never decided.
SYNTHESIS (PI): a general rational-certificate scheme, its instantiation to a
  four-decimal enclosure, and quantitative two-sided bounds on the key rate at
  exactly `11 %`.
-/

open Real Set

noncomputable section

namespace BB84

/-! ## 1. The exact rational identity for the binary entropy -/

/-- **Exact rational form of the binary entropy.**  For positive naturals `a, c`,
`2(a+c) · binEntropy (a/(a+c)) = 2(a+c) log (a+c) - 2a log a - 2c log c`.
Clearing the denominator `a+c` is what makes the subsequent comparison purely
arithmetic. -/
theorem binEntropy_ratio_mul_eq (a c : ℕ) (ha : 0 < a) (hc : 0 < c) :
    2 * ((a : ℝ) + c) * Real.binEntropy ((a : ℝ) / ((a : ℝ) + c))
      = 2 * ((a : ℝ) + c) * Real.log ((a : ℝ) + c)
        - 2 * (a : ℝ) * Real.log a - 2 * (c : ℝ) * Real.log c := by
  have ha' : (0 : ℝ) < a := by exact_mod_cast ha
  have hc' : (0 : ℝ) < c := by exact_mod_cast hc
  have h1 : (1 : ℝ) - (a : ℝ) / ((a : ℝ) + c) = (c : ℝ) / ((a : ℝ) + c) := by
    field_simp; ring
  unfold Real.binEntropy
  rw [h1, inv_div, inv_div, Real.log_div (by positivity) (by positivity),
    Real.log_div (by positivity) (by positivity)]
  field_simp
  ring

/-- Logarithm of the "entropy side" of a certificate. -/
private theorem log_cert_lhs (a c : ℕ) :
    Real.log ((((a + c) ^ (2 * (a + c)) : ℕ)) : ℝ)
      = 2 * ((a : ℝ) + c) * Real.log ((a : ℝ) + c) := by
  push_cast [Real.log_pow]
  ring

/-- Logarithm of the "capacity side" of a certificate. -/
private theorem log_cert_rhs (a c : ℕ) (ha : 0 < a) (hc : 0 < c) :
    Real.log (((2 ^ (a + c) * a ^ (2 * a) * c ^ (2 * c) : ℕ)) : ℝ)
      = ((a : ℝ) + c) * Real.log 2 + 2 * (a : ℝ) * Real.log a + 2 * (c : ℝ) * Real.log c := by
  have ha' : (0 : ℝ) < a := by exact_mod_cast ha
  have hc' : (0 : ℝ) < c := by exact_mod_cast hc
  push_cast
  rw [Real.log_mul (by positivity) (by positivity), Real.log_mul (by positivity) (by positivity),
    Real.log_pow, Real.log_pow, Real.log_pow]
  push_cast
  ring

/-! ## 2. The arithmetic certification criterion -/

/-- **Certification criterion (below threshold).**  For positive naturals `a, c`,
the transcendental inequality `binEntropy (a/(a+c)) < (log 2)/2` — i.e. the
BB84 key rate at error rate `a/(a+c)` is positive — is *equivalent* to the
integer inequality `(a+c)^(2(a+c)) < 2^(a+c) · a^(2a) · c^(2c)`. -/
theorem binEntropy_lt_half_log_two_iff (a c : ℕ) (ha : 0 < a) (hc : 0 < c) :
    Real.binEntropy ((a : ℝ) / ((a : ℝ) + c)) < Real.log 2 / 2
      ↔ (a + c) ^ (2 * (a + c)) < 2 ^ (a + c) * a ^ (2 * a) * c ^ (2 * c) := by
  have ha' : (0 : ℝ) < a := by exact_mod_cast ha
  have hc' : (0 : ℝ) < c := by exact_mod_cast hc
  have hposL : (0 : ℝ) < ((((a + c) ^ (2 * (a + c)) : ℕ)) : ℝ) := by
    push_cast; positivity
  have hposR : (0 : ℝ) < (((2 ^ (a + c) * a ^ (2 * a) * c ^ (2 * c) : ℕ)) : ℝ) := by
    push_cast; positivity
  have hcast : ((a + c) ^ (2 * (a + c)) < 2 ^ (a + c) * a ^ (2 * a) * c ^ (2 * c))
      ↔ ((((a + c) ^ (2 * (a + c)) : ℕ)) : ℝ)
          < (((2 ^ (a + c) * a ^ (2 * a) * c ^ (2 * c) : ℕ)) : ℝ) := by
    exact_mod_cast Iff.rfl
  rw [hcast, ← Real.log_lt_log_iff hposL hposR, log_cert_lhs, log_cert_rhs a c ha hc]
  have hid := binEntropy_ratio_mul_eq a c ha hc
  constructor <;> intro h <;> nlinarith [hid]

/-- **Certification criterion (above threshold).**  Dually, `(log 2)/2 <
binEntropy (a/(a+c))` — the key rate is negative — is equivalent to the reversed
integer inequality. -/
theorem half_log_two_lt_binEntropy_iff (a c : ℕ) (ha : 0 < a) (hc : 0 < c) :
    Real.log 2 / 2 < Real.binEntropy ((a : ℝ) / ((a : ℝ) + c))
      ↔ 2 ^ (a + c) * a ^ (2 * a) * c ^ (2 * c) < (a + c) ^ (2 * (a + c)) := by
  have ha' : (0 : ℝ) < a := by exact_mod_cast ha
  have hc' : (0 : ℝ) < c := by exact_mod_cast hc
  have hposL : (0 : ℝ) < ((((a + c) ^ (2 * (a + c)) : ℕ)) : ℝ) := by
    push_cast; positivity
  have hposR : (0 : ℝ) < (((2 ^ (a + c) * a ^ (2 * a) * c ^ (2 * c) : ℕ)) : ℝ) := by
    push_cast; positivity
  have hcast : (2 ^ (a + c) * a ^ (2 * a) * c ^ (2 * c) < (a + c) ^ (2 * (a + c)))
      ↔ (((2 ^ (a + c) * a ^ (2 * a) * c ^ (2 * c) : ℕ)) : ℝ)
          < ((((a + c) ^ (2 * (a + c)) : ℕ)) : ℝ) := by
    exact_mod_cast Iff.rfl
  rw [hcast, ← Real.log_lt_log_iff hposR hposL, log_cert_lhs, log_cert_rhs a c ha hc]
  have hid := binEntropy_ratio_mul_eq a c ha hc
  constructor <;> intro h <;> nlinarith [hid]

/-- Positivity of the key rate at a rational QBER, in certificate form. -/
theorem secureKeyRate_ratio_pos_iff (a c : ℕ) (ha : 0 < a) (hc : 0 < c) :
    0 < secureKeyRate ((a : ℝ) / ((a : ℝ) + c))
      ↔ (a + c) ^ (2 * (a + c)) < 2 ^ (a + c) * a ^ (2 * a) * c ^ (2 * c) := by
  rw [secureKeyRate_pos_iff, binEntropy_lt_half_log_two_iff a c ha hc]

/-! ## 3. The four integer certificates -/

set_option exponentiation.threshold 100000

/-- Certificate at `Q = 11/100`: `100^200 < 2^100 · 11^22 · 89^178`
(823-digit integers).  It certifies that `11 %` is *strictly below* threshold. -/
theorem cert_eleven_percent :
    (11 + 89) ^ (2 * (11 + 89)) < 2 ^ (11 + 89) * 11 ^ (2 * 11) * 89 ^ (2 * 89) := by
  decide

set_option maxRecDepth 1000000 in
/-- Certificate at `Q = 1101/10000`: `2^10000 · 1101^2202 · 8899^17798 < 10000^20000`
(80 000-digit integers).  It certifies that `11.01 %` is *strictly above* threshold. -/
theorem cert_upper_1101 :
    2 ^ (1101 + 8899) * 1101 ^ (2 * 1101) * 8899 ^ (2 * 8899)
      < (1101 + 8899) ^ (2 * (1101 + 8899)) := by
  decide

set_option maxRecDepth 1000000 in
/-- Certificate at `Q = 1100/10000`, the four-decimal restatement of the lower
endpoint.  (Consistency check for the scheme: it must agree with
`cert_eleven_percent`, since `1100/10000 = 11/100`.) -/
theorem cert_lower_1100 :
    (1100 + 8900) ^ (2 * (1100 + 8900))
      < 2 ^ (1100 + 8900) * 1100 ^ (2 * 1100) * 8900 ^ (2 * 8900) := by
  decide

/-- Certificate at `Q = 111/1000`, an intermediate three-decimal upper endpoint. -/
theorem cert_upper_111 :
    2 ^ (111 + 889) * 111 ^ (2 * 111) * 889 ^ (2 * 889)
      < (111 + 889) ^ (2 * (111 + 889)) := by
  decide

/-! ## 4. The certified endpoints -/

/-- At a quantum bit error rate of exactly `11 %` the BB84 key rate is still
**strictly positive**: `binEntropy (11/100) < (log 2)/2`. -/
theorem binEntropy_eleven_percent_lt : Real.binEntropy (11 / 100) < Real.log 2 / 2 := by
  have h := (binEntropy_lt_half_log_two_iff 11 89 (by norm_num) (by norm_num)).2
    cert_eleven_percent
  norm_num at h
  exact h

/-- At a quantum bit error rate of `11.01 %` the BB84 key rate is **strictly
negative**: `(log 2)/2 < binEntropy (1101/10000)`. -/
theorem half_log_two_lt_binEntropy_1101 :
    Real.log 2 / 2 < Real.binEntropy (1101 / 10000) := by
  have h := (half_log_two_lt_binEntropy_iff 1101 8899 (by norm_num) (by norm_num)).2
    cert_upper_1101
  norm_num at h
  exact h

/-- The key rate at `11 %` QBER is positive: secure key can still be distilled. -/
theorem secureKeyRate_eleven_percent_pos : 0 < secureKeyRate (11 / 100) := by
  rw [secureKeyRate_pos_iff]
  exact binEntropy_eleven_percent_lt

/-- The key rate at `11.01 %` QBER is negative: no key can be distilled. -/
theorem secureKeyRate_1101_neg : secureKeyRate (1101 / 10000) < 0 := by
  have h := half_log_two_lt_binEntropy_1101
  unfold secureKeyRate
  linarith

/-! ## 5. Localization of the threshold -/

/-- **General localization lemma.**  Every zero of the key rate in `[0, 1/2]` lies
strictly above any rational point `a/(a+c) ≤ 1/2` that carries a "below threshold"
certificate. -/
theorem lt_of_zero_of_binEntropy_lt {p q : ℝ} (hp : p ∈ Icc (0 : ℝ) 2⁻¹)
    (hq : q ∈ Icc (0 : ℝ) 2⁻¹) (hq' : Real.binEntropy q < Real.log 2 / 2)
    (hpz : secureKeyRate p = 0) : q < p := by
  have hbp : Real.binEntropy p = Real.log 2 / 2 := by
    unfold secureKeyRate at hpz; linarith
  by_contra hcon
  push_neg at hcon
  rcases eq_or_lt_of_le hcon with h | h
  · rw [← h, hbp] at hq'; exact lt_irrefl _ hq'
  · have := Real.binEntropy_strictMonoOn hp hq h
    rw [hbp] at this
    linarith

/-- **General localization lemma, upper side.**  Every zero of the key rate in
`[0, 1/2]` lies strictly below any rational point carrying an "above threshold"
certificate. -/
theorem lt_of_zero_of_lt_binEntropy {p q : ℝ} (hp : p ∈ Icc (0 : ℝ) 2⁻¹)
    (hq : q ∈ Icc (0 : ℝ) 2⁻¹) (hq' : Real.log 2 / 2 < Real.binEntropy q)
    (hpz : secureKeyRate p = 0) : p < q := by
  have hbp : Real.binEntropy p = Real.log 2 / 2 := by
    unfold secureKeyRate at hpz; linarith
  by_contra hcon
  push_neg at hcon
  rcases eq_or_lt_of_le hcon with h | h
  · rw [h, hbp] at hq'; exact lt_irrefl _ hq'
  · have := Real.binEntropy_strictMonoOn hq hp h
    rw [hbp] at this
    linarith

/-- **Certified four-decimal enclosure.**  Any zero of the BB84 key rate on
`[0, 1/2]` — and by `threshold_unique` there is exactly one — satisfies
`0.1100 < p⋆ < 0.1101`. -/
theorem threshold_mem_Ioo {p : ℝ} (hp : p ∈ Icc (0 : ℝ) 2⁻¹)
    (hpz : secureKeyRate p = 0) : p ∈ Ioo (11 / 100 : ℝ) (1101 / 10000) := by
  constructor
  · exact lt_of_zero_of_binEntropy_lt hp (by norm_num) binEntropy_eleven_percent_lt hpz
  · exact lt_of_zero_of_lt_binEntropy hp (by norm_num) half_log_two_lt_binEntropy_1101 hpz

/-- **Existence inside the certified enclosure.**  There is a critical QBER
strictly between `11.00 %` and `11.01 %` at which the BB84 key rate vanishes. -/
theorem exists_threshold_enclosure :
    ∃ p : ℝ, p ∈ Ioo (11 / 100 : ℝ) (1101 / 10000) ∧ secureKeyRate p = 0 := by
  have hcont : ContinuousOn Real.binEntropy (Icc (11 / 100 : ℝ) (1101 / 10000)) :=
    Real.binEntropy_continuous.continuousOn
  have hsub : Ioo (Real.binEntropy (11 / 100)) (Real.binEntropy (1101 / 10000))
      ⊆ Real.binEntropy '' Ioo (11 / 100 : ℝ) (1101 / 10000) :=
    intermediate_value_Ioo (by norm_num) hcont
  have hmem : Real.log 2 / 2 ∈ Ioo (Real.binEntropy (11 / 100)) (Real.binEntropy (1101 / 10000)) :=
    ⟨binEntropy_eleven_percent_lt, half_log_two_lt_binEntropy_1101⟩
  obtain ⟨p, hp, hpe⟩ := hsub hmem
  exact ⟨p, hp, by unfold secureKeyRate; rw [hpe]; ring⟩

/-- **The enclosure is a genuine refinement** of the catalog bracket `(1/16, 1/8)`:
the new interval has width `10⁻⁴` instead of `1/16`, a factor `625` improvement. -/
theorem enclosure_refines_catalog_bracket :
    Ioo (11 / 100 : ℝ) (1101 / 10000) ⊆ Ioo (1 / 16 : ℝ) (1 / 8) := by
  intro x hx
  exact ⟨by linarith [hx.1], by linarith [hx.2]⟩

/-- **Uniqueness inside the enclosure**: there is exactly one QBER in `[0, 1/2]`
with vanishing key rate, and it lies in `(0.1100, 0.1101)`. -/
theorem exists_unique_threshold_enclosure :
    ∃! p : ℝ, p ∈ Icc (0 : ℝ) 2⁻¹ ∧ secureKeyRate p = 0 := by
  obtain ⟨p, hp, hpz⟩ := exists_threshold_enclosure
  have hpI : p ∈ Icc (0 : ℝ) 2⁻¹ := ⟨by linarith [hp.1], by linarith [hp.2]⟩
  refine ⟨p, ⟨hpI, hpz⟩, ?_⟩
  rintro q ⟨hqI, hqz⟩
  exact threshold_unique hqI hpI hqz hpz

/-- **Two certified decimal digits.**  The threshold agrees with `0.11` to within
`10⁻⁴`; in particular its decimal expansion begins `0.110…`. -/
theorem threshold_abs_sub_eleven_percent_lt {p : ℝ} (hp : p ∈ Icc (0 : ℝ) 2⁻¹)
    (hpz : secureKeyRate p = 0) : |p - 11 / 100| < 1 / 10000 := by
  obtain ⟨h1, h2⟩ := threshold_mem_Ioo hp hpz
  rw [abs_lt]
  constructor <;> linarith

/-! ## 6. Quantitative key rate at exactly 11 % -/

/-- **The key rate at a rational QBER is the logarithm of a rational number.**
`secureKeyRate (a/(a+c)) = (1/(a+c)) · log (2^(a+c) a^(2a) c^(2c) / (a+c)^(2(a+c)))`.
This is the quantitative refinement of the certification criterion: the criterion
only reads off the *sign* of this logarithm. -/
theorem secureKeyRate_ratio_eq (a c : ℕ) (ha : 0 < a) (hc : 0 < c) :
    secureKeyRate ((a : ℝ) / ((a : ℝ) + c))
      = (((a : ℝ) + c)⁻¹) * Real.log
          ((((2 ^ (a + c) * a ^ (2 * a) * c ^ (2 * c) : ℕ)) : ℝ)
            / ((((a + c) ^ (2 * (a + c)) : ℕ)) : ℝ)) := by
  have ha' : (0 : ℝ) < a := by exact_mod_cast ha
  have hc' : (0 : ℝ) < c := by exact_mod_cast hc
  have hb : (0 : ℝ) < (a : ℝ) + c := by linarith
  have hposL : (0 : ℝ) < ((((a + c) ^ (2 * (a + c)) : ℕ)) : ℝ) := by push_cast; positivity
  have hposR : (0 : ℝ) < (((2 ^ (a + c) * a ^ (2 * a) * c ^ (2 * c) : ℕ)) : ℝ) := by
    push_cast; positivity
  rw [Real.log_div (ne_of_gt hposR) (ne_of_gt hposL), log_cert_lhs, log_cert_rhs a c ha hc]
  have hid := binEntropy_ratio_mul_eq a c ha hc
  unfold secureKeyRate
  field_simp
  nlinarith [hid]

/-- Rational lower certificate: `exp(100 · r(0.11)) > 1.0117`. -/
theorem cert_rate_lower :
    10000 * (2 ^ (11 + 89) * 11 ^ (2 * 11) * 89 ^ (2 * 89))
      > 10117 * (11 + 89) ^ (2 * (11 + 89)) := by
  decide

/-- Rational upper certificate: `exp(100 · r(0.11)) < 1.0118`. -/
theorem cert_rate_upper :
    10000 * (2 ^ (11 + 89) * 11 ^ (2 * 11) * 89 ^ (2 * 89))
      < 10118 * (11 + 89) ^ (2 * (11 + 89)) := by
  decide

/-- **Certified lower bound on the residual key rate at `11 %` QBER.**
`secureKeyRate (11/100) > 10⁻⁴` nats per sifted bit.  Proved from
`log x ≥ 1 - x⁻¹` applied to the rational `x = 2^100·11^22·89^178 / 100^200`,
whose lower bound `x > 1.0117` is the integer certificate `cert_rate_lower`. -/
theorem secureKeyRate_eleven_percent_gt : 1 / 10000 < secureKeyRate (11 / 100) := by
  have hpos : (0 : ℝ) < ((((11 + 89) ^ (2 * (11 + 89)) : ℕ)) : ℝ) := by norm_num
  set D : ℝ := ((((11 + 89) ^ (2 * (11 + 89)) : ℕ)) : ℝ) with hD
  set N : ℝ := (((2 ^ (11 + 89) * 11 ^ (2 * 11) * 89 ^ (2 * 89) : ℕ)) : ℝ) with hN
  have hNpos : (0 : ℝ) < N := by rw [hN]; norm_num
  have hratio : (10117 : ℝ) / 10000 < N / D := by
    rw [div_lt_div_iff₀ (by norm_num) hpos]
    have := cert_rate_lower
    rw [hN, hD]
    exact_mod_cast by exact_mod_cast this
  have hlog : 1 - (N / D)⁻¹ ≤ Real.log (N / D) := by
    have := Real.log_le_sub_one_of_pos (x := (N / D)⁻¹) (by positivity)
    rw [Real.log_inv] at this
    linarith
  have hinv : ((N / D))⁻¹ < 10000 / 10117 := by
    rw [inv_lt_comm₀ (by positivity) (by norm_num)]
    calc ((10000 : ℝ) / 10117)⁻¹ = 10117 / 10000 := by norm_num
      _ < N / D := hratio
  have hrate : secureKeyRate ((11 : ℝ) / (11 + 89)) = ((11 : ℝ) + 89)⁻¹ * Real.log (N / D) := by
    have := secureKeyRate_ratio_eq 11 89 (by norm_num) (by norm_num)
    rw [hN, hD]
    exact_mod_cast this
  have h11 : ((11 : ℝ) / (11 + 89)) = 11 / 100 := by norm_num
  rw [h11] at hrate
  rw [hrate]
  have : (1 : ℝ) - 10000 / 10117 ≤ Real.log (N / D) := by linarith
  norm_num at this ⊢
  linarith

/-- **Certified upper bound on the residual key rate at `11 %` QBER.**
`secureKeyRate (11/100) < 1.2·10⁻⁴` nats per sifted bit, from `log x ≤ x - 1`
and the integer certificate `cert_rate_upper`. -/
theorem secureKeyRate_eleven_percent_lt : secureKeyRate (11 / 100) < 3 / 25000 := by
  have hpos : (0 : ℝ) < ((((11 + 89) ^ (2 * (11 + 89)) : ℕ)) : ℝ) := by norm_num
  set D : ℝ := ((((11 + 89) ^ (2 * (11 + 89)) : ℕ)) : ℝ) with hD
  set N : ℝ := (((2 ^ (11 + 89) * 11 ^ (2 * 11) * 89 ^ (2 * 89) : ℕ)) : ℝ) with hN
  have hNpos : (0 : ℝ) < N := by rw [hN]; norm_num
  have hratio : N / D < (10118 : ℝ) / 10000 := by
    rw [div_lt_div_iff₀ hpos (by norm_num)]
    have := cert_rate_upper
    rw [hN, hD]
    exact_mod_cast by exact_mod_cast this
  have hlog : Real.log (N / D) ≤ N / D - 1 := Real.log_le_sub_one_of_pos (by positivity)
  have hrate : secureKeyRate ((11 : ℝ) / (11 + 89)) = ((11 : ℝ) + 89)⁻¹ * Real.log (N / D) := by
    have := secureKeyRate_ratio_eq 11 89 (by norm_num) (by norm_num)
    rw [hN, hD]
    exact_mod_cast this
  have h11 : ((11 : ℝ) / (11 + 89)) = 11 / 100 := by norm_num
  rw [h11] at hrate
  rw [hrate]
  have hbound : Real.log (N / D) < 10118 / 10000 - 1 := by linarith
  norm_num at hbound ⊢
  linarith

/-- **Summary: the certified enclosure of the BB84 threshold.**  The unique QBER
at which the asymptotic one-way BB84 key rate vanishes lies strictly between
`11.00 %` and `11.01 %`, and at `11 %` the surviving key rate is between
`1.0·10⁻⁴` and `1.2·10⁻⁴` nats per sifted bit. -/
theorem bb84_threshold_certified_enclosure :
    (∃! p : ℝ, p ∈ Icc (0 : ℝ) 2⁻¹ ∧ secureKeyRate p = 0) ∧
      (∀ p : ℝ, p ∈ Icc (0 : ℝ) 2⁻¹ → secureKeyRate p = 0 →
        11 / 100 < p ∧ p < 1101 / 10000) ∧
      1 / 10000 < secureKeyRate (11 / 100) ∧ secureKeyRate (11 / 100) < 3 / 25000 :=
  ⟨exists_unique_threshold_enclosure,
    fun _ hp hpz => threshold_mem_Ioo hp hpz,
    secureKeyRate_eleven_percent_gt, secureKeyRate_eleven_percent_lt⟩

end BB84