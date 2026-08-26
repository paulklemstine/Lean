import Mathlib
import Novelty.ShapeTestMonotoneDecline

/-!
# Where a leakage ghost can live, and how big it can be

Cycle-2 refinement of `Novelty.ShapeTestMonotoneDecline`. There we showed that a
curvature-mismatched baseline, tilted to match the log-residual at the two window edges,
manufactures a strict interior maximum located at the logarithmic mean of the edges. Here we
pin that artefact down quantitatively and thereby make it *falsifiable*:

* `ghost_peak_lt_window_midpoint` — a leakage ghost always sits in the **left half** of the
  window (logarithmic mean < arithmetic mean). An interior peak observed in the right half of
  the window is therefore not explicable by this mechanism.
* `ghost_peak_gt_geometric_mean` — it never sits further left than the geometric mean of the
  window edges. Together the two bounds trap the ghost in the geometric/arithmetic-mean gap.
* `ghostAmplitude_linear`, `ghostAmplitude_pos` — the bump height is exactly proportional to
  the curvature mismatch `d`, while its **location does not depend on `d` at all**. Doubling a
  baseline's curvature error must double the bump without moving it: a sharp experimental
  signature separating leakage from a genuine positional mode.
* `negative_mismatch_no_interiorMode` — the sign of the mismatch decides bump versus dip: an
  under-curved baseline produces no mode at all.

The two mean inequalities are proved from scratch in the hyperbolic normal form
`B = A e^{2s}`, via `sinh_lt_mul_cosh` (proved here by a derivative-monotonicity argument)
and Mathlib's `Real.self_lt_sinh_iff`.
-/

open Set Real

namespace ShapeTestMonotoneDecline

/-! ## 1. Two hyperbolic inequalities -/

/-- `sinh s < s cosh s` for `s > 0`, i.e. `tanh s < s`. Proved by showing that
`t ↦ t cosh t - sinh t` has derivative `t sinh t > 0` and vanishes at `0`. -/
theorem sinh_lt_mul_cosh {s : ℝ} (hs : 0 < s) : Real.sinh s < s * Real.cosh s := by
  have hderiv : ∀ x : ℝ, HasDerivAt (fun t : ℝ => t * Real.cosh t - Real.sinh t)
      (x * Real.sinh x) x := by
    intro x
    have h1 : HasDerivAt (fun t : ℝ => t * Real.cosh t)
        (1 * Real.cosh x + x * Real.sinh x) x :=
      (hasDerivAt_id x).mul (Real.hasDerivAt_cosh x)
    simpa using h1.sub (Real.hasDerivAt_sinh x)
  have hmono : StrictMonoOn (fun t : ℝ => t * Real.cosh t - Real.sinh t) (Ici 0) := by
    apply strictMonoOn_of_deriv_pos (convex_Ici 0)
    · fun_prop
    · intro x hx
      rw [interior_Ici] at hx
      have hx' : 0 < x := hx
      rw [(hderiv x).deriv]
      exact mul_pos hx' (Real.sinh_pos_iff.mpr hx')
  have hlt := hmono Set.self_mem_Ici (mem_Ici.2 hs.le) hs
  simp only [Real.cosh_zero, Real.sinh_zero, zero_mul, sub_self] at hlt
  linarith

/-- Hyperbolic normal form of a window of positive reals: `B = A e^{2s}` with `s > 0`. -/
theorem exp_repr {A B : ℝ} (hA : 0 < A) (hAB : A < B) :
    ∃ s : ℝ, 0 < s ∧ B = A * Real.exp s ^ 2 ∧ Real.log B - Real.log A = 2 * s := by
  refine ⟨(Real.log B - Real.log A) / 2, ?_, ?_, by ring⟩
  · have : Real.log A < Real.log B := Real.log_lt_log hA hAB
    linarith
  · have hB : (0:ℝ) < B := lt_trans hA hAB
    have h1 : Real.exp ((Real.log B - Real.log A) / 2) ^ 2
        = Real.exp (Real.log B - Real.log A) := by
      rw [← Real.exp_nat_mul]; ring_nf
    rw [h1, Real.exp_sub, Real.exp_log hB, Real.exp_log hA]
    field_simp

