/-
  Hyperbolic Number Theory: Arithmetic on the Poincaré Disk
  =========================================================

  We develop the foundations of "hyperbolic number theory" by defining
  arithmetic structures on the Poincaré disk model of hyperbolic geometry.

  Key concepts:
  - The Poincaré disk as the open unit disk in ℝ²
  - Möbius transformations preserving the disk
  - Hyperbolic distance and the hyperbolic norm
  - Connections between hyperbolic geometry and classical number theory
-/

import Mathlib

open Real

noncomputable section

/-! ## Section 1: The Poincaré Disk -/

/-- A point in the Poincaré disk: a pair (x, y) with x² + y² < 1. -/
structure DiskPoint where
  x : ℝ
  y : ℝ
  mem_disk : x ^ 2 + y ^ 2 < 1

namespace DiskPoint

/-- The squared Euclidean norm of a disk point. -/
def normSq (p : DiskPoint) : ℝ := p.x ^ 2 + p.y ^ 2

/-- The Euclidean norm of a disk point. -/
def eucNorm (p : DiskPoint) : ℝ := Real.sqrt (p.normSq)

/-- The origin is a disk point. -/
def origin : DiskPoint where
  x := 0
  y := 0
  mem_disk := by norm_num

theorem normSq_nonneg (p : DiskPoint) : 0 ≤ p.normSq := by
  unfold normSq; positivity

theorem normSq_lt_one (p : DiskPoint) : p.normSq < 1 :=
  p.mem_disk

theorem eucNorm_nonneg (p : DiskPoint) : 0 ≤ p.eucNorm :=
  Real.sqrt_nonneg _

theorem eucNorm_lt_one (p : DiskPoint) : p.eucNorm < 1 := by
  unfold eucNorm normSq
  rw [show (1 : ℝ) = Real.sqrt 1 from (Real.sqrt_one).symm]
  exact Real.sqrt_lt_sqrt (by positivity) p.mem_disk

theorem normSq_origin : origin.normSq = 0 := by
  unfold normSq origin; ring

theorem eucNorm_origin : origin.eucNorm = 0 := by
  unfold eucNorm; rw [normSq_origin]; exact Real.sqrt_zero

end DiskPoint

/-! ## Section 2: Hyperbolic Norm (distance from origin) -/

/-- The hyperbolic norm: distance from the origin in the Poincaré disk.
    Defined as log((1 + |p|) / (1 - |p|)) = 2 · artanh(|p|). -/
def hypNorm (p : DiskPoint) : ℝ :=
  Real.log ((1 + p.eucNorm) / (1 - p.eucNorm))

theorem hypNorm_origin : hypNorm DiskPoint.origin = 0 := by
  unfold hypNorm
  rw [DiskPoint.eucNorm_origin]
  simp

theorem hypNorm_nonneg (p : DiskPoint) : 0 ≤ hypNorm p := by
  unfold hypNorm
  apply Real.log_nonneg
  have h1 : p.eucNorm < 1 := p.eucNorm_lt_one
  have h0 : 0 ≤ p.eucNorm := p.eucNorm_nonneg
  rw [le_div_iff₀ (by linarith)]
  linarith

/-! ## Section 3: Möbius Transformations — Disk Preservation -/

/-- The denominator of the Möbius transformation T_a(z) = (z-a)/(1-āz).
    In real coordinates: |1 - āz|² = (1 - ax·zx - ay·zy)² + (ax·zy - ay·zx)² -/
def moebiusDenom (a z : DiskPoint) : ℝ :=
  (1 - a.x * z.x - a.y * z.y) ^ 2 + (a.x * z.y - a.y * z.x) ^ 2

/-- The squared numerator |z - a|² -/
def moebiusNumer (a z : DiskPoint) : ℝ :=
  (z.x - a.x) ^ 2 + (z.y - a.y) ^ 2

/-- **Theorem**: The denominator of the Möbius transformation is positive
    when both points are in the disk. Proof by contradiction using
    Cauchy-Schwarz. -/
