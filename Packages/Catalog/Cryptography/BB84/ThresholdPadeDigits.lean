import Mathlib
import Cryptography.BB84.KeyRateThreshold
import Cryptography.BB84.ThresholdEnclosure
import Cryptography.BB84.ThresholdNewtonRefinement

/-!
# Eight certified decimals of the BB84 threshold via Padé bounds for `log`

The refinement chain so far is

* `ThresholdEnclosure`        : `0.1100 < p⋆ < 0.1101`   (integer certificates),
* `ThresholdNewtonRefinement` : `0.110027 < p⋆ < 0.110029` (mean value theorem).

The residual error of the second stage is dominated entirely by the crude
logarithm bounds `1 - x⁻¹ ≤ log x ≤ x - 1`, whose relative slack at
`x ≈ 1.0117` is about `1.2 %`.  This file removes that bottleneck by proving the
*Padé* (order `(1,1)`) bounds

  `2 (x-1)/(x+1) ≤ log x ≤ (x - x⁻¹)/2`   for `x ≥ 1`

(`pade_le_log`, `log_le_half_sub_inv`), whose slack is cubic in `x - 1`
(`≈ 4·10⁻⁷` relative here), and by re-running the mean-value step on the tighter
bracket produced by the previous cycle.  The result is

  `0.11002786 < p⋆ < 0.11002787`,   i.e. `⌊10⁸ p⋆⌋ = 11002786`

(`threshold_mem_Ioo_eight_decimals`, `threshold_floor_eight_decimals`).
The exact value is `0.110027864438…`.

Both Padé bounds are proved from scratch by monotonicity of the auxiliary
functions `(x - x⁻¹)/2 - log x` and `log x - 2(x-1)/(x+1)`, whose derivatives are
the manifestly nonnegative `(x-1)²/(2x²)` and `(x-1)²/(x(x+1)²)`.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): each analytic upgrade (better `log` bound, tighter
  derivative bracket) buys a fixed number of decimals at *constant* arithmetic
  cost, so the certified precision grows without ever enlarging the integers.
EXPERIMENT (Experimenter): certificates at `10⁸` give
  `1.01171880 < 2^100·11^22·89^178 / 100^200 < 1.01171881`.  Padé then yields
  `r(0.11) ∈ (1.16505348·10⁻⁴, 1.16509402·10⁻⁴)` (exact: `1.16506723·10⁻⁴`),
  a slack of `4·10⁻¹⁰` instead of `1.5·10⁻⁶`.  Re-bracketing the derivative on
  `[0.110000, 0.110029]` gives `H₂' ∈ [2.0904447, 2.0907414]`, and the MVT
  quotient lands in `(2.786220·10⁻⁵, 2.786714·10⁻⁵)`; exact `2.7864438·10⁻⁵`.
  Certified decimals: 4 → 6 → 8.
ANALYSIS (Analyst): the limiting factor is now the *width of the derivative
  bracket*, i.e. the length of the previous enclosure, so the scheme is
  self-accelerating: each new enclosure shrinks the next bracket, and the
  precision roughly doubles per cycle (a Newton-type quadratic law), until the
  nine-digit bound on `log 2` becomes binding near `10⁻¹⁰`.
CRITIQUE (Critic): the Padé inequalities are proved, not assumed, and are stated
  with the sharp hypothesis `1 ≤ x` (they reverse for `x < 1`).  The chain is
  strictly bottom-up: this file consumes only proved statements of the previous
  two, and no step evaluates a transcendental numerically.
SYNTHESIS (PI): Padé logarithm bounds + certificate refresh at `10⁸` + a second
  MVT pass ⇒ `⌊10⁸ p⋆⌋ = 11002786`.
-/

open Real Set

noncomputable section

namespace BB84

/-! ## 1. Padé bounds for the logarithm -/

