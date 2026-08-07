/-
  Jacobi fields, conjugate points, and the Riccati ↔ Sturm–Liouville bridge.

  The expansion `θ` of a hypersurface-orthogonal geodesic congruence and the associated
  Jacobi field `y` (the transverse "area radius") are related by the classical
  substitution

      θ = m * y' / y,      y'' = -(Ric(k,k) / m) * y,

  which converts the *Riccati* form of the Raychaudhuri equation into the *linear*
  Jacobi (Sturm–Liouville) equation.  Under this bridge:

  * blow-up of `θ` in finite affine parameter  ↔  a zero of `y`, i.e. a conjugate point;
  * the Penrose focusing bound `m / |θ₀|`      ↔  the elementary concavity bound
    `y₀ / |y'₀|` for a concave positive function;
  * the Bonnet–Myers bound `π √(m/ε)`          ↔  Sturm comparison with `sin(√(ε/m) t)`.

  This file formalizes the bridge in both directions and gives *two independent proofs*
  of the length bound under a strict energy condition — one by transporting the Riccati
  (Prüfer) result of `MyersFocusing` through the bridge, one by a direct Wronskian /
  Sturm comparison argument — providing an internal consistency check of the framework.
-/

import Physics.Spacetime.MyersFocusing

open Set

namespace Catalog.Physics.Spacetime

/-! ### Concavity and conjugate points -/

section Concavity