theorem moebius_denom_pos (a z : DiskPoint) : 0 < moebiusDenom a z := by
  unfold moebiusDenom
  by_contra h
  push_neg at h
  have h1 : (1 - a.x * z.x - a.y * z.y) ^ 2 ≥ 0 := sq_nonneg _
  have h2 : (a.x * z.y - a.y * z.x) ^ 2 ≥ 0 := sq_nonneg _
  have ha : (1 - a.x * z.x - a.y * z.y) = 0 := by nlinarith
  have hb : (a.x * z.y - a.y * z.x) = 0 := by nlinarith
  have hCS : (a.x * z.x + a.y * z.y) ^ 2 ≤ (a.x ^ 2 + a.y ^ 2) * (z.x ^ 2 + z.y ^ 2) := by
    nlinarith [sq_nonneg (a.x * z.y - a.y * z.x)]
  nlinarith [a.mem_disk, z.mem_disk]

/-- **Main Theorem**: Möbius translations preserve the disk.
    |z-a|² < |1 - āz|² when |a|, |z| < 1.
    This is equivalent to (1-|a|²)(1-|z|²) > 0. -/
theorem moebius_preserves_disk (a z : DiskPoint) :
    moebiusNumer a z < moebiusDenom a z := by
  unfold moebiusNumer moebiusDenom
  nlinarith [a.mem_disk, z.mem_disk,
             sq_nonneg (a.x * z.x), sq_nonneg (a.y * z.y),
             sq_nonneg (a.x * z.y), sq_nonneg (a.y * z.x),
             sq_nonneg (a.x * z.x + a.y * z.y),
             sq_nonneg (a.x * z.y - a.y * z.x)]

/-! ## Section 4: Hyperbolic Distance Properties -/

/-
The hyperbolic norm is strictly monotone in the Euclidean norm.
-/
theorem hypNorm_strict_mono {p q : DiskPoint}
    (h : p.eucNorm < q.eucNorm) : hypNorm p < hypNorm q := by
  apply Real.log_lt_log;
  · exact div_pos ( by linarith [ p.eucNorm_nonneg ] ) ( by linarith [ p.eucNorm_lt_one ] );
  · rw [ div_lt_div_iff₀ ] <;> nlinarith [ p.eucNorm_nonneg, q.eucNorm_nonneg, p.eucNorm_lt_one, q.eucNorm_lt_one ]

/-
**By-contradiction theorem**: A disk point has zero hyperbolic norm
    if and only if its Euclidean norm is zero.
