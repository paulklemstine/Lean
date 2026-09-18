import Mathlib
import Shared.QubitTradeResourceSurface
import Shared.ShorPeakCertificationRamp

/-!
# The fungibility ramp: one register bit is worth one sample

*(FACT round-25 #1 — QUBIT-TRADE2, paper 85.  Builds on
`Shared.ShorPeakCertificationRamp` (the per-sample rate) and on
`Shared.QubitTradeResourceSurface` (the shot-compounding law of paper 87).)*

`Shared.ShorPeakCertificationRamp` shows that the single-sample certification
rate of Shor period finding is a **ramp** in the register/period ratio,
`P₁ ≈ q/r²` with `q = 2^t`, rather than a wall at `q = r²`.  Samples compound
it independently, `P_s = 1 - (1 - P₁)^s` (`QubitTradeSurface.succProb`).  This
file proves the consequence that names the round:

> the location of the 50 % contour depends on the register width `t` and the
> sample count `s` only through `t + log₂ s`, up to one bit.

## Main results

* `one_sub_pow_mul_le_one` — the elementary sandwich
  `(1-x)^n (1 + n x) ≤ 1`, the reverse of Bernoulli's inequality; it gives the
  lower rail `succProb_half_of_one_le` of the compounding law, while
  `QubitTradeSurface.succProb_le_mul` gives the upper rail.
* `contour_lower`, `contour_upper` — **the contour band**: with the ramp
  per-shot probability `rampProb c t = min 1 (c·2^t)`,
  `c·s·2^t ≥ 1 ⟹ P ≥ 1/2` and `P ≥ 1/2 ⟹ c·s·2^t ≥ 1/2`.  The half-success
  contour is therefore pinned inside the unit-slope band
  `1/2 ≤ c·s·2^t ≤ 1` — a ramp, not a wall, and an *exact* exchange rate of
  one bit per sample doubling up to one bit of slack.
* `exchange_bit_le_doubling` / `exchange_two_doublings_buy_bit` — the two
  directions of the exchange law at the level of configurations, with no
  reference to a threshold: a doubling of `s` is worth *at most* one bit, and
  two doublings are worth *at least* one bit.
* `tStar_le_pow_two_mul`, `tStar_four_pow_le`, `exchange_band` — the same law for the
  threshold width `tStar`: `t*(2^m s) ≥ t*(s) - m` and `t*(4^m s) ≤ t*(s) - m`.
  Measured slope of the round: `{s=2: -0, s=5: -2, s=20: -4, s=100: -6}`
  against `-log₂ s = {-1, -2.3, -4.3, -6.6}` — inside the proved band
  `[1/2, 1]` bits per doubling.
* `phase_boundary_lower` / `phase_boundary_upper` — the same statement carried
  back to the arithmetic ramp of `Shared.ShorPeakCertificationRamp`: the
  contour of the *exact* peak-certification model sits at `s·q ≍ r²`.
-/

namespace QubitSampleExchange

open QubitTradeSurface

/-! ## 1. The two rails of the compounding law -/

/-- **Reverse Bernoulli.**  `(1-x)^n (1 + n x) ≤ 1` for `0 ≤ x ≤ 1`.  Proof:
multiply the Bernoulli bound `1 + n x ≤ (1+x)^n` by `(1-x)^n ≥ 0` and use
`(1-x²)^n ≤ 1`. -/
theorem one_sub_pow_mul_le_one {x : ℝ} (h0 : 0 ≤ x) (h1 : x ≤ 1) (n : ℕ) :
    (1 - x) ^ n * (1 + n * x) ≤ 1 := by
  have hb : (1 : ℝ) + n * x ≤ (1 + x) ^ n := one_add_mul_le_pow (by linarith) n
  have hnn : (0 : ℝ) ≤ (1 - x) ^ n := pow_nonneg (by linarith) n
  have hprod : (1 - x) ^ n * (1 + x) ^ n = (1 - x ^ 2) ^ n := by
    rw [← mul_pow]; ring_nf
  have hle : (1 - x ^ 2) ^ n ≤ 1 := pow_le_one₀ (by nlinarith) (by nlinarith)
  calc (1 - x) ^ n * (1 + n * x) ≤ (1 - x) ^ n * (1 + x) ^ n := by nlinarith
    _ = (1 - x ^ 2) ^ n := hprod
    _ ≤ 1 := hle

