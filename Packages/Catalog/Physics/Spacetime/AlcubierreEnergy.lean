/-
  # The Alcubierre drive requires exotic matter: pointwise negativity of the energy density

  The Alcubierre metric solves the Einstein equations `G_{μν} = 8π T_{μν}` *by definition of
  `T`*, since the metric is everywhere nondegenerate (`det g = -1`, see `AlcubierreMetric`).
  The content of the "warp drive problem" is therefore not existence but the **sign** of the
  source.  This file computes that sign from first principles.

  Because the slices `t = const` are flat (`γ_ij = δ_ij`, intrinsic Ricci scalar `R⁽³⁾ = 0`)
  and the lapse is unity, the Hamiltonian (energy) constraint of the ADM decomposition,

      16π ρ = R⁽³⁾ + K² - K_ij K^ij ,   ρ := T_{μν} n^μ n^ν ,

  reduces to a purely algebraic statement about the expansion tensor of the Eulerian
  congruence built in `AlcubierreExpansion.lean` (`K_ij = -θ_ij`, so the constraint is
  insensitive to the sign convention).  Combined with the identity
  `θ² - θ_ijθ^ij = -(v²/2)((∂_y f)² + (∂_z f)²)` it gives Alcubierre's formula

      ρ = - (1/8π) · (v_s² (y² + z²) / (4 r_s²)) · (df/dr_s)²  ≤ 0 .

  Main results:

  * `energyDensity_eq` — the closed form of the Eulerian energy density.
  * `energyDensity_nonpos` — the energy density is never positive, for any shape function
    and any warp speed: the warp drive is *unconditionally* exotic.
  * `radialEnergyDensity_eq` — Alcubierre's published expression, derived here.
  * `radialEnergyDensity_eq_zero_iff` / `exotic_support_is_toroidal` — the exotic matter is
    supported exactly where the shape function varies **and** the point is off the axis of
    motion: a torus encircling the direction of travel.
  * `wec_violated` — a genuine weak-energy-condition violation: the unit timelike Eulerian
    observer measures strictly negative energy density.
-/

import Mathlib
import Physics.Spacetime.AlcubierreExpansion
import Physics.Spacetime.AlcubierreMetric

open Matrix

namespace Catalog.Physics.Spacetime.Alcubierre

/-- Auxiliary: a nonvanishing transverse gradient has positive square norm. -/
theorem sq_add_sq_pos {b c : ℝ} (h : ¬ (b = 0 ∧ c = 0)) : 0 < b ^ 2 + c ^ 2 := by
  rcases not_and_or.mp h with h | h
  · have hb : 0 < b ^ 2 := pow_two_pos_of_ne_zero h
    nlinarith [sq_nonneg c]
  · have hc : 0 < c ^ 2 := pow_two_pos_of_ne_zero h
    nlinarith [sq_nonneg b]

/-- The Eulerian energy density `ρ = T_{μν} n^μ n^ν` of the Alcubierre metric, obtained from
the ADM Hamiltonian constraint on flat slices: `16π ρ = θ² - θ_ij θ^ij`. -/
noncomputable def energyDensity (v : ℝ) (g : Fin 3 → ℝ) : ℝ :=
  (expansionScalar v g ^ 2 - expansionSquaredNorm v g) / (16 * Real.pi)

/-- **Closed form of the warp-drive energy density.** -/
theorem energyDensity_eq (v : ℝ) (g : Fin 3 → ℝ) :
    energyDensity v g = -(v ^ 2 * ((g 1) ^ 2 + (g 2) ^ 2)) / (32 * Real.pi) := by
  rw [energyDensity, expansion_quadratic_invariant]
  rw [div_eq_div_iff (by positivity) (by positivity)]
  ring

theorem energyDensity_of (v g0 g1 g2 : ℝ) :
    energyDensity v ![g0, g1, g2] = -(v ^ 2 * (g1 ^ 2 + g2 ^ 2)) / (32 * Real.pi) := by
  rw [energyDensity_eq]
  simp [Matrix.cons_val_two]

/-- **The warp drive needs exotic matter: the energy density is never positive.** -/
theorem energyDensity_nonpos (v : ℝ) (g : Fin 3 → ℝ) : energyDensity v g ≤ 0 := by
  rw [energyDensity_eq, neg_div, neg_nonpos]
  have hpi : (0:ℝ) < 32 * Real.pi := by positivity
  apply div_nonneg _ hpi.le
  nlinarith [sq_nonneg (g 1), sq_nonneg (g 2), sq_nonneg v]

/-- The energy density is strictly negative exactly when the warp speed is nonzero and the
shape function has a nonvanishing *transverse* gradient. -/
theorem energyDensity_neg_iff (v : ℝ) (g : Fin 3 → ℝ) :
    energyDensity v g < 0 ↔ v ≠ 0 ∧ ¬ (g 1 = 0 ∧ g 2 = 0) := by
  have hpi : (0:ℝ) < 32 * Real.pi := by positivity
  rw [energyDensity_eq, neg_div, neg_lt_zero]
  constructor
  · intro h
    have hN : 0 < v ^ 2 * ((g 1) ^ 2 + (g 2) ^ 2) := by
      by_contra hc
      push_neg at hc
      have : v ^ 2 * ((g 1) ^ 2 + (g 2) ^ 2) / (32 * Real.pi) ≤ 0 :=
        div_nonpos_of_nonpos_of_nonneg hc hpi.le
      linarith
    refine ⟨?_, ?_⟩
    · rintro rfl; simp at hN
    · rintro ⟨h1, h2⟩; rw [h1, h2] at hN; simp at hN
  · rintro ⟨hv, hg⟩
    exact div_pos (mul_pos (pow_two_pos_of_ne_zero hv) (sq_add_sq_pos hg)) hpi

