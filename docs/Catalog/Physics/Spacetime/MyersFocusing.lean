/-
  A Lorentzian Bonnet–Myers / Hawking bound: *strict* energy positivity forces focusing
  with **no** trapping hypothesis whatsoever.

  The Penrose mechanism (see `RaychaudhuriFocusing`) needs an initially converging
  congruence (`θ₀ < 0`) and produces the bound `m / |θ₀|`, which degenerates as `θ₀ → 0⁻`.
  Here we show that if the Ricci focusing term is bounded *below by a positive constant*,
  `Ric(k,k) ≥ ε > 0`, then the affine length of the congruence is bounded by

      L ≤ π √(m / ε)

  *uniformly in the initial expansion* — even for an initially expanding congruence.
  This is the sharp Lorentzian analogue of the Bonnet–Myers diameter bound, and the
  analytic heart of Hawking's cosmological singularity theorem.

  The proof is a phase-angle (Prüfer) argument: the angle `g = arctan(θ / √(mε))` obeys
  `g' ≤ -√(ε/m)`, i.e. it decreases at a definite rate, while it is confined to the
  interval `(-π/2, π/2)`.  The total available angle `π` divided by the rate gives the
  bound.  Sharpness is witnessed by the exact solution `θ(t) = -√(mε) tan(√(ε/m) t)`.
-/

import Physics.Spacetime.PenroseHawkingSingularity

open Set

namespace Catalog.Physics.Spacetime

section Prufer

