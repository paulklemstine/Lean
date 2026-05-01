/-! # CatalogBuild.Algebra.IntegerEnergy.BerggrenTraceFormula

Auto-generated from theorem catalog database.
Domain: Algebra/IntegerEnergy
Declarations: 13
-/

import Mathlib

/-- [Section: ## Section 1: Pell Sequence (self-contained)] -/
def pellXt : ℕ → ℤ
  | 0 => 1
  | 1 => 3
  | n + 2 => 6 * pellXt (n + 1) - pellXt n

@[simp] theorem pellXt_0 : pellXt 0 = 1 := rfl
@[simp] theorem pellXt_1 : pellXt 1 = 3 := rfl


/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenTraceFormula
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 13] -/
theorem pellXt_rec (n : ℕ) : pellXt (n + 2) = 6 * pellXt (n + 1) - pellXt n := rfl


/-- [Section: ## Section 2: The Target Sequence f(n) = 2·pellX(n) + (-1)ⁿ] -/
def traceTarget (n : ℕ) : ℤ := 2 * pellXt n + (-1 : ℤ) ^ n


theorem traceTarget_0 : traceTarget 0 = 3 := by simp [traceTarget]


theorem traceTarget_1 : traceTarget 1 = 5 := by simp [traceTarget]


theorem traceTarget_2 : traceTarget 2 = 35 := by
  simp [traceTarget]; native_decide


/-- traceTarget satisfies the recurrence f(n+3) = 5f(n+2) + 5f(n+1) - f(n) -/
theorem traceTarget_recurrence (n : ℕ) :
    traceTarget (n + 3) = 5 * traceTarget (n + 2) + 5 * traceTarget (n + 1) - traceTarget n := by
  simp only [traceTarget]
  have h1 : pellXt (n + 3) = 6 * pellXt (n + 2) - pellXt (n + 1) := pellXt_rec (n + 1)
  have h2 : pellXt (n + 2) = 6 * pellXt (n + 1) - pellXt n := pellXt_rec n
  rw [h1, h2]; ring


/-- [Section: ## Section 4: B₂ Matrix] -/
def BN₂t : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]


/-- [Section: ## Section 5: Cayley-Hamilton for B₂] -/
theorem BN₂t_cayley_hamilton : BN₂t ^ 3 = 5 • BN₂t ^ 2 + 5 • BN₂t - 1 := by
  native_decide


/-- From Cayley-Hamilton: tr(B₂^(n+3)) = 5·tr(B₂^(n+2)) + 5·tr(B₂^(n+1)) - tr(B₂^n) -/
theorem BN₂t_trace_rec (n : ℕ) :
    trace (BN₂t ^ (n + 3)) = 5 * trace (BN₂t ^ (n + 2)) +
      5 * trace (BN₂t ^ (n + 1)) - trace (BN₂t ^ n) := by
  have ch : BN₂t ^ 3 = 5 • BN₂t ^ 2 + 5 • BN₂t - 1 := BN₂t_cayley_hamilton
  have key : BN₂t ^ (n + 3) = 5 • BN₂t ^ (n + 2) + 5 • BN₂t ^ (n + 1) - BN₂t ^ n := by
    have : BN₂t ^ (n + 3) = BN₂t ^ n * BN₂t ^ 3 := by rw [pow_add]
    rw [this, ch]
    have h2 : BN₂t ^ n * BN₂t ^ 2 = BN₂t ^ (n + 2) := by rw [← pow_add]
    have h3 : BN₂t ^ n * BN₂t ^ 1 = BN₂t ^ (n + 1) := by rw [← pow_add]
    have h4 : BN₂t ^ n * (5 • BN₂t ^ 2 + 5 • BN₂t - 1) =
              5 • (BN₂t ^ n * BN₂t ^ 2) + 5 • (BN₂t ^ n * BN₂t ^ 1) - BN₂t ^ n := by
      noncomm_ring
    rw [h4, h2, h3]
  rw [key, Matrix.trace_sub, Matrix.trace_add, Matrix.trace_smul,
      Matrix.trace_smul]
  simp


/-- **Main Theorem**: tr(B₂ⁿ) = 2·pellX(n) + (-1)ⁿ for all n ∈ ℕ -/
theorem traceB2_eq_pellX (n : ℕ) :
    trace (BN₂t ^ n) = 2 * pellXt n + (-1 : ℤ) ^ n := by
  induction n using Nat.strongRecOn with
  | ind n ih =>
  match n with
  | 0 => native_decide
  | 1 => native_decide
  | 2 => native_decide
  | n + 3 =>
    rw [BN₂t_trace_rec]
    rw [ih (n + 2) (by omega), ih (n + 1) (by omega), ih n (by omega)]
    have h1 : pellXt (n + 3) = 6 * pellXt (n + 2) - pellXt (n + 1) := rfl
    have h2 : pellXt (n + 2) = 6 * pellXt (n + 1) - pellXt n := rfl
    rw [h1, h2]; ring


/-- [Section: ## Section 8: Corollaries] -/
theorem BN₂t_trace_pos (n : ℕ) : 0 < trace (BN₂t ^ n) := by
  -- From traceB2_eq_pellX, we have $trace (BN₂t ^ n) = 2 * pellXt n + (-1 : ℤ) ^ n$.
  have h_trace : trace (BN₂t ^ n) = 2 * pellXt n + (-1 : ℤ) ^ n := by
    exact?;
  -- By induction, we can show that $pellXt n \geq 1$ for all $n$.
  have h_pell_pos : ∀ n, 1 ≤ pellXt n := by
    -- We'll use induction to prove that the Pell sequence is positive.
    have h_pell_pos_induction : ∀ n, 1 ≤ pellXt n ∧ pellXt n ≤ pellXt (n + 1) := by
      intro n; induction n <;> simp_all +decide [ pellXt_rec ] ; omega;
    exact fun n => h_pell_pos_induction n |>.1;
  by_cases h : Even n <;> simp_all +decide ; linarith [ h_pell_pos n ];
  linarith [ h_pell_pos n ]


theorem BN₂t_trace_odd (n : ℕ) : trace (BN₂t ^ n) % 2 = 1 := by
  rw [ traceB2_eq_pellX ];
  cases Nat.even_or_odd n <;> simp +decide [ *, Int.add_emod, Int.mul_emod ]

