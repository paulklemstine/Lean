/-
# H0 window geometry: what the shape of `j² − N` can and cannot produce

Formal core of experiment **581** (paper 231), the *sole surviving registered
channel* after the composition carriers were eliminated arithmetically:

> `H0` — window / polynomial geometry of `j² − N` itself, interacting with the
> value sizes `v`.

## The empirical object

Across the sieve window the experiment measures a ratio profile `R = T/M`
(observed hits over model prediction) binned into `64` positions, normalised to
`x ∈ [0,1]`.  The measured profile is *concave with an interior maximum*:

  `R_first = .8371`, `R_peak = 1.2227 @ bin 33`, `R_last = .8935`,
  pooled quadratic-fit vertex `x = 0.5901` (independently `0.5896` in exp 579),
  fitted curvature `c = -0.105 … -0.44` in every resolvable stratum.

The question `H0` asks is whether the *geometry alone* — the fact that the sieve
polynomial is `v(j) = j² − N` on an interval of `j` — forces such a profile.

## The model formalised here

Write `r = √N`, let the window be `j = r + s` with `s` ranging over an interval,
and normalise by the window length `M`, `x = s/M`.  Then

  `v = j² − N = s(s + 2r) = M² · x(x + 2c)`,  `c = r/M > 0`,

so, up to an additive constant `2 log M`, the *log-size profile* of the window is

  `logSize c x = log x + log (x + 2c)`.

The reference ("model") profile against which `R` is read is affine in the
`j`-grid: the chord through the two window endpoints.  The interior deviation is
then exactly `gap (logSize c) a b`.

## What is proved

* `HumpWindowGeometry.strictConcaveOn_logSize` — the log-size profile of
  `j² − N` is **strictly concave** on the whole window.  This is the geometric
  content of `H0`.
* `HumpWindowGeometry.gap_pos_interior` — consequently the chord-referenced
  deviation is **strictly one-signed in the interior and vanishes at both
  window edges**: the geometry does produce a hump, with edge deficits, exactly
  the qualitative shape measured.
* `HumpWindowGeometry.exists_isVertex`, `isVertex_unique`,
  `isMaxOn_gap_of_isVertex` — the hump has a **unique** vertex, characterised by
  `1/ξ + 1/(ξ + 2c) = ` chord slope, and the profile is strictly increasing to
  the left of it and strictly decreasing to the right.
* `HumpWindowGeometry.vertex_c_zero` — in the degenerate limit `c = 0` the
  vertex is the **logarithmic mean** of the endpoints.
* `HumpWindowGeometry.log_lt_iff_two_mul_sub_div` (`log_gt_two_mul_sub_div`) —
  the sharp inequality `2(t-1)/(t+1) < log t`, i.e. logarithmic mean strictly
  below arithmetic mean.
* `HumpWindowGeometry.vertex_lt_midpoint` — **the obstruction.**  For *every*
  admissible `N`, window and window length, the geometric vertex lies strictly
  to the **left** of the window centre.
* `HumpWindowGeometry.normalized_vertex_lt_half`,
  `measured_vertex_not_from_window_geometry` — the measured vertex `0.5901` is
  strictly to the *right* of centre, hence is **not** reproducible by the
  chord-referenced `H0` channel.  `H0` fragments: it explains the sign of the
  curvature and the two edge deficits, but it cannot place the vertex.
* `HumpWindowGeometry.quadratic_gap_vertex_eq_midpoint` — the contrasting
  control: a purely quadratic profile (no logarithm) puts the vertex exactly at
  the centre, so `0.5901` is not that either.
-/
import Mathlib

namespace HumpWindowGeometry

open Set

/-! ## 1. The window value profile of `j² − N` -/

/-- The normalised value `v/M²` at relative window position `x`, where
`c = √N / M` is the window's aspect ratio: `j² − N = M² · x (x + 2c)`. -/
noncomputable def windowValue (c x : ℝ) : ℝ := x * (x + 2 * c)