/-- **Upper Padé bound.** `log x ≤ (x - x⁻¹)/2` for `x ≥ 1`.  Sharper than
`log x ≤ x - 1` by a factor `(x-1)/2`; the proof is monotonicity of
`(x - x⁻¹)/2 - log x`, whose derivative is `(x-1)²/(2x²) ≥ 0`. -/
theorem log_le_half_sub_inv {x : ℝ} (hx : 1 ≤ x) : Real.log x ≤ (x - x⁻¹) / 2 := by
  rcases eq_or_lt_of_le hx with h | h
  · rw [← h]; norm_num
  · have key : StrictMonoOn (fun y : ℝ => (y - y⁻¹) / 2 - Real.log y) (Ici 1) := by
      apply strictMonoOn_of_deriv_pos (convex_Ici 1)
      · apply ContinuousOn.sub
        · apply ContinuousOn.div_const
          exact continuousOn_id.sub (ContinuousOn.inv₀ continuousOn_id (fun y hy => by
            simp only [mem_Ici] at hy; intro hc; rw [hc] at hy; linarith))
        · exact ContinuousOn.log continuousOn_id (fun y hy => by
            simp only [mem_Ici] at hy; intro hc; rw [hc] at hy; linarith)
      · intro y hy
        simp only [interior_Ici, mem_Ioi] at hy
        have hy0 : y ≠ 0 := by intro hc; rw [hc] at hy; linarith
        have hd : HasDerivAt (fun y : ℝ => (y - y⁻¹) / 2 - Real.log y)
            ((1 - -(y ^ 2)⁻¹) / 2 - y⁻¹) y :=
          (((hasDerivAt_id y).sub (hasDerivAt_inv hy0)).div_const 2).sub (Real.hasDerivAt_log hy0)
        rw [hd.deriv]
        have heq : (1 - -(y ^ 2)⁻¹) / 2 - y⁻¹ = (y - 1) ^ 2 / (2 * y ^ 2) := by
          field_simp; ring
        rw [heq]
        exact div_pos (pow_pos (by linarith : (0:ℝ) < y - 1) 2) (by positivity)
    have := key (mem_Ici.2 le_rfl) (mem_Ici.2 (le_of_lt h)) h
    simp only [inv_one, Real.log_one] at this
    norm_num at this
    linarith

/-- **Lower Padé bound.** `2(x-1)/(x+1) ≤ log x` for `x ≥ 1`.  Sharper than
`1 - x⁻¹ ≤ log x`; the proof is monotonicity of `log x - 2(x-1)/(x+1)`, whose
derivative is `(x-1)²/(x(x+1)²) ≥ 0`. -/
theorem pade_le_log {x : ℝ} (hx : 1 ≤ x) : 2 * (x - 1) / (x + 1) ≤ Real.log x := by
  rcases eq_or_lt_of_le hx with h | h
  · rw [← h]; norm_num
  · have key : StrictMonoOn (fun y : ℝ => Real.log y - (2 - 4 / (y + 1))) (Ici 1) := by
      apply strictMonoOn_of_deriv_pos (convex_Ici 1)
      · apply ContinuousOn.sub
        · exact ContinuousOn.log continuousOn_id (fun y hy => by
            simp only [mem_Ici] at hy; intro hc; rw [hc] at hy; linarith)
        · apply ContinuousOn.sub continuousOn_const
          apply ContinuousOn.div continuousOn_const (continuousOn_id.add continuousOn_const)
          intro y hy; simp only [mem_Ici] at hy; intro hc; simp at hc; linarith
      · intro y hy
        simp only [interior_Ici, mem_Ioi] at hy
        have hy0 : y ≠ 0 := by intro hc; rw [hc] at hy; linarith
        have hy1 : y + 1 ≠ 0 := by intro hc; nlinarith
        have hinv : HasDerivAt (fun y : ℝ => 4 / (y + 1)) (4 * (-1 / (y + 1) ^ 2)) y := by
          have h0 : HasDerivAt (fun y : ℝ => (y + 1)⁻¹) (-1 / (y + 1) ^ 2) y := by
            simpa using ((hasDerivAt_id y).add_const 1).inv hy1
          simpa [div_eq_mul_inv] using h0.const_mul (4 : ℝ)
        have hd : HasDerivAt (fun y : ℝ => Real.log y - (2 - 4 / (y + 1)))
            (y⁻¹ - (0 - 4 * (-1 / (y + 1) ^ 2))) y :=
          (Real.hasDerivAt_log hy0).sub ((hasDerivAt_const y (2 : ℝ)).sub hinv)
        rw [hd.deriv]
        have heq : y⁻¹ - (0 - 4 * (-1 / (y + 1) ^ 2)) = (y - 1) ^ 2 / (y * (y + 1) ^ 2) := by
          field_simp; ring
        rw [heq]
        exact div_pos (pow_pos (by linarith : (0:ℝ) < y - 1) 2) (by positivity)
    have := key (mem_Ici.2 le_rfl) (mem_Ici.2 (le_of_lt h)) h
    simp only [Real.log_one] at this
    norm_num at this
    have hrw : 2 * (x - 1) / (x + 1) = 2 - 4 / (x + 1) := by field_simp; ring
    rw [hrw]
    linarith

