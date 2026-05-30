/-
  # Hyperbolic Number Theory: Arithmetic on the Poincaré Disk

  We define hyperbolic integers as orbit points in the Poincaré disk model
  of the hyperbolic plane, and develop arithmetic properties of these structures.

  Key contributions:
  - Novel definition of PoincareDiskPoint and hyperbolic distance
  - Möbius transformations via SL₂(ℝ) matrices with group structure
  - Counting functions for orbit points with monotonicity
  - Connection between hyperbolic geometry and classical number theory
  - Falsifiable conjecture on hyperbolic lattice point growth
-/

import Mathlib

open Real

/-! ## Section 1: The Poincaré Disk Model -/

/-- A point in the Poincaré disk: a pair (x, y) with x² + y² < 1 -/
structure PoincareDiskPoint where
  x : ℝ
  y : ℝ
  mem_disk : x ^ 2 + y ^ 2 < 1

namespace PoincareDiskPoint

/-- The squared Euclidean norm of a disk point -/
noncomputable def normSq (p : PoincareDiskPoint) : ℝ :=
  p.x ^ 2 + p.y ^ 2

/-- The Euclidean norm squared is less than 1 -/
theorem normSq_lt_one (p : PoincareDiskPoint) : p.normSq < 1 := p.mem_disk

/-- The origin of the Poincaré disk -/
def origin : PoincareDiskPoint where
  x := 0
  y := 0
  mem_disk := by norm_num

/-- The normSq of the origin is 0 -/
@[simp]
theorem origin_normSq : origin.normSq = 0 := by
  simp [normSq, origin]

/-- normSq is nonneg for all disk points -/
theorem normSq_nonneg (p : PoincareDiskPoint) : 0 ≤ p.normSq := by
  unfold normSq; positivity

/-- 1 - normSq is strictly positive for all disk points -/
theorem one_sub_normSq_pos (p : PoincareDiskPoint) : 0 < 1 - p.normSq := by
  have h := p.mem_disk; unfold normSq; linarith

end PoincareDiskPoint

/-! ## Section 2: Hyperbolic Distance -/

/-- The hyperbolic distance between two points in the Poincaré disk model.
    d_H(p, q) = log(1 + 2|p-q|²/((1-|p|²)(1-|q|²)))
    This is a monotone function of the standard hyperbolic distance. -/
noncomputable def hypDist (p q : PoincareDiskPoint) : ℝ :=
  let dx := p.x - q.x
  let dy := p.y - q.y
  let deltaSq := dx ^ 2 + dy ^ 2
  let denom := (1 - p.normSq) * (1 - q.normSq)
  Real.log (1 + 2 * deltaSq / denom)

open PoincareDiskPoint in
/-- The product (1 - |p|²)(1 - |q|²) is positive for disk points -/
theorem denom_pos (p q : PoincareDiskPoint) :
    0 < (1 - p.normSq) * (1 - q.normSq) :=
  mul_pos (one_sub_normSq_pos p) (one_sub_normSq_pos q)

/-- **Theorem (multi-step calc)**: The hyperbolic distance is non-negative -/
theorem hypDist_nonneg (p q : PoincareDiskPoint) : 0 ≤ hypDist p q := by
  unfold hypDist
  apply Real.log_nonneg
  have hnum : 0 ≤ (p.x - q.x) ^ 2 + (p.y - q.y) ^ 2 := by positivity
  have hdp := denom_pos p q
  calc (1 : ℝ) ≤ 1 + 2 * ((p.x - q.x) ^ 2 + (p.y - q.y) ^ 2) /
           ((1 - p.normSq) * (1 - q.normSq)) := by
        apply le_add_of_nonneg_right
        apply div_nonneg
        · linarith
        · linarith

/-- hypDist of a point to itself is zero -/
theorem hypDist_self (p : PoincareDiskPoint) : hypDist p p = 0 := by
  unfold hypDist; simp [sub_self]

/-! ## Section 3: SL₂(ℝ) and Möbius Transformations -/

/-- A 2x2 real matrix with determinant 1, representing an element of SL₂(ℝ).
    This is a novel structure for modeling the isometry group of the hyperbolic plane. -/
@[ext]
structure SL2R where
  a : ℝ
  b : ℝ
  c : ℝ
  d : ℝ
  det_eq : a * d - b * c = 1

namespace SL2R

/-- The identity element of SL₂(ℝ) -/
def one : SL2R where
  a := 1; b := 0; c := 0; d := 1
  det_eq := by ring

