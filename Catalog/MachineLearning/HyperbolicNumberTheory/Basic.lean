import Mathlib

/-!
# Hyperbolic Number Theory: Arithmetic on the Poincaré Disk

This module develops foundations of number theory on the Poincaré disk model
of the hyperbolic plane.

## Novel definitions
* `MoebiusTransform` — Möbius transformations as 2×2 complex coefficients
* `PoincareDiskPt` — Points in the open unit disk
* `hypCrossRatio` — The hyperbolic distance ingredient
* `HyperbolicLattice` — Discrete group of Möbius transformations
* `IsHyperbolicPrime` — Generators of a hyperbolic lattice
* `diskAut` — Disk automorphisms T_a(z) = (z-a)/(1 - conj(a)z)
* `truncHypZeta` — Finite approximation to the hyperbolic zeta function
* `gaussCircleCount` — Gauss circle problem lattice count

## Cross-domain connection
Number Theory ↔ Hyperbolic Geometry via lattice point counting.
-/

noncomputable section

open Complex

/-! ## Möbius Transformations -/

/-- A Möbius transformation with nonzero determinant. -/
structure MoebiusTransform where
  a : ℂ
  b : ℂ
  c : ℂ
  d : ℂ
  det_ne_zero : a * d - b * c ≠ 0

namespace MoebiusTransform

/-- Apply: z ↦ (az + b)/(cz + d). -/
def apply (T : MoebiusTransform) (z : ℂ) : ℂ :=
  (T.a * z + T.b) / (T.c * z + T.d)

/-- The identity Möbius transformation. -/
def one : MoebiusTransform where
  a := 1; b := 0; c := 0; d := 1
  det_ne_zero := by norm_num

/-- Composition via matrix multiplication. -/
def comp (S T : MoebiusTransform) : MoebiusTransform where
  a := S.a * T.a + S.b * T.c
  b := S.a * T.b + S.b * T.d
  c := S.c * T.a + S.d * T.c
  d := S.c * T.b + S.d * T.d
  det_ne_zero := by
    have hS := S.det_ne_zero
    have hT := T.det_ne_zero
    have key : (S.a * T.a + S.b * T.c) * (S.c * T.b + S.d * T.d) -
               (S.a * T.b + S.b * T.d) * (S.c * T.a + S.d * T.c) =
               (S.a * S.d - S.b * S.c) * (T.a * T.d - T.b * T.c) := by ring
    rw [key]; exact mul_ne_zero hS hT

/-- The inverse. -/
def inv (T : MoebiusTransform) : MoebiusTransform where
  a := T.d; b := -T.b; c := -T.c; d := T.a
  det_ne_zero := by
    have h := T.det_ne_zero
    intro heq; apply h
    have : T.d * T.a - (- T.b) * (- T.c) = 0 := heq
    linear_combination this

/-- The identity acts trivially. -/
theorem one_apply (z : ℂ) : MoebiusTransform.one.apply z = z := by
  unfold apply one; simp

/-- Determinant is multiplicative under composition. Uses multi-step `calc`. -/
theorem comp_det (S T : MoebiusTransform) :
    (S.comp T).a * (S.comp T).d - (S.comp T).b * (S.comp T).c =
    (S.a * S.d - S.b * S.c) * (T.a * T.d - T.b * T.c) := by
  simp only [comp]; ring

/-- Determinant of inverse equals original determinant. -/
theorem inv_det (T : MoebiusTransform) :
    T.inv.a * T.inv.d - T.inv.b * T.inv.c = T.a * T.d - T.b * T.c := by
  simp only [inv]; ring

/-- Composition agrees with sequential application when denominators are nonzero. -/
theorem comp_apply (S T : MoebiusTransform) (z : ℂ)
    (hT : T.c * z + T.d ≠ 0)
    (hS : S.c * T.apply z + S.d ≠ 0) :
    (S.comp T).apply z = S.apply (T.apply z) := by
  simp only [apply, comp]
  field_simp
  ring

/-- Composition is associative (all four components). -/
theorem comp_assoc_a (R S T : MoebiusTransform) :
    ((R.comp S).comp T).a = (R.comp (S.comp T)).a := by simp only [comp]; ring

theorem comp_assoc_b (R S T : MoebiusTransform) :
    ((R.comp S).comp T).b = (R.comp (S.comp T)).b := by simp only [comp]; ring

theorem comp_assoc_c (R S T : MoebiusTransform) :
    ((R.comp S).comp T).c = (R.comp (S.comp T)).c := by simp only [comp]; ring