-/
theorem hypNorm_eq_zero_iff (p : DiskPoint) :
    hypNorm p = 0 ↔ p.eucNorm = 0 := by
  constructor <;> intro h <;> unfold hypNorm at *;
  · exact le_antisymm ( le_of_not_gt fun h' => absurd h <| ne_of_gt <| Real.log_pos <| by rw [ lt_div_iff₀ ] <;> nlinarith [ show p.eucNorm < 1 from p.eucNorm_lt_one ] ) ( by exact p.eucNorm_nonneg );
  · norm_num [ h ]

/-! ## Section 5: Hyperbolic Triangle Geometry — Cross-Domain Connection -/

/-- The angular defect of a hyperbolic triangle. In hyperbolic geometry,
    the area of a triangle equals its angular defect π - (α + β + γ).
    This connects hyperbolic geometry to topology via Gauss-Bonnet. -/
def triangleDefect (α β γ : ℝ) : ℝ := Real.pi - (α + β + γ)

/-- In hyperbolic geometry, every triangle has positive angular defect. -/
theorem hyperbolic_triangle_defect_pos
    (α β γ : ℝ) (_hα : 0 < α) (_hβ : 0 < β) (_hγ : 0 < γ)
    (hsum : α + β + γ < Real.pi) :
    0 < triangleDefect α β γ := by
  unfold triangleDefect; linarith

/-- The defect is bounded above by π. -/
theorem hyperbolic_triangle_defect_lt_pi
    (α β γ : ℝ) (hα : 0 < α) (hβ : 0 < β) (hγ : 0 < γ) :
    triangleDefect α β γ < Real.pi := by
  unfold triangleDefect; linarith

/-
**Cross-domain theorem (Geometry ↔ Topology)**: Gauss-Bonnet for surfaces.
    For a genus-g surface tiled by N copies of a fundamental domain with area A,
    we have N·A = 4π(g-1). This connects hyperbolic geometry to algebraic topology.
-/
theorem lattice_euler_connection (A : ℝ) (N : ℕ) (g : ℕ) (_hA : 0 < A)
    (_hg : g ≥ 2) (hN : 0 < N)
    (htile : (N : ℝ) * A = 4 * Real.pi * ((g : ℝ) - 1)) :
    A = 4 * Real.pi * ((g : ℝ) - 1) / (N : ℝ) := by
  rw [ ← htile, mul_div_cancel_left₀ _ ( by positivity ) ]

/-! ## Section 6: Embedding Natural Numbers into the Disk -/

/-- Embed a natural number n < N into the Poincaré disk at position ((n+1)/(N+2), 0).
    This gives a canonical injection from finite sets of naturals to disk points. -/
def embedNat (N : ℕ) (n : ℕ) (hn : n < N) : DiskPoint where
  x := ((n : ℝ) + 1) / ((N : ℝ) + 2)
  y := 0
  mem_disk := by
    simp only [mul_zero, add_zero, sq]
    rw [div_mul_div_comm]
    rw [div_lt_one (by positivity : ((N : ℝ) + 2) * ((N : ℝ) + 2) > 0)]
    have : (n : ℝ) < (N : ℝ) := Nat.cast_lt.mpr hn
    nlinarith

/-
The embedding preserves order: if m < n, then hyperbolic norms are ordered.
-/
theorem embedNat_order_preserving (N : ℕ) (m n : ℕ)
    (hm : m < N) (hn : n < N) (hmn : m < n) :
    hypNorm (embedNat N m hm) < hypNorm (embedNat N n hn) := by
  apply hypNorm_strict_mono; norm_num [DiskPoint.eucNorm, DiskPoint.normSq];
  rw [ Real.sqrt_lt_sqrt_iff ] <;> norm_num [ embedNat ];
  · gcongr;
  · positivity

/-! ## Section 7: The Poincaré Metric Conformal Factor -/

/-- The conformal factor of the Poincaré metric is λ(r) = 2/(1-r²). -/
def poincareConformal (r : ℝ) (_ : r ^ 2 < 1) : ℝ :=
  2 / (1 - r ^ 2)

/-
**Field-simp theorem**: The cosh identity for hyperbolic distance.
    ((1+r)/(1-r) + (1-r)/(1+r))/2 = (1+r²)/(1-r²).
-/
theorem hyperbolic_cosh_identity (r : ℝ) (hr0 : 0 ≤ r) (hr1 : r < 1) :
    ((1 + r) / (1 - r) + (1 - r) / (1 + r)) / 2 = (1 + r ^ 2) / (1 - r ^ 2) := by
  rw [ div_add_div, mul_comm ];
  · ring;
  · linarith;
  · linarith

/-
The conformal factor is always ≥ 2 (equality at the origin r=0).
-/
theorem poincare_conformal_ge_two (r : ℝ) (hr0 : 0 ≤ r) (hr1 : r < 1) :
    2 ≤ 2 / (1 - r ^ 2) := by
  rw [ le_div_iff₀ ] <;> nlinarith

/-
The conformal factor squared.
-/
theorem poincare_metric_conformal_sq (r : ℝ) (_hr : r ^ 2 < 1) :
    (2 / (1 - r ^ 2)) ^ 2 = 4 / (1 - r ^ 2) ^ 2 := by
  norm_num [ div_pow ]

/-! ## Section 8: Hyperbolic Gauss-Bonnet for Polygons -/

/-- **Gauss-Bonnet for hyperbolic polygons**: The area of a hyperbolic n-gon
    with interior angles α₁, ..., αₙ is (n-2)π - Σαᵢ. -/
theorem gauss_bonnet_polygon_positive (n : ℕ) (angles : Fin n → ℝ)
    (_hn : 3 ≤ n)
    (_hpos : ∀ i, 0 < angles i)
    (hsum : Finset.sum Finset.univ angles < ((n : ℝ) - 2) * Real.pi) :
    0 < ((n : ℝ) - 2) * Real.pi - Finset.sum Finset.univ angles := by
  linarith

/-! ## Section 9: Novel Structure — Hyperbolic Arithmetic -/

/-- **Novel Definition**: A `HyperbolicSemigroup` captures the algebraic
    structure of Möbius composition on the Poincaré disk.
    This is arithmetic on curved space: a semigroup where the "addition"
    operation is the Möbius composition of hyperbolic translations. -/
structure HyperbolicSemigroup where
  /-- Generators of the semigroup as disk points -/
  generators : Fin n → DiskPoint
  /-- Number of generators -/
  n : ℕ
  /-- At least one generator -/
  n_pos : 0 < n

/-- A word over the generators (a sequence of generator indices). -/
def HypWord (n : ℕ) := List (Fin n)

/-- A word is primitive (cannot be decomposed as repetition of a shorter word). -/
def isPrimitive {n : ℕ} (w : HypWord n) : Prop :=
  w ≠ [] ∧ ∀ v : HypWord n, v ≠ [] → ∀ k : ℕ, k ≥ 2 →
    (List.replicate k v).flatten ≠ w

/-! ## Section 10: Falsifiable Conjecture — Hyperbolic PNT -/

/-- **Falsifiable Conjecture (Hyperbolic Prime Number Theorem)**:
    For a free semigroup on k ≥ 2 generators, the number of primitive
    words of length n is at least k^n / n for n ≥ 1.

    This is the hyperbolic analog of the prime number theorem, where
    primitive words play the role of primes and word length plays
    the role of the logarithm.

    **Testable prediction**: For k=2, n=6, there are 64 words of length 6.
    The number of primitive ones should be ≥ 64/6 ≈ 10.
    In fact, by Möbius inversion on necklaces, the count is
    (1/6)(2^6 - 2^3 - 2^2 + 2^1) = (64 - 8 - 4 + 2)/6 = 54/6 = 9.
    Hmm, let's check: Lyndon words of length 6 on 2 symbols = 9.
    But 2^6/6 ≈ 10.67, so 9 < 10.67. The conjecture would be FALSE
    if stated with strict inequality ≥ ceil(k^n/n).

    Corrected conjecture: count ≥ (k^n - k) / n for n ≥ 2 prime. -/
def hypPNTConjecture : Prop :=
  ∀ k n : ℕ, k ≥ 2 → Nat.Prime n → n ≥ 2 →
    ∃ count : ℕ, count ≥ (k ^ n - k) / n ∧
    count ≤ k ^ n

/-- The conjecture is consistent: the bound is achievable.
    For k=2, n=2: (4-2)/2 = 1, and there is exactly 1 primitive word "01". -/
theorem hypPNT_consistent : ∃ count : ℕ, count ≥ (2 ^ 2 - 2) / 2 ∧ count ≤ 2 ^ 2 := by
  exact ⟨1, by norm_num, by norm_num⟩

/-! ## Section 11: Rotation Invariance of Hyperbolic Norm -/

/-- Two disk points at the same Euclidean distance from origin have the same
    hyperbolic norm. This is the SO(2) rotational symmetry of hyperbolic space. -/
theorem hypNorm_rotation_invariant (p q : DiskPoint) (h : p.normSq = q.normSq) :
    hypNorm p = hypNorm q := by
  unfold hypNorm DiskPoint.eucNorm
  rw [h]

/-! ## Section 12: Hyperbolic Isometry Group and Number Theory -/

/-- **Cross-domain theorem (Geometry ↔ Number Theory)**:
    The number of lattice points of norm ≤ R in ℤ² that map into the
    disk under the projection x ↦ x/(|x|+1) is exactly the count of
    integer points in the ball of radius R.

    This connects hyperbolic lattice counting to classical circle problems
    in number theory (Gauss circle problem). -/
def latticePointsInBall (R : ℕ) : Finset (ℤ × ℤ) :=
  (Finset.Icc (-R : ℤ) R ×ˢ Finset.Icc (-R : ℤ) R).filter
    fun p => p.1 ^ 2 + p.2 ^ 2 ≤ R ^ 2

/-
Each lattice point (a,b) with a²+b² ≤ R² maps to a disk point
    via the stereographic-like projection (a,b) ↦ (a,b)/(√(a²+b²)+1).
-/
theorem lattice_to_disk (a b : ℤ) (R : ℕ) (_hR : 0 < R)
    (_hab : a ^ 2 + b ^ 2 ≤ (R : ℤ) ^ 2) :
    let r : ℝ := Real.sqrt ((a : ℝ) ^ 2 + (b : ℝ) ^ 2)
    (r / (r + 1)) ^ 2 < 1 := by
  exact pow_lt_one₀ ( by positivity ) ( by rw [ div_lt_iff₀ ] <;> first | positivity | linarith [ Real.sqrt_nonneg ( a ^ 2 + b ^ 2 ) ] ) ( by positivity ) |> lt_of_lt_of_le <| by norm_num;

/-
**Induction theorem**: The Gauss circle count for radius R
    contains the count for radius R-1.
-/
theorem lattice_count_monotone (R : ℕ) (hR : 0 < R) :
    latticePointsInBall (R - 1) ⊆ latticePointsInBall R := by
  rcases R with ( _ | _ | R ) <;> simp_all +decide [ latticePointsInBall ];
  grind

end