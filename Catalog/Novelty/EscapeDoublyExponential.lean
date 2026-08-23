import Mathlib
import Novelty.EscapeRateGreenFunction

/-!
# Doubly exponential escape, sharp potential bounds, and the Douady–Hubbard potential

Third iteration of the escape-criterion thread. The geometric bound of
`EscapeCriterion.escape_norm_growth` (`‖z_n‖ ≥ (‖z‖-1)^n ‖z‖`) is exponentially weaker than
the truth; combining it with the logarithmic distortion estimate of
`EscapeCriterion.log_distortion` upgrades it to the correct **doubly exponential** rate.

Main results:

* `log_norm_orbit_sub_one_ge`: `log ‖z_n‖ - 1 ≥ 2ⁿ (log ‖z‖ - 1)`.
* `norm_orbit_ge_exp`: `‖z_n‖ ≥ exp(2ⁿ (log ‖z‖ - 1) + 1)`.
* `escape_time_loglog`: the escape-time test terminates after `O(log log B)` iterations —
  exponentially better than the Bernoulli bound `escape_time_bound`.
* `abs_escapeRate_sub_log_le_two_div`: the sharp a priori estimate
  `|G_c(z) - log ‖z‖| ≤ 2/‖z‖`, whence `escapeRate_asymptotic`:
  `G_c(z) = log ‖z‖ + O(1/‖z‖)` uniformly in `c`.
* `mandelbrotPotential`: the Douady–Hubbard potential `G_M(c) = lim 2^{-n} log ‖z_n(c)‖` of
  the exterior of the Mandelbrot set, shown to exist and to be positive for `‖c‖ > 2`,
  with the explicit lower bound `mandelbrotPotential_ge`.
-/

namespace EscapeCriterion

open Filter MandelbrotEscape
open scoped Topology

variable {c z : ℂ}

/-! ## Doubly exponential growth -/

lemma norm_le_norm_orbit (hz : escapeRadius c < ‖z‖) (n : ℕ) : ‖z‖ ≤ ‖orbit c z n‖ := by
  have h2 : (2 : ℝ) < ‖z‖ := lt_of_le_of_lt (two_le_escapeRadius c) hz
  have hone : (1 : ℝ) ≤ (‖z‖ - 1) ^ n := one_le_pow₀ (by linarith)
  have hg := (escape_norm_growth c z hz n).2
  nlinarith [norm_nonneg z]

/-- **Doubly exponential escape.** Along an escaping orbit the quantity `log ‖z_n‖ - 1`
at least doubles at every step. -/
theorem log_norm_orbit_sub_one_ge (hz : escapeRadius c < ‖z‖) (n : ℕ) :
    2 ^ n * (Real.log ‖z‖ - 1) ≤ Real.log ‖orbit c z n‖ - 1 := by
  induction n with
  | zero => simp
  | succ n ih =>
    have hr2 : 2 < ‖orbit c z n‖ := two_lt_norm_orbit hz n
    have hkey := abs_log_orbit_succ_sub hz n
    rw [abs_le] at hkey
    have hsmall : 2 / ‖orbit c z n‖ ≤ 1 := by
      rw [div_le_one (by linarith)]; linarith
    have hstep : 2 * Real.log ‖orbit c z n‖ - 1 ≤ Real.log ‖orbit c z (n + 1)‖ := by
      linarith [hkey.1]
    have : (2 : ℝ) ^ (n + 1) * (Real.log ‖z‖ - 1) = 2 * (2 ^ n * (Real.log ‖z‖ - 1)) := by
      rw [pow_succ]; ring
    rw [this]
    linarith

/-- Exponentiated form of the doubly exponential bound. -/
theorem norm_orbit_ge_exp (hz : escapeRadius c < ‖z‖) (n : ℕ) :
    Real.exp (2 ^ n * (Real.log ‖z‖ - 1) + 1) ≤ ‖orbit c z n‖ := by
  have hpos : (0 : ℝ) < ‖orbit c z n‖ := by linarith [two_lt_norm_orbit hz n]
  have h := log_norm_orbit_sub_one_ge hz n
  calc Real.exp (2 ^ n * (Real.log ‖z‖ - 1) + 1)
      ≤ Real.exp (Real.log ‖orbit c z n‖) := Real.exp_le_exp.mpr (by linarith)
    _ = ‖orbit c z n‖ := Real.exp_log hpos

