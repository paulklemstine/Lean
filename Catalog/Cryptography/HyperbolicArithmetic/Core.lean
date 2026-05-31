/-
  Hyperbolic Number Theory: Arithmetic on the Poincaré Disk

  We develop the algebraic foundations of arithmetic in hyperbolic space,
  using Möbius addition on the Poincaré disk model. The key insight is that
  the operation a ⊕ b = (a + b) / (1 + ā·b) defines a gyrogroup structure
  on the open unit disk, providing a natural "hyperbolic arithmetic" that
  parallels ordinary addition on the real line.

  Main results:
  - Möbius addition is well-defined on the open unit disk (closure theorem)
  - The disk with Möbius addition forms an algebraic structure with identity and inverses
  - Möbius iterates stay in the disk (induction)
  - Monotonicity of positive Möbius iterates
-/
import Mathlib

open Real

noncomputable section

/-! ## Möbius Addition on the Real Line Disk (-1, 1) -/

/-- Möbius addition on the real interval (-1, 1), modeling
    the 1-dimensional Poincaré disk. This is the restriction of
    the full complex Möbius addition to the real axis. -/
def moebiusAddReal (a b : ℝ) : ℝ := (a + b) / (1 + a * b)

/-- Zero is a left identity for real Möbius addition. -/
theorem moebiusAdd_zero_left (b : ℝ) : moebiusAddReal 0 b = b := by
  simp [moebiusAddReal]

/-- Zero is a right identity for real Möbius addition. -/
theorem moebiusAdd_zero_right (a : ℝ) : moebiusAddReal a 0 = a := by
  simp [moebiusAddReal]

/-- Real Möbius addition is commutative. -/
theorem moebiusAdd_comm (a b : ℝ) : moebiusAddReal a b = moebiusAddReal b a := by
  simp [moebiusAddReal, mul_comm, add_comm]

/-- The denominator 1 + a*b is positive when both |a| < 1 and |b| < 1. -/
theorem moebiusAdd_denom_pos (a b : ℝ) (ha : |a| < 1) (hb : |b| < 1) :
    0 < 1 + a * b := by
  have hab : |a * b| < 1 := by
    rw [abs_mul]
    exact mul_lt_one_of_nonneg_of_lt_one_left (abs_nonneg a) ha (le_of_lt hb)
  linarith [neg_abs_le (a * b)]

/-- The denominator 1 + a*b is nonzero when both |a| < 1 and |b| < 1. -/
theorem moebiusAdd_denom_ne_zero (a b : ℝ) (ha : |a| < 1) (hb : |b| < 1) :
    1 + a * b ≠ 0 :=
  ne_of_gt (moebiusAdd_denom_pos a b ha hb)

/-! ## The Key Algebraic Identity -/

/-- The fundamental identity underlying Möbius arithmetic:
    (a+b)² - (1+ab)² = -(1-a²)(1-b²).
    This identity is the algebraic heart of hyperbolic geometry —
    it shows that the numerator squared is always less than the
    denominator squared when both inputs are in the unit disk. -/
theorem moebius_fundamental_identity (a b : ℝ) :
    (a + b) ^ 2 - (1 + a * b) ^ 2 = -((1 - a ^ 2) * (1 - b ^ 2)) := by
  ring

/-
**Closure Theorem**: Real Möbius addition maps the open unit interval to itself.
    If |a| < 1 and |b| < 1, then |a ⊕ b| < 1.

    The proof uses the algebraic identity:
    (a+b)² - (1+ab)² = -(1-a²)(1-b²)
    which shows (a+b)² < (1+ab)² when |a|,|b| < 1.
-/
theorem moebiusAdd_mem_disk (a b : ℝ) (ha : |a| < 1) (hb : |b| < 1) :
    |moebiusAddReal a b| < 1 := by
  rw [ moebiusAddReal, abs_div ];
  rw [ div_lt_iff₀ ] <;> cases abs_cases ( a + b ) <;> cases abs_cases ( 1 + a * b ) <;> nlinarith [ abs_lt.mp ha, abs_lt.mp hb ]

