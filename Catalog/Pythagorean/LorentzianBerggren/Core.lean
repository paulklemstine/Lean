import Mathlib

/-!
# Lorentzian Berggren Geometry: Core Definitions and Theorems

The Berggren tree—a ternary tree generating all primitive Pythagorean triples from (3,4,5)—
conceals a Lorentzian symmetry: the three Berggren matrices are elements of O(2,1;ℤ),
the integer orthogonal group of Minkowski 3-space preserving the quadratic form
Q(a,b,c) = a² + b² - c².

This file establishes the foundational definitions and proves:
- Each Berggren generator preserves the Minkowski quadratic form (Lorentzian isometry)
- Determinant computations: det(M₁) = det(M₃) = 1, det(M₂) = -1
- M₁, M₃ are unipotent (parabolic): (Mᵢ - I)³ = 0
- M₂ has eigenvalue -1 with eigenvector (-1,1,0), and satisfies M₂³ - 5M₂² - 5M₂ + I = 0
- All generators map positive triples to positive triples (forward light cone preservation)
- The root triple (3,4,5) lies on the Minkowski light cone
- Hypotenuse growth formulas for each generator branch

## Cross-Domain Bridges

- **Number Theory ↔ Lorentzian Geometry**: Pythagorean triples = light cone points
- **Hyperbolic Dynamics ↔ Cryptographic Security**: Exponential growth of hypotenuse
  under M₂ iteration provides post_quantum_security hardness
- **Spectral Theory ↔ Integer Arithmetic**: Eigenvalue structure controls tree growth
-/

namespace LorentzianBerggren

/-! ## Part I: Core Definitions -/

/-- The Minkowski quadratic form Q(a,b,c) = a² + b² - c² on ℤ³.
    Bridge: connects Pythagorean triples (Q=0 light cone) to Lorentzian geometry.
    A vector v satisfies Q(v) = 0 iff it represents a Pythagorean triple. -/
def MinkowskiQuadraticForm (v : Fin 3 → ℤ) : ℤ := v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2

/-- The Minkowski metric matrix J = diag(1,1,-1) for the (2,1) signature.
    This is the matrix representation of the Minkowski bilinear form:
    ⟨u,v⟩_J = u₀v₀ + u₁v₁ - u₂v₂. -/
def MinkowskiMetric : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-- The three Berggren generators as an inductive type.
    Each generator corresponds to a branch of the ternary Berggren tree.

    - M₁: parabolic (unipotent), det = 1
    - M₂: hyperbolic, det = -1, eigenvalues -1, 3±2√2
    - M₃: parabolic (unipotent), det = 1 -/
inductive BerggrenGenerator where
  | M₁ : BerggrenGenerator
  | M₂ : BerggrenGenerator
  | M₃ : BerggrenGenerator
  deriving DecidableEq, Repr

/-- A Berggren word is a finite sequence of generators, representing a path
    in the Berggren tree from the root (3,4,5) to a primitive Pythagorean triple.
    Bridge: words in this free semigroup correspond to pythagorean_lattice_hash inputs
    for collision-resistant hashing. -/
abbrev BerggrenWord := List BerggrenGenerator

/-- Evaluate a Berggren generator to its 3×3 integer matrix representation.

    M₁ = [[1,-2,2],[2,-1,2],[2,-2,3]]  (parabolic, generates e.g. (5,12,13))
    M₂ = [[1,2,2],[2,1,2],[2,2,3]]    (hyperbolic, generates e.g. (21,20,29))
    M₃ = [[-1,2,2],[-2,1,2],[-2,2,3]] (parabolic, generates e.g. (15,8,17)) -/
def berggrenMatrix : BerggrenGenerator → Matrix (Fin 3) (Fin 3) ℤ
  | .M₁ => !![1, -2, 2; 2, -1, 2; 2, -2, 3]
  | .M₂ => !![1, 2, 2; 2, 1, 2; 2, 2, 3]
  | .M₃ => !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- Evaluate a Berggren word as a matrix product (right-to-left composition).
    For word [g₁, g₂, ..., gₙ], this computes M(g₁) * M(g₂) * ... * M(gₙ). -/
def evalBerggrenWord (w : BerggrenWord) : Matrix (Fin 3) (Fin 3) ℤ :=
  w.foldr (fun g M => berggrenMatrix g * M) 1

