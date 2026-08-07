import Mathlib

/-!
# The Lagrange–Jacobi identity and positive-energy escape in the three-body problem

This file formalises the *global* structural facts about the Newtonian three-body problem
that complement the local (Lyapunov) analysis of `Physics.Chaos.ThreeBodyLagrange`:

* `virial_identity` — the Euler-homogeneity ("virial") identity
  `Σ mᵢ ⟪rᵢ, aᵢ⟫ = −U`, where `aᵢ` are the Newtonian accelerations and `U` is the
  gravitational potential energy. This is purely algebraic and holds in any real inner
  product space, in any dimension, and for any choice of origin.
* `lagrange_jacobi` — the **Lagrange–Jacobi identity** `Ï = 4T − 2U` for the polar moment
  of inertia `I = Σ mᵢ‖rᵢ‖²`.
* `positive_energy_escape` — if the total energy stays bounded below by `E₀ > 0`, then
  `I(t) → ∞`: the system disintegrates. In particular no positive-energy three-body
  motion is bounded, so all bounded (hence all chaotic) three-body motions have
  non-positive energy.

Everything is stated for arbitrary real inner product spaces, so it covers the planar and
spatial problems simultaneously.
-/

noncomputable section

open Filter Topology RealInnerProductSpace

namespace ThreeBody

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-! ### Newtonian data -/

/-- The Newtonian gravitational acceleration of the body at `ri` due to bodies of mass
`mj`, `mk` at `rj`, `rk`. -/
def newtonianAccel (G mj mk : ℝ) (ri rj rk : E) : E :=
  (G * mj / ‖rj - ri‖ ^ 3) • (rj - ri) + (G * mk / ‖rk - ri‖ ^ 3) • (rk - ri)

/-- The gravitational potential energy (as a positive quantity) of a three-body
configuration. -/
def potentialEnergy (G m₁ m₂ m₃ : ℝ) (r₁ r₂ r₃ : E) : ℝ :=
  G * m₁ * m₂ / ‖r₁ - r₂‖ + G * m₂ * m₃ / ‖r₂ - r₃‖ + G * m₃ * m₁ / ‖r₃ - r₁‖

/-- The kinetic energy of a three-body configuration. -/
def kineticEnergy (m₁ m₂ m₃ : ℝ) (v₁ v₂ v₃ : E) : ℝ :=
  (m₁ * ‖v₁‖ ^ 2 + m₂ * ‖v₂‖ ^ 2 + m₃ * ‖v₃‖ ^ 2) / 2

/-- The polar moment of inertia `I = Σ mᵢ‖rᵢ‖²`. -/
def momentOfInertia (m₁ m₂ m₃ : ℝ) (r₁ r₂ r₃ : E) : ℝ :=
  m₁ * ‖r₁‖ ^ 2 + m₂ * ‖r₂‖ ^ 2 + m₃ * ‖r₃‖ ^ 2

omit [InnerProductSpace ℝ E] in
theorem potentialEnergy_nonneg {G m₁ m₂ m₃ : ℝ} (hG : 0 ≤ G) (h₁ : 0 ≤ m₁) (h₂ : 0 ≤ m₂)
    (h₃ : 0 ≤ m₃) (r₁ r₂ r₃ : E) : 0 ≤ potentialEnergy G m₁ m₂ m₃ r₁ r₂ r₃ := by
  unfold potentialEnergy; positivity

/-! ### The virial (Euler homogeneity) identity -/

/-- **Pairwise virial identity.** The two-body contribution of an interacting pair to
`Σ mᵢ ⟪rᵢ, aᵢ⟫` is exactly minus its potential energy. This is where the inverse-square
law (homogeneity degree `−1` of the potential) enters. -/
theorem pair_virial (G mi mj : ℝ) (ri rj : E) (h : ri ≠ rj) :
    mi * ⟪ri, (G * mj / ‖rj - ri‖ ^ 3) • (rj - ri)⟫
      + mj * ⟪rj, (G * mi / ‖ri - rj‖ ^ 3) • (ri - rj)⟫
      = -(G * mi * mj / ‖ri - rj‖) := by
  have hd : 0 < ‖ri - rj‖ := by simpa [sub_eq_zero] using h
  have hsym : ‖rj - ri‖ = ‖ri - rj‖ := norm_sub_rev _ _
  rw [hsym, real_inner_smul_right, real_inner_smul_right]
  have h1 : ⟪ri, rj - ri⟫ + ⟪rj, ri - rj⟫ = -‖ri - rj‖ ^ 2 := by
    rw [inner_sub_right, inner_sub_right, ← real_inner_self_eq_norm_sq, inner_sub_sub_self]
    rw [real_inner_comm ri rj]; ring
  field_simp
  linear_combination (mi * G * mj) * h1

