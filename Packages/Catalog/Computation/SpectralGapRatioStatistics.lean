import Mathlib
import Computation.SpectralUnfoldingGapStatistics
import Computation.SpectralPoissonVsGUE

/-!
# The unfolding-free gap-ratio statistic, and the mode of the Wigner surmise

The normalized-gap statistics of `Computation.SpectralUnfoldingGapStatistics` require a
choice of window and of unfolding map.  This file develops two statistics that are
*free of that choice*, and uses them to separate the three regimes
(rigid / Poisson / GUE) intrinsically.

* `gapRatio` — the consecutive gap ratio `rᵢ = min(sᵢ, sᵢ₊₁) / max(sᵢ, sᵢ₊₁)`
  (Oganesyan–Huse `r`-statistic).  `gapRatio_affine` shows it is invariant under
  *every* affine change of scale with no unfolding whatsoever, and
  `gapRatio_eq_one_iff` characterizes the rigid value `r = 1`.
* `gapRatio_quad_tendsto_one` : the raw quadratic spectrum already has
  `rᵢ = (2i+1)/(2i+3) → 1`; combined with `unfoldedQuad_gapRatio_eq_one` this shows the
  `r`-statistic sees the rigidity of the quadratic spectrum *without* unfolding, whereas
  the normalized-gap distribution of the raw spectrum is uniform on `[0,2]`
  (`quad_gapCDF_close_uniform`) and only becomes a Dirac mass at `1` after unfolding.
* `gue_pdf_strict_max_at_mode` : the Wigner surmise has a strict interior mode at
  `s = √π/2`, with maximal value `8/(π e)`, while `poissonGapPdf_strictAnti` shows the
  Poisson density is strictly decreasing and has no interior mode.  This is a
  scale-free, normalization-free distinction between the two universality classes.
* `general_unfolding_normGap` and `arithmetic_spectrum_rigidity` : the unfolding
  principle and the number rigidity for a general spectrum, of which the quadratic
  spectrum is one instance.
-/

namespace Catalog.Computation.SpectralGapRatio

open Catalog.Computation.SpectralUnfolding Catalog.Computation.SpectralPoissonGUE
open Real Filter
open scoped Topology

/-! ## The gap ratio statistic -/

/-- The consecutive gap ratio `rᵢ = min(sᵢ, sᵢ₊₁)/max(sᵢ, sᵢ₊₁)`. -/
noncomputable def gapRatio (lam : ℕ → ℝ) (i : ℕ) : ℝ :=
  min (gap lam i) (gap lam (i + 1)) / max (gap lam i) (gap lam (i + 1))

/-- **The gap ratio needs no unfolding**: it is invariant under every affine change of
scale of the spectrum (positive slope), with no reference to a window or to a mean
spacing. -/
theorem gapRatio_affine (lam : ℕ → ℝ) (a b : ℝ) (ha : 0 < a) (i : ℕ) :
    gapRatio (fun k => a * lam k + b) i = gapRatio lam i := by
  have hg : ∀ j : ℕ, gap (fun k => a * lam k + b) j = a * gap lam j := by
    intro j
    simp only [gap]
    ring
  simp only [gapRatio, hg]
  rw [← mul_min_of_nonneg _ _ ha.le, ← mul_max_of_nonneg _ _ ha.le,
    mul_div_mul_left _ _ (ne_of_gt ha)]

/-- The gap ratio lies in `[0,1]` for a spectrum with positive gaps. -/
theorem gapRatio_le_one (lam : ℕ → ℝ) (i : ℕ) (h1 : 0 < gap lam i) :
    gapRatio lam i ≤ 1 := by
  rw [gapRatio, div_le_one (lt_max_of_lt_left h1)]
  exact min_le_max

theorem gapRatio_nonneg (lam : ℕ → ℝ) (i : ℕ) (h1 : 0 < gap lam i)
    (h2 : 0 < gap lam (i + 1)) : 0 ≤ gapRatio lam i := by
  apply div_nonneg (le_min h1.le h2.le)
  exact le_max_of_le_left h1.le

/-- The rigid value `r = 1` is attained exactly when two consecutive gaps agree. -/
theorem gapRatio_eq_one_iff (lam : ℕ → ℝ) (i : ℕ) (h1 : 0 < gap lam i) :
    gapRatio lam i = 1 ↔ gap lam i = gap lam (i + 1) := by
  have hmax : 0 < max (gap lam i) (gap lam (i + 1)) := lt_max_of_lt_left h1
  rw [gapRatio, div_eq_one_iff_eq (ne_of_gt hmax)]
  constructor
  · intro h
    rcases le_total (gap lam i) (gap lam (i + 1)) with hle | hle
    · rw [min_eq_left hle, max_eq_right hle] at h
      exact h
    · rw [min_eq_right hle, max_eq_left hle] at h
      exact h.symm
  · intro h
    rw [h, min_self, max_self]

/-! ## The quadratic spectrum through the gap-ratio lens -/