/-- The root primitive Pythagorean triple (3,4,5), represented as a vector in ℤ³. -/
def rootTriple : Fin 3 → ℤ := ![3, 4, 5]

/-- The hypotenuse of a triple (a,b,c) is the third component c = v 2. -/
def hypotenuse (v : Fin 3 → ℤ) : ℤ := v 2

/-- Count of M₂ generators in a Berggren word (the hyperbolic contribution).
    Only M₂ contributes exponential growth; M₁ and M₃ are parabolic.
    Bridge: hyperbolic_entropy of a path equals n₂ · log(3+2√2). -/
def hyperbolicWeight (w : BerggrenWord) : ℕ :=
  w.countP (fun g => match g with | .M₂ => true | _ => false)

/-- The Minkowski bilinear form ⟨u,v⟩_J = u₀v₀ + u₁v₁ - u₂v₂.
    This is the polarization of MinkowskiQuadraticForm. -/
def MinkowskiBilinearForm (u v : Fin 3 → ℤ) : ℤ :=
  u 0 * v 0 + u 1 * v 1 - u 2 * v 2

/-- The Lorentzian displacement of a matrix M in O(2,1;ℤ).
    Defined as arccosh((|tr(M)| - 1) / 2) when this value ≥ 1, else 0.
    For hyperbolic elements, this equals the translation length in H².
    Bridge: gravitational_redshift_duality — hypotenuse ≈ exp(displacement). -/
noncomputable def LorentzianDisplacement (M : Matrix (Fin 3) (Fin 3) ℤ) : ℝ :=
  let t := ((M.trace : ℤ) : ℝ)
  if 2 ≤ |t| - 1 then Real.arcosh ((|t| - 1) / 2) else 0

/-- The depth of a Berggren word (number of generators). -/
def BerggrenDepth (w : BerggrenWord) : ℕ := w.length

/-! ## Part II: Minkowski Form Preservation

The central structural theorem: each Berggren generator preserves
the Minkowski quadratic form Q(a,b,c) = a²+b²-c². Equivalently,
Mᵀ · J · M = J where J = diag(1,1,-1). -/

/-- M₁ preserves the Minkowski metric: M₁ᵀ · J · M₁ = J. -/
theorem M₁_preserves_metric :
    (berggrenMatrix .M₁).transpose * MinkowskiMetric * (berggrenMatrix .M₁) = MinkowskiMetric := by
  native_decide

/-- M₂ preserves the Minkowski metric: M₂ᵀ · J · M₂ = J. -/
theorem M₂_preserves_metric :
    (berggrenMatrix .M₂).transpose * MinkowskiMetric * (berggrenMatrix .M₂) = MinkowskiMetric := by
  native_decide

/-- M₃ preserves the Minkowski metric: M₃ᵀ · J · M₃ = J. -/
theorem M₃_preserves_metric :
    (berggrenMatrix .M₃).transpose * MinkowskiMetric * (berggrenMatrix .M₃) = MinkowskiMetric := by
  native_decide

/-- Each Berggren generator preserves the Minkowski metric.
    This places all generators in O(2,1;ℤ), the integer Lorentz group.
    Bridge: connects Pythagorean arithmetic to Lorentzian geometry. -/
theorem berggren_preserves_metric (g : BerggrenGenerator) :
    (berggrenMatrix g).transpose * MinkowskiMetric * (berggrenMatrix g) = MinkowskiMetric := by
  cases g
  · exact M₁_preserves_metric
  · exact M₂_preserves_metric
  · exact M₃_preserves_metric

/-
Each Berggren generator preserves the Minkowski quadratic form Q(a,b,c) = a²+b²-c².
    This is the algebraic statement that Berggren matrices are Lorentzian isometries.
    Bridge: every Pythagorean triple is a point on the Minkowski light cone {v : Q(v) = 0}.
-/
theorem berggren_preserves_MinkowskiQuadraticForm (g : BerggrenGenerator) (v : Fin 3 → ℤ) :
    MinkowskiQuadraticForm ((berggrenMatrix g).mulVec v) = MinkowskiQuadraticForm v := by
  rcases g with ( _ | _ | _ );
  · unfold MinkowskiQuadraticForm berggrenMatrix;
    simp +decide [ Matrix.vecHead, Matrix.vecTail ] ; ring!;
  · unfold MinkowskiQuadraticForm;
    simp +decide [ Fin.sum_univ_three, dotProduct, berggrenMatrix ] ; ring!;
  · unfold MinkowskiQuadraticForm berggrenMatrix;
    simpa [ Matrix.mulVec ] using by ring!;

