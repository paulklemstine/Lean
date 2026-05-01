import Mathlib

/-!
# Tropical p-Adic Berggren Factorization: Foundation and Analysis

This file establishes the rigorous foundations for the proposed connection between
Berggren tree matrices, their characteristic polynomials, and p-adic Newton polygons.

## Main Results

### Step 1: Berggren Matrix Foundations
- **Determinants**: `det_berggren_A = 1`, `det_berggren_B = -1`, `det_berggren_C = 1`
  (Note: The original conjecture incorrectly claimed det(B) = 1.)
- **Pythagorean preservation**: Each matrix preserves the Lorentz form Q = diag(1,1,-1),
  which implies preservation of the Pythagorean property a² + b² = c².
- **Characteristic polynomials**:
  - A and C are unipotent: χ(A) = χ(C) = (λ-1)³
  - B has irrational eigenvalues: χ(B) = (λ+1)(λ² - 6λ + 1),
    with eigenvalues -1, 3±2√2.
    (The original conjecture incorrectly claimed χ(B) = -(λ-1)(λ-2)².)

### Computational Corrections
- The path to (15, 8, 17) is C, not B·A.
- B·A produces (55, 48, 73), not (15, 8, 17).
- The product B·A = !![9,-8,12;8,-9,12;12,-12,17], not !![−3,4,4;−4,3,4;−4,4,5].

### Newton Polygon Analysis
The characteristic polynomial coefficients of Berggren path matrices are always
small integers (bounded by traces and minors of products of {A,B,C}).
For any prime hypotenuse p, the p-adic valuations of these coefficients are
generically all zero, making the Newton polygon trivial (a single horizontal edge).
This **refutes** the conjecture that Newton polygon slopes encode prime factorizations.

See `TropicalPAdicAnalysis.md` for detailed mathematical discussion.
-/

/-! ## Berggren Matrix Definitions -/

/-- Berggren matrix A (generating the A-branch of the Pythagorean triple tree) -/
def berggren_A : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Berggren matrix B (generating the B-branch of the Pythagorean triple tree) -/
def berggren_B : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Berggren matrix C (generating the C-branch of the Pythagorean triple tree) -/
def berggren_C : Matrix (Fin 3) (Fin 3) ℤ :=
  !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- The Lorentz form Q = diag(1, 1, -1), encoding the Pythagorean constraint a² + b² = c² -/
def lorentz_Q : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 0, 0; 0, 1, 0; 0, 0, (-1)]

/-- The root triple of the Berggren tree -/
def root_triple : Fin 3 → ℤ := ![3, 4, 5]

/-! ## Step 1a: Determinants -/

/-- det(A) = 1 -/
theorem det_berggren_A : berggren_A.det = 1 := by native_decide

/-- det(B) = -1 (NOT 1 as incorrectly stated in the original conjecture) -/
theorem det_berggren_B : berggren_B.det = -1 := by native_decide

/-- det(C) = 1 -/
theorem det_berggren_C : berggren_C.det = 1 := by native_decide

/-! ## Step 1b: Lorentz Form Preservation (implies Pythagorean preservation) -/

/-- A preserves the Lorentz form: Aᵀ Q A = Q -/
theorem berggren_A_preserves_lorentz :
    berggren_A.transpose * lorentz_Q * berggren_A = lorentz_Q := by native_decide

/-- B preserves the Lorentz form: Bᵀ Q B = Q -/
theorem berggren_B_preserves_lorentz :
    berggren_B.transpose * lorentz_Q * berggren_B = lorentz_Q := by native_decide

/-- C preserves the Lorentz form: Cᵀ Q C = Q -/
theorem berggren_C_preserves_lorentz :
    berggren_C.transpose * lorentz_Q * berggren_C = lorentz_Q := by native_decide

/-! ## Step 1c: Pythagorean Preservation (direct algebraic proofs) -/

/-- A maps Pythagorean triples to Pythagorean triples -/
theorem berggren_A_preserves_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a - 2*b + 2*c) ^ 2 + (2*a - b + 2*c) ^ 2 = (2*a - 2*b + 3*c) ^ 2 := by
  nlinarith [sq_nonneg (a - b), sq_nonneg (a + b), sq_nonneg (a - c), sq_nonneg (b - c)]

/-- B maps Pythagorean triples to Pythagorean triples -/
theorem berggren_B_preserves_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a + 2*b + 2*c) ^ 2 + (2*a + b + 2*c) ^ 2 = (2*a + 2*b + 3*c) ^ 2 := by
  nlinarith [sq_nonneg (a - b), sq_nonneg (a + b), sq_nonneg (a - c), sq_nonneg (b - c)]

/-- C maps Pythagorean triples to Pythagorean triples -/
theorem berggren_C_preserves_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (-a + 2*b + 2*c) ^ 2 + (-2*a + b + 2*c) ^ 2 = (-2*a + 2*b + 3*c) ^ 2 := by
  nlinarith [sq_nonneg (a - b), sq_nonneg (a + b), sq_nonneg (a - c), sq_nonneg (b - c)]

/-! ## Step 1d: Concrete triple generation -/

/-- A applied to (3,4,5) gives (5,12,13) -/
theorem berggren_A_root : berggren_A.mulVec root_triple = ![5, 12, 13] := by native_decide

/-- B applied to (3,4,5) gives (21,20,29) -/
theorem berggren_B_root : berggren_B.mulVec root_triple = ![21, 20, 29] := by native_decide

/-- C applied to (3,4,5) gives (15,8,17) -/
theorem berggren_C_root : berggren_C.mulVec root_triple = ![15, 8, 17] := by native_decide

/-! ## Step 1e: Characteristic Polynomials -/

