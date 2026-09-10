/-
# Cycle 5c: the rescaling law for window saturation scales, and its failure at α = 1/2

Let `B*_α(θ)` be the **saturation scale** of the `α`-dial at level `θ`: the
least window edge whose effective window size reaches `θ`
(`satScale (dial α) θ`).  This file proves:

1. **Rescaling law** (`rescaling_law`).  For `1/2 < α < 1`,

   `((1-α)² θ)^{1/(2-2α)} ≤ B*_α(θ) ≤ (2α θ/(2α-1))^{1/(2-2α)} + 1`,

   i.e. `B*_α(θ) = Θ(θ^{1/(2-2α)})` with explicit constants.  The predicted
   exponent `1/(2-2α)` is confirmed, and the constants blow up as `α ↓ 1/2`
   (through `2α/(2α-1) → ∞`) and as `α ↑ 1` (through the exponent).
   `rescaling_law_three_quarters` records the instance `α = 3/4`, exponent `2`.

2. **Failure at `α = 1/2`** (`sqrt_dial_no_uniform_window_bound`).  No linear —
   in fact no *uniform* — window bound survives: for every constant `C` there is
   a level `θ` at which every saturating window exceeds `C θ`.  The predicted
   exponent at `α = 1/2` is `1`, so the law fails exactly at the boundary; the
   obstruction is the logarithmic divergence of the square mass `P_1`.
   The matching positive statement `sqrt_dial_ess_ge` shows the true growth is
   `Θ(θ log θ)`, only a logarithm away.

3. **Exponential harmonic scale** (`harmonic_needs_exponential_window`).  At
   `α = 1` the scale is *exponential*: reaching level `θ` needs `B > 2^k`
   whenever `(1+k)² < θ`.  This is the `α → 1` degeneration of the exponent
   `1/(2-2α) → ∞`.

4. **Transport** (`transport_level_from_harmonic`, `transport_to_alpha`).  A
   measured harmonic saturation edge `B*` caps the level that was actually
   attained, `θ ≤ (1 + ⌈log₂ B*⌉)²`, and that cap transports to an explicit
   window bound for every other dial.  `harmonic_level_at_400` and
   `sqrt_scale_transported_from_400` carry this out for the recorded `B* = 400`.

5. **Lab notes** — proved two-sided intervals for the score at the stored window
   edges `B ∈ {50, 100, 200, 400, 800}` and both dials `α ∈ {1/2, 1}`.
-/
import Combinatorics.WindowSaturationPowerSums

open Finset

namespace WindowSaturation

namespace Dial

/-! ## Two rpow utilities -/

lemma rpow_sq {x : ℝ} (hx : 0 ≤ x) (a : ℝ) : (x ^ a) ^ 2 = x ^ (2 * a) := by
  rw [← Real.rpow_natCast (x ^ a) 2, ← Real.rpow_mul hx]
  norm_num
  ring_nf

lemma rpow_inv_cancel {Y : ℝ} (hY : 0 ≤ Y) {e : ℝ} (he : 0 < e) : (Y ^ (1 / e)) ^ e = Y := by
  rw [← Real.rpow_mul hY, one_div, inv_mul_cancel₀ (ne_of_gt he), Real.rpow_one]

lemma rpow_cancel_inv {x : ℝ} (hx : 0 ≤ x) {e : ℝ} (he : 0 < e) : (x ^ e) ^ (1 / e) = x := by
  rw [← Real.rpow_mul hx, one_div, mul_inv_cancel₀ (ne_of_gt he), Real.rpow_one]

/-! ## The saturation scale -/

/-- The **saturation scale**: the least window edge at which the effective window
size of the dial `w` reaches the level `θ`. -/
noncomputable def satScale (w : ℕ → ℝ) (theta : ℝ) : ℕ := sInf {B | theta ≤ ess w B}

lemma satScale_le {w : ℕ → ℝ} {theta : ℝ} {B : ℕ} (h : theta ≤ ess w B) :
    satScale w theta ≤ B := Nat.sInf_le h

lemma satScale_spec {w : ℕ → ℝ} {theta : ℝ} {B : ℕ} (h : theta ≤ ess w B) :
    theta ≤ ess w (satScale w theta) :=
  Nat.sInf_mem (s := {B | theta ≤ ess w B}) ⟨B, h⟩

