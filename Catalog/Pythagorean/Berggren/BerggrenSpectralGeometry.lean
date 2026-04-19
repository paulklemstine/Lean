/-
# Spectral Geometry of the Berggren Tree (V18 - NEW Direction 92)

NEW DISCOVERY: B₁ and B₃ are **unipotent** — (B₁ - I)³ = 0 and (B₃ - I)³ = 0,
meaning they have eigenvalue 1 with algebraic multiplicity 3. Their traces are
constantly 3 at all powers: tr(B₁ⁿ) = tr(B₃ⁿ) = 3 for all n.

In contrast, B₂ has eigenvalues 3 ± 2√2 and -1, giving rich spectral behavior.

The "spectral trichotomy" of the Berggren tree:
- A-branch (B₁): unipotent, polynomial growth
- B-branch (B₂): diagonalizable, exponential growth
- C-branch (B₃): unipotent, polynomial growth

Machine-verified in Lean 4 with Mathlib.
-/
import Mathlib

open Matrix

/-! ## Section 1: The Three Berggren Matrices -/

def B₁ : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]
def B₂ : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]
def B₃ : Matrix (Fin 3) (Fin 3) ℤ := !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-! ## Section 2: Determinants — The Spectral Trichotomy -/

/-- B₁ has determinant 1 (orientation-preserving, consistent with unipotency) -/
theorem B₁_det : det B₁ = 1 := by native_decide

/-- B₂ has determinant -1 (orientation-reversing) -/
theorem B₂_det : det B₂ = -1 := by native_decide

/-- B₃ has determinant 1 (orientation-preserving, consistent with unipotency) -/
theorem B₃_det : det B₃ = 1 := by native_decide

/-! ## Section 3: Traces -/

theorem B₁_trace : trace B₁ = 3 := by native_decide
theorem B₂_trace : trace B₂ = 5 := by native_decide
theorem B₃_trace : trace B₃ = 3 := by native_decide

/-- Sum of traces = 11 -/
theorem trace_sum : trace B₁ + trace B₂ + trace B₃ = 11 := by native_decide

/-! ## Section 4: UNIPOTENCY — The Key Discovery -/

/-- **B₁ is unipotent of degree 3**: (B₁ - I)³ = 0 -/
theorem B₁_unipotent : (B₁ - 1) ^ 3 = 0 := by native_decide

/-- **B₃ is unipotent of degree 3**: (B₃ - I)³ = 0 -/
theorem B₃_unipotent : (B₃ - 1) ^ 3 = 0 := by native_decide

/-- B₂ is NOT unipotent -/
theorem B₂_not_unipotent : (B₂ - 1) ^ 3 ≠ 0 := by native_decide

/-- (B₁ - I)² ≠ 0, so B₁ is unipotent of EXACT degree 3 -/
theorem B₁_unipotent_exact : (B₁ - 1) ^ 2 ≠ 0 := by native_decide

/-- (B₃ - I)² ≠ 0, so B₃ is unipotent of EXACT degree 3 -/
theorem B₃_unipotent_exact : (B₃ - 1) ^ 2 ≠ 0 := by native_decide

/-! ## Section 5: Constant Trace for Unipotent Matrices -/

/-- tr(B₁ⁿ) = 3 for small n (verified computationally) -/
theorem B₁_trace_constant :
    trace (B₁ ^ 0) = 3 ∧ trace (B₁ ^ 1) = 3 ∧
    trace (B₁ ^ 2) = 3 ∧ trace (B₁ ^ 3) = 3 ∧
    trace (B₁ ^ 4) = 3 ∧ trace (B₁ ^ 5) = 3 := by
  refine ⟨by native_decide, by native_decide, by native_decide,
          by native_decide, by native_decide, by native_decide⟩

/-- tr(B₃ⁿ) = 3 for small n (verified computationally) -/
theorem B₃_trace_constant :
    trace (B₃ ^ 0) = 3 ∧ trace (B₃ ^ 1) = 3 ∧
    trace (B₃ ^ 2) = 3 ∧ trace (B₃ ^ 3) = 3 ∧
    trace (B₃ ^ 4) = 3 ∧ trace (B₃ ^ 5) = 3 := by
  refine ⟨by native_decide, by native_decide, by native_decide,
          by native_decide, by native_decide, by native_decide⟩

