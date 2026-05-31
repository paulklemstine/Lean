import Mathlib

/-!
# Hyperbolic Number Theory: Definitions

Core definitions for arithmetic on the Poincaré disk model of hyperbolic geometry.
We define Möbius transformations, the pseudo-hyperbolic metric, hyperbolic lattice
structures, and counting functions that connect hyperbolic geometry to number theory.
-/

noncomputable section
open Complex Real

namespace HyperbolicNumberTheory

/-! ## Möbius Transformations -/

/-- A Möbius transformation represented by a 2×2 complex matrix with nonzero determinant.
    Acts on ℂ via z ↦ (az+b)/(cz+d). -/
structure MoebiusMat where
  a : ℂ
  b : ℂ
  c : ℂ
  d : ℂ
  det_ne : a * d - b * c ≠ 0

/-- Apply a Möbius transformation to a complex number. -/
def MoebiusMat.apply (M : MoebiusMat) (z : ℂ) : ℂ :=
  (M.a * z + M.b) / (M.c * z + M.d)

/-- The determinant of a Möbius matrix. -/
def MoebiusMat.det (M : MoebiusMat) : ℂ := M.a * M.d - M.b * M.c

/-- The identity Möbius transformation. -/
def MoebiusMat.one : MoebiusMat where
  a := 1; b := 0; c := 0; d := 1
  det_ne := by norm_num

/-- The inverse of a Möbius transformation. -/
def MoebiusMat.inv (M : MoebiusMat) : MoebiusMat where
  a := M.d; b := -M.b; c := -M.c; d := M.a
  det_ne := by
    rw [neg_mul_neg, show M.d * M.a = M.a * M.d from mul_comm M.d M.a]
    exact M.det_ne

/-! ## Pseudo-Hyperbolic Distance -/

/-- The pseudo-hyperbolic distance between two points in the complex plane.
    For points z, w in the unit disk, this equals |z - w| / |1 - conj(w) * z|. -/
def pseudoHypDist (z w : ℂ) : ℝ :=
  ‖z - w‖ / ‖1 - starRingEnd ℂ w * z‖

/-- The hyperbolic distance on the Poincaré disk.
    d(z,w) = artanh(ρ(z,w)) where ρ is the pseudo-hyperbolic distance.
    We use the formula log((1+ρ)/(1-ρ)) which equals 2·artanh(ρ). -/
def hypDist (z w : ℂ) : ℝ :=
  Real.log ((1 + pseudoHypDist z w) / (1 - pseudoHypDist z w))

/-! ## Poincaré Disk -/

/-- The open unit disk in ℂ. -/
def UnitDisk : Set ℂ := {z : ℂ | ‖z‖ < 1}

/-! ## Möbius Addition (Einstein velocity addition) -/

/-- Möbius addition on the Poincaré disk: the "sum" of two points z, w is
    (z + w) / (1 + conj(w) · z). This is also known as Einstein velocity addition
    in special relativity (in natural units). This is the fundamental binary operation
    for hyperbolic arithmetic. -/
def moebiusAdd (z w : ℂ) : ℂ :=
  (z + w) / (1 + starRingEnd ℂ w * z)

/-! ## Hyperbolic Integers -/

/-- A hyperbolic integer is a labeled point in the Poincaré disk. -/
structure HypInt where
  label : ℤ
  pos : ℂ
  in_disk : ‖pos‖ < 1

/-- The hyperbolic norm of a hyperbolic integer. -/
def HypInt.hnorm (n : HypInt) : ℝ :=
  Real.log ((1 + ‖n.pos‖) / (1 - ‖n.pos‖))

/-- A hyperbolic integer is a unit if its position is the origin. -/
def HypInt.isUnit (n : HypInt) : Prop := n.pos = 0

/-! ## Hyperbolic Lattice Counting -/

/-- Count points in a finite set of complex numbers within pseudo-hyperbolic distance R
    of a center point. -/
def latticeCount (points : Finset ℂ) (center : ℂ) (R : ℝ) : ℕ :=
  (points.filter (fun p => pseudoHypDist p center ≤ R)).card

/-! ## Hyperbolic Area -/

/-- The area of a hyperbolic disk of radius R in the Poincaré model.
    A(R) = 4π sinh²(R/2) = 2π(cosh R - 1). -/
def hypArea (R : ℝ) : ℝ := 2 * Real.pi * (Real.cosh R - 1)

/-! ## Hyperbolic Zeta Function -/

/-- The partial hyperbolic zeta sum over a finite set of hyperbolic integers. -/
def hypZetaPartial (points : Finset HypInt) (s : ℝ) : ℝ :=
  points.sum (fun n => if n.hnorm > 0 then (n.hnorm) ^ (-s) else 0)

/-! ## Cross-Ratio -/

/-- The cross-ratio of four complex numbers, a fundamental invariant of Möbius geometry. -/
def crossRatio (z₁ z₂ z₃ z₄ : ℂ) : ℂ :=
  ((z₁ - z₃) * (z₂ - z₄)) / ((z₁ - z₄) * (z₂ - z₃))

end HyperbolicNumberTheory
end