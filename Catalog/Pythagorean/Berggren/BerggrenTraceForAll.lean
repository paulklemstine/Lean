/-
# Berggren Trace Theorems for ALL n (V12)

## Key Results:
1. tr(B₁ⁿ) = 3 for ALL n ∈ ℕ (not just verified for n=1..5)
2. tr(B₃ⁿ) = 3 for ALL n ∈ ℕ
3. Proof via induction using the nilpotent decomposition B = I + N with N³ = 0.

The key insight is a chain of three inductions:
- tr(N² · (I+N)ⁿ) = 0  (since N³ = 0, the N² factor "absorbs" growth)
- tr(N · (I+N)ⁿ) = 0   (reduces to the above)
- tr((I+N)ⁿ) = 3        (reduces to the above)

This resolves Direction 42 from the V11 research paper.

Machine-verified in Lean 4 with Mathlib.
-/
import Mathlib

open Matrix

/-! ## Matrix Definitions -/

def BTA₁ : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]
def BTA₃ : Matrix (Fin 3) (Fin 3) ℤ := !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]

/-- Nilpotent part N₁ = B₁ - I -/
def NTA₁ : Matrix (Fin 3) (Fin 3) ℤ := !![0, -2, 2; 2, -2, 2; 2, -2, 2]
/-- Nilpotent part N₃ = B₃ - I -/
def NTA₃ : Matrix (Fin 3) (Fin 3) ℤ := !![(-2), 2, 2; (-2), 0, 2; (-2), 2, 2]

/-! ## Key identities -/

theorem trace_NTA₁ : Matrix.trace NTA₁ = 0 := by native_decide
theorem trace_NTA₃ : Matrix.trace NTA₃ = 0 := by native_decide
theorem trace_NTA₁_sq : Matrix.trace (NTA₁ ^ 2) = 0 := by native_decide
theorem trace_NTA₃_sq : Matrix.trace (NTA₃ ^ 2) = 0 := by native_decide

theorem NTA₁_cubed : NTA₁ ^ 3 = 0 := by native_decide
theorem NTA₃_cubed : NTA₃ ^ 3 = 0 := by native_decide

theorem BTA₁_eq : BTA₁ = 1 + NTA₁ := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [BTA₁, NTA₁]

theorem BTA₃_eq : BTA₃ = 1 + NTA₃ := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [BTA₃, NTA₃]

/-! ## General trace lemma for nilpotent perturbation of identity

For any 3×3 integer matrix N with N³ = 0 and tr(N) = 0 and tr(N²) = 0,
we have tr((I + N)ⁿ) = 3 for all n. -/

/-
Step 1: tr(N² · (1+N)ⁿ) = tr(N²) when N³ = 0
-/
theorem trace_Nsq_mul_pow (N : Matrix (Fin 3) (Fin 3) ℤ) (hN3 : N ^ 3 = 0)
    (n : ℕ) : Matrix.trace (N ^ 2 * (1 + N) ^ n) = Matrix.trace (N ^ 2) := by
  induction n <;> simp_all +decide [ pow_succ', mul_add, add_mul ];
  simp_all +decide [ ← mul_assoc ]

/-
Step 2: tr(N · (1+N)ⁿ) = tr(N) when N³ = 0 and tr(N²) = 0
-/
theorem trace_N_mul_pow (N : Matrix (Fin 3) (Fin 3) ℤ) (hN3 : N ^ 3 = 0)
    (htrN2 : Matrix.trace (N ^ 2) = 0)
    (n : ℕ) : Matrix.trace (N * (1 + N) ^ n) = Matrix.trace N := by
  -- By induction on n.
  induction' n with n ih;
  · norm_num;
  · rw [ pow_succ' ];
    simp_all +decide [ mul_add, add_mul, ← mul_assoc ];
    convert trace_Nsq_mul_pow N hN3 n using 1;
    · rw [ pow_two ];
    · exact htrN2.symm

/-
Step 3: tr((1+N)ⁿ) = 3 when N³ = 0 and tr(N) = 0 and tr(N²) = 0
-/
theorem trace_one_add_nilp_pow (N : Matrix (Fin 3) (Fin 3) ℤ) (hN3 : N ^ 3 = 0)
    (htrN : Matrix.trace N = 0) (htrN2 : Matrix.trace (N ^ 2) = 0)
    (n : ℕ) : Matrix.trace ((1 + N) ^ n) = 3 := by
  -- By induction on $n$.
  induction' n with n ih;
  · norm_num [ Matrix.trace ];
  · -- By linearity of trace, we can split the trace into the sum of two traces.
    have h_trace_split : Matrix.trace (((1 + N) ^ n) * (1 + N)) = Matrix.trace (((1 + N) ^ n)) + Matrix.trace (N * (1 + N) ^ n) := by
      rw [ ← Matrix.trace_mul_comm ] ; simp +decide [ add_mul, mul_add, mul_assoc, pow_succ ] ;
    rw [ pow_succ, h_trace_split, ih, trace_N_mul_pow N hN3 htrN2, htrN, add_zero ]

/-! ## Main results -/

/-- **tr(B₁ⁿ) = 3 for ALL n.** Previously verified only for n=1..5. -/
theorem trace_BTA₁_pow (n : ℕ) : Matrix.trace (BTA₁ ^ n) = 3 := by
  rw [BTA₁_eq]
  exact trace_one_add_nilp_pow NTA₁ NTA₁_cubed trace_NTA₁ trace_NTA₁_sq n

/-- **tr(B₃ⁿ) = 3 for ALL n.** -/
theorem trace_BTA₃_pow (n : ℕ) : Matrix.trace (BTA₃ ^ n) = 3 := by
  rw [BTA₃_eq]
  exact trace_one_add_nilp_pow NTA₃ NTA₃_cubed trace_NTA₃ trace_NTA₃_sq n