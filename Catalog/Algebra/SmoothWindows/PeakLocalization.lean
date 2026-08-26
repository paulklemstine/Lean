import Algebra.SmoothWindows.ScaleSpace

/-!
# Smooth windows VI: peak localization and a Rayleigh criterion for Gaussian windows

Cycle 3 of the programme.  Files I–V built the Gabor/Heisenberg algebra of the Gaussian window,
proved the modulation/translation (Weyl) identity in both its operator and its discrete forms,
quantified the Dirichlet sidelobes of the rectangular window, and showed that the Gaussian window
produces a continuous, strictly monotone scale space.  The remaining question is the one that
actually motivates smooth windows in a peak finder: **where are the peaks, and when are two nearby
ordinates resolved as two peaks rather than one?**

## Main results

* `posProfile` — the *position profile* `a ↦ Σ_t g_s(t - a)/(1/4 + t²)` obtained by sliding the
  Gaussian window along the ordinate axis; `gaborTransform_pairedData_re` identifies it with the
  real part of the discrete Gabor transform of `Algebra.SmoothWindows.HarmonicGaborWindow` at
  frequency `0`, so it is not a new object but a slice of the one already built.
* `gaussWin_half_eq`, `gaussWin_eq_pow_four` — the two *scale-doubling identities* of the Gaussian
  window, `g_s(d/2) = g_{2s}(d)` and `g_s(d) = g_{2s}(d)⁴`.  They are the reason the analysis below
  is a polynomial inequality in the single variable `u = g_{2s}(t₁ - t₂)`: the Gaussian is the only
  window for which the value at the midpoint and the value at the far ordinate are powers of one
  common quantity.
* `posProfile_singleton_lt` — for a single ordinate the profile attains a **strict global maximum
  exactly at that ordinate**.  The Gaussian window localizes a peak with no bias.
* `posProfile_two_resolved` — **a Rayleigh criterion.**  If
  `3 · g_{2s}(t₁ - t₂) · (1/4 + t₁²) ≤ 1/4 + t₂²` then the profile of the two-ordinate family
  `{t₁, t₂}` is strictly larger at `t₁` than at the midpoint: the two ordinates are *resolved*, the
  midpoint is a valley and not a spurious peak.
* `posProfile_two_resolved_eventually` — the criterion is never vacuous: for **any** two distinct
  ordinates it holds for all sufficiently narrow windows.  Narrowing the Gaussian always eventually
  separates two distinct ordinates, in sharp contrast to the rectangular window whose sidelobes
  (`Algebra.SmoothWindows.Sidelobes`) have amplitude `1/π` of the main lobe at *every* width.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).** Conjecture: for a Gaussian window the "two peaks or one" question
  has a *closed-form* threshold, polynomial in a single scale-doubling variable, and the threshold
  degenerates only in the equal-ordinate case.  Bold form: the Gaussian is the unique window for
  which the resolution criterion is a cubic inequality in one variable.
* **Experiment (Experimenter).** Set `u = g_{2s}(t₁ - t₂)`, `wᵢ = 1/(1/4 + tᵢ²)`.  The two scale
  doubling identities give exactly
  `P(t₁) = w₁ + u⁴ w₂` and `P((t₁+t₂)/2) = u (w₁ + w₂)`, hence
  `P(t₁) - P(m) = (1 - u)·(w₁ - u(1 + u + u²) w₂)`.
  Numerical probe (`ComputationalEvidence.md`): `t₁ = 14.13`, `t₂ = 21.02`, `s = 4` gives
  `u = g_8(-6.89) = exp(-π·47.5/64) ≈ 0.0974`, `w₁ ≈ 0.00500`, `w₂ ≈ 0.00226`; the criterion
  `3u w₂ ≤ w₁` reads `0.00066 ≤ 0.00500` — comfortably resolved, as observed.
* **Analysis (Analyst).** The factorisation `(1-u)(w₁ - u(1+u+u²)w₂)` is the structural content:
  the *first* factor vanishes exactly when the two ordinates coincide (`u = 1`), the *second* is
  the genuine resolution threshold.  Failure modes are therefore cleanly separated — "the same
  ordinate" versus "too wide a window" — which a purely numerical criterion cannot distinguish.
  The crude bound `u(1 + u + u²) < 3u` loses at most a factor `3` and is what makes the criterion a
  usable hypothesis; the sharp criterion `w₁ > u(1+u+u²) w₂` is `posProfile_two_resolved_sharp`.
* **Critique (Critic).** Two guards were added after review.  (i) The hypothesis `t₁ ≠ t₂` is
  genuinely needed: for `t₁ = t₂` the midpoint *is* `t₁` and the conclusion is a strict inequality
  between equal numbers.  (ii) `0 < s` is needed since `g_0 ≡ 1` by the junk value of division by
  zero, which would make every window infinitely wide.  Both appear explicitly in the statements.
  The eventual form is stated on `𝓝[>] 0` rather than `𝓝 0` for the same reason.