/-! ## 2. Refreshed integer certificates at precision `10⁻⁸` -/

set_option exponentiation.threshold 100000

/-- `2^100·11^22·89^178 / 100^200 > 1.01171880`. -/
theorem cert_ratio_gt_e8 :
    101171880 * ((11 + 89) ^ (2 * (11 + 89)))
      < 100000000 * (2 ^ (11 + 89) * 11 ^ (2 * 11) * 89 ^ (2 * 89)) := by
  decide

/-- `2^100·11^22·89^178 / 100^200 < 1.01171881`. -/
theorem cert_ratio_lt_e8 :
    100000000 * (2 ^ (11 + 89) * 11 ^ (2 * 11) * 89 ^ (2 * 89))
      < 101171881 * ((11 + 89) ^ (2 * (11 + 89))) := by
  decide

/-! ## 3. Padé-sharp bounds for the key rate at `11 %` -/

/-- Padé lower bound: `r(0.11) > 1.16505348·10⁻⁴` nats.  (Exact value:
`1.165067226·10⁻⁴`.) -/
theorem secureKeyRate_eleven_percent_gt_pade :
    116505348 / 1000000000000 < secureKeyRate (11 / 100) := by
  set D : ℝ := ((((11 + 89) ^ (2 * (11 + 89)) : ℕ)) : ℝ) with hDdef
  set N : ℝ := (((2 ^ (11 + 89) * 11 ^ (2 * 11) * 89 ^ (2 * 89) : ℕ)) : ℝ) with hNdef
  have hD : (0 : ℝ) < D := by rw [hDdef]; norm_num
  have hN : (0 : ℝ) < N := by rw [hNdef]; norm_num
  have hcert : (101171880 : ℝ) * D < 100000000 * N := by
    rw [hDdef, hNdef]; exact_mod_cast cert_ratio_gt_e8
  have hR : (101171880 : ℝ) / 100000000 < N / D := by
    rw [div_lt_div_iff₀ (by norm_num) hD]; linarith
  have hR1 : (1 : ℝ) ≤ N / D := by
    have : (101171880 : ℝ) / 100000000 ≥ 1 := by norm_num
    linarith
  have hpade : 2 * (N / D - 1) / (N / D + 1) ≤ Real.log (N / D) := pade_le_log hR1
  have hmono : 2 * ((101171880 : ℝ) / 100000000 - 1) / ((101171880 : ℝ) / 100000000 + 1)
      < 2 * (N / D - 1) / (N / D + 1) := by
    rw [div_lt_div_iff₀ (by norm_num) (by linarith)]
    nlinarith [hR]
  have hrate := secureKeyRate_ratio_eq 11 89 (by norm_num) (by norm_num)
  rw [← hDdef, ← hNdef] at hrate
  have h11 : ((11 : ℕ) : ℝ) / (((11 : ℕ) : ℝ) + ((89 : ℕ) : ℝ)) = 11 / 100 := by norm_num
  rw [h11] at hrate
  rw [hrate]
  have hcoef : (((11 : ℕ) : ℝ) + ((89 : ℕ) : ℝ))⁻¹ = 1 / 100 := by norm_num
  rw [hcoef]
  norm_num at hmono ⊢
  linarith

