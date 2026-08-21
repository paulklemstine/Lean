import Mathlib
import Cryptography.BB84.KeyRateThreshold
import Cryptography.BB84.ThresholdEnclosure
import Cryptography.BB84.ThresholdNewtonRefinement
import Cryptography.BB84.ThresholdPadeDigits

/-!
# Thirteen certified decimals of the BB84 threshold from a continued-fraction anchor

The three previous cycles anchor every mean-value step at the *decimal* point
`11/100`.  Because the mean value point `ξ` is only known to lie between the
anchor and the root, the derivative bracket has width `≈ |H₂''| · |anchor - p⋆|`,
so the final precision is `≈ 5 · |anchor - p⋆|²`.  Anchoring at a decimal
therefore costs precision: `|11/100 - p⋆| ≈ 2.8·10⁻⁵` caps the method at eight
decimals, and refining the decimal anchor is impossible because a denominator
`10⁷` certificate would need integers with `10⁸` digits.

The way out is to abandon decimals: **any** rational anchor works, and the
continued-fraction convergents of `p⋆` come far closer for a far smaller
denominator.  The convergent

  `79/718 = 0.110027855153…`,   `|79/718 - p⋆| ≈ 9.3·10⁻⁹`,

has a *three-digit* denominator, so its certificate involves only 4 102-digit
integers — cheaper than the `10⁴`-denominator certificate of the first cycle —
yet it is `3000` times closer to the root than `11/100`.  One mean-value step
from this anchor gives

  `0.1100278644383 < p⋆ < 0.1100278644384`,  i.e. `⌊10¹³ p⋆⌋ = 1100278644383`

(`threshold_mem_Ioo_thirteen_decimals`, `threshold_floor_thirteen_decimals`);
the certified interval has width `2.2·10⁻¹⁵`.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): the arithmetic cost of a certificate grows like the
  square of the denominator, while the achievable precision grows like the square
  of the anchor's *approximation quality*; hence Diophantine approximation, not
  brute force, is the right resource.  Continued fractions should therefore beat
  decimal refinement by orders of magnitude.
EXPERIMENT (Experimenter): the convergents of `p⋆` are
  `0/1, 1/9, 11/100, 34/309, 79/718, 16466/149653, 33011/300024, …`
  with errors `1.1·10⁻³, -2.8·10⁻⁵, 4.5·10⁻⁶, -9.3·10⁻⁹, 2.1·10⁻¹¹, …`.
  Note that `11/100` is itself a convergent — the textbook value `11 %` is the
  best rational approximation of the threshold with denominator `≤ 308`.  Taking
  the next-but-one convergent `79/718` and certifying
  `100002787345813950188 · 718^1436 < 10^20 · 2^718·79^158·639^1278
     < 100002787345813950189 · 718^1436`
  gives `r(79/718) ∈ (3.882043130930·10⁻⁸, 3.882043131686·10⁻⁸)` and, after one
  mean-value step with the derivative bracket `[2.0904563381, 2.0904568254]`,
  an interval of width `2.17·10⁻¹⁵` around the root.
  Certified decimals: 4 → 6 → 8 → 13.
ANALYSIS (Analyst): the precision of one Newton step is `≈ 5·δ²` where `δ` is the
  distance from the anchor, and `δ ≈ 1/q²` for a convergent of denominator `q`,
  so the certified precision behaves like `q⁻⁴` while the certificate cost is
  `q²` — a quartic-versus-quadratic tradeoff strongly favouring good rational
  approximations.  Using `16466/149653` would in principle reach `≈ 10⁻²¹`.
CRITIQUE (Critic): the anchor is *not* assumed to be near the root — its position
  is certified by the same integer machinery, and the ordering `79/718 < p⋆` is
  inherited from the previously proved eight-decimal enclosure.  The nine-digit
  Mathlib bounds on `log 2` enter only through the derivative bracket, where they
  contribute `< 10⁻¹⁷` to the final width.
SYNTHESIS (PI): Diophantine anchor + integer certificate + Padé + one mean-value
  step ⇒ `⌊10¹³ p⋆⌋ = 1100278644383`.
