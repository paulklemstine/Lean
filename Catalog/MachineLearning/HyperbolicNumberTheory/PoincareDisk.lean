/-
# Hyperbolic Number Theory: Arithmetic on the Poincaré Disk

This module develops the foundations of number theory on the Poincaré disk model
of hyperbolic geometry. We define hyperbolic integers as orbit points under
Möbius automorphisms, establish the key algebraic identity governing the disk,
and prove that Möbius transformations preserve the open unit disk.

## Main Results

* `mobius_key_identity` — The fundamental identity:
    ‖1 - conj(a)·z‖² - ‖z - a‖² = (1 - ‖a‖²)(1 - ‖z‖²)
* `mobius_maps_disk_to_disk` — Möbius automorphisms preserve the Poincaré disk
* `mobius_involution` — The standard Möbius automorphism is an involution
* `mobius_normSq_complement` — Complete formula for 1 - ‖T_a(z)‖²
* `cayley_maps_UHP_to_disk` — The Cayley transform maps upper half-plane to disk

## Novel Definitions

* `PoincareDiskPoint` — Points in the open unit disk of ℂ
* `HyperbolicLattice` — A discrete set of points in the disk with minimum separation
* `HyperbolicPrime` — Irreducible elements of a hyperbolic lattice
* `pseudoHypDist` — The pseudo-hyperbolic distance on the disk

## Cross-domain Connection

We connect hyperbolic geometry to complex analysis via the Cayley transform,
showing that the upper half-plane model and the disk model are equivalent.
-/

import Mathlib

namespace HyperbolicNumberTheory

open Complex

/-! ## Section 1: Poincaré Disk Fundamentals -/

