import Mathlib
import Catalog.NumberTheory.ProfileFormPowerLaw

/-!
# Profile form IV: the exponent-one threshold that the bootstrap straddles

Context (experiment 579, paper 229).  The fitted exponent of the positional
profile is `b ≈ 1.104` with cluster-bootstrap interval `b ∈ [0.991, 1.218]`.
That interval contains `1`, and `b = 1` is not an arbitrary number: it is the
exact threshold at which the total window mass of the profile changes from
divergent to finite.  Here we prove the threshold and then prove that the
measured interval genuinely straddles it, i.e. the experiment as it stands
cannot decide the qualitative question.

* `windowMass_eq` — closed form `∫₀^X (1+x)^(-b) dx = ((1+X)^(1-b) - 1)/(1-b)`
  for `b ≠ 1`;
* `windowMass_eq_log` — the harmonic case `b = 1` gives exactly `log (1+X)`;
* `windowMass_tendsto_finite` — for `b > 1` the total mass converges to
  `1/(b-1)`;
* `windowMass_tendsto_atTop` — for `b ≤ 1` it diverges;
* `exponent_bootstrap_straddles_threshold` — inside the bootstrap interval
  `[0.991, 1.218]` both behaviours occur;
* `harmonic_sum_ge_log` — the discrete counterpart: the harmonic hit counts of
  the critical profile `b = 1` dominate `log (n+1)`, so the divergence is
  visible already at the level of counted hits.
-/

namespace ProfileForm

open Real Filter Topology intervalIntegral

/-- Total profile mass accumulated across the window `[0, X]`, at unit
amplitude. -/
noncomputable def windowMass (b X : ℝ) : ℝ := ∫ x in (0:ℝ)..X, (1 + x) ^ (-b)

/-- Closed form of the window mass away from the critical exponent. -/
theorem windowMass_eq {b X : ℝ} (hb : b ≠ 1) (hX : 0 ≤ X) :
    windowMass b X = ((1 + X) ^ (1 - b) - 1) / (1 - b) := by
  have hb' : 1 - b ≠ 0 := sub_ne_zero.mpr (Ne.symm hb)
  have hderiv : ∀ x ∈ Set.uIcc (0:ℝ) X,
      HasDerivAt (fun x : ℝ => (1 + x) ^ (1 - b) / (1 - b)) ((1 + x) ^ (-b)) x := by
    intro x hx
    have hx0 : 0 ≤ x := by
      rcases Set.mem_uIcc.mp hx with h | h
      · exact h.1
      · linarith [h.1]
    have hne : (1 : ℝ) + x ≠ 0 := by positivity
    have h1 : HasDerivAt (fun x : ℝ => 1 + x) 1 x := by
      simpa using (hasDerivAt_id x).const_add 1
    have h2 := (h1.rpow_const (p := 1 - b) (Or.inl hne)).div_const (1 - b)
    have hsimp : 1 * (1 - b) * (1 + x) ^ (1 - b - 1) / (1 - b) = (1 + x) ^ (-b) := by
      rw [show (1 : ℝ) - b - 1 = -b by ring]
      field_simp
    rwa [hsimp] at h2
  have hint : IntervalIntegrable (fun x : ℝ => (1 + x) ^ (-b)) MeasureTheory.volume 0 X := by
    apply ContinuousOn.intervalIntegrable
    intro x hx
    have hx0 : 0 ≤ x := by
      rcases Set.mem_uIcc.mp hx with h | h
      · exact h.1
      · linarith [h.1]
    have hpos : (0:ℝ) < 1 + x := by linarith
    exact (Real.continuousAt_rpow_const _ _ (Or.inl (ne_of_gt hpos))).continuousWithinAt.comp
      (by fun_prop : ContinuousWithinAt (fun x : ℝ => 1 + x) (Set.uIcc 0 X) x)
      (fun y _ => Set.mem_univ _)
  rw [windowMass, integral_eq_sub_of_hasDerivAt hderiv hint]
  simp only [add_zero, Real.one_rpow]
  ring

