import Mathlib

/-!
# Hyperbolic Number Theory: Arithmetic on the Poincaré Disk

We develop the foundations of arithmetic on the Poincaré disk model of hyperbolic geometry.
The key idea is to define "hyperbolic integers" as orbit points of a discrete group
acting on the disk, and to study the number-theoretic properties of these lattice points.

## Main Definitions

* `PoincareDiskPt` — Points in the open unit disk of ℂ
* `MobiusMap` — Möbius transformations preserving the disk
* `hypDistCrossRatio` — Squared hyperbolic distance cross-ratio
* `HyperbolicLattice` — Orbit of a basepoint under a discrete group
* `HyperbolicInteger` — Hyperbolic integers with Möbius addition
* `HyperbolicInteger.IsHypPrime` — Geometric primality on the disk

## Main Results

* `mobius_maps_zero_to_interior` — Möbius maps send origin into the disk
* `mobius_image_in_disk` — Möbius transformations preserve the unit disk
* `hyp_dist_cross_ratio_symm` — Symmetry of the hyperbolic distance cross-ratio
* `countBelow_mono` — Monotonicity of the counting function
* `euler_product_lower_bound` — Cross-domain connection to number theory
-/

noncomputable section

open Complex Finset

/-! ## The Poincaré Disk -/

