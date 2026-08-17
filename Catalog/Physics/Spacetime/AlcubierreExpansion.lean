/-
  # Volume expansion of the Alcubierre warp bubble

  The Eulerian observers of the Alcubierre spacetime (the observers orthogonal to the
  flat slices `t = const`) have four-velocity `n = (1, v_s f(r_s), 0, 0)`
  (`AlcubierreMetric.eulerian_unit`).  Because the slices are flat and the lapse is `1`,
  the expansion tensor of this congruence is the symmetrised gradient of the spatial
  vector field `n = (v_s f, 0, 0)`,

      θ_ij = ½ (∂_i n_j + ∂_j n_i),

  and the York expansion scalar is its trace `θ = v_s ∂_x f`.

  This file:

  * defines `expansionTensor` from the spatial gradient `g = ∇f` and computes its trace
    (`trace_expansionTensor`) and its full quadratic invariant
    (`expansion_quadratic_invariant`) — the algebraic heart of the negative-energy result
    proved in `AlcubierreEnergy.lean`;
  * differentiates the radial shape function through `r_s = √((x-x_s)² + y² + z²)`
    (`hasDerivAt_shape_radial`), and
  * proves the *signature of the warp drive*: with a decreasing shape function, space
    **expands strictly behind** the ship and **contracts strictly ahead** of it
    (`expansion_pos_behind`, `expansion_neg_ahead`), the expansion vanishing exactly on the
    plane through the ship (`expansion_zero_iff`).
-/

import Mathlib

open Matrix

namespace Catalog.Physics.Spacetime.Alcubierre

/-! ## The expansion tensor of the Eulerian congruence -/

/-- The expansion tensor `θ_ij = ½(∂_i n_j + ∂_j n_i)` of the Eulerian congruence
`n = (v f, 0, 0)`, expressed through the spatial gradient `g = ∇f` of the shape function
(components `g 0 = ∂_x f`, `g 1 = ∂_y f`, `g 2 = ∂_z f`). -/
noncomputable def expansionTensor (v : ℝ) (g : Fin 3 → ℝ) : Matrix (Fin 3) (Fin 3) ℝ :=
  !![v * g 0,     v * g 1 / 2, v * g 2 / 2;
     v * g 1 / 2, 0,           0;
     v * g 2 / 2, 0,           0]

/-- The York expansion scalar `θ = v_s ∂_x f`. -/
def expansionScalar (v : ℝ) (g : Fin 3 → ℝ) : ℝ := v * g 0

@[simp] theorem trace_expansionTensor (v : ℝ) (g : Fin 3 → ℝ) :
    (expansionTensor v g).trace = expansionScalar v g := by
  simp [expansionTensor, expansionScalar, Matrix.trace, Fin.sum_univ_three]

/-- The full quadratic invariant `θ_ij θ^ij` (spatial indices are raised with `δ`). -/
noncomputable def expansionSquaredNorm (v : ℝ) (g : Fin 3 → ℝ) : ℝ :=
  ∑ i, ∑ j, (expansionTensor v g i j) ^ 2

theorem expansionSquaredNorm_eq (v : ℝ) (g : Fin 3 → ℝ) :
    expansionSquaredNorm v g = v ^ 2 * (g 0) ^ 2 + v ^ 2 * ((g 1) ^ 2 + (g 2) ^ 2) / 2 := by
  simp [expansionSquaredNorm, expansionTensor, Fin.sum_univ_three]
  ring

/-- **The algebraic identity behind the exotic matter.**
`θ² - θ_ij θ^ij = -(v²/2)((∂_y f)² + (∂_z f)²) ≤ 0`: the trace-square of the expansion
tensor can never beat its full norm, and the deficit is exactly the transverse gradient. -/
theorem expansion_quadratic_invariant (v : ℝ) (g : Fin 3 → ℝ) :
    (expansionScalar v g) ^ 2 - expansionSquaredNorm v g
      = -(v ^ 2 / 2) * ((g 1) ^ 2 + (g 2) ^ 2) := by
  rw [expansionSquaredNorm_eq]
  simp [expansionScalar]
  ring

/-! ## Differentiating the shape function through the radial coordinate -/

/-- The bubble radial coordinate `r_s = √((x - x_s)² + y² + z²)`. -/
noncomputable def bubbleRadius (a x y z : ℝ) : ℝ :=
  Real.sqrt ((x - a) ^ 2 + y ^ 2 + z ^ 2)

theorem bubbleRadius_nonneg (a x y z : ℝ) : 0 ≤ bubbleRadius a x y z :=
  Real.sqrt_nonneg _

theorem bubbleRadius_sq (a x y z : ℝ) :
    (bubbleRadius a x y z) ^ 2 = (x - a) ^ 2 + y ^ 2 + z ^ 2 :=
  Real.sq_sqrt (by positivity)

theorem bubbleRadius_pos_iff (a x y z : ℝ) :
    0 < bubbleRadius a x y z ↔ ¬ (x = a ∧ y = 0 ∧ z = 0) := by
  constructor
  · rintro h ⟨hx, hy, hz⟩
    simp [bubbleRadius, hx, hy, hz] at h
  · intro h
    have hpos : 0 < (x - a) ^ 2 + y ^ 2 + z ^ 2 := by
      rcases lt_trichotomy ((x - a) ^ 2 + y ^ 2 + z ^ 2) 0 with hlt | heq | hgt
      · nlinarith [sq_nonneg (x - a), sq_nonneg y, sq_nonneg z]
      · exfalso
        have hx : x - a = 0 := by nlinarith [sq_nonneg (x - a), sq_nonneg y, sq_nonneg z]
        have hy : y = 0 := by nlinarith [sq_nonneg (x - a), sq_nonneg y, sq_nonneg z]
        have hz : z = 0 := by nlinarith [sq_nonneg (x - a), sq_nonneg y, sq_nonneg z]
        exact h ⟨by linarith, hy, hz⟩
      · exact hgt
    exact Real.sqrt_pos.mpr hpos