-/

open Real Set

noncomputable section

namespace BB84

/-! ## 1. General Padé-sharpened certificate lemmas -/

/-- **General Padé lower certificate.**  If `m · D < n · N` with `n ≤ m`, where
`N = 2^(a+c) a^(2a) c^(2c)` and `D = (a+c)^(2(a+c))`, then
`r(a/(a+c)) > (a+c)⁻¹ · 2(m/n - 1)/(m/n + 1)`. -/
theorem secureKeyRate_gt_of_cert_pade (a c m n : ℕ) (ha : 0 < a) (hc : 0 < c) (hn : 0 < n)
    (hmn : n ≤ m)
    (hcert : m * ((a + c) ^ (2 * (a + c))) < n * (2 ^ (a + c) * a ^ (2 * a) * c ^ (2 * c))) :
    ((a : ℝ) + c)⁻¹ * (2 * ((m : ℝ) / n - 1) / ((m : ℝ) / n + 1))
      < secureKeyRate ((a : ℝ) / ((a : ℝ) + c)) := by
  have ha' : (0 : ℝ) < a := by exact_mod_cast ha
  have hc' : (0 : ℝ) < c := by exact_mod_cast hc
  have hn' : (0 : ℝ) < n := by exact_mod_cast hn
  have hmn' : (n : ℝ) ≤ m := by exact_mod_cast hmn
  set D : ℝ := ((((a + c) ^ (2 * (a + c)) : ℕ)) : ℝ) with hDdef
  set N : ℝ := (((2 ^ (a + c) * a ^ (2 * a) * c ^ (2 * c) : ℕ)) : ℝ) with hNdef
  have hD : (0 : ℝ) < D := by rw [hDdef]; push_cast; positivity
  have hN : (0 : ℝ) < N := by rw [hNdef]; push_cast; positivity
  have hcert' : (m : ℝ) * D < (n : ℝ) * N := by rw [hDdef, hNdef]; exact_mod_cast hcert
  have hu1 : (1 : ℝ) ≤ (m : ℝ) / n := (one_le_div hn').2 hmn'
  have hR : (m : ℝ) / n < N / D := by
    rw [div_lt_div_iff₀ hn' hD]; nlinarith [hcert']
  have hR1 : (1 : ℝ) ≤ N / D := le_trans hu1 (le_of_lt hR)
  have hpade : 2 * (N / D - 1) / (N / D + 1) ≤ Real.log (N / D) := pade_le_log hR1
  have hmono : 2 * ((m : ℝ) / n - 1) / ((m : ℝ) / n + 1) < 2 * (N / D - 1) / (N / D + 1) := by
    rw [div_lt_div_iff₀ (by linarith) (by linarith)]
    nlinarith [hR]
  have hrate := secureKeyRate_ratio_eq a c ha hc
  rw [← hDdef, ← hNdef] at hrate
  rw [hrate]
  exact mul_lt_mul_of_pos_left (by linarith) (by positivity)

/-- **General Padé upper certificate.**  If `D ≤ N` and `n · N < m · D`, then
`r(a/(a+c)) < (a+c)⁻¹ · (m/n - (m/n)⁻¹)/2`. -/
theorem secureKeyRate_lt_of_cert_pade (a c m n : ℕ) (ha : 0 < a) (hc : 0 < c) (hn : 0 < n)
    (hDN : (a + c) ^ (2 * (a + c)) ≤ 2 ^ (a + c) * a ^ (2 * a) * c ^ (2 * c))
    (hcert : n * (2 ^ (a + c) * a ^ (2 * a) * c ^ (2 * c)) < m * ((a + c) ^ (2 * (a + c)))) :
    secureKeyRate ((a : ℝ) / ((a : ℝ) + c))
      < ((a : ℝ) + c)⁻¹ * (((m : ℝ) / n - ((m : ℝ) / n)⁻¹) / 2) := by
  have ha' : (0 : ℝ) < a := by exact_mod_cast ha
  have hc' : (0 : ℝ) < c := by exact_mod_cast hc
  have hn' : (0 : ℝ) < n := by exact_mod_cast hn
  set D : ℝ := ((((a + c) ^ (2 * (a + c)) : ℕ)) : ℝ) with hDdef
  set N : ℝ := (((2 ^ (a + c) * a ^ (2 * a) * c ^ (2 * c) : ℕ)) : ℝ) with hNdef
  have hD : (0 : ℝ) < D := by rw [hDdef]; push_cast; positivity
  have hN : (0 : ℝ) < N := by rw [hNdef]; push_cast; positivity
  have hDN' : D ≤ N := by rw [hDdef, hNdef]; exact_mod_cast hDN
  have hcert' : (n : ℝ) * N < (m : ℝ) * D := by rw [hDdef, hNdef]; exact_mod_cast hcert
  have hR1 : (1 : ℝ) ≤ N / D := (one_le_div hD).2 hDN'
  have hR : N / D < (m : ℝ) / n := by
    rw [div_lt_div_iff₀ hD hn']; nlinarith [hcert']
  have hpade : Real.log (N / D) ≤ (N / D - (N / D)⁻¹) / 2 := log_le_half_sub_inv hR1
  have hmono : (N / D - (N / D)⁻¹) / 2 < ((m : ℝ) / n - ((m : ℝ) / n)⁻¹) / 2 := by
    have hx : (0 : ℝ) < N / D := by positivity
    have hinv : ((m : ℝ) / n)⁻¹ < (N / D)⁻¹ := inv_strictAnti₀ hx hR
    linarith
  have hrate := secureKeyRate_ratio_eq a c ha hc
  rw [← hDdef, ← hNdef] at hrate
  rw [hrate]
  exact mul_lt_mul_of_pos_left (by linarith) (by positivity)

/-! ## 2. The continued-fraction anchor `79/718` and its certificates -/

set_option exponentiation.threshold 100000

/-- The anchor is below threshold: `718^1436 < 2^718 · 79^158 · 639^1278`.
Equivalently `r(79/718) > 0`. -/
theorem cert_718_pos :
    (79 + 639) ^ (2 * (79 + 639)) < 2 ^ (79 + 639) * 79 ^ (2 * 79) * 639 ^ (2 * 639) := by
  decide

/-- `2^718·79^158·639^1278 / 718^1436 > 1.00002787345813950188`. -/
theorem cert_718_ratio_gt :
    100002787345813950188 * ((79 + 639) ^ (2 * (79 + 639)))
      < 100000000000000000000 * (2 ^ (79 + 639) * 79 ^ (2 * 79) * 639 ^ (2 * 639)) := by
  decide

/-- `2^718·79^158·639^1278 / 718^1436 < 1.00002787345813950189`. -/
theorem cert_718_ratio_lt :
    100000000000000000000 * (2 ^ (79 + 639) * 79 ^ (2 * 79) * 639 ^ (2 * 639))
      < 100002787345813950189 * ((79 + 639) ^ (2 * (79 + 639))) := by
  decide

/-- Lower bound for the key rate at the anchor: `r(79/718) > 3.88204313093·10⁻⁸`. -/
theorem secureKeyRate_anchor_gt :
    3882043130930 / 100000000000000000000 < secureKeyRate (79 / 718) := by
  have h := secureKeyRate_gt_of_cert_pade 79 639 100002787345813950188 100000000000000000000
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) cert_718_ratio_gt
  norm_num at h ⊢
  linarith

