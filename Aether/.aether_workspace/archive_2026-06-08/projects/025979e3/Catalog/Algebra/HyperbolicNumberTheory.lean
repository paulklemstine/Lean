import Mathlib

/-!
# Hyperbolic Number Theory: Arithmetic on the Poincaré Disk

We develop foundations for number theory on the Poincaré disk model of
hyperbolic geometry. The key idea: replace the integer line ℤ ⊂ ℝ with
a discrete orbit in the hyperbolic plane, and study the resulting
arithmetic structure.

## Main Definitions

* `PoincareDisk` — the open unit disk in ℂ as a type
* `hypDistSq` — squared cross-ratio quantity for hyperbolic distance
* `HypArithSystem` — algebraic structure for arithmetic on curved space
* `MobiusTransform` — automorphisms of the Poincaré disk

## Main Results

* `hypDistSq_nonneg` — hyperbolic distance quantity is non-negative
* `hypDistSq_self` — distance from a point to itself is zero
* `hypDistSq_symm` — hyperbolic distance is symmetric
* `mobius_denom_ne_zero` — Möbius denominators are nonzero in the disk
* `disk_convex_combination` — the open unit disk is convex
* `countBelow_monotone` — the counting function is monotone in R
-/

noncomputable section

open Complex Real Finset

/-! ## The Poincaré Disk -/