/-- The log-size profile of the sieve window, normalised (`log v - 2 log M`). -/
noncomputable def logSize (c x : ℝ) : ℝ := Real.log x + Real.log (x + 2 * c)

theorem windowValue_pos {c x : ℝ} (hc : 0 ≤ c) (hx : 0 < x) : 0 < windowValue c x := by
  have : 0 < x + 2 * c := by linarith
  exact mul_pos hx this

/-- On the window the abstract profile really is the logarithm of `j² − N`. -/
theorem logSize_eq_log_windowValue {c x : ℝ} (hc : 0 ≤ c) (hx : 0 < x) :
    logSize c x = Real.log (windowValue c x) := by
  have h2 : 0 < x + 2 * c := by linarith
  rw [logSize, windowValue, Real.log_mul (ne_of_gt hx) (ne_of_gt h2)]

/-! ## 2. Strict concavity: the geometric content of `H0` -/

/-- **The log-size profile of `j² − N` is strictly concave across the window.**
Both factors `s` and `s + 2√N` of the value contribute a concave logarithm. -/
theorem strictConcaveOn_logSize {c : ℝ} (hc : 0 ≤ c) :
    StrictConcaveOn ℝ (Ioi (0 : ℝ)) (logSize c) := by
  have h1 : StrictConcaveOn ℝ (Ioi (0 : ℝ)) Real.log := strictConcaveOn_log_Ioi
  have h2 : StrictConcaveOn ℝ (Ioi (0 : ℝ)) (fun x : ℝ => Real.log (x + 2 * c)) := by
    have ht := strictConcaveOn_log_Ioi.translate_left (2 * c)
    have hsub : Ioi (0 : ℝ) ⊆ (fun z : ℝ => 2 * c + z) ⁻¹' Ioi 0 := by
      intro x hx
      simp only [mem_preimage, mem_Ioi] at *
      linarith
    exact (ht.subset hsub (convex_Ioi 0))
  have hsum := h1.add h2
  have heq : (Real.log + fun x : ℝ => Real.log (x + 2 * c)) = logSize c := by
    funext x; simp [logSize]
  rwa [heq] at hsum

/-! ## 3. Chord reference and the interior deviation -/

/-- The affine reference profile through the two window endpoints. -/
noncomputable def chord (f : ℝ → ℝ) (a b x : ℝ) : ℝ := f a + (x - a) / (b - a) * (f b - f a)

/-- The chord slope over the window. -/
noncomputable def chordSlope (f : ℝ → ℝ) (a b : ℝ) : ℝ := (f b - f a) / (b - a)

/-- The interior deviation of a profile from its affine reference: the "hump". -/
noncomputable def gap (f : ℝ → ℝ) (a b x : ℝ) : ℝ := f x - chord f a b x

@[simp] theorem gap_left (f : ℝ → ℝ) (a b : ℝ) : gap f a b a = 0 := by
  simp [gap, chord]

@[simp] theorem gap_right {f : ℝ → ℝ} {a b : ℝ} (hab : a ≠ b) : gap f a b b = 0 := by
  have h : b - a ≠ 0 := sub_ne_zero.2 (Ne.symm hab)
  rw [gap, chord, div_self h]
  ring

theorem hasDerivAt_chord (f : ℝ → ℝ) {a b : ℝ} (hab : a ≠ b) (x : ℝ) :
    HasDerivAt (chord f a b) (chordSlope f a b) x := by
  have h : b - a ≠ 0 := sub_ne_zero.2 (Ne.symm hab)
  have hbase : HasDerivAt (fun x : ℝ => f a + (x - a) * ((f b - f a) / (b - a)))
      (1 * ((f b - f a) / (b - a))) x := by
    exact (((hasDerivAt_id x).sub_const a).mul_const _).const_add _
  have heq : (fun x : ℝ => f a + (x - a) * ((f b - f a) / (b - a))) = chord f a b := by
    funext y; rw [chord]; ring
  rw [heq] at hbase
  simpa [chordSlope] using hbase