/-! ## Two-sided bounds for the effective window size of the `α`-dial -/

/-- **Upper bound.**  For `1/2 < α < 1` the effective window size is at most
`B^{2-2α}/(1-α)²`. -/
theorem ess_dial_le {alpha : ℝ} (h2 : 1 / 2 < alpha) (h1 : alpha < 1) {B : ℕ} (hB : 1 ≤ B) :
    ess (dial alpha) B ≤ (B : ℝ) ^ (2 - 2 * alpha) / (1 - alpha) ^ 2 := by
  have ha0 : 0 < alpha := by linarith
  have hB0 : (0:ℝ) ≤ B := Nat.cast_nonneg B
  have hP : wsum (dial alpha) B ≤ (B : ℝ) ^ (1 - alpha) / (1 - alpha) :=
    wsum_dial_le ha0 h1 B
  have hPnn : 0 ≤ wsum (dial alpha) B := wsum_dial_nonneg alpha B
  have hQ : 1 ≤ wsum (dial (2 * alpha)) B := one_le_wsum_dial _ hB
  have hsq : (wsum (dial alpha) B) ^ 2 ≤ (B : ℝ) ^ (2 - 2 * alpha) / (1 - alpha) ^ 2 := by
    have := mul_self_le_mul_self hPnn hP
    rw [← sq, ← sq, div_pow, rpow_sq hB0 (1 - alpha)] at this
    have hexp : 2 * (1 - alpha) = 2 - 2 * alpha := by ring
    rwa [hexp] at this
  rw [ess_dial]
  calc (wsum (dial alpha) B) ^ 2 / wsum (dial (2 * alpha)) B
      ≤ (wsum (dial alpha) B) ^ 2 / 1 := by
        apply div_le_div_of_nonneg_left (sq_nonneg _) zero_lt_one hQ
    _ = (wsum (dial alpha) B) ^ 2 := by ring
    _ ≤ (B : ℝ) ^ (2 - 2 * alpha) / (1 - alpha) ^ 2 := hsq

/-- **Lower bound.**  For `1/2 < α < 1` the effective window size is at least
`((2α-1)/(2α)) B^{2-2α}`. -/
theorem ess_dial_ge {alpha : ℝ} (h2 : 1 / 2 < alpha) (h1 : alpha < 1) {B : ℕ} (hB : 1 ≤ B) :
    (2 * alpha - 1) / (2 * alpha) * (B : ℝ) ^ (2 - 2 * alpha) ≤ ess (dial alpha) B := by
  have ha0 : 0 < alpha := by linarith
  have hB0 : (0:ℝ) ≤ B := Nat.cast_nonneg B
  have hq : 1 < 2 * alpha := by linarith
  have hP : (B : ℝ) ^ (1 - alpha) ≤ wsum (dial alpha) B := wsum_dial_ge ha0.le hB
  have hPnn : (0:ℝ) ≤ (B : ℝ) ^ (1 - alpha) := Real.rpow_nonneg hB0 _
  have hQ : wsum (dial (2 * alpha)) B ≤ 2 * alpha / (2 * alpha - 1) := by
    have := wsum_dial_bdd hq B
    simpa using this
  have hQpos : 0 < wsum (dial (2 * alpha)) B := wsum_dial_pos _ hB
  have hsq : (B : ℝ) ^ (2 - 2 * alpha) ≤ (wsum (dial alpha) B) ^ 2 := by
    have := mul_self_le_mul_self hPnn hP
    rw [← sq, ← sq, rpow_sq hB0 (1 - alpha)] at this
    have hexp : 2 * (1 - alpha) = 2 - 2 * alpha := by ring
    rwa [hexp] at this
  rw [ess_dial, le_div_iff₀ hQpos]
  have hbound : (2 * alpha - 1) / (2 * alpha) * (B : ℝ) ^ (2 - 2 * alpha)
      * wsum (dial (2 * alpha)) B
      ≤ (2 * alpha - 1) / (2 * alpha) * (B : ℝ) ^ (2 - 2 * alpha) * (2 * alpha / (2 * alpha - 1)) := by
    apply mul_le_mul_of_nonneg_left hQ
    have : (0:ℝ) ≤ (B : ℝ) ^ (2 - 2 * alpha) := Real.rpow_nonneg hB0 _
    have h21 : (0:ℝ) < (2 * alpha - 1) / (2 * alpha) := by
      apply div_pos <;> linarith
    positivity
  have hne1 : (2 * alpha - 1) ≠ 0 := by linarith
  have hne2 : (2 * alpha) ≠ 0 := by linarith
  have hsimp : (2 * alpha - 1) / (2 * alpha) * (B : ℝ) ^ (2 - 2 * alpha)
      * (2 * alpha / (2 * alpha - 1)) = (B : ℝ) ^ (2 - 2 * alpha) := by
    field_simp
  rw [hsimp] at hbound
  linarith [hbound, hsq]