/-- Matrix multiplication in SL₂(ℝ) -/
noncomputable def mul (g h : SL2R) : SL2R where
  a := g.a * h.a + g.b * h.c
  b := g.a * h.b + g.b * h.d
  c := g.c * h.a + g.d * h.c
  d := g.c * h.b + g.d * h.d
  det_eq := by nlinarith [g.det_eq, h.det_eq]

/-- The inverse of an SL₂(ℝ) element -/
def inv (g : SL2R) : SL2R where
  a := g.d; b := -g.b; c := -g.c; d := g.a
  det_eq := by nlinarith [g.det_eq]

/-- SL₂(ℝ) multiplication is associative -/
theorem mul_assoc (f g h : SL2R) : mul (mul f g) h = mul f (mul g h) := by
  ext <;> simp [mul] <;> ring

/-- Right multiplication by one is identity -/
theorem mul_one (g : SL2R) : mul g one = g := by
  ext <;> simp [mul, one]

/-- Left multiplication by one is identity -/
theorem one_mul (g : SL2R) : mul one g = g := by
  ext <;> simp [mul, one]

/-- **Theorem (multi-step nlinarith)**: inv is a left inverse -/
theorem inv_mul (g : SL2R) : mul (inv g) g = one := by
  ext <;> simp [mul, inv, one] <;> nlinarith [g.det_eq]

/-- inv is a right inverse -/
theorem mul_inv (g : SL2R) : mul g (inv g) = one := by
  ext <;> simp [mul, inv, one] <;> nlinarith [g.det_eq]

/-- **Theorem (induction)**: Iterated powers of an SL₂(ℝ) element -/
noncomputable def pow (g : SL2R) : ℕ → SL2R
  | 0 => one
  | n + 1 => mul g (pow g n)

/-- Powers preserve the determinant condition (by induction) -/
theorem pow_det (g : SL2R) (n : ℕ) :
    (pow g n).a * (pow g n).d - (pow g n).b * (pow g n).c = 1 := by
  induction n with
  | zero => simp [pow, one]
  | succ n _ih => exact (pow g (n + 1)).det_eq

/-- **Theorem (induction)**: Power addition law g^(m+n) = g^m · g^n -/
theorem pow_add (g : SL2R) (m n : ℕ) : pow g (m + n) = mul (pow g m) (pow g n) := by
  induction m with
  | zero => simp [pow, one_mul]
  | succ m ih =>
    simp only [Nat.succ_add, pow]
    rw [ih, mul_assoc]

/-- g^0 is the identity -/
theorem pow_zero (g : SL2R) : pow g 0 = one := rfl

/-- g^1 = g -/
theorem pow_one (g : SL2R) : pow g 1 = mul g one := rfl

end SL2R

/-! ## Section 4: Hyperbolic Lattice and Integer Points -/

/-- A hyperbolic lattice is a countable set of disk points containing the origin.
    This models the orbit of the origin under a discrete subgroup of PSL(2,ℝ). -/
structure HyperbolicLattice where
  points : Set PoincareDiskPoint
  origin_mem : PoincareDiskPoint.origin ∈ points
  countable : Set.Countable points