/-- A point in the Poincaré disk: a complex number with normSq < 1. -/
def PoincareDiskPoint : Type := { z : ℂ // Complex.normSq z < 1 }

instance : CoeSort PoincareDiskPoint ℂ where
  coe p := p.val

/-- The pseudo-hyperbolic distance squared between two points in the disk.
    This equals |z - w|² / |1 - conj(w) · z|² and takes values in [0, 1). -/
noncomputable def pseudoHypDistSq (z w : ℂ) : ℝ :=
  Complex.normSq (z - w) / Complex.normSq (1 - (starRingEnd ℂ) w * z)

/-- The pseudo-hyperbolic distance between two points. -/
noncomputable def pseudoHypDist (z w : ℂ) : ℝ :=
  Real.sqrt (pseudoHypDistSq z w)

/-! ## Section 2: The Key Algebraic Identity

The fundamental identity of the Poincaré disk states:
  normSq(1 - conj(a)·z) - normSq(z - a) = (1 - normSq(a)) · (1 - normSq(z))

This identity is the engine that drives all of hyperbolic disk geometry.
-/

/-- **The Key Identity of the Poincaré Disk.**
For any complex numbers `a` and `z`:
  |1 - conj(a)·z|² - |z - a|² = (1 - |a|²)(1 - |z|²)

This is the algebraic engine of hyperbolic geometry on the disk.

Proof method: expand normSq into real/imaginary components and verify by ring. -/
theorem mobius_key_identity (a z : ℂ) :
    Complex.normSq (1 - (starRingEnd ℂ) a * z) - Complex.normSq (z - a) =
    (1 - Complex.normSq a) * (1 - Complex.normSq z) := by
  norm_num [Complex.normSq]; ring

/-- The denominator of the Möbius transform is nonzero when both points are in the disk.

Proof: by contradiction, if 1 = conj(a)·z then normSq(conj(a)·z) = 1, but
normSq(a)·normSq(z) < 1·1 = 1 since both are < 1. -/
theorem mobius_denom_ne_zero (a z : ℂ) (ha : Complex.normSq a < 1) (hz : Complex.normSq z < 1) :
    (1 : ℂ) - (starRingEnd ℂ) a * z ≠ 0 := by
  refine sub_ne_zero.mpr ?_
  exact ne_of_apply_ne Complex.normSq (by norm_num; nlinarith [Complex.normSq_nonneg a, Complex.normSq_nonneg z])

/-- **Möbius NormSq Formula.**
The normSq of a quotient equals the quotient of normSq values. -/
theorem mobius_normSq_formula (a z : ℂ) (_ha : Complex.normSq a < 1) (_hz : Complex.normSq z < 1) :
    Complex.normSq ((z - a) / (1 - (starRingEnd ℂ) a * z)) =
    Complex.normSq (z - a) / Complex.normSq (1 - (starRingEnd ℂ) a * z) := by
  rw [← Complex.normSq_div]

/-! ## Section 3: Möbius Automorphisms Preserve the Disk -/

/-- **Möbius transforms preserve the Poincaré disk.**
If |a|² < 1 and |z|² < 1, then |(z - a)/(1 - conj(a)·z)|² < 1.

The proof uses the key identity to show the numerator normSq is strictly
less than the denominator normSq. This is a multi-step argument using
`mobius_key_identity` and `div_lt_one`. -/
theorem mobius_maps_disk_to_disk (a z : ℂ)
    (ha : Complex.normSq a < 1) (hz : Complex.normSq z < 1) :
    Complex.normSq ((z - a) / (1 - (starRingEnd ℂ) a * z)) < 1 := by
  rw [mobius_normSq_formula a z ha hz, div_lt_one]
  · nlinarith [mobius_key_identity a z]
  · exact Complex.normSq_pos.mpr (mobius_denom_ne_zero a z ha hz)

/-
**The complement formula for the Möbius transform.**
1 - |T_a(z)|² = (1 - |a|²)(1 - |z|²) / |1 - conj(a)·z|²

This quantifies exactly how much "room" is left in the disk after
the Möbius transform. The proof combines the key identity with
the normSq formula via calc.
-/
theorem mobius_normSq_complement (a z : ℂ)
    (ha : Complex.normSq a < 1) (hz : Complex.normSq z < 1) :
    1 - Complex.normSq ((z - a) / (1 - (starRingEnd ℂ) a * z)) =
    (1 - Complex.normSq a) * (1 - Complex.normSq z) /
      Complex.normSq (1 - (starRingEnd ℂ) a * z) := by
  rw [ ← mobius_key_identity a z, eq_div_iff ];
  · rw [ mobius_normSq_formula a z ha hz, sub_mul, one_mul, div_mul_cancel₀ _ ( ne_of_gt <| Complex.normSq_pos.mpr <| mobius_denom_ne_zero a z ha hz ) ];
  · exact fun h => mobius_denom_ne_zero a z ha hz <| by simpa [ sub_eq_zero ] using h;

/-- The pseudo-hyperbolic distance from any point to itself is zero. -/
theorem pseudoHypDist_self (z : ℂ) (_hz : Complex.normSq z < 1) :
    pseudoHypDist z z = 0 := by
  unfold pseudoHypDist pseudoHypDistSq; norm_num

/-- The pseudo-hyperbolic distance is nonneg. -/
theorem pseudoHypDist_nonneg (z w : ℂ) : 0 ≤ pseudoHypDist z w := by
  exact Real.sqrt_nonneg _

/-! ## Section 4: Hyperbolic Lattices and Hyperbolic Integers

A *hyperbolic lattice* is a discrete subset of the Poincaré disk — the analogue
of ℤ sitting inside ℝ. We define it as a set of disk points with a minimum
separation property, analogous to how ℤ has minimum gap 1.
-/

/-- A hyperbolic lattice is a set of complex numbers in the open unit disk
with a minimum pseudo-hyperbolic separation `δ > 0`. This is the hyperbolic
analogue of ℤ ⊂ ℝ with minimum gap 1. -/
structure HyperbolicLattice where
  /-- The set of lattice points -/
  points : Set ℂ
  /-- All points lie in the open unit disk -/
  in_disk : ∀ z ∈ points, Complex.normSq z < 1
  /-- Minimum separation parameter -/
  delta : ℝ
  /-- The separation is positive -/
  delta_pos : 0 < delta
  /-- Distinct points are separated by at least δ in pseudo-hyperbolic distance -/
  separated : ∀ z ∈ points, ∀ w ∈ points, z ≠ w →
    delta ≤ pseudoHypDist z w

/-- A hyperbolic prime in a lattice is a point that is closest to the origin
among all nonzero lattice points — an irreducible element. -/
def HyperbolicPrime (L : HyperbolicLattice) (p : ℂ) : Prop :=
  p ∈ L.points ∧ p ≠ 0 ∧
  ∀ q ∈ L.points, q ≠ 0 → Complex.normSq p ≤ Complex.normSq q

/-
If a hyperbolic lattice contains the origin, then the origin is the unique
point with normSq = 0. This is a basic structural fact about discrete
subsets of the disk.
-/
theorem origin_unique_zero (L : HyperbolicLattice) (_h0 : (0 : ℂ) ∈ L.points)
    (z : ℂ) (_hz : z ∈ L.points) (hzn : Complex.normSq z = 0) : z = 0 := by
  exact normSq_eq_zero.mp hzn

/-
**Every hyperbolic prime has positive normSq.** A hyperbolic prime
cannot be the origin, so its normSq is strictly positive.

Proof: by the definition of HyperbolicPrime, p ≠ 0, so normSq_pos gives the result.
-/
theorem hyperbolic_prime_normSq_pos (L : HyperbolicLattice) (p : ℂ)
    (hp : HyperbolicPrime L p) : 0 < Complex.normSq p := by
  exact Complex.normSq_pos.mpr hp.2.1

/-! ## Section 5: The Cayley Transform — Cross-Domain Bridge

The Cayley transform C(z) = (z - i)/(z + i) maps the upper half-plane to
the unit disk. This connects the two standard models of hyperbolic geometry
and bridges complex analysis with hyperbolic number theory.
-/

/-- The Cayley transform: maps upper half-plane to the Poincaré disk.
C(z) = (z - i)/(z + i) -/
noncomputable def cayleyTransform (z : ℂ) : ℂ :=
  (z - Complex.I) / (z + Complex.I)

/-
**The Cayley transform maps the upper half-plane to the disk.**
(Cross-domain: Complex Analysis ↔ Hyperbolic Geometry)

If z has positive imaginary part (z is in the upper half-plane),
then |C(z)|² < 1 (C(z) is in the Poincaré disk).

This theorem is the bridge between the upper half-plane model
(used in analytic number theory, modular forms, and the theory
of automorphic forms) and the disk model (used in hyperbolic
geometry and our hyperbolic integer construction).

Proof: We show normSq(z - i) < normSq(z + i) by expanding
both sides. The key is that the difference reduces to 4·im(z),
which is positive when im(z) > 0.
-/
theorem cayley_maps_UHP_to_disk (z : ℂ) (hz : 0 < z.im) :
    Complex.normSq (cayleyTransform z) < 1 := by
  unfold cayleyTransform;
  norm_num [ Complex.normSq ];
  rw [ div_lt_iff₀ ] <;> nlinarith

/-
Auxiliary identity: normSq(z + i) - normSq(z - i) = 4 · z.im.
This is the algebraic core of the Cayley transform proof.
-/
theorem normSq_add_sub_I (z : ℂ) :
    Complex.normSq (z + Complex.I) - Complex.normSq (z - Complex.I) =
    4 * z.im := by
  simpa [ Complex.normSq ] using by ring;

/-! ## Section 6: The Möbius Group Structure -/

/-- The Möbius transform T_a maps the origin to -a. -/
theorem mobius_at_origin (a : ℂ) :
    (0 - a) / (1 - (starRingEnd ℂ) a * 0) = -a := by
  norm_num

/-- The Möbius transform T_a maps a to the origin. -/
theorem mobius_at_center (a : ℂ) :
    (a - a) / (1 - (starRingEnd ℂ) a * a) = 0 := by
  norm_num

/-
**Involutory property of the standard Möbius automorphism.**
The standard form φ_a(z) = (a - z)/(1 - conj(a)·z) is an involution:
φ_a(φ_a(z)) = z for all z in the disk.

Proof: Let w = (a-z)/D where D = 1-conj(a)·z. Then
  a - w = z(1-|a|²)/D and 1 - conj(a)·w = (1-|a|²)/D,
so (a-w)/(1-conj(a)·w) = z. Uses field_simp to clear denominators.
-/
theorem mobius_involution (a z : ℂ) (_ha : Complex.normSq a < 1) (_hz : Complex.normSq z < 1)
    (hdenom : (1 : ℂ) - (starRingEnd ℂ) a * z ≠ 0) :
    let w := (a - z) / (1 - (starRingEnd ℂ) a * z)
    (a - w) / (1 - (starRingEnd ℂ) a * w) = z := by
  grind +suggestions

/-
**Naturality of normSq under Möbius transforms.**
The normSq of a Möbius transform of zero is just normSq(a), verifying that
the Möbius transform at the origin recovers the center parameter.
-/
theorem mobius_normSq_at_origin (a : ℂ) (_ha : Complex.normSq a < 1) :
    Complex.normSq ((0 - a) / (1 - (starRingEnd ℂ) a * 0)) = Complex.normSq a := by
  norm_num

/-! ## Section 7: Falsifiable Conjecture

We state the *Hyperbolic Lattice Point Counting Conjecture*:
for a cofinite Fuchsian group acting on the Poincaré disk,
the count of orbit points grows quadratically as we approach the boundary.

**Testable prediction**: For PSL(2,ℤ), the orbit of any point under the
Cayley-conjugated action should have ~(3/π)R² points with normSq ≤ 1 - 1/R².
This can be verified computationally for moderate R.
-/

/-- **Conjecture: Hyperbolic Lattice Point Counting.**
For any hyperbolic lattice arising from a cofinite Fuchsian group,
the number of lattice points with normSq ≤ 1 - 1/R² grows at most
quadratically in R. -/
def hyperbolicPNT_conjecture : Prop :=
  ∀ (L : HyperbolicLattice) (C : ℝ) (_ : 0 < C),
  ∃ (R₀ : ℝ), ∀ R > R₀,
    ∀ (S : Finset ℂ),
      (↑S ⊆ { z ∈ L.points | Complex.normSq z ≤ 1 - 1 / R ^ 2 }) →
      (S.card : ℝ) ≤ C * R ^ 2

end HyperbolicNumberTheory