/-! ## The rescaling law -/

/-- The `α`-dial reaches level `θ` at the explicit window
`⌈(2αθ/(2α-1))^{1/(2-2α)}⌉`. -/
theorem ess_dial_saturates {alpha : ℝ} (h2 : 1 / 2 < alpha) (h1 : alpha < 1) {theta : ℝ}
    (hθ : 1 ≤ theta) :
    theta ≤ ess (dial alpha) ⌈(2 * alpha / (2 * alpha - 1) * theta) ^ (1 / (2 - 2 * alpha))⌉₊ := by
  have hexp : 0 < 2 - 2 * alpha := by linarith
  have hc : 1 < 2 * alpha / (2 * alpha - 1) := by
    rw [lt_div_iff₀ (by linarith)]
    linarith
  have hY : (1:ℝ) < 2 * alpha / (2 * alpha - 1) * theta := by nlinarith
  have hYnn : (0:ℝ) ≤ 2 * alpha / (2 * alpha - 1) * theta := by linarith
  set X : ℝ := (2 * alpha / (2 * alpha - 1) * theta) ^ (1 / (2 - 2 * alpha)) with hX
  have hX1 : 1 < X := by
    rw [hX]
    exact Real.one_lt_rpow_iff_of_pos (by linarith) |>.mpr (Or.inl ⟨hY, div_pos one_pos hexp⟩)
  have hceil : X ≤ (⌈X⌉₊ : ℝ) := Nat.le_ceil X
  have hN1 : 1 ≤ ⌈X⌉₊ := by
    have : (1:ℝ) ≤ (⌈X⌉₊ : ℝ) := le_trans hX1.le hceil
    exact_mod_cast this
  have hpow : 2 * alpha / (2 * alpha - 1) * theta ≤ ((⌈X⌉₊ : ℕ) : ℝ) ^ (2 - 2 * alpha) := by
    have h := Real.rpow_le_rpow (by linarith) hceil hexp.le
    rwa [hX, rpow_inv_cancel hYnn hexp] at h
  have hlow := ess_dial_ge h2 h1 (B := ⌈X⌉₊) hN1
  have hne1 : (2 * alpha - 1) ≠ 0 := by linarith
  have hne2 : (2 * alpha) ≠ 0 := by linarith
  have hfac : (2 * alpha - 1) / (2 * alpha) * (2 * alpha / (2 * alpha - 1) * theta) = theta := by
    field_simp
  have hmul : (2 * alpha - 1) / (2 * alpha) * (2 * alpha / (2 * alpha - 1) * theta)
      ≤ (2 * alpha - 1) / (2 * alpha) * ((⌈X⌉₊ : ℝ) ^ (2 - 2 * alpha)) := by
    apply mul_le_mul_of_nonneg_left hpow
    apply le_of_lt
    apply div_pos <;> linarith
  rw [hfac] at hmul
  linarith [hlow, hmul]

