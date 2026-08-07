/-
  Focusing with a quantitative energy *shortfall*.

  `MyersFocusing.myers_domain_bound` needs the strict energy condition `Ric(k,k) ≥ ε`
  *pointwise*: a single instant of weaker curvature destroys the hypothesis, even though
  physically a brief, mild violation should only delay the focal point a little.
  `AveragedEnergyFocusing.anec_domain_bound` removes the pointwise requirement, but its
  statement is parametrized by an abstract defect budget at a free scale `a`.

  This file makes the trade-off explicit by choosing the natural scale `a = √(mε)`, at
  which the defect rate becomes the *pointwise shortfall* `(ε - Ric(k,k))⁺`.  With
  `D = ∫ (ε - Ric)⁺` the total shortfall along the geodesic,

      L ≤ π √(m/ε) + D / ε.

  The correction is linear in the shortfall with the sharp dimensional factor `1/ε`, and
  for `D = 0` — i.e. under the pointwise condition `Ric ≥ ε` — it collapses exactly to the
  Bonnet–Myers/Hawking bound (`shortfall_bound_recovers_myers`).  A localized violation of
  depth `c` and duration `τ` has `D ≤ (ε + c) τ`, so it postpones focusing by at most
  `(1 + c/ε) τ` (`localized_violation_bound`): the singularity theorem is *stable* under
  bounded energy-condition violations, and only the accumulated shortfall matters.
-/

import Physics.Spacetime.AveragedEnergyFocusing

open Set MeasureTheory

namespace Catalog.Physics.Spacetime

section Shortfall

