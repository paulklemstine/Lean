import Mathlib
import Probability.PositionalRateLinkHarmonic

/-!
# Window-ratio identifiability from the edge decile (paper 230, follow-up direction 4)

`PositionalRateLinkHarmonic.lean` proves that the positional layer of the
exp-578/580 data is a harmonic (`1/x`) law, that it depends on the *window
ratio* `r` alone, and that its leading decile always carries strictly more than
one tenth of the hits (`edge_decile_excess`).  The round-80 analysis then tested
the null "the three hit-count terciles share one positional law" as a *difference*
test, and failed to reject it.

This file supplies the missing ingredient that turns that failure to reject into
a positive, parameter-based statement: **the window ratio is identifiable from a
single number, the edge-decile mass.**

Main results (for a fixed window fraction `u ∈ (0,1)`):

* `PositionalRateLink.harmCDF_ratio_strictMonoOn` — `r ↦ harmCDF r u` is
  strictly increasing on `(1, ∞)`.  The proof runs through the derivative, whose
  positivity is exactly **strict convexity of `x ↦ x log x`** evaluated at the
  convex combination `1 + (r-1)u = u·r + (1-u)·1`.
* `PositionalRateLink.harmCDF_ratio_injOn` — hence injective: no two window
  ratios produce the same leading-fraction mass.
* `PositionalRateLink.harmCDF_ratio_mem_Ioo` — the mass always lies strictly
  between the uniform value `u` and `1`.
* `PositionalRateLink.harmCDF_ratio_surjOn`, `harmCDF_ratio_bijOn` — every value
  in `(u, 1)` is attained, by an *explicitly bracketed* ratio (no limit theorems
  are used: the two brackets come from `log(1+x) ≤ x`, `log r ≥ 1 - 1/r` on one
  side and from `1 + (r-1)u > r·u` on the other).
* `PositionalRateLink.exists_unique_window_ratio` — the inversion statement:
  each observed leading-fraction mass in `(u,1)` comes from exactly one window
  ratio.
* `PositionalRateLink.edge_decile_identifies_ratio` and
  `PositionalRateLink.edge_decile_eq_iff_ratio_eq` — specialised to the edge
  decile `u = 1/10`: an observed edge-decile mass `m ∈ (1/10, 1)` determines the
  window ratio uniquely, and two rate strata have equal edge-decile masses **iff**
  they have equal window ratios.  The exp-580 null hypothesis is therefore an
  equivalence statement about one identified parameter, not a 49-degree-of-freedom
  difference test.
-/

open Finset Real Set

namespace PositionalRateLink

/-! ### Strict monotonicity in the window ratio -/

/-- **Strict convexity of `x ↦ x log x` at the window interpolation.**  Writing
`A = 1 + (r-1)u = u·r + (1-u)·1` for the right endpoint of the leading
`u`-fraction of a window of ratio `r`, we have `A log A < u · (r log r)`.  This
single inequality is what makes the window ratio identifiable. -/
theorem mul_log_window_lt {r u : ℝ} (hr : 1 < r) (hu0 : 0 < u) (hu1 : u < 1) :
    (1 + (r - 1) * u) * Real.log (1 + (r - 1) * u) < u * (r * Real.log r) := by
  have h1 : (1 : ℝ) ∈ Set.Ici (0 : ℝ) := by norm_num
  have h2 : r ∈ Set.Ici (0 : ℝ) := by simp; linarith
  have hne : (1 : ℝ) ≠ r := by linarith
  have h := Real.strictConvexOn_mul_log.2 h1 h2 hne
      (show (0 : ℝ) < 1 - u by linarith) hu0 (show (1 - u) + u = 1 by ring)
  simp only [smul_eq_mul] at h
  have hA : (1 - u) * 1 + u * r = 1 + (r - 1) * u := by ring
  rw [hA] at h
  simpa using h

/-- The derivative of `r ↦ harmCDF r u` at a ratio `r > 1`. -/
theorem harmCDF_hasDerivAt_ratio {r u : ℝ} (hr : 1 < r) (hu0 : 0 < u) :
    HasDerivAt (fun s : ℝ => harmCDF s u)
      ((u / (1 + (r - 1) * u) * Real.log r - Real.log (1 + (r - 1) * u) * (1 / r))
        / (Real.log r) ^ 2) r := by
  have hr0 : (0 : ℝ) < r := by linarith
  have hlogr : Real.log r ≠ 0 := (Real.log_pos hr).ne'
  have hA : (0 : ℝ) < 1 + (r - 1) * u := by nlinarith
  have h1 : HasDerivAt (fun s : ℝ => 1 + (s - 1) * u) u r := by
    simpa using (((hasDerivAt_id r).sub_const 1).mul_const u).const_add 1
  have h2 : HasDerivAt (fun s : ℝ => Real.log (1 + (s - 1) * u)) (u / (1 + (r - 1) * u)) r := by
    simpa [div_eq_mul_inv] using h1.log hA.ne'
  have h3 : HasDerivAt Real.log (1 / r) r := by
    simpa [one_div] using Real.hasDerivAt_log hr0.ne'
  simpa [harmCDF] using h2.div h3 hlogr