/-! ## 2. Logarithmic mean between the geometric and arithmetic means -/

/-- The logarithmic mean is strictly below the arithmetic mean. -/
theorem logMean_lt_arithMean {A B : ℝ} (hA : 0 < A) (hAB : A < B) :
    logMean A B < (A + B) / 2 := by
  obtain ⟨s, hs, hB, hlog⟩ := exp_repr hA hAB
  set E := Real.exp s with hE
  have hEpos : 0 < E := Real.exp_pos s
  have hsc := sinh_lt_mul_cosh hs
  rw [Real.sinh_eq, Real.cosh_eq, Real.exp_neg, ← hE] at hsc
  have hkey : E ^ 2 - 1 < s * (1 + E ^ 2) := by
    rw [div_lt_iff₀ (by norm_num : (0:ℝ) < 2)] at hsc
    field_simp at hsc
    nlinarith [hsc, hEpos, sq_nonneg E]
  rw [logMean, hlog, hB, div_lt_iff₀ (by linarith : (0:ℝ) < 2 * s)]
  nlinarith [hkey, hA, hEpos]

/-- The logarithmic mean is strictly above the geometric mean. -/
theorem sqrt_mul_lt_logMean {A B : ℝ} (hA : 0 < A) (hAB : A < B) :
    Real.sqrt (A * B) < logMean A B := by
  obtain ⟨s, hs, hB, hlog⟩ := exp_repr hA hAB
  set E := Real.exp s with hE
  have hEpos : 0 < E := Real.exp_pos s
  have hsq : A * B = (A * E) ^ 2 := by rw [hB]; ring
  have hsqrt : Real.sqrt (A * B) = A * E := by
    rw [hsq, Real.sqrt_sq (by positivity)]
  have hsinh := Real.self_lt_sinh_iff.mpr hs
  rw [Real.sinh_eq, Real.exp_neg, ← hE] at hsinh
  have hkey : 2 * s * E < E ^ 2 - 1 := by
    rw [lt_div_iff₀ (by norm_num : (0:ℝ) < 2)] at hsinh
    field_simp at hsinh
    nlinarith [hsinh, hEpos]
  rw [hsqrt, logMean, hlog, lt_div_iff₀ (by linarith : (0:ℝ) < 2 * s), hB]
  nlinarith [hkey, hA, hEpos]

/-! ## 3. Trapping the leakage ghost -/

/-- **A leakage ghost always lies in the left half of the window.** -/
theorem ghost_peak_lt_window_midpoint {l u : ℝ} (hl : -1 < l) (hlu : l < u) :
    logMean (1 + l) (1 + u) - 1 < (l + u) / 2 := by
  have h1 : (0:ℝ) < 1 + l := by linarith
  have h := logMean_lt_arithMean h1 (by linarith : (1:ℝ) + l < 1 + u)
  linarith

/-- **A leakage ghost never lies left of the geometric mean of the window edges.** -/
theorem ghost_peak_gt_geometric_mean {l u : ℝ} (hl : -1 < l) (hlu : l < u) :
    Real.sqrt ((1 + l) * (1 + u)) - 1 < logMean (1 + l) (1 + u) - 1 := by
  have h1 : (0:ℝ) < 1 + l := by linarith
  have h := sqrt_mul_lt_logMean h1 (by linarith : (1:ℝ) + l < 1 + u)
  linarith

/-- The ghost peak is trapped strictly between the geometric mean of the window edges and the
window midpoint. This is the falsifiable location prediction of the leakage mechanism. -/
theorem ghost_peak_trapped {d l u : ℝ} (hd : 0 < d) (hl : -1 < l) (hlu : l < u) :
    IsStrictInteriorMode (logResidual d (matchingTilt d l u)) l u
        (logMean (1 + l) (1 + u) - 1) ∧
      Real.sqrt ((1 + l) * (1 + u)) - 1 < logMean (1 + l) (1 + u) - 1 ∧
      logMean (1 + l) (1 + u) - 1 < (l + u) / 2 :=
  ⟨baseline_leakage_creates_ghost_mode hd hl hlu, ghost_peak_gt_geometric_mean hl hlu,
    ghost_peak_lt_window_midpoint hl hlu⟩

