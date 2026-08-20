import Catalog.Shared.FourthDimensionPlayground

/-!
# Smooth phase rotations in four dimensions

This file deepens `FourthDimensionPlayground` by replacing its single quarter-turn
with the full circle action on `ℂ²`.  Unit complex phases act by smooth linear
rotations, preserve every centered three-sphere and every Hopf fibre, compose as
the circle group does, and every nonidentity phase is fixed-point-free away from
the origin.
-/

open ComplexConjugate

namespace FourthDimensionPlayground

/-- Simultaneous multiplication by a complex phase on the `ℂ²` model of `ℝ⁴`. -/
def phaseRotation (u : ℂ) (p : ℂ × ℂ) : ℂ × ℂ := (u * p.1, u * p.2)

/-- Phase rotations compose according to multiplication in the circle group. -/
theorem phaseRotation_comp (u v : ℂ) (p : ℂ × ℂ) :
    phaseRotation u (phaseRotation v p) = phaseRotation (u * v) p := by
  ext <;> simp [phaseRotation, mul_assoc]

/-- The identity phase acts identically. -/
theorem phaseRotation_one (p : ℂ × ℂ) : phaseRotation 1 p = p := by
  ext <;> simp [phaseRotation]

/-- A unit phase has inverse given by complex conjugation. -/
theorem phaseRotation_conj_inverse (u : ℂ) (hu : ‖u‖ = 1) (p : ℂ × ℂ) :
    phaseRotation (conj u) (phaseRotation u p) = p := by
  have hinv : conj u * u = 1 := by
    rw [Complex.conj_mul', hu]
    norm_num
  ext <;> simp [phaseRotation, ← mul_assoc, hinv]

/-- The full phase action is smooth as a map of real normed spaces. -/
theorem phaseRotation_contDiff (u : ℂ) :
    ContDiff ℝ ⊤ (phaseRotation u) := by
  unfold phaseRotation
  fun_prop

/-- Unit phases preserve the squared Euclidean norm on `ℂ²`. -/
theorem phaseRotation_norm_sq (u : ℂ) (hu : ‖u‖ = 1) (p : ℂ × ℂ) :
    ‖(phaseRotation u p).1‖ ^ 2 + ‖(phaseRotation u p).2‖ ^ 2 =
      ‖p.1‖ ^ 2 + ‖p.2‖ ^ 2 := by
  simp [phaseRotation, hu]

/-- Unit phases preserve the Hopf map, hence move points only inside fibres. -/
theorem hopf_phaseRotation (u : ℂ) (hu : ‖u‖ = 1) (p : ℂ × ℂ) :
    hopf (phaseRotation u p).1 (phaseRotation u p).2 = hopf p.1 p.2 := by
  exact hopf_phase_invariant u p.1 p.2 hu

/-- Every nonidentity complex phase has only the origin as a fixed point. -/
theorem phaseRotation_fixed_iff (u : ℂ) (hu : u ≠ 1) (p : ℂ × ℂ) :
    phaseRotation u p = p ↔ p = 0 := by
  constructor
  · intro h
    have h1 : u * p.1 = p.1 := congr_arg Prod.fst h
    have h2 : u * p.2 = p.2 := congr_arg Prod.snd h
    have hp1 : p.1 = 0 := by
      by_contra hp1
      exact hu ((mul_eq_right₀ hp1).mp h1)
    have hp2 : p.2 = 0 := by
      by_contra hp2
      exact hu ((mul_eq_right₀ hp2).mp h2)
    exact Prod.ext hp1 hp2
  · rintro rfl
    simp [phaseRotation]

/-- A nonidentity unit phase gives a smooth, fixed-point-free motion on every
positive-radius centered three-sphere while preserving its Hopf fibres. -/
theorem smooth_rotation_through_fourth_dimension
    (u : ℂ) (hu : ‖u‖ = 1) (hne : u ≠ 1) (r : ℝ) (hr : 0 < r) :
    ContDiff ℝ ⊤ (phaseRotation u) ∧
    (∀ p : ℂ × ℂ,
      ‖p.1‖ ^ 2 + ‖p.2‖ ^ 2 = r ^ 2 →
        (‖(phaseRotation u p).1‖ ^ 2 + ‖(phaseRotation u p).2‖ ^ 2 = r ^ 2) ∧
        hopf (phaseRotation u p).1 (phaseRotation u p).2 = hopf p.1 p.2 ∧
        phaseRotation u p ≠ p) := by
  refine ⟨phaseRotation_contDiff u, ?_⟩
  intro p hp
  refine ⟨phaseRotation_norm_sq u hu p |>.trans hp, hopf_phaseRotation u hu p, ?_⟩
  intro hfix
  have hp0 : p = 0 := (phaseRotation_fixed_iff u hne p).mp hfix
  subst p
  norm_num at hp
  nlinarith

end FourthDimensionPlayground