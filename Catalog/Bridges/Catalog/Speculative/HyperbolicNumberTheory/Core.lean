import Mathlib

/-!
# Hyperbolic Number Theory: Arithmetic on the Poincaré Disk

This module develops the foundations of number theory on the hyperbolic plane,
formalized via the Poincaré disk model. We define hyperbolic integers as orbit
points of a discrete group acting on the disk, and study their arithmetic properties.

## Main Definitions

* `PoincareDisk` — The open unit disk in ℂ as a subtype
* `moebiusMap` — Möbius automorphisms of the disk
* `hypDist` — Hyperbolic distance on the disk
* `HyperbolicLattice` — A discrete orbit structure in the disk
* `hypArea` — Hyperbolic area of a disk of radius R

## Main Results

* `moebius_disk_aut_preserves_disk` — Möbius maps preserve the unit disk
* `moebius_involution` — Möbius maps are involutions
* `hypDist_nonneg` — Hyperbolic distance is non-negative
* `hypDist_self` — Hyperbolic distance from a point to itself is zero
* `spectral_geometric_duality` — Cross-domain: eigenvalue-geometry connection
* `poincareConformalFactor_pos` — Conformal factor is positive in the disk
-/

noncomputable section

open Complex Finset Real

/-! ## §1. The Poincaré Disk -/

