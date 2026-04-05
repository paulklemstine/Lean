import Mathlib

/-!
# Universal SAT Solver via Oracle Fixed-Point Theory

## Overview

We formalize the mathematical backbone of the "Universal Oracle Consulting Problem Solver"
(UOCPS) applied to Boolean satisfiability and integer factoring. The key ideas:

1. **SAT as Fixed-Point Search**: A SAT instance φ over n variables defines a landscape
   function `cost : (Fin n → Bool) → ℕ` counting unsatisfied clauses. A satisfying
   assignment is a zero of this cost — equivalently, a fixed point of the "projection to
   nearest satisfying assignment" oracle.

2. **Factoring as Tropical Optimization**: Integer factoring N = a × b can be viewed as
   minimizing the tropical action `|N - a * b|` over pairs (a, b). A zero of this action
   is a valid factorization.

3. **Oracle Idempotency**: Any projection operator O with O² = O has the property that
   its range equals its fixed-point set. This gives a universal algebraic framework for
   "consulting an oracle" — the answer is stable under re-consultation.

4. **Verification is Easy**: Even when finding a solution is hard, VERIFYING that a
   candidate (a, b) satisfies a * b = N is trivial (polynomial time). This verification
   step is what we can rigorously formalize and prove correct.

## Main Results

- `factoring_action_zero_iff`: The tropical action is zero iff we have a valid factorization
- `sat_cost_zero_iff`: Zero cost iff all clauses are satisfied
- `oracle_idempotent_range_eq_fixedPoints`: Fixed points = range for idempotent maps
- `simulated_annealing_invariant`: The SA acceptance criterion preserves the search invariant
- `nontrivial_factor_bound`: Nontrivial factors satisfy 1 < a ∧ a < N
- `factor_symmetry`: If (a, b) is a factorization, so is (b, a)
-/

noncomputable section

open Finset Function Set BigOperators

-- ============================================================================
-- PART I: FACTORING AS TROPICAL ACTION MINIMIZATION
-- ============================================================================

/-! ## The Tropical Action for Factoring

The "tropical action" (cost function) for the factoring problem is
  S(a, b) = |N - a * b|
A valid factorization is a zero of this action.
-/

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

/-
PROBLEM
A nontrivial factor of N satisfies a < N when b > 1.

PROVIDED SOLUTION
Since a > 1 and b > 1, a * b ≥ 2a > a. But a * b = N, so a < N.
-/
theorem nontrivial_factor_bound (N a b : ℕ) (hN : 1 < N) (hab : a * b = N)
    (ha : 1 < a) (hb : 1 < b) : a < N := by
  nlinarith

/-
PROBLEM
The tropical action satisfies the triangle inequality variant:
    |N - a*b| ≤ |N - a*c| + |a*c - a*b|

PROVIDED SOLUTION
This follows from the integer triangle inequality |a - c| ≤ |a - b| + |b - c| applied with a = N, b = a*c, c = a*b as integers. Use Int.natAbs_sub_le or similar.
-/
theorem factoring_action_triangle (N a b c : ℕ) :
    (Int.natAbs (↑N - ↑a * ↑b) : ℤ) ≤
    Int.natAbs (↑N - ↑a * ↑c) + Int.natAbs (↑a * ↑c - ↑a * ↑b) := by
  grind +ring

-- ============================================================================
-- PART II: SAT AS COST MINIMIZATION
-- ============================================================================

/-! ## Boolean Satisfiability

A SAT instance is a list of clauses, each clause a list of literals.
A literal is a variable index paired with a polarity (positive or negative).
The cost function counts unsatisfied clauses.
-/

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

/-
PROBLEM
The SAT cost is zero if and only if every clause is satisfied.

PROVIDED SOLUTION
satCost counts elements where !clauseSatisfied. This is zero iff filter produces empty list, iff every clause c in clauses has clauseSatisfied c assignment = true. Use List.filter properties and Bool negation.
-/
theorem sat_cost_zero_iff {n : ℕ} (clauses : List (List (SATLiteral n)))
    (assignment : Fin n → Bool) :
    satCost clauses assignment = 0 ↔ ∀ c ∈ clauses, clauseSatisfied c assignment = true := by
  unfold satCost; aesop;

/-
PROBLEM
An assignment that satisfies all clauses achieves zero cost.

PROVIDED SOLUTION
Direct consequence of sat_cost_zero_iff (backward direction).
-/
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

/-! ## Idempotent Oracle Framework

The universal oracle framework: an oracle is an idempotent map O : α → α.
Its fixed points are the "truths" — consulting the oracle twice yields the
same answer as consulting once.
-/

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

/-
PROBLEM
The fixed points of a composition of commuting oracles is the intersection.

PROVIDED SOLUTION
x is a fixed point of O₁ ∘ O₂ iff O₁(O₂(x)) = x. Forward: if O₁(O₂(x))=x, apply O₂ to get O₂(O₁(O₂(x)))=O₂(x), by commutativity O₁(O₂(O₂(x)))=O₂(x), by idempotency of O₂ we get O₁(O₂(x))=O₂(x), combined with O₁(O₂(x))=x gives O₂(x)=x. Then O₁(x)=O₁(O₂(x))=x. Backward: if O₁(x)=x and O₂(x)=x then O₁(O₂(x))=O₁(x)=x.
-/
theorem compose_oracle_fixedPoints {α : Type*} (O₁ O₂ : α → α)
    (h₁ : IsOracleIdempotent O₁) (h₂ : IsOracleIdempotent O₂)
    (hcomm : ∀ x, O₁ (O₂ x) = O₂ (O₁ x)) :
    OracleFixedPoints (O₁ ∘ O₂) = OracleFixedPoints O₁ ∩ OracleFixedPoints O₂ := by
  ext x; exact ⟨fun hx => by
    simp_all +decide [ IsOracleIdempotent, OracleFixedPoints ];
    grind +ring, by
    unfold OracleFixedPoints; aesop;⟩;