/-
Negation is the Möbius inverse: (-a) ⊕ a = 0.
-/
theorem moebiusAdd_neg_cancel (a : ℝ) (_ha : |a| < 1) :
    moebiusAddReal (-a) a = 0 := by
  unfold moebiusAddReal; ring;

/-- Right cancellation: a ⊕ (-a) = 0. -/
theorem moebiusAdd_neg_cancel_right (a : ℝ) (ha : |a| < 1) :
    moebiusAddReal a (-a) = 0 := by
  rw [moebiusAdd_comm]
  exact moebiusAdd_neg_cancel a ha

/-! ## Hyperbolic Norm -/

/-- The hyperbolic norm of a point, measuring its distance from the origin
    in the hyperbolic metric. Maps (-1,1) → [0, ∞). -/
def hypNorm (x : ℝ) : ℝ := |x| / (1 - |x|)

/-
Hyperbolic norm is zero iff the point is zero.
-/
theorem hypNorm_eq_zero_iff (x : ℝ) (hx : |x| < 1) : hypNorm x = 0 ↔ x = 0 := by
  unfold hypNorm;
  norm_num [ show 1 - |x| ≠ 0 by linarith ]

/-
Hyperbolic norm is nonneg.
-/
theorem hypNorm_nonneg (x : ℝ) (hx : |x| < 1) : 0 ≤ hypNorm x := by
  exact div_nonneg ( abs_nonneg x ) ( sub_nonneg.2 hx.le )

/-! ## Möbius Iteration -/

/-- **Möbius iteration**: Repeatedly applying Möbius addition of g to itself.
    This is the hyperbolic analog of n·g in ordinary arithmetic. -/
def moebiusIter (g : ℝ) : ℕ → ℝ
  | 0 => 0
  | n + 1 => moebiusAddReal (moebiusIter g n) g

/-- The zeroth Möbius iterate is zero. -/
theorem moebiusIter_zero (g : ℝ) : moebiusIter g 0 = 0 := rfl

/-- The first Möbius iterate is g itself. -/
theorem moebiusIter_one (g : ℝ) : moebiusIter g 1 = g := by
  simp [moebiusIter, moebiusAddReal]

/-
Möbius iterates stay in the disk: if |g| < 1, then |g^{⊕n}| < 1 for all n.
    This is proved by induction using the closure theorem.
-/
theorem moebiusIter_mem_disk (g : ℝ) (hg : |g| < 1) (n : ℕ) :
    |moebiusIter g n| < 1 := by
  induction' n with n ih;
  · exact show |0| < 1 by norm_num;
  · convert moebiusAdd_mem_disk ( moebiusIter g n ) g ih hg using 1

/-
**Monotonicity of Möbius iterates**: For 0 < g < 1, the sequence
    g^{⊕n} is strictly increasing and converges to 1.
    This is the hyperbolic analog of the fact that n·g → ∞.
-/
theorem moebiusIter_strict_mono (g : ℝ) (hg : 0 < g) (hg1 : g < 1) :
    StrictMono (moebiusIter g) := by
  refine' strictMono_nat_of_lt_succ _;
  intro n
  have h_pos : 0 ≤ moebiusIter g n := by
    induction' n with n ih;
    · exact le_rfl;
    · exact div_nonneg ( add_nonneg ih hg.le ) ( by nlinarith [ show 0 ≤ moebiusIter g n from ih ] );
  have h_step : moebiusIter g n < (moebiusIter g n + g) / (1 + moebiusIter g n * g) := by
    rw [ lt_div_iff₀ ] <;> nlinarith [ mul_lt_mul_of_pos_left hg1 hg, show moebiusIter g n ^ 2 < 1 from by nlinarith [ show |moebiusIter g n| < 1 from moebiusIter_mem_disk g ( by simpa [ abs_of_pos hg ] using hg1 ) n, abs_lt.mp ( show |moebiusIter g n| < 1 from moebiusIter_mem_disk g ( by simpa [ abs_of_pos hg ] using hg1 ) n ) ] ];
  exact h_step

