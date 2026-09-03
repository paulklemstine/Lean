import Mathlib

/-!
# The two-loop `O(N)` fixed point: existence and uniform `O(ε³)` asymptotics

`Catalog/Physics/ONModelEpsilonExpansion.lean` treats the *truncated* one-loop
flow, where the Wilson–Fisher coupling `3ε/(N+8)` is an exact root of a
quadratic.  At two loops the beta function

`β_N(ε, g) = -ε g + ((N+8)/3) g² - c g³`

is a genuine cubic and its non-Gaussian zero is no longer a polynomial in `ε`.
This file proves, with no appeal to formal power series:

* **existence** of a non-Gaussian zero in `[ε/a, 2ε/a]` (intermediate value
  theorem applied to the quadratic factor);
* an **exact algebraic identity** for the slope of the flow at *any*
  non-Gaussian zero: `∂_g β = ε - c g²`;
* a **quantitative expansion with explicit constants**,
  `0 ≤ g* - (ε/a + c ε²/a³) ≤ 12 c² ε³ / a⁵`,
  and correspondingly for the correction-to-scaling exponent
  `|ω - (ε - c ε²/a²)| ≤ 12 c² ε³ / a⁴`;
* the specialisation to the `O(N)` family, **uniform on `N ≥ 0` and
  `0 < ε ≤ 4/7`**: the two-loop fixed point is
  `3ε/(N+8) + 27 c ε²/(N+8)³ + O(ε³)` with an `N`-independent constant in the
  remainder, and it always *exceeds* the one-loop value.

The two-loop coefficient is kept as a parameter `c > 0` throughout, so that the
results are scheme-independent; the value `c = (3N+14)/9` is the standard
choice in the normalisation fixed in `ONModelEpsilonExpansion.lean`.
-/

namespace ONModel

open Set

/-! ## A self-contained quantitative root lemma -/

/-- Existence of a small positive root of `c x² - a x + ε` when `4cε ≤ a²`.
This is the non-Gaussian zero of the cubic beta function `-εg + a g² - c g³`
after removing the factor `g`. -/
theorem exists_small_root {a c ε : ℝ} (ha : 0 < a) (hc : 0 < c) (hε : 0 < ε)
    (hsmall : 4 * c * ε ≤ a ^ 2) :
    ∃ r ∈ Icc (ε / a) (2 * ε / a), c * r ^ 2 - a * r + ε = 0 := by
  set f : ℝ → ℝ := fun x => c * x ^ 2 - a * x + ε with hf
  have hcont : ContinuousOn f (Icc (ε / a) (2 * ε / a)) := by
    apply Continuous.continuousOn
    fun_prop
  have hle : ε / a ≤ 2 * ε / a := by
    rw [div_le_div_iff₀ ha ha]; nlinarith
  have hlow : f (2 * ε / a) ≤ 0 := by
    have h : f (2 * ε / a) = (4 * c * ε - a ^ 2) * ε / a ^ 2 := by
      simp only [hf]
      field_simp
      ring
    rw [h]
    apply div_nonpos_of_nonpos_of_nonneg _ (by positivity)
    nlinarith
  have hhigh : 0 ≤ f (ε / a) := by
    have h : f (ε / a) = c * ε ^ 2 / a ^ 2 := by
      simp only [hf]
      field_simp
      ring
    rw [h]; positivity
  have := intermediate_value_Icc' hle hcont
  have h0 : (0 : ℝ) ∈ Icc (f (2 * ε / a)) (f (ε / a)) := ⟨hlow, hhigh⟩
  obtain ⟨r, hr, hfr⟩ := this h0
  exact ⟨r, hr, hfr⟩

/-- **The slope of the two-loop flow at a non-Gaussian zero is exactly
`ε - c r²`.**  No approximation is involved: the cubic and its derivative are
related by an algebraic identity along the zero locus. -/
theorem slope_at_root {a c ε r : ℝ} (hr : c * r ^ 2 - a * r + ε = 0) :
    -ε + 2 * a * r - 3 * c * r ^ 2 = ε - c * r ^ 2 := by
  linear_combination -2 * hr

