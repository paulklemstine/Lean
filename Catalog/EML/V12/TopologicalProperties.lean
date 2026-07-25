import Mathlib

/-! # CatalogBuild.EML.V12.TopologicalProperties

Auto-generated from theorem catalog database.
Domain: EML/V12
Declarations: 12
-/

noncomputable section

/-- eml is continuous on ℝ × (0,∞). -/
theorem eml_continuousOn_joint :
    ContinuousOn (fun p : ℝ × ℝ => eml p.1 p.2) (Set.univ ×ˢ Set.Ioi 0) := by
  unfold eml
  apply ContinuousOn.sub
  · exact (Real.continuous_exp.comp continuous_fst).continuousOn
  · exact (Real.continuousOn_log.comp continuousOn_snd
      (fun ⟨_, y⟩ hy => ne_of_gt (Set.mem_prod.mp hy).2))

/-- Preimage of (c, ∞) under eml(·, y). -/
theorem eml_preimage_Ioi (y c : ℝ) (h : c + Real.log y > 0) :
    (fun x => eml x y) ⁻¹' (Set.Ioi c) = Set.Ioi (Real.log (c + Real.log y)) := by
  ext x; simp only [Set.mem_preimage, Set.mem_Ioi]; unfold eml
  constructor
  · intro hx -- c < exp(x) - log(y) means exp(x) > c + log(y) > 0
    have h1 : Real.exp x > c + Real.log y := by linarith
    rwa [← Real.exp_lt_exp, Real.exp_log h]
  · intro hx
    have := Real.exp_lt_exp.mpr hx
    rw [Real.exp_log h] at this
    linarith

/-- Preimage of {c} under eml(·, y) is a singleton. -/
theorem eml_preimage_singleton (y c : ℝ) (h : c + Real.log y > 0) :
    (fun x => eml x y) ⁻¹' {c} = {Real.log (c + Real.log y)} := by
  ext x; simp only [Set.mem_preimage, Set.mem_singleton_iff]; unfold eml
  constructor
  · intro hx
    have : Real.exp x = c + Real.log y := by linarith
    rw [← Real.log_exp x, this]
  · intro hx
    rw [hx, Real.exp_log h]; ring

/-- Level set equation: eml(x, exp(exp(x) − c)) = c. -/
theorem eml_level_set_graph (c : ℝ) :
    ∀ x : ℝ, eml x (Real.exp (Real.exp x - c)) = c := by
  intro x; unfold eml; rw [Real.log_exp]; ring

/-- Level curves are graphs of continuous functions. -/
theorem eml_level_curve_continuous (c : ℝ) :
    Continuous (fun x => Real.exp (Real.exp x - c)) :=
  Real.continuous_exp.comp (Real.continuous_exp.sub continuous_const)

/-- Level curve values are always positive. -/
theorem eml_level_curve_pos (c x : ℝ) :
    Real.exp (Real.exp x - c) > 0 := Real.exp_pos _

/-- Level curves are strictly increasing. -/
theorem eml_level_curve_strictMono (c : ℝ) :
    StrictMono (fun x => Real.exp (Real.exp x - c)) := by
  intro a b hab
  exact Real.exp_strictMono (by linarith [Real.exp_lt_exp.mpr hab])

/-- σ → +∞ as x → +∞. -/
theorem emlSelfPair_tendsto_atTop :
    Tendsto emlSelfPair atTop atTop := by
  rw [Filter.tendsto_atTop]; intro b
  filter_upwards [Filter.Ioi_mem_atTop (2 * (|b| + 1))] with x hx
  unfold emlSelfPair; simp only [Set.mem_Ioi] at hx
  have hx0 : x > 0 := by linarith [abs_nonneg b]
  have h := Real.sum_le_exp_of_nonneg (le_of_lt hx0) 3
  simp [Finset.sum_range_succ] at h
  nlinarith [le_abs_self b, sq_nonneg (x - 2), abs_nonneg b]

/-- σ → +∞ as x → −∞. -/
theorem emlSelfPair_tendsto_atBot :
    Tendsto emlSelfPair atBot atTop := by
  rw [Filter.tendsto_atTop]; intro b
  filter_upwards [Filter.Iio_mem_atBot (-(b + 1))] with x hx
  unfold emlSelfPair; simp only [Set.mem_Iio] at hx
  linarith [Real.exp_pos x]