/-- Upper bound for the key rate at the anchor: `r(79/718) < 3.88204313169·10⁻⁸`. -/
theorem secureKeyRate_anchor_lt :
    secureKeyRate (79 / 718) < 3882043131686 / 100000000000000000000 := by
  have h := secureKeyRate_lt_of_cert_pade 79 639 100002787345813950189 100000000000000000000
    (by norm_num) (by norm_num) (by norm_num) (le_of_lt cert_718_pos) cert_718_ratio_lt
  norm_num at h ⊢
  linarith

/-! ## 3. The derivative bracket on `[79/718, 0.11002787]` -/

/-- `log (639/79) ≤ 2.0904568254`, from `log 2 < 0.6931471808` and the Padé bound
`log (639/632) ≤ (639/632 - 632/639)/2 = 8897/807696`. -/
theorem log_639_div_79_le : Real.log (639 / 79) ≤ 20904568254 / 10000000000 := by
  have hsplit : (639 : ℝ) / 79 = 8 * (639 / 632) := by norm_num
  have h8 : Real.log 8 = 3 * Real.log 2 := by
    rw [show (8 : ℝ) = 2 ^ 3 by norm_num, Real.log_pow]; norm_num
  have hsmall : Real.log (639 / 632) ≤ 8897 / 807696 := by
    have h := log_le_half_sub_inv (x := (639 : ℝ) / 632) (by norm_num)
    norm_num at h ⊢
    linarith
  rw [hsplit, Real.log_mul (by norm_num) (by norm_num), h8]
  have h2 := Real.log_two_lt_d9
  norm_num at h2 ⊢
  linarith

