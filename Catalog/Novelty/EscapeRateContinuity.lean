import Mathlib
import Novelty.FilledJuliaCompact

/-!
# Uniform convergence and continuity of the escape rate

Fifth iteration of the escape-criterion thread. The increment bound
`dist_logOrbitSeq_le` is *uniform* in both the point `z` and the parameter `c`: the
`n`-th term of the defining sequence of the escape rate differs from its limit by at most
`2^{-n}`, whatever escaping `z` and whatever `c`. Consequently the convergence is uniform
on the whole escaping region, and the escape rate inherits continuity from the polynomial
iterates.

Main results:

* `abs_logOrbitSeq_sub_escapeRate_le`: `|2^{-n} log ‖z_n‖ - G_c(z)| ≤ 2^{-n}`, an explicit
  error bound for the numerical computation of the escape rate.
* `tendstoUniformlyOn_logOrbitSeq`: uniform convergence on the escaping region.
* `continuousOn_escapeRate`: `G_c` is continuous on `{z | ‖z‖ > max 2 ‖c‖}`.
* `continuousOn_mandelbrotPotential`: the Douady–Hubbard potential `G_M` is continuous on
  `{c | ‖c‖ > 2}`, obtained from the same uniform estimate in the *parameter*.
-/

namespace EscapeCriterion

open Filter MandelbrotEscape
open scoped Topology

variable {c z : ℂ}

