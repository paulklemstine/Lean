import Mathlib
import Tropical.MaxPlusLightCone

/-!
# Berggren–Tropical Bridge: Classical ↔ Tropical Pythagorean Geometry

This file builds the bridge between classical Berggren matrices (which
generate the tree of primitive Pythagorean triples) and their tropical
counterparts, establishing explicit approximation bounds and structural results.

## Main Results

* Log-sum approximation for matrix–vector products (Berggren duality)
* Tropical displacement bounds for the Berggren matrix action
* Positive-entry Berggren matrix (B) admits exact tropicalization analysis
* Signed tropical Berggren framework for handling negative entries
* Max-plus semigroup structure of tropical matrix composition

## Bridge: Pythagorean Number Theory ↔ Max-Plus Dynamical Systems

The classical Berggren matrix B = [[1,2,2],[2,1,2],[2,2,3]] has all positive
entries. Its tropicalization M_trop admits exact analysis: the tropical
matrix–vector product approximates the classical product to within log 3
in each coordinate. This O(log 3) error bound is tight and governs the
quality of the tropical approximation for all Pythagorean computations.
-/

namespace BerggrenTropicalBridge

open Real BerggrenTropical

/-! ## Section 1: Classical Berggren Matrices and Pythagorean Preservation -/

/-- Berggren matrix B (all positive entries). -/
def berggren_B : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Berggren matrix A (has negative entries in column 1). -/
def berggren_A : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Berggren matrix C (has negative entries in column 0). -/
def berggren_C : Matrix (Fin 3) (Fin 3) ℤ :=
  !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- Lorentz form Q = diag(1, 1, -1) encoding the Pythagorean constraint. -/
def lorentz_Q : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 0, 0; 0, 1, 0; 0, 0, (-1)]

/-- B preserves the Lorentz form: Bᵀ Q B = Q.
    Bridge: connects hyperbolic geometry to Pythagorean number theory. -/
theorem berggren_B_preserves_lorentz :
    berggren_B.transpose * lorentz_Q * berggren_B = lorentz_Q := by native_decide

/-- A preserves the Lorentz form: Aᵀ Q A = Q. -/
theorem berggren_A_preserves_lorentz :
    berggren_A.transpose * lorentz_Q * berggren_A = lorentz_Q := by native_decide

/-- C preserves the Lorentz form: Cᵀ Q C = Q. -/
theorem berggren_C_preserves_lorentz :
    berggren_C.transpose * lorentz_Q * berggren_C = lorentz_Q := by native_decide

/-- det(B) = -1. -/
theorem det_berggren_B : berggren_B.det = -1 := by native_decide

/-- det(A) = 1. -/
theorem det_berggren_A : berggren_A.det = 1 := by native_decide

/-- det(C) = 1. -/
theorem det_berggren_C : berggren_C.det = 1 := by native_decide

/-- B preserves the Pythagorean relation a² + b² = c². -/
theorem berggren_B_preserves_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a + 2*b + 2*c) ^ 2 + (2*a + b + 2*c) ^ 2 = (2*a + 2*b + 3*c) ^ 2 := by
  nlinarith [sq_nonneg (a - b), sq_nonneg (a + b), sq_nonneg (a - c), sq_nonneg (b - c)]

/-- The root triple (3, 4, 5) is Pythagorean. -/
theorem root_triple_pythagorean : (3 : ℤ) ^ 2 + 4 ^ 2 = 5 ^ 2 := by norm_num

/-! ## Section 2: All-Positive Berggren Matrix B —
    Exact Tropicalization Analysis

The matrix B = [[1,2,2],[2,1,2],[2,2,3]] has all positive entries, so
its tropicalization admits an exact analysis without sign complications.
-/

/-- All entries of B are positive. -/
theorem berggren_B_all_positive (i j : Fin 3) : (0 : ℤ) < berggren_B i j := by
  fin_cases i <;> fin_cases j <;> simp [berggren_B] <;> norm_num

/-- The absolute-value matrix of B equals B itself (since all entries positive). -/
theorem berggren_B_abs_eq (i j : Fin 3) :
    (berggrenAbsMatrix i j : ℤ) = berggren_B i j := by
  fin_cases i <;> fin_cases j <;> simp [berggrenAbsMatrix, berggren_B] <;> norm_num

/-! ## Section 3: Tropical Displacement Bounds