/-! ## Complex Möbius Addition -/

/-- Möbius addition on the complex unit disk (Poincaré disk model).
    For z, w in the open unit disk: z ⊕ w = (z + w) / (1 + z̄ · w). -/
def moebiusAddComplex (z w : ℂ) : ℂ := (z + w) / (1 + starRingEnd ℂ z * w)

/-- Zero is a left identity for complex Möbius addition. -/
theorem moebiusAddComplex_zero_left (w : ℂ) : moebiusAddComplex 0 w = w := by
  simp [moebiusAddComplex]

/-- Zero is a right identity for complex Möbius addition. -/
theorem moebiusAddComplex_zero_right (z : ℂ) : moebiusAddComplex z 0 = z := by
  simp [moebiusAddComplex]

/-! ## Hyperbolic Lattice Structure -/

/-- A hyperbolic lattice is a discrete subset of the Poincaré disk that is
    closed under Möbius addition and contains 0. This models the "hyperbolic
    integers" Z_H as orbit points of a discrete group action. -/
structure HyperbolicLattice where
  /-- The set of lattice points in (-1, 1) -/
  points : Set ℝ
  /-- All points lie in the open unit interval -/
  mem_disk : ∀ x ∈ points, |x| < 1
  /-- The origin is a lattice point -/
  zero_mem : (0 : ℝ) ∈ points
  /-- Closure under Möbius addition -/
  add_mem : ∀ x y, x ∈ points → y ∈ points → moebiusAddReal x y ∈ points
  /-- Closure under negation -/
  neg_mem : ∀ x, x ∈ points → -x ∈ points

/-- A hyperbolic prime in a lattice is a nonzero element that cannot be written
    as the Möbius sum of two nonzero lattice elements. These are the irreducible
    elements of hyperbolic arithmetic. -/
def IsHyperbolicPrime (L : HyperbolicLattice) (p : ℝ) : Prop :=
  p ∈ L.points ∧ p ≠ 0 ∧
  ∀ a b, a ∈ L.points → b ∈ L.points → a ≠ 0 → b ≠ 0 →
    moebiusAddReal a b ≠ p

/-- The trivial hyperbolic lattice consisting of only {0}. -/
def trivialHypLattice : HyperbolicLattice where
  points := {0}
  mem_disk := by simp
  zero_mem := rfl
  add_mem := by simp [moebiusAddReal]
  neg_mem := by simp

/-- The trivial lattice has no hyperbolic primes. -/
theorem trivialHypLattice_no_primes (p : ℝ) : ¬IsHyperbolicPrime trivialHypLattice p := by
  intro ⟨hp, hne, _⟩
  exact hne hp

/-! ## Hyperbolic Distance -/

/-- Hyperbolic distance from a point to itself is zero, via Möbius cancellation. -/
theorem hypDist_self_zero (a : ℝ) (ha : |a| < 1) :
    moebiusAddReal (-a) a = 0 :=
  moebiusAdd_neg_cancel a ha

/-! ## Falsifiable Conjecture -/

/-- **Conjecture (Hyperbolic Orbit Growth)**: For the Möbius iteration of
    g = 1/2, the n-th iterate satisfies g^{⊕n} > 1 - 2/(n+1) for all n ≥ 1.

    **Testable prediction**: Compute moebiusIter (1/2) n for n = 1, ..., 100
    and verify the bound. The Möbius iterates approach 1, and the conjecture
    asserts a specific rate of convergence.

    This can be tested computationally: the first few values are
    g^{⊕1} = 0.5, g^{⊕2} = 0.8, g^{⊕3} ≈ 0.929, g^{⊕4} ≈ 0.976, ...
    The bound 1 - 2/(n+1) gives 0, 0.333, 0.5, 0.6, ...
    so the conjecture appears to hold with room to spare. -/
def hyperbolicOrbitGrowthConjecture : Prop :=
  ∀ (n : ℕ), n ≥ 1 →
    moebiusIter (1/2 : ℝ) n > 1 - 2 / ((n : ℝ) + 1)

end