/-- **Virial identity for the three-body problem.**
`m₁⟪r₁,a₁⟫ + m₂⟪r₂,a₂⟫ + m₃⟪r₃,a₃⟫ = −U`. -/
theorem virial_identity (G m₁ m₂ m₃ : ℝ) (r₁ r₂ r₃ : E) (h₁₂ : r₁ ≠ r₂) (h₂₃ : r₂ ≠ r₃)
    (h₃₁ : r₃ ≠ r₁) :
    m₁ * ⟪r₁, newtonianAccel G m₂ m₃ r₁ r₂ r₃⟫
      + m₂ * ⟪r₂, newtonianAccel G m₃ m₁ r₂ r₃ r₁⟫
      + m₃ * ⟪r₃, newtonianAccel G m₁ m₂ r₃ r₁ r₂⟫
      = -potentialEnergy G m₁ m₂ m₃ r₁ r₂ r₃ := by
  have p₁ := pair_virial G m₁ m₂ r₁ r₂ h₁₂
  have p₂ := pair_virial G m₂ m₃ r₂ r₃ h₂₃
  have p₃ := pair_virial G m₃ m₁ r₃ r₁ h₃₁
  simp only [newtonianAccel, inner_add_right, potentialEnergy]
  linear_combination p₁ + p₂ + p₃

/-! ### The Lagrange–Jacobi identity -/

/-- Derivative of `t ↦ ‖r t‖²` along a differentiable curve. -/
theorem hasDerivAt_normSq (r v : ℝ → E) (hv : ∀ t, HasDerivAt r (v t) t) (t : ℝ) :
    HasDerivAt (fun s => ‖r s‖ ^ 2) (2 * ⟪r t, v t⟫) t := by
  have hsq : ∀ s : ℝ, ‖r s‖ ^ 2 = ⟪r s, r s⟫ := fun s => (real_inner_self_eq_norm_sq (r s)).symm
  have h := (hv t).inner ℝ (hv t)
  simp only [hsq]
  convert h using 1
  rw [real_inner_comm (v t) (r t)]; ring