/-- **The hump exists.**  A strictly concave profile exceeds its endpoint chord
strictly at every interior window position, and matches it exactly at both
edges.  With `strictConcaveOn_logSize` this is the geometric prediction of `H0`:
one-signed interior deviation, zero deviation at the two edges. -/
theorem gap_pos_of_strictConcaveOn {f : ℝ → ℝ} {s : Set ℝ} (hf : StrictConcaveOn ℝ s f)
    {a b x : ℝ} (ha : a ∈ s) (hb : b ∈ s) (hax : a < x) (hxb : x < b) :
    0 < gap f a b x := by
  have hab : a < b := lt_trans hax hxb
  have hba : (0 : ℝ) < b - a := by linarith
  set θ : ℝ := (b - x) / (b - a) with hθ
  have hθ0 : 0 < θ := div_pos (by linarith) hba
  have hθ1 : 0 < 1 - θ := by
    have : θ < 1 := by
      rw [hθ, div_lt_one hba]; linarith
    linarith
  have hsum : θ + (1 - θ) = 1 := by ring
  have hcomb : θ * a + (1 - θ) * b = x := by
    rw [hθ]; field_simp; ring
  have hlt := hf.2 ha hb (by linarith) hθ0 hθ1 hsum
  rw [smul_eq_mul, smul_eq_mul, smul_eq_mul, smul_eq_mul, hcomb] at hlt
  have hchord : chord f a b x = θ * f a + (1 - θ) * f b := by
    rw [chord, hθ]; field_simp; ring
  rw [gap, hchord]
  linarith

/-- Non-strict companion: a concave profile is never below its endpoint chord. -/
theorem gap_nonneg_of_concaveOn {f : ℝ → ℝ} {s : Set ℝ} (hf : ConcaveOn ℝ s f)
    {a b x : ℝ} (ha : a ∈ s) (hb : b ∈ s) (hab : a < b) (hax : a ≤ x) (hxb : x ≤ b) :
    0 ≤ gap f a b x := by
  have hba : (0 : ℝ) < b - a := by linarith
  set θ : ℝ := (b - x) / (b - a) with hθ
  have hθ0 : 0 ≤ θ := div_nonneg (by linarith) (le_of_lt hba)
  have hθ1 : 0 ≤ 1 - θ := by
    have : θ ≤ 1 := by rw [hθ, div_le_one hba]; linarith
    linarith
  have hsum : θ + (1 - θ) = 1 := by ring
  have hcomb : θ * a + (1 - θ) * b = x := by rw [hθ]; field_simp; ring
  have hle := hf.2 ha hb hθ0 hθ1 hsum
  rw [smul_eq_mul, smul_eq_mul, smul_eq_mul, smul_eq_mul, hcomb] at hle
  have hchord : chord f a b x = θ * f a + (1 - θ) * f b := by
    rw [chord, hθ]; field_simp; ring
  rw [gap, hchord]
  linarith

/-- Specialisation to the sieve window. -/
theorem gap_pos_interior {c a b x : ℝ} (hc : 0 ≤ c) (ha : 0 < a) (hax : a < x) (hxb : x < b) :
    0 < gap (logSize c) a b x :=
  gap_pos_of_strictConcaveOn (strictConcaveOn_logSize hc) (mem_Ioi.2 ha)
    (mem_Ioi.2 (by linarith)) hax hxb

/-! ## 4. The vertex of the hump -/

/-- Derivative of the log-size profile: `1/x + 1/(x + 2c)`. -/
noncomputable def logSizeDeriv (c x : ℝ) : ℝ := 1 / x + 1 / (x + 2 * c)

