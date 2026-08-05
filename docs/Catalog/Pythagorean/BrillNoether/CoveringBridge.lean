/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Catalog.Pythagorean.BrillNoether.Divisors
import Catalog.Pythagorean.BrillNoether.EnergyPath

/-!
# From an energy covering radius to Brill–Noether existence

This file closes the logical circle of the other files in this directory.

* `Divisors.lean` shows that an `ℓ^∞` covering bound `ρ` for the Laplacian lattice
  forces every divisor of degree at least `n(ρ + r)` to have Baker–Norine rank at
  least `r`.
* `EnergyCovering.lean` studies the covering radius of the Laplacian lattice in the
  *energy* metric, where spectral information (Cheeger's inequality) is available.
* `EnergyPath.lean` converts energy distance into sup-norm distance.

Combining the last two items with the first gives the implication used in the
geometry-of-numbers approach to the Brill–Noether existence conjecture: *if every
degree-zero divisor is within energy distance `ε` of the Laplacian lattice, then
the lattice has `ℓ^∞` covering radius at most `√(d ε)`, where `d` bounds the
distances in the graph, and consequently every divisor of degree at least
`n(√(d ε) + r)` has rank at least `r`.*

## Main results

* `BrillNoetherCoveringBridge.isCoveringBound_of_energy_covering` — the passage from
  an energy covering radius to an `ℓ^∞` covering bound.
* `BrillNoetherCoveringBridge.rankAtLeast_of_energy_covering` — the resulting
  Brill–Noether existence statement.
-/

open Finset BrillNoetherDivisor BrillNoetherEnergy BrillNoetherEnergyPath

namespace BrillNoetherCoveringBridge

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-- The real vector attached to an integer divisor. -/
noncomputable def toReal (D : Divisor V) : V → ℝ := fun v => (D v : ℝ)

omit [DecidableEq V] [DecidableRel G.Adj] in
lemma sum_toReal (D : Divisor V) : ∑ v, toReal D v = (deg D : ℝ) := by
  simp [toReal, deg]

/-- **From an energy covering radius to an `ℓ^∞` covering bound.**  Suppose every
degree-zero divisor lies within energy distance `ε` of the Laplacian lattice, and
`d` bounds all distances in the connected graph `G`.  Then the Laplacian lattice
has `ℓ^∞` covering radius at most any integer `ρ ≥ √(d ε)`. -/
theorem isCoveringBound_of_energy_covering [Nonempty V] (hG : G.Connected) {d : ℕ}
    (hd : ∀ a b : V, G.dist a b ≤ d) {eps : ℝ}
    (hcov : ∀ A : Divisor V, deg A = 0 →
      ∃ f : V → ℤ, energy G (toReal (A - lap G f)) ≤ eps)
    {rho : ℕ} (hrho : Real.sqrt ((d : ℝ) * eps) ≤ (rho : ℝ)) :
    IsCoveringBound G rho := by
  intro A hA
  obtain ⟨f, hf⟩ := hcov A hA
  refine ⟨-f, fun v => ?_⟩
  set z : V → ℝ := toReal (A - lap G f) with hz
  have hzsum : ∑ v, z v = 0 := by
    rw [hz, sum_toReal, deg_sub, deg_lap, hA]
    simp
  have hbound : |z v| ≤ Real.sqrt ((d : ℝ) * energy G z) :=
    abs_le_sqrt_of_sum_eq_zero G hG hd z hzsum v
  have hmono : Real.sqrt ((d : ℝ) * energy G z) ≤ Real.sqrt ((d : ℝ) * eps) :=
    Real.sqrt_le_sqrt (mul_le_mul_of_nonneg_left hf (Nat.cast_nonneg d))
  have hzv : |z v| ≤ (rho : ℝ) := le_trans hbound (le_trans hmono hrho)
  have hlow : -(rho : ℝ) ≤ z v := neg_le_of_abs_le hzv
  have hzval : z v = ((A v - lap G f v : ℤ) : ℝ) := by simp [hz, toReal]
  rw [hzval] at hlow
  have : (-(rho : ℤ) : ℝ) ≤ ((A v - lap G f v : ℤ) : ℝ) := by push_cast at hlow ⊢; linarith
  have hint : -(rho : ℤ) ≤ A v - lap G f v := by exact_mod_cast this
  simpa [lap_neg, sub_eq_add_neg] using hint

/-- **Brill–Noether existence from an energy covering radius.**  Under the
hypotheses of `isCoveringBound_of_energy_covering`, every divisor of degree at
least `n (ρ + r)` has Baker–Norine rank at least `r`. -/
theorem rankAtLeast_of_energy_covering [Nonempty V] (hG : G.Connected) {d : ℕ}
    (hd : ∀ a b : V, G.dist a b ≤ d) {eps : ℝ}
    (hcov : ∀ A : Divisor V, deg A = 0 →
      ∃ f : V → ℤ, energy G (toReal (A - lap G f)) ≤ eps)
    {rho r : ℕ} (hrho : Real.sqrt ((d : ℝ) * eps) ≤ (rho : ℝ)) (D : Divisor V)
    (h : (Fintype.card V : ℤ) * ((rho : ℤ) + (r : ℤ)) ≤ deg D) :
    RankAtLeast G D r :=
  rankAtLeast_of_covering G (isCoveringBound_of_energy_covering G hG hd hcov hrho) D h

end BrillNoetherCoveringBridge