/-- **Lagrange–Jacobi identity.** For any solution of Newton's equations for three bodies,
the polar moment of inertia satisfies `Ï = 4T − 2U`. -/
theorem lagrange_jacobi (G m₁ m₂ m₃ : ℝ) (r₁ r₂ r₃ v₁ v₂ v₃ : ℝ → E)
    (hr₁ : ∀ t, HasDerivAt r₁ (v₁ t) t) (hr₂ : ∀ t, HasDerivAt r₂ (v₂ t) t)
    (hr₃ : ∀ t, HasDerivAt r₃ (v₃ t) t)
    (hv₁ : ∀ t, HasDerivAt v₁ (newtonianAccel G m₂ m₃ (r₁ t) (r₂ t) (r₃ t)) t)
    (hv₂ : ∀ t, HasDerivAt v₂ (newtonianAccel G m₃ m₁ (r₂ t) (r₃ t) (r₁ t)) t)
    (hv₃ : ∀ t, HasDerivAt v₃ (newtonianAccel G m₁ m₂ (r₃ t) (r₁ t) (r₂ t)) t)
    (hsep : ∀ t, r₁ t ≠ r₂ t ∧ r₂ t ≠ r₃ t ∧ r₃ t ≠ r₁ t) (t : ℝ) :
    HasDerivAt (deriv fun s => momentOfInertia m₁ m₂ m₃ (r₁ s) (r₂ s) (r₃ s))
      (4 * kineticEnergy m₁ m₂ m₃ (v₁ t) (v₂ t) (v₃ t)
        - 2 * potentialEnergy G m₁ m₂ m₃ (r₁ t) (r₂ t) (r₃ t)) t := by
  -- the first derivative of the moment of inertia
  have hI : ∀ s : ℝ, HasDerivAt (fun u => momentOfInertia m₁ m₂ m₃ (r₁ u) (r₂ u) (r₃ u))
      (2 * (m₁ * ⟪r₁ s, v₁ s⟫ + m₂ * ⟪r₂ s, v₂ s⟫ + m₃ * ⟪r₃ s, v₃ s⟫)) s := by
    intro s
    have d₁ := (hasDerivAt_normSq r₁ v₁ hr₁ s).const_mul m₁
    have d₂ := (hasDerivAt_normSq r₂ v₂ hr₂ s).const_mul m₂
    have d₃ := (hasDerivAt_normSq r₃ v₃ hr₃ s).const_mul m₃
    have := (d₁.add d₂).add d₃
    simp only [momentOfInertia]
    convert this using 1
    ring
  have hderiv : (deriv fun s => momentOfInertia m₁ m₂ m₃ (r₁ s) (r₂ s) (r₃ s))
      = fun s => 2 * (m₁ * ⟪r₁ s, v₁ s⟫ + m₂ * ⟪r₂ s, v₂ s⟫ + m₃ * ⟪r₃ s, v₃ s⟫) :=
    funext fun s => (hI s).deriv
  rw [hderiv]
  -- the second derivative
  have e₁ := ((hr₁ t).inner ℝ (hv₁ t)).const_mul m₁
  have e₂ := ((hr₂ t).inner ℝ (hv₂ t)).const_mul m₂
  have e₃ := ((hr₃ t).inner ℝ (hv₃ t)).const_mul m₃
  have hsum := (((e₁.add e₂).add e₃).const_mul (2:ℝ))
  obtain ⟨s₁, s₂, s₃⟩ := hsep t
  have hvir := virial_identity G m₁ m₂ m₃ (r₁ t) (r₂ t) (r₃ t) s₁ s₂ s₃
  convert hsum using 1
  simp only [kineticEnergy]
  rw [← real_inner_self_eq_norm_sq (v₁ t), ← real_inner_self_eq_norm_sq (v₂ t),
    ← real_inner_self_eq_norm_sq (v₃ t)]
  linear_combination -2 * hvir

/-! ### Conservation of energy -/

/-- The total (kinetic minus potential) energy of a three-body configuration. -/
def totalEnergy (G m₁ m₂ m₃ : ℝ) (r₁ r₂ r₃ v₁ v₂ v₃ : E) : ℝ :=
  kineticEnergy m₁ m₂ m₃ v₁ v₂ v₃ - potentialEnergy G m₁ m₂ m₃ r₁ r₂ r₃

/-- Derivative of `t ↦ 1/‖w t‖` along a curve avoiding the origin. -/
theorem hasDerivAt_inv_norm (w v : ℝ → E) (hw : ∀ t, HasDerivAt w (v t) t) (t : ℝ)
    (h0 : w t ≠ 0) :
    HasDerivAt (fun s => (‖w s‖)⁻¹) (-(⟪w t, v t⟫ / ‖w t‖ ^ 3)) t := by
  have hq : HasDerivAt (fun s => ‖w s‖ ^ 2) (2 * ⟪w t, v t⟫) t := (hw t).norm_sq
  have hqpos : 0 < ‖w t‖ ^ 2 := by positivity
  have hne : ‖w t‖ ≠ 0 := by simpa using h0
  have hs : HasDerivAt (fun s => Real.sqrt (‖w s‖ ^ 2))
      (2 * ⟪w t, v t⟫ / (2 * Real.sqrt (‖w t‖ ^ 2))) t :=
    (Real.hasDerivAt_sqrt (ne_of_gt hqpos)).comp t hq |>.congr_deriv (by ring)
  have hnorm : ∀ s : ℝ, Real.sqrt (‖w s‖ ^ 2) = ‖w s‖ := fun s => Real.sqrt_sq (norm_nonneg _)
  simp only [hnorm] at hs
  have hn : HasDerivAt (fun s => ‖w s‖) (⟪w t, v t⟫ / ‖w t‖) t := hs.congr_deriv (by field_simp)
  have h := hn.inv hne
  convert h using 1
  field_simp