theorem hasDerivAt_logSize {c x : ℝ} (hc : 0 ≤ c) (hx : 0 < x) :
    HasDerivAt (logSize c) (logSizeDeriv c x) x := by
  have h2 : 0 < x + 2 * c := by linarith
  have hL : HasDerivAt Real.log x⁻¹ x := Real.hasDerivAt_log (ne_of_gt hx)
  have hR : HasDerivAt (fun y : ℝ => Real.log (y + 2 * c)) (x + 2 * c)⁻¹ x := by
    have hinner : HasDerivAt (fun y : ℝ => y + 2 * c) 1 x := (hasDerivAt_id x).add_const _
    simpa using (Real.hasDerivAt_log (ne_of_gt h2)).comp x hinner
  simpa [logSize, logSizeDeriv, one_div] using hL.add hR

theorem logSizeDeriv_strictAntiOn {c : ℝ} (hc : 0 ≤ c) :
    StrictAntiOn (logSizeDeriv c) (Ioi (0 : ℝ)) := by
  intro x hx y hy hxy
  simp only [mem_Ioi] at hx hy
  have h1 : 1 / y < 1 / x := by
    apply one_div_lt_one_div_of_lt hx hxy
  have h2 : 1 / (y + 2 * c) < 1 / (x + 2 * c) := by
    apply one_div_lt_one_div_of_lt (by linarith) (by linarith)
  simp only [logSizeDeriv]
  linarith

theorem continuousOn_logSize {c : ℝ} (hc : 0 ≤ c) :
    ContinuousOn (logSize c) (Ioi (0 : ℝ)) := fun _ hx =>
  ((hasDerivAt_logSize hc (mem_Ioi.1 hx)).continuousAt).continuousWithinAt

/-- `ξ` is *the vertex* of the window hump on `[a,b]`: an interior point where
the log-size slope equals the chord slope. -/
def IsVertex (c a b ξ : ℝ) : Prop :=
  ξ ∈ Ioo a b ∧ logSizeDeriv c ξ = chordSlope (logSize c) a b

/-- **The vertex exists** (mean value theorem on the window). -/
theorem exists_isVertex {c a b : ℝ} (hc : 0 ≤ c) (ha : 0 < a) (hab : a < b) :
    ∃ ξ, IsVertex c a b ξ := by
  have hcont : ContinuousOn (logSize c) (Icc a b) :=
    (continuousOn_logSize hc).mono (fun x hx => mem_Ioi.2 (lt_of_lt_of_le ha hx.1))
  have hder : ∀ x ∈ Ioo a b, HasDerivAt (logSize c) (logSizeDeriv c x) x := fun x hx =>
    hasDerivAt_logSize hc (lt_trans ha hx.1)
  obtain ⟨ξ, hξ, hslope⟩ := exists_hasDerivAt_eq_slope (logSize c) (logSizeDeriv c) hab hcont hder
  exact ⟨ξ, hξ, hslope⟩

/-- **The vertex is unique.** -/
theorem isVertex_unique {c a b ξ η : ℝ} (hc : 0 ≤ c) (ha : 0 < a)
    (hξ : IsVertex c a b ξ) (hη : IsVertex c a b η) : ξ = η := by
  have hξ0 : (0 : ℝ) < ξ := lt_trans ha hξ.1.1
  have hη0 : (0 : ℝ) < η := lt_trans ha hη.1.1
  have heq : logSizeDeriv c ξ = logSizeDeriv c η := by rw [hξ.2, hη.2]
  by_contra hne
  rcases lt_or_gt_of_ne hne with h | h
  · exact absurd heq (ne_of_gt (logSizeDeriv_strictAntiOn hc (mem_Ioi.2 hξ0) (mem_Ioi.2 hη0) h))
  · exact absurd heq.symm
      (ne_of_gt (logSizeDeriv_strictAntiOn hc (mem_Ioi.2 hη0) (mem_Ioi.2 hξ0) h))

theorem hasDerivAt_gap {c a b x : ℝ} (hc : 0 ≤ c) (hab : a ≠ b) (hx : 0 < x) :
    HasDerivAt (gap (logSize c) a b) (logSizeDeriv c x - chordSlope (logSize c) a b) x :=
  (hasDerivAt_logSize hc hx).sub (hasDerivAt_chord (logSize c) hab x)

