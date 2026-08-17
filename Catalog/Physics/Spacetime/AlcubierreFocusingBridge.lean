/-
  # Bridge: the warp bubble as a Raychaudhuri energy defect

  `Physics/Spacetime/RaychaudhuriFocusing.lean` develops the differential-inequality engine
  of the Penrose–Hawking singularity theorems, including the *degraded* focusing theory in
  which the energy condition is violated by at most `c ≥ 0`:

      dθ/dλ ≤ -θ²/m + c .

  The Alcubierre bubble supplies exactly such a defect, and this file computes it.  Since
  the lapse is unity, the Eulerian observers of the warp metric are geodesic, and the ADM
  Hamiltonian constraint of `AlcubierreEnergy.lean` gives their energy density
  `16π ρ = θ² - θ_ij θ^ij = -(v²/2)((∂_y f)² + (∂_z f)²)`.  The natural, manifestly
  nonnegative *defect* of the warp field is therefore

      c_warp := -16π ρ = (v²/2)((∂_y f)² + (∂_z f)²) ≥ 0 .

  Results:

  * `warpDefect_eq` — the defect is exactly `-16π` times the Eulerian energy density.
  * `warpDefect_pos_iff` — it is strictly positive precisely on the toroidal exotic region.
  * `warp_defect_defeats_focusing_at_threshold` — at the critical convergence
    `θ₀² = m · c_warp` the singularity theorems fail: an *eternal*, never-focusing solution
    of the degraded Raychaudhuri inequality exists.  So the warp bubble's exotic matter is
    of precisely the strength needed to defeat geodesic focusing.
  * `warp_critical_convergence` / `warp_focusing_survives` — the sharp threshold: a
    congruence entering the bubble wall with `θ₀ < -v √(m (f_y² + f_z²)/2)` still focuses,
    within affine parameter `m|θ₀|/(θ₀² - m c_warp)`.  Below the threshold, focusing may
    fail.
  * `warp_defect_scaling` — the defect, like the energy, is quadratic in the warp speed:
    doubling `v_s` quadruples the amount of focusing the drive can defeat.
-/

import Mathlib
import Physics.Spacetime.AlcubierreEnergy
import Physics.Spacetime.RaychaudhuriFocusing

open Set

namespace Catalog.Physics.Spacetime.Alcubierre

/-- The Raychaudhuri **energy defect** supplied by the warp field:
`c_warp = -16π ρ = (v²/2)((∂_y f)² + (∂_z f)²)`. -/
noncomputable def warpDefect (v : ℝ) (g : Fin 3 → ℝ) : ℝ :=
  v ^ 2 / 2 * ((g 1) ^ 2 + (g 2) ^ 2)

/-- The defect is exactly `-16π` times the Eulerian energy density: a nonnegative measure of
how badly the warp bubble violates the energy condition. -/
theorem warpDefect_eq (v : ℝ) (g : Fin 3 → ℝ) :
    warpDefect v g = -(16 * Real.pi) * energyDensity v g := by
  rw [warpDefect, energyDensity_eq]
  have hpi : Real.pi ≠ 0 := Real.pi_ne_zero
  field_simp
  ring

theorem warpDefect_nonneg (v : ℝ) (g : Fin 3 → ℝ) : 0 ≤ warpDefect v g := by
  rw [warpDefect]; positivity

/-- The defect is positive exactly where the exotic matter lives. -/
theorem warpDefect_pos_iff (v : ℝ) (g : Fin 3 → ℝ) :
    0 < warpDefect v g ↔ v ≠ 0 ∧ ¬ (g 1 = 0 ∧ g 2 = 0) := by
  constructor
  · intro h
    rw [warpDefect] at h
    constructor
    · rintro rfl; simp at h
    · rintro ⟨h1, h2⟩; rw [h1, h2] at h; simp at h
  · rintro ⟨hv, hg⟩
    rw [warpDefect]
    have hv2 : 0 < v ^ 2 := pow_two_pos_of_ne_zero hv
    have := sq_add_sq_pos hg
    positivity

/-- **Quadratic scaling of the defect.**  Doubling the warp speed quadruples the amount of
geodesic focusing the drive is able to defeat. -/
theorem warpDefect_scaling (lam v : ℝ) (g : Fin 3 → ℝ) :
    warpDefect (lam * v) g = lam ^ 2 * warpDefect v g := by
  rw [warpDefect, warpDefect]; ring

