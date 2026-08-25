import Mathlib
import Catalog.NumberTheory.ProfileFormResidualPeak

/-!
# Profile form V: how robust is the interior peak?

Context (experiment 579, paper 229; V2 rule and the fragility gate).  The
beyond-Dickman residual was fitted by a concave quadratic pinned at the measured
end values `R(0) = 0.80`, `R(1) = 0.90`, with curvature coefficient `c` whose
confidence interval is `[-0.62, -0.14]`; the reported vertex is `0.59`, interior,
and the verdict "PEAKED" was declared invariant across all three offset-`r`
brackets.

This file replaces the single fit by the whole one-parameter family

`residualQuad c x = 4/5 + (1/10 - c) x + c x²`  (the endpoint-pinned fits),

and asks which curvatures actually produce an interior peak.  The answer is a
sharp threshold at `c = -1/10`:

* `residualQuad_vertex_mem_Ioo` — for `c < -1/10` the vertex lies in `(1/2, 1)`;
* `residualQuad_peak_of_lt` — and the fit is then genuinely peaked: strict
  interior maximum, neither monotone nor antitone on the window;
* `residualQuad_monotoneOn_of_ge` — for `-1/10 ≤ c < 0` the fit is *monotone*
  on the window: no peak at all;
* `residualQuad_peak_invariant_over_CI` — the whole measured interval
  `[-0.62, -0.14]` sits on the peaked side, so the verdict is invariant across
  the reported bootstrap range, with margin `0.04` to the threshold;
* `residualQuad_hump_ratio_ge` — the apex of every concave endpoint-pinned fit
  overshoots the wall end value by at least `12 %` (the apex is attained inside
  the window exactly when `c < -1/10`), and
* `residualQuad_peak_gt_right_end` — the apex always overshoots the far end
  value too;
* `residualQuad_eq_residualFit` — the reported fit is the member `c = -5/9`.
-/

namespace ProfileForm

open Set

/-- Endpoint-pinned concave fits of the beyond-Dickman residual: the quadratic
with `R(0) = 0.80`, `R(1) = 0.90` and curvature `c`. -/
noncomputable def residualQuad (c x : ℝ) : ℝ := 4/5 + (1/10 - c) * x + c * x ^ 2

@[simp] theorem residualQuad_zero (c : ℝ) : residualQuad c 0 = 4/5 := by
  simp [residualQuad]

@[simp] theorem residualQuad_one (c : ℝ) : residualQuad c 1 = 9/10 := by
  simp only [residualQuad]; ring

/-- The reported fit is the member `c = -5/9` of the family. -/
theorem residualQuad_eq_residualFit (x : ℝ) : residualQuad (-5/9) x = residualFit x := by
  simp only [residualQuad, residualFit]; ring

/-- The vertex of the fit with curvature `c`. -/
noncomputable def residualQuadVertex (c : ℝ) : ℝ := (1/10 - c) / (-2 * c)

/-- Exact concavity identity around the vertex. -/
theorem residualQuad_vertex_identity {c : ℝ} (hc : c ≠ 0) (x : ℝ) :
    residualQuad c (residualQuadVertex c) - residualQuad c x
      = -c * (x - residualQuadVertex c) ^ 2 := by
  simp only [residualQuad, residualQuadVertex]
  field_simp
  ring

/-- Closed form for the peak height. -/
theorem residualQuad_vertex_value {c : ℝ} (hc : c ≠ 0) :
    residualQuad c (residualQuadVertex c) = 4/5 - (1/10 - c) ^ 2 / (4 * c) := by
  simp only [residualQuad, residualQuadVertex]
  field_simp
  ring

/-- **Threshold, peaked side.**  Curvature below `-1/10` puts the vertex strictly
inside the window (indeed in the right half). -/
theorem residualQuad_vertex_mem_Ioo {c : ℝ} (hc : c < -1/10) :
    residualQuadVertex c ∈ Ioo (1/2 : ℝ) 1 := by
  have hcneg : c < 0 := by linarith
  have hden : (0:ℝ) < -2 * c := by linarith
  constructor
  · rw [residualQuadVertex, lt_div_iff₀ hden]
    nlinarith
  · rw [residualQuadVertex, div_lt_one hden]
    nlinarith

/-- Strict global maximum at the vertex. -/
theorem residualQuad_lt_vertex {c x : ℝ} (hc : c < 0) (hx : x ≠ residualQuadVertex c) :
    residualQuad c x < residualQuad c (residualQuadVertex c) := by
  have hid := residualQuad_vertex_identity (ne_of_lt hc) x
  have hsq : 0 < (x - residualQuadVertex c) ^ 2 := by
    have : x - residualQuadVertex c ≠ 0 := sub_ne_zero.mpr hx
    positivity
  nlinarith