/-- The gap ratio of the *raw* quadratic spectrum. -/
theorem gapRatio_quad (i : ℕ) : gapRatio quadSpectrum i = (2 * i + 1) / (2 * i + 3) := by
  have h1 : gap quadSpectrum i = 2 * (i : ℝ) + 1 := gap_quad i
  have h2 : gap quadSpectrum (i + 1) = 2 * (i : ℝ) + 3 := by
    rw [gap_quad]
    push_cast
    ring
  have hle : (2 * (i : ℝ) + 1) ≤ 2 * (i : ℝ) + 3 := by linarith
  rw [gapRatio, h1, h2, min_eq_left hle, max_eq_right hle]

/-- **The `r`-statistic detects the rigidity of the quadratic spectrum without any
unfolding**: `rᵢ → 1`, the value of a perfectly rigid picket fence. -/
theorem gapRatio_quad_tendsto_one :
    Tendsto (fun i : ℕ => gapRatio quadSpectrum i) atTop (𝓝 1) := by
  have h : ∀ i : ℕ, gapRatio quadSpectrum i = 1 - 2 / (2 * (i : ℝ) + 3) := by
    intro i
    rw [gapRatio_quad]
    have hne : (2 * (i : ℝ) + 3) ≠ 0 := by positivity
    field_simp
    ring
  simp only [h]
  have hden : Tendsto (fun i : ℕ => 2 * (i : ℝ) + 3) atTop atTop := by
    apply Filter.tendsto_atTop_add_const_right
    exact tendsto_natCast_atTop_atTop.const_mul_atTop (by norm_num : (0:ℝ) < 2)
  have h0 : Tendsto (fun i : ℕ => 2 / (2 * (i : ℝ) + 3)) atTop (𝓝 0) :=
    Filter.Tendsto.div_atTop tendsto_const_nhds hden
  simpa using tendsto_const_nhds.sub h0

/-- The quantitative rate: the deviation of the quadratic `r`-statistic from the rigid
value `1` is exactly `2/(2i+3)`. -/
theorem one_sub_gapRatio_quad (i : ℕ) :
    1 - gapRatio quadSpectrum i = 2 / (2 * (i : ℝ) + 3) := by
  rw [gapRatio_quad]
  have hne : (2 * (i : ℝ) + 3) ≠ 0 := by positivity
  field_simp
  ring

/-- After unfolding, the gap ratio of the quadratic spectrum equals `1` exactly. -/
theorem unfoldedQuad_gapRatio_eq_one (i : ℕ) : gapRatio unfoldedQuad i = 1 := by
  rw [gapRatio, gap_unfoldedQuad, gap_unfoldedQuad, min_self, max_self, div_one]

/-- Every `r`-value of the raw quadratic spectrum is strictly below the rigid value:
rigidity is approached but never attained before unfolding. -/
theorem gapRatio_quad_lt_one (i : ℕ) : gapRatio quadSpectrum i < 1 := by
  rw [gapRatio_quad, div_lt_one (by positivity)]
  linarith

/-! ## The unfolding principle in general -/

/-- **The unfolding principle.**  If `g` inverts the level sequence (`g (λ k) = k`, i.e.
`g` is the counting function of the spectrum), then the unfolded spectrum `g ∘ λ` has all
normalized gaps equal to `1`. -/
theorem general_unfolding_normGap (lam : ℕ → ℝ) (g : ℝ → ℝ) (hg : ∀ k : ℕ, g (lam k) = k)
    (n i : ℕ) (hn : 0 < n) : normGap (fun k => g (lam k)) n i = 1 := by
  have hn' : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
  have hgap : gap (fun k => g (lam k)) i = 1 := by
    simp only [gap, hg]
    push_cast
    ring
  have hmean : meanGap (fun k => g (lam k)) n = 1 := by
    simp only [meanGap, hg, Nat.cast_zero, sub_zero]
    exact div_self hn'
  rw [normGap, hgap, hmean, div_one]

/-- The quadratic spectrum is the instance `g = √·` of the unfolding principle: its
counting function `N(x) = √x` inverts the level sequence, so all normalized gaps of
`√(λ_k)` are `1`. -/
theorem quadSpectrum_unfolding (n i : ℕ) (hn : 0 < n) :
    normGap (fun k => Real.sqrt (quadSpectrum k)) n i = 1 :=
  general_unfolding_normGap quadSpectrum Real.sqrt unfoldedQuad_eq n i hn

/-- **Rigidity of an arbitrary arithmetic spectrum.**  For levels `d·k` (`d > 0`) the
number of levels in any window `[a, a+L)` differs from the expected value `L/d` by less
than one, uniformly in the position of the window. -/
theorem arithmetic_spectrum_rigidity (d : ℝ) (hd : 0 < d) (a L : ℝ) (hL : 0 ≤ L) :
    |((Finset.Ico ⌈a / d⌉ ⌈a / d + L / d⌉).card : ℝ) - L / d| < 1 :=
  picket_number_rigidity (a / d) (L / d) (by positivity)