/-- Positivity of that derivative, for a genuine interior fraction `0 < u < 1`. -/
theorem harmCDF_deriv_ratio_pos {r u : ℝ} (hr : 1 < r) (hu0 : 0 < u) (hu1 : u < 1) :
    0 < (u / (1 + (r - 1) * u) * Real.log r - Real.log (1 + (r - 1) * u) * (1 / r))
      / (Real.log r) ^ 2 := by
  have hA : (0 : ℝ) < 1 + (r - 1) * u := by nlinarith
  have hr0 : (0 : ℝ) < r := by linarith
  have hlogr : 0 < Real.log r := Real.log_pos hr
  have key := mul_log_window_lt hr hu0 hu1
  apply div_pos _ (by positivity)
  rw [sub_pos, div_mul_eq_mul_div, mul_one_div, div_lt_div_iff₀ hr0 hA]
  nlinarith [key]

/-- **Monotonicity in the window ratio.**  For a fixed leading fraction
`u ∈ (0,1)`, a wider window (larger ratio `r`) always concentrates strictly more
mass in that leading fraction. -/
theorem harmCDF_ratio_strictMonoOn {u : ℝ} (hu0 : 0 < u) (hu1 : u < 1) :
    StrictMonoOn (fun r : ℝ => harmCDF r u) (Set.Ioi 1) := by
  refine strictMonoOn_of_deriv_pos (convex_Ioi 1) (fun r hr => ?_) (fun r hr => ?_)
  · exact ((harmCDF_hasDerivAt_ratio (u := u) hr hu0).continuousAt).continuousWithinAt
  · rw [interior_Ioi] at hr
    rw [(harmCDF_hasDerivAt_ratio (u := u) hr hu0).deriv]
    exact harmCDF_deriv_ratio_pos hr hu0 hu1

/-- **Injectivity: the window ratio is identifiable.** -/
theorem harmCDF_ratio_injOn {u : ℝ} (hu0 : 0 < u) (hu1 : u < 1) :
    Set.InjOn (fun r : ℝ => harmCDF r u) (Set.Ioi 1) :=
  (harmCDF_ratio_strictMonoOn hu0 hu1).injOn

/-! ### The exact range of attainable masses -/