/-- Time derivative of the gravitational potential energy along a motion. -/
theorem hasDerivAt_potentialEnergy (G m₁ m₂ m₃ : ℝ) (r₁ r₂ r₃ v₁ v₂ v₃ : ℝ → E)
    (hr₁ : ∀ t, HasDerivAt r₁ (v₁ t) t) (hr₂ : ∀ t, HasDerivAt r₂ (v₂ t) t)
    (hr₃ : ∀ t, HasDerivAt r₃ (v₃ t) t)
    (hsep : ∀ t, r₁ t ≠ r₂ t ∧ r₂ t ≠ r₃ t ∧ r₃ t ≠ r₁ t) (t : ℝ) :
    HasDerivAt (fun s => potentialEnergy G m₁ m₂ m₃ (r₁ s) (r₂ s) (r₃ s))
      (-(G * m₁ * m₂ * ⟪r₁ t - r₂ t, v₁ t - v₂ t⟫ / ‖r₁ t - r₂ t‖ ^ 3)
        - G * m₂ * m₃ * ⟪r₂ t - r₃ t, v₂ t - v₃ t⟫ / ‖r₂ t - r₃ t‖ ^ 3
        - G * m₃ * m₁ * ⟪r₃ t - r₁ t, v₃ t - v₁ t⟫ / ‖r₃ t - r₁ t‖ ^ 3) t := by
  obtain ⟨s₁, s₂, s₃⟩ := hsep t
  have d₁ := (hasDerivAt_inv_norm (fun s => r₁ s - r₂ s) (fun s => v₁ s - v₂ s)
    (fun s => (hr₁ s).sub (hr₂ s)) t (sub_ne_zero.mpr s₁)).const_mul (G * m₁ * m₂)
  have d₂ := (hasDerivAt_inv_norm (fun s => r₂ s - r₃ s) (fun s => v₂ s - v₃ s)
    (fun s => (hr₂ s).sub (hr₃ s)) t (sub_ne_zero.mpr s₂)).const_mul (G * m₂ * m₃)
  have d₃ := (hasDerivAt_inv_norm (fun s => r₃ s - r₁ s) (fun s => v₃ s - v₁ s)
    (fun s => (hr₃ s).sub (hr₁ s)) t (sub_ne_zero.mpr s₃)).const_mul (G * m₃ * m₁)
  have h := (d₁.add d₂).add d₃
  simp only [potentialEnergy, div_eq_mul_inv]
  convert h using 1
  ring

/-- **Pairwise power identity.** The work done by the mutual gravitational forces of a
pair equals minus the time derivative of its potential energy. -/
theorem pair_power (G mi mj : ℝ) (ri rj vi vj : E) (h : ri ≠ rj) :
    mi * ⟪vi, (G * mj / ‖rj - ri‖ ^ 3) • (rj - ri)⟫
      + mj * ⟪vj, (G * mi / ‖ri - rj‖ ^ 3) • (ri - rj)⟫
      = -(G * mi * mj * ⟪ri - rj, vi - vj⟫ / ‖ri - rj‖ ^ 3) := by
  have hd : 0 < ‖ri - rj‖ := by simpa [sub_eq_zero] using h
  have hsym : ‖rj - ri‖ = ‖ri - rj‖ := norm_sub_rev _ _
  rw [hsym, real_inner_smul_right, real_inner_smul_right]
  have h1 : ⟪vi, rj - ri⟫ + ⟪vj, ri - rj⟫ = -⟪ri - rj, vi - vj⟫ := by
    simp only [inner_sub_left, inner_sub_right, real_inner_comm vi ri, real_inner_comm vi rj,
      real_inner_comm vj ri, real_inner_comm vj rj]
    ring
  field_simp
  linear_combination (mi * G * mj) * h1

