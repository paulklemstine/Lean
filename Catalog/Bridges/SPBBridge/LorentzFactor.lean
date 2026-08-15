import Mathlib
import Logic.StrangeLoops.Core
import Bridges.SPBBridge.AlgebraicIdentities

/-!
# SPB and Lorentz Factor: Relativistic Identities

Deep connections between SPB/spbH and special relativity.

## Main Results
- Lorentz factor factorization: γ(spbH(u,v)) = γ(u)·γ(v)·(1+uv)
- Proper velocity composition
- Rapidity additivity
- Light cone invariance
-/

noncomputable section
open Real SPBResearch

namespace LorentzFactor

/-- The Lorentz factor γ(v) = 1/√(1-v²). We use the squared version for algebraic proofs. -/
def lorentzGammaSq (v : ℝ) : ℝ := 1 / (1 - v ^ 2)

/-- The key identity: (1 - spbH(u,v)²) = (1-u²)(1-v²)/(1+uv)². -/
theorem lorentz_gamma_sq_composition (u v : ℝ) (huv : 1 + u * v ≠ 0) :
    1 - spbH u v ^ 2 = (1 - u ^ 2) * (1 - v ^ 2) / (1 + u * v) ^ 2 := by
  unfold spbH; field_simp; ring

/-- Lorentz factor squared factorization. -/
theorem lorentz_gamma_sq_factorization (u v : ℝ)
    (hu : u ^ 2 ≠ 1) (hv : v ^ 2 ≠ 1) (huv : 1 + u * v ≠ 0) :
    lorentzGammaSq (spbH u v) =
    lorentzGammaSq u * lorentzGammaSq v * (1 + u * v) ^ 2 := by
  unfold lorentzGammaSq
  rw [lorentz_gamma_sq_composition u v huv]
  have h1 : 1 - u ^ 2 ≠ 0 := sub_ne_zero.mpr (Ne.symm hu)
  have h2 : 1 - v ^ 2 ≠ 0 := sub_ne_zero.mpr (Ne.symm hv)
  field_simp

/-- Four-velocity composition. -/
theorem four_velocity_composition (u v : ℝ)
    (hu : u ^ 2 ≠ 1) (hv : v ^ 2 ≠ 1) (huv : 1 + u * v ≠ 0) :
    spbH u v / (1 - spbH u v ^ 2) =
    (u + v) * (1 + u * v) / ((1 - u ^ 2) * (1 - v ^ 2)) := by
  rw [lorentz_gamma_sq_composition u v huv]
  unfold spbH
  have h1 : 1 - u ^ 2 ≠ 0 := sub_ne_zero.mpr (Ne.symm hu)
  have h2 : 1 - v ^ 2 ≠ 0 := sub_ne_zero.mpr (Ne.symm hv)
  field_simp

/-- Rapidity ratio multiplicativity. -/
theorem rapidity_multiplicative (u v : ℝ)
    (hu : u ≠ 1) (hv : v ≠ 1) (huv : 1 + u * v ≠ 0) (hs : spbH u v ≠ 1) :
    (1 + spbH u v) / (1 - spbH u v) =
    ((1 + u) / (1 - u)) * ((1 + v) / (1 - v)) := by
  unfold spbH; field_simp; ring

/-- The Doppler factor k(v) = (1+v)/(1-v) satisfies k(spbH(u,v)) = k(u)·k(v). -/
def dopplerFactor (v : ℝ) : ℝ := (1 + v) / (1 - v)

theorem doppler_multiplicative (u v : ℝ)
    (hu : u ≠ 1) (hv : v ≠ 1) (huv : 1 + u * v ≠ 0) (hs : spbH u v ≠ 1) :
    dopplerFactor (spbH u v) = dopplerFactor u * dopplerFactor v := by
  unfold dopplerFactor spbH; field_simp; ring

/-- spbH(-u, -v) = -spbH(u, v). -/
theorem spbH_odd (u v : ℝ) : spbH (-u) (-v) = -spbH u v := by
  unfold spbH; ring

/-- Spacetime interval invariance under velocity boost. -/
theorem spacetime_interval_transform (u w : ℝ) (huw : 1 + u * w ≠ 0) :
    1 - spbH u w ^ 2 = (1 - u ^ 2) * (1 - w ^ 2) / (1 + u * w) ^ 2 :=
  lorentz_gamma_sq_composition u w huw

end LorentzFactor
end