/-- **Chain rule through the bubble radius.**  If the shape function `f` is differentiable
at `r_s` with derivative `df`, then `x ↦ f(r_s(x,y,z))` is differentiable with derivative
`df · (x - x_s)/r_s`. -/
theorem hasDerivAt_shape_radial (f : ℝ → ℝ) (df a y z x : ℝ)
    (hr : 0 < bubbleRadius a x y z)
    (hf : HasDerivAt f df (bubbleRadius a x y z)) :
    HasDerivAt (fun ξ => f (bubbleRadius a ξ y z))
      (df * (x - a) / bubbleRadius a x y z) x := by
  have hq : HasDerivAt (fun ξ : ℝ => (ξ - a) ^ 2 + y ^ 2 + z ^ 2) (2 * (x - a)) x := by
    have h1 : HasDerivAt (fun ξ : ℝ => (ξ - a) ^ 2) (2 * (x - a)) x := by
      simpa using ((hasDerivAt_id x).sub_const a).pow 2
    simpa using (h1.add_const (y ^ 2)).add_const (z ^ 2)
  have hne : ((x - a) ^ 2 + y ^ 2 + z ^ 2) ≠ 0 := by
    have := hr
    rw [bubbleRadius] at this
    intro h
    rw [h] at this
    simp at this
  have hsqrt : HasDerivAt (fun ξ : ℝ => bubbleRadius a ξ y z)
      (2 * (x - a) / (2 * bubbleRadius a x y z)) x := by
    simpa [bubbleRadius] using hq.sqrt hne
  have := hf.comp x hsqrt
  have heq : df * (2 * (x - a) / (2 * bubbleRadius a x y z))
      = df * (x - a) / bubbleRadius a x y z := by
    field_simp
  simpa [heq] using this

/-! ## Expansion behind, contraction ahead -/

/-- The expansion scalar of the Alcubierre congruence at a point with bubble radius `r_s`,
for a shape function with radial derivative `df` at `r_s`. -/
noncomputable def radialExpansion (v df a x y z : ℝ) : ℝ :=
  v * (df * (x - a) / bubbleRadius a x y z)

/-- The radial expansion is exactly the York expansion `θ = v ∂_x f` of the gradient
obtained from the chain rule: consistency of the two descriptions. -/
theorem radialExpansion_eq_expansionScalar (v df a x y z : ℝ) :
    radialExpansion v df a x y z
      = expansionScalar v ![df * (x - a) / bubbleRadius a x y z,
                            df * y / bubbleRadius a x y z,
                            df * z / bubbleRadius a x y z] := by
  simp [radialExpansion, expansionScalar]

/-- **Space expands strictly behind the ship.**  For a decreasing shape function
(`df < 0`, which holds throughout the bubble wall since `f` falls from `1` to `0`) and a
superluminal-or-not positive warp speed, the York expansion is strictly positive at every
point behind the ship (`x < x_s`). -/
theorem expansion_pos_behind {v df a x y z : ℝ} (hv : 0 < v) (hdf : df < 0) (hx : x < a) :
    0 < radialExpansion v df a x y z := by
  have hr : 0 < bubbleRadius a x y z := by
    rw [bubbleRadius_pos_iff]
    rintro ⟨hxa, -, -⟩
    exact absurd hxa (ne_of_lt hx)
  have : 0 < df * (x - a) := mul_pos_of_neg_of_neg hdf (by linarith)
  exact mul_pos hv (div_pos this hr)

/-- **Space contracts strictly ahead of the ship.** -/
theorem expansion_neg_ahead {v df a x y z : ℝ} (hv : 0 < v) (hdf : df < 0) (hx : a < x) :
    radialExpansion v df a x y z < 0 := by
  have hr : 0 < bubbleRadius a x y z := by
    rw [bubbleRadius_pos_iff]
    rintro ⟨hxa, -, -⟩
    exact absurd hxa (ne_of_gt hx)
  have : df * (x - a) < 0 := mul_neg_of_neg_of_pos hdf (by linarith)
  have := div_neg_of_neg_of_pos this hr
  exact mul_neg_of_pos_of_neg hv this

/-- The expansion vanishes exactly on the transverse plane through the ship. -/
theorem expansion_zero_iff {v df a x y z : ℝ} (hv : 0 < v) (hdf : df < 0) :
    radialExpansion v df a x y z = 0 ↔ x = a := by
  constructor
  · intro h
    rcases lt_trichotomy x a with hlt | heq | hgt
    · exact absurd h (ne_of_gt (expansion_pos_behind hv hdf hlt))
    · exact heq
    · exact absurd h (ne_of_lt (expansion_neg_ahead hv hdf hgt))
  · intro h
    simp [radialExpansion, h]

/-- **Antisymmetry of the warp field.**  The contraction ahead exactly mirrors the
expansion behind: the expansion is an odd function of the longitudinal displacement.
This is the precise sense in which the bubble "pulls space in front and pushes it
behind", producing net transport with no local motion. -/
theorem expansion_odd (v df a s y z : ℝ) :
    radialExpansion v df a (a + s) y z = - radialExpansion v df a (a - s) y z := by
  have hrad : bubbleRadius a (a + s) y z = bubbleRadius a (a - s) y z := by
    simp [bubbleRadius]
  rw [radialExpansion, radialExpansion, hrad]
  ring

end Catalog.Physics.Spacetime.Alcubierre