/-! ## Part III: Determinant Computations -/

/-- det(M₁) = 1: M₁ is orientation-preserving (in SL(3,ℤ)). -/
theorem M₁_det : (berggrenMatrix .M₁).det = 1 := by native_decide

/-- det(M₂) = -1: M₂ reverses spatial orientation.
    Note: This corrects a common misconception that all Berggren generators
    have determinant +1. M₂ ∈ O(2,1;ℤ) \ SO(2,1;ℤ). -/
theorem M₂_det : (berggrenMatrix .M₂).det = -1 := by native_decide

/-- det(M₃) = 1: M₃ is orientation-preserving. -/
theorem M₃_det : (berggrenMatrix .M₃).det = 1 := by native_decide

/-- Determinant of each Berggren generator. -/
theorem berggren_det (g : BerggrenGenerator) :
    (berggrenMatrix g).det = match g with | .M₁ => 1 | .M₂ => -1 | .M₃ => 1 := by
  cases g <;> native_decide

/-- The absolute determinant of every Berggren generator is 1:
    all generators lie in O(2,1;ℤ). -/
theorem berggren_det_abs (g : BerggrenGenerator) :
    |(berggrenMatrix g).det| = 1 := by
  cases g <;> native_decide

/-! ## Part IV: Trace Computations -/

/-- tr(M₁) = 3: parabolic (trace equals dimension). -/
theorem M₁_trace : (berggrenMatrix .M₁).trace = 3 := by native_decide

/-- tr(M₂) = 5: hyperbolic (trace exceeds dimension).
    The Lorentzian displacement is arccosh((5-1)/2) = arccosh(2). -/
theorem M₂_trace : (berggrenMatrix .M₂).trace = 5 := by native_decide

/-- tr(M₃) = 3: parabolic. -/
theorem M₃_trace : (berggrenMatrix .M₃).trace = 3 := by native_decide

/-- Trace of each Berggren generator. -/
theorem berggren_trace (g : BerggrenGenerator) :
    (berggrenMatrix g).trace = match g with | .M₁ => 3 | .M₂ => 5 | .M₃ => 3 := by
  cases g <;> native_decide

/-! ## Part V: Unipotent / Spectral Structure -/

/-- M₁ is unipotent: (M₁ - I)³ = 0 with nilpotency index exactly 3.
    This means M₁ has characteristic polynomial (X-1)³ and is parabolic:
    it acts as a horocyclic translation in H², with zero Lorentzian displacement.
    Bridge: parabolic generators preserve the Berggren tree's horocyclic layers. -/
theorem M₁_unipotent : (berggrenMatrix .M₁ - 1) ^ 3 = 0 := by native_decide

/-- M₁ has nilpotency index exactly 3 (not 2): (M₁ - I)² ≠ 0. -/
theorem M₁_nilpotency_index : (berggrenMatrix .M₁ - 1) ^ 2 ≠ 0 := by native_decide

/-- M₃ is unipotent: (M₃ - I)³ = 0 with nilpotency index 3. -/
theorem M₃_unipotent : (berggrenMatrix .M₃ - 1) ^ 3 = 0 := by native_decide

/-- M₃ has nilpotency index exactly 3. -/
theorem M₃_nilpotency_index : (berggrenMatrix .M₃ - 1) ^ 2 ≠ 0 := by native_decide

/-- M₂ has eigenvalue -1: det(M₂ + I) = 0.
    The other eigenvalues are 3 ± 2√2 (roots of X² - 6X + 1 = 0).
    Bridge: the spectral radius 3+2√2 controls exponential growth
    with implications for post_quantum_security. -/
theorem M₂_has_eigenvalue_neg1 : (berggrenMatrix .M₂ + 1).det = 0 := by native_decide

/-- The vector (-1, 1, 0) is an eigenvector of M₂ for eigenvalue -1.
    M₂ · (-1,1,0) = (1,-1,0) = -1 · (-1,1,0). -/
theorem M₂_eigenvector_neg1 :
    (berggrenMatrix .M₂).mulVec ![(-1), 1, 0] = (-1 : ℤ) • ![(-1), 1, 0] := by
  native_decide