/-- **Log-log escape time.** Starting from `‖z‖ ≥ 3`, the orbit exceeds the threshold `B`
after `n` iterations as soon as `2ⁿ ≥ (log B - 1)/(log ‖z‖ - 1)`; i.e. `O(log log B)`
iterations suffice, in contrast with the `O(B)` Bernoulli bound `escape_time_bound`. -/
theorem escape_time_loglog (hz : escapeRadius c < ‖z‖) (h3 : 3 ≤ ‖z‖) {B : ℝ} (hB : 0 < B)
    {n : ℕ} (hn : (Real.log B - 1) / (Real.log ‖z‖ - 1) ≤ 2 ^ n) : B ≤ ‖orbit c z n‖ := by
  have hlog3 : 1 < Real.log ‖z‖ := by
    have h1 : Real.log 3 ≤ Real.log ‖z‖ := Real.log_le_log (by norm_num) h3
    have h2 : (1 : ℝ) < Real.log 3 := by
      rw [show (1 : ℝ) = Real.log (Real.exp 1) by simp]
      exact Real.log_lt_log (Real.exp_pos 1) (by linarith [Real.exp_one_lt_d9])
    linarith
  have hden : (0 : ℝ) < Real.log ‖z‖ - 1 := by linarith
  have hmul : Real.log B - 1 ≤ 2 ^ n * (Real.log ‖z‖ - 1) := by
    rw [div_le_iff₀ hden] at hn
    linarith [hn]
  have hposn : (0 : ℝ) < ‖orbit c z n‖ := by linarith [two_lt_norm_orbit hz n]
  have hgrow := log_norm_orbit_sub_one_ge hz n
  have : Real.log B ≤ Real.log ‖orbit c z n‖ := by linarith
  exact (Real.log_le_log_iff hB hposn).mp this

/-! ## The sharp a priori bound for the escape rate -/

lemma dist_logOrbitSeq_le_two_div (hz : escapeRadius c < ‖z‖) (n : ℕ) :
    dist (logOrbitSeq c z n) (logOrbitSeq c z (n + 1)) ≤ (2 / ‖z‖) * (1 / 2 : ℝ) ^ (n + 1) := by
  have hzpos : (0 : ℝ) < ‖z‖ := by linarith [lt_of_le_of_lt (two_le_escapeRadius c) hz]
  have hmono : 2 / ‖orbit c z n‖ ≤ 2 / ‖z‖ :=
    div_le_div_of_nonneg_left (by norm_num) hzpos (norm_le_norm_orbit hz n)
  have hkey := abs_log_orbit_succ_sub hz n
  have hpowpos : (0 : ℝ) < 2 ^ (n + 1) := by positivity
  rw [Real.dist_eq, logOrbitSeq, logOrbitSeq]
  have hexpand :
      Real.log ‖orbit c z n‖ / 2 ^ n - Real.log ‖orbit c z (n + 1)‖ / 2 ^ (n + 1)
        = -(Real.log ‖orbit c z (n + 1)‖ - 2 * Real.log ‖orbit c z n‖) / 2 ^ (n + 1) := by
    field_simp
    ring
  rw [hexpand, abs_div, abs_neg, abs_of_pos hpowpos, div_le_iff₀ hpowpos]
  have hone : (2 / ‖z‖) * (1 / 2 : ℝ) ^ (n + 1) * 2 ^ (n + 1) = 2 / ‖z‖ := by
    rw [div_pow, one_pow]
    field_simp
  rw [hone]
  exact le_trans hkey hmono