/-! ## Section 6: tr(Bⁿ) = 3 for ALL n when B is unipotent of degree 3

For a 3×3 integer matrix M with (M-I)³ = 0:
  M = I + N where N³ = 0
  Mⁿ = I + n·N + n(n-1)/2·N²   (binomial, since N³=0)
  tr(Mⁿ) = 3 + n·tr(N) + n(n-1)/2·tr(N²)

If tr(N) = 0 and tr(N²) = 0, then tr(Mⁿ) = 3 for all n. -/

/-- B₁ - I has trace 0 -/
theorem B₁_minus_I_trace : trace (B₁ - 1) = 0 := by native_decide

/-- (B₁ - I)² has trace 0 -/
theorem B₁_minus_I_sq_trace : trace ((B₁ - 1) ^ 2) = 0 := by native_decide

/-- B₃ - I has trace 0 -/
theorem B₃_minus_I_trace : trace (B₃ - 1) = 0 := by native_decide

/-- (B₃ - I)² has trace 0 -/
theorem B₃_minus_I_sq_trace : trace ((B₃ - 1) ^ 2) = 0 := by native_decide

/-! ## Section 7: Full Proof that tr(B₁ⁿ) = 3 for all n -/

/-
**Main theorem**: tr(B₁ⁿ) = 3 for all n ∈ ℕ
-/
theorem B₁_trace_all (n : ℕ) : trace (B₁ ^ n) = 3 := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | _ | n ) <;> simp_all +decide;
  -- Use the recurrence relation for the trace of B₁^n
  have h_recurrence : ∀ n, Matrix.trace (B₁ ^ (n + 3)) = 3 * Matrix.trace (B₁ ^ (n + 2)) - 3 * Matrix.trace (B₁ ^ (n + 1)) + Matrix.trace (B₁ ^ n) := by
    intro n
    have h_recurrence : B₁ ^ (n + 3) = 3 • (B₁ ^ (n + 2)) - 3 • (B₁ ^ (n + 1)) + (B₁ ^ n) := by
      induction n <;> simp_all +decide [ pow_succ, mul_assoc ] ; abel_nf;
      simp_all +decide [ mul_assoc, add_mul, mul_add, pow_succ ];
      grind +qlia;
    simp +decide [ h_recurrence, Matrix.trace_add, Matrix.trace_smul ];
    norm_num [ Matrix.trace, Matrix.mul_apply ];
    erw [ show ( 3 : Matrix ( Fin 3 ) ( Fin 3 ) ℤ ) = fun i j => if i = j then 3 else 0 by ext i j; fin_cases i <;> fin_cases j <;> rfl ] ; simp +decide [ Fin.sum_univ_three ] ; ring!;
  linarith [ ih n ( by linarith ), ih ( n + 1 ) ( by linarith ), ih ( n + 2 ) ( by linarith ), h_recurrence n ]

