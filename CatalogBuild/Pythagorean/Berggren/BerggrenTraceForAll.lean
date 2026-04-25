/-! # CatalogBuild.Pythagorean.Berggren.BerggrenTraceForAll

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 17
-/

import Mathlib

/-- [Section: ## Matrix Definitions] -/
def BTA₁ : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]


/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenTraceForAll
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 17] -/
def BTA₃ : Matrix (Fin 3) (Fin 3) ℤ := !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]


/-- Nilpotent part N₁ = B₁ - I -/
def NTA₁ : Matrix (Fin 3) (Fin 3) ℤ := !![0, -2, 2; 2, -2, 2; 2, -2, 2]


/-- Nilpotent part N₃ = B₃ - I -/
def NTA₃ : Matrix (Fin 3) (Fin 3) ℤ := !![(-2), 2, 2; (-2), 0, 2; (-2), 2, 2]


/-- [Section: ## Key identities] -/
theorem trace_NTA₁ : Matrix.trace NTA₁ = 0 := by native_decide


/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenTraceForAll
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 17] -/
theorem trace_NTA₃ : Matrix.trace NTA₃ = 0 := by native_decide


theorem trace_NTA₁_sq : Matrix.trace (NTA₁ ^ 2) = 0 := by native_decide


theorem trace_NTA₃_sq : Matrix.trace (NTA₃ ^ 2) = 0 := by native_decide


theorem NTA₁_cubed : NTA₁ ^ 3 = 0 := by native_decide


theorem NTA₃_cubed : NTA₃ ^ 3 = 0 := by native_decide


theorem BTA₁_eq : BTA₁ = 1 + NTA₁ := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [BTA₁, NTA₁]


theorem BTA₃_eq : BTA₃ = 1 + NTA₃ := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [BTA₃, NTA₃]


/-- [Section: ## General trace lemma for nilpotent perturbation of identity
For any 3×3 integer matrix N with N³ = 0 and tr(N) = 0 and tr(N²) = 0,
we have tr((I + N)ⁿ) = 3 for all n.] -/
theorem trace_Nsq_mul_pow (N : Matrix (Fin 3) (Fin 3) ℤ) (hN3 : N ^ 3 = 0)
    (n : ℕ) : Matrix.trace (N ^ 2 * (1 + N) ^ n) = Matrix.trace (N ^ 2) := by
  induction n <;> simp_all +decide [ pow_succ', mul_add, add_mul ];
  simp_all +decide [ ← mul_assoc ]


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


/-- **tr(B₁ⁿ) = 3 for ALL n.** Previously verified only for n=1..5. -/
theorem trace_BTA₁_pow (n : ℕ) : Matrix.trace (BTA₁ ^ n) = 3 := by
  rw [BTA₁_eq]
  exact trace_one_add_nilp_pow NTA₁ NTA₁_cubed trace_NTA₁ trace_NTA₁_sq n


/-- **tr(B₃ⁿ) = 3 for ALL n.** -/
theorem trace_BTA₃_pow (n : ℕ) : Matrix.trace (BTA₃ ^ n) = 3 := by
  rw [BTA₃_eq]
  exact trace_one_add_nilp_pow NTA₃ NTA₃_cubed trace_NTA₃ trace_NTA₃_sq n