variable {m eps L : ℝ} {θ θ' : ℝ → ℝ}

/-- **Prüfer angle estimate.**  If `θ' ≤ -θ²/m - ε`, the phase angle
`arctan (θ / √(mε))` decreases at least at the constant rate `√(mε)/m = √(ε/m)`. -/
theorem arctan_expansion_decay (hm : 0 < m) (he : 0 < eps)
    (hd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt θ (θ' x) x)
    (hineq : ∀ x ∈ Ico (0 : ℝ) L, θ' x ≤ -(θ x) ^ 2 / m - eps) :
    ∀ t ∈ Ico (0 : ℝ) L, Real.arctan (θ t / Real.sqrt (m * eps))
      ≤ Real.arctan (θ 0 / Real.sqrt (m * eps)) - (Real.sqrt (m * eps) / m) * t := by
  set a : ℝ := Real.sqrt (m * eps) with ha
  have hapos : 0 < a := Real.sqrt_pos.2 (by positivity)
  have hasq : a ^ 2 = m * eps := Real.sq_sqrt (by positivity)
  intro t ht
  have hsub : Ico (0 : ℝ) t ⊆ Ico (0 : ℝ) L := Ico_subset_Ico le_rfl ht.2.le
  have hsub2 : Icc (0 : ℝ) t ⊆ Ico (0 : ℝ) L := fun x hx => ⟨hx.1, lt_of_le_of_lt hx.2 ht.2⟩
  have hderiv : ∀ x ∈ Ico (0 : ℝ) L,
      HasDerivAt (fun s => Real.arctan (θ s / a)) (a * θ' x / (a ^ 2 + (θ x) ^ 2)) x := by
    intro x hx
    have h1 : HasDerivAt (fun s => θ s / a) (θ' x / a) x := (hd x hx).div_const a
    have h2 := (Real.hasDerivAt_arctan (θ x / a)).comp x h1
    convert h2 using 1
    field_simp
  refine image_le_of_deriv_right_le_deriv_boundary
    (f := fun s => Real.arctan (θ s / a)) (f' := fun x => a * θ' x / (a ^ 2 + (θ x) ^ 2))
    (B := fun s => Real.arctan (θ 0 / a) - (a / m) * s) (B' := fun _ => -(a / m))
    ?_ ?_ ?_ ?_ ?_ ?_ (right_mem_Icc.2 ht.1)
  · exact fun x hx => (hderiv x (hsub2 hx)).continuousAt.continuousWithinAt
  · exact fun x hx => (hderiv x (hsub hx)).hasDerivWithinAt
  · simp
  · fun_prop
  · intro x _
    simpa using
      (((hasDerivAt_id x).const_mul (a / m)).const_sub (Real.arctan (θ 0 / a))).hasDerivWithinAt
  · intro x hx
    have h1 : θ' x ≤ -(θ x) ^ 2 / m - eps := hineq x (hsub hx)
    have hden : 0 < a ^ 2 + (θ x) ^ 2 := by positivity
    have hXm : (-(θ x) ^ 2 / m) * m = -(θ x) ^ 2 := div_mul_cancel₀ _ hm.ne'
    have h2 : θ' x * m ≤ -((θ x) ^ 2 + a ^ 2) := by
      have h3 := mul_le_mul_of_nonneg_right h1 hm.le
      nlinarith [h3, hXm, hasq]
    show a * θ' x / (a ^ 2 + (θ x) ^ 2) ≤ -(a / m)
    rw [div_le_iff₀ hden]
    have hfac : a * θ' x = (a / m) * (θ' x * m) := by field_simp
    rw [hfac]
    have hpos : 0 < a / m := div_pos hapos hm
    calc (a / m) * (θ' x * m) ≤ (a / m) * (-((θ x) ^ 2 + a ^ 2)) :=
          mul_le_mul_of_nonneg_left h2 hpos.le
      _ = -(a / m) * (a ^ 2 + (θ x) ^ 2) := by ring

/-- **Refined Myers bound.**  The affine length is controlled by the *initial phase*: the
congruence exists for at most the time the phase angle needs to fall from
`arctan(θ₀/√(mε))` to `-π/2`. -/
theorem myers_domain_bound_refined (hm : 0 < m) (he : 0 < eps)
    (hd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt θ (θ' x) x)
    (hineq : ∀ x ∈ Ico (0 : ℝ) L, θ' x ≤ -(θ x) ^ 2 / m - eps) :
    L ≤ m / Real.sqrt (m * eps) *
      (Real.arctan (θ 0 / Real.sqrt (m * eps)) + Real.pi / 2) := by
  set a : ℝ := Real.sqrt (m * eps) with ha
  have hapos : 0 < a := Real.sqrt_pos.2 (by positivity)
  set Bd : ℝ := m / a * (Real.arctan (θ 0 / a) + Real.pi / 2) with hBd
  have hstep : ∀ t ∈ Ico (0 : ℝ) L, t ≤ Bd := by
    intro t ht
    have h1 := arctan_expansion_decay hm he hd hineq t ht
    have h2 : -(Real.pi / 2) < Real.arctan (θ t / a) := Real.neg_pi_div_two_lt_arctan _
    have h3 : (a / m) * t < Real.arctan (θ 0 / a) + Real.pi / 2 := by linarith
    have h4 : t < Bd := by
      rw [hBd]
      rw [div_mul_eq_mul_div, lt_div_iff₀ hapos]
      have h5 : (a / m) * t * m = t * a := by field_simp
      nlinarith [mul_lt_mul_of_pos_right h3 hm, h5]
    exact h4.le
  by_contra hcon
  push_neg at hcon
  have hBdpos : 0 < Bd := by
    rw [hBd]
    have : 0 < Real.arctan (θ 0 / a) + Real.pi / 2 := by
      have := Real.neg_pi_div_two_lt_arctan (θ 0 / a)
      linarith
    positivity
  have ht : (Bd + L) / 2 ∈ Ico (0 : ℝ) L := ⟨by linarith, by linarith⟩
  have := hstep _ ht
  linarith

/-- **Lorentzian Bonnet–Myers / Hawking bound.**  If the focusing term satisfies the
*strict* energy condition `Ric(k,k) ≥ ε > 0`, then the affine length of the congruence is
at most `π √(m/ε)`, with no assumption on the initial expansion: strict positive energy
alone forces a focal point, hence geodesic incompleteness. -/
theorem myers_domain_bound (hm : 0 < m) (he : 0 < eps)
    (hd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt θ (θ' x) x)
    (hineq : ∀ x ∈ Ico (0 : ℝ) L, θ' x ≤ -(θ x) ^ 2 / m - eps) :
    L ≤ Real.pi * Real.sqrt (m / eps) := by
  have hapos : 0 < Real.sqrt (m * eps) := Real.sqrt_pos.2 (by positivity)
  have href := myers_domain_bound_refined hm he hd hineq
  have hang : Real.arctan (θ 0 / Real.sqrt (m * eps)) + Real.pi / 2 ≤ Real.pi := by
    have := Real.arctan_lt_pi_div_two (θ 0 / Real.sqrt (m * eps))
    linarith
  have hmono : m / Real.sqrt (m * eps) *
      (Real.arctan (θ 0 / Real.sqrt (m * eps)) + Real.pi / 2)
      ≤ m / Real.sqrt (m * eps) * Real.pi :=
    mul_le_mul_of_nonneg_left hang (by positivity)
  have hsq : m / Real.sqrt (m * eps) * Real.pi = Real.pi * Real.sqrt (m / eps) := by
    rw [Real.sqrt_div' m he.le, Real.sqrt_mul hm.le]
    rw [show Real.sqrt m * Real.sqrt eps = Real.sqrt eps * Real.sqrt m by ring]
    have hm0 : Real.sqrt m ≠ 0 := ne_of_gt (Real.sqrt_pos.2 hm)
    have he0 : Real.sqrt eps ≠ 0 := ne_of_gt (Real.sqrt_pos.2 he)
    have hmm : Real.sqrt m * Real.sqrt m = m := Real.mul_self_sqrt hm.le
    field_simp
    nlinarith [hmm]
  linarith [href.trans (hmono.trans hsq.le)]

end Prufer

/-! ### The bound applied to congruences, and its sharpness -/

section Congruence

variable {m L : ℝ}

/-- **Hawking's singularity theorem, uniform form.**  A geodesic congruence whose Ricci
focusing term is bounded below by `ε > 0` has affine length at most `π √(m/ε)`,
irrespective of whether it is initially converging. -/
theorem GeodesicCongruence.affine_length_le_of_strict_energy (C : GeodesicCongruence m L)
    (hm : 0 < m) {eps : ℝ} (he : 0 < eps)
    (hstrict : ∀ t ∈ Ico (0 : ℝ) L, eps ≤ C.ricci t) :
    L ≤ Real.pi * Real.sqrt (m / eps) := by
  refine myers_domain_bound hm he C.hasDeriv ?_
  intro t ht
  have h := C.raychaudhuri t ht
  have h1 := C.shearSq_nonneg t ht
  have h2 := hstrict t ht
  rw [h]
  linarith

/-- The exact solution of `θ' = -θ²/m - ε` starting at `θ(0) = 0`:
`θ(t) = -√(mε) tan(√(ε/m) t)`. -/
noncomputable def tanSol (m eps t : ℝ) : ℝ :=
  -Real.sqrt (m * eps) * Real.tan (Real.sqrt (m * eps) / m * t)

/-- `tanSol` solves the critical Riccati equation exactly wherever the tangent is
regular. -/
theorem hasDerivAt_tanSol {m eps t : ℝ} (hm : 0 < m) (he : 0 < eps)
    (hcos : Real.cos (Real.sqrt (m * eps) / m * t) ≠ 0) :
    HasDerivAt (tanSol m eps) (-(tanSol m eps t) ^ 2 / m - eps) t := by
  set a : ℝ := Real.sqrt (m * eps) with ha
  have hapos : 0 < a := Real.sqrt_pos.2 (by positivity)
  have hasq : a ^ 2 = m * eps := Real.sq_sqrt (by positivity)
  set u : ℝ := a / m * t with hu
  have h1 : HasDerivAt (fun s : ℝ => a / m * s) (a / m) t := by
    simpa using (hasDerivAt_id t).const_mul (a / m)
  have h2 : HasDerivAt (fun s : ℝ => Real.tan (a / m * s)) (1 / Real.cos u ^ 2 * (a / m)) t :=
    (Real.hasDerivAt_tan hcos).comp t h1
  have h3 := h2.const_mul (-a)
  have hkey : -a * (1 / Real.cos u ^ 2 * (a / m)) = -(tanSol m eps t) ^ 2 / m - eps := by
    have htan : Real.tan u ^ 2 + 1 = 1 / Real.cos u ^ 2 := by
      rw [Real.tan_eq_sin_div_cos]
      field_simp
      nlinarith [Real.sin_sq_add_cos_sq u]
    have hts : tanSol m eps t = -a * Real.tan u := by rw [tanSol, ← ha, ← hu]
    rw [hts, ← htan]
    field_simp
    nlinarith [hasq]
  rw [← hkey]
  exact h3

/-- **Sharpness of the Myers bound at zero initial expansion.**  For a marginally trapped
initial condition `θ₀ = 0` the refined bound reads `L ≤ (π/2)√(m/ε)`, and the exact
solution `tanSol` realises exactly that affine length: it satisfies the critical
Raychaudhuri equation on `[0, (π/2)√(m/ε))` and starts at `θ = 0`. -/
theorem tanSol_sharp {m eps : ℝ} (hm : 0 < m) (he : 0 < eps) :
    tanSol m eps 0 = 0 ∧
      ∀ t ∈ Ico (0 : ℝ) (m / Real.sqrt (m * eps) * (Real.pi / 2)),
        HasDerivAt (tanSol m eps) (-(tanSol m eps t) ^ 2 / m - eps) t := by
  set a : ℝ := Real.sqrt (m * eps) with ha
  have hapos : 0 < a := Real.sqrt_pos.2 (by positivity)
  constructor
  · simp [tanSol]
  · intro t ht
    refine hasDerivAt_tanSol hm he (ne_of_gt (Real.cos_pos_of_mem_Ioo ⟨?_, ?_⟩))
    · have h0 : 0 ≤ a / m * t := by
        have := ht.1
        positivity
      have : (0 : ℝ) < Real.pi / 2 := by positivity
      linarith
    · rw [← ha]
      have h : t < m / a * (Real.pi / 2) := ht.2
      have hpos : 0 < a / m := div_pos hapos hm
      have h2 := mul_lt_mul_of_pos_left h hpos
      have hid : a / m * (m / a * (Real.pi / 2)) = Real.pi / 2 := by
        field_simp
      rw [hid] at h2
      exact h2

end Congruence

end Catalog.Physics.Spacetime