/-- `2.0904563381 ≤ log (88997213/11002787)`, from `0.6931471803 < log 2` and the
Padé bound `log (88997213/88022296) ≥ 2·974917/177019509`. -/
theorem le_log_88997213_div_11002787 :
    20904563381 / 10000000000 ≤ Real.log (88997213 / 11002787) := by
  have hsplit : (88997213 : ℝ) / 11002787 = 8 * (88997213 / 88022296) := by norm_num
  have h8 : Real.log 8 = 3 * Real.log 2 := by
    rw [show (8 : ℝ) = 2 ^ 3 by norm_num, Real.log_pow]; norm_num
  have hsmall : 1949834 / 177019509 ≤ Real.log (88997213 / 88022296) := by
    have h := pade_le_log (x := (88997213 : ℝ) / 88022296) (by norm_num)
    norm_num at h ⊢
    linarith
  rw [hsplit, Real.log_mul (by norm_num) (by norm_num), h8]
  have h2 := Real.log_two_gt_d9
  norm_num at h2 ⊢
  linarith

/-- **Derivative bracket at the anchor scale.**  On `[79/718, 0.11002787]` the
derivative of the binary entropy lies in `[2.0904563381, 2.0904568254]`, an
interval of width `4.9·10⁻⁷`. -/
theorem deriv_binEntropy_bracket_anchor {x : ℝ}
    (hx : x ∈ Icc ((79 : ℝ) / 718) (11002787 / 100000000)) :
    20904563381 / 10000000000 ≤ Real.log (1 - x) - Real.log x ∧
      Real.log (1 - x) - Real.log x ≤ 20904568254 / 10000000000 := by
  obtain ⟨hx1, hx2⟩ := hx
  have hxpos : (0 : ℝ) < x := lt_of_lt_of_le (by norm_num) hx1
  have hx1' : (0 : ℝ) < 1 - x := by
    have : x ≤ 11002787 / 100000000 := hx2
    linarith
  constructor
  · have hA : Real.log (88997213 / 100000000) ≤ Real.log (1 - x) :=
      Real.log_le_log (by norm_num) (by linarith)
    have hB : Real.log x ≤ Real.log (11002787 / 100000000) :=
      Real.log_le_log hxpos (by linarith)
    have hC : Real.log (88997213 / 100000000) - Real.log (11002787 / 100000000)
        = Real.log (88997213 / 11002787) := by
      rw [Real.log_div (by norm_num) (by norm_num), Real.log_div (by norm_num) (by norm_num),
        Real.log_div (by norm_num) (by norm_num)]
      ring
    have := le_log_88997213_div_11002787
    linarith [hA, hB, hC ▸ this]
  · have hA : Real.log (1 - x) ≤ Real.log (639 / 718) :=
      Real.log_le_log hx1' (by linarith)
    have hB : Real.log ((79 : ℝ) / 718) ≤ Real.log x :=
      Real.log_le_log (by norm_num) hx1
    have hC : Real.log ((639 : ℝ) / 718) - Real.log ((79 : ℝ) / 718) = Real.log (639 / 79) := by
      rw [Real.log_div (by norm_num) (by norm_num), Real.log_div (by norm_num) (by norm_num),
        Real.log_div (by norm_num) (by norm_num)]
      ring
    have := log_639_div_79_le
    linarith [hA, hB, hC ▸ this]