/-- **Falsifier.** An interior peak located in the right half of the window cannot be produced
by endpoint-matched baseline curvature leakage. -/
theorem right_half_mode_not_leakage {d l u x : ℝ} (hd : 0 < d) (hl : -1 < l) (hlu : l < u)
    (hx : (l + u) / 2 ≤ x) :
    ¬ IsStrictInteriorMode (logResidual d (matchingTilt d l u)) l u x := by
  intro hmode
  have heq := hmode.unique (baseline_leakage_creates_ghost_mode hd hl hlu)
  have hlt := ghost_peak_lt_window_midpoint hl hlu
  rw [heq] at hx
  linarith

/-! ## 4. Amplitude scaling: the mismatch calibrates the bump but cannot move it -/

/-- Height of the manufactured bump above the (common) edge value. -/
noncomputable def ghostAmplitude (d l u : ℝ) : ℝ :=
  logResidual d (matchingTilt d l u) (logMean (1 + l) (1 + u) - 1)
    - logResidual d (matchingTilt d l u) l

theorem logResidual_scale (d b x : ℝ) : logResidual d (d * b) x = d * logResidual 1 b x := by
  simp only [logResidual]; ring

theorem matchingTilt_linear (d l u : ℝ) : matchingTilt d l u = d * matchingTilt 1 l u := by
  simp only [matchingTilt]; ring

theorem matchingTilt_neg_mismatch (d l u : ℝ) :
    matchingTilt (-d) l u = - matchingTilt d l u := by
  simp only [matchingTilt]; ring

theorem logResidual_neg (d b x : ℝ) : logResidual (-d) (-b) x = - logResidual d b x := by
  simp only [logResidual]; ring

/-- **The bump height is exactly proportional to the curvature mismatch**, while its location
(the logarithmic mean) is independent of it. -/
theorem ghostAmplitude_linear (d l u : ℝ) : ghostAmplitude d l u = d * ghostAmplitude 1 l u := by
  simp only [ghostAmplitude]
  rw [matchingTilt_linear d l u, logResidual_scale, logResidual_scale]
  ring

/-- The manufactured bump is a genuine excess: its height is strictly positive. -/
theorem ghostAmplitude_pos {d l u : ℝ} (hd : 0 < d) (hl : -1 < l) (hlu : l < u) :
    0 < ghostAmplitude d l u := by
  obtain ⟨hx, hmax⟩ := baseline_leakage_creates_ghost_mode hd hl hlu
  have hlne : l ≠ logMean (1 + l) (1 + u) - 1 := ne_of_lt hx.1
  have h := hmax l ⟨le_rfl, hlu.le⟩ hlne
  simp only [ghostAmplitude]
  linarith

/-! ## 5. The sign of the mismatch decides bump versus dip -/

/-- The log-residual of a positively mismatched baseline is strictly concave. -/
theorem logResidual_strictConcaveOn {d : ℝ} (hd : 0 < d) (b : ℝ) :
    StrictConcaveOn ℝ (Ioi (-1 : ℝ)) (logResidual d b) := by
  refine ⟨convex_Ioi _, ?_⟩
  intro x hx y hy hxy p q hp hq hpq
  simp only [smul_eq_mul, mem_Ioi, logResidual] at *
  have hA : (0:ℝ) < 1 + x := by linarith
  have hB : (0:ℝ) < 1 + y := by linarith
  have hne : (1 + x) ≠ (1 + y) := by intro h; exact hxy (by linarith)
  have h := strictConcaveOn_log_Ioi.2 (mem_Ioi.2 hA) (mem_Ioi.2 hB) hne hp hq hpq
  simp only [smul_eq_mul] at h
  have harg : p * (1 + x) + q * (1 + y) = 1 + (p * x + q * y) := by nlinarith [hpq]
  rw [harg] at h
  nlinarith [h]