variable {m eps L : ℝ} {θ θ' r : ℝ → ℝ}

/-- The pointwise energy shortfall `(ε - Ric(k,k))⁺` against the reference level `ε`. -/
noncomputable def energyShortfall (eps : ℝ) (r : ℝ → ℝ) : ℝ → ℝ :=
  fun s => max 0 (eps - r s)

theorem energyShortfall_nonneg (eps : ℝ) (r : ℝ → ℝ) (s : ℝ) :
    0 ≤ energyShortfall eps r s := le_max_left _ _

theorem continuous_energyShortfall {eps : ℝ} {r : ℝ → ℝ} (hr : Continuous r) :
    Continuous (energyShortfall eps r) :=
  continuous_const.max (continuous_const.sub hr)

/-- Under the pointwise condition `Ric ≥ ε` the shortfall vanishes identically. -/
theorem energyShortfall_eq_zero_of_le {eps : ℝ} {r : ℝ → ℝ} {s : ℝ} (h : eps ≤ r s) :
    energyShortfall eps r s = 0 := by
  unfold energyShortfall
  exact max_eq_left (by linarith)

/-- **Focusing bound with an energy shortfall.**  Let the expansion obey
`θ' ≤ -θ²/m - r` with `r = Ric(k,k)` continuous, and let the accumulated shortfall of `r`
below the level `ε > 0` never exceed `D`.  Then the affine length satisfies

    L ≤ π √(m/ε) + D/ε.

No pointwise sign condition on `r` is assumed: the curvature may be arbitrarily negative,
provided the *total* shortfall stays bounded. -/
theorem myers_bound_with_shortfall (hm : 0 < m) (he : 0 < eps) {D : ℝ}
    (hd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt θ (θ' x) x)
    (hrcont : Continuous r)
    (hineq : ∀ x ∈ Ico (0 : ℝ) L, θ' x ≤ -(θ x) ^ 2 / m - r x)
    (hbudget : ∀ x ∈ Ico (0 : ℝ) L, (∫ s in (0 : ℝ)..x, energyShortfall eps r s) ≤ D)
    (hL : 0 < L) :
    L ≤ Real.pi * Real.sqrt (m / eps) + D / eps := by
  set a : ℝ := Real.sqrt (m * eps) with ha
  have hapos : 0 < a := Real.sqrt_pos.2 (by positivity)
  have hasq : a ^ 2 = m * eps := Real.sq_sqrt (by positivity)
  have haem : a ^ 2 / m = eps := by
    rw [hasq]
    field_simp
  have hbound := anec_domain_bound_integral (m := m) (a := a) (L := L) (Dmax := D)
    (θ := θ) (θ' := θ') (r := r) (q := energyShortfall eps r) hm hapos hd
    (continuous_energyShortfall hrcont) hineq ?_ (fun x _ => energyShortfall_nonneg eps r x)
    hbudget hL
  · -- rewrite the scale-`a` bound in terms of `π √(m/ε)` and `D/ε`
    have hpi : m / a * Real.pi = Real.pi * Real.sqrt (m / eps) := by
      rw [Real.sqrt_div' m he.le, ha, Real.sqrt_mul hm.le]
      have hm0 : Real.sqrt m ≠ 0 := ne_of_gt (Real.sqrt_pos.2 hm)
      have he0 : Real.sqrt eps ≠ 0 := ne_of_gt (Real.sqrt_pos.2 he)
      field_simp
      exact (Real.sq_sqrt hm.le).symm
    have hD : m / a * (D / a) = D / eps := by
      rw [div_mul_div_comm, ← sq, hasq]
      field_simp
    have hsplit : m / a * (Real.pi + D / a) = m / a * Real.pi + m / a * (D / a) := by ring
    rw [hsplit, hpi, hD] at hbound
    exact hbound
  · intro x _
    rw [haem]
    exact le_max_right _ _

/-- **Consistency.**  Under the pointwise strict energy condition the shortfall is `0` and
the bound is exactly the Bonnet–Myers/Hawking length `π √(m/ε)`. -/
theorem shortfall_bound_recovers_myers (hm : 0 < m) (he : 0 < eps)
    (hd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt θ (θ' x) x)
    (hrcont : Continuous r)
    (hineq : ∀ x ∈ Ico (0 : ℝ) L, θ' x ≤ -(θ x) ^ 2 / m - r x)
    (hr : ∀ s : ℝ, eps ≤ r s) (hL : 0 < L) :
    L ≤ Real.pi * Real.sqrt (m / eps) := by
  have hzero : ∀ x : ℝ, (∫ s in (0 : ℝ)..x, energyShortfall eps r s) = 0 := by
    intro x
    have : ∀ s : ℝ, energyShortfall eps r s = 0 := fun s =>
      energyShortfall_eq_zero_of_le (hr s)
    simp [this]
  have h := myers_bound_with_shortfall (D := 0) hm he hd hrcont hineq
    (fun x _ => by rw [hzero x]) hL
  simpa using h

/-- **A localized violation only delays focusing.**  Suppose the strict energy condition
`Ric ≥ ε` holds outside a window `[t₁, t₂]` of duration `τ = t₂ - t₁`, inside which the
curvature is merely bounded below by `-c`.  Then the total shortfall is at most
`(ε + c) τ`, and the affine length obeys

    L ≤ π √(m/ε) + (1 + c/ε) τ,

so the focusing conclusion survives any violation of finite duration and finite depth. -/
theorem localized_violation_bound (hm : 0 < m) (he : 0 < eps) {c t1 t2 : ℝ}
    (hd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt θ (θ' x) x)
    (hrcont : Continuous r)
    (hineq : ∀ x ∈ Ico (0 : ℝ) L, θ' x ≤ -(θ x) ^ 2 / m - r x)
    (ht12 : t1 ≤ t2) (hc : 0 ≤ c)
    (hout : ∀ s : ℝ, s ∉ Icc t1 t2 → eps ≤ r s)
    (hin : ∀ s ∈ Icc t1 t2, -c ≤ r s) (hL : 0 < L) :
    L ≤ Real.pi * Real.sqrt (m / eps) + (eps + c) * (t2 - t1) / eps := by
  set q : ℝ → ℝ := energyShortfall eps r with hq
  have hqcont : Continuous q := continuous_energyShortfall hrcont
  -- the shortfall is dominated by `(ε + c)` times the indicator of the window
  set g : ℝ → ℝ := Set.indicator (Icc t1 t2) (fun _ => eps + c) with hg
  have hgnn : ∀ s : ℝ, 0 ≤ g s := fun s =>
    Set.indicator_nonneg (fun _ _ => by linarith) s
  have hqg : ∀ s : ℝ, q s ≤ g s := by
    intro s
    by_cases hs : s ∈ Icc t1 t2
    · have h := hin s hs
      have hval : g s = eps + c := by rw [hg, Set.indicator_of_mem hs]
      rw [hval, hq]
      exact max_le (by linarith) (by linarith)
    · have hval : g s = 0 := by rw [hg, Set.indicator_of_notMem hs]
      rw [hval, hq]
      exact le_of_eq (energyShortfall_eq_zero_of_le (hout s hs))
  have hgint : Integrable g := by
    rw [hg]
    exact (integrable_indicator_iff measurableSet_Icc).2
      (integrableOn_const (hs := by simp [Real.volume_Icc]))
  -- hence the running integral never exceeds `(ε + c) τ`
  have hbudget : ∀ x ∈ Ico (0 : ℝ) L, (∫ s in (0 : ℝ)..x, q s) ≤ (eps + c) * (t2 - t1) := by
    intro x hx
    have hx0 : (0 : ℝ) ≤ x := hx.1
    have hqI : IntegrableOn q (Ioc (0 : ℝ) x) :=
      (intervalIntegrable_iff_integrableOn_Ioc_of_le hx0).1 (hqcont.intervalIntegrable 0 x)
    calc (∫ s in (0 : ℝ)..x, q s) = ∫ s in Ioc (0 : ℝ) x, q s :=
          intervalIntegral.integral_of_le hx0
      _ ≤ ∫ s in Ioc (0 : ℝ) x, g s :=
          setIntegral_mono_on hqI hgint.integrableOn measurableSet_Ioc (fun s _ => hqg s)
      _ ≤ ∫ s, g s := setIntegral_le_integral hgint (Filter.Eventually.of_forall hgnn)
      _ = (eps + c) * (t2 - t1) := by
          rw [hg, integral_indicator_const _ measurableSet_Icc,
            Real.volume_real_Icc_of_le ht12, smul_eq_mul]
          ring
  have h := myers_bound_with_shortfall (D := (eps + c) * (t2 - t1)) hm he hd hrcont hineq
    hbudget hL
  exact h

end Shortfall

/-! ### The congruence form -/

namespace GeodesicCongruence

variable {m L : ℝ} (C : GeodesicCongruence m L)

/-- **Singularity theorem with an energy shortfall, for a congruence.**  A geodesic
congruence whose Ricci focusing term is continuous and whose accumulated shortfall below
the level `ε > 0` never exceeds `D` has affine length at most `π √(m/ε) + D/ε`.  No
trapping hypothesis and no pointwise energy condition beyond `σ² ≥ 0` are used. -/
theorem affine_length_le_of_shortfall (hm : 0 < m) {eps D : ℝ} (he : 0 < eps)
    (hcont : Continuous C.ricci)
    (hbudget : ∀ x ∈ Ico (0 : ℝ) L,
      (∫ s in (0 : ℝ)..x, energyShortfall eps C.ricci s) ≤ D) (hL : 0 < L) :
    L ≤ Real.pi * Real.sqrt (m / eps) + D / eps := by
  refine myers_bound_with_shortfall (θ := C.expansion) (θ' := C.expansionDot)
    (r := C.ricci) hm he C.hasDeriv hcont ?_ hbudget hL
  intro x hx
  have h := C.raychaudhuri x hx
  have h1 := C.shearSq_nonneg x hx
  rw [h]
  linarith

end GeodesicCongruence

end Catalog.Physics.Spacetime