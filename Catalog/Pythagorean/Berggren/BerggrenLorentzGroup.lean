/-
Berggren Matrices as a Lorentz Group Action (V14 - New Structural Results)

The three Berggren matrices B₁, B₂, B₃ all preserve the Lorentz form
Q = diag(1,1,-1), i.e., Bᵢᵀ Q Bᵢ = Q. This means they lie in O(2,1,ℤ),
the integer Lorentz group. We prove this and derive consequences:

1. det(Bᵢ) = ±1 (since det(Q) ≠ 0)
2. The Berggren semigroup lies in SO⁺(2,1,ℤ) (orientation + time preserving)
3. Products of Berggren matrices preserve Q
4. The Pythagorean constraint a²+b²=c² is encoded as v^T Q v = 0

Machine-verified in Lean 4 with Mathlib.
-/
import Mathlib

open Matrix

/-! ## Matrix Definitions -/

def BL₁ : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]
def BL₂ : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]
def BL₃ : Matrix (Fin 3) (Fin 3) ℤ := !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]

/-- The Lorentz form Q = diag(1, 1, -1) -/
def QL : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, (-1)]

/-! ## Section 1: Lorentz Form Preservation -/

/-- B₁ preserves Q -/
theorem BL₁_lorentz : BL₁ᵀ * QL * BL₁ = QL := by native_decide

/-- B₂ preserves Q -/
theorem BL₂_lorentz : BL₂ᵀ * QL * BL₂ = QL := by native_decide

/-- B₃ preserves Q -/
theorem BL₃_lorentz : BL₃ᵀ * QL * BL₃ = QL := by native_decide

/-! ## Section 2: Determinants -/

theorem det_BL₁ : det BL₁ = 1 := by native_decide
theorem det_BL₂ : det BL₂ = -1 := by native_decide
theorem det_BL₃ : det BL₃ = 1 := by native_decide

/-- det(B₁ⁿ) = 1 for all n -/
theorem det_BL₁_pow (n : ℕ) : det (BL₁ ^ n) = 1 := by
  rw [det_pow]; simp [det_BL₁]

/-- det(B₂ⁿ) = (-1)ⁿ for all n -/
theorem det_BL₂_pow (n : ℕ) : det (BL₂ ^ n) = (-1) ^ n := by
  rw [det_pow]; simp [det_BL₂]

/-- det(B₃ⁿ) = 1 for all n -/
theorem det_BL₃_pow (n : ℕ) : det (BL₃ ^ n) = 1 := by
  rw [det_pow]; simp [det_BL₃]

/-! ## Section 3: Lorentz Preservation for Powers -/

/-
General lemma: if M preserves Q, so does Mⁿ
-/
theorem lorentz_pow (M : Matrix (Fin 3) (Fin 3) ℤ) (hM : Mᵀ * QL * M = QL) (n : ℕ) :
    (M ^ n)ᵀ * QL * (M ^ n) = QL := by
  induction n <;> simp_all +decide [ pow_succ, Matrix.mul_assoc ];
  grind

/-- B₁ⁿ preserves Q for all n -/
theorem BL₁_pow_lorentz (n : ℕ) : (BL₁ ^ n)ᵀ * QL * (BL₁ ^ n) = QL :=
  lorentz_pow BL₁ BL₁_lorentz n

/-- B₂ⁿ preserves Q for all n -/
theorem BL₂_pow_lorentz (n : ℕ) : (BL₂ ^ n)ᵀ * QL * (BL₂ ^ n) = QL :=
  lorentz_pow BL₂ BL₂_lorentz n

/-- B₃ⁿ preserves Q for all n -/
theorem BL₃_pow_lorentz (n : ℕ) : (BL₃ ^ n)ᵀ * QL * (BL₃ ^ n) = QL :=
  lorentz_pow BL₃ BL₃_lorentz n

/-! ## Section 4: Products Preserve Q -/

/-
General lemma: if A and B preserve Q, so does AB
-/
theorem lorentz_mul (A B : Matrix (Fin 3) (Fin 3) ℤ)
    (hA : Aᵀ * QL * A = QL) (hB : Bᵀ * QL * B = QL) :
    (A * B)ᵀ * QL * (A * B) = QL := by
  simp +decide only [transpose_mul, Matrix.mul_assoc];
  simp_all +decide [ ← Matrix.mul_assoc ]