/-- Upper bound used to bracket small masses: `harmCDF r u ≤ u · r`. -/
theorem harmCDF_le_mul_ratio {r u : ℝ} (hr : 1 < r) (hu0 : 0 < u) : harmCDF r u ≤ u * r := by
  have hA : (0 : ℝ) < 1 + (r - 1) * u := by nlinarith
  have hr0 : (0 : ℝ) < r := by linarith
  have hlogr : 0 < Real.log r := Real.log_pos hr
  have h1 : Real.log (1 + (r - 1) * u) ≤ (r - 1) * u := by
    have := Real.log_le_sub_one_of_pos hA; linarith
  have h2 : (r - 1) / r ≤ Real.log r := by
    have h := Real.log_le_sub_one_of_pos (show (0 : ℝ) < 1 / r by positivity)
    rw [Real.log_div one_ne_zero hr0.ne', Real.log_one] at h
    have hh : (r - 1) / r = 1 - 1 / r := by field_simp
    rw [hh]; linarith
  have h3 : u * r * ((r - 1) / r) ≤ u * r * Real.log r :=
    mul_le_mul_of_nonneg_left h2 (by positivity)
  have heq : u * r * ((r - 1) / r) = (r - 1) * u := by field_simp
  rw [heq] at h3
  rw [harmCDF, div_le_iff₀ hlogr]
  linarith

/-- Lower bound used to bracket large masses: `harmCDF r u > 1 + log u / log r`. -/
theorem harmCDF_gt_one_add_log_div {r u : ℝ} (hr : 1 < r) (hu0 : 0 < u) (hu1 : u < 1) :
    1 + Real.log u / Real.log r < harmCDF r u := by
  have hlogr : 0 < Real.log r := Real.log_pos hr
  have hru : (0 : ℝ) < r * u := by nlinarith
  have hlt : r * u < 1 + (r - 1) * u := by nlinarith
  have h := Real.log_lt_log hru hlt
  rw [Real.log_mul (by linarith) hu0.ne'] at h
  rw [harmCDF, lt_div_iff₀ hlogr]
  field_simp
  linarith

/-- Every attainable mass lies strictly between the uniform value `u` and `1`. -/
theorem harmCDF_ratio_mem_Ioo {r u : ℝ} (hr : 1 < r) (hu0 : 0 < u) (hu1 : u < 1) :
    harmCDF r u ∈ Set.Ioo u 1 := by
  refine ⟨harmCDF_gt_id hr hu0 hu1, ?_⟩
  have hlogr : 0 < Real.log r := Real.log_pos hr
  have hA : (0 : ℝ) < 1 + (r - 1) * u := by nlinarith
  have hlt : 1 + (r - 1) * u < r := by nlinarith
  have := Real.log_lt_log hA hlt
  rw [harmCDF, div_lt_one hlogr]
  exact this

/-- **Surjectivity onto `(u,1)`.**  Every mass strictly between the uniform value
and `1` is realised by some window ratio; the witness is found by the
intermediate value theorem between two explicit brackets. -/
theorem harmCDF_ratio_surjOn {u : ℝ} (hu0 : 0 < u) (hu1 : u < 1) :
    Set.Ioo u 1 ⊆ (fun r : ℝ => harmCDF r u) '' Set.Ioi 1 := by
  rintro y ⟨hyu, hy1⟩
  -- lower bracket
  set r₁ : ℝ := (1 + y / u) / 2 with hr₁def
  have hyu' : 1 < y / u := (one_lt_div hu0).2 hyu
  have hr₁ : 1 < r₁ := by rw [hr₁def]; linarith
  have hfr₁ : harmCDF r₁ u < y := by
    have h := harmCDF_le_mul_ratio hr₁ hu0
    have : u * r₁ = (u + y) / 2 := by
      rw [hr₁def]; field_simp
    rw [this] at h
    linarith
  -- upper bracket
  set r₂ : ℝ := Real.exp ((-Real.log u) / (1 - y) + 1) with hr₂def
  have hlogu : Real.log u < 0 := Real.log_neg hu0 hu1
  have hexp : 0 < (-Real.log u) / (1 - y) + 1 := by
    have : 0 < (-Real.log u) / (1 - y) := div_pos (by linarith) (by linarith)
    linarith
  have hr₂ : 1 < r₂ := by
    rw [hr₂def]
    calc (1 : ℝ) = Real.exp 0 := by simp
      _ < _ := Real.exp_lt_exp.2 hexp
  have hlogr₂ : Real.log r₂ = (-Real.log u) / (1 - y) + 1 := by
    rw [hr₂def, Real.log_exp]
  have hlogr₂pos : 0 < Real.log r₂ := Real.log_pos hr₂
  have hfr₂ : y < harmCDF r₂ u := by
    have hkey : y < 1 + Real.log u / Real.log r₂ := by
      have hgt : (-Real.log u) / (1 - y) < Real.log r₂ := by rw [hlogr₂]; linarith
      rw [div_lt_iff₀ (show (0:ℝ) < 1 - y by linarith)] at hgt
      have h3 : y - 1 < Real.log u / Real.log r₂ := by
        rw [lt_div_iff₀ hlogr₂pos]; nlinarith
      linarith
    exact lt_trans hkey (harmCDF_gt_one_add_log_div hr₂ hu0 hu1)
  -- intermediate value theorem
  have hr₁₂ : r₁ ≤ r₂ := by
    by_contra hcon
    push_neg at hcon
    have := harmCDF_ratio_strictMonoOn hu0 hu1 (Set.mem_Ioi.2 hr₂) (Set.mem_Ioi.2 hr₁) hcon
    simp only at this
    linarith
  have hcont : ContinuousOn (fun s : ℝ => harmCDF s u) (Set.Icc r₁ r₂) := by
    intro s hs
    have hs1 : 1 < s := lt_of_lt_of_le hr₁ hs.1
    exact ((harmCDF_hasDerivAt_ratio (u := u) hs1 hu0).continuousAt).continuousWithinAt
  have hmem : y ∈ Set.Icc (harmCDF r₁ u) (harmCDF r₂ u) := ⟨le_of_lt hfr₁, le_of_lt hfr₂⟩
  obtain ⟨r, hrmem, hry⟩ := intermediate_value_Icc hr₁₂ hcont hmem
  exact ⟨r, Set.mem_Ioi.2 (lt_of_lt_of_le hr₁ hrmem.1), hry⟩

/-- **The window ratio parametrises the leading-fraction masses bijectively.** -/
theorem harmCDF_ratio_bijOn {u : ℝ} (hu0 : 0 < u) (hu1 : u < 1) :
    Set.BijOn (fun r : ℝ => harmCDF r u) (Set.Ioi 1) (Set.Ioo u 1) :=
  ⟨fun _ hr => harmCDF_ratio_mem_Ioo (Set.mem_Ioi.1 hr) hu0 hu1,
    harmCDF_ratio_injOn hu0 hu1, harmCDF_ratio_surjOn hu0 hu1⟩

/-- **Inversion.**  An observed leading-fraction mass `y ∈ (u,1)` determines the
window ratio uniquely. -/
theorem exists_unique_window_ratio {u y : ℝ} (hu0 : 0 < u) (hu1 : u < 1)
    (hy : y ∈ Set.Ioo u 1) : ∃! r : ℝ, 1 < r ∧ harmCDF r u = y := by
  obtain ⟨r, hr, hry⟩ := harmCDF_ratio_surjOn hu0 hu1 hy
  refine ⟨r, ⟨Set.mem_Ioi.1 hr, hry⟩, ?_⟩
  rintro s ⟨hs, hsy⟩
  exact harmCDF_ratio_injOn hu0 hu1 (Set.mem_Ioi.2 hs) hr (by simpa using hsy.trans hry.symm)

/-! ### Specialisation to the edge decile -/

/-- The edge-decile mass is precisely the leading-tenth mass. -/
theorem decileMass_zero (r : ℝ) : decileMass r 0 = harmCDF r (1 / 10) := by
  simp [decileMass]

/-- **The edge decile identifies the window ratio.**  Any edge-decile mass
strictly between the uniform value `1/10` and `1` is produced by exactly one
window ratio `r > 1`.  This is the positive counterpart of the exp-580 null: the
three terciles report `0.229 / 0.245 / 0.230`, each of which pins down a ratio. -/
theorem edge_decile_identifies_ratio {m : ℝ} (hm0 : 1 / 10 < m) (hm1 : m < 1) :
    ∃! r : ℝ, 1 < r ∧ decileMass r 0 = m := by
  have h := exists_unique_window_ratio (u := 1 / 10) (y := m) (by norm_num) (by norm_num)
    ⟨hm0, hm1⟩
  obtain ⟨r, ⟨hr, hrm⟩, huniq⟩ := h
  refine ⟨r, ⟨hr, by rw [decileMass_zero]; exact hrm⟩, ?_⟩
  rintro s ⟨hs, hsm⟩
  exact huniq s ⟨hs, by rw [← decileMass_zero]; exact hsm⟩

/-- **Equivalence form of the exp-580 null hypothesis.**  Two rate strata
(hit-poor versus hit-rich terciles, say), each following a harmonic positional
law, have the same edge-decile mass **iff** they have the same window ratio.  A
failure to reject a difference in the edge decile is therefore, under the
harmonic law, exactly a statement about a single identified parameter. -/
theorem edge_decile_eq_iff_ratio_eq {r s : ℝ} (hr : 1 < r) (hs : 1 < s) :
    decileMass r 0 = decileMass s 0 ↔ r = s := by
  constructor
  · intro h
    rw [decileMass_zero, decileMass_zero] at h
    exact harmCDF_ratio_injOn (u := 1 / 10) (by norm_num) (by norm_num)
      (Set.mem_Ioi.2 hr) (Set.mem_Ioi.2 hs) h
  · rintro rfl; rfl

/-- Monotone comparison of terciles: a strictly larger edge-decile mass means a
strictly wider scan window, never a different positional law. -/
theorem edge_decile_lt_iff_ratio_lt {r s : ℝ} (hr : 1 < r) (hs : 1 < s) :
    decileMass r 0 < decileMass s 0 ↔ r < s := by
  rw [decileMass_zero, decileMass_zero]
  constructor
  · intro h
    by_contra hcon
    push_neg at hcon
    rcases eq_or_lt_of_le hcon with heq | hlt
    · rw [heq] at h; exact lt_irrefl _ h
    · exact absurd (harmCDF_ratio_strictMonoOn (u := 1 / 10) (by norm_num) (by norm_num)
        (Set.mem_Ioi.2 hs) (Set.mem_Ioi.2 hr) hlt) (by simpa using not_lt.2 h.le)
  · intro h
    exact harmCDF_ratio_strictMonoOn (u := 1 / 10) (by norm_num) (by norm_num)
      (Set.mem_Ioi.2 hr) (Set.mem_Ioi.2 hs) h

end PositionalRateLink