/-- **Quantitative two-loop expansion of the fixed point.**  Any root of
`c x² - a x + ε` lying in `[ε/a, 2ε/a]` exceeds the one-loop value by the
two-loop term `cε²/a³`, with a remainder bounded by `12c²ε³/a⁵`. -/
theorem root_expansion {a c ε r : ℝ} (ha : 0 < a) (hc : 0 < c) (hε : 0 < ε)
    (h1 : ε / a ≤ r) (h2 : r ≤ 2 * ε / a) (hr : c * r ^ 2 - a * r + ε = 0) :
    0 ≤ r - (ε / a + c * ε ^ 2 / a ^ 3) ∧
      r - (ε / a + c * ε ^ 2 / a ^ 3) ≤ 12 * c ^ 2 * ε ^ 3 / a ^ 5 := by
  have ha' : a ≠ 0 := ne_of_gt ha
  have hlow : ε ≤ a * r := by
    rw [div_le_iff₀ ha] at h1; linarith
  have hup : a * r ≤ 2 * ε := by
    rw [le_div_iff₀ ha] at h2; linarith
  -- the defect, after clearing `a³`
  have hid : a ^ 3 * (r - (ε / a + c * ε ^ 2 / a ^ 3))
      = c * (a * r - ε) * (a * r + ε) := by
    field_simp
    linear_combination (-a ^ 2) * hr
  have hdiff : a * r - ε = c * r ^ 2 := by linarith
  have hrpos : 0 ≤ r := le_trans (by positivity) h1
  have hfac1 : 0 ≤ a * r - ε := by linarith
  have hfac2 : 0 ≤ a * r + ε := by linarith
  have ha3 : (0 : ℝ) < a ^ 3 := by positivity
  constructor
  · have : 0 ≤ a ^ 3 * (r - (ε / a + c * ε ^ 2 / a ^ 3)) := by
      rw [hid]; positivity
    nlinarith
  · -- sharpen: `a r - ε = c r² ≤ 4cε²/a²` and `a r + ε ≤ 3ε`
    have hr2 : r ^ 2 ≤ 4 * ε ^ 2 / a ^ 2 := by
      have h2' : r ≤ 2 * ε / a := h2
      have : r ^ 2 ≤ (2 * ε / a) ^ 2 := by nlinarith
      calc r ^ 2 ≤ (2 * ε / a) ^ 2 := this
        _ = 4 * ε ^ 2 / a ^ 2 := by field_simp; ring
    have hb1 : a * r - ε ≤ 4 * c * ε ^ 2 / a ^ 2 := by
      rw [hdiff]
      have : c * r ^ 2 ≤ c * (4 * ε ^ 2 / a ^ 2) := by nlinarith
      calc c * r ^ 2 ≤ c * (4 * ε ^ 2 / a ^ 2) := this
        _ = 4 * c * ε ^ 2 / a ^ 2 := by ring
    have hb2 : a * r + ε ≤ 3 * ε := by linarith
    have hprod : c * (a * r - ε) * (a * r + ε) ≤ 12 * c ^ 2 * ε ^ 3 / a ^ 2 := by
      have hstep : c * (a * r - ε) * (a * r + ε)
          ≤ c * (4 * c * ε ^ 2 / a ^ 2) * (3 * ε) := by
        have h1' : c * (a * r - ε) ≤ c * (4 * c * ε ^ 2 / a ^ 2) := by nlinarith
        have h2' : (0:ℝ) ≤ c * (a * r - ε) := by positivity
        nlinarith
      calc c * (a * r - ε) * (a * r + ε) ≤ c * (4 * c * ε ^ 2 / a ^ 2) * (3 * ε) := hstep
        _ = 12 * c ^ 2 * ε ^ 3 / a ^ 2 := by field_simp; ring
    have hkey : a ^ 3 * (r - (ε / a + c * ε ^ 2 / a ^ 3)) ≤ 12 * c ^ 2 * ε ^ 3 / a ^ 2 := by
      rw [hid]; exact hprod
    have hgoal : r - (ε / a + c * ε ^ 2 / a ^ 3) ≤ (12 * c ^ 2 * ε ^ 3 / a ^ 2) / a ^ 3 := by
      rw [le_div_iff₀ ha3]; linarith [hkey]
    calc r - (ε / a + c * ε ^ 2 / a ^ 3) ≤ (12 * c ^ 2 * ε ^ 3 / a ^ 2) / a ^ 3 := hgoal
      _ = 12 * c ^ 2 * ε ^ 3 / a ^ 5 := by field_simp