/-- To the left of the vertex the hump strictly rises. -/
theorem strictMonoOn_gap_left {c a b ξ : ℝ} (hc : 0 ≤ c) (ha : 0 < a) (hξ : IsVertex c a b ξ) :
    StrictMonoOn (gap (logSize c) a b) (Icc a ξ) := by
  have hab : a < b := lt_trans hξ.1.1 hξ.1.2
  have hξ0 : (0 : ℝ) < ξ := lt_trans ha hξ.1.1
  apply strictMonoOn_of_deriv_pos (convex_Icc a ξ)
  · intro x hx
    exact ((hasDerivAt_gap hc (ne_of_lt hab) (lt_of_lt_of_le ha hx.1)).continuousAt).continuousWithinAt
  · intro x hx
    rw [interior_Icc] at hx
    have hx0 : (0 : ℝ) < x := lt_trans ha hx.1
    rw [(hasDerivAt_gap hc (ne_of_lt hab) hx0).deriv, ← hξ.2, sub_pos]
    exact logSizeDeriv_strictAntiOn hc (mem_Ioi.2 hx0) (mem_Ioi.2 hξ0) hx.2

/-- To the right of the vertex the hump strictly falls. -/
theorem strictAntiOn_gap_right {c a b ξ : ℝ} (hc : 0 ≤ c) (ha : 0 < a) (hξ : IsVertex c a b ξ) :
    StrictAntiOn (gap (logSize c) a b) (Icc ξ b) := by
  have hab : a < b := lt_trans hξ.1.1 hξ.1.2
  have hξ0 : (0 : ℝ) < ξ := lt_trans ha hξ.1.1
  apply strictAntiOn_of_deriv_neg (convex_Icc ξ b)
  · intro x hx
    exact ((hasDerivAt_gap hc (ne_of_lt hab)
      (lt_of_lt_of_le hξ0 hx.1)).continuousAt).continuousWithinAt
  · intro x hx
    rw [interior_Icc] at hx
    have hx0 : (0 : ℝ) < x := lt_trans hξ0 hx.1
    rw [(hasDerivAt_gap hc (ne_of_lt hab) hx0).deriv, ← hξ.2, sub_neg]
    exact logSizeDeriv_strictAntiOn hc (mem_Ioi.2 hξ0) (mem_Ioi.2 hx0) hx.1

/-- **The vertex is the peak.**  The chord-referenced deviation attains its
maximum over the window exactly at `ξ`. -/
theorem isMaxOn_gap_of_isVertex {c a b ξ : ℝ} (hc : 0 ≤ c) (ha : 0 < a) (hξ : IsVertex c a b ξ) :
    IsMaxOn (gap (logSize c) a b) (Icc a b) ξ := by
  intro x hx
  simp only [mem_Icc] at hx
  show gap (logSize c) a b x ≤ gap (logSize c) a b ξ
  rcases le_total x ξ with h | h
  · rcases eq_or_lt_of_le h with rfl | hlt
    · exact le_refl _
    · exact le_of_lt (strictMonoOn_gap_left hc ha hξ ⟨hx.1, h⟩
        ⟨le_of_lt hξ.1.1, le_refl _⟩ hlt)
  · rcases eq_or_lt_of_le h with rfl | hlt
    · exact le_refl _
    · exact le_of_lt (strictAntiOn_gap_right hc ha hξ ⟨le_refl _, le_of_lt hξ.1.2⟩
        ⟨h, hx.2⟩ hlt)

/-! ## 5. The sharp mean inequality -/

