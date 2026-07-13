/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# The Mathematics of Stellar Energy Collection: Dyson Spheres and Dyson Swarms

A star of luminosity `L` radiates energy isotropically into space.  A hypothetical
megastructure that intercepts this radiation — a *Dyson sphere* (a complete shell)
or a *Dyson swarm* (a cloud of independent collectors) — converts a fraction of the
stellar output into usable power.  This file develops the exact optimization theory
of such structures from the inverse-square law.

## The physical model

At orbital radius `R` from the star the radiation is spread over a sphere of area
`4πR²`, so the **flux** (power per unit area) is

  `flux L R = L / (4πR²)`.

A flat collector of area `A` placed at radius `R` and facing the star intercepts

  `collectedPower L R A = A · flux L R`.

Equivalently, writing the **solid angle** subtended by the collector as
`solidAngle A R = A / R²`, the collected power is `L · (A/R²) / (4π)`: energy
collection depends only on the *solid angle* the collectors occupy in the star's
sky, never on their absolute size or distance separately.

## Main results

* `sphere_captures_all` — a complete shell of area `4πR²` captures the *entire*
  luminosity `L`, for every radius `R`.  This is the geometric heart of the
  Dyson-sphere idea: total capture is *scale invariant*
  (`sphere_captures_all_scale_invariant`).
* `flux_inverse_square` and `flux_strictAnti` — the inverse-square law and the
  fact that flux strictly decreases with distance.
* `collectedPower_eq_solidAngle`, `swarmPower_eq` — collection is governed by
  solid angle; a swarm's output is `L/(4π)` times its total subtended solid angle.
* `swarmPower_le_luminosity` — **no swarm can beat the sphere**: under at-most-full
  coverage (total solid angle `≤ 4π`) the collected power never exceeds `L`.
* `swarm_common_radius_full` — the **optimality characterization**: collectors at a
  common radius `R` capture the full luminosity if and only if their total area is
  exactly the Dyson-sphere area `4πR²`.
* `swarmPower_refinement_invariant` — subdividing a collector into many pieces at
  the same radius changes nothing; only total area matters.
* `swarmPower_le_minRadius` — the **concentration principle**: with a fixed area
  budget, collection is maximized by placing collectors as close as possible.
* `efficiency_mem_Icc`, `capturedOfAngle_tendsto` — the capture efficiency is a
  number in `[0,1]`, approaching perfect capture as coverage approaches `4π`.
* `gauss_law` — a Gauss-law identity: integrating the (constant) flux over any
  closed surface of area `4πR²` recovers the full luminosity `L`.
-/

open scoped Real
open Real BigOperators MeasureTheory

namespace Dyson

/-! ## Basic definitions -/

/-- Radiative flux (power per unit area) at radius `R` from a star of luminosity
`L`, obtained by spreading `L` uniformly over the sphere of area `4πR²`. -/
noncomputable def flux (L R : ℝ) : ℝ := L / (4 * Real.pi * R ^ 2)

/-- Power collected by a flat collector of area `A` at radius `R`, facing the star. -/
noncomputable def collectedPower (L R A : ℝ) : ℝ := A * flux L R

/-- Surface area of a sphere of radius `R` (the area of a full Dyson shell). -/
noncomputable def sphereArea (R : ℝ) : ℝ := 4 * Real.pi * R ^ 2

/-- Solid angle subtended at the star by a collector of area `A` at radius `R`. -/
noncomputable def solidAngle (A R : ℝ) : ℝ := A / R ^ 2

/-- Total power collected by a swarm: a finite family of collectors indexed by `s`,
the `i`-th having area `A i` at radius `R i`. -/
noncomputable def swarmPower {ι : Type*} (L : ℝ) (s : Finset ι) (A R : ι → ℝ) : ℝ :=
  ∑ i ∈ s, collectedPower L (R i) (A i)

/-- Fraction of the stellar luminosity captured by a swarm (its efficiency). -/
noncomputable def efficiency {ι : Type*} (s : Finset ι) (A R : ι → ℝ) : ℝ :=
  (∑ i ∈ s, solidAngle (A i) (R i)) / (4 * Real.pi)