/-- Time derivative of the kinetic energy along a Newtonian motion. -/
theorem hasDerivAt_kineticEnergy (G m₁ m₂ m₃ : ℝ) (r₁ r₂ r₃ v₁ v₂ v₃ : ℝ → E)
    (hv₁ : ∀ t, HasDerivAt v₁ (newtonianAccel G m₂ m₃ (r₁ t) (r₂ t) (r₃ t)) t)
    (hv₂ : ∀ t, HasDerivAt v₂ (newtonianAccel G m₃ m₁ (r₂ t) (r₃ t) (r₁ t)) t)
    (hv₃ : ∀ t, HasDerivAt v₃ (newtonianAccel G m₁ m₂ (r₃ t) (r₁ t) (r₂ t)) t) (t : ℝ) :
    HasDerivAt (fun s => kineticEnergy m₁ m₂ m₃ (v₁ s) (v₂ s) (v₃ s))
      (m₁ * ⟪v₁ t, newtonianAccel G m₂ m₃ (r₁ t) (r₂ t) (r₃ t)⟫
        + m₂ * ⟪v₂ t, newtonianAccel G m₃ m₁ (r₂ t) (r₃ t) (r₁ t)⟫
        + m₃ * ⟪v₃ t, newtonianAccel G m₁ m₂ (r₃ t) (r₁ t) (r₂ t)⟫) t := by
  have d₁ := ((hv₁ t).norm_sq).const_mul m₁
  have d₂ := ((hv₂ t).norm_sq).const_mul m₂
  have d₃ := ((hv₃ t).norm_sq).const_mul m₃
  have h := ((d₁.add d₂).add d₃).div_const 2
  simp only [kineticEnergy]
  convert h using 1
  ring

/-- **Conservation of energy for the Newtonian three-body problem.**
Along any collision-free solution the total energy is constant in time. -/
theorem energy_conservation (G m₁ m₂ m₃ : ℝ) (r₁ r₂ r₃ v₁ v₂ v₃ : ℝ → E)
    (hr₁ : ∀ t, HasDerivAt r₁ (v₁ t) t) (hr₂ : ∀ t, HasDerivAt r₂ (v₂ t) t)
    (hr₃ : ∀ t, HasDerivAt r₃ (v₃ t) t)
    (hv₁ : ∀ t, HasDerivAt v₁ (newtonianAccel G m₂ m₃ (r₁ t) (r₂ t) (r₃ t)) t)
    (hv₂ : ∀ t, HasDerivAt v₂ (newtonianAccel G m₃ m₁ (r₂ t) (r₃ t) (r₁ t)) t)
    (hv₃ : ∀ t, HasDerivAt v₃ (newtonianAccel G m₁ m₂ (r₃ t) (r₁ t) (r₂ t)) t)
    (hsep : ∀ t, r₁ t ≠ r₂ t ∧ r₂ t ≠ r₃ t ∧ r₃ t ≠ r₁ t) (t : ℝ) :
    totalEnergy G m₁ m₂ m₃ (r₁ t) (r₂ t) (r₃ t) (v₁ t) (v₂ t) (v₃ t)
      = totalEnergy G m₁ m₂ m₃ (r₁ 0) (r₂ 0) (r₃ 0) (v₁ 0) (v₂ 0) (v₃ 0) := by
  have hzero : ∀ s : ℝ, HasDerivAt
      (fun u => totalEnergy G m₁ m₂ m₃ (r₁ u) (r₂ u) (r₃ u) (v₁ u) (v₂ u) (v₃ u)) 0 s := by
    intro s
    have hT := hasDerivAt_kineticEnergy G m₁ m₂ m₃ r₁ r₂ r₃ v₁ v₂ v₃ hv₁ hv₂ hv₃ s
    have hU := hasDerivAt_potentialEnergy G m₁ m₂ m₃ r₁ r₂ r₃ v₁ v₂ v₃ hr₁ hr₂ hr₃ hsep s
    obtain ⟨s₁, s₂, s₃⟩ := hsep s
    have p₁ := pair_power G m₁ m₂ (r₁ s) (r₂ s) (v₁ s) (v₂ s) s₁
    have p₂ := pair_power G m₂ m₃ (r₂ s) (r₃ s) (v₂ s) (v₃ s) s₂
    have p₃ := pair_power G m₃ m₁ (r₃ s) (r₁ s) (v₃ s) (v₁ s) s₃
    have heq : m₁ * ⟪v₁ s, newtonianAccel G m₂ m₃ (r₁ s) (r₂ s) (r₃ s)⟫
        + m₂ * ⟪v₂ s, newtonianAccel G m₃ m₁ (r₂ s) (r₃ s) (r₁ s)⟫
        + m₃ * ⟪v₃ s, newtonianAccel G m₁ m₂ (r₃ s) (r₁ s) (r₂ s)⟫
        = -(G * m₁ * m₂ * ⟪r₁ s - r₂ s, v₁ s - v₂ s⟫ / ‖r₁ s - r₂ s‖ ^ 3)
          - G * m₂ * m₃ * ⟪r₂ s - r₃ s, v₂ s - v₃ s⟫ / ‖r₂ s - r₃ s‖ ^ 3
          - G * m₃ * m₁ * ⟪r₃ s - r₁ s, v₃ s - v₁ s⟫ / ‖r₃ s - r₁ s‖ ^ 3 := by
      simp only [newtonianAccel, inner_add_right]
      linear_combination p₁ + p₂ + p₃
    have hsub := hT.sub hU
    rw [heq, sub_self] at hsub
    exact hsub
  have hdiff : Differentiable ℝ
      (fun u => totalEnergy G m₁ m₂ m₃ (r₁ u) (r₂ u) (r₃ u) (v₁ u) (v₂ u) (v₃ u)) :=
    fun s => (hzero s).differentiableAt
  exact is_const_of_deriv_eq_zero hdiff (fun s => (hzero s).deriv) t 0