/-- **`2(t-1)/(t+1) < log t` for `t > 1`**: the logarithmic mean of two distinct
positive reals is strictly below their arithmetic mean.  This is the analytic
engine of the vertex obstruction. -/
theorem log_gt_two_mul_sub_div {t : ℝ} (ht : 1 < t) : 2 * (t - 1) / (t + 1) < Real.log t := by
  set f : ℝ → ℝ := fun t => Real.log t - 2 * (t - 1) / (t + 1) with hf
  have hderiv : ∀ x : ℝ, 0 < x → HasDerivAt f (1 / x - 4 / (x + 1) ^ 2) x := by
    intro x hx
    have hx1 : x + 1 ≠ 0 := by positivity
    have hnum : HasDerivAt (fun y : ℝ => 2 * (y - 1)) 2 x := by
      simpa using (((hasDerivAt_id x).sub_const 1).const_mul (2 : ℝ))
    have hden : HasDerivAt (fun y : ℝ => y + 1) 1 x := (hasDerivAt_id x).add_const 1
    have hdiv : HasDerivAt (fun y : ℝ => 2 * (y - 1) / (y + 1))
        ((2 * (x + 1) - 2 * (x - 1) * 1) / (x + 1) ^ 2) x := hnum.div hden hx1
    have hlog : HasDerivAt Real.log x⁻¹ x := Real.hasDerivAt_log (ne_of_gt hx)
    have := hlog.sub hdiv
    convert this using 1
    field_simp
    ring
  have hmono : StrictMonoOn f (Ici (1 : ℝ)) := by
    apply strictMonoOn_of_deriv_pos (convex_Ici 1)
    · intro x hx
      have hx0 : (0 : ℝ) < x := lt_of_lt_of_le zero_lt_one hx
      exact ((hderiv x hx0).continuousAt).continuousWithinAt
    · intro x hx
      rw [interior_Ici] at hx
      have hx0 : (0 : ℝ) < x := lt_trans zero_lt_one hx
      rw [(hderiv x hx0).deriv]
      have hkey : 1 / x - 4 / (x + 1) ^ 2 = (x - 1) ^ 2 / (x * (x + 1) ^ 2) := by
        field_simp; ring
      rw [hkey]
      have h1 : (0 : ℝ) < (x - 1) ^ 2 := by
        have : x - 1 ≠ 0 := by intro h; rw [sub_eq_zero] at h; exact absurd h (ne_of_gt hx)
        positivity
      positivity
  have h0 : f 1 = 0 := by simp [hf]
  have := hmono Set.self_mem_Ici (mem_Ici.2 (le_of_lt ht)) ht
  rw [h0] at this
  simp only [hf] at this
  linarith

/-- Endpoint form: for `0 < p < q`, the secant slope of `log` strictly exceeds
the reciprocal of the arithmetic mean. -/
theorem two_div_add_lt_log_slope {p q : ℝ} (hp : 0 < p) (hpq : p < q) :
    2 / (p + q) < (Real.log q - Real.log p) / (q - p) := by
  have hq : 0 < q := lt_trans hp hpq
  have ht : 1 < q / p := (one_lt_div hp).2 hpq
  have hlog : Real.log (q / p) = Real.log q - Real.log p := Real.log_div (ne_of_gt hq) (ne_of_gt hp)
  have hkey := log_gt_two_mul_sub_div ht
  rw [hlog] at hkey
  have hsimp : 2 * (q / p - 1) / (q / p + 1) = 2 * (q - p) / (q + p) := by
    field_simp
  rw [hsimp] at hkey
  rw [div_lt_div_iff₀ (by linarith) (by linarith)]
  have h2 : 2 * (q - p) / (q + p) * (q + p) = 2 * (q - p) := by
    field_simp
  nlinarith [hkey, sub_pos.2 hpq]

/-! ## 6. The obstruction: the geometric vertex is left of centre -/