/-- **Sharp a priori estimate.** `|G_c(z) - log ‖z‖| ≤ 2/‖z‖` for every escaping `z`,
uniformly in the parameter `c`. -/
theorem abs_escapeRate_sub_log_le_two_div (hz : escapeRadius c < ‖z‖) :
    |escapeRate c z - Real.log ‖z‖| ≤ 2 / ‖z‖ := by
  have hzpos : (0 : ℝ) < ‖z‖ := by linarith [lt_of_le_of_lt (two_le_escapeRadius c) hz]
  have hsummable : Summable fun n : ℕ => (2 / ‖z‖) * (1 / 2 : ℝ) ^ (n + 1) :=
    summable_geom_half.mul_left _
  have hdist := dist_le_tsum_of_dist_le_of_tendsto₀
    (fun n : ℕ => (2 / ‖z‖) * (1 / 2 : ℝ) ^ (n + 1))
    (fun n => dist_logOrbitSeq_le_two_div hz n) hsummable (escapeRate_tendsto hz)
  have htsum : (∑' n : ℕ, (2 / ‖z‖) * (1 / 2 : ℝ) ^ (n + 1)) = 2 / ‖z‖ := by
    rw [tsum_mul_left]
    have h : (∑' n : ℕ, (1 / 2 : ℝ) ^ (n + 1)) = (1 / 2) * ∑' n : ℕ, (1 / 2 : ℝ) ^ n := by
      rw [← tsum_mul_left]
      exact tsum_congr fun n => by rw [pow_succ]; ring
    rw [h, tsum_geometric_of_lt_one (by norm_num) (by norm_num)]
    norm_num
  rw [htsum] at hdist
  have h0 : logOrbitSeq c z 0 = Real.log ‖z‖ := by simp [logOrbitSeq]
  rw [h0, Real.dist_eq] at hdist
  rw [abs_sub_comm]
  exact hdist

/-- Asymptotics of the escape rate: `G_c(z) = log ‖z‖ + O(1/‖z‖)`, uniformly in `c`. -/
theorem escapeRate_asymptotic {ε : ℝ} (hε : 0 < ε) :
    ∃ R : ℝ, ∀ c z : ℂ, R < ‖z‖ → escapeRadius c < ‖z‖ →
      |escapeRate c z - Real.log ‖z‖| < ε := by
  refine ⟨max 2 (2 / ε), fun c z hR hz => ?_⟩
  have h2z : (2 : ℝ) < ‖z‖ := lt_of_le_of_lt (le_max_left 2 (2 / ε)) hR
  have hzpos : (0 : ℝ) < ‖z‖ := by linarith
  have h1 : 2 / ε < ‖z‖ := lt_of_le_of_lt (le_max_right 2 (2 / ε)) hR
  have h2 : 2 / ‖z‖ < ε := by
    rw [div_lt_iff₀ hzpos]
    rw [div_lt_iff₀ hε] at h1
    linarith
  exact lt_of_le_of_lt (abs_escapeRate_sub_log_le_two_div hz) h2

/-! ## The Douady–Hubbard potential of the Mandelbrot exterior -/

/-- For `‖c‖ > 2` the second point of the critical orbit is strictly outside the escape
radius (the first one, `c` itself, only meets it). -/
lemma escapeRadius_lt_norm_critOrbit_two (hc : 2 < ‖c‖) :
    escapeRadius c < ‖orbit c 0 2‖ := by
  have hR : escapeRadius c = ‖c‖ := max_eq_right hc.le
  have h1 : orbit c 0 1 = c := by simp [orbit_succ', MandelbrotEscape.qmap]
  have h2 : ‖c‖ ^ 2 - ‖c‖ ≤ ‖orbit c 0 2‖ := by
    have h := MandelbrotEscape.qmap_norm_lower c c
    have : orbit c 0 2 = MandelbrotEscape.qmap c c := by rw [orbit_succ', h1]
    rw [this]
    linarith
  rw [hR]
  nlinarith

/-- The **Douady–Hubbard potential** of the exterior of the Mandelbrot set:
`G_M(c) = G_c(c) = lim 2^{-n} log ‖f_c^n(c)‖`, i.e. the escape rate of the critical *value*
`c`. It is computed here through the (strictly escaping) second critical-orbit point. -/
noncomputable def mandelbrotPotential (c : ℂ) : ℝ := escapeRate c (orbit c 0 2) / 2

/-- The defining limit: for `‖c‖ > 2` the normalised logarithms of the orbit of the critical
value `c` (that is, `critOrbit c (n+1) = f_c^n(c)`) converge to the Douady–Hubbard
potential. -/
theorem mandelbrotPotential_tendsto (hc : 2 < ‖c‖) :
    Tendsto (fun n => Real.log ‖critOrbit c (n + 1)‖ / 2 ^ n) atTop
      (𝓝 (mandelbrotPotential c)) := by
  have hz2 : escapeRadius c < ‖orbit c 0 2‖ := escapeRadius_lt_norm_critOrbit_two hc
  have hshift := escapeRate_tendsto hz2
  have hscaled : Tendsto (fun n => logOrbitSeq c (orbit c 0 2) n / 2) atTop
      (𝓝 (mandelbrotPotential c)) := by
    simpa [mandelbrotPotential] using hshift.div_const 2
  rw [← Filter.tendsto_add_atTop_iff_nat 1]
  refine Filter.Tendsto.congr (fun n => ?_) hscaled
  rw [logOrbitSeq, critOrbit_eq_orbit, ← orbit_add]
  have hidx : n + 1 + 1 = 2 + n := by omega
  rw [hidx, pow_succ]
  field_simp

/-- Explicit positive lower bound for the potential outside the disk of radius `2`. -/
theorem mandelbrotPotential_ge (hc : 2 < ‖c‖) :
    (Real.log ‖orbit c 0 2‖ - 2 / ‖orbit c 0 2‖) / 2 ≤ mandelbrotPotential c := by
  have hz2 : escapeRadius c < ‖orbit c 0 2‖ := escapeRadius_lt_norm_critOrbit_two hc
  have h := abs_escapeRate_sub_log_le_two_div hz2
  rw [abs_le] at h
  rw [mandelbrotPotential]
  linarith [h.1]

/-- The Douady–Hubbard potential is strictly positive outside the Mandelbrot set's
enclosing disk. -/
theorem mandelbrotPotential_pos (hc : 2 < ‖c‖) : 0 < mandelbrotPotential c := by
  have hz2 : escapeRadius c < ‖orbit c 0 2‖ := escapeRadius_lt_norm_critOrbit_two hc
  have := escapeRate_pos hz2
  rw [mandelbrotPotential]
  linarith

end EscapeCriterion