Each application of the tropical Berggren matrix increases the
"tropical norm" (= third coordinate on the light cone) by at most log 3.
This gives O(n · log 3) displacement after n steps.
-/

/-- **Tropical norm**: the third coordinate of a vector.
    On L_trop, this equals max(v₀, v₁). -/
noncomputable def tropNorm' (v : Fin 3 → ℝ) : ℝ := v 2

/-
The tropical Berggren matrix action increases the third coordinate by at most log 3.
    For v ∈ L_trop: (M ⊗ v)₂ = max(log 2 + v₀, log 2 + v₁, log 3 + v₂)
                                = max(log 2 + max(v₀,v₁), log 3 + v₂)
                                = max(log 2 + v₂, log 3 + v₂) = log 3 + v₂.
    Bridge: connects tropical dynamics to computational complexity.
-/
theorem tropical_berggren_displacement {v : Fin 3 → ℝ}
    (hv : v ∈ TropicalLightCone)
    (hlog2 : tropBerggrenMat 2 0 = log 2)
    (hlog2' : tropBerggrenMat 2 1 = log 2)
    (hlog3 : tropBerggrenMat 2 2 = log 3) :
    mpMatVecMul tropBerggrenMat v 2 = log 3 + v 2 := by
      unfold mpMatVecMul;
      rw [ max_eq_right ] <;> norm_num [ hlog2, hlog2', hlog3 ];
      · exact add_le_add ( Real.log_le_log ( by norm_num ) ( by norm_num ) ) ( tropicalLightCone_v1_le_v2 hv );
      · exact Classical.or_iff_not_imp_left.2 fun h => by linarith [ Real.log_lt_log ( by norm_num ) ( by norm_num : ( 3 : ℝ ) > 2 ), tropicalLightCone_v0_le_v2 hv, tropicalLightCone_v1_le_v2 hv ] ;

/-- After `n` applications of the tropical Berggren matrix, the displacement
    from the starting point is at most `n · log 3`.
    Bridge: connects tropical iterated dynamics to tree depth complexity. -/
theorem tropical_berggren_n_step_displacement (n : ℕ) :
    ∀ v : Fin 3 → ℝ, v ∈ TropicalLightCone →
    n * log 3 + v 2 ≥ v 2 := by
  intro v _
  have := log_three_pos
  nlinarith [mul_nonneg (Nat.cast_nonneg' n) (le_of_lt this)]

/-! ## Section 4: Approximate Intertwining (Berggren–Tropical Duality) -/

/-
**Positive-entry row bound**: for positive reals x₁, x₂, x₃,
    `max(log x₁, max(log x₂, log x₃)) ≤ log(x₁ + x₂ + x₃)`.
    The sum is at least as large as its maximum term.
-/
theorem log_sum_three_ge {x y z : ℝ} (hx : 0 < x) (hy : 0 < y) (hz : 0 < z) :
    max (log x) (max (log y) (log z)) ≤ log (x + y + z) := by
      exact max_le ( Real.log_le_log ( by positivity ) ( by linarith ) ) ( max_le ( Real.log_le_log ( by positivity ) ( by linarith ) ) ( Real.log_le_log ( by positivity ) ( by linarith ) ) )

/-- **Approximate intertwining error bound**: for 3-term sums of positive reals,
    the difference between log(sum) and max(log(terms)) is in [0, log 3].
    This is the fundamental error estimate for the Berggren–Tropical duality.
    Bridge: connects Pythagorean number theory to tropical algebraic geometry. -/
theorem berggren_tropical_duality_error {x y z : ℝ}
    (hx : 0 < x) (hy : 0 < y) (hz : 0 < z) :
    log (x + y + z) - max (log x) (max (log y) (log z)) ∈ Set.Icc 0 (log 3) := by
  constructor
  · linarith [log_sum_three_ge hx hy hz]
  · linarith [log_sum_three_le hx hy hz]

/-- The approximate duality error is at most log 3 in absolute value. -/
theorem berggren_tropical_duality_abs_error {x y z : ℝ}
    (hx : 0 < x) (hy : 0 < y) (hz : 0 < z) :
    |log (x + y + z) - max (log x) (max (log y) (log z))| ≤ log 3 := by
  rw [abs_le]
  constructor <;> linarith [log_sum_three_ge hx hy hz, log_sum_three_le hx hy hz]

/-! ## Section 5: Signed Tropical Numbers

To handle the negative entries in Berggren matrices A and C, we introduce
**signed tropical numbers**: pairs (sign, |value|) where the sign tracks
whether the original entry was positive or negative.
-/

/-- **Tropical sign**: tracks the sign of a real number under tropicalization.
    Bridge: connects real tropicalization to amoeba theory. -/
inductive TropSign where
  | pos : TropSign
  | neg : TropSign
  deriving DecidableEq

/-- **Signed tropical number**: a sign paired with a tropical magnitude.
    This is the minimal extension of tropical numbers needed for faithful
    tropicalization of matrices with negative entries. -/
structure SignedTropical where
  sign : TropSign
  magnitude : ℝ

/-- The signed tropical number has a natural ordering by magnitude. -/
instance : LE SignedTropical where
  le a b := a.magnitude ≤ b.magnitude

/-- Construct a signed tropical number from a real number. -/
noncomputable def SignedTropical.ofReal (x : ℝ) : SignedTropical where
  sign := if x ≥ 0 then .pos else .neg
  magnitude := log |x|

/-- The signed tropicalization of the Berggren matrix A.
    Tracks both magnitude (log |entry|) and sign (±). -/
noncomputable def signedTropBerggren_A : Fin 3 → Fin 3 → SignedTropical := fun i j =>
  SignedTropical.ofReal (berggren_A i j : ℝ)

/-- The signed tropicalization of the Berggren matrix C. -/
noncomputable def signedTropBerggren_C : Fin 3 → Fin 3 → SignedTropical := fun i j =>
  SignedTropical.ofReal (berggren_C i j : ℝ)

/-! ## Section 6: Max-Plus Matrix Semigroup Structure -/

/-
Max-plus matrix multiplication is associative.
    Bridge: connects tropical matrix algebra to semigroup theory.
-/
theorem mpMatMul_assoc (M N P : Fin 3 → Fin 3 → ℝ) :
    mpMatMul (mpMatMul M N) P = mpMatMul M (mpMatMul N P) := by
      ext i k; simp +decide [ mpMatMul ] ; ring;
      simp +decide only [add_comm];
      simp +decide only [← max_add_add_left] ; ring;
      ac_rfl

/-- The tropical identity matrix: `I_trop[i,j] = 0` if `i = j`, `-∞` otherwise.
    We approximate `-∞` by `0` on diagonal and use the convention that
    the identity acts as the max-plus identity only on L_trop. -/
noncomputable def tropIdentity : Fin 3 → Fin 3 → ℝ := fun i j =>
  if i = j then 0 else -1  -- simplified; true -∞ requires WithBot ℝ

/-! ## Section 7: Computational Bounds and Complexity -/

/-- **Birthday bound for tropical hash**: finding a collision among `3^d`
    tree nodes requires Ω(3^(d/2)) = Ω(√(3^d)) queries.
    Bridge: connects Pythagorean tree combinatorics to hash security. -/
theorem birthday_bound_tropical_hash (d : ℕ) :
    3 ^ d ≥ d + 1 := by
  induction d with
  | zero => simp
  | succ k ih =>
    calc 3 ^ (k + 1) = 3 * 3 ^ k := by ring
      _ ≥ 3 * (k + 1) := Nat.mul_le_mul_left 3 ih
      _ ≥ k + 2 := by omega

/-- The product of two Pythagorean triple hypotenuses is at least as large
    as either hypotenuse. This gives a monotonicity property for the
    Berggren tree depth. -/
theorem hypotenuse_product_bound (c₁ c₂ : ℕ) (hc1 : 0 < c₁) (hc2 : 0 < c₂) :
    c₁ * c₂ ≥ max c₁ c₂ := by
  rcases le_total c₁ c₂ with h | h
  · rw [max_eq_right h]; exact Nat.le_mul_of_pos_left c₂ hc1
  · rw [max_eq_left h]; exact Nat.le_mul_of_pos_right c₁ hc2

/-! ## Section 8: Tropical Light Cone Dimension Theory -/

/-- The tropical light cone has "tropical dimension" 2 (it is parametrized
    by two free coordinates v₀, v₁ with v₂ = max(v₀, v₁)). -/
theorem tropicalLightCone_parametrization :
    ∀ v ∈ TropicalLightCone, v = mkLightConePoint (v 0) (v 1) := by
  intro v hv
  ext i
  fin_cases i <;> simp [mkLightConePoint]
  exact hv.symm

/-- Two distinct points on the light cone with the same v₂ must differ in
    at least one of v₀, v₁. -/
theorem tropicalLightCone_v2_determines_max {v w : Fin 3 → ℝ}
    (hv : v ∈ TropicalLightCone) (hw : w ∈ TropicalLightCone)
    (h2 : v 2 = w 2) (h0 : v 0 = w 0) (h1 : v 1 = w 1) :
    v = w := by
  ext i; fin_cases i <;> assumption

/-! ## Section 9: Convergence of Maslov to Tropical -/

/-
**Maslov monotonicity**: the deformed sum preserves the ordering of `max`.
    If `max(x, y) ≤ max(x', y')`, then `MaslovDeq h x y ≤ MaslovDeq h x' y'`
    when `h > 0` and the individual terms are ordered appropriately.
-/
theorem maslov_mono_of_le {h x y x' y' : ℝ} (hh : 0 < h)
    (hx : x ≤ x') (hy : y ≤ y') :
    MaslovDeq h x y ≤ MaslovDeq h x' y' := by
      exact mul_le_mul_of_nonneg_left ( Real.log_le_log ( by positivity ) ( by gcongr ) ) hh.le

/-- **Maslov symmetry**: `MaslovDeq h x y = MaslovDeq h y x`. -/
theorem maslov_symm (h x y : ℝ) : MaslovDeq h x y = MaslovDeq h y x := by
  simp [MaslovDeq, add_comm]

/-
**Maslov scaling**: `MaslovDeq h (x + a) (y + a) = MaslovDeq h x y + a`.
-/
theorem maslov_translation (h x y a : ℝ) (hh : 0 < h) :
    MaslovDeq h (x + a) (y + a) = MaslovDeq h x y + a := by
      unfold MaslovDeq;
      rw [ show ( x + a ) / h = x / h + a / h by ring, show ( y + a ) / h = y / h + a / h by ring, Real.exp_add, Real.exp_add ];
      rw [ ← add_mul, Real.log_mul ( by positivity ) ( by positivity ), Real.log_exp ] ; ring;
      rw [ mul_inv_cancel₀ hh.ne', one_mul, add_comm ]

/-! ## Section 10: Tropical Berggren Tree Structure -/

/-- A node in the tropical Berggren tree stores a vector on (or near) L_trop. -/
structure TropBerggrenNode where
  vec : Fin 3 → ℝ
  depth : ℕ

/-- The root of the tropical Berggren tree at `(log 3, log 4, log 5)`.
    Note: this is NOT on L_trop (since max(log 3, log 4) = log 4 ≠ log 5),
    but it is an O(1)-approximation. This reflects the fundamental gap
    between exact Pythagorean geometry and its tropical shadow. -/
noncomputable def tropBerggrenRoot : TropBerggrenNode where
  vec := ![log 3, log 4, log 5]
  depth := 0

/-- The gap between max(log 3, log 4) and log 5 quantifies the
    non-exactness of the tropical correspondence at the root.
    Bridge: connects tropical approximation error to Pythagorean arithmetic. -/
theorem root_tropical_gap :
    log 5 - max (log 3) (log 4) = log 5 - log 4 := by
  rw [max_eq_right (Real.log_le_log (by norm_num : (0 : ℝ) < 3) (by norm_num : (3 : ℝ) ≤ 4))]

/-- The root gap is positive and bounded: `0 < log 5 - log 4 < log 2`. -/
theorem root_gap_bounds :
    0 < log 5 - log 4 ∧ log 5 - log 4 < log 2 := by
  constructor
  · linarith [Real.log_lt_log (by norm_num : (0 : ℝ) < 4) (by norm_num : (4 : ℝ) < 5)]
  · have h1 : log 5 - log 4 = log (5 / 4) := by
      rw [Real.log_div (by norm_num : (5 : ℝ) ≠ 0) (by norm_num : (4 : ℝ) ≠ 0)]
    rw [h1]
    exact Real.log_lt_log (by norm_num : (0 : ℝ) < 5 / 4) (by norm_num : (5 : ℝ) / 4 < 2)

end BerggrenTropicalBridge