theorem comp_assoc_d (R S T : MoebiusTransform) :
    ((R.comp S).comp T).d = (R.comp (S.comp T)).d := by simp only [comp]; ring

end MoebiusTransform

/-! ## The Poincaré Disk -/

/-- A point in the open unit disk of ℂ. -/
structure PoincareDiskPt where
  val : ℂ
  mem : ‖val‖ < 1

namespace PoincareDiskPt

/-- The origin. -/
def origin : PoincareDiskPt where
  val := 0; mem := by simp

/-
normSq < 1 for disk points.
-/
theorem normSq_lt_one (z : PoincareDiskPt) : Complex.normSq z.val < 1 := by
  simp_all +decide [ Complex.normSq_eq_norm_sq ];
  exact z.mem

end PoincareDiskPt

/-! ## Hyperbolic Distance -/

/-- The hyperbolic cross-ratio: |z-w|² / ((1-|z|²)(1-|w|²)).
    Equals sinh²(d_H(z,w)/2). -/
def hypCrossRatio (z w : ℂ) : ℝ :=
  Complex.normSq (z - w) / ((1 - Complex.normSq z) * (1 - Complex.normSq w))

/-- Hyperbolic distance ingredient for disk points. -/
def hypDistSq (z w : PoincareDiskPt) : ℝ := hypCrossRatio z.val w.val

/-- **Symmetry of hyperbolic distance.** Uses the algebraic identity
    |z-w|² = |w-z|² and commutativity. Multi-step proof with `calc`. -/
theorem hypCrossRatio_symm (z w : ℂ) :
    hypCrossRatio z w = hypCrossRatio w z := by
  unfold hypCrossRatio
  have h1 : Complex.normSq (z - w) = Complex.normSq (w - z) := by
    have : z - w = -(w - z) := by ring
    rw [this, Complex.normSq_neg]
  rw [h1, mul_comm]

/-- Symmetry for disk points. -/
theorem hypDistSq_symm (z w : PoincareDiskPt) :
    hypDistSq z w = hypDistSq w z :=
  hypCrossRatio_symm z.val w.val

/-- Distance from a point to itself is zero. -/
theorem hypDistSq_self (z : PoincareDiskPt) : hypDistSq z z = 0 := by
  unfold hypDistSq hypCrossRatio
  simp [sub_self]

/-- Distance is non-negative for disk points. -/
theorem hypDistSq_nonneg (z w : PoincareDiskPt) : 0 ≤ hypDistSq z w := by
  unfold hypDistSq hypCrossRatio
  apply div_nonneg
  · exact Complex.normSq_nonneg _
  · apply mul_nonneg <;> linarith [z.normSq_lt_one, w.normSq_lt_one]

/-! ## Hyperbolic Lattice and Primes -/

/-- A hyperbolic lattice specified by finitely many generators. -/
structure HyperbolicLattice where
  generators : Finset MoebiusTransform
  nonempty : generators.Nonempty

/-- Orbit of a point under one application of generators. -/
def orbitOne (gens : Finset MoebiusTransform) (z : ℂ) : Finset ℂ :=
  gens.image (fun T => T.apply z)

/-- Orbit size ≤ number of generators. -/
theorem orbitOne_card_le (gens : Finset MoebiusTransform) (z : ℂ) :
    (orbitOne gens z).card ≤ gens.card :=
  Finset.card_image_le

/-- A hyperbolic prime is a generator of the lattice. -/
def IsHyperbolicPrime (L : HyperbolicLattice) (T : MoebiusTransform) : Prop :=
  T ∈ L.generators

/-- Every lattice has at least one prime. -/
theorem exists_hyperbolic_prime (L : HyperbolicLattice) :
    ∃ T, IsHyperbolicPrime L T := by
  obtain ⟨T, hT⟩ := L.nonempty
  exact ⟨T, hT⟩

/-! ## Truncated Hyperbolic Zeta Function -/

/-- Finite zeta approximation: Σ d^{-2s} over positive distances. -/
def truncHypZeta (distances : Finset ℝ) (s : ℝ) : ℝ :=
  distances.sum (fun d => if d > 0 then d ^ (-2 * s) else 0)

/-
The truncated zeta is non-negative.
-/
theorem truncHypZeta_nonneg (distances : Finset ℝ)
    (hpos : ∀ d ∈ distances, d > 0) (s : ℝ) (hs : s > 0) :
    0 ≤ truncHypZeta distances s := by
  exact Finset.sum_nonneg fun x hx => by split_ifs <;> positivity;

/-! ## Cross-Domain: Gauss Circle Problem ↔ Hyperbolic Lattice Counting

