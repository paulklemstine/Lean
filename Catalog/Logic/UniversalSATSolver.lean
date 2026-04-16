/-! # CatalogBuild.Logic.UniversalSATSolver

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 32
-/

import Mathlib

noncomputable section

/-- The tropical action (cost) for factoring: distance from N to the product a*b. -/
def factoringAction (N a b : ℕ) : ℕ := Int.natAbs (↑N - ↑a * ↑b)



/-- The tropical action is zero if and only if a * b = N. -/
theorem factoring_action_zero_iff (N a b : ℕ) :
    factoringAction N a b = 0 ↔ a * b = N := by
  simp only [factoringAction, Int.natAbs_eq_zero, sub_eq_zero]
  constructor
  · intro h; exact_mod_cast h.symm
  · intro h; push_cast; linarith



/-- Factoring verification: if we find a, b with a * b = N, the factorization is correct. -/
theorem factoring_verification_correct (N a b : ℕ) (h : a * b = N) :
    N = a * b := h.symm



/-- If (a, b) is a factorization of N, so is (b, a). -/
theorem factor_symmetry (N a b : ℕ) (h : a * b = N) : b * a = N := by
  rw [mul_comm]; exact h



/-- [Section: # CatalogBuild.Logic.UniversalSATSolver
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 32] -/
theorem nontrivial_factor_bound (N a b : ℕ) (hN : 1 < N) (hab : a * b = N)
    (ha : 1 < a) (hb : 1 < b) : a < N := by
  nlinarith



theorem factoring_action_triangle (N a b c : ℕ) :
    (Int.natAbs (↑N - ↑a * ↑b) : ℤ) ≤
    Int.natAbs (↑N - ↑a * ↑c) + Int.natAbs (↑a * ↑c - ↑a * ↑b) := by
  grind +ring

-- ============================================================================
-- PART II: SAT AS COST MINIMIZATION
-- ============================================================================



/-- A literal: a variable index and whether it appears positively. -/
structure SATLiteral (n : ℕ) where
  var : Fin n
  polarity : Bool



/-- Evaluate a literal under an assignment. -/
def SATLiteral.eval {n : ℕ} (l : SATLiteral n) (assignment : Fin n → Bool) : Bool :=
  if l.polarity then assignment l.var else !assignment l.var



/-- A clause is a disjunction of literals — satisfied if ANY literal is true. -/
def clauseSatisfied {n : ℕ} (clause : List (SATLiteral n)) (assignment : Fin n → Bool) : Bool :=
  clause.any (fun l => l.eval assignment)



/-- The SAT cost function: number of unsatisfied clauses. -/
def satCost {n : ℕ} (clauses : List (List (SATLiteral n))) (assignment : Fin n → Bool) : ℕ :=
  (clauses.filter (fun c => !clauseSatisfied c assignment)).length



theorem sat_cost_zero_iff {n : ℕ} (clauses : List (List (SATLiteral n)))
    (assignment : Fin n → Bool) :
    satCost clauses assignment = 0 ↔ ∀ c ∈ clauses, clauseSatisfied c assignment = true := by
  unfold satCost; aesop;



theorem satisfying_assignment_zero_cost {n : ℕ}
    (clauses : List (List (SATLiteral n))) (assignment : Fin n → Bool)
    (h : ∀ c ∈ clauses, clauseSatisfied c assignment = true) :
    satCost clauses assignment = 0 := by
  exact?



/-- The SAT cost is bounded above by the number of clauses. -/
theorem sat_cost_le_num_clauses {n : ℕ} (clauses : List (List (SATLiteral n)))
    (assignment : Fin n → Bool) :
    satCost clauses assignment ≤ clauses.length := by
  unfold satCost
  exact List.length_filter_le _ _

-- ============================================================================
-- PART III: ORACLE FIXED-POINT THEORY (The Mathematical Core)
-- ============================================================================



/-- An oracle is idempotent: O(O(x)) = O(x). -/
def IsOracleIdempotent {α : Type*} (O : α → α) : Prop := ∀ x, O (O x) = O x



/-- The fixed-point set (truths) of an oracle. -/
def OracleFixedPoints {α : Type*} (O : α → α) : Set α := {x | O x = x}



/-- For an idempotent oracle, the range equals the fixed-point set. -/
theorem oracle_idempotent_range_eq_fixedPoints {α : Type*} (O : α → α)
    (hO : IsOracleIdempotent O) :
    range O = OracleFixedPoints O := by
  ext x
  simp only [OracleFixedPoints, Set.mem_range, mem_setOf_eq]
  constructor
  · rintro ⟨y, rfl⟩; exact hO y
  · intro hx; exact ⟨x, hx⟩



/-- Every element in the range of an idempotent oracle is a fixed point. -/
theorem oracle_range_are_fixedPoints {α : Type*} (O : α → α)
    (hO : IsOracleIdempotent O) :
    ∀ y ∈ range O, O y = y := by
  rintro y ⟨x, rfl⟩
  exact hO x



/-- Composing two commuting idempotent oracles yields an idempotent oracle. -/
theorem compose_commuting_oracles {α : Type*} (O₁ O₂ : α → α)
    (h₁ : IsOracleIdempotent O₁) (h₂ : IsOracleIdempotent O₂)
    (hcomm : ∀ x, O₁ (O₂ x) = O₂ (O₁ x)) :
    IsOracleIdempotent (O₁ ∘ O₂) := by
  intro x
  simp only [comp]
  calc O₁ (O₂ (O₁ (O₂ x)))
      = O₁ (O₁ (O₂ (O₂ x))) := by rw [hcomm (O₂ x)]
    _ = O₁ (O₂ (O₂ x)) := by rw [h₁]
    _ = O₁ (O₂ x) := by rw [h₂]



