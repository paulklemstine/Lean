/-
  Focusing under an *averaged* energy condition: a quantitative ANEC singularity theorem.

  The classical singularity theorems assume the energy condition *pointwise*
  (`Ric(k,k) ≥ 0`, or `≥ ε > 0` for the Myers-type bound).  Quantum fields violate
  pointwise energy conditions, so physically one wants a version in which only an
  *average* of the curvature along the geodesic is controlled.

  The result proved here is a sharp-in-form, fully quantitative statement of this kind.
  Fix a scale `a > 0`.  Say that a "defect budget" `Q` at scale `a` accounts for the
  failure of `Ric(k,k) = r` to dominate the threshold `a²/m`, i.e.

      Q' = q ≥ a²/m - r,     q ≥ 0,     Q 0 = 0,     Q ≤ Dmax.

  Then any solution of the Raychaudhuri inequality `θ' ≤ -θ²/m - r` has affine length

      L ≤ (m / a) * (π + Dmax / a).

  Only the *accumulated* defect `Dmax` enters, never the pointwise sign of `r`: the
  curvature may be arbitrarily negative on short scales.  Choosing `a = √(mε)` when
  `r ≥ ε > 0` gives `Dmax = 0` and recovers the Bonnet–Myers bound `π√(m/ε)` exactly,
  so the theorem is a strict generalization of `myers_domain_bound`.

  The proof is again a Prüfer phase-angle argument, with the phase compared to the
  *defect-corrected* boundary function `arctan(θ₀/a) - (a/m) t + Q t / a`.
-/

import Physics.Spacetime.JacobiConjugatePoints

open Set

namespace Catalog.Physics.Spacetime

section ANEC