/-! ### Positive energy forces escape -/

/-- A twice-differentiable function with second derivative bounded below by `c > 0`
dominates the corresponding parabola on `[0, ∞)`. -/
theorem quadratic_lower_bound (f g h : ℝ → ℝ) (c : ℝ)
    (hg : ∀ t, HasDerivAt f (g t) t) (hh : ∀ t, HasDerivAt g (h t) t)
    (hcc : ∀ t, c ≤ h t) {t : ℝ} (ht : 0 ≤ t) :
    f 0 + g 0 * t + c / 2 * t ^ 2 ≤ f t := by
  have hφ : ∀ s : ℝ, HasDerivAt (fun u => g u - c * u) (h s - c) s := fun s =>
    (hh s).sub ((hasDerivAt_id s).const_mul c |>.congr_deriv (by ring))
  have hgmono : ∀ s : ℝ, 0 ≤ s → g 0 + c * s ≤ g s := by
    have hmono : Monotone (fun u => g u - c * u) := by
      apply monotone_of_deriv_nonneg
      · exact fun s => (hφ s).differentiableAt
      · intro s; rw [(hφ s).deriv]; linarith [hcc s]
    intro s hs
    have := hmono hs
    simp at this
    linarith
  have hψ : ∀ s : ℝ, HasDerivAt (fun u => f u - (f 0 + g 0 * u + c / 2 * u ^ 2))
      (g s - (g 0 + c * s)) s := by
    intro s
    have h1 : HasDerivAt (fun u : ℝ => f 0 + g 0 * u + c / 2 * u ^ 2) (g 0 + c * s) s := by
      have ha := ((hasDerivAt_id s).const_mul (g 0)).const_add (f 0)
      have h2 : HasDerivAt (fun u : ℝ => c / 2 * u ^ 2) (c * s) s := by
        have := (hasDerivAt_pow 2 s).const_mul (c / 2)
        convert this using 1
        push_cast; ring
      have := ha.add h2
      convert this using 1
      ring
    exact (hg s).sub h1
  have hmono2 : MonotoneOn (fun u => f u - (f 0 + g 0 * u + c / 2 * u ^ 2)) (Set.Ici 0) := by
    apply monotoneOn_of_deriv_nonneg (convex_Ici 0)
    · exact fun s _ => ((hψ s).differentiableAt.continuousAt).continuousWithinAt
    · exact fun s _ => (hψ s).differentiableAt.differentiableWithinAt
    · intro s hs
      rw [(hψ s).deriv]
      simp only [interior_Ici, Set.mem_Ioi] at hs
      linarith [hgmono s hs.le]
  have := hmono2 Set.self_mem_Ici (Set.mem_Ici.mpr ht) ht
  simp at this
  linarith