/-- The log-residual of a non-positively mismatched baseline is convex, for any tilt. -/
theorem logResidual_convexOn_of_nonpos {d : ℝ} (hd : d ≤ 0) (b : ℝ) :
    ConvexOn ℝ (Ioi (-1 : ℝ)) (logResidual d b) := by
  refine ⟨convex_Ioi _, ?_⟩
  intro x hx y hy p q hp hq hpq
  simp only [smul_eq_mul, mem_Ioi, logResidual] at *
  have hA : (0:ℝ) < 1 + x := by linarith
  have hB : (0:ℝ) < 1 + y := by linarith
  have h := (strictConcaveOn_log_Ioi.concaveOn).2 (mem_Ioi.2 hA) (mem_Ioi.2 hB) hp hq hpq
  simp only [smul_eq_mul] at h
  have harg : p * (1 + x) + q * (1 + y) = 1 + (p * x + q * y) := by nlinarith [hpq]
  rw [harg] at h
  nlinarith [h]

/-- **A baseline no more curved than the signal can never leak a peak, whatever tilt is
fitted.** This is the certificate form of the erratum: the guarantee depends only on the sign
of the log-curvature mismatch, not on the calibration. -/
theorem undercurved_baseline_no_strict_mode {d b l u : ℝ} (hd : d ≤ 0) (hl : -1 < l)
    (hlu : l < u) (x : ℝ) : ¬ IsStrictInteriorMode (logResidual d b) l u x := by
  refine no_strictInteriorMode_of_convexOn hlu ?_ x
  exact (logResidual_convexOn_of_nonpos hd b).subset
    (fun z hz => mem_Ioi.2 (by have := hz.1; linarith)) (convex_Icc l u)

/-- **An under-curved baseline produces no mode at all.** For a negative curvature mismatch the
endpoint-matched residual dips in the middle: no interior maximum exists anywhere. -/
theorem negative_mismatch_no_interiorMode {d l u : ℝ} (hd : d < 0) (hl : -1 < l)
    (hlu : l < u) (x : ℝ) : ¬ IsInteriorMode (logResidual d (matchingTilt d l u)) l u x := by
  rintro ⟨hx, hmax⟩
  set b := matchingTilt d l u with hb
  have hcc : StrictConcaveOn ℝ (Ioi (-1:ℝ)) (logResidual (-d) (-b)) :=
    logResidual_strictConcaveOn (by linarith) _
  have hlmem : l ∈ Ioi (-1:ℝ) := mem_Ioi.2 hl
  have humem : u ∈ Ioi (-1:ℝ) := mem_Ioi.2 (by linarith)
  have hseg : x ∈ openSegment ℝ l u := by rw [openSegment_eq_Ioo hlu]; exact hx
  have hgt := hcc.lt_on_openSegment hlmem humem hlu.ne hseg
  have hedges : logResidual (-d) (-b) l = logResidual (-d) (-b) u := by
    rw [hb, ← matchingTilt_neg_mismatch d l u]
    exact logResidual_edges_eq hlu
  rw [hedges, min_self] at hgt
  rw [logResidual_neg, logResidual_neg] at hgt
  have hu := hmax u ⟨hlu.le, le_rfl⟩
  linarith

/-! ## 6. Leakage beyond the power-law family -/