/-- **Explicit error bound** for the escape rate: truncating the defining sequence at step
`n` costs at most `2^{-n}`, uniformly in `c` and in the escaping point `z`. -/
theorem abs_logOrbitSeq_sub_escapeRate_le (hz : escapeRadius c < ‖z‖) (n : ℕ) :
    |logOrbitSeq c z n - escapeRate c z| ≤ (1 / 2 : ℝ) ^ n := by
  have hdist := dist_le_tsum_of_dist_le_of_tendsto (fun k : ℕ => (1 / 2 : ℝ) ^ (k + 1))
    (fun k => dist_logOrbitSeq_le hz k) summable_geom_half (escapeRate_tendsto hz) n
  have htsum : (∑' m : ℕ, (1 / 2 : ℝ) ^ (n + m + 1)) = (1 / 2 : ℝ) ^ n := by
    have h : ∀ m : ℕ, (1 / 2 : ℝ) ^ (n + m + 1) = ((1 / 2 : ℝ) ^ (n + 1)) * (1 / 2 : ℝ) ^ m := by
      intro m
      rw [← pow_add]
      ring_nf
    rw [tsum_congr h, tsum_mul_left, tsum_geometric_of_lt_one (by norm_num) (by norm_num)]
    rw [pow_succ]
    ring
  rw [htsum] at hdist
  rwa [Real.dist_eq] at hdist

lemma continuousOn_logOrbitSeq (c : ℂ) (n : ℕ) :
    ContinuousOn (fun z => logOrbitSeq c z n) {z : ℂ | escapeRadius c < ‖z‖} := by
  intro z hz
  refine ContinuousAt.continuousWithinAt ?_
  have hne : ‖orbit c z n‖ ≠ 0 := by
    have := two_lt_norm_orbit (c := c) (z := z) hz n
    positivity
  exact ContinuousAt.div_const
    (ContinuousAt.log ((continuous_orbit c n).norm).continuousAt hne) _

/-- **Uniform convergence** of the defining sequence of the escape rate on the escaping
region. -/
theorem tendstoUniformlyOn_logOrbitSeq (c : ℂ) :
    TendstoUniformlyOn (fun n z => logOrbitSeq c z n) (escapeRate c) atTop
      {z : ℂ | escapeRadius c < ‖z‖} := by
  rw [Metric.tendstoUniformlyOn_iff]
  intro ε hε
  obtain ⟨N, hN⟩ : ∃ N : ℕ, (1 / 2 : ℝ) ^ N < ε :=
    exists_pow_lt_of_lt_one hε (by norm_num)
  filter_upwards [eventually_ge_atTop N] with n hn z hz
  have hbound := abs_logOrbitSeq_sub_escapeRate_le (c := c) (z := z) hz n
  have hmono : (1 / 2 : ℝ) ^ n ≤ (1 / 2 : ℝ) ^ N :=
    pow_le_pow_of_le_one (by norm_num) (by norm_num) hn
  rw [Real.dist_eq, abs_sub_comm]
  linarith

/-- **Continuity of the escape rate** on the escaping region. -/
theorem continuousOn_escapeRate (c : ℂ) :
    ContinuousOn (escapeRate c) {z : ℂ | escapeRadius c < ‖z‖} :=
  (tendstoUniformlyOn_logOrbitSeq c).continuousOn
    ((Eventually.of_forall fun n => continuousOn_logOrbitSeq c n).frequently)

/-! ## Continuity of the Douady–Hubbard potential -/

/-- The truncations of the potential, `2^{-(n+1)} log ‖z_{n+2}(c)‖`. -/
noncomputable def potentialSeq (n : ℕ) (c : ℂ) : ℝ := logOrbitSeq c (orbit c 0 2) n / 2

lemma potentialSeq_eq (n : ℕ) (c : ℂ) :
    potentialSeq n c = Real.log ‖critOrbit c (n + 2)‖ / 2 ^ (n + 1) := by
  rw [potentialSeq, logOrbitSeq, critOrbit_eq_orbit, ← orbit_add, Nat.add_comm 2 n, pow_succ]
  field_simp

lemma abs_potentialSeq_sub_le (hc : 2 < ‖c‖) (n : ℕ) :
    |potentialSeq n c - mandelbrotPotential c| ≤ (1 / 2 : ℝ) ^ n := by
  have hz2 : escapeRadius c < ‖orbit c 0 2‖ := escapeRadius_lt_norm_critOrbit_two hc
  have h := abs_logOrbitSeq_sub_escapeRate_le hz2 n
  have hhalf : |potentialSeq n c - mandelbrotPotential c|
      = |logOrbitSeq c (orbit c 0 2) n - escapeRate c (orbit c 0 2)| / 2 := by
    rw [potentialSeq, mandelbrotPotential, ← abs_of_pos (show (0:ℝ) < 2 by norm_num),
      ← abs_div]
    congr 1
    ring
  rw [hhalf]
  have hpos : (0 : ℝ) ≤ (1 / 2 : ℝ) ^ n := by positivity
  linarith [abs_nonneg (logOrbitSeq c (orbit c 0 2) n - escapeRate c (orbit c 0 2))]

lemma continuousOn_potentialSeq (n : ℕ) :
    ContinuousOn (potentialSeq n) {c : ℂ | 2 < ‖c‖} := by
  intro c hc
  refine ContinuousAt.continuousWithinAt ?_
  have hne : ‖critOrbit c (n + 2)‖ ≠ 0 := by
    have hz2 : escapeRadius c < ‖orbit c 0 2‖ := escapeRadius_lt_norm_critOrbit_two hc
    have h2 : 2 < ‖orbit c (orbit c 0 2) n‖ := two_lt_norm_orbit hz2 n
    have hidx : orbit c (orbit c 0 2) n = critOrbit c (n + 2) := by
      rw [critOrbit_eq_orbit, ← orbit_add, Nat.add_comm 2 n]
    rw [hidx] at h2
    positivity
  have hcont : ContinuousAt (fun c : ℂ => Real.log ‖critOrbit c (n + 2)‖ / 2 ^ (n + 1)) c :=
    ContinuousAt.div_const
      (ContinuousAt.log ((continuous_critOrbit (n + 2)).norm).continuousAt hne) _
  exact hcont.congr (Filter.Eventually.of_forall fun c => (potentialSeq_eq n c).symm)

/-- **Continuity of the Douady–Hubbard potential** on the exterior of the closed disk of
radius `2`. -/
theorem continuousOn_mandelbrotPotential :
    ContinuousOn mandelbrotPotential {c : ℂ | 2 < ‖c‖} := by
  have huniform : TendstoUniformlyOn potentialSeq mandelbrotPotential atTop {c : ℂ | 2 < ‖c‖} := by
    rw [Metric.tendstoUniformlyOn_iff]
    intro ε hε
    obtain ⟨N, hN⟩ : ∃ N : ℕ, (1 / 2 : ℝ) ^ N < ε :=
      exists_pow_lt_of_lt_one hε (by norm_num)
    filter_upwards [eventually_ge_atTop N] with n hn c hc
    have hbound := abs_potentialSeq_sub_le hc n
    have hmono : (1 / 2 : ℝ) ^ n ≤ (1 / 2 : ℝ) ^ N :=
      pow_le_pow_of_le_one (by norm_num) (by norm_num) hn
    rw [Real.dist_eq, abs_sub_comm]
    linarith
  exact huniform.continuousOn ((Eventually.of_forall continuousOn_potentialSeq).frequently)

end EscapeCriterion