/-- **Quantitative two-loop expansion of the correction-to-scaling exponent.**
`ω = ε - cε²/a² + O(ε³)` with an explicit constant. -/
theorem omega_expansion {a c ε r : ℝ} (ha : 0 < a) (hc : 0 < c) (hε : 0 < ε)
    (h1 : ε / a ≤ r) (h2 : r ≤ 2 * ε / a) (hr : c * r ^ 2 - a * r + ε = 0) :
    |(-ε + 2 * a * r - 3 * c * r ^ 2) - (ε - c * ε ^ 2 / a ^ 2)|
      ≤ 12 * c ^ 2 * ε ^ 3 / a ^ 4 := by
  have ha' : a ≠ 0 := ne_of_gt ha
  have hlow : ε ≤ a * r := by rw [div_le_iff₀ ha] at h1; linarith
  have hup : a * r ≤ 2 * ε := by rw [le_div_iff₀ ha] at h2; linarith
  rw [slope_at_root hr]
  have hval : (ε - c * r ^ 2) - (ε - c * ε ^ 2 / a ^ 2)
      = -(c * (r ^ 2 - ε ^ 2 / a ^ 2)) := by ring
  rw [hval, abs_neg]
  have hr2u : r ^ 2 ≤ 4 * ε ^ 2 / a ^ 2 := by
    have : r ^ 2 ≤ (2 * ε / a) ^ 2 := by
      have hrpos : 0 ≤ r := le_trans (by positivity) h1
      nlinarith
    calc r ^ 2 ≤ (2 * ε / a) ^ 2 := this
      _ = 4 * ε ^ 2 / a ^ 2 := by field_simp; ring
  have hr2l : ε ^ 2 / a ^ 2 ≤ r ^ 2 := by
    have hrpos : 0 ≤ ε / a := by positivity
    have : (ε / a) ^ 2 ≤ r ^ 2 := by nlinarith
    calc ε ^ 2 / a ^ 2 = (ε / a) ^ 2 := by field_simp
      _ ≤ r ^ 2 := this
  -- the difference of squares is controlled by `4cε³/a³ · 3`
  have hgap : r ^ 2 - ε ^ 2 / a ^ 2 ≤ 12 * c * ε ^ 3 / a ^ 4 := by
    have hdiff : a * r - ε = c * r ^ 2 := by linarith
    have hfactor : r ^ 2 - ε ^ 2 / a ^ 2 = (a * r - ε) * (a * r + ε) / a ^ 2 := by
      field_simp; ring
    rw [hfactor]
    have hb1 : a * r - ε ≤ 4 * c * ε ^ 2 / a ^ 2 := by
      rw [hdiff]
      have : c * r ^ 2 ≤ c * (4 * ε ^ 2 / a ^ 2) := by nlinarith
      linarith [this, (by ring : c * (4 * ε ^ 2 / a ^ 2) = 4 * c * ε ^ 2 / a ^ 2)]
    have hb2 : a * r + ε ≤ 3 * ε := by linarith
    have hnn : 0 ≤ a * r - ε := by linarith
    have hprod : (a * r - ε) * (a * r + ε) ≤ (4 * c * ε ^ 2 / a ^ 2) * (3 * ε) := by
      nlinarith [(by positivity : (0:ℝ) ≤ 4 * c * ε ^ 2 / a ^ 2)]
    have ha2 : (0:ℝ) < a ^ 2 := by positivity
    rw [div_le_iff₀ ha2]
    calc (a * r - ε) * (a * r + ε) ≤ (4 * c * ε ^ 2 / a ^ 2) * (3 * ε) := hprod
      _ = 12 * c * ε ^ 3 / a ^ 4 * a ^ 2 := by field_simp; ring
  have hnonneg : 0 ≤ r ^ 2 - ε ^ 2 / a ^ 2 := by linarith
  rw [abs_of_nonneg (by positivity : (0:ℝ) ≤ c * (r ^ 2 - ε ^ 2 / a ^ 2))]
  have : c * (r ^ 2 - ε ^ 2 / a ^ 2) ≤ c * (12 * c * ε ^ 3 / a ^ 4) := by nlinarith
  calc c * (r ^ 2 - ε ^ 2 / a ^ 2) ≤ c * (12 * c * ε ^ 3 / a ^ 4) := this
    _ = 12 * c ^ 2 * ε ^ 3 / a ^ 4 := by ring

/-! ## Specialisation to the `O(N)` family -/

/-- The two-loop beta function of the `O(N)` model, with the two-loop
coefficient `c` kept as a parameter. -/
noncomputable def betaTwoLoop (N c ε g : ℝ) : ℝ :=
  -ε * g + ((N + 8) / 3) * g ^ 2 - c * g ^ 3

/-- The standard two-loop coefficient in the normalisation of this catalog
entry. -/
noncomputable def twoLoopCoeff (N : ℝ) : ℝ := (3 * N + 14) / 9

/-- The prediction for the two-loop fixed point:
`3ε/(N+8) + 27 c ε²/(N+8)³`. -/
noncomputable def fixedPointTwoLoop (N c ε : ℝ) : ℝ :=
  3 * ε / (N + 8) + 27 * c * ε ^ 2 / (N + 8) ^ 3

/-- A zero of the quadratic factor is a zero of the cubic beta function. -/
theorem betaTwoLoop_eq_zero_of_root {N c ε g : ℝ}
    (hr : c * g ^ 2 - ((N + 8) / 3) * g + ε = 0) : betaTwoLoop N c ε g = 0 := by
  unfold betaTwoLoop
  linear_combination (-g) * hr