/-! ## 4. The mean-value step from an arbitrary rational anchor -/

/-- **Mean value theorem for the binary entropy, at an arbitrary anchor.** -/
theorem exists_mvt_point_at {q p : ℝ} (hq0 : 0 < q) (hqp : q < p) (hp1 : p < 1) :
    ∃ ξ ∈ Ioo q p,
      (Real.log (1 - ξ) - Real.log ξ) * (p - q) = Real.binEntropy p - Real.binEntropy q := by
  have hcont : ContinuousOn Real.binEntropy (Icc q p) := Real.binEntropy_continuous.continuousOn
  have hderiv : ∀ x ∈ Ioo q p, HasDerivAt Real.binEntropy (Real.log (1 - x) - Real.log x) x := by
    intro x hx
    exact Real.hasDerivAt_binEntropy (by nlinarith [hx.1]) (by nlinarith [hx.2])
  obtain ⟨ξ, hξ, hslope⟩ :=
    exists_hasDerivAt_eq_slope Real.binEntropy (fun x => Real.log (1 - x) - Real.log x) hqp
      hcont hderiv
  exact ⟨ξ, hξ, by rw [hslope, div_mul_cancel₀ _ (by linarith : p - q ≠ 0)]⟩

/-- **The refinement engine.**  One mean-value step: given

* a rational anchor `q₀` and an upper barrier `q₁` with `q₀ < p⋆ < q₁`,
* certified bounds `A₁ < (log 2/2 - H₂(q₀)) < A₂` on the entropy defect at the
  anchor (equivalently on half the key rate there), and
* a certified bracket `L ≤ H₂' ≤ U` on `[q₀, q₁]` with `L > 0`,

the zero of the key rate is pinned to `q₀ + A₁/U < p⋆ < q₀ + A₂/L`.  All four
cycles of this development are instances of this single lemma; the achievable
width `A(1/L - 1/U) ≈ (p⋆ - q₀)·(U - L)/L` is quadratic in the anchor's error. -/
theorem newton_enclosure_step {q₀ q₁ A₁ A₂ L U p : ℝ} (hq₀ : 0 < q₀) (hq₁ : q₁ < 1)
    (hlow : q₀ < p) (hhigh : p < q₁) (hpz : secureKeyRate p = 0)
    (hA₁ : A₁ < secureKeyRate q₀ / 2) (hA₂ : secureKeyRate q₀ / 2 < A₂)
    (hbr : ∀ x ∈ Icc q₀ q₁,
      L ≤ Real.log (1 - x) - Real.log x ∧ Real.log (1 - x) - Real.log x ≤ U)
    (hL : 0 < L) :
    q₀ + A₁ / U < p ∧ p < q₀ + A₂ / L := by
  have hp1 : p < 1 := lt_trans hhigh hq₁
  obtain ⟨ξ, hξ, hslope⟩ := exists_mvt_point_at hq₀ hlow hp1
  have hbp : Real.binEntropy p = Real.log 2 / 2 := by
    unfold secureKeyRate at hpz; linarith
  have hA : (Real.log (1 - ξ) - Real.log ξ) * (p - q₀) = secureKeyRate q₀ / 2 := by
    rw [hslope, hbp]; unfold secureKeyRate; ring
  obtain ⟨hLb, hUb⟩ := hbr ξ ⟨le_of_lt hξ.1, le_of_lt (lt_trans hξ.2 hhigh)⟩
  have hd : (0 : ℝ) < p - q₀ := by linarith
  have hU0 : (0 : ℝ) < U := lt_of_lt_of_le hL (le_trans hLb hUb)
  constructor
  · have h : A₁ / U < p - q₀ := by
      rw [div_lt_iff₀ hU0]
      nlinarith [hA, hUb, hd]
    linarith
  · have h : p - q₀ < A₂ / L := by
      rw [lt_div_iff₀ hL]
      nlinarith [hA, hLb, hd]
    linarith

/-! ## 5. Thirteen certified decimals -/