/-- **The warp bubble defeats the singularity theorems at threshold.**
With the defect `c_warp > 0` supplied by the bubble wall, there is a solution of the
degraded Raychaudhuri inequality `θ' ≤ -θ²/m + c_warp` which starts converging
(`θ₀ < 0`) at the critical value `θ₀² = m c_warp` and yet never focuses: it is defined for
all affine parameters.  Hence the exotic matter of a warp drive is exactly of the strength
required to invalidate the Penrose–Hawking focusing conclusion. -/
theorem warp_defect_defeats_focusing_at_threshold {m v : ℝ} (g : Fin 3 → ℝ) (hm : 0 < m)
    (hv : v ≠ 0) (hg : ¬ (g 1 = 0 ∧ g 2 = 0)) :
    ∃ θ θ' : ℝ → ℝ,
      (∀ x : ℝ, HasDerivAt θ (θ' x) x) ∧
      (∀ x : ℝ, θ' x ≤ -(θ x) ^ 2 / m + warpDefect v g) ∧
      θ 0 < 0 ∧ (θ 0) ^ 2 = m * warpDefect v g :=
  Catalog.Physics.Spacetime.no_focusing_at_threshold hm ((warpDefect_pos_iff v g).mpr ⟨hv, hg⟩)

/-- **Sharp convergence threshold for surviving a warp wall.**
A geodesic congruence that enters the bubble wall converging faster than
`v √(m (f_y² + f_z²)/2)` still focuses: its affine domain is bounded by
`m|θ₀|/(θ₀² - m c_warp)`. -/
theorem warp_focusing_survives {m L v : ℝ} {θ θ' : ℝ → ℝ} (g : Fin 3 → ℝ) (hm : 0 < m)
    (hd : ∀ x ∈ Ico (0 : ℝ) L, HasDerivAt θ (θ' x) x)
    (hineq : ∀ x ∈ Ico (0 : ℝ) L, θ' x ≤ -(θ x) ^ 2 / m + warpDefect v g)
    (h0 : θ 0 < 0) (hthr : m * warpDefect v g < (θ 0) ^ 2) :
    L ≤ m * (-θ 0) / ((θ 0) ^ 2 - m * warpDefect v g) :=
  Catalog.Physics.Spacetime.focusing_domain_bound_of_energy_defect hm
    (warpDefect_nonneg v g) hd hineq h0 hthr

/-- The threshold in explicit form: `θ₀ < -v √(m (f_y² + f_z²)/2)` implies
`θ₀² > m c_warp`, so `warp_focusing_survives` applies. -/
theorem warp_critical_convergence {m v : ℝ} {θ0 : ℝ} (g : Fin 3 → ℝ) (hm : 0 < m) (hv : 0 < v)
    (hθ : θ0 < -(v * Real.sqrt (m * ((g 1) ^ 2 + (g 2) ^ 2) / 2))) :
    m * warpDefect v g < θ0 ^ 2 := by
  set T : ℝ := (g 1) ^ 2 + (g 2) ^ 2 with hT
  have hTnn : 0 ≤ T := by rw [hT]; positivity
  have hs : 0 ≤ Real.sqrt (m * T / 2) := Real.sqrt_nonneg _
  have hsq : (Real.sqrt (m * T / 2)) ^ 2 = m * T / 2 := Real.sq_sqrt (by positivity)
  have hX : 0 ≤ v * Real.sqrt (m * T / 2) := by positivity
  have hlt : (v * Real.sqrt (m * T / 2)) ^ 2 < θ0 ^ 2 := by
    have h1 : v * Real.sqrt (m * T / 2) < -θ0 := by linarith
    nlinarith
  have hexp : (v * Real.sqrt (m * T / 2)) ^ 2 = m * warpDefect v g := by
    rw [mul_pow, hsq, warpDefect, ← hT]
    ring
  linarith [hexp ▸ hlt]

/-- **Physical reading of the bridge.**  On the axis of motion the warp defect vanishes, so
the classical focusing theory applies unchanged there; off the axis, in the toroidal exotic
region, the defect is strictly positive and focusing can be defeated.  The two regimes are
separated exactly by the transverse gradient of the shape function. -/
theorem warp_defect_axis_vs_torus (v : ℝ) (g : Fin 3 → ℝ) (hv : v ≠ 0) :
    (warpDefect v g = 0 ↔ (g 1 = 0 ∧ g 2 = 0)) := by
  constructor
  · intro h
    by_contra hc
    have := (warpDefect_pos_iff v g).mpr ⟨hv, hc⟩
    linarith
  · rintro ⟨h1, h2⟩
    rw [warpDefect, h1, h2]
    ring

end Catalog.Physics.Spacetime.Alcubierre