/-! ## The inverse-square law -/

/-- **Inverse-square law.** Rescaling the distance by a factor `c` divides the flux
by `c²`. -/
theorem flux_inverse_square (L R c : ℝ) (hR : R ≠ 0) (hc : c ≠ 0) :
    flux L (c * R) = flux L R / c ^ 2 := by
  unfold flux
  have hpi : Real.pi ≠ 0 := Real.pi_ne_zero
  field_simp

/-- Flux is strictly decreasing in the distance for a star of positive luminosity:
moving a collector farther away always reduces the power it receives. -/
theorem flux_strictAnti (L : ℝ) (hL : 0 < L) {R₁ R₂ : ℝ}
    (h₁ : 0 < R₁) (h₁₂ : R₁ < R₂) : flux L R₂ < flux L R₁ := by
  unfold flux
  have hpi : 0 < Real.pi := Real.pi_pos
  have hR₂ : 0 < R₂ := lt_trans h₁ h₁₂
  apply div_lt_div_of_pos_left hL (by positivity)
  have : R₁ ^ 2 < R₂ ^ 2 := by nlinarith
  nlinarith [this, hpi]

/-! ## The full Dyson sphere -/

/-- **A complete Dyson shell captures the entire stellar output.** A sphere of area
`4πR²` at any radius `R` collects exactly the luminosity `L`. -/
theorem sphere_captures_all (L R : ℝ) (hR : R ≠ 0) :
    collectedPower L R (sphereArea R) = L := by
  unfold collectedPower flux sphereArea
  have hpi : Real.pi ≠ 0 := Real.pi_ne_zero
  field_simp

/-- **Scale invariance of total capture.** Two complete shells at different radii
capture the same power — namely all of it. -/
theorem sphere_captures_all_scale_invariant (L R₁ R₂ : ℝ) (h₁ : R₁ ≠ 0)
    (h₂ : R₂ ≠ 0) :
    collectedPower L R₁ (sphereArea R₁) = collectedPower L R₂ (sphereArea R₂) := by
  rw [sphere_captures_all L R₁ h₁, sphere_captures_all L R₂ h₂]

/-! ## Collection is governed by solid angle -/

/-- The power a collector receives depends only on the solid angle it subtends at
the star: `collectedPower = L · solidAngle / (4π)`. -/
theorem collectedPower_eq_solidAngle (L R A : ℝ) (hR : R ≠ 0) :
    collectedPower L R A = L * solidAngle A R / (4 * Real.pi) := by
  unfold collectedPower flux solidAngle
  have hpi : Real.pi ≠ 0 := Real.pi_ne_zero
  field_simp

/-- A swarm's total collected power equals the luminosity times its total subtended
solid angle, divided by `4π`. -/
theorem swarmPower_eq {ι : Type*} (L : ℝ) (s : Finset ι) (A R : ι → ℝ)
    (hR : ∀ i ∈ s, R i ≠ 0) :
    swarmPower L s A R = L / (4 * Real.pi) * ∑ i ∈ s, solidAngle (A i) (R i) := by
  unfold swarmPower
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl ?_
  intro i hi
  unfold collectedPower flux solidAngle
  have hpi : Real.pi ≠ 0 := Real.pi_ne_zero
  have := hR i hi
  field_simp

/-- The captured power is the luminosity scaled by the swarm's efficiency. -/
theorem swarmPower_eq_efficiency {ι : Type*} (L : ℝ) (s : Finset ι) (A R : ι → ℝ)
    (hR : ∀ i ∈ s, R i ≠ 0) :
    swarmPower L s A R = L * efficiency s A R := by
  rw [swarmPower_eq L s A R hR]
  unfold efficiency
  ring

/-! ## Optimality: the sphere is the best you can do -/