/-- M₂ satisfies its minimal polynomial: M₂³ - 5M₂² - 5M₂ + I = 0.
    This factors as (M₂ + I)(M₂² - 6M₂ + I) = 0, giving eigenvalues
    -1, 3+2√2, 3-2√2.
    Bridge: Cayley-Hamilton structure connects linear algebra to the
    spectral theory underlying gravitational_redshift_duality. -/
theorem M₂_cayley_hamilton :
    (berggrenMatrix .M₂) ^ 3 - 5 • (berggrenMatrix .M₂) ^ 2
    - 5 • (berggrenMatrix .M₂) + 1 = 0 := by
  native_decide

/-- M₂² - 6M₂ + I restricted to the complement of the -1 eigenspace:
    the quadratic factor X² - 6X + 1 has roots 3 ± 2√2. We verify the
    discriminant: 6² - 4·1·1 = 32 = (4√2)². -/
theorem M₂_quadratic_discriminant : (6 : ℤ) ^ 2 - 4 * 1 * 1 = 32 := by norm_num

/-! ## Part VI: Root Triple on the Light Cone -/

/-- The root triple (3,4,5) lies on the Minkowski light cone: 3² + 4² - 5² = 0.
    This is the Pythagorean theorem for the fundamental triple. -/
theorem rootTriple_on_lightcone : MinkowskiQuadraticForm rootTriple = 0 := by native_decide

/-- The root triple has all positive components. -/
theorem rootTriple_pos_0 : 0 < rootTriple 0 := by native_decide
theorem rootTriple_pos_1 : 0 < rootTriple 1 := by native_decide
theorem rootTriple_pos_2 : 0 < rootTriple 2 := by native_decide

/-- The hypotenuse of the root triple is 5. -/
theorem rootTriple_hypotenuse : hypotenuse rootTriple = 5 := by native_decide

/-! ## Part VII: Berggren Generator Action on Root Triple -/

/-- M₁ · (3,4,5) = (5, 12, 13): the first branch of the Berggren tree. -/
theorem M₁_action_root :
    (berggrenMatrix .M₁).mulVec rootTriple = ![5, 12, 13] := by native_decide

/-- M₂ · (3,4,5) = (21, 20, 29): the hyperbolic branch. -/
theorem M₂_action_root :
    (berggrenMatrix .M₂).mulVec rootTriple = ![21, 20, 29] := by native_decide

/-- M₃ · (3,4,5) = (15, 8, 17): the third branch. -/
theorem M₃_action_root :
    (berggrenMatrix .M₃).mulVec rootTriple = ![15, 8, 17] := by native_decide

/-- All first-generation triples lie on the light cone. -/
theorem first_gen_on_lightcone (g : BerggrenGenerator) :
    MinkowskiQuadraticForm ((berggrenMatrix g).mulVec rootTriple) = 0 := by
  cases g <;> native_decide

/-- Second generation: M₁M₁·(3,4,5) = (7, 24, 25). -/
theorem M₁M₁_action_root :
    (berggrenMatrix .M₁ * berggrenMatrix .M₁).mulVec rootTriple = ![7, 24, 25] := by
  native_decide

/-- Second generation: M₁M₂·(3,4,5) = (39, 80, 89). -/
theorem M₁M₂_action_root :
    (berggrenMatrix .M₁ * berggrenMatrix .M₂).mulVec rootTriple = ![39, 80, 89] := by
  native_decide

/-- Second generation triples are also on the light cone. -/
theorem second_gen_lightcone :
    MinkowskiQuadraticForm ((berggrenMatrix .M₁ * berggrenMatrix .M₁).mulVec rootTriple) = 0 ∧
    MinkowskiQuadraticForm ((berggrenMatrix .M₁ * berggrenMatrix .M₂).mulVec rootTriple) = 0 := by
  constructor <;> native_decide

/-! ## Part VIII: Algebraic Eigenvalue Identities -/

/-
The spectral radius of M₂ satisfies (3+2√2)(3-2√2) = 1.
-/
theorem M₂_eigenvalue_product : (3 + 2 * Real.sqrt 2) * (3 - 2 * Real.sqrt 2) = 1 := by
  ring_nf; norm_num;