-/

namespace SmoothWindows

open Complex Real Filter Topology ReciprocalZeroHarmonics

/-! ## Scale-doubling identities for the Gaussian window -/

/-- **Half-argument identity**: halving the offset is the same as doubling the width. -/
theorem gaussWin_half_eq (s d : ℝ) : gaussWin s (d / 2) = gaussWin (2 * s) d := by
  unfold gaussWin
  congr 1
  ring

/-- **Fourth-power identity**: the value of the width-`s` window is the fourth power of the value
of the width-`2s` window at the same offset. -/
theorem gaussWin_eq_pow_four (s d : ℝ) : gaussWin s d = gaussWin (2 * s) d ^ 4 := by
  unfold gaussWin
  rw [← Real.exp_nat_mul]
  congr 1
  push_cast
  ring

/-! ## The position profile -/

/-- The **paired spectral data** of a family of critical-line ordinates: the pairs
`(t, 1/(1/4 + t²))`.  This is the positive-amplitude half of `zeroData (pairedOrdinates S)`. -/
noncomputable def pairedData (S : Multiset ℝ) : Multiset (ℝ × ℂ) :=
  S.map fun t => (t, ((1 / (1 / 4 + t ^ 2) : ℝ) : ℂ))

/-- The **position profile** of a family of ordinates: the Gaussian window is slid to position `a`
and the harmonic amplitudes are accumulated. -/
noncomputable def posProfile (S : Multiset ℝ) (s a : ℝ) : ℝ :=
  (S.map fun t => gaussWin s (t - a) / (1 / 4 + t ^ 2)).sum

@[simp] theorem posProfile_zero (s a : ℝ) : posProfile 0 s a = 0 := by simp [posProfile]

@[simp] theorem posProfile_cons (t : ℝ) (S : Multiset ℝ) (s a : ℝ) :
    posProfile (t ::ₘ S) s a = gaussWin s (t - a) / (1 / 4 + t ^ 2) + posProfile S s a := by
  simp [posProfile]

/-- At zero position the profile is the Gaussian scale space of
`Algebra.SmoothWindows.ScaleSpace`. -/
theorem posProfile_zero_pos (S : Multiset ℝ) (s : ℝ) :
    posProfile S s 0 = gaussSpectral S s := by
  simp [posProfile, gaussSpectral]

/-- **The profile is a slice of the discrete Gabor transform**: it is the real part of the
Gabor transform of the paired data at frequency `0` and position `a`. -/
theorem gaborTransform_pairedData_re (S : Multiset ℝ) (s a : ℝ) :
    (gaborTransform (pairedData S) (gaussC s) a 0).re = posProfile S s a := by
  unfold gaborTransform pairedData posProfile
  rw [Multiset.map_map]
  induction S using Multiset.induction with
  | empty => simp
  | cons t S ih =>
      simp only [Multiset.map_cons, Multiset.sum_cons, Complex.add_re, ih]
      congr 1
      have hterm : ((fun p : ℝ × ℂ => chi (-(0 * p.1)) * gaussC s (p.1 - a) * p.2) ∘
            fun t : ℝ => (t, ((1 / (1 / 4 + t ^ 2) : ℝ) : ℂ))) t
          = ((gaussWin s (t - a) / (1 / 4 + t ^ 2) : ℝ) : ℂ) := by
        show chi (-(0 * t)) * gaussC s (t - a) * ((1 / (1 / 4 + t ^ 2) : ℝ) : ℂ) = _
        simp only [zero_mul, neg_zero, chi_zero, one_mul, gaussC]
        push_cast
        ring
      rw [hterm, Complex.ofReal_re]

/-! ## Exact localization for a single ordinate -/

/-- **Unbiased localization.**  For a single ordinate the position profile has a strict global
maximum exactly at that ordinate: a Gaussian window never displaces a peak. -/
theorem posProfile_singleton_lt {s : ℝ} (hs : s ≠ 0) (t a : ℝ) (ha : a ≠ t) :
    posProfile {t} s a < posProfile {t} s t := by
  have hd : (0:ℝ) < 1 / 4 + t ^ 2 := by positivity
  have h : gaussWin s (t - a) < 1 := gaussWin_lt_one hs (sub_ne_zero.mpr (Ne.symm ha))
  simp only [posProfile, Multiset.map_singleton, Multiset.sum_singleton, sub_self, gaussWin_zero]
  gcongr

/-! ## The two-ordinate Rayleigh criterion -/