/-- The range of σ is [1, ∞). -/
theorem emlSelfPair_range : Set.range emlSelfPair = Set.Ici 1 := by
  ext c; simp only [Set.mem_range, Set.mem_Ici]
  constructor
  · rintro ⟨x, rfl⟩; unfold emlSelfPair; linarith [Real.add_one_le_exp x]
  · intro hc
    have h0 : emlSelfPair 0 = 1 := by unfold emlSelfPair; simp
    -- For c = 1, use x = 0
    by_cases hc1 : c = 1
    · exact ⟨0, by rw [h0, hc1]⟩
    · -- For c > 1, by IVT: σ(0) = 1 < c ≤ σ(c) (since σ(c) ≥ 1+c²/2... actually σ(c) ≥ 1)
      -- Use σ is continuous, σ(0) = 1, σ → ∞
      have hc1' : c > 1 := lt_of_le_of_ne hc (Ne.symm hc1)
      -- σ(c) = exp(c) - c ≥ exp(1)·exp(c-1) - c
      -- For large enough x, σ(x) > c. Take x = c:
      -- σ(c) = exp(c) - c. Is this ≥ c? Need exp(c) ≥ 2c.
      -- Not necessarily for small c > 1. Use x = max c 2 instead.
      -- Actually just use IVT with σ continuous, σ(0) = 1 < c, and find large x with σ(x) ≥ c
      have : ∃ x₀ : ℝ, emlSelfPair x₀ ≥ c := by
        use c; unfold emlSelfPair
        have h3 := Real.sum_le_exp_of_nonneg (show (0:ℝ) ≤ c by linarith) 3
        simp [Finset.sum_range_succ] at h3; nlinarith [sq_nonneg (c - 1)]
      obtain ⟨x₀, hx₀⟩ := this
      have h_ivt := @intermediate_value_uIcc ℝ _ _ _ _ ℝ _ _ _ 0 x₀ emlSelfPair
        emlSelfPair_continuous.continuousOn
      have h0c : c ∈ Set.uIcc (emlSelfPair 0) (emlSelfPair x₀) := by
        rw [h0]; exact Set.mem_uIcc.mpr (Or.inl ⟨hc, hx₀⟩)
      obtain ⟨t, _, ht⟩ := h_ivt h0c
      exact ⟨t, ht⟩

/-- The sublevel set {x | σ(x) ≤ c} is bounded for c ≥ 1. -/
theorem emlSelfPair_sublevel_bounded (c : ℝ) (hc : 1 ≤ c) :
    ∃ M : ℝ, ∀ x : ℝ, emlSelfPair x ≤ c → |x| ≤ M := by
  use c + 1
  intro x hx
  unfold emlSelfPair at hx
  rw [abs_le]; constructor
  · linarith [Real.exp_pos x]
  · -- Need x ≤ c + 1. From exp(x) - x ≤ c, so exp(x) ≤ x + c.
    -- For x > c + 1: exp(x) > exp(c+1) ≥ 1 + c + 1 = c + 2 > x + c (if x > c+1, contradiction)
    -- Actually: exp(x) ≥ 1 + x, so 1 + x ≤ exp(x) ≤ x + c, giving 1 ≤ c. Need more.
    -- exp(x) ≤ x + c. If x > c + 1, then exp(x) ≥ exp(c+1) > c + 2 > (c+1) + c... not quite.
    -- Better: exp(x) ≥ 1 + x, and exp(x) ≤ x + c gives 1 + x ≤ x + c, which is 1 ≤ c. OK.
    -- For sharper: exp(x) ≥ 1 + x + x²/2 for x ≥ 0. Then x²/2 ≤ c - 1, x ≤ √(2(c-1)).
    -- For x ≤ 0: trivially x ≤ 0 ≤ c + 1.
    -- For x > 0: exp(x) ≤ x + c. Also exp(x) > x (for x > 0). So x + c > x → c > 0 ✓.
    -- Need to show x ≤ c + 1.
    by_contra h
    push_neg at h
    have hx0 : x > 0 := by linarith
    -- exp(x) > exp(c+1) ≥ 1 + (c+1) = c + 2 and exp(x) ≤ x + c
    -- So x + c ≥ exp(x) ≥ 1 + x, giving c ≥ 1 ✓
    -- Also exp(x) ≥ 1 + x + x²/2
    have := Real.add_one_le_exp x
    -- exp(x) ≤ x + c but exp(x) ≥ 1 + x so 1 + x ≤ x + c → 1 ≤ c
    -- This doesn't help directly. Let me use sum_le_exp:
    have h3 := Real.sum_le_exp_of_nonneg (le_of_lt hx0) 3
    simp [Finset.sum_range_succ] at h3
    -- h3: 1 + x + x²/2 ≤ exp(x)
    -- hx: exp(x) ≤ x + c
    -- So 1 + x + x²/2 ≤ x + c → 1 + x²/2 ≤ c → x² ≤ 2(c-1)
    -- x > c + 1 → x² > (c+1)² = c² + 2c + 1
    -- Need c² + 2c + 1 > 2c - 2 → c² + 3 > 0. Always true!
    -- So x² > (c+1)² > 2(c-1) = 2c-2 (when c ≥ 1, (c+1)² ≥ 4 > 2c-2 for c ≤ 3, and for c > 3, (c+1)² > 2c)
    -- More directly: x²/2 > (c+1)²/2 = c²/2 + c + 1/2
    -- And c²/2 + c + 1/2 ≥ c for c ≥ 0 (since c²/2 + 1/2 ≥ 0). So x²/2 > c.
    -- But we need 1 + x²/2 ≤ c, contradiction since x²/2 > c gives 1 + x²/2 > c + 1 > c.
    nlinarith [sq_nonneg x, sq_nonneg (x - 1)]

/-- The sublevel set {x | σ(x) ≤ c} is closed. -/
theorem emlSelfPair_sublevel_closed (c : ℝ) :
    IsClosed {x : ℝ | emlSelfPair x ≤ c} :=
  isClosed_le emlSelfPair_continuous continuous_const

end