/-- The critical exponent `b = 1` gives exactly the logarithm: harmonic
decline. -/
theorem windowMass_eq_log {X : ℝ} (hX : 0 ≤ X) :
    windowMass 1 X = Real.log (1 + X) := by
  have hderiv : ∀ x ∈ Set.uIcc (0:ℝ) X,
      HasDerivAt (fun x : ℝ => Real.log (1 + x)) ((1 + x) ^ (-(1:ℝ))) x := by
    intro x hx
    have hx0 : 0 ≤ x := by
      rcases Set.mem_uIcc.mp hx with h | h
      · exact h.1
      · linarith [h.1]
    have hpos : (0:ℝ) < 1 + x := by linarith
    have h1 : HasDerivAt (fun x : ℝ => 1 + x) 1 x := by
      simpa using (hasDerivAt_id x).const_add 1
    have h2 := h1.log (ne_of_gt hpos)
    rw [Real.rpow_neg_one]
    simpa using h2
  have hint : IntervalIntegrable (fun x : ℝ => (1 + x) ^ (-(1:ℝ)))
      MeasureTheory.volume 0 X := by
    apply ContinuousOn.intervalIntegrable
    intro x hx
    have hx0 : 0 ≤ x := by
      rcases Set.mem_uIcc.mp hx with h | h
      · exact h.1
      · linarith [h.1]
    have hpos : (0:ℝ) < 1 + x := by linarith
    exact (Real.continuousAt_rpow_const _ _ (Or.inl (ne_of_gt hpos))).continuousWithinAt.comp
      (by fun_prop : ContinuousWithinAt (fun x : ℝ => 1 + x) (Set.uIcc 0 X) x)
      (fun y _ => Set.mem_univ _)
  rw [windowMass, integral_eq_sub_of_hasDerivAt hderiv hint]
  simp