/-- Padé upper bound: `r(0.11) < 1.16509402·10⁻⁴` nats. -/
theorem secureKeyRate_eleven_percent_lt_pade :
    secureKeyRate (11 / 100) < 116509402 / 1000000000000 := by
  set D : ℝ := ((((11 + 89) ^ (2 * (11 + 89)) : ℕ)) : ℝ) with hDdef
  set N : ℝ := (((2 ^ (11 + 89) * 11 ^ (2 * 11) * 89 ^ (2 * 89) : ℕ)) : ℝ) with hNdef
  have hD : (0 : ℝ) < D := by rw [hDdef]; norm_num
  have hN : (0 : ℝ) < N := by rw [hNdef]; norm_num
  have hcertlo : (101171880 : ℝ) * D < 100000000 * N := by
    rw [hDdef, hNdef]; exact_mod_cast cert_ratio_gt_e8
  have hcert : (100000000 : ℝ) * N < 101171881 * D := by
    rw [hDdef, hNdef]; exact_mod_cast cert_ratio_lt_e8
  have hR : N / D < (101171881 : ℝ) / 100000000 := by
    rw [div_lt_div_iff₀ hD (by norm_num)]; linarith
  have hR1 : (1 : ℝ) ≤ N / D := by
    have h1 : (101171880 : ℝ) / 100000000 < N / D := by
      rw [div_lt_div_iff₀ (by norm_num) hD]; linarith
    linarith
  have hpade : Real.log (N / D) ≤ (N / D - (N / D)⁻¹) / 2 := log_le_half_sub_inv hR1
  have hmono : (N / D - (N / D)⁻¹) / 2
      ≤ ((101171881 : ℝ) / 100000000 - ((101171881 : ℝ) / 100000000)⁻¹) / 2 := by
    have hx : (0 : ℝ) < N / D := by positivity
    have hinv : ((101171881 : ℝ) / 100000000)⁻¹ ≤ (N / D)⁻¹ := by
      exact inv_anti₀ hx (le_of_lt hR)
    linarith
  have hrate := secureKeyRate_ratio_eq 11 89 (by norm_num) (by norm_num)
  rw [← hDdef, ← hNdef] at hrate
  have h11 : ((11 : ℕ) : ℝ) / (((11 : ℕ) : ℝ) + ((89 : ℕ) : ℝ)) = 11 / 100 := by norm_num
  rw [h11] at hrate
  rw [hrate]
  have hcoef : (((11 : ℕ) : ℝ) + ((89 : ℕ) : ℝ))⁻¹ = 1 / 100 := by norm_num
  rw [hcoef]
  norm_num at hmono ⊢
  linarith

/-! ## 4. A Padé-sharp derivative bracket on the six-decimal enclosure -/

/-- `log (89/11) ≤ 2.0907414`, from `log 2 < 0.6931471808` and the Padé bound
`log (89/88) ≤ (89/88 - 88/89)/2 = 177/15664`. -/
theorem log_eightynine_div_eleven_le_pade : Real.log (89 / 11) ≤ 20907414 / 10000000 := by
  have hsplit : (89 : ℝ) / 11 = 8 * (89 / 88) := by norm_num
  have h8 : Real.log 8 = 3 * Real.log 2 := by
    rw [show (8 : ℝ) = 2 ^ 3 by norm_num, Real.log_pow]; norm_num
  have hsmall : Real.log (89 / 88) ≤ 177 / 15664 := by
    have h := log_le_half_sub_inv (x := (89 : ℝ) / 88) (by norm_num)
    norm_num at h ⊢
    linarith
  rw [hsplit, Real.log_mul (by norm_num) (by norm_num), h8]
  have h2 := Real.log_two_lt_d9
  norm_num at h2 ⊢
  linarith

/-- `2.0904447 ≤ log (889971/110029)`, from `0.6931471803 < log 2` and the Padé
bound `log (889971/880232) ≥ 2·9739/1770203`. -/
theorem le_log_889971_div_110029_pade :
    20904447 / 10000000 ≤ Real.log (889971 / 110029) := by
  have hsplit : (889971 : ℝ) / 110029 = 8 * (889971 / 880232) := by norm_num
  have h8 : Real.log 8 = 3 * Real.log 2 := by
    rw [show (8 : ℝ) = 2 ^ 3 by norm_num, Real.log_pow]; norm_num
  have hsmall : 19478 / 1770203 ≤ Real.log (889971 / 880232) := by
    have h := pade_le_log (x := (889971 : ℝ) / 880232) (by norm_num)
    norm_num at h ⊢
    linarith
  rw [hsplit, Real.log_mul (by norm_num) (by norm_num), h8]
  have h2 := Real.log_two_gt_d9
  norm_num at h2 ⊢
  linarith