variable {m a L Dmax : ℝ} {θ θ' r q Q : ℝ → ℝ}

/-- **Defect-corrected Prüfer estimate.**  The phase angle `arctan (θ / a)` decreases at
rate `a/m` up to the accumulated energy defect `Q / a`. -/
theorem arctan_expansion_decay_with_defect (hm : 0 < m) (ha : 0 < a)
    (hd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt θ (θ' x) x)
    (hQ : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt Q (q x) x)
    (hineq : ∀ x ∈ Ico (0 : ℝ) L, θ' x ≤ -(θ x) ^ 2 / m - r x)
    (hq : ∀ x ∈ Ico (0 : ℝ) L, a ^ 2 / m - r x ≤ q x)
    (hqnn : ∀ x ∈ Ico (0 : ℝ) L, 0 ≤ q x) :
    ∀ t ∈ Ico (0 : ℝ) L, Real.arctan (θ t / a)
      ≤ Real.arctan (θ 0 / a) - (a / m) * t + (Q t - Q 0) / a := by
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
    (B := fun s => Real.arctan (θ 0 / a) - (a / m) * s + (Q s - Q 0) / a)
    (B' := fun x => -(a / m) + q x / a) ?_ ?_ ?_ ?_ ?_ ?_ (right_mem_Icc.2 ht.1)
  · exact fun x hx => (hderiv x (hsub2 hx)).continuousAt.continuousWithinAt
  · exact fun x hx => (hderiv x (hsub hx)).hasDerivWithinAt
  · simp
  · intro x hx
    exact ((((hasDerivAt_id x).const_mul (a / m)).const_sub (Real.arctan (θ 0 / a))).add
      (((hQ x (hsub2 hx)).sub_const (Q 0)).div_const a)).continuousAt.continuousWithinAt
  · intro x hx
    have h := (((hasDerivAt_id x).const_mul (a / m)).const_sub (Real.arctan (θ 0 / a))).add
      (((hQ x (hsub hx)).sub_const (Q 0)).div_const a)
    simp only [mul_one] at h
    exact h.hasDerivWithinAt
  · intro x hx
    have h1 : θ' x ≤ -(θ x) ^ 2 / m - r x := hineq x (hsub hx)
    have h2 : a ^ 2 / m - r x ≤ q x := hq x (hsub hx)
    have h3 : 0 ≤ q x := hqnn x (hsub hx)
    have hden : 0 < a ^ 2 + (θ x) ^ 2 := by positivity
    show a * θ' x / (a ^ 2 + (θ x) ^ 2) ≤ -(a / m) + q x / a
    rw [div_le_iff₀ hden]
    have hmul : a * θ' x ≤ a * (-(θ x) ^ 2 / m - r x) :=
      mul_le_mul_of_nonneg_left h1 ha.le
    have hkey : a * (-(θ x) ^ 2 / m - r x)
        ≤ (-(a / m) + q x / a) * (a ^ 2 + (θ x) ^ 2) := by
      have hexp : (-(a / m) + q x / a) * (a ^ 2 + (θ x) ^ 2)
          - a * (-(θ x) ^ 2 / m - r x)
          = a * (q x - (a ^ 2 / m - r x)) + q x * (θ x) ^ 2 / a := by
        field_simp
        ring
      nlinarith [mul_nonneg ha.le (sub_nonneg.2 h2),
        div_nonneg (mul_nonneg h3 (sq_nonneg (θ x))) ha.le, hexp]
    linarith

/-- **Quantitative averaged-energy-condition singularity theorem.**
Only the total accumulated energy defect `Dmax` at scale `a` enters the focusing bound;
the pointwise sign of the curvature term `r = Ric(k,k)` is irrelevant, and no trapping
hypothesis is imposed. -/
theorem anec_domain_bound (hm : 0 < m) (ha : 0 < a)
    (hd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt θ (θ' x) x)
    (hQ : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt Q (q x) x)
    (hineq : ∀ x ∈ Ico (0 : ℝ) L, θ' x ≤ -(θ x) ^ 2 / m - r x)
    (hq : ∀ x ∈ Ico (0 : ℝ) L, a ^ 2 / m - r x ≤ q x)
    (hqnn : ∀ x ∈ Ico (0 : ℝ) L, 0 ≤ q x)
    (hbudget : ∀ x ∈ Ico (0 : ℝ) L, Q x - Q 0 ≤ Dmax) (hL : 0 < L) :
    L ≤ m / a * (Real.pi + Dmax / a) := by
  set Bd : ℝ := m / a * (Real.pi + Dmax / a) with hBd
  have hDnn : 0 ≤ Dmax := by
    have h0 : (0 : ℝ) ∈ Ico (0 : ℝ) L := ⟨le_rfl, hL⟩
    have := hbudget 0 h0
    linarith
  have hstep : ∀ t ∈ Ico (0 : ℝ) L, t ≤ Bd := by
    intro t ht
    have h1 := arctan_expansion_decay_with_defect hm ha hd hQ hineq hq hqnn t ht
    have h2 : -(Real.pi / 2) < Real.arctan (θ t / a) := Real.neg_pi_div_two_lt_arctan _
    have h3 : Real.arctan (θ 0 / a) < Real.pi / 2 := Real.arctan_lt_pi_div_two _
    have h4 : (Q t - Q 0) / a ≤ Dmax / a :=
      (div_le_div_iff_of_pos_right ha).mpr (hbudget t ht)
    have h5 : (a / m) * t < Real.pi + Dmax / a := by linarith
    have h6 : t ≤ Bd := by
      rw [hBd]
      have h7 := mul_lt_mul_of_pos_left h5 (div_pos hm ha)
      have hid : m / a * ((a / m) * t) = t := by field_simp
      rw [hid] at h7
      exact h7.le
    exact h6
  by_contra hcon
  push_neg at hcon
  have hBdpos : 0 < Bd := by
    rw [hBd]
    have hsum : 0 < Real.pi + Dmax / a := by
      have h1 : 0 ≤ Dmax / a := div_nonneg hDnn ha.le
      linarith [Real.pi_pos]
    positivity
  have ht : (Bd + L) / 2 ∈ Ico (0 : ℝ) L := ⟨by linarith, by linarith⟩
  have := hstep _ ht
  linarith

/-- **Consistency with Bonnet–Myers.**  If the pointwise strict energy condition
`r ≥ ε > 0` holds, the defect budget at scale `a = √(mε)` is identically zero, and the
averaged theorem returns exactly the bound `π √(m/ε)` of `myers_domain_bound`. -/
theorem anec_recovers_myers (hm : 0 < m) {eps : ℝ} (he : 0 < eps)
    (hd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt θ (θ' x) x)
    (hineq : ∀ x ∈ Ico (0 : ℝ) L, θ' x ≤ -(θ x) ^ 2 / m - r x)
    (hr : ∀ x ∈ Ico (0 : ℝ) L, eps ≤ r x) (hL : 0 < L) :
    L ≤ Real.pi * Real.sqrt (m / eps) := by
  set a : ℝ := Real.sqrt (m * eps) with ha'
  have hapos : 0 < a := Real.sqrt_pos.2 (by positivity)
  have hasq : a ^ 2 = m * eps := Real.sq_sqrt (by positivity)
  have hbound := anec_domain_bound (m := m) (a := a) (L := L) (Dmax := 0)
    (θ := θ) (θ' := θ') (r := r) (q := fun _ => 0) (Q := fun _ => 0) hm hapos hd
    (fun x _ => hasDerivAt_const x 0) hineq ?_ (fun x _ => le_rfl) (fun x _ => by simp) hL
  · have hpi : m / a * (Real.pi + 0 / a) = Real.pi * Real.sqrt (m / eps) := by
      rw [Real.sqrt_div' m he.le, ha', Real.sqrt_mul hm.le]
      have hm0 : Real.sqrt m ≠ 0 := ne_of_gt (Real.sqrt_pos.2 hm)
      have he0 : Real.sqrt eps ≠ 0 := ne_of_gt (Real.sqrt_pos.2 he)
      have hcube : Real.sqrt m ^ 3 = m * Real.sqrt m := by
        have h3 : Real.sqrt m ^ 3 = Real.sqrt m ^ 2 * Real.sqrt m := by ring
        rw [h3, Real.sq_sqrt hm.le]
      field_simp
      rw [hcube]
      ring
    rwa [hpi] at hbound
  · intro x hx
    have h := hr x hx
    have : a ^ 2 / m = eps := by
      rw [hasq]
      field_simp
    rw [this]
    linarith

/-- Integral form of the averaged energy condition.  If the defect rate `q` is continuous
and its running integral never exceeds `Dmax`, the same focusing bound holds — here the
"averaged energy condition" is literally an integral condition along the geodesic. -/
theorem anec_domain_bound_integral (hm : 0 < m) (ha : 0 < a)
    (hd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt θ (θ' x) x)
    (hqcont : Continuous q)
    (hineq : ∀ x ∈ Ico (0 : ℝ) L, θ' x ≤ -(θ x) ^ 2 / m - r x)
    (hq : ∀ x ∈ Ico (0 : ℝ) L, a ^ 2 / m - r x ≤ q x)
    (hqnn : ∀ x ∈ Ico (0 : ℝ) L, 0 ≤ q x)
    (hbudget : ∀ x ∈ Ico (0 : ℝ) L, (∫ s in (0 : ℝ)..x, q s) ≤ Dmax) (hL : 0 < L) :
    L ≤ m / a * (Real.pi + Dmax / a) := by
  refine anec_domain_bound (Q := fun x => ∫ s in (0 : ℝ)..x, q s) hm ha hd ?_ hineq hq hqnn ?_ hL
  · exact fun x _ => (hqcont.integral_hasStrictDerivAt 0 x).hasDerivAt
  · intro x hx
    simpa using hbudget x hx

end ANEC

end Catalog.Physics.Spacetime