/-- **The rescaling law.**  For `1/2 < α < 1` the saturation scale of the
`α`-dial at level `θ` is `Θ(θ^{1/(2-2α)})`, with the explicit constants
`(1-α)²` and `2α/(2α-1)` inside the power. -/
theorem rescaling_law {alpha : ℝ} (h2 : 1 / 2 < alpha) (h1 : alpha < 1) {theta : ℝ}
    (hθ : 1 ≤ theta) :
    ((1 - alpha) ^ 2 * theta) ^ (1 / (2 - 2 * alpha)) ≤ (satScale (dial alpha) theta : ℝ) ∧
      (satScale (dial alpha) theta : ℝ)
        ≤ (2 * alpha / (2 * alpha - 1) * theta) ^ (1 / (2 - 2 * alpha)) + 1 := by
  have hexp : 0 < 2 - 2 * alpha := by linarith
  have hsat := ess_dial_saturates h2 h1 hθ
  refine ⟨?_, ?_⟩
  · -- lower bound: any saturating window is at least this large
    have hmem := satScale_spec hsat
    set B := satScale (dial alpha) theta with hB
    have hB1 : 1 ≤ B := by
      by_contra hcon
      have : B = 0 := by omega
      rw [this] at hmem
      simp [ess_zero] at hmem
      linarith
    have hup := ess_dial_le h2 h1 hB1
    have hstep : (1 - alpha) ^ 2 * theta ≤ (B : ℝ) ^ (2 - 2 * alpha) := by
      have hle : theta ≤ (B : ℝ) ^ (2 - 2 * alpha) / (1 - alpha) ^ 2 := le_trans hmem hup
      rw [le_div_iff₀ (pow_pos (by linarith : (0:ℝ) < 1 - alpha) 2)] at hle
      linarith
    have hmono := Real.rpow_le_rpow (by nlinarith [sq_nonneg (1 - alpha)]) hstep
      (le_of_lt (div_pos one_pos hexp))
    rwa [rpow_cancel_inv (Nat.cast_nonneg B) hexp] at hmono
  · -- upper bound: the explicit window above already saturates
    have hle := satScale_le hsat
    have hceil : ((⌈(2 * alpha / (2 * alpha - 1) * theta) ^ (1 / (2 - 2 * alpha))⌉₊ : ℕ) : ℝ)
        < (2 * alpha / (2 * alpha - 1) * theta) ^ (1 / (2 - 2 * alpha)) + 1 :=
      Nat.ceil_lt_add_one (Real.rpow_nonneg
        (mul_nonneg (le_of_lt (div_pos (by linarith) (by linarith))) (by linarith)) _)
    have : ((satScale (dial alpha) theta : ℕ) : ℝ)
        ≤ ((⌈(2 * alpha / (2 * alpha - 1) * theta) ^ (1 / (2 - 2 * alpha))⌉₊ : ℕ) : ℝ) := by
      exact_mod_cast hle
    linarith

/-- **The predicted exponent, confirmed at `α = 3/4`**: the saturation scale is
quadratic in the level, `1/(2-2·(3/4)) = 2`. -/
theorem rescaling_law_three_quarters {theta : ℝ} (hθ : 1 ≤ theta) :
    (theta / 16) ^ 2 ≤ (satScale (dial (3 / 4)) theta : ℝ) ∧
      (satScale (dial (3 / 4)) theta : ℝ) ≤ (3 * theta) ^ 2 + 1 := by
  have h := rescaling_law (alpha := 3 / 4) (by norm_num) (by norm_num) hθ
  have hexp : (1 : ℝ) / (2 - 2 * (3 / 4)) = 2 := by norm_num
  rw [hexp] at h
  have h2 : ∀ z : ℝ, 0 ≤ z → z ^ (2 : ℝ) = z ^ 2 := by
    intro z hz
    rw [show (2:ℝ) = ((2:ℕ) : ℝ) by norm_num, Real.rpow_natCast]
  obtain ⟨hlow, hup⟩ := h
  constructor
  · have hz : (0:ℝ) ≤ (1 - 3 / 4) ^ 2 * theta := by nlinarith
    rw [h2 _ hz] at hlow
    have heq : ((1 - 3 / 4 : ℝ) ^ 2 * theta) = theta / 16 := by ring
    rw [heq] at hlow
    exact hlow
  · have hz : (0:ℝ) ≤ 2 * (3 / 4) / (2 * (3 / 4) - 1) * theta := by norm_num; linarith
    rw [h2 _ hz] at hup
    have heq : (2 * (3 / 4 : ℝ) / (2 * (3 / 4) - 1) * theta) = 3 * theta := by norm_num
    rw [heq] at hup
    exact hup

