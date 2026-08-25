import Mathlib

/-!
# Monotone decline versus interior modes: the shape/leakage decomposition

This file formalises the mathematical skeleton behind the *absolute-shape* channel
closure (exp 583): a highly significant rejection of a **linear-in-`x`** model for a
positional rate does **not** license an interior positional mode, because the
alternative that actually fits — a power law `T(x) = C (1+x)^(-a)` — is nonlinear
*and* strictly declining, hence provably mode-free.

The second half proves the erratum: an apparent *mid-window* peak in a residual is
manufactured by baseline curvature alone. If the baseline carries a different
log-curvature exponent than the signal, and a linear tilt is fitted so that the
log-residual matches at the two window ends, then the residual has a genuine strict
interior maximum, located exactly at the **logarithmic mean** of the window ends
(shifted by the `1+x` convention). No positional mode is needed to produce it.

Main results:
* `rateT_strictAntiOn`, `rateT_no_interiorMode` — the power law never has an interior mode.
* `logRate_strictConvexOn`, `rateT_log_not_affine` — yet its log rate is *not* affine in `x`
  (real nonlinearity, of purely convex-decline type).
* `no_interiorMode_of_strictConvexOn` — no strictly convex shape can produce an interior mode.
* `baseline_leakage_creates_ghost_mode` — curvature-mismatched baselines *do* produce one.
* `ghost_peak_eq_logMean`, `ghost_peak_unit_window_lt`, `ghost_peak_unit_window_gt` — its location.
* `strict_interior_mode_forces_nonaffine_log_residual` — an observed mode forces baseline
  mis-specification, never a positional mode inside the power-law family.
-/

open Set Real

namespace ShapeTestMonotoneDecline

/-! ## 1. Window shapes: interior modes -/

/-- `x` is an interior mode of `f` on the window `[l,u]`: an interior point at which `f`
attains its maximum over the closed window. -/
def IsInteriorMode (f : ℝ → ℝ) (l u x : ℝ) : Prop :=
  x ∈ Ioo l u ∧ ∀ y ∈ Icc l u, f y ≤ f x

/-- The strict version: an interior point which strictly dominates every other point of
the window. This is what a "positional mode" claim asserts. -/
def IsStrictInteriorMode (f : ℝ → ℝ) (l u x : ℝ) : Prop :=
  x ∈ Ioo l u ∧ ∀ y ∈ Icc l u, y ≠ x → f y < f x

theorem IsStrictInteriorMode.isInteriorMode {f : ℝ → ℝ} {l u x : ℝ}
    (h : IsStrictInteriorMode f l u x) : IsInteriorMode f l u x := by
  refine ⟨h.1, fun y hy => ?_⟩
  rcases eq_or_ne y x with rfl | hne
  · exact le_rfl
  · exact (h.2 y hy hne).le

/-- Modes only depend on the values of the function on the window. -/
theorem IsStrictInteriorMode.congr {f g : ℝ → ℝ} {l u x : ℝ}
    (h : IsStrictInteriorMode f l u x) (hfg : EqOn f g (Icc l u)) :
    IsStrictInteriorMode g l u x := by
  obtain ⟨hx, hmax⟩ := h
  have hxI : x ∈ Icc l u := ⟨hx.1.le, hx.2.le⟩
  refine ⟨hx, fun y hy hne => ?_⟩
  rw [← hfg hy, ← hfg hxI]
  exact hmax y hy hne