/-- The levels `d·m` (`m` an integer) inside the window `[a, a+L)` correspond exactly to
the integers of `Finset.Ico ⌈a/d⌉ ⌈a/d + L/d⌉`. -/
theorem mem_arithmetic_window (d : ℝ) (hd : 0 < d) (a L : ℝ) (m : ℤ) :
    m ∈ Finset.Ico ⌈a / d⌉ ⌈a / d + L / d⌉ ↔ (a ≤ d * m ∧ d * m < a + L) := by
  rw [mem_picketWindow]
  rw [← add_div]
  constructor
  · rintro ⟨h1, h2⟩
    refine ⟨?_, ?_⟩
    · have hle := (div_le_iff₀ hd).mp h1
      rw [mul_comm]
      exact hle
    · have hlt := (lt_div_iff₀ hd).mp h2
      rw [mul_comm]
      exact hlt
  · rintro ⟨h1, h2⟩
    refine ⟨?_, ?_⟩
    · rw [div_le_iff₀ hd, mul_comm]
      exact h1
    · rw [lt_div_iff₀ hd, mul_comm]
      exact h2

/-! ## The mode of the Wigner surmise versus the monotone Poisson density -/

/-- The Poisson spacing density is strictly decreasing: it has no interior mode, and its
maximum sits at zero spacing. -/
theorem poissonGapPdf_strictAnti : StrictAnti poissonGapPdf := by
  intro x y hxy
  simp only [poissonGapPdf]
  exact Real.exp_lt_exp.mpr (by linarith)

/-- The maximal value of the Wigner surmise. -/
theorem gue_pdf_at_mode : gueGapPdf (Real.sqrt π / 2) = 8 / (π * Real.exp 1) := by
  have hpi : 0 < π := Real.pi_pos
  have hpine : π ≠ 0 := ne_of_gt hpi
  have he : Real.exp 1 ≠ 0 := Real.exp_ne_zero 1
  have hsq : (Real.sqrt π / 2) ^ 2 = π / 4 := by
    rw [div_pow, Real.sq_sqrt hpi.le]
    norm_num
  rw [gueGapPdf, hsq, show -(4 / π) * (π / 4) = -1 by field_simp, Real.exp_neg]
  field_simp
  ring

/-- The elementary strict inequality behind the mode: `u e^{-u} < e^{-1}` for `u ≠ 1`. -/
lemma u_mul_exp_neg_lt (u : ℝ) (hne : u ≠ 1) : u * Real.exp (-u) < Real.exp (-1) := by
  have hexp : u < Real.exp (u - 1) := by
    have h := Real.add_one_lt_exp (x := u - 1) (by intro h; exact hne (by linarith))
    linarith
  have h1 : (0 : ℝ) < Real.exp (-u) := Real.exp_pos _
  calc u * Real.exp (-u) < Real.exp (u - 1) * Real.exp (-u) := mul_lt_mul_of_pos_right hexp h1
    _ = Real.exp (-1) := by
        rw [← Real.exp_add]
        ring_nf

/-- **Level repulsion produces an interior mode.**  The Wigner surmise attains its
maximum `8/(πe)` at `s = √π/2 ≈ 0.886`, and is strictly below it at every other positive
spacing.  The Poisson density, by contrast, is strictly decreasing
(`poissonGapPdf_strictAnti`). -/
theorem gue_pdf_strict_max_at_mode (s : ℝ) (hs : 0 < s) (hne : s ≠ Real.sqrt π / 2) :
    gueGapPdf s < gueGapPdf (Real.sqrt π / 2) := by
  have hpi : 0 < π := Real.pi_pos
  have hpine : π ≠ 0 := ne_of_gt hpi
  have hsq : (Real.sqrt π / 2) ^ 2 = π / 4 := by
    rw [div_pow, Real.sq_sqrt hpi.le]
    norm_num
  have hune : (4 / π) * s ^ 2 ≠ 1 := by
    intro h
    apply hne
    have hs2 : s ^ 2 = π / 4 := by
      field_simp at h
      linarith
    have hstep : s = Real.sqrt (π / 4) := by
      rw [← hs2, Real.sqrt_sq hs.le]
    rw [hstep, ← hsq, Real.sqrt_sq (by positivity)]
  have hkey := u_mul_exp_neg_lt ((4 / π) * s ^ 2) hune
  have hguerw : gueGapPdf s
      = (8 / π) * (((4 / π) * s ^ 2) * Real.exp (-((4 / π) * s ^ 2))) := by
    rw [gueGapPdf, show -(4 / π) * s ^ 2 = -((4 / π) * s ^ 2) by ring]
    field_simp
    ring
  have h8 : 0 < 8 / π := by positivity
  have he : Real.exp 1 ≠ 0 := Real.exp_ne_zero 1
  rw [hguerw, gue_pdf_at_mode]
  calc (8 / π) * (((4 / π) * s ^ 2) * Real.exp (-((4 / π) * s ^ 2)))
      < (8 / π) * Real.exp (-1) := mul_lt_mul_of_pos_left hkey h8
    _ = 8 / (π * Real.exp 1) := by
        rw [Real.exp_neg]
        field_simp

end Catalog.Computation.SpectralGapRatio