/-! ## The boundary case `α = 1/2` -/

lemma dial_half_sq (B : ℕ) : wsum (dial (2 * (1 / 2 : ℝ))) B = wsum (dial 1) B := by
  norm_num

/-- At `α = 1/2` the effective window size is at most `4B / P_1(B)`. -/
theorem sqrt_dial_ess_le {B : ℕ} (hB : 1 ≤ B) :
    ess (dial (1 / 2 : ℝ)) B ≤ 4 * B / wsum (dial 1) B := by
  have hB0 : (0:ℝ) ≤ B := Nat.cast_nonneg B
  have hP : wsum (dial (1 / 2 : ℝ)) B ≤ (B : ℝ) ^ (1 - (1 / 2 : ℝ)) / (1 - 1 / 2) :=
    wsum_dial_le (by norm_num) (by norm_num) B
  have hPnn : 0 ≤ wsum (dial (1 / 2 : ℝ)) B := wsum_dial_nonneg _ B
  have hsq : (wsum (dial (1 / 2 : ℝ)) B) ^ 2 ≤ 4 * B := by
    have hmul := mul_self_le_mul_self hPnn hP
    rw [← sq, ← sq, div_pow, rpow_sq hB0 (1 - (1 / 2 : ℝ))] at hmul
    have hx : (2:ℝ) * (1 - 1 / 2) = 1 := by norm_num
    rw [hx, Real.rpow_one] at hmul
    calc (wsum (dial (1 / 2 : ℝ)) B) ^ 2 ≤ (B : ℝ) / (1 - 1 / 2) ^ 2 := hmul
      _ = 4 * B := by norm_num; ring
  have hQpos : 0 < wsum (dial 1) B := wsum_dial_pos _ hB
  rw [ess_dial, dial_half_sq]
  exact (div_le_div_iff_of_pos_right hQpos).mpr hsq

/-- At `α = 1/2` the effective window size is at least `B / P_1(B)`: the sqrt
dial does saturate, but only at scale `θ log θ`. -/
theorem sqrt_dial_ess_ge {B : ℕ} (hB : 1 ≤ B) :
    (B : ℝ) / wsum (dial 1) B ≤ ess (dial (1 / 2 : ℝ)) B := by
  have hB0 : (0:ℝ) ≤ B := Nat.cast_nonneg B
  have hP : (B : ℝ) ^ (1 - (1 / 2 : ℝ)) ≤ wsum (dial (1 / 2 : ℝ)) B :=
    wsum_dial_ge (by norm_num) hB
  have hPnn : (0:ℝ) ≤ (B : ℝ) ^ (1 - (1 / 2 : ℝ)) := Real.rpow_nonneg hB0 _
  have hsq : (B : ℝ) ≤ (wsum (dial (1 / 2 : ℝ)) B) ^ 2 := by
    have hmul := mul_self_le_mul_self hPnn hP
    rw [← sq, ← sq, rpow_sq hB0 (1 - (1 / 2 : ℝ))] at hmul
    have hx : (2:ℝ) * (1 - 1 / 2) = 1 := by norm_num
    rwa [hx, Real.rpow_one] at hmul
  have hQpos : 0 < wsum (dial 1) B := wsum_dial_pos _ hB
  rw [ess_dial, dial_half_sq]
  exact (div_le_div_iff_of_pos_right hQpos).mpr hsq

/-- **Quantitative window lower bound for the sqrt dial.**  Any window `B ≥ 2^k`
that reaches level `θ` must satisfy `θ (1 + k/2) ≤ 4B`: the logarithmic factor
is present in every saturating window. -/
theorem sqrt_dial_window_lower {theta : ℝ} (hθ : 0 ≤ theta) {B k : ℕ} (hBk : 2 ^ k ≤ B)
    (hsat : theta ≤ ess (dial (1 / 2 : ℝ)) B) : theta * (1 + (k : ℝ) / 2) ≤ 4 * B := by
  have hB1 : 1 ≤ B := le_trans Nat.one_le_two_pow hBk
  have hH : 1 + (k : ℝ) / 2 ≤ wsum (dial 1) B :=
    le_trans (harmonic_dyadic_lower k) (wsum_dial_mono 1 hBk)
  have hHpos : 0 < wsum (dial 1) B := wsum_dial_pos _ hB1
  have hle : theta ≤ 4 * B / wsum (dial 1) B := le_trans hsat (sqrt_dial_ess_le hB1)
  rw [le_div_iff₀ hHpos] at hle
  nlinarith [hle, hH, hθ]

