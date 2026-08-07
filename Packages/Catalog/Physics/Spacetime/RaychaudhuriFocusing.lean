/-
  Raychaudhuri focusing: the analytic engine of the Penrose–Hawking singularity theorems.

  This file develops, from scratch and with complete proofs, the one–dimensional
  differential–inequality theory that underlies geodesic focusing.

  The physical input of the singularity theorems is the *Raychaudhuri equation* for the
  expansion `θ` of a geodesic congruence,

      dθ/dλ = - θ² / m - σ² - Ric(k,k),

  where `m` is the effective transverse dimension (`m = n - 1` for a timelike congruence in
  `n` spacetime dimensions, `m = n - 2` for a null congruence), `σ² ≥ 0` is the shear scalar
  and `Ric(k,k)` is the Ricci curvature contracted along the congruence.  A pointwise energy
  condition makes `Ric(k,k) ≥ 0`, so the expansion obeys the *differential inequality*

      dθ/dλ ≤ - θ² / m.

  All statements below are about that inequality; nothing else about spacetime is used.
  The main results are:

  * `le_init_of_contact_deriv_neg` — a fencing lemma: a solution never rises above its
    initial value if its derivative is negative at every contact point.
  * `inv_expansion_lower_bound` — the reciprocal `1/θ` grows at least linearly with slope
    `1/m` (the integrated Raychaudhuri inequality).
  * `focusing_time_bound` / `focusing_domain_bound` — an initially converging congruence
    (`θ 0 < 0`) cannot be defined for affine parameter beyond `m / |θ 0|`.
  * `expansion_comparison` — the sharp pointwise comparison with the exact Riccati solution.
  * `focusing_domain_bound_of_energy_defect` — the *boundary condition*: if the energy
    condition is violated by at most `c ≥ 0` (`Ric(k,k) ≥ -c`), focusing still occurs
    provided `θ 0 ² > m * c`, with an explicit, degrading affine bound.
  * `no_focusing_at_threshold` — at the threshold `θ 0 ² = m * c` the conclusion fails:
    an eternal solution exists.  Hence the strict inequality above is sharp.
-/

import Mathlib

open Set

namespace Catalog.Physics.Spacetime

section Fencing

