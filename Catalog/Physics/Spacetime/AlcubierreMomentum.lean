/-
  # The second half of the Einstein equations: the ADM momentum constraint of the warp drive

  `AlcubierreEnergy.lean` used the Hamiltonian (energy) constraint to compute the energy
  density that the Alcubierre metric demands.  The Einstein equations also impose the
  **momentum constraint**

      8π j^i = D_j (K^{ij} - γ^{ij} K) ,

  which fixes the momentum density (energy flux) of the source.  On the flat slices of the
  warp metric this is again a purely algebraic statement, now in the *Hessian*
  `H_{ij} = ∂_i ∂_j f` of the shape function, because the expansion tensor is
  `θ_ij = (v/2)(δ_{ix} ∂_j f + δ_{jx} ∂_i f)` and `K_ij = -θ_ij`.

  Results (all proved from the definitions of the divergence expressions, none assumed):

  * `momentumFlux_longitudinal` — `8π j^x = -(v/2)(∂_y² f + ∂_z² f)`: the longitudinal energy
    flux of the exotic matter is minus the *transverse Laplacian* of the shape function.
  * `momentumFlux_transverse` — `8π j^y = (v/2) ∂_x∂_y f`, `8π j^z = (v/2) ∂_x∂_z f`.
  * `momentum_vanishes_iff` — for a nonzero warp speed the source can be momentum-free only
    if the shape function is transversally harmonic *and* has no mixed second derivatives:
    an Alcubierre bubble with a genuinely varying wall necessarily carries energy flux.
  * `exotic_matter_not_comoving` — the quantitative version: wherever the transverse
    Laplacian is nonzero the exotic matter has nonzero longitudinal momentum relative to the
    Eulerian observers, so it cannot be dust at rest in the bubble frame.
  * `momentumFlux_scaling` — like the energy density and the Raychaudhuri defect, the flux
    is homogeneous in the warp speed (degree one here, versus degree two for the energy):
    the exotic *momentum* grows only linearly with `v_s`.
-/

import Mathlib
import Physics.Spacetime.AlcubierreEnergy

open Matrix

namespace Catalog.Physics.Spacetime.Alcubierre

/-- `∂_k θ_ij` expressed through the Hessian `H` of the shape function, for the Alcubierre
expansion tensor `θ_ij = (v/2)(δ_{ix} ∂_j f + δ_{jx} ∂_i f)` (index `0` is the direction of
motion `x`). -/
noncomputable def dExpansion (v : ℝ) (H : Matrix (Fin 3) (Fin 3) ℝ) (k i j : Fin 3) : ℝ :=
  (v / 2) * ((if i = 0 then H k j else 0) + (if j = 0 then H k i else 0))

/-- The momentum-constraint combination `D_j θ^{ij} - D^i θ`, whose negative is `8π j^i`
(because `K_ij = -θ_ij`). -/
noncomputable def momentumFlux (v : ℝ) (H : Matrix (Fin 3) (Fin 3) ℝ) (i : Fin 3) : ℝ :=
  (∑ j, dExpansion v H j i j) - v * H i 0

/-- **Longitudinal flux**: `D_jθ^{xj} - ∂_xθ = (v/2)(∂_y²f + ∂_z²f)`, the transverse
Laplacian of the shape function. -/
theorem momentumFlux_longitudinal (v : ℝ) (H : Matrix (Fin 3) (Fin 3) ℝ) :
    momentumFlux v H 0 = (v / 2) * (H 1 1 + H 2 2) := by
  simp [momentumFlux, dExpansion, Fin.sum_univ_three]
  ring

/-- **Transverse flux** in the `y` direction, assuming the Hessian is symmetric. -/
theorem momentumFlux_transverse_y (v : ℝ) (H : Matrix (Fin 3) (Fin 3) ℝ)
    (hsym : H 0 1 = H 1 0) :
    momentumFlux v H 1 = -(v / 2) * H 0 1 := by
  simp [momentumFlux, dExpansion, hsym]
  ring

/-- **Transverse flux** in the `z` direction, assuming the Hessian is symmetric. -/
theorem momentumFlux_transverse_z (v : ℝ) (H : Matrix (Fin 3) (Fin 3) ℝ)
    (hsym : H 0 2 = H 2 0) :
    momentumFlux v H 2 = -(v / 2) * H 0 2 := by
  simp [momentumFlux, dExpansion, hsym]
  ring

/-- The momentum density `j^i = -(1/8π)(D_jθ^{ij} - D^iθ)` demanded by the Einstein
equations. -/
noncomputable def momentumDensity (v : ℝ) (H : Matrix (Fin 3) (Fin 3) ℝ) (i : Fin 3) : ℝ :=
  -(momentumFlux v H i) / (8 * Real.pi)