/-
**Main theorem**: tr(B₃ⁿ) = 3 for all n ∈ ℕ
-/
theorem B₃_trace_all (n : ℕ) : trace (B₃ ^ n) = 3 := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | _ | n ) <;> simp_all +decide [ pow_succ' ];
  have h_recurrence : ∀ n : ℕ, trace (B₃ ^ (n + 3)) = 3 * trace (B₃ ^ (n + 2)) - 3 * trace (B₃ ^ (n + 1)) + trace (B₃ ^ n) := by
    intro n
    have h_recurrence : B₃ ^ (n + 3) = 3 • B₃ ^ (n + 2) - 3 • B₃ ^ (n + 1) + B₃ ^ n := by
      induction n <;> simp_all +decide [ pow_succ, mul_assoc ];
      simp_all +decide [ mul_assoc, sub_mul, add_mul ];
      grind;
    simp +decide [ h_recurrence, Matrix.trace_add, Matrix.trace_smul ];
    norm_num [ Matrix.trace, Matrix.mul_apply ];
    erw [ show ( 3 : Matrix ( Fin 3 ) ( Fin 3 ) ℤ ) = fun i j => if i = j then 3 else 0 by ext i j; fin_cases i <;> fin_cases j <;> rfl ] ; simp +decide [ Fin.sum_univ_three ] ; ring;
  have := ih n ( by linarith ) ; have := ih ( n+1 ) ( by linarith ) ; have := ih ( n+2 ) ( by linarith ) ; simp_all +decide [ pow_succ' ] ;

/-! ## Section 8: The Sum Matrix -/

def B_sum : Matrix (Fin 3) (Fin 3) ℤ := B₁ + B₂ + B₃

theorem B_sum_eq : B_sum = !![1, 2, 6; 2, 1, 6; 2, 2, 9] := by native_decide
theorem B_sum_det : det B_sum = -3 := by native_decide
theorem B_sum_trace : trace B_sum = 11 := by native_decide

/-! ## Section 9: Product Determinants -/

theorem B₁B₂_det : det (B₁ * B₂) = -1 := by native_decide
theorem B₂B₃_det : det (B₂ * B₃) = -1 := by native_decide
theorem B₁B₃_det : det (B₁ * B₃) = 1 := by native_decide

/-- Products of same-parity determinant matrices preserve det sign -/
theorem unipotent_product_det : det (B₁ * B₃) = 1 := by native_decide

/-! ## Section 10: Commutator Analysis -/

/-- No two Berggren matrices commute -/
theorem B₁B₂_noncommute : B₁ * B₂ ≠ B₂ * B₁ := by native_decide
theorem B₁B₃_noncommute : B₁ * B₃ ≠ B₃ * B₁ := by native_decide
theorem B₂B₃_noncommute : B₂ * B₃ ≠ B₃ * B₂ := by native_decide

/-- All commutators have trace 0 -/
theorem commutator_B₁B₂_trace : trace (B₁ * B₂ - B₂ * B₁) = 0 := by native_decide
theorem commutator_B₁B₃_trace : trace (B₁ * B₃ - B₃ * B₁) = 0 := by native_decide
theorem commutator_B₂B₃_trace : trace (B₂ * B₃ - B₃ * B₂) = 0 := by native_decide

/-! ## Section 11: Cayley-Hamilton -/

/-- B₁ satisfies (λ-1)³ = 0, i.e., B₁³ - 3B₁² + 3B₁ - I = 0 -/
theorem B₁_cayley_hamilton : B₁ ^ 3 - 3 • B₁ ^ 2 + 3 • B₁ - 1 = 0 := by native_decide

/-- B₃ satisfies the same Cayley-Hamilton as B₁ -/
theorem B₃_cayley_hamilton : B₃ ^ 3 - 3 • B₃ ^ 2 + 3 • B₃ - 1 = 0 := by native_decide

/-- B₂ has different Cayley-Hamilton: B₂³ - 5B₂² - 5B₂ + I = 0 -/
theorem B₂_cayley_hamilton : B₂ ^ 3 = 5 • B₂ ^ 2 + 5 • B₂ - 1 := by native_decide

/-! ## Section 12: B₂ Trace Sequence (exponential growth) -/

theorem B₂_trace_seq :
    trace (B₂ ^ 0) = 3 ∧ trace (B₂ ^ 1) = 5 ∧
    trace (B₂ ^ 2) = 35 ∧ trace (B₂ ^ 3) = 197 := by
  refine ⟨by native_decide, by native_decide, by native_decide, by native_decide⟩

/-- B₂ trace grows exponentially (verified for first terms) -/
theorem B₂_trace_growth :
    trace (B₂ ^ 2) > 2 * trace (B₂ ^ 1) ∧
    trace (B₂ ^ 3) > 2 * trace (B₂ ^ 2) := by
  refine ⟨by native_decide, by native_decide⟩

/-! ## Section 13: Hypotenuse Growth Rates -/

/-- The (3,3) entry is 3 for all three matrices -/
theorem hypotenuse_coefficient :
    B₁ 2 2 = 3 ∧ B₂ 2 2 = 3 ∧ B₃ 2 2 = 3 := by
  refine ⟨by native_decide, by native_decide, by native_decide⟩