/-- **Matching upper bound for the sqrt dial.**  The sqrt dial does saturate, at
the near-linear scale `θ log θ`: whenever `θ (1+k) ≤ 2^k` the window `2^k`
suffices. -/
theorem sqrt_dial_satScale_le {theta : ℝ} {k : ℕ} (hθ : 0 ≤ theta)
    (h : theta * (1 + (k : ℝ)) ≤ 2 ^ k) : satScale (dial (1 / 2 : ℝ)) theta ≤ 2 ^ k := by
  refine satScale_le (B := 2 ^ k) ?_
  have hB1 : 1 ≤ 2 ^ k := Nat.one_le_two_pow
  have hlow := sqrt_dial_ess_ge (B := 2 ^ k) hB1
  have hH : wsum (dial 1) (2 ^ k) ≤ 1 + (k : ℝ) := harmonic_dyadic_upper k
  have hHpos : 0 < wsum (dial 1) (2 ^ k) := wsum_dial_pos _ hB1
  have hmul : theta * wsum (dial 1) (2 ^ k) ≤ ((2 ^ k : ℕ) : ℝ) := by
    have : theta * wsum (dial 1) (2 ^ k) ≤ theta * (1 + (k : ℝ)) :=
      mul_le_mul_of_nonneg_left hH hθ
    push_cast
    linarith
  have hkey : theta ≤ ((2 ^ k : ℕ) : ℝ) / wsum (dial 1) (2 ^ k) := by
    rw [le_div_iff₀ hHpos]
    exact hmul
  linarith

/-- **No uniform window bound at `α = 1/2`.**  The rescaling law predicts the
exponent `1/(2-2α) = 1` at `α = 1/2`, i.e. a saturation scale linear in the
level.  That fails: for *every* constant `C` there is a level `θ` whose every
saturating window exceeds `C θ`.  The obstruction is the logarithmic divergence
of the square mass of the sqrt dial. -/
theorem sqrt_dial_no_uniform_window_bound (C : ℝ) (hC : 0 < C) :
    ∃ theta : ℝ, 0 < theta ∧ ∀ B : ℕ, theta ≤ ess (dial (1 / 2 : ℝ)) B → C * theta < (B : ℝ) := by
  obtain ⟨k, hk⟩ := exists_nat_gt (8 * C)
  refine ⟨(2 : ℝ) ^ k, by positivity, ?_⟩
  intro B hsat
  have h2k : (0:ℝ) < (2:ℝ) ^ k := by positivity
  have hcard : ess (dial (1 / 2 : ℝ)) B ≤ (B : ℝ) := ess_le_card _ B
  have hBk : (2 : ℝ) ^ k ≤ (B : ℝ) := le_trans hsat hcard
  have hBk' : 2 ^ k ≤ B := by exact_mod_cast hBk
  have hstep := sqrt_dial_window_lower h2k.le hBk' hsat
  have hCk : C * 4 < 1 + (k : ℝ) / 2 := by linarith
  nlinarith [hstep, hCk, h2k]

/-! ## The harmonic dial: exponential saturation scale -/