/-- **Existence and uniform two-loop asymptotics of the `O(N)` fixed point.**
For every `N ≥ 0` and every `0 < ε ≤ 4/7` the two-loop beta function with the
standard coefficient has a non-Gaussian zero `g` which
* is a genuine zero of the cubic;
* lies strictly above the one-loop Wilson–Fisher value; and
* satisfies `|g - (3ε/(N+8) + 27 c ε²/(N+8)³)| ≤ ε³`,
the constant `1` being independent of `N`. -/
theorem twoLoop_fixedPoint_uniform {N ε : ℝ} (hN : 0 ≤ N) (hε : 0 < ε)
    (hε' : ε ≤ 4 / 7) :
    ∃ g, betaTwoLoop N (twoLoopCoeff N) ε g = 0 ∧
      3 * ε / (N + 8) ≤ g ∧
      |g - fixedPointTwoLoop N (twoLoopCoeff N) ε| ≤ ε ^ 3 := by
  set a : ℝ := (N + 8) / 3 with hadef
  set c : ℝ := twoLoopCoeff N with hcdef
  have ht : (8 : ℝ) ≤ N + 8 := by linarith
  have ha : 0 < a := by rw [hadef]; linarith
  have hc : 0 < c := by rw [hcdef, twoLoopCoeff]; linarith
  have hsmall : 4 * c * ε ≤ a ^ 2 := by
    rw [hcdef, hadef, twoLoopCoeff]
    have h1 : 4 * ((3 * N + 14) / 9) * ε ≤ 4 * ((3 * N + 14) / 9) * (4 / 7) := by
      have : (0:ℝ) ≤ 4 * ((3 * N + 14) / 9) := by linarith
      nlinarith
    nlinarith
  obtain ⟨r, hrmem, hr⟩ := exists_small_root ha hc hε hsmall
  obtain ⟨h1, h2⟩ := hrmem
  have hεa : ε / a = 3 * ε / (N + 8) := by rw [hadef]; field_simp
  have hexp := root_expansion ha hc hε h1 h2 hr
  refine ⟨r, betaTwoLoop_eq_zero_of_root hr, ?_, ?_⟩
  · rw [← hεa]; exact h1
  · have hpred : fixedPointTwoLoop N c ε = ε / a + c * ε ^ 2 / a ^ 3 := by
      rw [hadef, fixedPointTwoLoop]
      have h8 : N + 8 ≠ 0 := by linarith
      field_simp
      ring
    rw [hpred, abs_of_nonneg hexp.1]
    refine le_trans hexp.2 ?_
    -- `12 c²/a⁵ ≤ 1` uniformly for `N ≥ 0`
    have hcle : c ≤ (N + 8) / 3 := by
      rw [hcdef, twoLoopCoeff]; linarith
    have ha5 : (0:ℝ) < a ^ 5 := by positivity
    rw [div_le_iff₀ ha5]
    have hc2 : c ^ 2 ≤ ((N + 8) / 3) ^ 2 := by nlinarith
    have ha5' : a ^ 5 = ((N + 8) / 3) ^ 5 := by rw [hadef]
    have hstep : 12 * c ^ 2 * ε ^ 3 ≤ 12 * ((N + 8) / 3) ^ 2 * ε ^ 3 := by
      have : (0:ℝ) < ε ^ 3 := by positivity
      nlinarith
    refine le_trans hstep ?_
    rw [ha5']
    have hbig : 12 * ((N + 8) / 3) ^ 2 ≤ ((N + 8) / 3) ^ 5 := by
      have h3 : (8:ℝ) / 3 ≤ (N + 8) / 3 := by linarith
      have hcube : (12:ℝ) ≤ ((N + 8) / 3) ^ 3 := by nlinarith
      nlinarith [sq_nonneg ((N + 8) / 3)]
    nlinarith [(by positivity : (0:ℝ) < ε ^ 3)]

/-- **The two-loop correction pushes the fixed-point coupling up.**  For every
`N ≥ 0` and `0 < ε ≤ 4/7` the predicted two-loop coupling strictly exceeds the
one-loop Wilson–Fisher coupling. -/
theorem twoLoop_exceeds_oneLoop {N ε : ℝ} (hN : 0 ≤ N) (hε : 0 < ε) :
    3 * ε / (N + 8) < fixedPointTwoLoop N (twoLoopCoeff N) ε := by
  have ht : (0:ℝ) < N + 8 := by linarith
  unfold fixedPointTwoLoop twoLoopCoeff
  have : 0 < 27 * ((3 * N + 14) / 9) * ε ^ 2 / (N + 8) ^ 3 := by
    apply div_pos (by nlinarith) (by positivity)
  linarith

end ONModel