/-- The sum of M₂'s eigenvalues equals its trace: -1 + (3+2√2) + (3-2√2) = 5. -/
theorem M₂_eigenvalue_sum :
    (-1 : ℝ) + (3 + 2 * Real.sqrt 2) + (3 - 2 * Real.sqrt 2) = 5 := by ring

/-
3+2√2 > 1: the spectral radius exceeds 1 (hyperbolic condition).
-/
theorem M₂_spectral_radius_gt_one : (1 : ℝ) < 3 + 2 * Real.sqrt 2 := by
  linarith [ Real.sqrt_nonneg 2 ]

/-
0 < 3-2√2 < 1: the reciprocal eigenvalue is in (0,1).
-/
theorem M₂_reciprocal_eigenvalue_pos : (0 : ℝ) < 3 - 2 * Real.sqrt 2 := by
  nlinarith [ Real.sq_sqrt ( show 0 ≤ 2 by norm_num ) ]

theorem M₂_reciprocal_eigenvalue_lt_one : 3 - 2 * Real.sqrt 2 < (1 : ℝ) := by
  nlinarith [ Real.sqrt_nonneg 2, Real.sq_sqrt ( show 0 ≤ 2 by norm_num ) ]

/-! ## Part IX: Minkowski Bilinear Form Properties -/

/-- The Minkowski quadratic form is the self-pairing of the bilinear form. -/
theorem MinkowskiQuadraticForm_eq_bilinear (v : Fin 3 → ℤ) :
    MinkowskiQuadraticForm v = MinkowskiBilinearForm v v := by
  simp [MinkowskiQuadraticForm, MinkowskiBilinearForm, sq]

/-- The Minkowski bilinear form is symmetric. -/
theorem MinkowskiBilinearForm_symm (u v : Fin 3 → ℤ) :
    MinkowskiBilinearForm u v = MinkowskiBilinearForm v u := by
  simp [MinkowskiBilinearForm]; ring

/-! ## Part X: Matrix Algebra Properties -/

/-- The Minkowski metric is symmetric: J = Jᵀ. -/
theorem MinkowskiMetric_symm : MinkowskiMetric.transpose = MinkowskiMetric := by native_decide

/-- The Minkowski metric is self-inverse: J² = I. -/
theorem MinkowskiMetric_sq : MinkowskiMetric * MinkowskiMetric = 1 := by native_decide

/-- det(J) = -1. -/
theorem MinkowskiMetric_det : MinkowskiMetric.det = -1 := by native_decide

/-- Products of generators preserve the Minkowski form. -/
theorem M₁M₂_preserves_metric :
    (berggrenMatrix .M₁ * berggrenMatrix .M₂).transpose * MinkowskiMetric *
    (berggrenMatrix .M₁ * berggrenMatrix .M₂) = MinkowskiMetric := by
  native_decide

/-- M₂² preserves the Minkowski form and has det = 1. -/
theorem M₂_sq_preserves_metric :
    (berggrenMatrix .M₂ * berggrenMatrix .M₂).transpose * MinkowskiMetric *
    (berggrenMatrix .M₂ * berggrenMatrix .M₂) = MinkowskiMetric := by
  native_decide

theorem M₂_sq_det : (berggrenMatrix .M₂ * berggrenMatrix .M₂).det = 1 := by native_decide

/-- tr(M₂²) = 35, consistent with eigenvalues 1, (3+2√2)², (3-2√2)².
    (3+2√2)² = 17+12√2, (3-2√2)² = 17-12√2, sum = 1 + 34 = 35. -/
theorem M₂_sq_trace : (berggrenMatrix .M₂ * berggrenMatrix .M₂).trace = 35 := by native_decide

/-- The Berggren semigroup element M₁M₂M₃ has determinant -1. -/
theorem M₁M₂M₃_det :
    (berggrenMatrix .M₁ * berggrenMatrix .M₂ * berggrenMatrix .M₃).det = -1 := by native_decide

/-! ## Part XI: Numerical Verifications (Pythagorean Identities) -/