/-- **Lower rail of the compounding law.**  Once the expected number of
successes `n·x` reaches `1`, the compounded probability is at least `1/2`. -/
theorem succProb_half_of_one_le {x : ℝ} (h0 : 0 ≤ x) (h1 : x ≤ 1) {n : ℕ}
    (hn : 1 ≤ n * x) : 1 / 2 ≤ succProb x n := by
  have hkey := one_sub_pow_mul_le_one h0 h1 n
  have hnn : (0 : ℝ) ≤ (1 - x) ^ n := pow_nonneg (by linarith) n
  have h2 : (1 - x) ^ n * 2 ≤ 1 := by nlinarith
  simp only [succProb]
  linarith

/-- **Upper rail of the compounding law.**  Below `n·x = 1/2` the compounded
probability is still below `1/2` (union bound, from paper 87). -/
theorem succProb_lt_half {x : ℝ} (h1 : x ≤ 1) {n : ℕ} (hn : n * x < 1 / 2) :
    succProb x n < 1 / 2 := lt_of_le_of_lt (succProb_le_mul h1 n) hn

/-! ## 2. The ramp per-shot probability -/

/-- The ramp per-shot success probability at register width `t`: linear in
`2^t` with slope `c` (the arithmetic model has `c = 1/r²`), saturating at `1`.
-/
noncomputable def rampProb (c : ℝ) (t : ℕ) : ℝ := min 1 (c * 2 ^ t)

lemma rampProb_nonneg {c : ℝ} (hc : 0 ≤ c) (t : ℕ) : 0 ≤ rampProb c t :=
  le_min (by norm_num) (by positivity)

lemma rampProb_le_one (c : ℝ) (t : ℕ) : rampProb c t ≤ 1 := min_le_left _ _

lemma rampProb_le_lin (c : ℝ) (t : ℕ) : rampProb c t ≤ c * 2 ^ t := min_le_right _ _

/-- **The halving step.**  Removing one register bit at most halves the
per-shot probability — in the linear part it halves it exactly, in the
saturated part less. -/
lemma rampProb_sq {c : ℝ} (hc : 0 ≤ c) (t : ℕ) :
    1 - rampProb c (t + 1) ≤ (1 - rampProb c t) ^ 2 := by
  have h2 : c * 2 ^ (t + 1) = 2 * (c * 2 ^ t) := by ring
  set a := c * 2 ^ t with ha
  have hann : 0 ≤ a := by positivity
  simp only [rampProb, h2]
  rcases le_or_gt 1 a with h | h
  · rw [min_eq_left (by linarith), min_eq_left (by linarith)]
    norm_num
  · rw [min_eq_right h.le]
    rcases le_or_gt 1 (2 * a) with h2a | h2a
    · rw [min_eq_left h2a]; nlinarith
    · rw [min_eq_right h2a.le]; nlinarith

/-! ## 3. The exchange law on configurations -/

/-- A configuration `(t, s)` *reaches* the target if its compounded success
probability is at least `1/2`. -/
def Reaches (c : ℝ) (t s : ℕ) : Prop := 1 / 2 ≤ succProb (rampProb c t) s

/-- **A sample doubling is worth at most one register bit.**  Whatever `2s`
samples achieve at width `t`, `s` samples achieve at width `t+1`. -/
theorem exchange_bit_le_doubling {c : ℝ} (hc : 0 ≤ c) (t s : ℕ)
    (h : Reaches c t (2 * s)) : Reaches c (t + 1) s := by
  have hx1 : rampProb c (t + 1) ≤ 1 := rampProb_le_one _ _
  have hkey : (1 - rampProb c (t + 1)) ^ s ≤ (1 - rampProb c t) ^ (2 * s) := by
    have hsq := rampProb_sq hc t
    have hnn : (0 : ℝ) ≤ 1 - rampProb c (t + 1) := by linarith
    calc (1 - rampProb c (t + 1)) ^ s ≤ ((1 - rampProb c t) ^ 2) ^ s :=
          pow_le_pow_left₀ hnn hsq s
      _ = (1 - rampProb c t) ^ (2 * s) := by rw [← pow_mul]
  simp only [Reaches, succProb] at h ⊢
  linarith