/-- The value of the profile of `{t₁, t₂}` at `t₁`, in terms of `u = g_{2s}(t₁ - t₂)`. -/
theorem posProfile_pair_at (s t₁ t₂ : ℝ) :
    posProfile {t₁, t₂} s t₁
      = 1 / (1 / 4 + t₁ ^ 2)
        + gaussWin (2 * s) (t₁ - t₂) ^ 4 * (1 / (1 / 4 + t₂ ^ 2)) := by
  have h : gaussWin s (t₂ - t₁) = gaussWin (2 * s) (t₁ - t₂) ^ 4 := by
    rw [gaussWin_eq_pow_four s (t₂ - t₁), show t₂ - t₁ = -(t₁ - t₂) by ring, gaussWin_even]
  simp only [posProfile, Multiset.insert_eq_cons, Multiset.map_cons, Multiset.sum_cons,
    Multiset.map_singleton, Multiset.sum_singleton, sub_self, gaussWin_zero, h]
  ring

/-- The value of the profile of `{t₁, t₂}` at the midpoint, in terms of `u = g_{2s}(t₁ - t₂)`. -/
theorem posProfile_pair_mid (s t₁ t₂ : ℝ) :
    posProfile {t₁, t₂} s ((t₁ + t₂) / 2)
      = gaussWin (2 * s) (t₁ - t₂) * (1 / (1 / 4 + t₁ ^ 2) + 1 / (1 / 4 + t₂ ^ 2)) := by
  have h1 : gaussWin s (t₁ - (t₁ + t₂) / 2) = gaussWin (2 * s) (t₁ - t₂) := by
    rw [show t₁ - (t₁ + t₂) / 2 = (t₁ - t₂) / 2 by ring, gaussWin_half_eq]
  have h2 : gaussWin s (t₂ - (t₁ + t₂) / 2) = gaussWin (2 * s) (t₁ - t₂) := by
    rw [show t₂ - (t₁ + t₂) / 2 = (-(t₁ - t₂)) / 2 by ring, gaussWin_half_eq, gaussWin_even]
  simp only [posProfile, Multiset.insert_eq_cons, Multiset.map_cons, Multiset.sum_cons,
    Multiset.map_singleton, Multiset.sum_singleton, h1, h2]
  ring

/-- **The sharp two-ordinate resolution criterion.**  With `u = g_{2s}(t₁ - t₂)` and
`wᵢ = 1/(1/4 + tᵢ²)`, the profile is strictly larger at `t₁` than at the midpoint precisely when
`u(1 + u + u²) w₂ < w₁`. -/
theorem posProfile_two_resolved_sharp {s t₁ t₂ : ℝ} (hs : 0 < s) (hne : t₁ ≠ t₂)
    (h : gaussWin (2 * s) (t₁ - t₂) *
          (1 + gaussWin (2 * s) (t₁ - t₂) + gaussWin (2 * s) (t₁ - t₂) ^ 2) *
          (1 / (1 / 4 + t₂ ^ 2))
        < 1 / (1 / 4 + t₁ ^ 2)) :
    posProfile {t₁, t₂} s ((t₁ + t₂) / 2) < posProfile {t₁, t₂} s t₁ := by
  rw [posProfile_pair_at, posProfile_pair_mid]
  set u := gaussWin (2 * s) (t₁ - t₂) with hu
  set A := 1 / (1 / 4 + t₁ ^ 2) with hA
  set B := 1 / (1 / 4 + t₂ ^ 2) with hB
  have hu0 : 0 < u := gaussWin_pos _ _
  have hu1 : u < 1 := gaussWin_lt_one (by positivity) (sub_ne_zero.mpr hne)
  have hpos : 0 < (1 - u) * (A - u * (1 + u + u ^ 2) * B) :=
    mul_pos (by linarith) (by linarith)
  nlinarith [hpos]