/-- **The apex always clears the far end value.**  For any concave
endpoint-pinned fit the apex height exceeds `R(1) = 0.90`, with equality only in
the degenerate threshold case `c = -1/10`. -/
theorem residualQuad_peak_gt_right_end {c : ℝ} (hc : c < 0) (hne : c ≠ -1/10) :
    9/10 < residualQuad c (residualQuadVertex c) := by
  rw [residualQuad_vertex_value (ne_of_lt hc)]
  have hkey : (1/10 - c) ^ 2 / (4 * c) < -(1/10 : ℝ) := by
    rw [div_lt_iff_of_neg (by linarith)]
    have hsq : 0 < (c + 1/10) ^ 2 := by
      have : c + 1/10 ≠ 0 := by
        intro h; apply hne; linarith
      positivity
    nlinarith
  linarith

/-- **The apex of every concave endpoint-pinned fit is at least `12 %` above the
small-`j` wall end value.**  (For `c < -1/10` the apex is attained inside the
window, so this is a genuine hump; for weaker curvature the apex lies beyond the
right endpoint.) -/
theorem residualQuad_hump_ratio_ge {c : ℝ} (hc : c < 0) :
    (28/25) * residualQuad c 0 ≤ residualQuad c (residualQuadVertex c) := by
  rw [residualQuad_zero, residualQuad_vertex_value (ne_of_lt hc)]
  have hkey : (1/10 - c) ^ 2 / (4 * c) ≤ -(0.096 : ℝ) := by
    rw [div_le_iff_of_neg (by linarith)]
    nlinarith [sq_nonneg (c + 0.092), sq_nonneg c]
  linarith

/-- **Peakedness on the whole sub-threshold range.** -/
theorem residualQuad_peak_of_lt {c : ℝ} (hc : c < -1/10) :
    (∃ m ∈ Ioo (0:ℝ) 1, IsMaxOn (residualQuad c) (Icc (0:ℝ) 1) m) ∧
      ¬ MonotoneOn (residualQuad c) (Icc (0:ℝ) 1) ∧
      ¬ AntitoneOn (residualQuad c) (Icc (0:ℝ) 1) := by
  have hcneg : c < 0 := by linarith
  have hv := residualQuad_vertex_mem_Ioo hc
  have hvIoo : residualQuadVertex c ∈ Ioo (0:ℝ) 1 := ⟨by linarith [hv.1], hv.2⟩
  have h0 : residualQuad c 0 < residualQuad c (residualQuadVertex c) :=
    residualQuad_lt_vertex hcneg (by intro h; rw [← h] at hv; linarith [hv.1])
  have h1 : residualQuad c 1 < residualQuad c (residualQuadVertex c) :=
    residualQuad_lt_vertex hcneg (by intro h; rw [h] at hv; linarith [hv.2])
  have hcont : ContinuousOn (residualQuad c) (Icc (0:ℝ) 1) := by
    apply Continuous.continuousOn
    unfold residualQuad
    fun_prop
  exact ⟨exists_interiorMax_of_gt_endpoints hcont hvIoo h0 h1,
    not_monotoneOn_of_peak hvIoo h1, not_antitoneOn_of_peak hvIoo h0⟩

/-- **Threshold, monotone side.**  A curvature weaker than `-1/10` produces no
peak whatsoever: the fit increases across the whole window. -/
theorem residualQuad_monotoneOn_of_ge {c : ℝ} (hc1 : -1/10 ≤ c) (hc2 : c < 0) :
    MonotoneOn (residualQuad c) (Icc (0:ℝ) 1) := by
  intro x hx y hy hxy
  have hx0 : 0 ≤ x := hx.1
  have hy1 : y ≤ 1 := hy.2
  have hfac : residualQuad c y - residualQuad c x
      = (y - x) * ((1/10 - c) + c * (x + y)) := by
    simp only [residualQuad]; ring
  have hslope : 0 ≤ (1/10 - c) + c * (x + y) := by
    nlinarith [hx.1, hy.2, hx.2, hy.1]
  nlinarith [hfac, hslope, sub_nonneg.mpr hxy]

/-- **The measured verdict is invariant across the reported bootstrap interval
for the curvature.**  Every `c ∈ [-0.62, -0.14]` gives an interior peak, and the
interval clears the threshold `-0.1` by `0.04`. -/
theorem residualQuad_peak_invariant_over_CI :
    ∀ c ∈ Icc (-0.62 : ℝ) (-0.14),
      (∃ m ∈ Ioo (0:ℝ) 1, IsMaxOn (residualQuad c) (Icc (0:ℝ) 1) m) ∧
        ¬ MonotoneOn (residualQuad c) (Icc (0:ℝ) 1) ∧
        ¬ AntitoneOn (residualQuad c) (Icc (0:ℝ) 1) := by
  intro c hc
  exact residualQuad_peak_of_lt (by linarith [hc.2])

/-- The threshold is sharp: at `c = -1/10` the vertex sits exactly at the right
endpoint, so the peak degenerates into monotonicity. -/
theorem residualQuadVertex_threshold : residualQuadVertex (-1/10) = 1 := by
  norm_num [residualQuadVertex]

end ProfileForm