/-- **Fencing lemma.** If `θ` is differentiable on `[0, L)` and its derivative is strictly
negative at every point where `θ` returns to its initial value, then `θ` never exceeds its
initial value.  This is the rigorous replacement of the informal "the expansion can only
decrease" step in the singularity theorems. -/
theorem le_init_of_contact_deriv_neg {L : ℝ} {θ θ' : ℝ → ℝ}
    (hd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt θ (θ' x) x)
    (hc : ∀ x ∈ Ico (0 : ℝ) L, θ x = θ 0 → θ' x < 0) :
    ∀ t ∈ Ico (0 : ℝ) L, θ t ≤ θ 0 := by
  intro t ht
  have hsub : Ico (0 : ℝ) t ⊆ Ico (0 : ℝ) L := Ico_subset_Ico le_rfl ht.2.le
  have hsub2 : Icc (0 : ℝ) t ⊆ Ico (0 : ℝ) L := fun x hx => ⟨hx.1, lt_of_le_of_lt hx.2 ht.2⟩
  refine image_le_of_deriv_right_lt_deriv_boundary (f := θ) (f' := θ')
    (B := fun _ => θ 0) (B' := fun _ => 0) ?_ ?_ le_rfl ?_ ?_ (right_mem_Icc.2 ht.1)
  · exact fun x hx => (hd x (hsub2 hx)).continuousAt.continuousWithinAt
  · exact fun x hx => (hd x (hsub hx)).hasDerivWithinAt
  · exact fun x => hasDerivAt_const x _
  · exact fun x hx h => hc x (hsub hx) h

end Fencing

section Riccati

variable {m L : ℝ} {θ θ' : ℝ → ℝ}

/-- Under the Raychaudhuri inequality `θ' ≤ -θ²/m` with `m > 0`, an initially converging
congruence stays converging: `θ t ≤ θ 0 < 0` on the whole domain. -/
theorem expansion_le_init (hm : 0 < m)
    (hd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt θ (θ' x) x)
    (hineq : ∀ x ∈ Ico (0 : ℝ) L, θ' x ≤ -(θ x) ^ 2 / m)
    (h0 : θ 0 < 0) :
    ∀ t ∈ Ico (0 : ℝ) L, θ t ≤ θ 0 := by
  refine le_init_of_contact_deriv_neg hd ?_
  intro x hx hxe
  have h1 : θ' x ≤ -(θ x) ^ 2 / m := hineq x hx
  have h2 : 0 < (θ 0) ^ 2 := by
    have : θ 0 ≠ 0 := ne_of_lt h0
    positivity
  have h3 : -(θ x) ^ 2 / m < 0 := by
    rw [hxe]
    exact div_neg_of_neg_of_pos (by linarith) hm
  exact lt_of_le_of_lt h1 h3

/-- The **integrated Raychaudhuri inequality**: the reciprocal of the expansion increases
at least at rate `1/m`.  Combined with `θ < 0` this forces `θ → -∞` in finite affine
parameter. -/
theorem inv_expansion_lower_bound (hm : 0 < m)
    (hd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt θ (θ' x) x)
    (hineq : ∀ x ∈ Ico (0 : ℝ) L, θ' x ≤ -(θ x) ^ 2 / m)
    (h0 : θ 0 < 0) :
    ∀ t ∈ Ico (0 : ℝ) L, 1 / θ 0 + t / m ≤ (θ t)⁻¹ := by
  have hle := expansion_le_init hm hd hineq h0
  intro t ht
  have hsub : Ico (0 : ℝ) t ⊆ Ico (0 : ℝ) L := Ico_subset_Ico le_rfl ht.2.le
  have hsub2 : Icc (0 : ℝ) t ⊆ Ico (0 : ℝ) L := fun x hx => ⟨hx.1, lt_of_le_of_lt hx.2 ht.2⟩
  have hne : ∀ x ∈ Ico (0 : ℝ) L, θ x ≠ 0 := fun x hx =>
    ne_of_lt (lt_of_le_of_lt (hle x hx) h0)
  refine image_le_of_deriv_right_le_deriv_boundary
    (f := fun x => 1 / θ 0 + x / m) (f' := fun _ => 1 / m)
    (B := fun x => (θ x)⁻¹) (B' := fun x => -θ' x / (θ x) ^ 2) ?_ ?_ ?_ ?_ ?_ ?_
    (right_mem_Icc.2 ht.1)
  · fun_prop
  · exact fun x _ => (((hasDerivAt_id x).div_const m).const_add (1 / θ 0)).hasDerivWithinAt
  · simp
  · exact fun x hx => ((hd x (hsub2 hx)).inv (hne x (hsub2 hx))).continuousAt.continuousWithinAt
  · exact fun x hx => ((hd x (hsub hx)).inv (hne x (hsub hx))).hasDerivWithinAt
  · intro x hx
    have h1 : θ' x ≤ -(θ x) ^ 2 / m := hineq x (hsub hx)
    have h2 : (0 : ℝ) < (θ x) ^ 2 := by
      have := hne x (hsub hx); positivity
    rw [div_le_div_iff₀ hm h2]
    have h : θ' x * m ≤ -(θ x) ^ 2 := (le_div_iff₀ hm).1 h1
    nlinarith

/-- **Focusing time bound.**  Every affine parameter in the domain of an initially
converging congruence is smaller than `m / |θ 0|`. -/
theorem focusing_time_bound (hm : 0 < m)
    (hd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt θ (θ' x) x)
    (hineq : ∀ x ∈ Ico (0 : ℝ) L, θ' x ≤ -(θ x) ^ 2 / m)
    (h0 : θ 0 < 0) :
    ∀ t ∈ Ico (0 : ℝ) L, t < m / (-θ 0) := by
  intro t ht
  have hkey := inv_expansion_lower_bound hm hd hineq h0 t ht
  have hlt : θ t ≤ θ 0 := expansion_le_init hm hd hineq h0 t ht
  have hneg : (θ t)⁻¹ < 0 := inv_lt_zero.2 (lt_of_le_of_lt hlt h0)
  have h1 : 1 / θ 0 + t / m < 0 := lt_of_le_of_lt hkey hneg
  have h2 : t / m < -(1 / θ 0) := by linarith
  have h3 : -(1 / θ 0) = 1 / (-θ 0) := by field_simp
  rw [h3, div_lt_div_iff₀ hm (neg_pos.2 h0)] at h2
  rw [lt_div_iff₀ (neg_pos.2 h0)]
  linarith

/-- **Focusing domain bound (Penrose–Hawking incompleteness estimate).**  A congruence
satisfying the Raychaudhuri inequality with initial expansion `θ 0 < 0` cannot be defined
on `[0, L)` for `L > m / |θ 0|`.  Equivalently, the affine length of the congruence is at
most `m / |θ 0|`: the geodesics are incomplete (or a conjugate/focal point occurs first). -/
theorem focusing_domain_bound (hm : 0 < m)
    (hd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt θ (θ' x) x)
    (hineq : ∀ x ∈ Ico (0 : ℝ) L, θ' x ≤ -(θ x) ^ 2 / m)
    (h0 : θ 0 < 0) :
    L ≤ m / (-θ 0) := by
  by_contra hcon
  push_neg at hcon
  set b : ℝ := m / (-θ 0) with hb
  have hbpos : 0 < b := div_pos hm (neg_pos.2 h0)
  set t : ℝ := (b + L) / 2 with hts
  have htb : b < t := by simp only [hts]; linarith
  have htL : t < L := by simp only [hts]; linarith
  have ht : t ∈ Ico (0 : ℝ) L := ⟨by linarith, htL⟩
  exact absurd (focusing_time_bound hm hd hineq h0 t ht) (not_lt.2 htb.le)

/-- **Sharp comparison with the exact Riccati solution.**  Any subsolution of the
Raychaudhuri inequality is bounded above by the explicit solution
`t ↦ m θ₀ / (m + θ₀ t)` of `θ' = -θ²/m` with the same initial value. -/
theorem expansion_comparison (hm : 0 < m)
    (hd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt θ (θ' x) x)
    (hineq : ∀ x ∈ Ico (0 : ℝ) L, θ' x ≤ -(θ x) ^ 2 / m)
    (h0 : θ 0 < 0) :
    ∀ t ∈ Ico (0 : ℝ) L, θ t ≤ m * θ 0 / (m + θ 0 * t) := by
  intro t ht
  have hkey := inv_expansion_lower_bound hm hd hineq h0 t ht
  have hθt : θ t < 0 := lt_of_le_of_lt (expansion_le_init hm hd hineq h0 t ht) h0
  have htb : t < m / (-θ 0) := focusing_time_bound hm hd hineq h0 t ht
  have hden : 0 < m + θ 0 * t := by
    rw [lt_div_iff₀ (neg_pos.2 h0)] at htb
    nlinarith
  have hθ0ne : θ 0 ≠ 0 := ne_of_lt h0
  have hA : 1 / θ 0 + t / m = (m + θ 0 * t) / (m * θ 0) := by
    field_simp
  have hAneg : (m + θ 0 * t) / (m * θ 0) < 0 :=
    div_neg_of_pos_of_neg hden (by nlinarith)
  rw [hA] at hkey
  -- invert the inequality between two negative numbers
  have h1 : (m + θ 0 * t) / (m * θ 0) ≤ (θ t)⁻¹ := hkey
  have h2 : (θ t)⁻¹ < 0 := inv_lt_zero.2 hθt
  have h3 : m * θ 0 / (m + θ 0 * t) = ((m + θ 0 * t) / (m * θ 0))⁻¹ := by
    rw [inv_div]
  rw [h3]
  have h4 : ((θ t)⁻¹)⁻¹ ≤ ((m + θ 0 * t) / (m * θ 0))⁻¹ :=
    (inv_le_inv_of_neg h2 hAneg).mpr h1
  rwa [inv_inv] at h4

end Riccati

section Sharpness

/-- The exact Riccati solution with `m > 0` and initial value `θ₀ < 0`. -/
noncomputable def riccatiSol (m t0 t : ℝ) : ℝ := m * t0 / (m + t0 * t)

/-- On its maximal interval of existence, `riccatiSol` solves `θ' = -θ²/m` exactly. -/
theorem hasDerivAt_riccatiSol {m t0 t : ℝ} (hden : m + t0 * t ≠ 0) :
    HasDerivAt (riccatiSol m t0) (-(riccatiSol m t0 t) ^ 2 / m) t := by
  have hnum : HasDerivAt (fun x : ℝ => m + t0 * x) t0 t := by
    simpa using ((hasDerivAt_id t).const_mul t0).const_add m
  have h := (hasDerivAt_const t (m * t0)).div hnum hden
  simp only [riccatiSol]
  convert h using 1
  field_simp
  ring

/-- **Sharpness of the focusing bound.**  The exact solution is defined on
`[0, m / |θ₀|)`, satisfies the Raychaudhuri equation with vanishing shear and Ricci term
there, and has initial expansion `θ₀ < 0`.  Hence the bound `L ≤ m / |θ 0|` of
`focusing_domain_bound` is attained and cannot be improved. -/
theorem riccatiSol_sharp {m t0 : ℝ} (hm : 0 < m) (h0 : t0 < 0) :
    riccatiSol m t0 0 = t0 ∧
      (∀ t ∈ Ico (0 : ℝ) (m / (-t0)),
        HasDerivAt (riccatiSol m t0) (-(riccatiSol m t0 t) ^ 2 / m) t) := by
  constructor
  · simp only [riccatiSol, mul_zero, add_zero]
    exact mul_div_cancel_left₀ _ hm.ne'
  · intro t ht
    refine hasDerivAt_riccatiSol (ne_of_gt ?_)
    have h := ht.2
    rw [lt_div_iff₀ (neg_pos.2 h0)] at h
    nlinarith [ht.1]

end Sharpness

section EnergyDefect

variable {m L c : ℝ} {θ θ' : ℝ → ℝ}

/-- **Focusing under a bounded violation of the energy condition.**
Suppose the Ricci term is allowed to be negative but bounded below by `-c` (`c ≥ 0`), so
that `θ' ≤ -θ²/m + c`.  If the initial convergence is strong enough that
`m * c < θ 0 ²` — i.e. `θ 0 < -√(m c)` — then focusing still occurs, and the affine domain
is bounded by the explicit, degrading estimate `m |θ 0| / (θ 0 ² - m c)`.
For `c = 0` this reduces exactly to `m / |θ 0|`. -/
theorem focusing_domain_bound_of_energy_defect (hm : 0 < m) (hc : 0 ≤ c)
    (hd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt θ (θ' x) x)
    (hineq : ∀ x ∈ Ico (0 : ℝ) L, θ' x ≤ -(θ x) ^ 2 / m + c)
    (h0 : θ 0 < 0) (hthr : m * c < (θ 0) ^ 2) :
    L ≤ m * (-θ 0) / ((θ 0) ^ 2 - m * c) := by
  -- Step 1: the expansion stays below its initial value.
  have hle : ∀ t ∈ Ico (0 : ℝ) L, θ t ≤ θ 0 := by
    refine le_init_of_contact_deriv_neg hd ?_
    intro x hx hxe
    have h1 : θ' x ≤ -(θ x) ^ 2 / m + c := hineq x hx
    have h2 : -(θ 0) ^ 2 / m + c < 0 := by
      have hlt : -(θ 0) ^ 2 / m < -c := by
        rw [div_lt_iff₀ hm]
        nlinarith
      linarith
    rw [hxe] at h1
    linarith
  -- Step 2: rescale the effective dimension `m` so as to absorb the energy defect.
  have hθ0ne : θ 0 ≠ 0 := ne_of_lt h0
  have hθ0sq : (0 : ℝ) < (θ 0) ^ 2 := by positivity
  have hApos : (0 : ℝ) < (θ 0) ^ 2 - m * c := by linarith
  have hm'pos : (0 : ℝ) < m * (θ 0) ^ 2 / ((θ 0) ^ 2 - m * c) :=
    div_pos (mul_pos hm hθ0sq) hApos
  have hineq' : ∀ x ∈ Ico (0 : ℝ) L,
      θ' x ≤ -(θ x) ^ 2 / (m * (θ 0) ^ 2 / ((θ 0) ^ 2 - m * c)) := by
    intro x hx
    have h1 : θ' x ≤ -(θ x) ^ 2 / m + c := hineq x hx
    have h2 : (θ 0) ^ 2 ≤ (θ x) ^ 2 := by
      have := hle x hx
      nlinarith
    have key : -(θ x) ^ 2 / (m * (θ 0) ^ 2 / ((θ 0) ^ 2 - m * c))
        = -(θ x) ^ 2 / m + c * (θ x) ^ 2 / (θ 0) ^ 2 := by
      field_simp
      ring
    have h3 : c ≤ c * (θ x) ^ 2 / (θ 0) ^ 2 := by
      rw [le_div_iff₀ hθ0sq]
      nlinarith
    rw [key]
    linarith
  -- Step 3: apply the core focusing bound with the rescaled dimension.
  have hbound := focusing_domain_bound hm'pos hd hineq' h0
  have heq : m * (θ 0) ^ 2 / ((θ 0) ^ 2 - m * c) / (-θ 0)
      = m * (-θ 0) / ((θ 0) ^ 2 - m * c) := by
    field_simp
  rwa [heq] at hbound

/-- **The threshold is sharp: no focusing at `θ 0 ² = m c`.**
At the critical initial expansion `θ 0 = -√(m c)` the differential inequality
`θ' ≤ -θ²/m + c` admits the constant eternal solution `θ ≡ -√(m c)`, defined for *all*
affine parameters.  Hence the strict inequality `m c < θ 0 ²` in
`focusing_domain_bound_of_energy_defect` cannot be weakened to `≤`: an energy-condition
defect of size `c` genuinely obstructs the singularity theorem for weakly trapped data. -/
theorem no_focusing_at_threshold {c : ℝ} (hm : 0 < m) (hc : 0 < c) :
    ∃ θ θ' : ℝ → ℝ,
      (∀ x : ℝ, HasDerivAt θ (θ' x) x) ∧
      (∀ x : ℝ, θ' x ≤ -(θ x) ^ 2 / m + c) ∧
      θ 0 < 0 ∧ (θ 0) ^ 2 = m * c := by
  refine ⟨fun _ => -Real.sqrt (m * c), fun _ => 0, fun x => hasDerivAt_const x _, ?_, ?_, ?_⟩
  · intro x
    have h : Real.sqrt (m * c) ^ 2 = m * c := Real.sq_sqrt (by positivity)
    have h2 : (-Real.sqrt (m * c)) ^ 2 = m * c := by rw [neg_pow]; simpa using h
    show (0 : ℝ) ≤ -(-Real.sqrt (m * c)) ^ 2 / m + c
    rw [h2]
    have h3 : -(m * c) / m + c = 0 := by
      field_simp; ring
    linarith
  · simpa using Real.sqrt_pos.2 (by positivity)
  · have h : Real.sqrt (m * c) ^ 2 = m * c := Real.sq_sqrt (by positivity)
    rw [neg_pow]
    simpa using h

end EnergyDefect

end Catalog.Physics.Spacetime