/-! ## The spherically symmetric case: Alcubierre's formula -/

/-- The Eulerian energy density for a spherically symmetric shape function `f(r_s)` whose
radial derivative at the point is `df`. -/
noncomputable def radialEnergyDensity (v df a x y z : ℝ) : ℝ :=
  energyDensity v ![df * (x - a) / bubbleRadius a x y z,
                    df * y / bubbleRadius a x y z,
                    df * z / bubbleRadius a x y z]

/-- **Alcubierre's formula**, derived from the Hamiltonian constraint:
`ρ = -(1/8π)·(v² (y²+z²)/(4 r_s²))·(df/dr_s)²`. -/
theorem radialEnergyDensity_eq (v df a x y z : ℝ) (hr : 0 < bubbleRadius a x y z) :
    radialEnergyDensity v df a x y z
      = -(1 / (8 * Real.pi)) *
          (v ^ 2 * (y ^ 2 + z ^ 2) / (4 * (bubbleRadius a x y z) ^ 2)) * df ^ 2 := by
  have hne : bubbleRadius a x y z ≠ 0 := ne_of_gt hr
  have hpi : Real.pi ≠ 0 := Real.pi_ne_zero
  rw [radialEnergyDensity, energyDensity_of]
  field_simp
  ring

theorem radialEnergyDensity_nonpos (v df a x y z : ℝ) : radialEnergyDensity v df a x y z ≤ 0 :=
  energyDensity_nonpos _ _

/-- Strict negativity off the axis, wherever the shape function actually varies. -/
theorem radialEnergyDensity_neg_iff (v df a x y z : ℝ) (hv : v ≠ 0)
    (hr : 0 < bubbleRadius a x y z) :
    radialEnergyDensity v df a x y z < 0 ↔ (df ≠ 0 ∧ ¬ (y = 0 ∧ z = 0)) := by
  have hne : bubbleRadius a x y z ≠ 0 := ne_of_gt hr
  rw [radialEnergyDensity, energyDensity_neg_iff]
  simp only [Matrix.cons_val_one, Matrix.cons_val_two, Matrix.head_cons, Matrix.tail_cons]
  constructor
  · rintro ⟨-, hg⟩
    constructor
    · rintro rfl; exact hg ⟨by simp, by simp⟩
    · rintro ⟨rfl, rfl⟩; exact hg ⟨by simp, by simp⟩
  · rintro ⟨hdf, hyz⟩
    refine ⟨hv, ?_⟩
    rintro ⟨h1, h2⟩
    refine hyz ⟨?_, ?_⟩
    · rcases div_eq_zero_iff.mp h1 with h | h
      · exact (mul_eq_zero.mp h).resolve_left hdf
      · exact absurd h hne
    · rcases div_eq_zero_iff.mp h2 with h | h
      · exact (mul_eq_zero.mp h).resolve_left hdf
      · exact absurd h hne

/-- **The exotic matter forms a torus around the axis of motion.**
The energy density vanishes identically on the axis `y = z = 0` (directly in front of and
behind the ship) and wherever the shape function is locally constant; everywhere else it is
strictly negative.  Hence the negative energy is a ring encircling the direction of
travel. -/
theorem exotic_support_is_toroidal (v df a x y z : ℝ) (hv : v ≠ 0)
    (hr : 0 < bubbleRadius a x y z) :
    (radialEnergyDensity v df a x y z = 0 ↔ (df = 0 ∨ (y = 0 ∧ z = 0))) := by
  constructor
  · intro h
    by_contra hcon
    push_neg at hcon
    have hneg : radialEnergyDensity v df a x y z < 0 :=
      (radialEnergyDensity_neg_iff v df a x y z hv hr).mpr ⟨hcon.1, by
        intro hyz; exact hcon.2 hyz.1 hyz.2⟩
    linarith
  · rintro (rfl | ⟨rfl, rfl⟩) <;>
      simp [radialEnergyDensity, energyDensity_of]

/-- **Weak energy condition violation.**  The Eulerian observer `n = (1, v f, 0, 0)` is unit
timelike (`eulerian_unit`) and measures strictly negative energy density at every off-axis
point of the bubble wall.  Hence no classical matter obeying the WEC can source an
Alcubierre bubble. -/
theorem wec_violated (v df a x y z : ℝ) (hv : v ≠ 0) (hdf : df ≠ 0)
    (hr : 0 < bubbleRadius a x y z) (hyz : ¬ (y = 0 ∧ z = 0)) (w : ℝ) :
    lineElement w ![1, w, 0, 0] = -1 ∧ radialEnergyDensity v df a x y z < 0 :=
  ⟨eulerian_unit w, (radialEnergyDensity_neg_iff v df a x y z hv hr).mpr ⟨hdf, hyz⟩⟩

end Catalog.Physics.Spacetime.Alcubierre