/-- **Main obstruction theorem.**  For every aspect ratio `c ≥ 0` and every
window `[a,b]` with `0 < a < b`, the vertex of the chord-referenced hump of
`j² − N` lies strictly to the *left* of the window centre. -/
theorem vertex_lt_midpoint {c a b ξ : ℝ} (hc : 0 ≤ c) (ha : 0 < a) (hab : a < b)
    (hξ : IsVertex c a b ξ) : ξ < (a + b) / 2 := by
  set m : ℝ := (a + b) / 2 with hm
  have hm0 : 0 < m := by rw [hm]; linarith
  have hξ0 : (0 : ℝ) < ξ := lt_trans ha hξ.1.1
  -- slope of the chord splits into the two factor slopes
  have hslope : chordSlope (logSize c) a b =
      (Real.log b - Real.log a) / (b - a) +
      (Real.log (b + 2 * c) - Real.log (a + 2 * c)) / ((b + 2 * c) - (a + 2 * c)) := by
    rw [chordSlope, logSize, logSize]
    have h : (b + 2 * c) - (a + 2 * c) = b - a := by ring
    rw [h]
    ring
  have h1 : 2 / (a + b) < (Real.log b - Real.log a) / (b - a) :=
    two_div_add_lt_log_slope ha hab
  have h2 : 2 / ((a + 2 * c) + (b + 2 * c)) <
      (Real.log (b + 2 * c) - Real.log (a + 2 * c)) / ((b + 2 * c) - (a + 2 * c)) :=
    two_div_add_lt_log_slope (by linarith) (by linarith)
  have hd1 : 1 / m = 2 / (a + b) := by rw [hm]; field_simp
  have hd2 : 1 / (m + 2 * c) = 2 / ((a + 2 * c) + (b + 2 * c)) := by
    rw [hm]
    rw [div_eq_div_iff (by linarith) (by linarith)]
    ring
  have hlt : logSizeDeriv c m < chordSlope (logSize c) a b := by
    rw [logSizeDeriv, hslope, hd1, hd2]
    linarith
  rw [← hξ.2] at hlt
  by_contra hcon
  push_neg at hcon
  rcases eq_or_lt_of_le hcon with heq | hlt2
  · rw [heq] at hlt; exact lt_irrefl _ hlt
  · exact absurd (logSizeDeriv_strictAntiOn hc (mem_Ioi.2 hm0) (mem_Ioi.2 hξ0) hlt2)
      (not_lt.2 (le_of_lt hlt))

/-- Normalised statement: the geometric vertex sits at relative window position
strictly below `1/2`. -/
theorem normalized_vertex_lt_half {c a b ξ : ℝ} (hc : 0 ≤ c) (ha : 0 < a) (hab : a < b)
    (hξ : IsVertex c a b ξ) : (ξ - a) / (b - a) < 1 / 2 := by
  have hba : (0 : ℝ) < b - a := by linarith
  rw [div_lt_div_iff₀ hba (by norm_num)]
  have := vertex_lt_midpoint hc ha hab hξ
  linarith

/-- **`H0` fragments.**  The measured pooled vertex `0.5901` (independently
`0.5896` in exp 579) lies to the *right* of the window centre, so no window
geometry of `j² − N`, at any aspect ratio and on any window, can produce it
against an affine reference. -/
theorem measured_vertex_not_from_window_geometry {c a b ξ : ℝ} (hc : 0 ≤ c) (ha : 0 < a)
    (hab : a < b) (hξ : IsVertex c a b ξ) : (ξ - a) / (b - a) ≠ 0.5901 := by
  intro h
  have := normalized_vertex_lt_half hc ha hab hξ
  rw [h] at this
  norm_num at this

/-! ## 7. Two calibrating special cases -/