/-- **Sharp derivative bracket.**  On the six-decimal enclosure
`[0.110000, 0.110029]` the derivative of the binary entropy satisfies
`2.0904447 ≤ H₂'(x) ≤ 2.0907414`. -/
theorem deriv_binEntropy_bracket_sharp {x : ℝ}
    (hx : x ∈ Icc (11 / 100 : ℝ) (110029 / 1000000)) :
    20904447 / 10000000 ≤ Real.log (1 - x) - Real.log x ∧
      Real.log (1 - x) - Real.log x ≤ 20907414 / 10000000 := by
  obtain ⟨hx1, hx2⟩ := hx
  have hxpos : (0 : ℝ) < x := by linarith
  have hx1' : (0 : ℝ) < 1 - x := by linarith
  constructor
  · have hA : Real.log (889971 / 1000000) ≤ Real.log (1 - x) :=
      Real.log_le_log (by norm_num) (by linarith)
    have hB : Real.log x ≤ Real.log (110029 / 1000000) :=
      Real.log_le_log hxpos (by linarith)
    have hC : Real.log (889971 / 1000000) - Real.log (110029 / 1000000)
        = Real.log (889971 / 110029) := by
      rw [Real.log_div (by norm_num) (by norm_num), Real.log_div (by norm_num) (by norm_num),
        Real.log_div (by norm_num) (by norm_num)]
      ring
    have := le_log_889971_div_110029_pade
    linarith [hA, hB, hC ▸ this]
  · have hA : Real.log (1 - x) ≤ Real.log (89 / 100) :=
      Real.log_le_log hx1' (by linarith)
    have hB : Real.log (11 / 100) ≤ Real.log x :=
      Real.log_le_log (by norm_num) (by linarith)
    have hC : Real.log (89 / 100) - Real.log (11 / 100) = Real.log (89 / 11) := by
      rw [Real.log_div (by norm_num) (by norm_num), Real.log_div (by norm_num) (by norm_num),
        Real.log_div (by norm_num) (by norm_num)]
      ring
    have := log_eightynine_div_eleven_le_pade
    linarith [hA, hB, hC ▸ this]

/-! ## 5. Eight certified decimals -/

/-- **Eight certified decimals.**  Every zero of the BB84 key rate on `[0, 1/2]`
satisfies `0.11002786 < p⋆ < 0.11002787`. -/
theorem threshold_mem_Ioo_eight_decimals {p : ℝ} (hp : p ∈ Icc (0 : ℝ) 2⁻¹)
    (hpz : secureKeyRate p = 0) :
    p ∈ Ioo (11002786 / 100000000 : ℝ) (11002787 / 100000000) := by
  obtain ⟨h1, h2⟩ := threshold_mem_Ioo_six_decimals hp hpz
  obtain ⟨ξ, hξ, heq⟩ := exists_mvt_point hp hpz
  have hξ2 : ξ ≤ 110029 / 1000000 := le_of_lt (lt_trans hξ.2 h2)
  obtain ⟨hL, hU⟩ := deriv_binEntropy_bracket_sharp ⟨le_of_lt hξ.1, hξ2⟩
  have hd : (0 : ℝ) < p - 11 / 100 := by linarith
  have hrlo := secureKeyRate_eleven_percent_gt_pade
  have hrhi := secureKeyRate_eleven_percent_lt_pade
  set s : ℝ := Real.log (1 - ξ) - Real.log ξ with hs
  constructor
  · nlinarith [heq, hU, hd, hrlo]
  · nlinarith [heq, hL, hd, hrhi]

/-- **The first eight decimal digits of the threshold** are `0.11002786`. -/
theorem threshold_floor_eight_decimals {p : ℝ} (hp : p ∈ Icc (0 : ℝ) 2⁻¹)
    (hpz : secureKeyRate p = 0) : ⌊(100000000 : ℝ) * p⌋ = 11002786 := by
  obtain ⟨h1, h2⟩ := threshold_mem_Ioo_eight_decimals hp hpz
  apply Int.floor_eq_iff.mpr
  constructor
  · push_cast; linarith
  · push_cast; linarith

/-- **Final certified statement of this cycle.**  The unique QBER at which the
asymptotic one-way BB84 key rate vanishes is `0.110027865 ± 5·10⁻⁹`; equivalently
its first eight decimals are `0.11002786`.  (Exact value `0.1100278644…`.) -/
theorem bb84_threshold_eight_decimals :
    ∃! p : ℝ, p ∈ Icc (0 : ℝ) 2⁻¹ ∧ secureKeyRate p = 0 ∧
      |p - 110027865 / 1000000000| < 5 / 1000000000 := by
  obtain ⟨p, ⟨hpI, hpz⟩, huniq⟩ := exists_unique_threshold_enclosure
  obtain ⟨h1, h2⟩ := threshold_mem_Ioo_eight_decimals hpI hpz
  refine ⟨p, ⟨hpI, hpz, ?_⟩, ?_⟩
  · rw [abs_lt]; constructor <;> linarith
  · rintro q ⟨hqI, hqz, -⟩
    exact huniq q ⟨hqI, hqz⟩

end BB84