/-- **The Rayleigh criterion for Gaussian windows.**  If
`3 · g_{2s}(t₁ - t₂) · (1/4 + t₁²) ≤ 1/4 + t₂²`, the two ordinates `t₁ ≠ t₂` are *resolved*: the
position profile is strictly larger at `t₁` than at the midpoint, so the midpoint is not a peak.
The constant `3` is the crude bound `1 + u + u² < 3` on the sharp criterion. -/
theorem posProfile_two_resolved {s t₁ t₂ : ℝ} (hs : 0 < s) (hne : t₁ ≠ t₂)
    (h : 3 * gaussWin (2 * s) (t₁ - t₂) * (1 / 4 + t₁ ^ 2) ≤ 1 / 4 + t₂ ^ 2) :
    posProfile {t₁, t₂} s ((t₁ + t₂) / 2) < posProfile {t₁, t₂} s t₁ := by
  have hd₁ : (0:ℝ) < 1 / 4 + t₁ ^ 2 := by positivity
  have hd₂ : (0:ℝ) < 1 / 4 + t₂ ^ 2 := by positivity
  have hu0 : 0 < gaussWin (2 * s) (t₁ - t₂) := gaussWin_pos _ _
  have hu1 : gaussWin (2 * s) (t₁ - t₂) < 1 :=
    gaussWin_lt_one (by positivity) (sub_ne_zero.mpr hne)
  have hB : (0:ℝ) < 1 / (1 / 4 + t₂ ^ 2) := by positivity
  have h1 : 3 * gaussWin (2 * s) (t₁ - t₂) * (1 / (1 / 4 + t₂ ^ 2)) ≤ 1 / (1 / 4 + t₁ ^ 2) := by
    rw [mul_one_div, div_le_div_iff₀ hd₂ hd₁]
    linarith
  refine posProfile_two_resolved_sharp hs hne (lt_of_lt_of_le ?_ h1)
  have : gaussWin (2 * s) (t₁ - t₂) *
      (1 + gaussWin (2 * s) (t₁ - t₂) + gaussWin (2 * s) (t₁ - t₂) ^ 2)
      < 3 * gaussWin (2 * s) (t₁ - t₂) := by nlinarith
  exact mul_lt_mul_of_pos_right this hB

/-! ## The criterion is never vacuous -/

/-- As the window narrows, its value at any fixed nonzero offset tends to `0`. -/
theorem gaussWin_tendsto_zero_nhdsGT {c d : ℝ} (hc : 0 < c) (hd : d ≠ 0) :
    Tendsto (fun s : ℝ => gaussWin (c * s) d) (𝓝[>] (0:ℝ)) (𝓝 0) := by
  have hsq : Tendsto (fun s : ℝ => s ^ 2) (𝓝[>] (0:ℝ)) (𝓝[>] (0:ℝ)) := by
    rw [tendsto_nhdsWithin_iff]
    constructor
    · have : Tendsto (fun s : ℝ => s ^ 2) (𝓝 (0:ℝ)) (𝓝 ((0:ℝ) ^ 2)) :=
        (continuous_pow 2).tendsto 0
      simpa using this.mono_left nhdsWithin_le_nhds
    · filter_upwards [self_mem_nhdsWithin] with s hs
      exact pow_pos (Set.mem_Ioi.mp hs) 2
  have hinv : Tendsto (fun s : ℝ => (s ^ 2)⁻¹) (𝓝[>] (0:ℝ)) atTop :=
    tendsto_inv_nhdsGT_zero.comp hsq
  have hneg : (-(π * d ^ 2 / c ^ 2) : ℝ) < 0 := by
    have : 0 < π * d ^ 2 / c ^ 2 := by positivity
    linarith
  have hbot : Tendsto (fun s : ℝ => -(π * d ^ 2 / c ^ 2) * (s ^ 2)⁻¹) (𝓝[>] (0:ℝ)) atBot :=
    hinv.const_mul_atTop_of_neg hneg
  have := Real.tendsto_exp_atBot.comp hbot
  refine this.congr fun s => ?_
  simp only [Function.comp_apply, gaussWin]
  congr 1
  field_simp

/-- **The Rayleigh criterion is never vacuous.**  Any two *distinct* ordinates are resolved by all
sufficiently narrow Gaussian windows.  This is the precise sense in which a Gaussian peak finder
has no resolution floor — unlike the rectangular window, whose relative sidelobe amplitude is the
width-independent constant `1/π` (`Algebra.SmoothWindows.Sidelobes`). -/
theorem posProfile_two_resolved_eventually {t₁ t₂ : ℝ} (hne : t₁ ≠ t₂) :
    ∀ᶠ s in 𝓝[>] (0:ℝ),
      posProfile {t₁, t₂} s ((t₁ + t₂) / 2) < posProfile {t₁, t₂} s t₁ := by
  have hd₂ : (0:ℝ) < 1 / 4 + t₂ ^ 2 := by positivity
  have h0 : Tendsto (fun s : ℝ => 3 * gaussWin (2 * s) (t₁ - t₂) * (1 / 4 + t₁ ^ 2))
      (𝓝[>] (0:ℝ)) (𝓝 0) := by
    have := gaussWin_tendsto_zero_nhdsGT (c := 2) (d := t₁ - t₂) two_pos
      (sub_ne_zero.mpr hne)
    simpa using ((this.const_mul 3).mul_const (1 / 4 + t₁ ^ 2))
  filter_upwards [self_mem_nhdsWithin, h0.eventually_lt_const hd₂] with s hs hlt
  exact posProfile_two_resolved (Set.mem_Ioi.mp hs) hne hlt.le

end SmoothWindows