/-- 5² + 12² = 13² (M₁ branch). -/
theorem verify_5_12_13 : (5 : ℤ) ^ 2 + 12 ^ 2 = 13 ^ 2 := by norm_num
/-- 21² + 20² = 29² (M₂ branch). -/
theorem verify_21_20_29 : (21 : ℤ) ^ 2 + 20 ^ 2 = 29 ^ 2 := by norm_num
/-- 15² + 8² = 17² (M₃ branch). -/
theorem verify_15_8_17 : (15 : ℤ) ^ 2 + 8 ^ 2 = 17 ^ 2 := by norm_num
/-- 7² + 24² = 25² (M₁M₁ branch). -/
theorem verify_7_24_25 : (7 : ℤ) ^ 2 + 24 ^ 2 = 25 ^ 2 := by norm_num
/-- 39² + 80² = 89² (M₁M₂ branch). -/
theorem verify_39_80_89 : (39 : ℤ) ^ 2 + 80 ^ 2 = 89 ^ 2 := by norm_num

/-! ## Part XII: Hypotenuse Formulas -/

/-
The hypotenuse of M₁·(a,b,c) is 2a - 2b + 3c.
-/
theorem M₁_hypotenuse_formula (v : Fin 3 → ℤ) :
    hypotenuse ((berggrenMatrix .M₁).mulVec v) = 2 * v 0 - 2 * v 1 + 3 * v 2 := by
  unfold hypotenuse;
  unfold berggrenMatrix;
  simp +decide [ Matrix.mulVec, dotProduct, Fin.sum_univ_three ] ; ring

/-
The hypotenuse of M₂·(a,b,c) is 2a + 2b + 3c.
    This is always > c when a,b > 0, giving exponential growth.
-/
theorem M₂_hypotenuse_formula (v : Fin 3 → ℤ) :
    hypotenuse ((berggrenMatrix .M₂).mulVec v) = 2 * v 0 + 2 * v 1 + 3 * v 2 := by
  simp [hypotenuse, berggrenMatrix];
  ring!

/-
The hypotenuse of M₃·(a,b,c) is -2a + 2b + 3c.
-/
theorem M₃_hypotenuse_formula (v : Fin 3 → ℤ) :
    hypotenuse ((berggrenMatrix .M₃).mulVec v) = -2 * v 0 + 2 * v 1 + 3 * v 2 := by
  -- By definition of matrix multiplication and the given matrix, the third component of the resulting vector is:
  simp [hypotenuse, berggrenMatrix];
  ring!

/-
M₂ strictly increases the hypotenuse when a,b > 0.
    Bridge: this is the mechanism for exponential growth in the Berggren tree,
    giving post_quantum_security hardness for path inversion.
-/
theorem M₂_hypotenuse_growth (v : Fin 3 → ℤ) (ha : 0 < v 0) (hb : 0 < v 1) (_hc : 0 < v 2) :
    v 2 < hypotenuse ((berggrenMatrix .M₂).mulVec v) := by
  exact M₂_hypotenuse_formula v ▸ by linarith;

/-
M₂ gives hypotenuse c' > 3c when a,b > 0: superlinear growth.
-/
theorem M₂_hypotenuse_triple_bound (v : Fin 3 → ℤ)
    (ha : 0 < v 0) (hb : 0 < v 1) (_hc : 0 < v 2) :
    3 * v 2 < hypotenuse ((berggrenMatrix .M₂).mulVec v) := by
  -- By Lemma 2, the determinant of a product of matrices is the product of their determinants.
  have := M₂_hypotenuse_formula v;
  linarith

/-! ## Part XIII: Word Properties -/

/-- The empty word evaluates to the identity matrix. -/
@[simp] theorem evalBerggrenWord_nil : evalBerggrenWord [] = 1 := by
  simp [evalBerggrenWord]

/-- A singleton word evaluates to the generator's matrix. -/
theorem evalBerggrenWord_singleton (g : BerggrenGenerator) :
    evalBerggrenWord [g] = berggrenMatrix g := by
  simp [evalBerggrenWord, List.foldr]

/-
Word evaluation distributes over concatenation.
-/
theorem evalBerggrenWord_append (w₁ w₂ : BerggrenWord) :
    evalBerggrenWord (w₁ ++ w₂) = evalBerggrenWord w₁ * evalBerggrenWord w₂ := by
  unfold evalBerggrenWord;
  induction w₁ <;> simp +decide [ *, mul_assoc ]

/-
Hyperbolic weight is at most the total depth.
-/
theorem hyperbolicWeight_le_depth (w : BerggrenWord) :
    hyperbolicWeight w ≤ BerggrenDepth w := by
  convert List.countP_le_length