/-- A parabola with positive leading coefficient tends to infinity. -/
theorem tendsto_quadratic_atTop (A B c : ℝ) (hc : 0 < c) :
    Tendsto (fun t : ℝ => A + B * t + c / 2 * t ^ 2) atTop atTop := by
  have h1 : Tendsto (fun t : ℝ => c / 2 * t + B) atTop atTop :=
    Filter.tendsto_atTop_add_const_right _ B
      (Filter.Tendsto.const_mul_atTop (by linarith) tendsto_id)
  have h3 : Tendsto (fun t : ℝ => t * (c / 2 * t + B) + A) atTop atTop :=
    Filter.tendsto_atTop_add_const_right _ A
      (Filter.Tendsto.atTop_mul_atTop₀ tendsto_id h1)
  exact h3.congr fun t => by ring

/-- **Positive energy forces escape (Lagrange–Jacobi).**
If along a three-body solution the total energy `T − U` stays at least `E₀ > 0`, then the
moment of inertia tends to `+∞`. Consequently, bounded — in particular recurrent or
chaotic — three-body motion requires non-positive energy. -/
theorem positive_energy_escape (G m₁ m₂ m₃ E₀ : ℝ) (hG : 0 ≤ G) (hm₁ : 0 ≤ m₁)
    (hm₂ : 0 ≤ m₂) (hm₃ : 0 ≤ m₃) (hE₀ : 0 < E₀) (r₁ r₂ r₃ v₁ v₂ v₃ : ℝ → E)
    (hr₁ : ∀ t, HasDerivAt r₁ (v₁ t) t) (hr₂ : ∀ t, HasDerivAt r₂ (v₂ t) t)
    (hr₃ : ∀ t, HasDerivAt r₃ (v₃ t) t)
    (hv₁ : ∀ t, HasDerivAt v₁ (newtonianAccel G m₂ m₃ (r₁ t) (r₂ t) (r₃ t)) t)
    (hv₂ : ∀ t, HasDerivAt v₂ (newtonianAccel G m₃ m₁ (r₂ t) (r₃ t) (r₁ t)) t)
    (hv₃ : ∀ t, HasDerivAt v₃ (newtonianAccel G m₁ m₂ (r₃ t) (r₁ t) (r₂ t)) t)
    (hsep : ∀ t, r₁ t ≠ r₂ t ∧ r₂ t ≠ r₃ t ∧ r₃ t ≠ r₁ t)
    (henergy : ∀ t, E₀ ≤ kineticEnergy m₁ m₂ m₃ (v₁ t) (v₂ t) (v₃ t)
      - potentialEnergy G m₁ m₂ m₃ (r₁ t) (r₂ t) (r₃ t)) :
    Tendsto (fun t => momentOfInertia m₁ m₂ m₃ (r₁ t) (r₂ t) (r₃ t)) atTop atTop := by
  set I : ℝ → ℝ := fun t => momentOfInertia m₁ m₂ m₃ (r₁ t) (r₂ t) (r₃ t) with hIdef
  set h : ℝ → ℝ := fun t => 4 * kineticEnergy m₁ m₂ m₃ (v₁ t) (v₂ t) (v₃ t)
    - 2 * potentialEnergy G m₁ m₂ m₃ (r₁ t) (r₂ t) (r₃ t) with hhdef
  have hLJ : ∀ t, HasDerivAt (deriv I) (h t) t :=
    fun t => lagrange_jacobi G m₁ m₂ m₃ r₁ r₂ r₃ v₁ v₂ v₃ hr₁ hr₂ hr₃ hv₁ hv₂ hv₃ hsep t
  have hI : ∀ t, HasDerivAt I (deriv I t) t := by
    intro t
    have d₁ := (hasDerivAt_normSq r₁ v₁ hr₁ t).const_mul m₁
    have d₂ := (hasDerivAt_normSq r₂ v₂ hr₂ t).const_mul m₂
    have d₃ := (hasDerivAt_normSq r₃ v₃ hr₃ t).const_mul m₃
    have hd : HasDerivAt I
        (m₁ * (2 * ⟪r₁ t, v₁ t⟫) + m₂ * (2 * ⟪r₂ t, v₂ t⟫) + m₃ * (2 * ⟪r₃ t, v₃ t⟫)) t :=
      (d₁.add d₂).add d₃
    rw [hd.deriv]
    exact hd
  -- second derivative is at least `4 E₀`
  have hbound : ∀ t, 4 * E₀ ≤ h t := by
    intro t
    have hU := potentialEnergy_nonneg hG hm₁ hm₂ hm₃ (r₁ t) (r₂ t) (r₃ t)
    have := henergy t
    simp only [hhdef]
    linarith
  have hquad : ∀ t : ℝ, 0 ≤ t → I 0 + deriv I 0 * t + (4 * E₀) / 2 * t ^ 2 ≤ I t :=
    fun t ht => quadratic_lower_bound I (deriv I) h (4 * E₀) hI hLJ hbound ht
  have hlim := tendsto_quadratic_atTop (I 0) (deriv I 0) (4 * E₀) (by linarith)
  refine tendsto_atTop_mono' atTop ?_ hlim
  filter_upwards [eventually_ge_atTop (0:ℝ)] with t ht
  exact hquad t ht