/-- **Two sample doublings buy a register bit.**  Whatever `s` samples achieve
at width `t+1`, `4s` samples achieve at width `t`. -/
theorem exchange_two_doublings_buy_bit {c : ℝ} (hc : 0 < c) {t s : ℕ}
    (h : Reaches c (t + 1) s) : Reaches c t (4 * s) := by
  have hx1 : rampProb c (t + 1) ≤ 1 := rampProb_le_one _ _
  -- the union bound forces the expected count at `(t+1, s)` to be at least `1/2`
  have hub : 1 / 2 ≤ (s : ℝ) * rampProb c (t + 1) :=
    le_trans h (succProb_le_mul hx1 s)
  -- one bit down at most halves the per-shot probability
  have hhalf : rampProb c (t + 1) ≤ 2 * rampProb c t := by
    have h2 : c * 2 ^ (t + 1) = 2 * (c * 2 ^ t) := by ring
    simp only [rampProb, h2]
    rcases le_or_gt 1 (c * 2 ^ t) with hge | hlt
    · rw [min_eq_left (by nlinarith), min_eq_left hge]; norm_num
    · rw [min_eq_right hlt.le]
      rcases le_or_gt 1 (2 * (c * 2 ^ t)) with h2a | h2a
      · rw [min_eq_left h2a]; linarith
      · rw [min_eq_right h2a.le]
  have hone : 1 ≤ ((4 * s : ℕ) : ℝ) * rampProb c t := by
    push_cast
    nlinarith [hub, hhalf]
  exact succProb_half_of_one_le (rampProb_nonneg hc.le t) (rampProb_le_one c t) hone

/-! ## 4. The contour band: unit slope in `t + log₂ s` -/

/-- **Contour, achievability side.**  The configuration reaches the target as
soon as the *exchange coordinate* `c·s·2^t` reaches `1`. -/
theorem contour_lower {c : ℝ} (hc : 0 < c) (t s : ℕ)
    (h : 1 ≤ c * s * 2 ^ t) : Reaches c t s := by
  have hone : 1 ≤ (s : ℝ) * rampProb c t := by
    simp only [rampProb]
    rcases le_or_gt 1 (c * 2 ^ t) with hge | hlt
    · rw [min_eq_left hge]
      have hs : 1 ≤ (s : ℝ) := by
        rcases Nat.eq_zero_or_pos s with h0 | h1
        · exfalso; rw [h0] at h; simp at h; linarith
        · exact_mod_cast h1
      linarith
    · rw [min_eq_right hlt.le]; nlinarith
  exact succProb_half_of_one_le (rampProb_nonneg hc.le t) (rampProb_le_one c t) hone

/-- **Contour, converse side.**  Reaching the target forces the exchange
coordinate to be at least `1/2`. -/
theorem contour_upper {c : ℝ} (t s : ℕ) (h : Reaches c t s) :
    1 / 2 ≤ c * s * 2 ^ t := by
  have h1 : 1 / 2 ≤ (s : ℝ) * rampProb c t :=
    le_trans h (succProb_le_mul (rampProb_le_one c t) s)
  have h2 : (s : ℝ) * rampProb c t ≤ (s : ℝ) * (c * 2 ^ t) := by
    have : (0 : ℝ) ≤ (s : ℝ) := Nat.cast_nonneg s
    nlinarith [rampProb_le_lin c t]
  nlinarith

/-- **The fungibility ramp.**  The half-success contour of the `(t, s)` phase
diagram is pinned between the two parallel unit-slope lines
`c·s·2^t = 1/2` and `c·s·2^t = 1`: the diagram is a ramp of exchange rate
exactly one register bit per sample doubling, up to one bit of width, and in
particular contains no vertical wall. -/
theorem contour_band {c : ℝ} (hc : 0 < c) (t s : ℕ) :
    (1 ≤ c * s * 2 ^ t → Reaches c t s) ∧ (Reaches c t s → 1 / 2 ≤ c * s * 2 ^ t) :=
  ⟨contour_lower hc t s, contour_upper t s⟩

/-- **Exact fungibility of the exchange coordinate.**  Removing a register bit
and doubling the sample count leave the coordinate `c·s·2^t` unchanged: the
trade is one-for-one along the whole diagram. -/
theorem exchange_coordinate_invariant (c : ℝ) (t s : ℕ) :
    c * ((2 * s : ℕ) : ℝ) * 2 ^ t = c * (s : ℝ) * 2 ^ (t + 1) := by
  push_cast; ring

/-! ## 5. The threshold width and its `-log₂ s` shift -/

open scoped Classical in
/-- The least register width at which `s` samples reach the target. -/
noncomputable def tStar (c : ℝ) (s : ℕ) : ℕ := sInf {t | Reaches c t s}