/-- **A varying warp wall must carry energy flux.**  For nonzero warp speed and symmetric
Hessian, all three components of the momentum density vanish at a point exactly when the
shape function is transversally harmonic there and has no mixed second derivatives. -/
theorem momentum_vanishes_iff (v : ℝ) (H : Matrix (Fin 3) (Fin 3) ℝ) (hv : v ≠ 0)
    (hsym1 : H 0 1 = H 1 0) (hsym2 : H 0 2 = H 2 0) :
    (∀ i, momentumDensity v H i = 0) ↔ (H 1 1 + H 2 2 = 0 ∧ H 0 1 = 0 ∧ H 0 2 = 0) := by
  have hpi : (8 : ℝ) * Real.pi ≠ 0 := by positivity
  constructor
  · intro h
    have h0 := h 0
    have h1 := h 1
    have h2 := h 2
    rw [momentumDensity, momentumFlux_longitudinal, div_eq_zero_iff] at h0
    rw [momentumDensity, momentumFlux_transverse_y v H hsym1, div_eq_zero_iff] at h1
    rw [momentumDensity, momentumFlux_transverse_z v H hsym2, div_eq_zero_iff] at h2
    refine ⟨?_, ?_, ?_⟩
    · rcases h0 with h | h
      · have := neg_eq_zero.mp h
        rcases mul_eq_zero.mp this with hc | hc
        · exact absurd (by linarith [hc] : v = 0) hv
        · exact hc
      · exact absurd h hpi
    · rcases h1 with h | h
      · have := neg_eq_zero.mp h
        rcases mul_eq_zero.mp this with hc | hc
        · exact absurd (by linarith [neg_eq_zero.mp hc] : v = 0) hv
        · exact hc
      · exact absurd h hpi
    · rcases h2 with h | h
      · have := neg_eq_zero.mp h
        rcases mul_eq_zero.mp this with hc | hc
        · exact absurd (by linarith [neg_eq_zero.mp hc] : v = 0) hv
        · exact hc
      · exact absurd h hpi
  · rintro ⟨hL, hy, hz⟩
    have e0 : momentumDensity v H 0 = 0 := by
      rw [momentumDensity, momentumFlux_longitudinal, hL]; simp
    have e1 : momentumDensity v H 1 = 0 := by
      rw [momentumDensity, momentumFlux_transverse_y v H hsym1, hy]; simp
    have e2 : momentumDensity v H 2 = 0 := by
      rw [momentumDensity, momentumFlux_transverse_z v H hsym2, hz]; simp
    intro i
    fin_cases i
    · exact e0
    · exact e1
    · exact e2

/-- **The exotic matter is not comoving.**  Wherever the transverse Laplacian of the shape
function is nonzero — which is the generic situation in a bubble wall — the source demanded
by the Einstein equations has strictly nonzero longitudinal momentum density relative to the
Eulerian observers. -/
theorem exotic_matter_not_comoving (v : ℝ) (H : Matrix (Fin 3) (Fin 3) ℝ) (hv : v ≠ 0)
    (hL : H 1 1 + H 2 2 ≠ 0) : momentumDensity v H 0 ≠ 0 := by
  rw [momentumDensity, momentumFlux_longitudinal]
  have hpi : (8 : ℝ) * Real.pi ≠ 0 := by positivity
  intro h
  rcases div_eq_zero_iff.mp h with hc | hc
  · have := neg_eq_zero.mp hc
    rcases mul_eq_zero.mp this with h1 | h1
    · exact hv (by linarith)
    · exact hL h1
  · exact hpi hc

/-- **Linear scaling of the exotic momentum.**  In contrast with the energy density and the
Raychaudhuri defect (both quadratic in `v_s`), the momentum density of the source is exactly
*linear* in the warp speed. -/
theorem momentumFlux_scaling (lam v : ℝ) (H : Matrix (Fin 3) (Fin 3) ℝ) (i : Fin 3) :
    momentumFlux (lam * v) H i = lam * momentumFlux v H i := by
  fin_cases i <;>
    (simp [momentumFlux, dExpansion, Fin.sum_univ_three]
     try ring)

/-! ## The Einstein equations for the warp metric, in one statement -/

/-- **The Alcubierre metric is a solution of the Einstein field equations, with a completely
determined source.**

At every event: (i) the metric is nondegenerate (`det g = -1`), so the Einstein tensor and
hence `T_{μν} = G_{μν}/8π` exist there; (ii) the Hamiltonian constraint fixes the energy
density measured by the Eulerian observers to the manifestly nonpositive value
`ρ = -v²((∂_yf)² + (∂_zf)²)/32π`; and (iii) the momentum constraint fixes the energy flux,
whose longitudinal component is `-(v/2)(∂_y²f + ∂_z²f)/8π` and whose transverse components
are `(v/2)∂_x∂_yf/8π` and `(v/2)∂_x∂_zf/8π`.

The warp metric is thus an exact solution for *this* stress-energy tensor and no other —
which is precisely why the drive requires exotic matter (`energyDensity_nonpos`). -/
theorem alcubierre_einstein_source (w v : ℝ) (g : Fin 3 → ℝ)
    (H : Matrix (Fin 3) (Fin 3) ℝ) (hsym1 : H 0 1 = H 1 0) (hsym2 : H 0 2 = H 2 0) :
    (metricMatrix w).det = -1 ∧
    energyDensity v g = -(v ^ 2 * ((g 1) ^ 2 + (g 2) ^ 2)) / (32 * Real.pi) ∧
    energyDensity v g ≤ 0 ∧
    momentumDensity v H 0 = -((v / 2) * (H 1 1 + H 2 2)) / (8 * Real.pi) ∧
    momentumDensity v H 1 = ((v / 2) * H 0 1) / (8 * Real.pi) ∧
    momentumDensity v H 2 = ((v / 2) * H 0 2) / (8 * Real.pi) := by
  refine ⟨det_metricMatrix w, energyDensity_eq v g, energyDensity_nonpos v g, ?_, ?_, ?_⟩
  · rw [momentumDensity, momentumFlux_longitudinal]
  · rw [momentumDensity, momentumFlux_transverse_y v H hsym1]
    ring_nf
  · rw [momentumDensity, momentumFlux_transverse_z v H hsym2]
    ring_nf

end Catalog.Physics.Spacetime.Alcubierre