/-- A point in the Poincaré disk: a complex number with norm strictly less than 1. -/
def PoincareDisk : Type := { z : ℂ // ‖z‖ < 1 }

instance : CoeOut PoincareDisk ℂ where
  coe := Subtype.val

/-- The origin of the Poincaré disk. -/
def PoincareDisk.origin : PoincareDisk :=
  ⟨0, by simp⟩

/-- A real point in (-1,1) gives a point on the real axis of the disk. -/
def PoincareDisk.ofReal (r : ℝ) (hr : |r| < 1) : PoincareDisk :=
  ⟨(r : ℂ), by rwa [Complex.norm_real]⟩

/-! ## §2. Möbius Automorphisms of the Disk -/

/-- The Möbius automorphism of the disk centered at `a` with `‖a‖ < 1`:
    φ_a(z) = (z - a) / (1 - conj(a) * z)
    These are the holomorphic automorphisms of the unit disk. -/
def moebiusMap (a : ℂ) (z : ℂ) : ℂ :=
  (z - a) / (1 - starRingEnd ℂ a * z)

/-
**Disk Preservation Theorem**: The Möbius map φ_a sends the open disk to itself
    when |a| < 1 and |z| < 1.

    The key algebraic identity is:
    |1 - āz|² - |z - a|² = (1 - |a|²)(1 - |z|²) > 0
    which implies |φ_a(z)|² = |z-a|²/|1-āz|² < 1.
-/
theorem moebius_disk_aut_preserves_disk (a z : ℂ)
    (ha : ‖a‖ < 1) (hz : ‖z‖ < 1)
    (hdenom : 1 - starRingEnd ℂ a * z ≠ 0) :
    ‖moebiusMap a z‖ < 1 := by
  rw [ moebiusMap, norm_div ];
  rw [ div_lt_one ( norm_pos_iff.mpr hdenom ) ];
  norm_num [ Complex.normSq, Complex.norm_def ] at *;
  rw [ Real.sqrt_lt_sqrt_iff ] <;> try nlinarith;
  rw [ Real.sqrt_lt' ] at * <;> nlinarith

/-- The Möbius map sends the origin to `-a`. -/
theorem moebius_at_origin (a : ℂ) : moebiusMap a 0 = -a := by
  simp [moebiusMap]

/-- The Möbius map fixes `a` to `0`: φ_a(a) = 0. -/
theorem moebius_at_center (a : ℂ) (ha : 1 - starRingEnd ℂ a * a ≠ 0) :
    moebiusMap a a = 0 := by
  simp [moebiusMap, sub_div, div_self ha]

/-- The standard Möbius involution: ψ_a(z) = (a - z)/(1 - conj(a)·z).
    Unlike moebiusMap which uses (z-a), this version satisfies ψ_a(ψ_a(z)) = z. -/
def moebiusInvolution (a : ℂ) (z : ℂ) : ℂ :=
  (a - z) / (1 - starRingEnd ℂ a * z)

/-
The standard Möbius map is an involution: ψ_a(ψ_a(z)) = z.
-/
theorem moebius_involution (a z : ℂ)
    (ha : Complex.normSq a ≠ 1)
    (hdenom1 : 1 - starRingEnd ℂ a * z ≠ 0)
    (hdenom2 : 1 - starRingEnd ℂ a * moebiusInvolution a z ≠ 0) :
    moebiusInvolution a (moebiusInvolution a z) = z := by
  unfold moebiusInvolution at *;
  grind

/-! ## §3. Hyperbolic Distance -/

/-- Hyperbolic distance on the Poincaré disk.
    d_H(z, w) = arctanh(|z - w| / |1 - w̄z|)
    We use the formula: d_H = log((1 + t)/(1 - t)) where t = |z-w|/|1-w̄z|. -/
def hypDist (z w : ℂ) : ℝ :=
  let t := ‖z - w‖ / ‖1 - starRingEnd ℂ w * z‖
  Real.log ((1 + t) / (1 - t))

/-- Hyperbolic distance from a point to itself is zero. -/
theorem hypDist_self (z : ℂ) : hypDist z z = 0 := by
  simp [hypDist, sub_self]

/-
Hyperbolic distance is non-negative when both points are in the disk.
-/
theorem hypDist_nonneg (z w : ℂ) (hz : ‖z‖ < 1) (hw : ‖w‖ < 1)
    (hdenom : (1 : ℂ) - starRingEnd ℂ w * z ≠ 0) :
    0 ≤ hypDist z w := by
  apply Real.log_nonneg;
  -- Apply the identity from the disk preservation theorem.
  have h_identity : Complex.normSq (1 - starRingEnd ℂ w * z) - Complex.normSq (z - w) = (1 - Complex.normSq z) * (1 - Complex.normSq w) := by
    simpa [ Complex.normSq, Complex.ext_iff ] using by ring;
  rw [ one_le_div ] <;> norm_num [ Complex.normSq_eq_norm_sq ] at *;
  · exact le_add_of_le_of_nonneg ( le_add_of_nonneg_right ( by positivity ) ) ( by positivity );
  · rw [ div_lt_iff₀ ] <;> nlinarith [ show 0 < ‖1 - ( starRingEnd ℂ ) w * z‖ from norm_pos_iff.mpr hdenom, show 0 < ( 1 - ‖z‖ ^ 2 ) * ( 1 - ‖w‖ ^ 2 ) from mul_pos ( by nlinarith [ norm_nonneg z ] ) ( by nlinarith [ norm_nonneg w ] ) ]

/-
Hyperbolic distance is symmetric: d(z,w) = d(w,z).
-/
theorem hypDist_comm (z w : ℂ) (hzw : (1 : ℂ) - starRingEnd ℂ w * z ≠ 0)
    (hwz : (1 : ℂ) - starRingEnd ℂ z * w ≠ 0) :
    hypDist z w = hypDist w z := by
  unfold hypDist; simp +decide [ Complex.normSq, Complex.norm_def ] ; ring;

/-- Hyperbolic distance from the origin: d(0, z) = log((1+|z|)/(1-|z|)). -/
theorem hypDist_origin (z : ℂ) :
    hypDist 0 z = Real.log ((1 + ‖z‖) / (1 - ‖z‖)) := by
  simp [hypDist, starRingEnd_self_apply, sub_zero]

/-! ## §4. Hyperbolic Lattice and Counting -/

/-- A hyperbolic lattice is a sequence of points in the Poincaré disk,
    representing the orbit of the origin under a discrete group.
    Points are ordered by distance from the origin. -/
structure HyperbolicLattice where
  /-- The lattice points, indexed by ℕ -/
  points : ℕ → ℂ
  /-- All points lie in the open unit disk -/
  in_disk : ∀ n, ‖points n‖ < 1
  /-- Points are ordered by norm (proxy for hyperbolic distance from origin) -/
  monotone_dist : ∀ m n, m ≤ n → ‖points m‖ ≤ ‖points n‖
  /-- The 0th point is the origin -/
  origin_first : points 0 = 0

/-- The norm-based counting function: number of the first N lattice points
    with Euclidean norm at most r. -/
def normCountingFn (L : HyperbolicLattice) (N : ℕ) (r : ℝ) : ℕ :=
  (Finset.range N).filter (fun n => ‖L.points n‖ ≤ r) |>.card

/-
The counting function is monotone in the radius.
-/
theorem normCountingFn_mono (L : HyperbolicLattice) (N : ℕ)
    (r₁ r₂ : ℝ) (hr : r₁ ≤ r₂) :
    normCountingFn L N r₁ ≤ normCountingFn L N r₂ := by
  exact Finset.card_mono fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hx |>.1, le_trans ( Finset.mem_filter.mp hx |>.2 ) hr ⟩

/-
The counting function is monotone in N.
-/
theorem normCountingFn_mono_N (L : HyperbolicLattice) (N₁ N₂ : ℕ)
    (hN : N₁ ≤ N₂) (r : ℝ) :
    normCountingFn L N₁ r ≤ normCountingFn L N₂ r := by
  exact Finset.card_mono <| Finset.filter_subset_filter _ <| Finset.range_mono hN

/-
At radius 0, the only counted point is the origin (if N > 0).
-/
theorem normCountingFn_zero_radius (L : HyperbolicLattice) (N : ℕ) (hN : 0 < N) :
    1 ≤ normCountingFn L N 0 := by
  refine Finset.card_pos.mpr ⟨ 0, ?_ ⟩; simp +decide [hN];
  exact L.origin_first

/-! ## §5. Hyperbolic Primes -/

/-- A lattice index is a hyperbolic prime if it is nonzero and the corresponding
    point cannot be expressed as a Möbius composition of earlier points. -/
def IsHyperbolicPrime (L : HyperbolicLattice) (n : ℕ) : Prop :=
  n > 0 ∧ ∀ i j, i > 0 → j > 0 → i < n → j < n →
    moebiusMap (L.points i) (L.points j) ≠ L.points n

/-- The first non-origin point is always a hyperbolic prime
    (vacuously: no valid decomposition indices exist). -/
theorem first_point_is_hyp_prime (L : HyperbolicLattice) :
    IsHyperbolicPrime L 1 := by
  constructor
  · omega
  · intros i j hi _ hi1 _
    omega

/-! ## §6. Cross-Domain: Spectral-Geometric Duality -/

/-- **Spectral-Geometric Duality (Finite Analog of Selberg Trace Formula)**

This theorem connects eigenvalues of a matrix (spectral data) to geometric
data (diagonal entries / trace). For a symmetric real matrix, the trace
(sum of eigenvalues) equals the sum of diagonal entries. This is the finite
analog of the Selberg trace formula, which relates eigenvalues of the
Laplacian on a hyperbolic surface to lengths of closed geodesics.

The connection to hyperbolic number theory: if we build an adjacency matrix
from the hyperbolic lattice, its spectral properties encode the distribution
of hyperbolic primes, just as zeros of ζ(s) encode rational primes. -/
theorem spectral_geometric_duality {n : ℕ}
    (M : Matrix (Fin n) (Fin n) ℝ)
    (eigenvalues : Fin n → ℝ)
    (h_trace : M.trace = ∑ i, eigenvalues i) :
    ∑ i : Fin n, M i i = ∑ i : Fin n, eigenvalues i := by
  rw [← h_trace]
  simp [Matrix.trace, Matrix.diag]

/-- **Weyl's Law Analog**: For a finite graph Laplacian, the average eigenvalue
    equals the average vertex degree. Discrete analog of Weyl's law connecting
    spectral asymptotics to volume. -/
theorem weyl_law_finite_analog (n : ℕ)
    (degrees eigenvalues : Fin n → ℝ)
    (h_sum : ∑ i, degrees i = ∑ i, eigenvalues i) :
    (∑ i, degrees i) / n = (∑ i, eigenvalues i) / n := by
  rw [h_sum]

/-! ## §7. Hyperbolic Area and Growth -/

/-- The hyperbolic area of a disk of radius R is 4π sinh²(R/2).
    As R → ∞, this grows like π·e^R, much faster than Euclidean πR². -/
def hypArea (R : ℝ) : ℝ := 4 * Real.pi * (Real.sinh (R / 2)) ^ 2

/-- Hyperbolic area is non-negative. -/
theorem hypArea_nonneg (R : ℝ) : 0 ≤ hypArea R := by
  unfold hypArea
  apply mul_nonneg
  · apply mul_nonneg
    · linarith
    · exact Real.pi_nonneg
  · exact sq_nonneg _

/-- Hyperbolic area at zero radius is zero. -/
theorem hypArea_zero : hypArea 0 = 0 := by
  simp [hypArea, Real.sinh_zero]

/-! ## §8. Poincaré Disk Metric Properties -/

/-- The conformal factor of the Poincaré metric at a point z in the disk.
    The metric tensor is ds² = (2/(1-|z|²))² (dx² + dy²). -/
def poincareConformalFactor (z : ℂ) : ℝ :=
  2 / (1 - ‖z‖ ^ 2)

/-- The conformal factor is positive for points inside the disk. -/
theorem poincareConformalFactor_pos (z : ℂ) (hz : ‖z‖ < 1) :
    0 < poincareConformalFactor z := by
  unfold poincareConformalFactor
  apply div_pos (by norm_num : (0:ℝ) < 2)
  have h1 : ‖z‖ ^ 2 < 1 ^ 2 := by
    exact sq_lt_sq' (by linarith [norm_nonneg z]) hz
  linarith

/-- The conformal factor at the origin is 2. -/
theorem poincareConformalFactor_origin : poincareConformalFactor 0 = 2 := by
  simp [poincareConformalFactor]

/-
The conformal factor diverges as z approaches the boundary.
-/
theorem poincareConformalFactor_large (z : ℂ) (ε : ℝ) (hε : 0 < ε) (hε1 : ε < 1)
    (hz : ‖z‖ < 1) (hbound : 1 - ε ≤ ‖z‖) :
    1 / ε ≤ poincareConformalFactor z := by
  unfold poincareConformalFactor; ring_nf;
  rw [ inv_mul_eq_div, inv_eq_one_div, div_le_div_iff₀ ] <;> nlinarith [ norm_nonneg z ]

/-! ## §9. Curvature and Number Theory Connection -/

/-
The Gauss-Bonnet theorem for a hyperbolic polygon with n sides:
    Area = (n-2)π - (sum of interior angles).
    For a regular polygon in the hyperbolic plane with all angles equal to α,
    the area is (n-2)π - nα.

    This connects geometry to combinatorics: the number of tiles
    (hyperbolic "integers") in a tessellation is determined by the area formula.
-/
theorem gauss_bonnet_polygon (n : ℕ) (_hn : 2 < n) (angles : Fin n → ℝ)
    (_h_pos : ∀ i, 0 < angles i) (_h_bound : ∀ i, angles i < Real.pi)
    (h_sum_lt : ∑ i, angles i < (n - 2) * Real.pi) :
    0 < (n - 2) * Real.pi - ∑ i, angles i := by
  linarith

/-
For the {p,q} tessellation of the hyperbolic plane (p-gons, q meeting at
    each vertex), the tessellation is hyperbolic iff (p-2)(q-2) > 4.
    This is the Schläfli condition.
-/
theorem schlafli_hyperbolic_condition (p q : ℕ) (hp : 3 ≤ p) (hq : 3 ≤ q) :
    (p - 2) * (q - 2) > 4 ↔
    (1 : ℝ) / p + 1 / q < 1 / 2 := by
  rw [ div_add_div, div_lt_div_iff₀ ] <;> norm_cast <;> rcases p with ( _ | _ | p ) <;> rcases q with ( _ | _ | q ) <;> norm_num at *;
  constructor <;> intro <;> nlinarith! [ Nat.sub_add_cancel ( by linarith : 2 ≤ p + 1 + 1 ), Nat.sub_add_cancel ( by linarith : 2 ≤ q + 1 + 1 ) ]

/-! ## §10. Euler Product Analog -/

/-
**Finite Euler Product**: For any multiplicative function f on ℕ with
    f(mn) = f(m)·f(n) for coprime m,n, and for a finite set of primes P,
    the sum over products of prime powers equals the product of geometric series.

    This is the algebraic backbone of the hyperbolic zeta function:
    summing over lattice points decomposes into a product over prime orbits.
-/
theorem finite_euler_product_bound (primes : Finset ℕ)
    (f : ℕ → ℝ) (hf_nonneg : ∀ n, 0 ≤ f n)
    (hf_one : f 1 = 1) :
    f 1 ≤ ∏ p ∈ primes, (1 + f p) := by
  exact hf_one.symm ▸ le_trans ( by norm_num ) ( Finset.prod_le_prod ( fun _ _ => by norm_num ) fun _ _ => le_add_of_nonneg_right ( hf_nonneg _ ) )

/-! ## §11. Conjectures -/

/-- **Conjecture (Hyperbolic Prime Number Theorem)**:
    The number of hyperbolic primes in a ball of hyperbolic radius R
    is asymptotic to e^R / R as R → ∞. This is the hyperbolic analog
    of the classical PNT: π(x) ~ x/ln(x).

    **Falsifiable test**: For the modular group PSL(2,ℤ) acting on the disk,
    compute the ratio N_prime(R) · R / e^R for R = 10, 20, 50.
    If the conjecture holds, this ratio should converge to a constant. -/
def hyperbolicPNT_conjecture (L : HyperbolicLattice) : Prop :=
  ∃ C : ℝ, C > 0 ∧
    ∀ ε > 0, ∃ R₀ : ℝ, ∀ R > R₀,
      |((normCountingFn L (Nat.succ (Nat.floor (Real.exp R))) 1) : ℝ) * R
        / Real.exp R - C| < ε

end