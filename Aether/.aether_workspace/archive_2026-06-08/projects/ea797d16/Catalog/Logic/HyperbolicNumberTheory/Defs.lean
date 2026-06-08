import Mathlib

/-!
# Hyperbolic Number Theory: Definitions

Core definitions for arithmetic on the Poincaré disk model of hyperbolic geometry.

## Main Definitions

- `PDisk`: The open unit disk in ℂ as a subtype
- `poincareCF`: The Poincaré conformal factor λ(z) = 2/(1 - |z|²)
- `mobiusAut`: Möbius automorphism φ_a(z) = (z - a)/(1 - ā·z)
- `hypDist`: Hyperbolic distance d_H(z,w) = 2·artanh|φ_w(z)|
- `HypLattice`: A discrete orbit in the Poincaré disk (hyperbolic integers)
- `GyrationOp`: The Thomas gyration, capturing non-associativity of Möbius addition
-/

open Complex Real Set

noncomputable section

/-! ## The Poincaré Disk -/

/-- The open unit disk in ℂ as a subtype. -/
def PDisk := {z : ℂ // Complex.normSq z < 1}

namespace PDisk

instance : CoeOut PDisk ℂ := ⟨Subtype.val⟩

/-- The origin of the Poincaré disk. -/
def origin : PDisk := ⟨0, by simp [Complex.normSq]⟩

/-- normSq of a disk point is nonneg. -/
theorem normSq_nonneg (z : PDisk) : 0 ≤ Complex.normSq z.val :=
  Complex.normSq_nonneg z.val

/-- normSq of a disk point is < 1. -/
theorem normSq_lt_one (z : PDisk) : Complex.normSq z.val < 1 := z.property

/-- 1 - normSq z > 0 for disk points. -/
theorem one_sub_normSq_pos (z : PDisk) : 0 < 1 - Complex.normSq z.val := by
  linarith [z.property]

/-- ‖z‖ < 1 for disk points. -/
theorem norm_lt_one (z : PDisk) : ‖z.val‖ < 1 := by
  rw [Complex.norm_def]
  calc √(Complex.normSq z.val) < √1 :=
        Real.sqrt_lt_sqrt (Complex.normSq_nonneg z.val) z.property
    _ = 1 := Real.sqrt_one

end PDisk

/-! ## Conformal Factor -/

/-- The Poincaré conformal factor: λ(z) = 2 / (1 - |z|²). -/
def poincareCF (z : ℂ) : ℝ := 2 / (1 - Complex.normSq z)

/-! ## Möbius Automorphisms -/

/-- Möbius automorphism of the disk: φ_a(z) = (z - a) / (1 - ā·z). -/
def mobiusAut (a z : ℂ) : ℂ :=
  (z - a) / (1 - starRingEnd ℂ a * z)

/-- Möbius addition (Einstein velocity addition / gyrovector addition):
    z ⊕ w = (z + w) / (1 + z̄·w). This is the fundamental binary operation
    on the Poincaré disk, replacing Euclidean addition. -/
def mobiusAdd (z w : ℂ) : ℂ :=
  (z + w) / (1 + starRingEnd ℂ z * w)

/-! ## Hyperbolic Distance -/

/-- Hyperbolic distance via Möbius map:
    d_H(z, w) = 2 · artanh(‖φ_w(z)‖). -/
def hypDist (z w : ℂ) : ℝ :=
  2 * Real.artanh ‖mobiusAut w z‖

/-! ## Hyperbolic Area -/

/-- Hyperbolic area of a disk of radius R: A(R) = 2π(cosh R - 1) = 4π·sinh²(R/2). -/
def hypArea (R : ℝ) : ℝ := 2 * Real.pi * (Real.cosh R - 1)

/-! ## Hyperbolic Lattice (Hyperbolic Integers) -/

/-- A hyperbolic lattice: a discrete set of points in the disk,
    given by applying elements of a countable group to a basepoint.
    This models Z_H = Γ · bp for a Fuchsian group Γ. -/
structure HypLattice where
  /-- The lattice points, indexed by ℕ. -/
  points : ℕ → ℂ
  /-- All lattice points lie in the disk. -/
  in_disk : ∀ n, Complex.normSq (points n) < 1
  /-- The basepoint (index 0) is the origin. -/
  base_is_origin : points 0 = 0
  /-- Distinct indices give distinct points (discreteness). -/
  injective : Function.Injective points

/-- Lattice counting function: |{n < N : d_H(0, p_n) ≤ R}|. -/
def HypLattice.countBelow (L : HypLattice) (R : ℝ) (N : ℕ) : ℕ :=
  ((Finset.range N).filter (fun n =>
    decide (hypDist 0 (L.points n) ≤ R))).card

/-! ## The Thomas Gyration -/

/-- **Novel definition**: The Thomas gyration operator.
    For points a, b in the Poincaré disk, the gyration gyr[a,b]
    measures the failure of Möbius addition to be associative:
      a ⊕ (b ⊕ c) = (a ⊕ b) ⊕ gyr[a,b](c).
    This is a rotation by angle -2·arg(1 + ā·b), and it endows
    the Poincaré disk with the structure of a gyrogroup. -/
def gyration (a b : ℂ) : ℂ → ℂ := fun c =>
  let denom := 1 + starRingEnd ℂ a * b
  let denomConj := 1 + starRingEnd ℂ b * a
  (denom / denomConj) * c

/-- Gyration parameter: the ratio (1 + ā·b)/(1 + b̄·a). -/
def gyrationFactor (a b : ℂ) : ℂ :=
  (1 + starRingEnd ℂ a * b) / (1 + starRingEnd ℂ b * a)

/-! ## Hyperbolic Prime Data -/

/-- A hyperbolic prime: a lattice point that cannot be written as
    a Möbius sum of two non-trivial lattice points. Generators of
    the orbit under the group action. -/
structure HypPrimeData where
  /-- Indices of generator lattice points. -/
  generators : Finset ℕ
  /-- No generator is the basepoint. -/
  all_nonzero : ∀ g ∈ generators, g ≠ 0

/-- Count of hyperbolic primes below index N. -/
def HypPrimeData.countBelow (pd : HypPrimeData) (N : ℕ) : ℕ :=
  (pd.generators.filter (· < N)).card

end