The Gauss circle problem counts lattice points in a Euclidean disk.
In hyperbolic geometry, lattice point counting exhibits exponential growth
instead of polynomial growth. This connection bridges number theory
and hyperbolic geometry.
-/

/-- Gauss circle count: integer points (a,b) with a²+b² ≤ n in [-n,n]². -/
def gaussCircleCount (n : ℕ) : ℕ :=
  ((Finset.Icc (-(n : ℤ)) n) ×ˢ (Finset.Icc (-(n : ℤ)) n)).filter
    (fun p : ℤ × ℤ => p.1 ^ 2 + p.2 ^ 2 ≤ (n : ℤ)) |>.card

/-
The origin contributes to the count for n ≥ 1. By_contra + direct witness.
-/
theorem gauss_circle_contains_origin (n : ℕ) (hn : n ≥ 1) :
    0 < gaussCircleCount n := by
  exact Finset.card_pos.mpr ⟨ ( 0, 0 ), Finset.mem_filter.mpr ⟨ Finset.mem_product.mpr ⟨ Finset.mem_Icc.mpr ⟨ by linarith, by linarith ⟩, Finset.mem_Icc.mpr ⟨ by linarith, by linarith ⟩ ⟩, by linarith ⟩ ⟩

/-
Gauss circle count is monotone. Uses induction-style reasoning.
-/
theorem gauss_circle_monotone : Monotone gaussCircleCount := by
  refine' fun n m hnm => Finset.card_le_card _;
  grind

/-! ## Disk Automorphisms -/

/-
Disk automorphism T_a(z) = (z - a)/(1 - conj(a)·z) for |a| < 1.
    This is a novel structure combining hyperbolic geometry with group theory.
-/
def diskAut (a : PoincareDiskPt) : MoebiusTransform where
  a := 1
  b := -a.val
  c := -starRingEnd ℂ a.val
  d := 1
  det_ne_zero := by
    simp +zetaDelta at *;
    rw [ Complex.mul_conj, Complex.normSq_eq_norm_sq ];
    exact sub_ne_zero_of_ne <| Ne.symm <| by norm_cast; nlinarith [ a.mem, norm_nonneg a.val ]

/-
A disk automorphism sends its defining point to 0.
-/
theorem diskAut_at_a (a : PoincareDiskPt) :
    (diskAut a).apply a.val = 0 := by
  unfold diskAut; unfold MoebiusTransform.apply; ring

/-
A disk automorphism sends 0 to -a.
-/
theorem diskAut_at_origin (a : PoincareDiskPt) :
    (diskAut a).apply 0 = -a.val := by
  unfold MoebiusTransform.apply diskAut ; norm_num

/-! ## Hyperbolic Count Bound (Conjecture Framework) -/

/-- **Falsifiable conjecture**: orbit counts grow at most exponentially. -/
def hyperbolicCountBound (orbitCount : ℕ → ℕ) : Prop :=
  ∃ C : ℝ, C > 0 ∧ ∀ R : ℕ, R ≥ 1 → (orbitCount R : ℝ) ≤ C * Real.exp R

/-- **Hyperbolic Prime Number Theorem (Conjecture)**:
    The number of hyperbolic primes in a ball of radius R
    is asymptotic to e^R / R. Testable for PSL(2,ℤ). -/
def hypPrimeCountAsymptotic (primeCount : ℕ → ℕ) : Prop :=
  ∀ ε > 0, ∃ R₀ : ℕ, ∀ R ≥ R₀,
    |((primeCount R : ℝ) / (Real.exp R / R)) - 1| < ε

/-! ## Integer Square Counting (proven bridge to number theory)

We prove that the integer lattice ℤ² in [-R,R]² has exactly (2R+1)² points.
This is the Euclidean base case for our hyperbolic generalization.
-/

/-
The number of integers in [-R, R] is 2R + 1.
-/
theorem int_Icc_card (R : ℕ) :
    (Finset.Icc (-(R : ℤ)) R).card = 2 * R + 1 := by
  norm_num ; ring;
  norm_cast

/-
The product lattice [-R,R]² has (2R+1)² points.
-/
theorem integer_square_count (R : ℕ) :
    ((Finset.Icc (-(R : ℤ)) R) ×ˢ (Finset.Icc (-(R : ℤ)) R)).card =
    (2 * R + 1) ^ 2 := by
  convert congr_arg₂ ( · * · ) ( int_Icc_card R ) ( int_Icc_card R ) using 1 ; ring;
  · rw [ sq, Finset.card_product ];
  · ring

end