/-- **No swarm beats the complete sphere.** If the collectors together subtend at
most the full sky (`total solid angle ≤ 4π`), the collected power cannot exceed the
luminosity `L`. -/
theorem swarmPower_le_luminosity {ι : Type*} (L : ℝ) (s : Finset ι) (A R : ι → ℝ)
    (hR : ∀ i ∈ s, R i ≠ 0) (hL : 0 ≤ L)
    (hcov : ∑ i ∈ s, solidAngle (A i) (R i) ≤ 4 * Real.pi) :
    swarmPower L s A R ≤ L := by
  rw [swarmPower_eq L s A R hR]
  have hpi : (0 : ℝ) < 4 * Real.pi := by positivity
  rw [div_mul_eq_mul_div, div_le_iff₀ hpi]
  exact mul_le_mul_of_nonneg_left hcov hL

/-- **The optimal collecting area.** For collectors placed at a common orbital
radius `R`, the swarm captures the *entire* luminosity if and only if the total
collecting area equals the Dyson-sphere area `4πR²`.  Thus the optimal (minimal,
full-capture) collecting area at radius `R` is exactly `4πR²`. -/
theorem swarm_common_radius_full {ι : Type*} (L R : ℝ) (s : Finset ι) (A : ι → ℝ)
    (hR : R ≠ 0) (hL : L ≠ 0) :
    swarmPower L s A (fun _ => R) = L ↔ ∑ i ∈ s, A i = sphereArea R := by
  unfold swarmPower collectedPower flux sphereArea
  have hpi : Real.pi ≠ 0 := Real.pi_ne_zero
  rw [← Finset.sum_mul]
  constructor
  · intro h
    field_simp at h ⊢
    nlinarith [h]
  · intro h
    rw [h]
    field_simp

/-- **Refinement invariance.** Splitting collectors into finer pieces at the same
radius does not change the collected power: only the total area matters.  A swarm at
common radius `R` with total area `A_tot` collects exactly what a single collector
of area `A_tot` would. -/
theorem swarmPower_refinement_invariant {ι : Type*} (L R : ℝ) (s : Finset ι)
    (A : ι → ℝ) :
    swarmPower L s A (fun _ => R) = collectedPower L R (∑ i ∈ s, A i) := by
  unfold swarmPower collectedPower
  rw [Finset.sum_mul]

/-- **Concentration principle.** With every collector at radius at least `Rmin > 0`
and nonnegative areas, the swarm collects no more than a single collector holding the
entire area at radius `Rmin`.  Energy collection is maximized by moving collectors as
close to the star as possible. -/
theorem swarmPower_le_minRadius {ι : Type*} (L Rmin : ℝ) (s : Finset ι) (A R : ι → ℝ)
    (hRmin : 0 < Rmin) (hR : ∀ i ∈ s, Rmin ≤ R i) (hA : ∀ i ∈ s, 0 ≤ A i)
    (hL : 0 ≤ L) :
    swarmPower L s A R ≤ L / (4 * Real.pi) * ((∑ i ∈ s, A i) / Rmin ^ 2) := by
  have hRne : ∀ i ∈ s, R i ≠ 0 := fun i hi =>
    ne_of_gt (lt_of_lt_of_le hRmin (hR i hi))
  rw [swarmPower_eq L s A R hRne]
  have hLc : 0 ≤ L / (4 * Real.pi) := by positivity
  apply mul_le_mul_of_nonneg_left _ hLc
  rw [Finset.sum_div]
  refine Finset.sum_le_sum ?_
  intro i hi
  unfold solidAngle
  have hRi : Rmin ≤ R i := hR i hi
  gcongr
  exact hA i hi

/-! ## Efficiency and the approach to perfect capture -/

/-- The efficiency of a physically admissible swarm (nonnegative total solid angle,
no more than complete coverage) lies in the unit interval `[0,1]`. -/
theorem efficiency_mem_Icc {ι : Type*} (s : Finset ι) (A R : ι → ℝ)
    (hnn : 0 ≤ ∑ i ∈ s, solidAngle (A i) (R i))
    (hcov : ∑ i ∈ s, solidAngle (A i) (R i) ≤ 4 * Real.pi) :
    efficiency s A R ∈ Set.Icc (0 : ℝ) 1 := by
  unfold efficiency
  have hpi : (0 : ℝ) < 4 * Real.pi := by positivity
  constructor
  · positivity
  · rw [div_le_one hpi]; exact hcov