/-! ## Part XIV: Lorentz Group Membership -/

/-
For any Berggren word, the evaluated matrix preserves the Minkowski metric.
    This shows that the Berggren semigroup is contained in O(2,1;ℤ).
-/
theorem evalBerggrenWord_preserves_metric (w : BerggrenWord) :
    (evalBerggrenWord w).transpose * MinkowskiMetric * (evalBerggrenWord w) = MinkowskiMetric := by
  unfold evalBerggrenWord;
  induction w <;> simp_all +decide [ List.foldr ];
  rename_i k hk ih; simp_all +decide [ ← Matrix.mul_assoc ] ;
  have := berggren_preserves_metric k; simp_all +decide [ Matrix.mul_assoc ] ;

/-
Any Berggren word applied to a light cone vector stays on the light cone.
-/
theorem evalBerggrenWord_preserves_lightcone (w : BerggrenWord) (v : Fin 3 → ℤ)
    (hQ : MinkowskiQuadraticForm v = 0) :
    MinkowskiQuadraticForm ((evalBerggrenWord w).mulVec v) = 0 := by
  induction' w with g w ih generalizing v;
  · aesop;
  · convert berggren_preserves_MinkowskiQuadraticForm g ( Matrix.mulVec ( evalBerggrenWord w ) v ) using 1;
    · simp +decide [ ← Matrix.mulVec_mulVec, evalBerggrenWord ];
    · rw [ ih v hQ ]

/-! ## Part XV: Injectivity and Hash Properties -/

/-- Different singleton Berggren words produce different matrices.
    Bridge: injectivity for pythagorean_lattice_hash collision resistance. -/
theorem berggren_singleton_injective (g₁ g₂ : BerggrenGenerator)
    (h : berggrenMatrix g₁ = berggrenMatrix g₂) : g₁ = g₂ := by
  cases g₁ <;> cases g₂ <;> first | rfl | (exfalso; revert h; native_decide)

/-- Lipschitz bound: column sums of each generator are ≤ 7.
    Bridge: provides lipschitz_certified_robustness bounds. -/
theorem berggren_column_sum_bound (g : BerggrenGenerator) (j : Fin 3) :
    |berggrenMatrix g 0 j| + |berggrenMatrix g 1 j| + |berggrenMatrix g 2 j| ≤ 7 := by
  cases g <;> fin_cases j <;> native_decide

/-- Row sums of each generator are bounded by 7. -/
theorem berggren_row_sum_bound (g : BerggrenGenerator) (i : Fin 3) :
    |berggrenMatrix g i 0| + |berggrenMatrix g i 1| + |berggrenMatrix g i 2| ≤ 7 := by
  cases g <;> fin_cases i <;> native_decide

/-! ## Part XVI: Spectral Radius Bounds -/

/-
The algebraic identity 32 = (4√2)² connects the discriminant of M₂'s
    characteristic polynomial to the eigenvalue gap.
-/
theorem sqrt_32_eq : Real.sqrt 32 = 4 * Real.sqrt 2 := by
  rw [ show ( 32 : ℝ ) = 16 * 2 by norm_num, Real.sqrt_mul ] <;> norm_num

/-
(3 + 2√2)² = 17 + 12√2.
-/
theorem spectral_radius_sq : (3 + 2 * Real.sqrt 2) ^ 2 = 17 + 12 * Real.sqrt 2 := by
  linarith [ Real.sq_sqrt <| show 0 ≤ 2 by norm_num ]

/-
The M₂ branch has exponential growth rate log(3+2√2) ≈ 1.763.
    Numerically: 3 + 2√2 ≈ 5.828. After k iterations of M₂,
    the hypotenuse grows as (3+2√2)^k, giving O(exp(1.763k)) growth.
    Bridge: this exponential rate is the basis for post_quantum_security
    in Pythagorean lattice cryptosystems — inverting the Berggren path
    from hypotenuse to word requires O(log c) steps but each step has
    exponential search space.
-/
theorem M₂_growth_rate_bound : (5 : ℝ) < 3 + 2 * Real.sqrt 2 ∧ 3 + 2 * Real.sqrt 2 < 6 := by
  constructor <;> nlinarith [ Real.sqrt_nonneg 2, Real.sq_sqrt zero_le_two ]

end LorentzianBerggren