/-- The harmonic level attained at a window of size at most `2^k` is at most
`(1+k)²`. -/
theorem harmonic_ess_le {B k : ℕ} (hB : 1 ≤ B) (hBk : B ≤ 2 ^ k) :
    ess (dial 1) B ≤ (1 + (k : ℝ)) ^ 2 := by
  have hP : wsum (dial 1) B ≤ 1 + (k : ℝ) :=
    le_trans (wsum_dial_mono 1 hBk) (harmonic_dyadic_upper k)
  have hPnn : 0 ≤ wsum (dial 1) B := wsum_dial_nonneg 1 B
  have hQ : 1 ≤ wsum (dial (2 * (1:ℝ))) B := one_le_wsum_dial _ hB
  have hsq : (wsum (dial 1) B) ^ 2 ≤ (1 + (k : ℝ)) ^ 2 := by
    have := mul_self_le_mul_self hPnn hP
    rw [← sq, ← sq] at this
    exact this
  rw [ess_dial]
  calc (wsum (dial 1) B) ^ 2 / wsum (dial (2 * (1:ℝ))) B
      ≤ (wsum (dial 1) B) ^ 2 / 1 :=
        div_le_div_of_nonneg_left (sq_nonneg _) zero_lt_one hQ
    _ = (wsum (dial 1) B) ^ 2 := by ring
    _ ≤ (1 + (k : ℝ)) ^ 2 := hsq

/-- **The harmonic saturation scale is exponential in the level.**  If the
harmonic dial reaches level `θ > (1+k)²` at the window `B`, then `B > 2^k`. -/
theorem harmonic_needs_exponential_window {k : ℕ} {theta : ℝ} (hθ : (1 + (k : ℝ)) ^ 2 < theta)
    {B : ℕ} (hsat : theta ≤ ess (dial 1) B) : 2 ^ k < B := by
  by_contra hcon
  push_neg at hcon
  have hB1 : 1 ≤ B := by
    rcases Nat.eq_zero_or_pos B with h | h
    · exfalso
      rw [h] at hsat
      simp [ess_zero] at hsat
      nlinarith [sq_nonneg (1 + (k:ℝ)), Nat.cast_nonneg (α := ℝ) k]
    · exact h
  have := harmonic_ess_le hB1 hcon
  linarith

/-! ## Transport of a recorded saturation constant -/

/-- **Transport, step 1.**  A recorded harmonic saturation edge `B*` caps the
level that the harmonic dial can have attained: `θ ≤ (1 + ⌈log₂ B*⌉)²`. -/
theorem transport_level_from_harmonic {theta : ℝ} {Bstar : ℕ} (hB : 1 ≤ Bstar)
    (hsat : theta ≤ ess (dial 1) Bstar) : theta ≤ (1 + (Nat.clog 2 Bstar : ℝ)) ^ 2 :=
  le_trans hsat (harmonic_ess_le hB (Nat.le_pow_clog (by norm_num) Bstar))

/-- **Transport, step 2.**  The capped level transports to an explicit window
bound for every dial with `1/2 < α < 1`: the saturation edge of the `α`-dial is
at most `(2α/(2α-1) · (1+⌈log₂B*⌉)²)^{1/(2-2α)} + 1`. -/
theorem transport_to_alpha {alpha : ℝ} (h2 : 1 / 2 < alpha) (h1 : alpha < 1) {theta : ℝ}
    (hθ : 1 ≤ theta) {Bstar : ℕ} (hB : 1 ≤ Bstar) (hsat : theta ≤ ess (dial 1) Bstar) :
    (satScale (dial alpha) theta : ℝ)
      ≤ (2 * alpha / (2 * alpha - 1) * (1 + (Nat.clog 2 Bstar : ℝ)) ^ 2) ^ (1 / (2 - 2 * alpha))
        + 1 := by
  have hlev := transport_level_from_harmonic hB hsat
  have hup := (rescaling_law h2 h1 hθ).2
  have hc : 0 < 2 * alpha / (2 * alpha - 1) := by
    apply div_pos <;> linarith
  have hmono : (2 * alpha / (2 * alpha - 1) * theta) ^ (1 / (2 - 2 * alpha))
      ≤ (2 * alpha / (2 * alpha - 1) * (1 + (Nat.clog 2 Bstar : ℝ)) ^ 2) ^ (1 / (2 - 2 * alpha)) := by
    apply Real.rpow_le_rpow (mul_nonneg hc.le (by linarith))
    · exact mul_le_mul_of_nonneg_left hlev hc.le
    · exact div_nonneg zero_le_one (by linarith)
  linarith

/-! ## Lab notes: the recorded window `B* = 400` and the stored counts

The measured harmonic edge is `B* = 400`.  Since `400 ≤ 2^9`, the harmonic level
attained there is at most `(1+9)² = 100`, and that level is reached by the sqrt
dial already at the window `2^11 = 2048`. -/