/-- **Positive initial energy forces escape.** Combining the Lagrange–Jacobi identity with
conservation of energy: if the three-body system starts with strictly positive total
energy, its moment of inertia grows without bound. Hence every bounded (in particular
every recurrent or chaotic) collision-free three-body motion has non-positive energy. -/
theorem positive_initial_energy_escape (G m₁ m₂ m₃ : ℝ) (hG : 0 ≤ G) (hm₁ : 0 ≤ m₁)
    (hm₂ : 0 ≤ m₂) (hm₃ : 0 ≤ m₃) (r₁ r₂ r₃ v₁ v₂ v₃ : ℝ → E)
    (hr₁ : ∀ t, HasDerivAt r₁ (v₁ t) t) (hr₂ : ∀ t, HasDerivAt r₂ (v₂ t) t)
    (hr₃ : ∀ t, HasDerivAt r₃ (v₃ t) t)
    (hv₁ : ∀ t, HasDerivAt v₁ (newtonianAccel G m₂ m₃ (r₁ t) (r₂ t) (r₃ t)) t)
    (hv₂ : ∀ t, HasDerivAt v₂ (newtonianAccel G m₃ m₁ (r₂ t) (r₃ t) (r₁ t)) t)
    (hv₃ : ∀ t, HasDerivAt v₃ (newtonianAccel G m₁ m₂ (r₃ t) (r₁ t) (r₂ t)) t)
    (hsep : ∀ t, r₁ t ≠ r₂ t ∧ r₂ t ≠ r₃ t ∧ r₃ t ≠ r₁ t)
    (hE₀ : 0 < totalEnergy G m₁ m₂ m₃ (r₁ 0) (r₂ 0) (r₃ 0) (v₁ 0) (v₂ 0) (v₃ 0)) :
    Tendsto (fun t => momentOfInertia m₁ m₂ m₃ (r₁ t) (r₂ t) (r₃ t)) atTop atTop := by
  refine positive_energy_escape G m₁ m₂ m₃ _ hG hm₁ hm₂ hm₃ hE₀ r₁ r₂ r₃ v₁ v₂ v₃
    hr₁ hr₂ hr₃ hv₁ hv₂ hv₃ hsep (fun t => ?_)
  have := energy_conservation G m₁ m₂ m₃ r₁ r₂ r₃ v₁ v₂ v₃ hr₁ hr₂ hr₃ hv₁ hv₂ hv₃ hsep t
  simp only [totalEnergy] at this ⊢
  linarith [this]

end ThreeBody