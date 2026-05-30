import Mathlib

/-!
# Hyperbolic Number Theory: Definitions

Core definitions for arithmetic on the Poincaré disk model of hyperbolic geometry.
-/

noncomputable section

open Complex Real

/-! ## The Poincaré Disk -/

/-- A point in the Poincaré disk: a complex number with norm strictly less than 1. -/
def PoincareDisk := {z : ℂ // ‖z‖ < 1}

namespace PoincareDisk

instance : CoeOut PoincareDisk ℂ := ⟨Subtype.val⟩

/-- The origin of the Poincaré disk. -/
def origin : PoincareDisk := ⟨0, by simp⟩

/-- The norm squared of a Poincaré disk point is less than 1. -/
lemma normSq_lt_one (z : PoincareDisk) : Complex.normSq z.val < 1 := by
  have h2 : ‖z.val‖^2 = Complex.normSq z.val := Complex.sq_norm z.val
  have h3 : ‖z.val‖ * ‖z.val‖ < 1 * 1 := by nlinarith [norm_nonneg z.val, z.prop]
  nlinarith

/-- 1 - |z|² > 0 for any point in the Poincaré disk. -/
lemma one_sub_normSq_pos (z : PoincareDisk) : 0 < 1 - Complex.normSq z.val := by
  linarith [normSq_lt_one z]

/-- 1 - ‖z‖² > 0 for any point in the Poincaré disk (with ℕ exponent). -/
lemma one_sub_norm_sq_pos (z : PoincareDisk) : 0 < 1 - ‖z.val‖ * ‖z.val‖ := by
  have : ‖z.val‖ * ‖z.val‖ < 1 := by nlinarith [norm_nonneg z.val, z.prop]
  linarith

end PoincareDisk

/-! ## SL(2,ℝ) -/

/-- An element of SL(2,ℝ) represented by its matrix entries with det = 1. -/
structure SL2R where
  a : ℝ
  b : ℝ
  c : ℝ
  d : ℝ
  det_eq : a * d - b * c = 1

namespace SL2R

/-- The identity element of SL(2,ℝ). -/
def one : SL2R where
  a := 1; b := 0; c := 0; d := 1
  det_eq := by ring

/-- Multiplication of SL(2,ℝ) elements. -/
def mul (g h : SL2R) : SL2R where
  a := g.a * h.a + g.b * h.c
  b := g.a * h.b + g.b * h.d
  c := g.c * h.a + g.d * h.c
  d := g.c * h.b + g.d * h.d
  det_eq := by nlinarith [g.det_eq, h.det_eq]

/-- The inverse of an SL(2,ℝ) element. -/
def inv (g : SL2R) : SL2R where
  a := g.d; b := -g.b; c := -g.c; d := g.a
  det_eq := by nlinarith [g.det_eq]

end SL2R

/-! ## Möbius Addition on the Disk -/

/-- Möbius addition on the unit disk: z ⊕ w = (z + w) / (1 + z̄w).
    This is the "Einstein velocity addition" formula and gives a
    gyrogroup structure on the Poincaré disk. -/
def moebiusAdd (z w : ℂ) : ℂ :=
  (z + w) / (1 + starRingEnd ℂ z * w)

/-- The Poincaré metric conformal factor at a point z in the disk. -/
def poincareConformal (z : PoincareDisk) : ℝ :=
  2 / (1 - Complex.normSq z.val)

/-! ## Hyperbolic Lattice -/

/-- A hyperbolic lattice: an injective sequence of points in the Poincaré disk
    with the origin as the first element. -/
structure HyperbolicLattice where
  points : ℕ → PoincareDisk
  origin_mem : points 0 = PoincareDisk.origin
  injective : Function.Injective points

/-- The hyperbolic norm: the Euclidean norm of a point in the disk,
    which is monotonically related to hyperbolic distance from origin.
    We use ‖z‖ as a proxy for the full artanh-based distance. -/
def hypNorm (z : PoincareDisk) : ℝ := ‖z.val‖

/-- Count lattice points among the first N with hypNorm ≤ R. -/
def hypCountingN (L : HyperbolicLattice) (R : ℝ) (N : ℕ) : ℕ :=
  (Finset.range N).filter (fun n => hypNorm (L.points n) ≤ R) |>.card

/-- A lattice point at index n is hyperbolic-prime if it cannot be expressed
    as a Möbius sum of two other non-origin lattice points with smaller index. -/
def IsHypPrime (L : HyperbolicLattice) (n : ℕ) : Prop :=
  n ≠ 0 ∧ ∀ i j : ℕ, i ≠ 0 → j ≠ 0 → i < n → j < n →
    moebiusAdd (L.points i).val (L.points j).val ≠ (L.points n).val

end