theorem exists_reaches {c : ℝ} (hc : 0 < c) {s : ℕ} (hs : 0 < s) :
    ∃ t, Reaches c t s := by
  obtain ⟨n, hn⟩ := pow_unbounded_of_one_lt (1 / c) (by norm_num : (1 : ℝ) < 2)
  refine ⟨n, contour_lower hc n s ?_⟩
  rw [div_lt_iff₀ hc] at hn
  have hs1 : (1 : ℝ) ≤ (s : ℝ) := by exact_mod_cast hs
  nlinarith [pow_pos (by norm_num : (0:ℝ) < 2) n]

theorem reaches_tStar {c : ℝ} (hc : 0 < c) {s : ℕ} (hs : 0 < s) :
    Reaches c (tStar c s) s :=
  Nat.sInf_mem (exists_reaches hc hs)

theorem tStar_le {c : ℝ} {t s : ℕ} (h : Reaches c t s) : tStar c s ≤ t :=
  Nat.sInf_le h

/-- More samples never hurt: the success probability is monotone in `s`. -/
theorem reaches_mono {c : ℝ} (hc : 0 < c) {t s s' : ℕ} (hss : s ≤ s')
    (h : Reaches c t s) : Reaches c t s' := by
  have hx0 : 0 ≤ rampProb c t := rampProb_nonneg hc.le t
  have hx1 : rampProb c t ≤ 1 := rampProb_le_one c t
  have hpow : (1 - rampProb c t) ^ s' ≤ (1 - rampProb c t) ^ s :=
    pow_le_pow_of_le_one (by linarith) (by linarith) hss
  simp only [Reaches, succProb] at h ⊢
  linarith

/-- The threshold width is antitone in the sample budget. -/
theorem tStar_anti {c : ℝ} (hc : 0 < c) {s s' : ℕ} (hss : s ≤ s') (hs : 0 < s) :
    tStar c s' ≤ tStar c s :=
  tStar_le (reaches_mono hc hss (reaches_tStar hc hs))

/-- **One doubling is worth at most one bit** for the threshold width. -/
theorem tStar_le_two_mul_succ {c : ℝ} (hc : 0 < c) {s : ℕ} (hs : 0 < s) :
    tStar c s ≤ tStar c (2 * s) + 1 :=
  tStar_le (exchange_bit_le_doubling hc.le _ _ (reaches_tStar hc (by omega)))

/-- **Two doublings are worth at least one bit** for the threshold width. -/
theorem tStar_four_mul_add_le {c : ℝ} (hc : 0 < c) {s : ℕ} (hs : 0 < s)
    (h0 : tStar c s ≠ 0) : tStar c (4 * s) + 1 ≤ tStar c s := by
  obtain ⟨T, hT⟩ : ∃ T, tStar c s = T + 1 := ⟨tStar c s - 1, by omega⟩
  have hreach : Reaches c (T + 1) s := hT ▸ reaches_tStar hc hs
  have := tStar_le (exchange_two_doublings_buy_bit hc hreach)
  omega

/-- **The exchange law, lower slope.**  Multiplying the sample budget by `2^m`
lowers the threshold width by at most `m` bits: samples can never buy register
bits faster than one per doubling. -/
theorem tStar_le_pow_two_mul {c : ℝ} (hc : 0 < c) :
    ∀ (m s : ℕ), 0 < s → tStar c s ≤ tStar c (2 ^ m * s) + m := by
  intro m
  induction m with
  | zero => intro s _; simp
  | succ m ih =>
      intro s hs
      have h1 : tStar c s ≤ tStar c (2 * s) + 1 := tStar_le_two_mul_succ hc hs
      have h2 : tStar c (2 * s) ≤ tStar c (2 ^ m * (2 * s)) + m := ih (2 * s) (by omega)
      have hrw : 2 ^ m * (2 * s) = 2 ^ (m + 1) * s := by ring
      rw [hrw] at h2
      omega

