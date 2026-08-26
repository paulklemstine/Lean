import Mathlib
import Novelty.EscapeCriterionIteration

/-!
# The escape rate (Green's function) of an escaping orbit

Building on the escape criterion of `Novelty.EscapeCriterionIteration`, this file constructs
the **escape rate**
`G_c(z) = lim_{n→∞} 2^{-n} · log ‖f_c^n(z)‖`
for every point `z` that has crossed the escape radius of `c`, and establishes its defining
structural properties:

* `log_distortion` / `abs_log_orbit_succ_sub`: the one-step doubling law
  `log ‖f_c(w)‖ = 2 log ‖w‖ + O(1/‖w‖)` in the escaping region, proved from the two-sided
  estimate `‖w‖² - ‖w‖ ≤ ‖f_c(w)‖ ≤ ‖w‖² + ‖w‖` and the exponential bounds
  `1 + x ≤ exp x`, `(1 + 2u)⁻¹ ≤ 1 - u` (`u ≤ 1/2`).
* `escapeRate_tendsto`: the limit exists — the increments are summable with geometric
  majorant `2^{-(n+1)}`.
* `escapeRate_functional_equation`: `G_c(f_c z) = 2 · G_c(z)`, the Böttcher/Green functional
  equation, and its iterate `escapeRate_iterate`.
* `abs_escapeRate_sub_log_le_one`: `|G_c(z) - log ‖z‖| ≤ 1`, an effective a priori estimate.
* `escapeRate_pos`: `G_c(z) > 0` for every escaping `z`, obtained by iterating the functional
  equation until the orbit exceeds `3 > e`, where the a priori estimate forces positivity.

Thus the escape-time test of `Novelty.EscapeCriterionIteration` is refined from a Boolean
test into a positive real-valued potential, and the qualitative statement "the orbit escapes"
becomes the quantitative statement `G_c(z) > 0`.
-/

namespace EscapeCriterion

open Filter
open scoped Topology

variable {c z : ℂ}

/-- The normalised logarithmic orbit sequence whose limit is the escape rate. -/
noncomputable def logOrbitSeq (c z : ℂ) (n : ℕ) : ℝ := Real.log ‖orbit c z n‖ / 2 ^ n