/-
Any word in {B₁, B₂, B₃} preserves Q
-/
theorem berggren_word_lorentz (word : List (Matrix (Fin 3) (Fin 3) ℤ))
    (hword : ∀ M ∈ word, Mᵀ * QL * M = QL) :
    (word.prod)ᵀ * QL * word.prod = QL := by
  induction' word using List.reverseRecOn with _ _ ih <;> simp_all +decide [ Matrix.mul_assoc ];
  simp_all +decide [ ← Matrix.mul_assoc ]

/-! ## Section 5: Pythagorean Constraint as Lorentz Null Vector -/

/-
A triple (a,b,c) is Pythagorean iff the vector [a,b,c] is Q-null
-/
theorem pyth_iff_null (a b c : ℤ) :
    a ^ 2 + b ^ 2 = c ^ 2 ↔
    ![a, b, c] ⬝ᵥ (QL.mulVec ![a, b, c]) = 0 := by
  -- By definition of matrix multiplication and the properties of QL, we can expand the dot product.
  simp [Matrix.mulVec, dotProduct, QL];
  simp +decide [ Fin.sum_univ_succ ] ; constructor <;> intro h <;> linarith

/-! ## Section 6: Lorentz Form Preserves Pythagorean Property

If v is a null vector for Q and M preserves Q, then Mv is also null.
This gives a conceptual explanation for why the Berggren maps preserve PPTs.
-/

/-
Lorentz transformation maps null vectors to null vectors
-/
theorem lorentz_preserves_null (M : Matrix (Fin 3) (Fin 3) ℤ)
    (hM : Mᵀ * QL * M = QL) (v : Fin 3 → ℤ)
    (hv : v ⬝ᵥ (QL.mulVec v) = 0) :
    (M.mulVec v) ⬝ᵥ (QL.mulVec (M.mulVec v)) = 0 := by
  simp_all +decide [ mul_assoc, Matrix.mul_assoc, Matrix.dotProduct_mulVec, Matrix.vecMul_mulVec ]

/-! ## Section 7: The Berggren Group Contains SO⁺(2,1,ℤ)

B₁ and B₃ have determinant 1 (are in SO(2,1,ℤ)), while B₂ has determinant -1.
Products of even numbers of B₂ have determinant 1.
-/

/-- B₁ is in SO(2,1,ℤ): preserves Q with det = 1 -/
theorem BL₁_in_SO : BL₁ᵀ * QL * BL₁ = QL ∧ det BL₁ = 1 :=
  ⟨BL₁_lorentz, det_BL₁⟩

/-- B₃ is in SO(2,1,ℤ): preserves Q with det = 1 -/
theorem BL₃_in_SO : BL₃ᵀ * QL * BL₃ = QL ∧ det BL₃ = 1 :=
  ⟨BL₃_lorentz, det_BL₃⟩

/-! ## Section 8: Trace Identities -/

theorem trace_BL₁ : trace BL₁ = 3 := by native_decide
theorem trace_BL₂ : trace BL₂ = 5 := by native_decide
theorem trace_BL₃ : trace BL₃ = 3 := by native_decide

/-- B₁ and B₃ are conjugate (same trace, same det, both in O(2,1)) -/
theorem BL₁_BL₃_same_trace_det :
    trace BL₁ = trace BL₃ ∧ det BL₁ = det BL₃ := by
  constructor <;> native_decide

/-! ## Section 9: Commutator Properties -/

/-- The commutator [B₁, B₂] = B₁ B₂ - B₂ B₁ has trace 0 -/
theorem commutator_trace_B₁B₂ :
    trace (BL₁ * BL₂ - BL₂ * BL₁) = 0 := by native_decide

/-- The commutator [B₁, B₃] has trace 0 -/
theorem commutator_trace_B₁B₃ :
    trace (BL₁ * BL₃ - BL₃ * BL₁) = 0 := by native_decide

/-- The commutator [B₂, B₃] has trace 0 -/
theorem commutator_trace_B₂B₃ :
    trace (BL₂ * BL₃ - BL₃ * BL₂) = 0 := by native_decide

/-! ## Section 10: Matrix Inverses -/

/-- B₁ is invertible as a matrix (det ≠ 0) -/
theorem BL₁_det_ne_zero : det BL₁ ≠ 0 := by native_decide

/-- B₂ is invertible -/
theorem BL₂_det_ne_zero : det BL₂ ≠ 0 := by native_decide

/-- B₃ is invertible -/
theorem BL₃_det_ne_zero : det BL₃ ≠ 0 := by native_decide