variable {T : ℝ} {y y' y'' : ℝ → ℝ}

/-- A function with non-positive second derivative has non-increasing derivative. -/
theorem deriv_le_initial_of_second_deriv_nonpos
    (hd' : ∀ x ∈ Icc (0 : ℝ) T, HasDerivAt y' (y'' x) x)
    (hcc : ∀ x ∈ Ico (0 : ℝ) T, y'' x ≤ 0) :
    ∀ t ∈ Icc (0 : ℝ) T, y' t ≤ y' 0 := by
  intro t ht
  refine image_le_of_deriv_right_le_deriv_boundary (f := y') (f' := y'')
    (B := fun _ => y' 0) (B' := fun _ => 0) ?_ ?_ le_rfl ?_ ?_ ?_ ht
  · exact fun x hx => (hd' x hx).continuousAt.continuousWithinAt
  · exact fun x hx => (hd' x (Ico_subset_Icc_self hx)).hasDerivWithinAt
  · exact fun x _ => continuousWithinAt_const
  · exact fun x _ => (hasDerivAt_const x _).hasDerivWithinAt
  · exact hcc

/-- **Tangent line bound.**  A concave function lies below its tangent at `0`. -/
theorem le_tangent_of_second_deriv_nonpos
    (hd : ∀ x ∈ Icc (0 : ℝ) T, HasDerivAt y (y' x) x)
    (hd' : ∀ x ∈ Icc (0 : ℝ) T, HasDerivAt y' (y'' x) x)
    (hcc : ∀ x ∈ Ico (0 : ℝ) T, y'' x ≤ 0) :
    ∀ t ∈ Icc (0 : ℝ) T, y t ≤ y 0 + y' 0 * t := by
  have hmono := deriv_le_initial_of_second_deriv_nonpos hd' hcc
  intro t ht
  refine image_le_of_deriv_right_le_deriv_boundary (f := y) (f' := y')
    (B := fun s => y 0 + y' 0 * s) (B' := fun _ => y' 0) ?_ ?_ ?_ ?_ ?_ ?_ ht
  · exact fun x hx => (hd x hx).continuousAt.continuousWithinAt
  · exact fun x hx => (hd x (Ico_subset_Icc_self hx)).hasDerivWithinAt
  · simp
  · fun_prop
  · intro x _
    simpa using (((hasDerivAt_id x).const_mul (y' 0)).const_add (y 0)).hasDerivWithinAt
  · exact fun x hx => hmono x (Ico_subset_Icc_self hx)

/-- **Existence of a conjugate point.**  A positive concave function with negative initial
slope must vanish, and it does so no later than the affine parameter `y₀ / |y'₀|` — the
Jacobi-field form of the Penrose focusing bound. -/
theorem exists_conjugate_point {y y' y'' : ℝ → ℝ} (hy0 : 0 < y 0) (hy'0 : y' 0 < 0)
    (hd : ∀ x ∈ Icc (0 : ℝ) (y 0 / (-y' 0)), HasDerivAt y (y' x) x)
    (hd' : ∀ x ∈ Icc (0 : ℝ) (y 0 / (-y' 0)), HasDerivAt y' (y'' x) x)
    (hcc : ∀ x ∈ Ico (0 : ℝ) (y 0 / (-y' 0)), y'' x ≤ 0) :
    ∃ t ∈ Ioc (0 : ℝ) (y 0 / (-y' 0)), y t = 0 := by
  set T : ℝ := y 0 / (-y' 0) with hT
  have hTpos : 0 < T := div_pos hy0 (neg_pos.2 hy'0)
  have htan := le_tangent_of_second_deriv_nonpos hd hd' hcc T (right_mem_Icc.2 hTpos.le)
  have hne : y' 0 ≠ 0 := ne_of_lt hy'0
  have hzero : y 0 + y' 0 * T = 0 := by
    rw [hT]
    field_simp
    ring
  have hyT : y T ≤ 0 := by linarith
  have hcont : ContinuousOn y (Icc 0 T) := fun x hx => (hd x hx).continuousAt.continuousWithinAt
  have hmem : (0 : ℝ) ∈ Icc (y T) (y 0) := ⟨hyT, hy0.le⟩
  obtain ⟨t, ht, hyt⟩ := intermediate_value_Icc' hTpos.le hcont hmem
  refine ⟨t, ⟨?_, ht.2⟩, hyt⟩
  rcases lt_or_eq_of_le ht.1 with h | h
  · exact h
  · exact absurd (h ▸ hyt) (ne_of_gt hy0)

end Concavity

/-! ### Jacobi fields and the bridge to the Riccati picture -/

/-- A **Jacobi field** along a geodesic congruence: a positive solution of the linear
Sturm–Liouville equation `y'' = -(Ric(k,k)/m) y` on `[0, L)`, satisfying the energy
condition `Ric(k,k) ≥ 0`.  Positivity of `y` says that no conjugate point has occurred
yet on `[0, L)`. -/
structure JacobiField (m L : ℝ) where
  /-- Transverse area radius of the congruence. -/
  y : ℝ → ℝ
  /-- Its affine derivative. -/
  y' : ℝ → ℝ
  /-- Its second affine derivative. -/
  y'' : ℝ → ℝ
  /-- The curvature focusing term `Ric(k,k)`. -/
  ric : ℝ → ℝ
  hasDeriv : ∀ t ∈ Ico (0 : ℝ) L, HasDerivAt y (y' t) t
  hasDeriv' : ∀ t ∈ Ico (0 : ℝ) L, HasDerivAt y' (y'' t) t
  jacobi : ∀ t ∈ Ico (0 : ℝ) L, y'' t = -(ric t / m) * y t
  ric_nonneg : ∀ t ∈ Ico (0 : ℝ) L, 0 ≤ ric t
  pos : ∀ t ∈ Ico (0 : ℝ) L, 0 < y t

namespace JacobiField

variable {m L : ℝ} (J : JacobiField m L)

/-- **The Riccati bridge.**  A Jacobi field induces a shear-free geodesic congruence with
expansion `θ = m y'/y` satisfying the Raychaudhuri equation with the same Ricci term. -/
noncomputable def toCongruence (hm : 0 < m) : GeodesicCongruence m L where
  expansion := fun t => m * J.y' t / J.y t
  expansionDot := fun t => -(m * J.y' t / J.y t) ^ 2 / m - J.ric t
  shearSq := fun _ => 0
  ricci := J.ric
  hasDeriv := by
    intro t ht
    have hne : J.y t ≠ 0 := ne_of_gt (J.pos t ht)
    have h := ((J.hasDeriv' t ht).const_mul m).div (J.hasDeriv t ht) hne
    convert h using 1
    rw [J.jacobi t ht]
    field_simp
    ring
  raychaudhuri := by intro t _; ring
  shearSq_nonneg := by intro t _; exact le_rfl
  energy_condition := J.ric_nonneg

@[simp] theorem toCongruence_expansion (hm : 0 < m) (t : ℝ) :
    (J.toCongruence hm).expansion t = m * J.y' t / J.y t := rfl

/-- **Focusing for Jacobi fields, transported from the Riccati picture.**  If the field is
initially decreasing, it must reach a conjugate point by affine parameter `y₀ / |y'₀|`;
equivalently, a positive Jacobi field cannot survive beyond that parameter. -/
theorem length_le_of_initial_decrease (hm : 0 < m) (hL : 0 < L) (hy'0 : J.y' 0 < 0) :
    L ≤ J.y 0 / (-J.y' 0) := by
  have h0 : (0 : ℝ) ∈ Ico (0 : ℝ) L := ⟨le_rfl, hL⟩
  have hy0 : 0 < J.y 0 := J.pos 0 h0
  have hθ0 : (J.toCongruence hm).expansion 0 < 0 := by
    simp only [toCongruence_expansion]
    exact div_neg_of_neg_of_pos (mul_neg_of_pos_of_neg hm hy'0) hy0
  have hb := (J.toCongruence hm).affine_length_le hm hθ0
  have heq : m / (-((J.toCongruence hm).expansion 0)) = J.y 0 / (-J.y' 0) := by
    simp only [toCongruence_expansion]
    have h1 : -(m * J.y' 0 / J.y 0) = m * (-J.y' 0) / J.y 0 := by ring
    rw [h1, div_div_eq_mul_div, mul_div_mul_left _ _ hm.ne']
  rwa [heq] at hb

/-- **Bonnet–Myers for Jacobi fields, route 1: through the Riccati bridge.**  A positive
Jacobi field with `Ric(k,k) ≥ ε > 0` exists only for affine parameter `< π √(m/ε)`. -/
theorem length_le_of_strict_energy (hm : 0 < m) {eps : ℝ} (he : 0 < eps)
    (hstrict : ∀ t ∈ Ico (0 : ℝ) L, eps ≤ J.ric t) :
    L ≤ Real.pi * Real.sqrt (m / eps) :=
  (J.toCongruence hm).affine_length_le_of_strict_energy hm he hstrict

end JacobiField

/-! ### Sturm comparison: an independent route to the Bonnet–Myers bound -/

section Sturm

variable {m eps L : ℝ} {y y' y'' : ℝ → ℝ}

/-- **Sturm comparison / Wronskian argument.**  If `y > 0` on `[0, L)` and
`y'' ≤ -(ε/m) y` with `ε, m > 0`, then `L ≤ π √(m/ε)`.  This is proved directly from the
monotonicity of the Wronskian `W = y' s - y s'` against the comparison solution
`s(t) = sin(√(ε/m) t)`, with no reference to the Riccati equation; it reproves
`JacobiField.length_le_of_strict_energy` by a completely different route. -/
theorem sturm_length_bound (hm : 0 < m) (he : 0 < eps)
    (hd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt y (y' x) x)
    (hd' : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt y' (y'' x) x)
    (hpos : ∀ x ∈ Ico (0 : ℝ) L, 0 < y x)
    (hcomp : ∀ x ∈ Ico (0 : ℝ) L, y'' x ≤ -(eps / m) * y x) :
    L ≤ Real.pi * Real.sqrt (m / eps) := by
  set b : ℝ := Real.sqrt (eps / m) with hb
  have hbpos : 0 < b := Real.sqrt_pos.2 (div_pos he hm)
  have hbsq : b ^ 2 = eps / m := Real.sq_sqrt (le_of_lt (div_pos he hm))
  have hpi : Real.pi / b = Real.pi * Real.sqrt (m / eps) := by
    have h1 : Real.sqrt (m / eps) * b = 1 := by
      rw [hb, ← Real.sqrt_mul (by positivity)]
      rw [show m / eps * (eps / m) = 1 by field_simp]
      exact Real.sqrt_one
    field_simp
    nlinarith [h1]
  by_contra hcon
  push_neg at hcon
  rw [← hpi] at hcon
  -- the comparison interval `[0, π/b]` lies inside the domain
  set T : ℝ := Real.pi / b with hT
  have hTpos : 0 < T := div_pos Real.pi_pos hbpos
  have hsubIcc : Icc (0 : ℝ) T ⊆ Ico (0 : ℝ) L := fun x hx =>
    ⟨hx.1, lt_of_le_of_lt hx.2 hcon⟩
  have hsubIco : Ico (0 : ℝ) T ⊆ Ico (0 : ℝ) L := fun x hx =>
    ⟨hx.1, lt_trans hx.2 hcon⟩
  -- the comparison solution and the Wronskian
  set s : ℝ → ℝ := fun t => Real.sin (b * t) with hs
  set s' : ℝ → ℝ := fun t => b * Real.cos (b * t) with hs'
  have hds : ∀ x : ℝ, HasDerivAt s (s' x) x := by
    intro x
    have h1 : HasDerivAt (fun t : ℝ => b * t) b x := by
      simpa using (hasDerivAt_id x).const_mul b
    have h2 := (Real.hasDerivAt_sin (b * x)).comp x h1
    simp only [hs, hs', Function.comp_def] at *
    convert h2 using 1
    ring
  have hds' : ∀ x : ℝ, HasDerivAt s' (-(b ^ 2) * Real.sin (b * x)) x := by
    intro x
    have h1 : HasDerivAt (fun t : ℝ => b * t) b x := by
      simpa using (hasDerivAt_id x).const_mul b
    have h2 := ((Real.hasDerivAt_cos (b * x)).comp x h1).const_mul b
    convert h2 using 1
    ring
  set W : ℝ → ℝ := fun t => y' t * s t - y t * s' t with hW
  set W' : ℝ → ℝ := fun t => y'' t * s t + y t * (b ^ 2) * Real.sin (b * t) with hW'
  have hdW : ∀ x ∈ Ico (0 : ℝ) T, HasDerivAt W (W' x) x := by
    intro x hx
    have h1 := ((hd' x (hsubIco hx)).mul (hds x)).sub ((hd x (hsubIco hx)).mul (hds' x))
    convert h1 using 1
    simp only [hW', hs, hs']
    ring
  have hsin_nonneg : ∀ x ∈ Icc (0 : ℝ) T, 0 ≤ Real.sin (b * x) := by
    intro x hx
    refine Real.sin_nonneg_of_nonneg_of_le_pi (mul_nonneg hbpos.le hx.1) ?_
    have h := hx.2
    rw [hT, le_div_iff₀ hbpos] at h
    linarith [h]
  have hW'_nonpos : ∀ x ∈ Ico (0 : ℝ) T, W' x ≤ 0 := by
    intro x hx
    have hx' := hsubIco hx
    have h1 : y'' x ≤ -(eps / m) * y x := hcomp x hx'
    have h2 : 0 ≤ Real.sin (b * x) := hsin_nonneg x (Ico_subset_Icc_self hx)
    have h3 : y'' x * Real.sin (b * x) ≤ (-(eps / m) * y x) * Real.sin (b * x) :=
      mul_le_mul_of_nonneg_right h1 h2
    simp only [hW', hs]
    rw [hbsq]
    nlinarith [h3]
  -- the Wronskian is non-increasing on `[0, T]`
  have hWmono : ∀ t ∈ Icc (0 : ℝ) T, W t ≤ W 0 := by
    intro t ht
    refine image_le_of_deriv_right_le_deriv_boundary (f := W) (f' := W')
      (B := fun _ => W 0) (B' := fun _ => 0) ?_ ?_ le_rfl ?_ ?_ ?_ ht
    · intro x hx
      exact (((hd' x (hsubIcc hx)).mul (hds x)).sub
        ((hd x (hsubIcc hx)).mul (hds' x))).continuousAt.continuousWithinAt
    · exact fun x hx => (hdW x hx).hasDerivWithinAt
    · exact fun x _ => continuousWithinAt_const
    · exact fun x _ => (hasDerivAt_const x _).hasDerivWithinAt
    · exact hW'_nonpos
  -- but `W 0 < 0 < W T`
  have hy0 : 0 < y 0 := hpos 0 (hsubIco ⟨le_rfl, hTpos⟩)
  have hyT : 0 < y T := hpos T (hsubIcc (right_mem_Icc.2 hTpos.le))
  have hW0 : W 0 < 0 := by
    have : W 0 = -(y 0 * b) := by simp [hW, hs, hs']
    rw [this]
    have : 0 < y 0 * b := mul_pos hy0 hbpos
    linarith
  have hbT : b * T = Real.pi := by
    rw [hT]
    field_simp
  have hWT : 0 < W T := by
    have h1 : Real.sin (b * T) = 0 := by rw [hbT]; exact Real.sin_pi
    have h2 : Real.cos (b * T) = -1 := by rw [hbT]; exact Real.cos_pi
    have : W T = y T * b := by
      simp only [hW, hs, hs', h1, h2]
      ring
    rw [this]
    exact mul_pos hyT hbpos
  linarith [hWmono T (right_mem_Icc.2 hTpos.le)]

end Sturm

end Catalog.Physics.Spacetime