theorem compose_oracle_fixedPoints {α : Type*} (O₁ O₂ : α → α)
    (h₁ : IsOracleIdempotent O₁) (h₂ : IsOracleIdempotent O₂)
    (hcomm : ∀ x, O₁ (O₂ x) = O₂ (O₁ x)) :
    OracleFixedPoints (O₁ ∘ O₂) = OracleFixedPoints O₁ ∩ OracleFixedPoints O₂ := by
  ext x; exact ⟨fun hx => by
    simp_all +decide [ IsOracleIdempotent, OracleFixedPoints ];
    grind +ring, by
    unfold OracleFixedPoints; aesop;⟩;



/-- The Metropolis acceptance criterion: accept if the new cost is lower,
or with probability exp(-Δ/T) if higher. This is the core of SA. -/
def metropolisAccepts (currentCost newCost : ℝ) (temperature : ℝ) (randomVal : ℝ) : Prop :=
  newCost ≤ currentCost ∨
    (0 < temperature ∧ randomVal < Real.exp (-(newCost - currentCost) / temperature))



/-- Improvements are always accepted by the Metropolis criterion. -/
theorem metropolis_always_accepts_improvement (c_old c_new T r : ℝ) (h : c_new ≤ c_old) :
    metropolisAccepts c_old c_new T r := by
  left; exact h



/-- At zero temperature, only improvements are accepted (greedy descent). -/
theorem metropolis_zero_temp_greedy (c_old c_new : ℝ) (r : ℝ) (hr : 0 < r)
    (h_worse : c_old < c_new) :
    ¬metropolisAccepts c_old c_new 0 r := by
  intro h
  rcases h with h1 | ⟨h2, _⟩
  · linarith
  · linarith



theorem metropolis_monotone_acceptance (c_old c1 c2 T : ℝ) (hT : 0 < T)
    (h12 : c1 ≤ c2) :
    Real.exp (-(c2 - c_old) / T) ≤ Real.exp (-(c1 - c_old) / T) := by
  gcongr

-- ============================================================================
-- PART V: BIT-VECTOR SEARCH SPACE
-- ============================================================================



/-- Convert a bit-vector (list of bools) to a natural number (big-endian). -/
def bitsToNat : List Bool → ℕ
  | [] => 0
  | b :: bs => (if b then 1 else 0) * 2 ^ bs.length + bitsToNat bs



theorem bitsToNat_lt_pow (bits : List Bool) :
    bitsToNat bits < 2 ^ bits.length := by
  induction' bits with b bits ih <;> simp +arith +decide [ *, pow_succ' ];
  norm_num [ bitsToNat ];
  split_ifs <;> linarith



/-- The search space for n-bit factor pairs has size 2^(2n). -/
theorem search_space_size (n : ℕ) :
    Fintype.card (Fin (2^n) × Fin (2^n)) = 2 ^ (2 * n) := by
  simp [Fintype.card_prod, Fintype.card_fin, ← pow_add, two_mul]

-- ============================================================================
-- PART VI: COMPLEXITY AND VERIFICATION
-- ============================================================================



theorem composite_has_nontrivial_factors (N : ℕ) (hN : 1 < N) (hc : ¬ Nat.Prime N) :
    ∃ a b, 1 < a ∧ 1 < b ∧ a * b = N := by
  rcases Nat.exists_dvd_of_not_prime2 hN hc with ⟨ k, hk₁, hk₂ ⟩ ; exact ⟨ k, N / k, by nlinarith, by nlinarith [ Nat.div_mul_cancel hk₁ ], by rw [ Nat.mul_div_cancel' hk₁ ] ⟩



/-- The number of bits needed to represent N is ⌈log₂(N+1)⌉. -/
theorem bits_needed (N : ℕ) (hN : 0 < N) :
    N < 2 ^ (Nat.log 2 N + 1) := by
  exact Nat.lt_pow_succ_log_self (by norm_num : 1 < 2) N



theorem prime_or_composite (N : ℕ) (hN : 2 ≤ N) :
    Nat.Prime N ∨ ∃ a b, 1 < a ∧ 1 < b ∧ a * b = N := by
  exact Classical.or_iff_not_imp_left.2 fun h => by rcases Nat.exists_dvd_of_not_prime2 hN h with ⟨ a, ha₁, ha₂ ⟩ ; exact ⟨ a, N / a, by nlinarith, by nlinarith [ Nat.div_mul_cancel ha₁ ], by rw [ mul_comm, Nat.div_mul_cancel ha₁ ] ⟩ ;

-- ============================================================================
-- PART VII: COOLING SCHEDULE PROPERTIES
-- ============================================================================



/-- Geometric cooling: T_k = T₀ · α^k. -/
def geometricTemp (T₀ α : ℝ) (k : ℕ) : ℝ := T₀ * α ^ k



theorem geometric_cooling_converges (T₀ : ℝ) (α : ℝ) (hT : 0 < T₀)
    (hα1 : 0 < α) (hα2 : α < 1) :
    Filter.Tendsto (geometricTemp T₀ α) Filter.atTop (nhds 0) := by
  simpa using tendsto_pow_atTop_nhds_zero_of_lt_one ( by linarith ) hα2 |> Filter.Tendsto.const_mul T₀



/-- The temperature is always positive under geometric cooling. -/
theorem geometric_temp_pos (T₀ α : ℝ) (hT : 0 < T₀) (hα : 0 < α) (k : ℕ) :
    0 < geometricTemp T₀ α k := by
  unfold geometricTemp
  exact mul_pos hT (pow_pos hα k)



end