/-- In the degenerate aspect ratio `c = 0` (window as long as `√N`) the vertex
is exactly the **logarithmic mean** of the window endpoints. -/
theorem vertex_c_zero {a b : ℝ} (ha : 0 < a) (hab : a < b) :
    IsVertex 0 a b ((b - a) / (Real.log b - Real.log a)) := by
  have hq : 0 < b := lt_trans ha hab
  have hlogpos : 0 < Real.log b - Real.log a := by
    have := Real.log_lt_log ha hab
    linarith
  obtain ⟨ξ, hξ⟩ := exists_isVertex (le_refl (0 : ℝ)) ha hab
  have hξ0 : (0 : ℝ) < ξ := lt_trans ha hξ.1.1
  have hslope : chordSlope (logSize 0) a b = 2 * (Real.log b - Real.log a) / (b - a) := by
    rw [chordSlope, logSize, logSize]
    have h1 : a + 2 * (0 : ℝ) = a := by ring
    have h2 : b + 2 * (0 : ℝ) = b := by ring
    rw [h1, h2]
    ring
  have hd : logSizeDeriv 0 ξ = 2 / ξ := by
    rw [logSizeDeriv]
    have h : ξ + 2 * (0 : ℝ) = ξ := by ring
    rw [h]
    ring
  have heq : (2 : ℝ) / ξ = 2 * (Real.log b - Real.log a) / (b - a) := by
    rw [← hd, hξ.2, hslope]
  have hba : (0 : ℝ) < b - a := by linarith
  have hcross : (2 : ℝ) * (b - a) = 2 * (Real.log b - Real.log a) * ξ :=
    (div_eq_div_iff (ne_of_gt hξ0) (ne_of_gt hba)).1 heq
  have hL : ξ = (b - a) / (Real.log b - Real.log a) := by
    rw [eq_div_iff (ne_of_gt hlogpos)]
    linear_combination -hcross / 2
  rw [← hL]
  exact hξ

/-- Corollary of the vertex analysis: the **logarithmic mean lies strictly
between** the endpoints (and, by `vertex_lt_midpoint`, strictly below their
arithmetic mean). -/
theorem logMean_mem_Ioo {a b : ℝ} (ha : 0 < a) (hab : a < b) :
    (b - a) / (Real.log b - Real.log a) ∈ Ioo a b :=
  (vertex_c_zero ha hab).1

theorem logMean_lt_midpoint {a b : ℝ} (ha : 0 < a) (hab : a < b) :
    (b - a) / (Real.log b - Real.log a) < (a + b) / 2 :=
  vertex_lt_midpoint (le_refl (0 : ℝ)) ha hab (vertex_c_zero ha hab)

/-- **Quantitative collapse to the left edge.**  In the degenerate aspect ratio
the normalised vertex is at most `1 / log (b/a)`: as the window widens (the
sieve regime `a = 1/M`, `b = 1`, so `log (b/a) = log M`) the geometric vertex
collapses onto the *left* edge.  It cannot merely fail to reach `0.5901`; it
runs the other way. -/
theorem normalized_logMean_le_inv_log {a b : ℝ} (ha : 0 < a) (hab : a < b) :
    ((b - a) / (Real.log b - Real.log a) - a) / (b - a)
      ≤ 1 / (Real.log b - Real.log a) := by
  have hq : 0 < b := lt_trans ha hab
  have hlogpos : 0 < Real.log b - Real.log a := by
    have := Real.log_lt_log ha hab
    linarith
  have hba : (0 : ℝ) < b - a := by linarith
  have hsplit : ((b - a) / (Real.log b - Real.log a) - a) / (b - a)
      = 1 / (Real.log b - Real.log a) - a / (b - a) := by
    field_simp
  rw [hsplit]
  have : 0 < a / (b - a) := div_pos ha hba
  linarith

/-- **Control profile.**  If the window profile were a pure quadratic (no
logarithm) the chord-referenced deviation would be `-(x-a)(x-b)`, whose
extremum sits exactly at the window centre.  So a measured vertex `≠ 1/2` is not
a quadratic-profile artefact either. -/
theorem quadratic_gap_vertex_eq_midpoint {a b : ℝ} (hab : a < b) (x : ℝ) :
    gap (fun y : ℝ => -y ^ 2) a b x ≤ gap (fun y : ℝ => -y ^ 2) a b ((a + b) / 2) := by
  have hba : b - a ≠ 0 := sub_ne_zero.2 (Ne.symm (ne_of_lt hab))
  have hexp : ∀ y : ℝ, gap (fun z : ℝ => -z ^ 2) a b y = -(y - a) * (y - b) := by
    intro y
    rw [gap, chord]
    field_simp
    ring
  rw [hexp, hexp]
  nlinarith [sq_nonneg (x - (a + b) / 2)]

end HumpWindowGeometry