/-- The harmonic level recorded at the measured edge `B* = 400` is at most `100`. -/
theorem harmonic_level_at_400 : ess (dial 1) 400 ≤ 100 := by
  have h := harmonic_ess_le (B := 400) (k := 9) (by norm_num) (by norm_num)
  norm_num at h
  exact h

/-- **The transported sqrt-weight constant.**  The level `100` recorded by the
harmonic dial at `B* = 400` is attained by the sqrt dial at the window
`2^11 = 2048`: the explicit transport of the recorded saturation constant to the
sqrt weight. -/
theorem sqrt_scale_transported_from_400 : satScale (dial (1 / 2 : ℝ)) 100 ≤ 2048 := by
  have h := sqrt_dial_satScale_le (theta := 100) (k := 11) (by norm_num) (by norm_num)
  norm_num at h
  exact h

/-! ### The score table on the stored counts

For each stored window edge `B ∈ {50, 100, 200, 400, 800}` we record proved
two-sided bounds for the effective window size of the two dials.  The harmonic
dial (`α = 1`) is confined to a logarithmic band, the sqrt dial (`α = 1/2`) to a
near-linear one: this is the measured form of the `α = 1/2` obstruction. -/

/-- Harmonic dial: proved bands at the stored window edges. -/
theorem harmonic_table :
    ess (dial 1) 50 ≤ 49 ∧ ess (dial 1) 100 ≤ 64 ∧ ess (dial 1) 200 ≤ 81 ∧
      ess (dial 1) 400 ≤ 100 ∧ ess (dial 1) 800 ≤ 121 := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · have h := harmonic_ess_le (B := 50) (k := 6) (by norm_num) (by norm_num)
    norm_num at h; exact h
  · have h := harmonic_ess_le (B := 100) (k := 7) (by norm_num) (by norm_num)
    norm_num at h; exact h
  · have h := harmonic_ess_le (B := 200) (k := 8) (by norm_num) (by norm_num)
    norm_num at h; exact h
  · exact harmonic_level_at_400
  · have h := harmonic_ess_le (B := 800) (k := 10) (by norm_num) (by norm_num)
    norm_num at h; exact h

/-- Sqrt dial: proved lower bands at the stored window edges.  Comparing with
`harmonic_table` shows the sqrt dial collecting an order of magnitude more
effective columns at the same window edge — and hence saturating far later. -/
theorem sqrt_table :
    7 ≤ ess (dial (1 / 2 : ℝ)) 50 ∧ 12 ≤ ess (dial (1 / 2 : ℝ)) 100 ∧
      22 ≤ ess (dial (1 / 2 : ℝ)) 200 ∧ 40 ≤ ess (dial (1 / 2 : ℝ)) 400 ∧
      72 ≤ ess (dial (1 / 2 : ℝ)) 800 := by
  have key : ∀ (B k : ℕ), 1 ≤ B → B ≤ 2 ^ k →
      ((B : ℝ) / (1 + (k : ℝ))) ≤ ess (dial (1 / 2 : ℝ)) B := by
    intro B k hB hBk
    have hlow := sqrt_dial_ess_ge hB
    have hH : wsum (dial 1) B ≤ 1 + (k : ℝ) :=
      le_trans (wsum_dial_mono 1 hBk) (harmonic_dyadic_upper k)
    have hHpos : 0 < wsum (dial 1) B := wsum_dial_pos _ hB
    have : (B : ℝ) / (1 + (k : ℝ)) ≤ (B : ℝ) / wsum (dial 1) B := by
      apply div_le_div_of_nonneg_left (Nat.cast_nonneg B) hHpos hH
    linarith
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · have h := key 50 6 (by norm_num) (by norm_num); norm_num at h; linarith
  · have h := key 100 7 (by norm_num) (by norm_num); norm_num at h; linarith
  · have h := key 200 8 (by norm_num) (by norm_num); norm_num at h; linarith
  · have h := key 400 9 (by norm_num) (by norm_num); norm_num at h; linarith
  · have h := key 800 10 (by norm_num) (by norm_num); norm_num at h; linarith

end Dial

end WindowSaturation