/-- A strictly concave shape whose values agree at the two window edges has a strict interior
mode: compactness gives a maximiser, strict concavity places it in the interior and makes it
unique. -/
theorem strictConcave_matched_endpoints_mode {f : ℝ → ℝ} {l u : ℝ} (hlu : l < u)
    (hcont : ContinuousOn f (Icc l u)) (hconc : StrictConcaveOn ℝ (Icc l u) f)
    (hends : f l = f u) : ∃ x, IsStrictInteriorMode f l u x := by
  obtain ⟨x, hxmem, hxmax⟩ :=
    (isCompact_Icc (a := l) (b := u)).exists_isMaxOn ⟨l, ⟨le_rfl, hlu.le⟩⟩ hcont
  have hmax' : ∀ y ∈ Icc l u, f y ≤ f x := fun y hy => hxmax hy
  have hlI : l ∈ Icc l u := ⟨le_rfl, hlu.le⟩
  have huI : u ∈ Icc l u := ⟨hlu.le, le_rfl⟩
  have hmidI : ((l + u) / 2) ∈ Icc l u := ⟨by linarith, by linarith⟩
  have hmidu : f u < f ((l + u) / 2) := by
    have hseg : ((l + u) / 2) ∈ openSegment ℝ l u := by
      rw [openSegment_eq_Ioo hlu]; exact ⟨by linarith, by linarith⟩
    have h := hconc.lt_on_openSegment hlI huI hlu.ne hseg
    rwa [hends, min_self] at h
  have hmidl : f l < f ((l + u) / 2) := by rw [hends]; exact hmidu
  have hxint : x ∈ Ioo l u := by
    constructor
    · rcases eq_or_lt_of_le hxmem.1 with h1 | h1
      · exfalso
        have hcmp := hmax' _ hmidI
        rw [← h1] at hcmp
        linarith
      · exact h1
    · rcases eq_or_lt_of_le hxmem.2 with h2 | h2
      · exfalso
        have hcmp := hmax' _ hmidI
        rw [h2] at hcmp
        linarith
      · exact h2
  refine ⟨x, hxint, fun y hy hne => ?_⟩
  rcases lt_or_eq_of_le (hmax' y hy) with h | h
  · exact h
  · exfalso
    have hz : ((y + x) / 2) ∈ openSegment ℝ y x := by
      rcases lt_or_gt_of_ne hne with hyx | hyx
      · rw [openSegment_eq_Ioo hyx]; exact ⟨by linarith, by linarith⟩
      · rw [openSegment_symm, openSegment_eq_Ioo hyx]; exact ⟨by linarith, by linarith⟩
    have hlt := hconc.lt_on_openSegment hy hxmem hne hz
    have hzI : ((y + x) / 2) ∈ Icc l u := by
      refine ⟨by have := hy.1; have := hxmem.1; linarith,
        by have := hy.2; have := hxmem.2; linarith⟩
    have hle := hmax' _ hzI
    rw [h, min_self] at hlt
    linarith

/-- **General curvature leakage.** For *any* strictly convex continuous log-baseline excess `g`
on the window, the secant tilt makes the residual match at the edges and forces a strict
interior mode. The manufactured peak is therefore not an artefact of the power-law
parametrisation: it is a consequence of curvature alone. -/
theorem general_curvature_leakage {g : ℝ → ℝ} {l u : ℝ} (hlu : l < u)
    (hcont : ContinuousOn g (Icc l u)) (hconv : StrictConvexOn ℝ (Icc l u) g) :
    ∃ x, IsStrictInteriorMode (fun y => (g u - g l) / (u - l) * y - g y) l u x := by
  set c := (g u - g l) / (u - l) with hc
  have haff : ConcaveOn ℝ (Icc l u) (fun y => 0 + c * y) :=
    concaveOn_affine 0 c (convex_Icc l u)
  have hconc : StrictConcaveOn ℝ (Icc l u) (fun y => c * y - g y) :=
    (ConcaveOn.sub_strictConvexOn haff hconv).congr (fun y _ => by simp)
  have hcont' : ContinuousOn (fun y => c * y - g y) (Icc l u) :=
    (continuousOn_const.mul continuousOn_id).sub hcont
  have hends : c * l - g l = c * u - g u := by
    have hne : u - l ≠ 0 := by intro h; exact absurd (by linarith : l = u) (ne_of_lt hlu)
    rw [hc]
    field_simp
    ring
  exact strictConcave_matched_endpoints_mode hlu hcont' hconc hends

end ShapeTestMonotoneDecline