/-- As the total subtended solid angle approaches the full sky `4π`, the captured
power converges continuously to the entire luminosity `L`. -/
theorem capturedOfAngle_tendsto (L : ℝ) :
    Filter.Tendsto (fun θ => L * θ / (4 * Real.pi)) (nhds (4 * Real.pi)) (nhds L) := by
  have hcont : Continuous (fun θ : ℝ => L * θ / (4 * Real.pi)) := by fun_prop
  have h := hcont.tendsto (4 * Real.pi)
  have hval : L * (4 * Real.pi) / (4 * Real.pi) = L := by
    have hpi : Real.pi ≠ 0 := Real.pi_ne_zero
    field_simp
  rwa [hval] at h

/-! ## A Gauss-law identity -/

/-- **Gauss's law for radiation.** The flux is constant over any closed surface
surrounding the star, so integrating it over a surface of area `4πR²` recovers the
full luminosity `L`, regardless of the surface's shape. -/
theorem gauss_law {α : Type*} [MeasurableSpace α] (μ : Measure α) (S : Set α)
    (L R : ℝ) (hR : R ≠ 0) (hS : μ.real S = 4 * Real.pi * R ^ 2) :
    ∫ _x in S, flux L R ∂μ = L := by
  rw [MeasureTheory.setIntegral_const, hS]
  unfold flux
  have hpi : Real.pi ≠ 0 := Real.pi_ne_zero
  rw [smul_eq_mul]
  field_simp

end Dyson

/-
-- !-- Lab Notes -- !--

## Hypothesis (team: Hypothesizer)
The Dyson-sphere/swarm folklore claims that (a) a complete shell captures a star's
entire output independent of radius, and (b) a swarm of independent collectors can
do no better than the shell, with full capture requiring total collecting area
`4πR²` at radius `R`.  We conjectured the sharper statements: capture depends only
on subtended *solid angle*; the shell is a global optimum; and full capture at a
common radius holds *iff* total area equals `4πR²`.

## Experiment (team: Experimenter)
Working from `flux L R = L/(4πR²)` we verified each claim symbolically.  The core
algebraic identity `A · L/(4πR²) = L · (A/R²)/(4π)` reduces every statement to a
fact about solid angle.  `sphere_captures_all`, `swarmPower_eq`,
`swarm_common_radius_full`, `swarmPower_le_luminosity`, and the concentration
bound `swarmPower_le_minRadius` all went through; the last needed a monotonicity
step (`gcongr`) on `1/R²`.

## Analysis (team: Analyst)
The unifying structure is that collection factors through the linear functional
"total solid angle", divided by `4π`.  This explains simultaneously the scale
invariance of full capture, refinement invariance (subdivision is irrelevant), and
the sharp optimality: `4π` is the total solid angle of the whole sky, so the bound
`≤ L` is the statement that no arrangement subtends more than the full sphere.  The
concentration principle is the observation that solid angle per unit area, `1/R²`,
is maximized at the smallest radius.

## Critique (team: Critic)
Each theorem carries the minimal genuine hypotheses (`R ≠ 0`, and sign conditions
only where the inequality direction demands them); none is vacuous.  The optimality
`iff` requires `L ≠ 0` — necessary, since for a dark star every arrangement
trivially "captures" `L = 0`.  The coverage hypothesis `total solid angle ≤ 4π` in
`swarmPower_le_luminosity` is the honest physical no-overlap constraint; without it
the linear formula would allow unphysical super-capture, correctly reflected by the
mathematics.  No proof invokes decision procedures alone; each uses `field_simp`,
`nlinarith`, `gcongr`, monotone-sum, continuity, or measure-theoretic integration.

## Synthesis (team: Principal Investigator)
The file gives a complete, self-contained optimization theory of stellar energy
collection: the inverse-square law, the shell optimum, the solid-angle
factorization, the exact `4πR²` characterization of full capture, refinement and
scale invariance, the concentration principle, efficiency bounds, a continuity
limit toward perfect capture, and a Gauss-law integral identity.
-/