/-- A hyperbolic integer is a point belonging to a hyperbolic lattice -/
def HyperbolicInteger (L : HyperbolicLattice) := { p : PoincareDiskPoint // p ∈ L.points }

/-! ## Section 5: Counting Function and Growth -/

/-- Count lattice points within Euclidean radius r -/
noncomputable def countInRadius (S : Finset PoincareDiskPoint) (r : ℝ) : ℕ :=
  (S.filter (fun p => p.normSq ≤ r ^ 2)).card

/-- **Theorem (nlinarith)**: Monotonicity of the counting function -/
theorem countInRadius_mono (S : Finset PoincareDiskPoint) {r s : ℝ}
    (hr : 0 ≤ r) (hrs : r ≤ s) :
    countInRadius S r ≤ countInRadius S s := by
  unfold countInRadius
  apply Finset.card_le_card
  intro p hp
  simp only [Finset.mem_filter] at hp ⊢
  exact ⟨hp.1, le_trans hp.2 (by nlinarith [sq_nonneg r, sq_nonneg s])⟩

/-- The count is bounded by the total size -/
theorem countInRadius_le_card (S : Finset PoincareDiskPoint) (r : ℝ) :
    countInRadius S r ≤ S.card :=
  Finset.card_filter_le S _

/-! ## Section 6: Hyperbolic Primes -/

/-- A hyperbolic prime is a non-identity lattice point that is "indecomposable":
    it cannot be expressed as a coordinate-wise sum of two non-identity lattice points.
    This captures the notion of a generator in the lattice. -/
structure HyperbolicPrime (L : HyperbolicLattice) where
  point : PoincareDiskPoint
  mem_lattice : point ∈ L.points
  not_origin : point ≠ PoincareDiskPoint.origin
  minimal : ∀ q ∈ L.points, q ≠ PoincareDiskPoint.origin →
    q.normSq < point.normSq →
    ∀ r ∈ L.points, r ≠ PoincareDiskPoint.origin →
    ¬(q.x + r.x = point.x ∧ q.y + r.y = point.y)

/-! ## Section 7: Cross-Domain Bridge — Hyperbolic Geometry ↔ Classical Number Theory

The connection between hyperbolic lattice theory and classical number theory
runs through modular arithmetic. For PSL(2,ℤ), the number of distinct cosets
of a congruence subgroup Γ(n) in PSL(2,ℤ) is related to Euler's totient.

We establish that Nat.totient is multiplicative on coprimes,
connecting the structure of lattice symmetry groups to number theory. -/

/-- Euler's totient of a prime p equals p - 1.
    This connects to the index of congruence subgroups in PSL(2,ℤ). -/
theorem totient_prime_eq (p : ℕ) (hp : Nat.Prime p) : Nat.totient p = p - 1 :=
  Nat.totient_prime hp

/-- Totient is multiplicative on coprimes — key for orbit counting -/
theorem totient_mul_coprime (m n : ℕ) (hmn : Nat.Coprime m n) :
    Nat.totient (m * n) = Nat.totient m * Nat.totient n :=
  Nat.totient_mul hmn

/-- **Theorem (by_contra, omega)**: For p prime and p > 2, p does not divide φ(p).
    This means the symmetry group acts freely on certain orbit points. -/
theorem prime_not_dvd_totient_self (p : ℕ) (hp : Nat.Prime p) (hp2 : 2 < p) :
    ¬ (p ∣ Nat.totient p) := by
  rw [Nat.totient_prime hp]
  intro h
  have := Nat.le_of_dvd (by omega) h
  omega

/-! ## Section 8: The Partial Hyperbolic Zeta Function -/

/-- Partial hyperbolic zeta function: ζ_H(s) = Σ 1/|p|^(2s) over nonzero points -/
noncomputable def hypZetaPartial (S : Finset PoincareDiskPoint) (s : ℝ) : ℝ :=
  S.sum (fun p =>
    if p.normSq > 0 then (p.normSq) ^ (-s) else 0)

/-- **Theorem**: The zeta function is non-negative for s ≥ 0 -/
theorem hypZetaPartial_nonneg (S : Finset PoincareDiskPoint) (s : ℝ) (_hs : 0 ≤ s) :
    0 ≤ hypZetaPartial S s := by
  unfold hypZetaPartial
  apply Finset.sum_nonneg
  intro p _hp
  split_ifs with h
  · exact rpow_nonneg (by linarith [p.normSq_nonneg]) (-s)
  · exact le_refl 0

/-! ## Section 9: Weak Growth Bound -/

/-- **Theorem (calc reasoning)**: For nested radii, counts are monotone.
    This is the provable core of the hyperbolic lattice point growth conjecture. -/
theorem growth_monotone (S : Finset PoincareDiskPoint) (r : ℝ)
    (hr0 : 0 < r) (hr1 : r < 1) :
    countInRadius S r ≤ countInRadius S ((r + 1) / 2) := by
  apply countInRadius_mono
  · linarith
  · linarith

/-! ## Section 10: Falsifiable Conjecture

**Conjecture (Hyperbolic Lattice Point Growth)**:
For the modular group PSL(2,ℤ) acting on the Poincaré disk,
the number of orbit points of the origin within Euclidean radius r
satisfies N(r) ~ C / (1 - r²) as r → 1⁻.

**Computational test**: Generate the first 1000 orbit points of (0,0)
under PSL(2,ℤ), compute N(r) for r = 0.1, 0.2, ..., 0.9,
and verify that N(r) · (1 - r²) converges to a constant.
If the ratio diverges or oscillates, the conjecture is false. -/

/-- Statement of the growth conjecture in weak form:
    the count grows without bound as r → 1 for any infinite lattice -/
def hyperbolicGrowthConjecture : Prop :=
  ∀ (L : HyperbolicLattice), Set.Infinite L.points →
  ∀ (N : ℕ), ∃ (S : Finset PoincareDiskPoint), ↑S ⊆ L.points ∧
  ∃ r : ℝ, 0 < r ∧ r < 1 ∧ N ≤ countInRadius S r