/-- **Thirteen certified decimals.**  Every zero of the BB84 key rate on `[0,1/2]`
satisfies `0.1100278644383 < p⋆ < 0.1100278644384`. -/
theorem threshold_mem_Ioo_thirteen_decimals {p : ℝ} (hp : p ∈ Icc (0 : ℝ) 2⁻¹)
    (hpz : secureKeyRate p = 0) :
    p ∈ Ioo (1100278644383 / 10000000000000 : ℝ) (1100278644384 / 10000000000000) := by
  obtain ⟨h1, h2⟩ := threshold_mem_Ioo_eight_decimals hp hpz
  obtain ⟨hlo, hhi⟩ :=
    newton_enclosure_step (q₀ := (79 : ℝ) / 718) (q₁ := 11002787 / 100000000)
      (A₁ := 1941021565465 / 100000000000000000000)
      (A₂ := 1941021565843 / 100000000000000000000)
      (L := 20904563381 / 10000000000) (U := 20904568254 / 10000000000)
      (by norm_num) (by norm_num) (by linarith) h2 hpz
      (by linarith [secureKeyRate_anchor_gt]) (by linarith [secureKeyRate_anchor_lt])
      (fun x hx => deriv_binEntropy_bracket_anchor hx) (by norm_num)
  constructor
  · calc (1100278644383 / 10000000000000 : ℝ)
        < 79 / 718 + 1941021565465 / 100000000000000000000 / (20904568254 / 10000000000) := by
          norm_num
      _ < p := hlo
  · calc p < 79 / 718 + 1941021565843 / 100000000000000000000 / (20904563381 / 10000000000) :=
          hhi
      _ < 1100278644384 / 10000000000000 := by norm_num

/-- **The first thirteen decimal digits of the BB84 threshold** are
`0.1100278644383`. -/
theorem threshold_floor_thirteen_decimals {p : ℝ} (hp : p ∈ Icc (0 : ℝ) 2⁻¹)
    (hpz : secureKeyRate p = 0) : ⌊(10000000000000 : ℝ) * p⌋ = 1100278644383 := by
  obtain ⟨h1, h2⟩ := threshold_mem_Ioo_thirteen_decimals hp hpz
  apply Int.floor_eq_iff.mpr
  constructor
  · push_cast; linarith
  · push_cast; linarith

/-- **The certified error of the textbook value `11 %`.**  The distance between
the conventional figure `11/100` and the true threshold satisfies
`2.786·10⁻⁵ < |11/100 - p⋆| < 2.787·10⁻⁵`, so quoting `11 %` overstates the
security margin by about `2.8·10⁻⁵` in error rate. -/
theorem abs_eleven_percent_sub_threshold {p : ℝ} (hp : p ∈ Icc (0 : ℝ) 2⁻¹)
    (hpz : secureKeyRate p = 0) :
    2786 / 100000000 < |p - 11 / 100| ∧ |p - 11 / 100| < 2787 / 100000000 := by
  obtain ⟨h1, h2⟩ := threshold_mem_Ioo_eight_decimals hp hpz
  have habs : |p - 11 / 100| = p - 11 / 100 := abs_of_pos (by linarith)
  rw [habs]
  constructor <;> linarith

/-- **Final certified statement.**  The unique quantum bit error rate at which the
asymptotic one-way BB84 secret-key rate vanishes has certified decimal expansion
`p⋆ = 0.1100278644383…`, with a certified interval of width `10⁻¹³`. -/
theorem bb84_threshold_thirteen_decimals :
    ∃! p : ℝ, p ∈ Icc (0 : ℝ) 2⁻¹ ∧ secureKeyRate p = 0 ∧
      ⌊(10000000000000 : ℝ) * p⌋ = 1100278644383 := by
  obtain ⟨p, ⟨hpI, hpz⟩, huniq⟩ := exists_unique_threshold_enclosure
  refine ⟨p, ⟨hpI, hpz, threshold_floor_thirteen_decimals hpI hpz⟩, ?_⟩
  rintro q ⟨hqI, hqz, -⟩
  exact huniq q ⟨hqI, hqz⟩

end BB84