/-- A strict interior mode is unique. -/
theorem IsStrictInteriorMode.unique {f : ℝ → ℝ} {l u x x' : ℝ}
    (h : IsStrictInteriorMode f l u x) (h' : IsStrictInteriorMode f l u x') : x = x' := by
  by_contra hne
  have hx : x ∈ Icc l u := ⟨h.1.1.le, h.1.2.le⟩
  have hx' : x' ∈ Icc l u := ⟨h'.1.1.le, h'.1.2.le⟩
  have h1 := h.2 x' hx' (Ne.symm hne)
  have h2 := h'.2 x hx hne
  linarith

/-- A strictly decreasing shape has no interior mode: the left edge always wins. -/
theorem no_interiorMode_of_strictAntiOn {f : ℝ → ℝ} {l u : ℝ} (hlu : l < u)
    (hf : StrictAntiOn f (Icc l u)) (x : ℝ) : ¬ IsInteriorMode f l u x := by
  rintro ⟨hx, hmax⟩
  have hlI : l ∈ Icc l u := ⟨le_rfl, hlu.le⟩
  have hxI : x ∈ Icc l u := ⟨hx.1.le, hx.2.le⟩
  have : f x < f l := hf hlI hxI hx.1
  exact absurd (hmax l hlI) (not_le.2 this)

/-- **No strictly convex shape can have an interior mode.** Convex curvature — however
strongly it rejects a linear model — is structurally incapable of producing a hump. -/
theorem no_interiorMode_of_strictConvexOn {f : ℝ → ℝ} {l u : ℝ} (hlu : l < u)
    (hf : StrictConvexOn ℝ (Icc l u) f) (x : ℝ) : ¬ IsInteriorMode f l u x := by
  rintro ⟨hx, hmax⟩
  have hlI : l ∈ Icc l u := ⟨le_rfl, hlu.le⟩
  have huI : u ∈ Icc l u := ⟨hlu.le, le_rfl⟩
  have hseg : x ∈ openSegment ℝ l u := by
    rw [openSegment_eq_Ioo hlu]; exact hx
  have hlt : f x < max (f l) (f u) := hf.lt_on_openSegment hlI huI hlu.ne hseg
  rcases max_cases (f l) (f u) with ⟨he, _⟩ | ⟨he, _⟩
  · rw [he] at hlt; exact absurd (hmax l hlI) (not_le.2 hlt)
  · rw [he] at hlt; exact absurd (hmax u huI) (not_le.2 hlt)

/-- **A convex shape has no strict interior mode.** (Weaker hypothesis than strict convexity,
at the price of only excluding *strict* modes.) -/
theorem no_strictInteriorMode_of_convexOn {f : ℝ → ℝ} {l u : ℝ} (hlu : l < u)
    (hf : ConvexOn ℝ (Icc l u) f) (x : ℝ) : ¬ IsStrictInteriorMode f l u x := by
  rintro ⟨hx, hmax⟩
  have hlI : l ∈ Icc l u := ⟨le_rfl, hlu.le⟩
  have huI : u ∈ Icc l u := ⟨hlu.le, le_rfl⟩
  have hseg : x ∈ segment ℝ l u := by
    rw [segment_eq_Icc hlu.le]; exact ⟨hx.1.le, hx.2.le⟩
  have hle : f x ≤ max (f l) (f u) := hf.le_on_segment hlI huI hseg
  have h1 := hmax l hlI (ne_of_lt hx.1)
  have h2 := hmax u huI (ne_of_gt hx.2)
  rcases max_cases (f l) (f u) with ⟨he, _⟩ | ⟨he, _⟩ <;> rw [he] at hle <;> linarith

/-- Affine functions are concave. -/
theorem concaveOn_affine (p q : ℝ) {s : Set ℝ} (hs : Convex ℝ s) :
    ConcaveOn ℝ s (fun y => p + q * y) := by
  refine ⟨hs, fun x _ y _ c d hc hd hcd => ?_⟩
  simp only [smul_eq_mul]
  have hd' : d = 1 - c := by linarith
  subst hd'
  ring_nf
  linarith

/-- Affine functions are convex. -/
theorem convexOn_affine (p q : ℝ) {s : Set ℝ} (hs : Convex ℝ s) :
    ConvexOn ℝ s (fun y => p + q * y) := by
  refine ⟨hs, fun x _ y _ c d hc hd hcd => ?_⟩
  simp only [smul_eq_mul]
  have hd' : d = 1 - c := by linarith
  subst hd'
  ring_nf
  linarith

/-- A residual that is affine on the window has no strict interior mode. -/
theorem no_strictInteriorMode_of_affine {l u : ℝ} (hlu : l < u) (p q x : ℝ) :
    ¬ IsStrictInteriorMode (fun y => p + q * y) l u x :=
  no_strictInteriorMode_of_convexOn hlu (convexOn_affine p q (convex_Icc l u)) x

/-- **Log-curvature certificate.** If the log-ratio of signal to baseline is convex on the
window, then no fitted linear tilt can make the residual display a strict interior mode. This
is the reusable side condition guaranteeing that a baseline cannot leak a peak. -/
theorem no_ghost_mode_of_convex_log_ratio {g : ℝ → ℝ} {l u : ℝ} (hlu : l < u)
    (hconv : ConvexOn ℝ (Icc l u) g) (p q x : ℝ) :
    ¬ IsStrictInteriorMode (fun y => g y - (p + q * y)) l u x := by
  have h := ConvexOn.sub hconv (concaveOn_affine p q (convex_Icc l u))
  exact no_strictInteriorMode_of_convexOn hlu (h.congr (fun y _ => rfl)) x

/-! ## 2. The power-law rate `T(x) = C (1+x)^(-a)` -/

/-- The absolute-shape power law `T(x) = C (1+x)^(-a)` (real exponent). -/
noncomputable def rateT (C a x : ℝ) : ℝ := C * (1 + x) ^ (-a)

theorem rateT_pos {C a x : ℝ} (hC : 0 < C) (hx : -1 < x) : 0 < rateT C a x :=
  mul_pos hC (Real.rpow_pos_of_pos (by linarith) _)

/-- The power law is strictly declining on the whole admissible range. -/
theorem rateT_strictAntiOn {C a : ℝ} (hC : 0 < C) (ha : 0 < a) :
    StrictAntiOn (rateT C a) (Ioi (-1 : ℝ)) := by
  intro x hx y hy hxy
  have hx' : (0:ℝ) < 1 + x := by simp only [mem_Ioi] at hx; linarith
  have hlt : (1 + y) ^ (-a) < (1 + x) ^ (-a) :=
    Real.rpow_lt_rpow_of_neg hx' (by linarith) (by linarith)
  exact mul_lt_mul_of_pos_left hlt hC

/-- Restriction of the decline to a window `[l,u] ⊆ (-1, ∞)`. -/
theorem rateT_strictAntiOn_window {C a l u : ℝ} (hC : 0 < C) (ha : 0 < a) (hl : -1 < l) :
    StrictAntiOn (rateT C a) (Icc l u) :=
  (rateT_strictAntiOn hC ha).mono (fun _ hz => lt_of_lt_of_le hl hz.1)

/-- **The power law has no interior mode** on any window: its maximum sits on the left edge. -/
theorem rateT_no_interiorMode {C a l u : ℝ} (hC : 0 < C) (ha : 0 < a) (hl : -1 < l)
    (hlu : l < u) (x : ℝ) : ¬ IsInteriorMode (rateT C a) l u x :=
  no_interiorMode_of_strictAntiOn hlu (rateT_strictAntiOn_window hC ha hl) x

/-- The left edge is the greatest value on the window. -/
theorem rateT_isGreatest_left {C a l u : ℝ} (hC : 0 < C) (ha : 0 < a) (hl : -1 < l)
    (hlu : l < u) : IsGreatest (rateT C a '' Icc l u) (rateT C a l) := by
  refine ⟨⟨l, ⟨le_rfl, hlu.le⟩, rfl⟩, ?_⟩
  rintro _ ⟨y, hy, rfl⟩
  rcases eq_or_lt_of_le hy.1 with rfl | hlt
  · exact le_rfl
  · exact ((rateT_strictAntiOn_window hC ha hl) ⟨le_rfl, hlu.le⟩ hy hlt).le

/-! ### Rate ratios and exponent identification -/

/-- The peak/end rate ratio across a window depends only on the window ratio and the exponent. -/
theorem rateT_ratio {C a l u : ℝ} (hC : C ≠ 0) (hl : -1 < l) (hu : -1 < u) :
    rateT C a l / rateT C a u = ((1 + u) / (1 + l)) ^ a := by
  have hl' : (0:ℝ) < 1 + l := by linarith
  have hu' : (0:ℝ) < 1 + u := by linarith
  have h1 : (1 + l) ^ (-a) = ((1 + l) ^ a)⁻¹ := Real.rpow_neg hl'.le a
  have h2 : (1 + u) ^ (-a) = ((1 + u) ^ a)⁻¹ := Real.rpow_neg hu'.le a
  have hpl : (0:ℝ) < (1 + l) ^ a := Real.rpow_pos_of_pos hl' a
  have hpu : (0:ℝ) < (1 + u) ^ a := Real.rpow_pos_of_pos hu' a
  rw [rateT, rateT, h1, h2, Real.div_rpow hu'.le hl'.le]
  field_simp

/-- **Exponent identification.** The measured peak/end ratio determines the exponent. -/
theorem exponent_eq_log_ratio {C a l u R : ℝ} (hC : C ≠ 0) (hl : -1 < l) (hu : -1 < u)
    (hlu : l < u) (hR : rateT C a l / rateT C a u = R) :
    a = Real.log R / Real.log ((1 + u) / (1 + l)) := by
  have hl' : (0:ℝ) < 1 + l := by linarith
  have hρ : (1:ℝ) < (1 + u) / (1 + l) := by
    rw [lt_div_iff₀ hl']; linarith
  have hlogρ : 0 < Real.log ((1 + u) / (1 + l)) := Real.log_pos hρ
  have hRe : R = ((1 + u) / (1 + l)) ^ a := by rw [← hR]; exact rateT_ratio hC hl hu
  rw [hRe, Real.log_rpow (by linarith)]
  field_simp

/-- **Dickman-type steepness test.** If the measured peak/end ratio exceeds the window
ratio itself, the exponent must exceed `1`. -/
theorem exponent_gt_one_of_ratio_gt_window {C a l u R : ℝ} (hC : C ≠ 0) (hl : -1 < l)
    (hu : -1 < u) (hlu : l < u) (hR : rateT C a l / rateT C a u = R)
    (hbig : (1 + u) / (1 + l) < R) : 1 < a := by
  have hl' : (0:ℝ) < 1 + l := by linarith
  have hρ : (1:ℝ) < (1 + u) / (1 + l) := by
    rw [lt_div_iff₀ hl']; linarith
  have hlogρ : 0 < Real.log ((1 + u) / (1 + l)) := Real.log_pos hρ
  have hlogR : Real.log ((1 + u) / (1 + l)) < Real.log R :=
    Real.log_lt_log (by linarith) hbig
  rw [exponent_eq_log_ratio hC hl hu hlu hR]
  rw [lt_div_iff₀ hlogρ]
  linarith

/-- Log form of the power-law rate. -/
theorem rateT_log {C a x : ℝ} (hC : 0 < C) (hx : -1 < x) :
    Real.log (rateT C a x) = Real.log C - a * Real.log (1 + x) := by
  have hx' : (0:ℝ) < 1 + x := by linarith
  rw [rateT, Real.log_mul (ne_of_gt hC) (ne_of_gt (Real.rpow_pos_of_pos hx' _)),
    Real.log_rpow hx']
  ring

/-- **Identifiability.** Two power laws agreeing at two distinct points of the window have the
same amplitude and the same exponent: the shape is pinned by two measurements. -/
theorem rateT_param_identifiable {C C' a a' x₁ x₂ : ℝ} (hC : 0 < C) (hC' : 0 < C')
    (h1 : -1 < x₁) (h2 : -1 < x₂) (hne : x₁ ≠ x₂)
    (e1 : rateT C a x₁ = rateT C' a' x₁) (e2 : rateT C a x₂ = rateT C' a' x₂) :
    C = C' ∧ a = a' := by
  have hL1 : Real.log C - a * Real.log (1 + x₁) = Real.log C' - a' * Real.log (1 + x₁) := by
    rw [← rateT_log hC h1, ← rateT_log hC' h1, e1]
  have hL2 : Real.log C - a * Real.log (1 + x₂) = Real.log C' - a' * Real.log (1 + x₂) := by
    rw [← rateT_log hC h2, ← rateT_log hC' h2, e2]
  have hlogne : Real.log (1 + x₁) ≠ Real.log (1 + x₂) := by
    intro h
    apply hne
    have h1' : (0:ℝ) < 1 + x₁ := by linarith
    have h2' : (0:ℝ) < 1 + x₂ := by linarith
    have := Real.log_injOn_pos (mem_Ioi.2 h1') (mem_Ioi.2 h2') h
    linarith
  have haa : a = a' := by
    have hsub : (a' - a) * (Real.log (1 + x₁) - Real.log (1 + x₂)) = 0 := by nlinarith [hL1, hL2]
    rcases mul_eq_zero.1 hsub with h | h
    · linarith
    · exact absurd (by linarith : Real.log (1 + x₁) = Real.log (1 + x₂)) hlogne
  subst haa
  refine ⟨?_, rfl⟩
  have hlogC : Real.log C = Real.log C' := by linarith
  exact Real.log_injOn_pos (mem_Ioi.2 hC) (mem_Ioi.2 hC') hlogC

/-- A steeper exponent means a larger peak/end ratio across a fixed window: the monotone
direction needed to test an exponent that varies with a rate-layer covariate. -/
theorem rateT_ratio_strictMono_in_exponent {l u a a' : ℝ} (hl : -1 < l) (hlu : l < u)
    (haa : a < a') :
    ((1 + u) / (1 + l)) ^ a < ((1 + u) / (1 + l)) ^ a' := by
  have hl' : (0:ℝ) < 1 + l := by linarith
  have hρ : (1:ℝ) < (1 + u) / (1 + l) := by rw [lt_div_iff₀ hl']; linarith
  exact (Real.rpow_lt_rpow_left_iff hρ).mpr haa

/-! ### Genuine nonlinearity of the log rate -/

/-- Strict concavity of `log` at the midpoint. -/
theorem log_midpoint_strict {A B : ℝ} (hA : 0 < A) (hB : 0 < B) (hAB : A ≠ B) :
    (Real.log A + Real.log B) / 2 < Real.log ((A + B) / 2) := by
  have h := strictConcaveOn_log_Ioi.2 (mem_Ioi.2 hA) (mem_Ioi.2 hB) hAB
    (by norm_num : (0:ℝ) < 1/2) (by norm_num : (0:ℝ) < 1/2) (by norm_num)
  simp only [smul_eq_mul] at h
  have : (1:ℝ)/2 * A + 1/2 * B = (A + B) / 2 := by ring
  rw [this] at h
  linarith

/-- The log rate `x ↦ -a log(1+x)` is **strictly convex**: the shape really is nonlinear in `x`. -/
theorem logRate_strictConvexOn {a : ℝ} (ha : 0 < a) :
    StrictConvexOn ℝ (Ioi (-1 : ℝ)) (fun x => -a * Real.log (1 + x)) := by
  refine ⟨convex_Ioi _, ?_⟩
  intro x hx y hy hxy p q hp hq hpq
  simp only [smul_eq_mul, mem_Ioi] at *
  have hA : (0:ℝ) < 1 + x := by linarith
  have hB : (0:ℝ) < 1 + y := by linarith
  have hne : (1 + x) ≠ (1 + y) := by intro h; exact hxy (by linarith)
  have h := strictConcaveOn_log_Ioi.2 (mem_Ioi.2 hA) (mem_Ioi.2 hB) hne hp hq hpq
  simp only [smul_eq_mul] at h
  have harg : p * (1 + x) + q * (1 + y) = 1 + (p * x + q * y) := by
    have : p + q = 1 := hpq
    nlinarith [this]
  rw [harg] at h
  nlinarith [h]

/-- **The power law is not log-linear in `x`.** No affine function of `x` reproduces its
log rate on a nondegenerate window — the LRT rejection of a linear-`x` model is real. -/
theorem rateT_log_not_affine {C a l u : ℝ} (hC : 0 < C) (ha : 0 < a) (hl : -1 < l)
    (hlu : l < u) :
    ¬ ∃ p q : ℝ, ∀ x ∈ Icc l u, Real.log (rateT C a x) = p + q * x := by
  rintro ⟨p, q, hfit⟩
  set m := (l + u) / 2 with hm
  have hlm : l < m := by simp only [hm]; linarith
  have hmu : m < u := by simp only [hm]; linarith
  have hA : (0:ℝ) < 1 + l := by linarith
  have hB : (0:ℝ) < 1 + u := by linarith
  have hLl := hfit l ⟨le_rfl, hlu.le⟩
  have hLu := hfit u ⟨hlu.le, le_rfl⟩
  have hLm := hfit m ⟨hlm.le, hmu.le⟩
  rw [rateT_log hC hl] at hLl
  rw [rateT_log hC (by linarith : (-1:ℝ) < u)] at hLu
  rw [rateT_log hC (by linarith : (-1:ℝ) < m)] at hLm
  have hmid : (1 + m) = ((1 + l) + (1 + u)) / 2 := by simp only [hm]; ring
  have hstrict : (Real.log (1 + l) + Real.log (1 + u)) / 2 < Real.log (1 + m) := by
    rw [hmid]
    exact log_midpoint_strict hA hB (by intro h; exact absurd (by linarith : l = u) (ne_of_lt hlu))
  have haff : p + q * m = ((p + q * l) + (p + q * u)) / 2 := by simp only [hm]; ring
  nlinarith [hstrict, ha]

/-- **Headline decomposition.** On any window inside the admissible range, the power law
is simultaneously (i) genuinely nonlinear in `x` (no affine log fit), and (ii) strictly
declining, hence (iii) mode-free. Significance against a linear model therefore carries
no information about an interior peak. -/
theorem nonlinearity_without_mode {C a l u : ℝ} (hC : 0 < C) (ha : 0 < a) (hl : -1 < l)
    (hlu : l < u) :
    (¬ ∃ p q : ℝ, ∀ x ∈ Icc l u, Real.log (rateT C a x) = p + q * x) ∧
      StrictAntiOn (rateT C a) (Icc l u) ∧
      (∀ x : ℝ, ¬ IsInteriorMode (rateT C a) l u x) :=
  ⟨rateT_log_not_affine hC ha hl hlu, rateT_strictAntiOn_window hC ha hl,
    rateT_no_interiorMode hC ha hl hlu⟩

/-! ## 3. Baseline curvature leakage: the manufactured mid-window peak -/

/-- A Dickman-type mixture baseline `B(x) = C' (1+x)^(-a') exp(-b x)`. -/
noncomputable def baselineB (C' a' b x : ℝ) : ℝ :=
  C' * (1 + x) ^ (-a') * Real.exp (-b * x)

/-- The log-residual of a signal against a curvature-mismatched baseline, up to an additive
constant: `d = a' - a` is the curvature mismatch and `b` the fitted linear tilt. -/
noncomputable def logResidual (d b x : ℝ) : ℝ := d * Real.log (1 + x) + b * x

/-- The log of the signal/baseline ratio *is* a log-residual, up to an additive constant. -/
theorem log_ratio_eq_logResidual {C C' a a' b x : ℝ} (hC : 0 < C) (hC' : 0 < C')
    (hx : -1 < x) :
    Real.log (rateT C a x / baselineB C' a' b x)
      = Real.log (C / C') + logResidual (a' - a) b x := by
  have hx' : (0:ℝ) < 1 + x := by linarith
  have hp : (0:ℝ) < (1 + x) ^ (-a) := Real.rpow_pos_of_pos hx' _
  have hp' : (0:ℝ) < (1 + x) ^ (-a') := Real.rpow_pos_of_pos hx' _
  have hT : (0:ℝ) < rateT C a x := mul_pos hC hp
  have hB : (0:ℝ) < baselineB C' a' b x := by
    exact mul_pos (mul_pos hC' hp') (Real.exp_pos _)
  rw [Real.log_div (ne_of_gt hT) (ne_of_gt hB), rateT, baselineB,
    Real.log_mul (ne_of_gt hC) (ne_of_gt hp), Real.log_mul
      (ne_of_gt (mul_pos hC' hp')) (ne_of_gt (Real.exp_pos _)),
    Real.log_mul (ne_of_gt hC') (ne_of_gt hp'), Real.log_rpow hx', Real.log_rpow hx',
    Real.log_exp, Real.log_div (ne_of_gt hC) (ne_of_gt hC'), logResidual]
  ring

/-- The logarithmic mean of two positive reals. -/
noncomputable def logMean (A B : ℝ) : ℝ := (B - A) / (Real.log B - Real.log A)

/-- The logarithmic mean lies strictly between its arguments. -/
theorem logMean_mem_Ioo {A B : ℝ} (hA : 0 < A) (hAB : A < B) : logMean A B ∈ Ioo A B := by
  have hB : (0:ℝ) < B := lt_trans hA hAB
  have ht : (1:ℝ) < B / A := (one_lt_div hA).2 hAB
  have hlog : Real.log A < Real.log B := Real.log_lt_log hA hAB
  have hd : 0 < Real.log B - Real.log A := by linarith
  have hlogdiv : Real.log B - Real.log A = Real.log (B / A) := by
    rw [Real.log_div (ne_of_gt hB) (ne_of_gt hA)]
  constructor
  · -- A < (B - A) / (log B - log A)
    rw [logMean, lt_div_iff₀ hd, hlogdiv]
    have h := Real.log_lt_sub_one_of_pos (by positivity : (0:ℝ) < B / A) (by
      intro h; rw [h] at ht; exact lt_irrefl _ ht)
    have h2 : A * Real.log (B / A) < A * (B / A - 1) := mul_lt_mul_of_pos_left h hA
    have hBA : A * (B / A - 1) = B - A := by field_simp
    nlinarith [h2, hBA]
  · -- (B - A) / (log B - log A) < B
    rw [logMean, div_lt_iff₀ hd, hlogdiv]
    have hs : (0:ℝ) < A / B := by positivity
    have hs1 : A / B ≠ 1 := by
      intro h
      have : A = B := by field_simp at h; linarith
      exact absurd this (ne_of_lt hAB)
    have h := Real.log_lt_sub_one_of_pos hs hs1
    have hlogs : Real.log (A / B) = -Real.log (B / A) := by
      rw [Real.log_div (ne_of_gt hA) (ne_of_gt hB), Real.log_div (ne_of_gt hB) (ne_of_gt hA)]
      ring
    rw [hlogs] at h
    have hAB' : A / B - 1 = (A - B) / B := by field_simp
    rw [hAB'] at h
    have hmul : B * (-Real.log (B / A)) < B * ((A - B) / B) := mul_lt_mul_of_pos_left h hB
    have hBB : B * ((A - B) / B) = A - B := by field_simp
    nlinarith [hmul, hBB]

/-- The linear tilt that makes the log-residual agree at the two window edges. -/
noncomputable def matchingTilt (d l u : ℝ) : ℝ :=
  -d * (Real.log (1 + u) - Real.log (1 + l)) / (u - l)

theorem matchingTilt_neg {d l u : ℝ} (hd : 0 < d) (hl : -1 < l) (hlu : l < u) :
    matchingTilt d l u < 0 := by
  have h1 : (0:ℝ) < 1 + l := by linarith
  have hlog : Real.log (1 + l) < Real.log (1 + u) := Real.log_lt_log h1 (by linarith)
  have hnum : -d * (Real.log (1 + u) - Real.log (1 + l)) < 0 := by nlinarith
  exact div_neg_of_neg_of_pos hnum (by linarith)

/-- With the matching tilt, the log-residual takes the same value at both window edges:
the fit is calibrated exactly as in the experiment. -/
theorem logResidual_edges_eq {d l u : ℝ} (hlu : l < u) :
    logResidual d (matchingTilt d l u) l = logResidual d (matchingTilt d l u) u := by
  have hne : u - l ≠ 0 := by intro h; exact absurd (by linarith : l = u) (ne_of_lt hlu)
  simp only [logResidual, matchingTilt]
  field_simp
  ring

/-- **Tangent-line maximality.** For `d > 0` and a negative tilt `b`, the log-residual has a
unique global maximum at `x* = -d/b - 1`. -/
theorem logResidual_strict_max {d b : ℝ} (hd : 0 < d) (hb : b < 0) {y : ℝ}
    (hy : -1 < y) (hne : y ≠ -d / b - 1) :
    logResidual d b y < logResidual d b (-d / b - 1) := by
  set m : ℝ := -d / b with hmdef
  have hm : 0 < m := by
    have hme : m = d / (-b) := by rw [hmdef]; field_simp
    rw [hme]; exact div_pos hd (by linarith)
  have hxstar : (1 : ℝ) + (-d / b - 1) = m := by rw [hmdef]; ring
  have hb_eq : b = -d / m := by rw [hmdef]; field_simp
  have hy' : (0:ℝ) < 1 + y := by linarith
  have hratio : (0:ℝ) < (1 + y) / m := div_pos hy' hm
  have hrne : (1 + y) / m ≠ 1 := by
    intro h
    apply hne
    have hym : 1 + y = m := by field_simp at h; linarith
    rw [hmdef] at hym ⊢; linarith
  have htan := Real.log_lt_sub_one_of_pos hratio hrne
  have hlogsplit : Real.log ((1 + y) / m) = Real.log (1 + y) - Real.log m :=
    Real.log_div (ne_of_gt hy') (ne_of_gt hm)
  rw [hlogsplit] at htan
  have hkey : d * (Real.log (1 + y) - Real.log m) < d * ((1 + y) / m - 1) :=
    mul_lt_mul_of_pos_left htan hd
  have hrhs : d * ((1 + y) / m - 1) = -(b * (y - (-d / b - 1))) := by
    rw [hb_eq]; field_simp; ring
  simp only [logResidual]
  rw [hxstar]
  nlinarith [hkey, hrhs]

/-- The location of the manufactured peak: with the matching tilt, the vertex is exactly the
logarithmic mean of the window edges (in the `1+x` coordinate). -/
theorem ghost_peak_eq_logMean {d l u : ℝ} (hd : 0 < d) (hl : -1 < l) (hlu : l < u) :
    -d / matchingTilt d l u - 1 = logMean (1 + l) (1 + u) - 1 := by
  have h1 : (0:ℝ) < 1 + l := by linarith
  have hlog : Real.log (1 + l) < Real.log (1 + u) := Real.log_lt_log h1 (by linarith)
  have hd' : Real.log (1 + u) - Real.log (1 + l) ≠ 0 := by intro h; linarith
  have hul : u - l ≠ 0 := by intro h; exact absurd (by linarith : l = u) (ne_of_lt hlu)
  have hsimp : (1 + u) - (1 + l) = u - l := by ring
  simp only [matchingTilt, logMean, hsimp]
  rw [div_div_eq_mul_div]
  field_simp

/-- **Baseline leakage manufactures a mid-window mode.** If the baseline carries a strictly
larger log-curvature exponent than the signal (`d = a' - a > 0`) and the linear tilt is
calibrated so the log-residual matches at the window edges, then the residual has a genuine
*strict interior* maximum — at the logarithmic mean of the edges — even though the underlying
signal is strictly declining and mode-free. -/
theorem baseline_leakage_creates_ghost_mode {d l u : ℝ} (hd : 0 < d) (hl : -1 < l)
    (hlu : l < u) :
    IsStrictInteriorMode (logResidual d (matchingTilt d l u)) l u
      (logMean (1 + l) (1 + u) - 1) := by
  have h1 : (0:ℝ) < 1 + l := by linarith
  have hmem := logMean_mem_Ioo h1 (by linarith : (1:ℝ) + l < 1 + u)
  have hb := matchingTilt_neg hd hl hlu
  have hloc := ghost_peak_eq_logMean hd hl hlu
  refine ⟨⟨by linarith [hmem.1], by linarith [hmem.2]⟩, fun y hy hne => ?_⟩
  have hy' : -1 < y := lt_of_lt_of_le hl hy.1
  rw [← hloc]
  refine logResidual_strict_max hd hb hy' ?_
  rw [hloc]; exact hne

/-- The signal itself, in the same situation, has no interior mode: the peak is entirely an
artefact of the baseline. -/
theorem ghost_mode_is_not_a_signal_mode {C a d l u : ℝ} (hC : 0 < C) (ha : 0 < a)
    (hd : 0 < d) (hl : -1 < l) (hlu : l < u) :
    IsStrictInteriorMode (logResidual d (matchingTilt d l u)) l u
        (logMean (1 + l) (1 + u) - 1) ∧
      (∀ x : ℝ, ¬ IsInteriorMode (rateT C a) l u x) :=
  ⟨baseline_leakage_creates_ghost_mode hd hl hlu, rateT_no_interiorMode hC ha hl hlu⟩

/-- **Erratum principle.** A strict interior mode in a log-residual is *impossible* when the
log-baseline differs from the log-signal by an affine function of `x`. Hence any observed
mid-window peak forces a non-affine (curvature) mis-specification of the baseline; it can
never be read as a positional mode. -/
theorem strict_interior_mode_forces_nonaffine_log_residual {f : ℝ → ℝ} {l u x : ℝ}
    (hlu : l < u) (hmode : IsStrictInteriorMode f l u x) :
    ¬ ∃ p q : ℝ, ∀ y ∈ Icc l u, f y = p + q * y := by
  rintro ⟨p, q, hfit⟩
  exact no_strictInteriorMode_of_affine hlu p q x
    (hmode.congr (fun y hy => hfit y hy))

/-! ### A numeric instance: the unit window -/

/-- On the unit window `[0,1]` the ghost peak sits at `1/log 2 - 1 ≈ 0.4427`, comfortably in
the interior — a mid-window "mode" produced by pure baseline curvature. -/
theorem ghost_peak_unit_window_gt : (0.4426 : ℝ) < logMean 1 2 - 1 := by
  have h2 : Real.log 2 < 0.6931471808 := Real.log_two_lt_d9
  have h2' : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  have hpos : (0:ℝ) < Real.log 2 := by linarith
  have hLM : logMean 1 2 = 1 / Real.log 2 := by rw [logMean, Real.log_one]; norm_num
  have key : (0.4426:ℝ) + 1 < 1 / Real.log 2 := by
    rw [lt_div_iff₀ hpos]; nlinarith [h2]
  rw [hLM]; linarith

theorem ghost_peak_unit_window_lt : logMean 1 2 - 1 < (0.4428 : ℝ) := by
  have h2' : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  have hpos : (0:ℝ) < Real.log 2 := by linarith
  have hLM : logMean 1 2 = 1 / Real.log 2 := by rw [logMean, Real.log_one]; norm_num
  have key : 1 / Real.log 2 < (0.4428:ℝ) + 1 := by
    rw [div_lt_iff₀ hpos]; nlinarith [h2']
  rw [hLM]; linarith

/-- The unit-window ghost peak really is interior. -/
theorem ghost_peak_unit_window_interior : logMean 1 2 - 1 ∈ Ioo (0:ℝ) 1 := by
  constructor
  · linarith [ghost_peak_unit_window_gt]
  · linarith [ghost_peak_unit_window_lt]

end ShapeTestMonotoneDecline