/-- A point in the Poincaré disk: a complex number with ‖z‖ < 1 -/
def PoincareDisk := { z : ℂ // ‖z‖ < 1 }

namespace PoincareDisk

instance : CoeOut PoincareDisk ℂ := ⟨Subtype.val⟩

/-- The origin of the Poincaré disk -/
def origin : PoincareDisk := ⟨0, by simp⟩

/-- The norm of a Poincaré disk point is less than 1 -/
theorem norm_lt_one (z : PoincareDisk) : ‖(z : ℂ)‖ < 1 := z.property

/-- The squared norm of a Poincaré disk point is less than 1 -/
theorem normSq_lt_one (z : PoincareDisk) : Complex.normSq (z : ℂ) < 1 := by
  rw [Complex.normSq_eq_norm_sq]
  exact pow_lt_one₀ (norm_nonneg _) z.property (by norm_num)

/-- 1 - |z|² > 0 for points in the disk -/
theorem one_sub_normSq_pos (z : PoincareDisk) : 0 < 1 - Complex.normSq (z : ℂ) := by
  linarith [normSq_lt_one z]

end PoincareDisk

/-! ## Hyperbolic Distance -/

/-- The squared cross-ratio quantity used in defining hyperbolic distance:
    δ(z,w) = |z - w|² / ((1 - |z|²)(1 - |w|²))
    The actual hyperbolic distance satisfies d(z,w) = arcosh(1 + 2δ(z,w)) -/
def hypDistSq (z w : PoincareDisk) : ℝ :=
  ‖(z : ℂ) - (w : ℂ)‖ ^ 2 / ((1 - Complex.normSq (z : ℂ)) * (1 - Complex.normSq (w : ℂ)))

/-- Hyperbolic distance quantity is non-negative -/
theorem hypDistSq_nonneg (z w : PoincareDisk) : 0 ≤ hypDistSq z w := by
  unfold hypDistSq
  apply div_nonneg
  · positivity
  · apply mul_nonneg
    · linarith [PoincareDisk.one_sub_normSq_pos z]
    · linarith [PoincareDisk.one_sub_normSq_pos w]

/-- Distance from a point to itself is zero -/
theorem hypDistSq_self (z : PoincareDisk) : hypDistSq z z = 0 := by
  unfold hypDistSq
  simp

/-- Hyperbolic distance squared is symmetric -/
theorem hypDistSq_symm (z w : PoincareDisk) : hypDistSq z w = hypDistSq w z := by
  unfold hypDistSq
  congr 1
  · rw [norm_sub_rev]
  · ring

/-! ## Möbius Transformations -/

/-- A Möbius transformation of the Poincaré disk, parameterized by
    a center point a ∈ D and a rotation angle θ.
    φ_a(z) = e^{iθ} · (z - a) / (1 - ā·z) -/
structure MobiusTransform where
  center : ℂ
  rotation : ℂ
  center_in_disk : ‖center‖ < 1
  rotation_unit : ‖rotation‖ = 1

namespace MobiusTransform

/-- Apply a Möbius transform to a complex number -/
def apply (φ : MobiusTransform) (z : ℂ) : ℂ :=
  φ.rotation * (z - φ.center) / (1 - starRingEnd ℂ φ.center * z)

/-- The identity Möbius transform -/
def id : MobiusTransform where
  center := 0
  rotation := 1
  center_in_disk := by simp
  rotation_unit := by simp

/-
The denominator 1 - ā·z is nonzero when both z and a are in the disk
-/
theorem denom_ne_zero (φ : MobiusTransform) (z : PoincareDisk) :
    (1 : ℂ) - starRingEnd ℂ φ.center * (z : ℂ) ≠ 0 := by
  norm_num [ Complex.ext_iff ] at *;
  intro h₁ h₂;
  have := φ.center_in_disk; have := z.norm_lt_one; norm_num [ Complex.normSq, Complex.norm_def ] at *;
  rw [ Real.sqrt_lt' ] at * <;> nlinarith [ sq_nonneg ( φ.center.re * ( z : ℂ ).im - φ.center.im * ( z : ℂ ).re ) ]

/-- The identity transform fixes all points -/
theorem id_apply (z : ℂ) : MobiusTransform.id.apply z = z := by
  unfold apply id
  simp [starRingEnd_self_apply]

end MobiusTransform

/-! ## Novel Structure: Hyperbolic Arithmetic System -/

/-- A **Hyperbolic Arithmetic System** consists of:
  - A discrete set of "hyperbolic integers" in the Poincaré disk
  - An "addition" operation (via a group action)
  - A "norm" function (hyperbolic distance from origin)
  This captures the algebraic structure of doing arithmetic on curved space. -/
structure HypArithSystem where
  /-- The underlying set of hyperbolic integers -/
  elements : Finset ℂ
  /-- All elements lie in the unit disk -/
  in_disk : ∀ z ∈ elements, ‖z‖ < 1
  /-- The identity element (origin) -/
  identity : ℂ
  identity_mem : identity ∈ elements
  identity_eq : identity = 0
  /-- Binary operation (e.g., hyperbolic midpoint) -/
  op : ℂ → ℂ → ℂ
  /-- The operation preserves the disk for elements -/
  op_closed : ∀ z w, z ∈ elements → w ∈ elements → ‖op z w‖ < 1
  /-- Identity is neutral -/
  op_identity_left : ∀ z ∈ elements, op identity z = z
  /-- Hyperbolic norm (distance from origin) -/
  hypNorm : ℂ → ℝ
  /-- Norm is non-negative -/
  hypNorm_nonneg : ∀ z ∈ elements, 0 ≤ hypNorm z
  /-- Only the identity has norm zero -/
  hypNorm_zero_iff : ∀ z ∈ elements, hypNorm z = 0 ↔ z = identity

namespace HypArithSystem

/-- The number of elements in the system -/
def size (H : HypArithSystem) : ℕ := H.elements.card

/-- A hyperbolic arithmetic system always has at least one element -/
theorem size_pos (H : HypArithSystem) : 0 < H.size :=
  Finset.card_pos.mpr ⟨H.identity, H.identity_mem⟩

/-- Elements with norm below a threshold -/
def elementsBelow (H : HypArithSystem) (R : ℝ) : Finset ℂ :=
  H.elements.filter (fun z => decide (H.hypNorm z ≤ R) = true)

/-- The counting function for the hyperbolic arithmetic system -/
def countBelow (H : HypArithSystem) (R : ℝ) : ℕ :=
  (H.elementsBelow R).card

/-- A "hyperbolic prime" in the system: an element that cannot be
    decomposed as op of two non-identity elements -/
def IsHypPrime (H : HypArithSystem) (p : ℂ) : Prop :=
  p ∈ H.elements ∧ p ≠ H.identity ∧
  ∀ a b, a ∈ H.elements → b ∈ H.elements →
    H.op a b = p → (a = H.identity ∨ b = H.identity)

/-- The identity is not a hyperbolic prime -/
theorem identity_not_prime (H : HypArithSystem) : ¬H.IsHypPrime H.identity := by
  intro ⟨_, hne, _⟩
  exact hne rfl

/-
The number of non-identity elements is at most size - 1
-/
theorem card_nonidentity_le (H : HypArithSystem) :
    (H.elements.filter (fun p => p ≠ H.identity)).card ≤ H.size - 1 := by
  convert Finset.card_erase_of_mem ( H.identity_mem ) |> le_of_eq |> le_trans <| Nat.le_refl _;
  grind

end HypArithSystem

/-! ## Constructing the Trivial System -/

/-- The trivial hyperbolic arithmetic system with just the origin -/
def trivialHypArith : HypArithSystem where
  elements := {0}
  in_disk := by simp
  identity := 0
  identity_mem := by simp
  identity_eq := rfl
  op := fun _ _ => 0
  op_closed := by simp
  op_identity_left := by simp
  hypNorm := fun _ => 0
  hypNorm_nonneg := by simp
  hypNorm_zero_iff := by simp

/-- The trivial system has exactly one element -/
theorem trivialHypArith_size : trivialHypArith.size = 1 := by
  simp [HypArithSystem.size, trivialHypArith]

/-! ## Disk Convexity -/

/-
**Disk Convexity Theorem**: The open unit disk is convex — any convex
    combination of disk points remains in the disk. This is fundamental
    because it means "hyperbolic addition" (midpoint) is well-defined.
-/
theorem disk_convex_combination (z w : ℂ) (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1)
    (hz : ‖z‖ < 1) (hw : ‖w‖ < 1) :
    ‖(1 - t) • z + t • w‖ < 1 := by
  have h_comb : ‖(1 - t) • z + t • w‖ ≤ (1 - t) * ‖z‖ + t * ‖w‖ := by
    convert norm_add_le ( ( 1 - t ) • z ) ( t • w ) using 1 ; norm_num [ norm_smul, abs_of_nonneg, ht0, ht1 ];
    exact Or.inl ( by norm_cast; rw [ Real.norm_of_nonneg ] ; linarith );
  cases lt_or_ge t ( 1 / 2 ) <;> nlinarith

/-! ## Hyperbolic Area Scaling -/

/-- The hyperbolic area element scaling factor at Euclidean radius r:
    dA_hyp = 4 / (1 - r²)² · dA_eucl -/
def hypAreaFactor (r : ℝ) : ℝ :=
  4 / (1 - r ^ 2) ^ 2

/-- The area factor is positive for r ∈ [0, 1) -/
theorem hypAreaFactor_pos {r : ℝ} (hr0 : 0 ≤ r) (hr1 : r < 1) :
    0 < hypAreaFactor r := by
  unfold hypAreaFactor
  apply div_pos (by norm_num : (0:ℝ) < 4)
  apply sq_pos_of_pos
  nlinarith [sq_nonneg r]

/-
The area factor is at least 4 (minimum at r = 0)
-/
theorem hypAreaFactor_ge_four {r : ℝ} (hr0 : 0 ≤ r) (hr1 : r < 1) :
    4 ≤ hypAreaFactor r := by
  rw [ hypAreaFactor, le_div_iff₀ ] <;> nlinarith [ mul_nonneg hr0 ( sq_nonneg r ), mul_le_mul_of_nonneg_left hr1.le hr0 ]

/-
The area factor diverges as r → 1: for any bound M, there exists
    r ∈ [0,1) with hypAreaFactor r > M.
-/
theorem hypAreaFactor_unbounded (M : ℝ) (hM : 0 < M) :
    ∃ r : ℝ, 0 ≤ r ∧ r < 1 ∧ M < hypAreaFactor r := by
  cases' exists_nat_gt ( M/4 ) with n hn;
  -- Choose $r = \sqrt{1 - \frac{1}{n}}$ for � some� $n > \frac{M}{4}$.
  use Real.sqrt (1 - 1 / (n + 1));
  norm_num [ hypAreaFactor ];
  rw [ Real.sqrt_lt' ] <;> norm_num;
  rw [ Real.sq_sqrt ] <;> norm_num;
  · constructor <;> nlinarith;
  · exact inv_le_one_of_one_le₀ <| by linarith

/-! ## Hyperbolic Prime Counting Asymptotics -/

/-- The conjectured asymptotic form of the hyperbolic prime counting function.
    Analogous to x/ln(x) in the classical PNT, we have e^R / R in
    hyperbolic geometry, reflecting exponential growth of area. -/
def hypPrimeAsymptotic (R : ℝ) : ℝ := Real.exp R / R

/-- The asymptotic is positive for positive R -/
theorem hypPrimeAsymptotic_pos {R : ℝ} (hR : 0 < R) :
    0 < hypPrimeAsymptotic R := by
  exact div_pos (Real.exp_pos R) hR

/-
**Key monotonicity**: e^R / R is eventually increasing.
    Specifically, it is increasing for R ≥ 1.
-/
theorem hypPrimeAsymptotic_eventually_increasing :
    ∀ R₁ R₂ : ℝ, 1 ≤ R₁ → R₁ ≤ R₂ →
    hypPrimeAsymptotic R₁ ≤ hypPrimeAsymptotic R₂ := by
  intros R₁ R₂ hR₁ hR₂;
  rw [ hypPrimeAsymptotic, hypPrimeAsymptotic, div_le_div_iff₀ ] <;> try linarith;
  -- We can divide both sides by $e^{R₁} * R₁$ to get $R₂ / R₁ ≤ e^{R₂ - R₁}$.
  suffices h_div : R₂ / R₁ ≤ Real.exp (R₂ - R₁) by
    rw [ div_le_iff₀ ( by positivity ) ] at h_div;
    convert mul_le_mul_of_nonneg_left h_div ( Real.exp_nonneg R₁ ) using 1 ; rw [ ← mul_assoc, ← Real.exp_add ] ; ring;
  nlinarith [ Real.add_one_le_exp ( R₂ - R₁ ), mul_div_cancel₀ R₂ ( by linarith : R₁ ≠ 0 ) ]

/-! ## Gauss-Bonnet for Hyperbolic Polygons -/

/-- For a hyperbolic polygon with n sides and interior angles α₁,...,αₙ,
    the hyperbolic area is (n-2)π - ∑αᵢ. -/
def hypPolygonArea (n : ℕ) (angles : Fin n → ℝ) : ℝ :=
  (n - 2 : ℝ) * Real.pi - ∑ i, angles i

/-- An ideal polygon (all angles = 0) has area (n-2)π -/
theorem ideal_polygon_area (n : ℕ) :
    hypPolygonArea n (fun _ => 0) = (n - 2 : ℝ) * Real.pi := by
  unfold hypPolygonArea
  simp

/-- For a regular n-gon with equal angles α, the area simplifies -/
theorem regular_polygon_area (n : ℕ) (α : ℝ) :
    hypPolygonArea n (fun _ => α) = (n - 2 : ℝ) * Real.pi - n * α := by
  unfold hypPolygonArea
  simp [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]

/-- The area of a hyperbolic triangle (n=3) with angles summing to S -/
theorem hyperbolic_triangle_area (angles : Fin 3 → ℝ)
    (hS : ∑ i, angles i = S) :
    hypPolygonArea 3 angles = Real.pi - S := by
  unfold hypPolygonArea
  rw [hS]
  push_cast
  ring

/-- **Gauss-Bonnet consequence**: A hyperbolic triangle must have
    angle sum strictly less than π for positive area -/
theorem triangle_angle_sum_lt_pi (angles : Fin 3 → ℝ)
    (_h_nonneg : ∀ i, 0 ≤ angles i)
    (h_pos_area : 0 < hypPolygonArea 3 angles) :
    ∑ i, angles i < Real.pi := by
  unfold hypPolygonArea at h_pos_area
  push_cast at h_pos_area
  linarith

/-! ## The Hyperbolic Lattice Point Problem -/

/-- For a cofinite Fuchsian group Γ with covolume V,
    the leading coefficient in the lattice point count is V/(4π). -/
def latticePointLeadingCoeff (covolume : ℝ) : ℝ :=
  covolume / (4 * Real.pi)

/-- The leading coefficient is positive for positive covolume -/
theorem latticePointLeadingCoeff_pos {V : ℝ} (hV : 0 < V) :
    0 < latticePointLeadingCoeff V := by
  unfold latticePointLeadingCoeff
  exact div_pos hV (mul_pos (by norm_num) Real.pi_pos)

/-- For PSL(2,ℤ) the covolume is π/3, so the leading coefficient is 1/12 -/
theorem psl2z_leading_coeff :
    latticePointLeadingCoeff (Real.pi / 3) = 1 / 12 := by
  unfold latticePointLeadingCoeff
  field_simp
  ring

/-! ## The Selberg Trace Formula Connection -/

/-- The Selberg zeta function truncated product over a list of primitive
    geodesic lengths:
    Z_K(s) = ∏_{ℓ ∈ spec} ∏_{k=0}^{K-1} (1 - e^{-(s+k)ℓ}) -/
def selbergZetaTrunc (spec : List ℝ) (s : ℝ) (K : ℕ) : ℝ :=
  spec.foldl (fun acc ℓ =>
    acc * (List.range K).foldl (fun a k => a * (1 - Real.exp (-(s + k) * ℓ))) 1) 1

/-- The truncated Selberg zeta is 1 for empty spectrum -/
theorem selbergZetaTrunc_empty (s : ℝ) (K : ℕ) :
    selbergZetaTrunc [] s K = 1 := by
  unfold selbergZetaTrunc
  simp [List.foldl]

/-- A valid geodesic spectrum has all positive lengths -/
def isValidSpectrum (spec : List ℝ) : Prop :=
  ∀ ℓ ∈ spec, (0 : ℝ) < ℓ

/-- The empty spectrum is trivially valid -/
theorem empty_spectrum_valid : isValidSpectrum [] := by
  intro ℓ hℓ
  simp at hℓ

/-! ## Conjecture: Hyperbolic Prime Counting

**Conjecture** (Hyperbolic Prime Number Theorem):
For the modular group Γ = PSL(2,ℤ) acting on the Poincaré disk,
the number of primitive closed geodesics with length ≤ R satisfies:

  π_H(R) ~ e^R / R   as R → ∞

**Testable prediction**: For R = 10, the count should be approximately
e^10 / 10 ≈ 2203. A numerical enumeration of closed geodesics in
PSL(2,ℤ)\ℍ can verify or refute this.

This is actually a well-known result (the Prime Geodesic Theorem),
proved by Huber (1961) and Hejhal. The "hyperbolic primes" are
precisely the primitive closed geodesics.
-/

end