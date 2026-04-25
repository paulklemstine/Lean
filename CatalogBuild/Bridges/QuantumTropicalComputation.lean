/-! # CatalogBuild.Bridges.QuantumTropicalComputation

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 30
-/

import Mathlib

noncomputable section

/-- Boolean OR is idempotent (the tropical property). -/
theorem bool_or_idempotent (a : Bool) : (a || a) = a := Bool.or_self a


/-- Boolean AND distributes over OR. -/
theorem bool_and_distrib_or (a b c : Bool) :
    (a && (b || c)) = ((a && b) || (a && c)) := Bool.and_or_distrib_left a b c


/-- A qubit state: pair of complex amplitudes with |α|² + |β|² = 1. -/
structure Qubit where
  alpha : ℂ
  beta : ℂ
  normalized : Complex.normSq alpha + Complex.normSq beta = 1


/-- The |0⟩ state. -/
def qubit0 : Qubit where
  alpha := 1; beta := 0
  normalized := by simp [Complex.normSq_one, Complex.normSq_zero]


/-- The |1⟩ state. -/
def qubit1 : Qubit where
  alpha := 0; beta := 1
  normalized := by simp [Complex.normSq_one, Complex.normSq_zero]


/-- Born rule: probability of measuring |0⟩. -/
def probZero (q : Qubit) : ℝ := Complex.normSq q.alpha


/-- Born rule: probability of measuring |1⟩. -/
def probOne (q : Qubit) : ℝ := Complex.normSq q.beta


/-- Born probabilities sum to 1. -/
theorem born_probabilities_sum (q : Qubit) :
    probZero q + probOne q = 1 := q.normalized


/-- Born probabilities are non-negative. -/
theorem born_prob_nonneg (q : Qubit) :
    0 ≤ probZero q ∧ 0 ≤ probOne q :=
  ⟨Complex.normSq_nonneg _, Complex.normSq_nonneg _⟩


/-- |0⟩ always measures as 0. -/
theorem qubit0_deterministic : probZero qubit0 = 1 := by
  simp [probZero, qubit0, Complex.normSq_one]


/-- |1⟩ never measures as 0. -/
theorem qubit1_opposite : probZero qubit1 = 0 := by
  simp [probZero, qubit1, Complex.normSq_zero]


/-- The Hadamard coefficient: 1/√2. -/
def hadamardCoeff : ℝ := 1 / Real.sqrt 2


/-- [Section: # CatalogBuild.Bridges.QuantumTropicalComputation
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 30] -/
theorem hadamard_creates_equal_superposition :
    hadamardCoeff ^ 2 + hadamardCoeff ^ 2 = 1 := by
  norm_num [ hadamardCoeff ]


/-- Tropical inner product: ⟨x, y⟩_trop = max_i(xᵢ + yᵢ). -/
def tropicalInnerProduct2 (x₁ x₂ y₁ y₂ : ℝ) : ℝ :=
  max (x₁ + y₁) (x₂ + y₂)


/-- Tropical inner product is commutative. -/
theorem tropical_inner_comm (x₁ x₂ y₁ y₂ : ℝ) :
    tropicalInnerProduct2 x₁ x₂ y₁ y₂ = tropicalInnerProduct2 y₁ y₂ x₁ x₂ := by
  simp only [tropicalInnerProduct2]
  rw [add_comm x₁ y₁, add_comm x₂ y₂, max_comm]


/-- [Section: # CatalogBuild.Bridges.QuantumTropicalComputation
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 30] -/
theorem tropical_cauchy_schwarz (x₁ x₂ y₁ y₂ : ℝ) :
    tropicalInnerProduct2 x₁ x₂ y₁ y₂ ≤
    max (2 * x₁) (2 * x₂) / 2 + max (2 * y₁) (2 * y₂) / 2 := by
  unfold tropicalInnerProduct2;
  cases max_cases ( x₁ + y₁ ) ( x₂ + y₂ ) <;> cases max_cases ( 2 * x₁ ) ( 2 * x₂ ) <;> cases max_cases ( 2 * y₁ ) ( 2 * y₂ ) <;> linarith


/-- Boolean → Tropical embedding. -/
def boolToTropical (b : Bool) : ℝ := if b then 0 else -1


/-- The embedding preserves OR = tropical max. -/
theorem bool_tropical_or (a b : Bool) :
    boolToTropical (a || b) = max (boolToTropical a) (boolToTropical b) := by
  cases a <;> cases b <;> simp [boolToTropical]


/-- Tropical → Quantum embedding: x ↦ exp(x). -/
def tropicalToQuantum (x : ℝ) : ℝ := Real.exp x


/-- The embedding is monotone. -/
theorem tropical_quantum_monotone : Monotone tropicalToQuantum :=
  fun _ _ h => Real.exp_le_exp.2 h


/-- The embedding is positive. -/
theorem tropical_quantum_positive (x : ℝ) : 0 < tropicalToQuantum x :=
  Real.exp_pos x


/-- Grover's quantum speedup: √N < N for N ≥ 4. -/
theorem grover_speedup (N : ℕ) (hN : 4 ≤ N) : Nat.sqrt N < N := by
  exact Nat.sqrt_lt_self (by omega)


/-- For N = 4, √N = 2. -/
theorem grover_n4_exact : Nat.sqrt 4 = 2 := by native_decide


/-- The Maslov deformation: a ⊕_ε b = ε · log(exp(a/ε) + exp(b/ε)). -/
def maslovDeform (eps : ℝ) (a b : ℝ) : ℝ :=
  eps * Real.log (Real.exp (a / eps) + Real.exp (b / eps))


/-- Maslov deformation is commutative. -/
theorem maslov_comm' (eps a b : ℝ) :
    maslovDeform eps a b = maslovDeform eps b a := by
  simp [maslovDeform, add_comm]


/-- At ε = 1, Maslov deformation = LogSumExp. -/
theorem maslov_unit (a b : ℝ) :
    maslovDeform 1 a b = Real.log (Real.exp a + Real.exp b) := by
  simp [maslovDeform]


/-- Classical repetition code: majority vote. -/
def majorityVote3 (b₁ b₂ b₃ : Bool) : Bool :=
  (b₁ && b₂) || (b₂ && b₃) || (b₁ && b₃)


/-- Majority vote corrects single errors (true case). -/
theorem majority_corrects_single_error_true :
    majorityVote3 true true false = true ∧
    majorityVote3 true false true = true ∧
    majorityVote3 false true true = true := by simp [majorityVote3]


/-- Majority vote corrects single errors (false case). -/
theorem majority_corrects_single_error_false :
    majorityVote3 false false true = false ∧
    majorityVote3 false true false = false ∧
    majorityVote3 true false false = false := by simp [majorityVote3]


/-- No errors → correct output. -/
theorem majority_no_error (b : Bool) :
    majorityVote3 b b b = b := by cases b <;> simp [majorityVote3]


end