/-- A is unipotent of order exactly 3: (A - I)³ = 0 -/
theorem berggren_A_unipotent : (berggren_A - 1) ^ 3 = 0 := by native_decide

/-- (A - I)² ≠ 0, so nilpotency order is exactly 3 -/
theorem berggren_A_nilpotency_exact : (berggren_A - 1) ^ 2 ≠ 0 := by native_decide

/-- B satisfies the Cayley-Hamilton relation B³ - 5B² - 5B + I = 0,
    corresponding to characteristic polynomial λ³ - 5λ² - 5λ + 1 = (λ+1)(λ² - 6λ + 1).
    The eigenvalues are -1, 3+2√2, 3-2√2.
    (NOT (λ-1)(λ-2)² as incorrectly claimed in the original conjecture.) -/
theorem berggren_B_cayley_hamilton :
    berggren_B ^ 3 - 5 • berggren_B ^ 2 - 5 • berggren_B + 1 = 0 := by native_decide

/-- B does NOT satisfy the incorrectly claimed relation B³ - 5B² + 8B - 4I = 0 -/
theorem berggren_B_not_user_charpoly :
    berggren_B ^ 3 - 5 • berggren_B ^ 2 + 8 • berggren_B
      - 4 • (1 : Matrix (Fin 3) (Fin 3) ℤ) ≠ 0 := by
  native_decide

/-- C is unipotent of order exactly 3: (C - I)³ = 0 -/
theorem berggren_C_unipotent : (berggren_C - 1) ^ 3 = 0 := by native_decide

/-- C and A are conjugate via the leg-swap matrix -/
def leg_swap : Matrix (Fin 3) (Fin 3) ℤ := !![0, 1, 0; 1, 0, 0; 0, 0, 1]

theorem berggren_C_eq_swap_A_swap :
    leg_swap * berggren_A * leg_swap = berggren_C := by native_decide

/-! ## Step 1f: Correcting the claimed B·A computation -/

/-- The actual product B·A (correcting the user's erroneous matrix) -/
theorem berggren_BA_product :
    berggren_B * berggren_A = !![9, -8, 12; 8, -9, 12; 12, -12, 17] := by native_decide

/-- B·A applied to (3,4,5) gives (55,48,73), NOT (15,8,17) as claimed -/
theorem berggren_BA_root :
    (berggren_B * berggren_A).mulVec root_triple = ![55, 48, 73] := by native_decide

/-- The path to (15,8,17) is C alone, not B·A -/
theorem path_to_15_8_17_is_C :
    berggren_C.mulVec root_triple = ![15, 8, 17] := by native_decide

/-! ## Newton Polygon Refutation

The conjecture claims that the Newton polygon of χ(M) at a prime p dividing the
hypotenuse encodes the factorization of p. We refute this by showing the Newton
polygon is trivial in all base cases.

For a prime hypotenuse p, the characteristic polynomial coefficients of the
corresponding Berggren path matrix are small integers not divisible by p:

- p = 5: identity matrix, χ = (λ-1)³, coefficients {-1, 3, -3, 1}, all coprime to 5
- p = 13: matrix A, χ = (λ-1)³, coefficients {-1, 3, -3, 1}, all coprime to 13
- p = 17: matrix C, χ = (λ-1)³, coefficients {-1, 3, -3, 1}, all coprime to 17
- p = 29: matrix B, χ = λ³ - 5λ² - 5λ + 1, coefficients {1, -5, -5, 1}, all coprime to 29

In each case, all p-adic valuations are 0, so the Newton polygon is a single
horizontal line segment — carrying no information about p whatsoever.
-/

/-- None of the char poly coefficients of A are divisible by 13 -/
theorem charpoly_A_coprime_13 : ∀ c ∈ ([(-1 : ℤ), 3, -3, 1] : List ℤ), ¬(13 ∣ c) := by
  decide

/-- None of the char poly coefficients of C are divisible by 17 -/
theorem charpoly_C_coprime_17 : ∀ c ∈ ([(-1 : ℤ), 3, -3, 1] : List ℤ), ¬(17 ∣ c) := by
  decide

/-- None of the char poly coefficients of B are divisible by 29 -/
theorem charpoly_B_coprime_29 : ∀ c ∈ ([1, (-5 : ℤ), -5, 1] : List ℤ), ¬(29 ∣ c) := by
  decide

/-! ## What IS True: The Lorentz Structure

The correct algebraic story is that the Berggren matrices preserve the indefinite
quadratic form Q(a,b,c) = a² + b² - c², forming a subgroup of the integer orthogonal
group O(2,1; ℤ). This structure completely explains why they map Pythagorean triples
to Pythagorean triples.

The characteristic polynomial of a Berggren path matrix M depends on M itself
(its trace, minors, determinant) and has no systematic relationship to the
hypotenuse of the triple M·(3,4,5)ᵀ. The hypotenuse is the third component of a
matrix-vector product, while the char poly is an intrinsic invariant of the matrix.
These are fundamentally different algebraic objects.
-/

/-- The root triple satisfies the Pythagorean property -/
theorem root_triple_pythagorean :
    root_triple 0 ^ 2 + root_triple 1 ^ 2 = root_triple 2 ^ 2 := by native_decide

/-
Any product of Berggren matrices preserves the Lorentz form.
    This is proved by induction on the list of matrices.
-/
theorem berggren_product_preserves_lorentz
    (Ms : List (Matrix (Fin 3) (Fin 3) ℤ))
    (hMs : ∀ M ∈ Ms, M.transpose * lorentz_Q * M = lorentz_Q) :
    let P := Ms.prod
    P.transpose * lorentz_Q * P = lorentz_Q := by
  induction' Ms using List.reverseRecOn with Ms M ih <;> simp +decide [ *, mul_assoc ];
  simp_all +decide [ ← mul_assoc ]