/-- The identity is an idempotent oracle (the trivial oracle that always agrees). -/
theorem id_is_oracle {α : Type*} : IsOracleIdempotent (id : α → α) := by
  intro x; rfl

/-- A constant function is an idempotent oracle. -/
theorem const_is_oracle {α : Type*} (c : α) :
    IsOracleIdempotent (fun _ => c) := by
  intro _; rfl

-- ============================================================================
-- PART IV: SIMULATED ANNEALING FRAMEWORK
-- ============================================================================

/-! ## Simulated Annealing Properties

The Python implementation uses simulated annealing to search for factorizations.
We formalize the key invariant: the acceptance criterion ensures that the algorithm
always accepts improvements and probabilistically accepts worse states.
-/

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

/-
PROBLEM
The Metropolis acceptance probability is monotone: lower cost ⟹ higher acceptance.

PROVIDED SOLUTION
exp is monotone and -(c2-c_old)/T ≤ -(c1-c_old)/T since c1 ≤ c2 and T > 0. Use Real.exp_le_exp and div_le_div_of_nonneg_right or similar.
-/
theorem metropolis_monotone_acceptance (c_old c1 c2 T : ℝ) (hT : 0 < T)
    (h12 : c1 ≤ c2) :
    Real.exp (-(c2 - c_old) / T) ≤ Real.exp (-(c1 - c_old) / T) := by
  gcongr

-- ============================================================================
-- PART V: BIT-VECTOR SEARCH SPACE
-- ============================================================================

/-! ## Bit-Vector Encoding

The Python code represents candidate factors as bit-vectors.
We formalize the encoding and its properties.
-/

/-- Convert a bit-vector (list of bools) to a natural number (big-endian). -/
def bitsToNat : List Bool → ℕ
  | [] => 0
  | b :: bs => (if b then 1 else 0) * 2 ^ bs.length + bitsToNat bs

/-
PROBLEM
An n-bit number is less than 2^n.

PROVIDED SOLUTION
By induction on bits. Base: 0 < 1 = 2^0. Step: bitsToNat (b::bs) = (0 or 1)*2^|bs| + bitsToNat bs < 2^|bs| + 2^|bs| = 2^(|bs|+1).
-/
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

/-! ## The Fundamental Asymmetry: Searching vs Verifying

The key insight: VERIFICATION of a solution is computationally easy (polynomial),
even when FINDING the solution is hard. This is the P vs NP gap.
-/

/-
PROBLEM
If N > 1 is composite, it has a nontrivial factorization.

PROVIDED SOLUTION
Use Nat.exists_prime_and_dvd or minFac. Since N > 1 and not prime, N.minFac divides N and 1 < N.minFac. Let b = N/minFac. Then minFac * b = N and b > 1 since minFac < N. Use Nat.minFac_prime, Nat.minFac_dvd, Nat.div_pos.
-/
theorem composite_has_nontrivial_factors (N : ℕ) (hN : 1 < N) (hc : ¬ Nat.Prime N) :
    ∃ a b, 1 < a ∧ 1 < b ∧ a * b = N := by
  rcases Nat.exists_dvd_of_not_prime2 hN hc with ⟨ k, hk₁, hk₂ ⟩ ; exact ⟨ k, N / k, by nlinarith, by nlinarith [ Nat.div_mul_cancel hk₁ ], by rw [ Nat.mul_div_cancel' hk₁ ] ⟩

/-- The number of bits needed to represent N is ⌈log₂(N+1)⌉. -/
theorem bits_needed (N : ℕ) (hN : 0 < N) :
    N < 2 ^ (Nat.log 2 N + 1) := by
  exact Nat.lt_pow_succ_log_self (by norm_num : 1 < 2) N

/-
PROBLEM
Every natural number ≥ 2 is either prime or has a nontrivial factor.

PROVIDED SOLUTION
By cases on Nat.Prime N. If prime, left. If not prime, use composite_has_nontrivial_factors with hN (2 ≤ N implies 1 < N).
-/
theorem prime_or_composite (N : ℕ) (hN : 2 ≤ N) :
    Nat.Prime N ∨ ∃ a b, 1 < a ∧ 1 < b ∧ a * b = N := by
  exact Classical.or_iff_not_imp_left.2 fun h => by rcases Nat.exists_dvd_of_not_prime2 hN h with ⟨ a, ha₁, ha₂ ⟩ ; exact ⟨ a, N / a, by nlinarith, by nlinarith [ Nat.div_mul_cancel ha₁ ], by rw [ mul_comm, Nat.div_mul_cancel ha₁ ] ⟩ ;

-- ============================================================================
-- PART VII: COOLING SCHEDULE PROPERTIES
-- ============================================================================

/-! ## Geometric Cooling

The Python implementation uses geometric cooling: T_{k+1} = α · T_k where α < 1.
We prove that this converges to zero.
-/

/-- Geometric cooling: T_k = T₀ · α^k. -/
def geometricTemp (T₀ α : ℝ) (k : ℕ) : ℝ := T₀ * α ^ k

/-
PROBLEM
Geometric cooling converges to zero when 0 < α < 1.

PROVIDED SOLUTION
geometricTemp T₀ α k = T₀ * α^k. Since 0 < α < 1, α^k → 0 as k → ∞. Use tendsto_pow_atTop_nhds_zero_of_lt_one (or similar) and Filter.Tendsto.const_mul.
-/
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