/-- **The exchange law, upper slope.**  Multiplying the sample budget by `4^m`
lowers the threshold width by at least `m` bits.  Together with
`tStar_le_pow_two_mul` the measured exchange rate is pinned between one half
and one register bit per sample doubling. -/
theorem tStar_four_pow_le {c : ℝ} (hc : 0 < c) :
    ∀ (m s : ℕ), 0 < s → tStar c (4 ^ m * s) ≤ tStar c s - m := by
  intro m
  induction m with
  | zero => intro s _; simp
  | succ m ih =>
      intro s hs
      have hstep : tStar c (4 * s) ≤ tStar c s - 1 := by
        rcases Nat.eq_zero_or_pos (tStar c s) with h0 | h0
        · have := tStar_anti hc (show s ≤ 4 * s by omega) hs
          omega
        · have := tStar_four_mul_add_le hc hs (by omega)
          omega
      have h3 : tStar c (4 ^ m * (4 * s)) ≤ tStar c (4 * s) - m := ih (4 * s) (by omega)
      have hrw : 4 ^ m * (4 * s) = 4 ^ (m + 1) * s := by ring
      rw [hrw] at h3
      omega

/-- **The exchange band.**  Paying `2m` sample doublings buys between `m` and
`2m` register bits: the exchange rate is one bit per doubling, up to a factor
two.  This is the proved form of the measured law
`t*(s) shifts by ≈ -log₂ s`. -/
theorem exchange_band {c : ℝ} (hc : 0 < c) (m s : ℕ) (hs : 0 < s) :
    tStar c (4 ^ m * s) ≤ tStar c s - m ∧ tStar c s ≤ tStar c (4 ^ m * s) + 2 * m := by
  refine ⟨tStar_four_pow_le hc m s hs, ?_⟩
  have h := tStar_le_pow_two_mul hc (2 * m) s hs
  have hrw : (2 : ℕ) ^ (2 * m) * s = 4 ^ m * s := by
    rw [pow_mul]; norm_num
  rw [hrw] at h
  omega

/-! ## 6. Back to the arithmetic ramp -/

open ShorPeakRamp

/-- The exact per-sample certification rate of the peak model. -/
noncomputable def peakRate (q r : ℕ) : ℝ := ((certPeaks q r).card : ℝ) / r

lemma peakRate_nonneg (q r : ℕ) : 0 ≤ peakRate q r := by
  unfold peakRate; positivity

lemma peakRate_le_one (q r : ℕ) (hr : 0 < r) : peakRate q r ≤ 1 := by
  have hcard : (certPeaks q r).card ≤ r := by
    simpa using Finset.card_filter_le (Finset.range r) (CertRes q r)
  have hr0 : (0 : ℝ) < r := by exact_mod_cast hr
  rw [peakRate, div_le_one hr0]
  exact_mod_cast hcard

/-- **Phase boundary of the arithmetic model, achievability.**  If the sample
budget times the (proved) lower rail of the ramp reaches `1`, then `s` samples
certify with probability at least `1/2`.  Since the lower rail is
`q/r² - 1/r`, the contour sits at `s·q ≍ r²`: one register bit is worth one
sample. -/
theorem phase_boundary_lower (q r s : ℕ) (hr : 0 < r) (hco : Nat.Coprime q r)
    (hsat : 2 * (q / (2 * r)) < r) (h : 1 ≤ (s : ℝ) * ((q : ℝ) / r ^ 2 - 1 / r)) :
    1 / 2 ≤ succProb (peakRate q r) s := by
  have hramp := ramp_lower q r hr hco hsat
  have hs : (0 : ℝ) ≤ (s : ℝ) := Nat.cast_nonneg s
  have : (s : ℝ) * ((q : ℝ) / r ^ 2 - 1 / r) ≤ (s : ℝ) * peakRate q r := by
    have := hramp
    unfold peakRate
    nlinarith
  exact succProb_half_of_one_le (peakRate_nonneg q r) (peakRate_le_one q r hr)
    (by linarith)

/-- **Phase boundary of the arithmetic model, converse.**  Below the upper rail
the target is out of reach, again at `s·q ≍ r²`. -/
theorem phase_boundary_upper (q r s : ℕ) (hr : 0 < r) (hco : Nat.Coprime q r)
    (hsat : 2 * (q / (2 * r)) < r)
    (h : (s : ℝ) * ((q : ℝ) / r ^ 2 + 1 / r) < 1 / 2) :
    succProb (peakRate q r) s < 1 / 2 := by
  have hramp := ramp_upper q r hr hco hsat
  have hs : (0 : ℝ) ≤ (s : ℝ) := Nat.cast_nonneg s
  have hle : (s : ℝ) * peakRate q r ≤ (s : ℝ) * ((q : ℝ) / r ^ 2 + 1 / r) := by
    unfold peakRate at *
    nlinarith
  exact succProb_lt_half (peakRate_le_one q r hr) (by linarith)

end QubitSampleExchange