/-- **Supercritical exponents give finite total mass.** -/
theorem windowMass_tendsto_finite {b : ℝ} (hb : 1 < b) :
    Tendsto (windowMass b) atTop (𝓝 (1 / (b - 1))) := by
  have hb' : b ≠ 1 := ne_of_gt hb
  have hshift : Tendsto (fun X : ℝ => 1 + X) atTop atTop :=
    tendsto_atTop_add_const_left _ 1 tendsto_id
  have hrpow : Tendsto (fun X : ℝ => (1 + X) ^ (1 - b)) atTop (𝓝 0) := by
    have h0 : Tendsto (fun y : ℝ => y ^ (-(b - 1))) atTop (𝓝 0) :=
      tendsto_rpow_neg_atTop (by linarith)
    have := h0.comp hshift
    simpa [Function.comp, show -(b - 1) = 1 - b by ring] using this
  have heq : ∀ᶠ X : ℝ in atTop, windowMass b X = ((1 + X) ^ (1 - b) - 1) / (1 - b) := by
    filter_upwards [eventually_ge_atTop (0:ℝ)] with X hX using windowMass_eq hb' hX
  rw [tendsto_congr' heq]
  have hlim : Tendsto (fun X : ℝ => ((1 + X) ^ (1 - b) - 1) / (1 - b)) atTop
      (𝓝 ((0 - 1) / (1 - b))) := ((hrpow.sub tendsto_const_nhds).div_const _)
  have : (0 - 1) / (1 - b) = 1 / (b - 1) := by
    rw [show (0:ℝ) - 1 = -1 by ring, show (1:ℝ) - b = -(b - 1) by ring]
    field_simp
  rwa [this] at hlim

/-- **Subcritical and critical exponents give divergent total mass.** -/
theorem windowMass_tendsto_atTop {b : ℝ} (hb : b ≤ 1) :
    Tendsto (windowMass b) atTop atTop := by
  have hshift : Tendsto (fun X : ℝ => 1 + X) atTop atTop :=
    tendsto_atTop_add_const_left _ 1 tendsto_id
  rcases eq_or_lt_of_le hb with h | h
  · subst h
    have heq : ∀ᶠ X : ℝ in atTop, windowMass 1 X = Real.log (1 + X) := by
      filter_upwards [eventually_ge_atTop (0:ℝ)] with X hX using windowMass_eq_log hX
    rw [tendsto_congr' heq]
    exact Real.tendsto_log_atTop.comp hshift
  · have hb' : b ≠ 1 := ne_of_lt h
    have heq : ∀ᶠ X : ℝ in atTop, windowMass b X = ((1 + X) ^ (1 - b) - 1) / (1 - b) := by
      filter_upwards [eventually_ge_atTop (0:ℝ)] with X hX using windowMass_eq hb' hX
    rw [tendsto_congr' heq]
    have hrpow : Tendsto (fun X : ℝ => (1 + X) ^ (1 - b)) atTop atTop := by
      have h0 : Tendsto (fun y : ℝ => y ^ (1 - b)) atTop atTop :=
        tendsto_rpow_atTop (by linarith)
      exact h0.comp hshift
    have hpos : (0:ℝ) < 1 - b := by linarith
    exact ((hrpow.atTop_add tendsto_const_nhds).atTop_div_const hpos)

/-- **The bootstrap interval straddles the threshold.**  Within the measured
interval `[0.991, 1.218]` there are exponents whose total window mass diverges
and exponents whose total window mass converges: the experiment pins the shape
of the profile but not the finiteness of its total mass. -/
theorem exponent_bootstrap_straddles_threshold :
    (∃ b ∈ Set.Icc (0.991:ℝ) 1.218, Tendsto (windowMass b) atTop atTop) ∧
    (∃ b ∈ Set.Icc (0.991:ℝ) 1.218, ∃ L : ℝ, Tendsto (windowMass b) atTop (𝓝 L)) := by
  constructor
  · exact ⟨1, ⟨by norm_num, by norm_num⟩, windowMass_tendsto_atTop le_rfl⟩
  · exact ⟨1.104, ⟨by norm_num, by norm_num⟩, _, windowMass_tendsto_finite (by norm_num)⟩

/-! ## The discrete counterpart -/

/-- The counted-hit version of the critical profile: the harmonic sum dominates
`log (n+1)`, so the divergence at `b = 1` is already visible in the counts. -/
theorem harmonic_sum_ge_log (n : ℕ) :
    Real.log (n + 1) ≤ ∑ j ∈ Finset.range n, (1 : ℝ) / (j + 1) := by
  induction n with
  | zero => simp
  | succ n ih =>
      have hpos : (0:ℝ) < n + 1 := by positivity
      have hstep : Real.log ((n : ℝ) + 1 + 1) - Real.log ((n : ℝ) + 1) ≤ 1 / (n + 1) := by
        have hratio : Real.log (((n : ℝ) + 2) / ((n : ℝ) + 1)) ≤ ((n : ℝ) + 2) / ((n : ℝ) + 1) - 1 :=
          Real.log_le_sub_one_of_pos (by positivity)
        have hsplit : Real.log (((n : ℝ) + 2) / ((n : ℝ) + 1))
            = Real.log ((n : ℝ) + 2) - Real.log ((n : ℝ) + 1) :=
          Real.log_div (by positivity) (by positivity)
        have harith : ((n : ℝ) + 2) / ((n : ℝ) + 1) - 1 = 1 / ((n : ℝ) + 1) := by
          field_simp
          ring
        rw [hsplit, harith] at hratio
        have : ((n : ℝ) + 1 + 1) = (n : ℝ) + 2 := by ring
        rw [this]
        exact hratio
      have hrec : ∑ j ∈ Finset.range (n + 1), (1 : ℝ) / (j + 1)
          = (∑ j ∈ Finset.range n, (1 : ℝ) / (j + 1)) + 1 / ((n : ℝ) + 1) := by
        rw [Finset.sum_range_succ]
      rw [hrec]
      push_cast
      linarith

end ProfileForm