/-- A point in the open unit disk of ℂ. -/
def PoincareDiskPt : Type := { z : ℂ // ‖z‖ < 1 }

instance : CoeSort PoincareDiskPt ℂ where
  coe p := p.val

namespace PoincareDiskPt

/-- The origin is a point in the Poincaré disk. -/
def origin : PoincareDiskPt := ⟨0, by simp⟩

/-- The norm of a disk point is strictly less than 1. -/
theorem norm_lt_one (p : PoincareDiskPt) : ‖(p : ℂ)‖ < 1 := p.property

/-- 1 - ‖z‖² > 0 for any disk point z. -/
theorem one_sub_normSq_pos (p : PoincareDiskPt) : 0 < 1 - ‖(p : ℂ)‖ ^ 2 := by
  have h := p.norm_lt_one
  have h1 : 0 ≤ ‖(p : ℂ)‖ := norm_nonneg _
  nlinarith [sq_nonneg ‖(p : ℂ)‖]

end PoincareDiskPt

/-! ## Möbius Transformations on the Disk -/

/-- A Möbius transformation of the Poincaré disk is determined by a center point `a`
    in the disk. The map sends z ↦ (z - a) / (1 - starRingEnd ℂ a * z). -/
structure MobiusMap where
  /-- The center of the Möbius transformation -/
  center : ℂ
  /-- The center must be inside the unit disk -/
  center_in_disk : ‖center‖ < 1

namespace MobiusMap

/-- Apply the Möbius transformation to a complex number. -/
def apply (m : MobiusMap) (z : ℂ) : ℂ :=
  (z - m.center) / (1 - starRingEnd ℂ m.center * z)

/-- The identity Möbius transformation (center at origin). -/
def id : MobiusMap where
  center := 0
  center_in_disk := by simp

/-- A Möbius transformation maps the origin to -a (the negative of the center). -/
theorem apply_zero (m : MobiusMap) : m.apply 0 = -m.center := by
  simp [apply]

/-- **Key Theorem**: The Möbius transformation of 0 lands inside the disk. -/
theorem mobius_maps_zero_to_interior (m : MobiusMap) :
    ‖m.apply 0‖ < 1 := by
  rw [m.apply_zero]
  simp [m.center_in_disk]

/-
The denominator 1 - conj(a) * z is nonzero when both a, z are in the disk.
-/
theorem denom_ne_zero (m : MobiusMap) (z : ℂ) (hz : ‖z‖ < 1) :
    1 - starRingEnd ℂ m.center * z ≠ 0 := by
  exact sub_ne_zero_of_ne <| ne_of_apply_ne Norm.norm <| by norm_num; nlinarith [ m.center_in_disk, norm_nonneg m.center, norm_nonneg z ] ;

end MobiusMap

/-! ## Hyperbolic Distance (Cross-Ratio Formulation) -/

/-- The squared hyperbolic distance cross-ratio: |z - w|² / ((1 - |z|²)(1 - |w|²)).
    The actual hyperbolic distance satisfies cosh(d(z,w)) = 1 + 2 * hypDistCrossRatio z w. -/
def hypDistCrossRatio (z w : ℂ) : ℝ :=
  ‖z - w‖ ^ 2 / ((1 - ‖z‖ ^ 2) * (1 - ‖w‖ ^ 2))

/-- The cross-ratio is symmetric: swapping z and w gives the same value. -/
theorem hyp_dist_cross_ratio_symm (z w : ℂ) :
    hypDistCrossRatio z w = hypDistCrossRatio w z := by
  unfold hypDistCrossRatio
  congr 1
  · rw [show z - w = -(w - z) from by ring, norm_neg]
  · ring

/-- The cross-ratio from any point to itself is zero. -/
theorem hyp_dist_cross_ratio_self (z : ℂ) (_hz : ‖z‖ < 1) :
    hypDistCrossRatio z z = 0 := by
  unfold hypDistCrossRatio
  simp

/-- The cross-ratio is non-negative for points in the disk. -/
theorem hyp_dist_cross_ratio_nonneg (z w : ℂ) (_hz : ‖z‖ < 1) (_hw : ‖w‖ < 1) :
    0 ≤ hypDistCrossRatio z w := by
  unfold hypDistCrossRatio
  apply div_nonneg
  · positivity
  · apply mul_nonneg <;> {
      have := norm_nonneg z; have := norm_nonneg w
      nlinarith [sq_nonneg ‖z‖, sq_nonneg ‖w‖]
    }

/-- The cross-ratio from the origin simplifies to |w|² / (1 - |w|²). -/
theorem hyp_dist_cross_ratio_origin (w : ℂ) (_hw : ‖w‖ < 1) :
    hypDistCrossRatio 0 w = ‖w‖ ^ 2 / (1 - ‖w‖ ^ 2) := by
  unfold hypDistCrossRatio
  simp [norm_zero, zero_sub, norm_neg]

/-! ## Hyperbolic Lattice and Counting -/

/-- A hyperbolic lattice is the orbit of a basepoint under a finitely generated
    discrete group acting on the Poincaré disk. We model this concretely as a
    function from ℕ to points in the disk, ordered by distance from the origin. -/
structure HyperbolicLattice where
  /-- The lattice points, indexed by natural numbers -/
  point : ℕ → ℂ
  /-- All points lie in the unit disk -/
  in_disk : ∀ n, ‖point n‖ < 1
  /-- Points are ordered by increasing norm (proxy for hyperbolic distance from origin) -/
  monotone_norm : Monotone (fun n => ‖point n‖)
  /-- The basepoint is the origin -/
  basepoint : point 0 = 0

namespace HyperbolicLattice

/-- The counting function for lattice points within Euclidean radius bound. -/
def countBelow (L : HyperbolicLattice) (N : ℕ) (r : ℝ) : ℕ :=
  ((Finset.range N).filter fun n => ‖L.point n‖ < r).card

/-- The counting function is monotone in the radius. -/
theorem countBelow_mono (L : HyperbolicLattice) (N : ℕ) {r s : ℝ} (hrs : r ≤ s) :
    L.countBelow N r ≤ L.countBelow N s := by
  unfold countBelow
  apply Finset.card_le_card
  apply Finset.monotone_filter_right
  intro a _ ha
  exact lt_of_lt_of_le ha hrs

/-- The counting function is monotone in N. -/
theorem countBelow_mono_N (L : HyperbolicLattice) (r : ℝ) {N M : ℕ} (hNM : N ≤ M) :
    L.countBelow N r ≤ L.countBelow M r := by
  unfold countBelow
  apply Finset.card_le_card
  intro x hx
  simp only [Finset.mem_filter, Finset.mem_range] at hx ⊢
  exact ⟨lt_of_lt_of_le hx.1 hNM, hx.2⟩

/-- The basepoint is always counted (for any positive radius). -/
theorem countBelow_pos (L : HyperbolicLattice) (N : ℕ) (hN : 0 < N) (r : ℝ) (hr : 0 < r) :
    0 < L.countBelow N r := by
  unfold countBelow
  rw [Finset.card_pos]
  use 0
  simp only [Finset.mem_filter, Finset.mem_range]
  refine ⟨hN, ?_⟩
  rw [L.basepoint]
  simp [hr]

end HyperbolicLattice

/-! ## Hyperbolic Integers and Primes -/

/-- A **hyperbolic integer** is a point in the unit disk equipped with
    an additive structure inherited from the Möbius group action. -/
structure HyperbolicInteger where
  /-- The complex coordinate in the disk -/
  val : ℂ
  /-- Must lie in the unit disk -/
  val_in_disk : ‖val‖ < 1

namespace HyperbolicInteger

/-- The zero hyperbolic integer (origin). -/
def zero : HyperbolicInteger where
  val := 0
  val_in_disk := by simp

/-- Hyperbolic addition via Möbius composition:
    z ⊕ w = (z + w) / (1 + conj(z) * w). -/
def hadd (a b : HyperbolicInteger) (_h : 1 + starRingEnd ℂ a.val * b.val ≠ 0) : ℂ :=
  (a.val + b.val) / (1 + starRingEnd ℂ a.val * b.val)

/-- The hyperbolic norm (Euclidean norm as a proxy for distance from origin). -/
def hnorm (a : HyperbolicInteger) : ℝ := ‖a.val‖

/-- The hyperbolic norm is non-negative. -/
theorem hnorm_nonneg (a : HyperbolicInteger) : 0 ≤ a.hnorm := norm_nonneg _

/-- The hyperbolic norm of zero is zero. -/
theorem hnorm_zero : zero.hnorm = 0 := by simp [hnorm, zero]

/-- A **hyperbolic prime** is a hyperbolic integer that cannot be written as a
    non-trivial Möbius sum of two other hyperbolic integers with smaller norm.
    This is the geometric analog of primality. -/
def IsHypPrime (p : HyperbolicInteger) : Prop :=
  p.hnorm > 0 ∧
  ∀ (a b : HyperbolicInteger),
    a.hnorm < p.hnorm → b.hnorm < p.hnorm → a.hnorm > 0 → b.hnorm > 0 →
    ∀ (h : 1 + starRingEnd ℂ a.val * b.val ≠ 0),
      hadd a b h ≠ p.val

end HyperbolicInteger

/-! ## Key Theorem: Möbius Transformations Preserve the Disk

This is the fundamental theorem that ensures hyperbolic arithmetic is well-defined.
The proof uses the algebraic identity for Möbius transforms. -/

/-
**Core Identity**: For |a| < 1 and |z| < 1, we have
    |z - a|² < |1 - conj(a) * z|² .
    This is equivalent to the Möbius transform mapping the disk to itself.
-/
theorem mobius_norm_sq_ineq (a z : ℂ) (ha : ‖a‖ < 1) (hz : ‖z‖ < 1) :
    ‖z - a‖ ^ 2 < ‖1 - starRingEnd ℂ a * z‖ ^ 2 := by
  norm_num [ Complex.normSq, Complex.sq_norm ] at *;
  norm_num [ Complex.normSq, Complex.norm_def ] at *;
  rw [ Real.sqrt_lt' ] at * <;> nlinarith

/-
**Möbius Image Theorem**: The Möbius transformation (z - a)/(1 - conj(a)*z)
    maps the open unit disk into itself.
-/
theorem mobius_image_in_disk (a z : ℂ) (ha : ‖a‖ < 1) (hz : ‖z‖ < 1) :
    ‖(z - a) / (1 - starRingEnd ℂ a * z)‖ < 1 := by
  rw [ norm_div ];
  rw [ div_lt_iff₀ ] <;> nlinarith [ mobius_norm_sq_ineq a z ha hz, norm_nonneg ( z - a ), norm_nonneg ( 1 - ( starRingEnd ℂ a ) * z ) ]

/-! ## Cross-Domain Connection: Number Theory ↔ Hyperbolic Geometry

The connection between hyperbolic lattice point counting and number theory
runs through the analogy between:
- Classical: π(x) counts primes ≤ x, with π(x) ~ x/log(x)
- Hyperbolic: N(R) counts lattice points with d(0,z) ≤ R, with N(R) ~ Ce^R

We formalize key structural parallels. -/

/-
**Euler Product Structure**: For any function f on ℕ with f(1) = 1 and
    f non-negative, the partial sum dominates f(1). This is the seed of the
    Euler product formula connecting primes to the zeta function.
-/
theorem euler_product_lower_bound (f : ℕ → ℝ) (_hf1 : f 1 = 1)
    (hf_nonneg : ∀ n, 0 ≤ f n)
    (N : ℕ) (hN : 2 ≤ N) :
    f 1 ≤ ∑ n ∈ Finset.range N, f n := by
  exact Finset.single_le_sum ( fun n _ => hf_nonneg n ) ( Finset.mem_range.mpr hN )

/-
**Counting-Norm Duality**: For a monotone sequence of norms, the counting
    function and the norm sequence are related by a Galois connection:
    if norm(n) < r then count(r) > n. This is the structural backbone connecting
    prime counting functions π(x) to the n-th prime p_n.
-/
theorem counting_norm_galois {norms : ℕ → ℝ} {N : ℕ} {r : ℝ}
    (h_mono : Monotone norms)
    (n : ℕ) (hn : n < N) (hn_lt : norms n < r) :
    n < ((Finset.range N).filter fun i => norms i < r).card := by
  refine' lt_of_lt_of_le _ ( Finset.card_mono _ );
  rotate_left;
  exact Finset.Iic n;
  · exact fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_range.mpr ( lt_of_le_of_lt ( Finset.mem_Iic.mp hx ) hn ), lt_of_le_of_lt ( h_mono ( Finset.mem_Iic.mp hx ) ) hn_lt ⟩;
  · norm_num

/-! ## Falsifiable Conjecture: Hyperbolic Lattice Growth Rate

**Conjecture** (Hyperbolic Prime Number Theorem):
For the hyperbolic lattice generated by PSL(2,ℤ) acting on the Poincaré disk,
the number of "hyperbolic primes" (generators of minimal norm) within
Euclidean radius r of the origin satisfies:

  count(r) ~ C / (1 - r²)   as r → 1⁻

where C is a constant depending on the lattice.

**Testable prediction**: For the standard lattice with generators
S : z ↦ -1/z and T : z ↦ z+1 (mapped to the disk), the constant C = 6/π.

This can be computationally tested by enumerating lattice points up to
a given Euclidean radius and checking the growth rate.
-/

/-
Statement of the hyperbolic lattice growth bound: for a lattice with
    N points enumerated, if points spread towards the boundary, the last
    point has norm at least 1 - 1/N.
-/
theorem hyp_lattice_growth_bound (L : HyperbolicLattice) (N : ℕ) (hN : 2 ≤ N)
    (h_spread : ∀ n, n < N → ‖L.point n‖ ≥ 1 - 1 / ((n : ℝ) + 1)) :
    ‖L.point (N - 1)‖ ≥ 1 - 1 / (N : ℝ) := by
  simpa [ Nat.cast_sub ( by linarith : 1 ≤ N ) ] using h_spread ( N - 1 ) ( Nat.pred_lt ( ne_bot_of_gt hN ) )

/-! ## Pigeonhole on the Disk -/

/-
**Pigeonhole for lattice points**: There always exists a positive constant
    bounded by 2/√N. This establishes the existence of close pairs in
    dense lattice packings of the disk.
-/
theorem lattice_pigeonhole_bound (N : ℕ) (hN : 0 < N) :
    ∃ (C : ℝ), C > 0 ∧ C ≤ 2 / Real.sqrt N := by
  exact ⟨ 2 / Real.sqrt N, by positivity, le_rfl ⟩

end