/-- The escape rate (Green's function of the filled Julia set) at `z`. -/
noncomputable def escapeRate (c z : ℂ) : ℝ := limUnder atTop (logOrbitSeq c z)

/-! ## Basic estimates in the escaping region -/

lemma two_lt_norm_orbit (hz : escapeRadius c < ‖z‖) (n : ℕ) : 2 < ‖orbit c z n‖ :=
  lt_of_le_of_lt (two_le_escapeRadius c) (escape_norm_growth c z hz n).1

lemma norm_c_lt_norm_orbit (hz : escapeRadius c < ‖z‖) (n : ℕ) : ‖c‖ < ‖orbit c z n‖ :=
  lt_of_le_of_lt (norm_le_escapeRadius c) (escape_norm_growth c z hz n).1

/-- Two-sided one-step estimate: `r² - r ≤ ‖f_c(w)‖ ≤ r² + r` where `r = ‖w‖`. -/
lemma norm_orbit_succ_bounds (hz : escapeRadius c < ‖z‖) (n : ℕ) :
    ‖orbit c z n‖ ^ 2 - ‖orbit c z n‖ ≤ ‖orbit c z (n + 1)‖ ∧
      ‖orbit c z (n + 1)‖ ≤ ‖orbit c z n‖ ^ 2 + ‖orbit c z n‖ := by
  have hc := (norm_c_lt_norm_orbit hz n).le
  constructor
  · have h := MandelbrotEscape.qmap_norm_lower c (orbit c z n)
    rw [orbit_succ']
    linarith
  · rw [orbit_succ]
    calc ‖(orbit c z n) ^ 2 + c‖ ≤ ‖(orbit c z n) ^ 2‖ + ‖c‖ := norm_add_le _ _
      _ ≤ ‖orbit c z n‖ ^ 2 + ‖orbit c z n‖ := by rw [norm_pow]; linarith

/-- **One-step logarithmic distortion.** If `r > 2` and `r² - r ≤ s ≤ r² + r`, then
`log s` differs from `2 log r` by at most `2/r`. This is the analytic heart of the
renormalisation `2^{-n} log ‖z_n‖`. -/
theorem log_distortion (r s : ℝ) (hr : 2 < r) (hlow : r ^ 2 - r ≤ s) (hhigh : s ≤ r ^ 2 + r) :
    |Real.log s - 2 * Real.log r| ≤ 2 / r := by
  have hrpos : (0 : ℝ) < r := by linarith
  have hr2 : (0 : ℝ) < r ^ 2 := by positivity
  have hspos : 0 < s := by nlinarith
  have hexp : (1 : ℝ) + 2 / r ≤ Real.exp (2 / r) := by
    linarith [Real.add_one_le_exp (2 / r)]
  have hup : Real.log s ≤ 2 * Real.log r + 2 / r := by
    have h1 : s ≤ r ^ 2 * Real.exp (2 / r) := by
      have h2 : r ^ 2 * (1 + 2 / r) = r ^ 2 + 2 * r := by field_simp
      nlinarith [mul_le_mul_of_nonneg_left hexp hr2.le]
    calc Real.log s ≤ Real.log (r ^ 2 * Real.exp (2 / r)) := Real.log_le_log hspos h1
      _ = 2 * Real.log r + 2 / r := by
          rw [Real.log_mul (by positivity) (Real.exp_ne_zero _), Real.log_pow, Real.log_exp]
          push_cast; ring
  have hlo : 2 * Real.log r - 2 / r ≤ Real.log s := by
    have hpos1 : (0 : ℝ) < 1 + 2 / r := by positivity
    have hinv : Real.exp (-(2 / r)) ≤ 1 - 1 / r := by
      rw [Real.exp_neg]
      have h3 : (Real.exp (2 / r))⁻¹ ≤ (1 + 2 / r)⁻¹ := inv_anti₀ hpos1 hexp
      have h4 : (1 + 2 / r)⁻¹ ≤ 1 - 1 / r := by
        rw [inv_le_iff_one_le_mul₀ hpos1]
        have he : (1 - 1 / r) * (1 + 2 / r) = 1 + 1 / r - 2 / r ^ 2 := by field_simp; ring
        rw [he]
        have h6 : 2 / r ^ 2 ≤ 1 / r := by
          rw [div_le_div_iff₀ (by positivity) hrpos]; nlinarith
        linarith
      linarith
    have h1 : r ^ 2 * Real.exp (-(2 / r)) ≤ s := by
      have h5 : r ^ 2 * (1 - 1 / r) = r ^ 2 - r := by field_simp
      nlinarith [mul_le_mul_of_nonneg_left hinv hr2.le]
    calc 2 * Real.log r - 2 / r = Real.log (r ^ 2 * Real.exp (-(2 / r))) := by
          rw [Real.log_mul (by positivity) (Real.exp_ne_zero _), Real.log_pow, Real.log_exp]
          push_cast; ring
      _ ≤ Real.log s := Real.log_le_log (by positivity) h1
  rw [abs_le]
  constructor <;> linarith

/-- The doubling law along an escaping orbit. -/
lemma abs_log_orbit_succ_sub (hz : escapeRadius c < ‖z‖) (n : ℕ) :
    |Real.log ‖orbit c z (n + 1)‖ - 2 * Real.log ‖orbit c z n‖| ≤ 2 / ‖orbit c z n‖ := by
  obtain ⟨hlow, hhigh⟩ := norm_orbit_succ_bounds hz n
  exact log_distortion _ _ (two_lt_norm_orbit hz n) hlow hhigh

/-- The increments of the normalised sequence are dominated by a geometric series. -/
lemma dist_logOrbitSeq_le (hz : escapeRadius c < ‖z‖) (n : ℕ) :
    dist (logOrbitSeq c z n) (logOrbitSeq c z (n + 1)) ≤ (1 / 2 : ℝ) ^ (n + 1) := by
  have hr2 : 2 < ‖orbit c z n‖ := two_lt_norm_orbit hz n
  have hkey := abs_log_orbit_succ_sub hz n
  have hbound : 2 / ‖orbit c z n‖ ≤ 1 := by
    rw [div_le_one (by linarith)]; linarith
  have hpowpos : (0 : ℝ) < 2 ^ (n + 1) := by positivity
  rw [Real.dist_eq, logOrbitSeq, logOrbitSeq]
  have hexpand :
      Real.log ‖orbit c z n‖ / 2 ^ n - Real.log ‖orbit c z (n + 1)‖ / 2 ^ (n + 1)
        = -(Real.log ‖orbit c z (n + 1)‖ - 2 * Real.log ‖orbit c z n‖) / 2 ^ (n + 1) := by
    field_simp
    ring
  rw [hexpand, abs_div, abs_neg, abs_of_pos hpowpos, div_le_iff₀ hpowpos]
  have hone : (1 / 2 : ℝ) ^ (n + 1) * 2 ^ (n + 1) = 1 := by
    rw [div_pow, one_pow, div_mul_cancel₀]
    positivity
  rw [hone]
  exact le_trans hkey hbound

lemma summable_geom_half : Summable fun n : ℕ => (1 / 2 : ℝ) ^ (n + 1) := by
  refine ((summable_geometric_of_lt_one (r := (1 / 2 : ℝ)) (by norm_num)
    (by norm_num)).mul_left (1 / 2)).congr fun n => ?_
  rw [pow_succ]
  ring

lemma summable_dist_logOrbitSeq (hz : escapeRadius c < ‖z‖) :
    Summable fun n : ℕ => dist (logOrbitSeq c z n) (logOrbitSeq c z n.succ) :=
  Summable.of_nonneg_of_le (fun _ => dist_nonneg) (fun n => dist_logOrbitSeq_le hz n)
    summable_geom_half

/-- **Existence of the escape rate.** For an escaping point the normalised logarithmic
orbit sequence converges, and its limit is `escapeRate c z`. -/
theorem escapeRate_tendsto (hz : escapeRadius c < ‖z‖) :
    Tendsto (logOrbitSeq c z) atTop (𝓝 (escapeRate c z)) := by
  have hcauchy : CauchySeq (logOrbitSeq c z) :=
    cauchySeq_of_summable_dist (summable_dist_logOrbitSeq hz)
  obtain ⟨L, hL⟩ := cauchySeq_tendsto_of_complete hcauchy
  rw [escapeRate, hL.limUnder_eq]
  exact hL

/-! ## The functional equation -/

lemma orbit_qmap (c z : ℂ) (n : ℕ) :
    orbit c (MandelbrotEscape.qmap c z) n = orbit c z (n + 1) := by
  have h1 : orbit c z 1 = MandelbrotEscape.qmap c z := by simp [orbit_succ']
  rw [Nat.add_comm, orbit_add, h1]

/-- **Böttcher/Green functional equation**: the escape rate doubles under one iteration. -/
theorem escapeRate_functional_equation (hz : escapeRadius c < ‖z‖) :
    escapeRate c (MandelbrotEscape.qmap c z) = 2 * escapeRate c z := by
  have hz1 : escapeRadius c < ‖MandelbrotEscape.qmap c z‖ := escapeRadius_lt_qmap_norm c z hz
  have h1 : Tendsto (logOrbitSeq c (MandelbrotEscape.qmap c z)) atTop
      (𝓝 (escapeRate c (MandelbrotEscape.qmap c z))) := escapeRate_tendsto hz1
  have h2 : Tendsto (fun n => 2 * logOrbitSeq c z (n + 1)) atTop (𝓝 (2 * escapeRate c z)) :=
    Tendsto.const_mul 2
      ((Filter.tendsto_add_atTop_iff_nat (f := logOrbitSeq c z) 1).mpr (escapeRate_tendsto hz))
  have heq : ∀ n, logOrbitSeq c (MandelbrotEscape.qmap c z) n = 2 * logOrbitSeq c z (n + 1) := by
    intro n
    rw [logOrbitSeq, logOrbitSeq, orbit_qmap, pow_succ]
    field_simp
  exact tendsto_nhds_unique (Filter.Tendsto.congr heq h1) h2

/-- Iterated functional equation: `G_c(f_c^N z) = 2^N · G_c(z)`. -/
theorem escapeRate_iterate (hz : escapeRadius c < ‖z‖) (N : ℕ) :
    escapeRate c (orbit c z N) = 2 ^ N * escapeRate c z := by
  induction N with
  | zero => simp
  | succ N ih =>
    have hN : escapeRadius c < ‖orbit c z N‖ := (escape_norm_growth c z hz N).1
    have h := escapeRate_functional_equation hN
    rw [← orbit_succ'] at h
    rw [h, ih, pow_succ]
    ring

/-! ## Effective bounds and positivity -/

/-- **A priori estimate**: the escape rate differs from `log ‖z‖` by at most `1`. -/
theorem abs_escapeRate_sub_log_le_one (hz : escapeRadius c < ‖z‖) :
    |escapeRate c z - Real.log ‖z‖| ≤ 1 := by
  have hdist := dist_le_tsum_of_dist_le_of_tendsto₀ (fun n : ℕ => (1 / 2 : ℝ) ^ (n + 1))
    (fun n => dist_logOrbitSeq_le hz n) summable_geom_half (escapeRate_tendsto hz)
  have htsum : (∑' n : ℕ, (1 / 2 : ℝ) ^ (n + 1)) = 1 := by
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

/-- **Positivity of the escape rate.** Every escaping point has strictly positive escape
rate: iterate the functional equation until the orbit exceeds `3 > e`, where the a priori
estimate forces positivity. -/
theorem escapeRate_pos (hz : escapeRadius c < ‖z‖) : 0 < escapeRate c z := by
  obtain ⟨N, hN⟩ := ((escape_tendsto_atTop c z hz).eventually_ge_atTop 3).exists
  have hzN : escapeRadius c < ‖orbit c z N‖ := (escape_norm_growth c z hz N).1
  have hlog : 1 < Real.log ‖orbit c z N‖ := by
    have h3 : Real.log 3 ≤ Real.log ‖orbit c z N‖ := Real.log_le_log (by norm_num) hN
    have h1 : (1 : ℝ) < Real.log 3 := by
      rw [show (1 : ℝ) = Real.log (Real.exp 1) by simp]
      exact Real.log_lt_log (Real.exp_pos 1) (by linarith [Real.exp_one_lt_d9])
    linarith
  have hbound := abs_escapeRate_sub_log_le_one hzN
  rw [abs_le] at hbound
  have hposN : 0 < escapeRate c (orbit c z N) := by linarith [hbound.1]
  rw [escapeRate_iterate hz N] at hposN
  have hpow : (0 : ℝ) < 2 ^ N := by positivity
  by_contra hcon
  push_neg at hcon
  nlinarith

end EscapeCriterion