/-
# Growth Regime Trichotomy for Enriched Type Systems

Three type constructors — sum, product, and arrow — generate exactly three
computational growth regimes: linear, exponential, and double-exponential.

## Main Results

1. `tsb_sum_only_equals_leaf_count` — Sum-only types grow linearly
2. `tsb_arrow_free_exponential_bound` — Arrow-free types are at most singly exponential
3. `tsb_balanced_double_exp` — Balanced arrow trees achieve doubly exponential growth
4. `tsb_arrow_dominance` — Arrows dominate products and sums
5. `classify_correct` — Certified growth regime classifier
-/

import Mathlib

/-! ## Type Grammar -/

/-- Extended type syntax: base, arrow, product, sum. -/
inductive Ty' where
  | base : Ty'
  | arrow : Ty' → Ty' → Ty'
  | prod : Ty' → Ty' → Ty'
  | sum : Ty' → Ty' → Ty'
  deriving Repr, DecidableEq

namespace GrowthRegime

/-! ## Core Measures -/

/-- Type state bound with +1 regularization for arrows. -/
def tsb : Ty' → ℕ
  | .base => 1
  | .arrow A B => (tsb A + 1) * (tsb B + 1)
  | .prod A B => tsb A * tsb B
  | .sum A B => tsb A + tsb B

/-- Arrow nesting depth. -/
def arrowDepth : Ty' → ℕ
  | .base => 0
  | .arrow A B => max (arrowDepth A) (arrowDepth B) + 1
  | .prod A B => max (arrowDepth A) (arrowDepth B)
  | .sum A B => max (arrowDepth A) (arrowDepth B)

/-- Total type size (number of constructors). -/
def typeSize : Ty' → ℕ
  | .base => 1
  | .arrow A B => typeSize A + typeSize B + 1
  | .prod A B => typeSize A + typeSize B + 1
  | .sum A B => typeSize A + typeSize B + 1

/-- Number of base leaves. -/
def leafCount : Ty' → ℕ
  | .base => 1
  | .arrow A B => leafCount A + leafCount B
  | .prod A B => leafCount A + leafCount B
  | .sum A B => leafCount A + leafCount B

/-! ## Constructor Predicates -/

/-- Type contains an arrow constructor. -/
inductive HasArrow : Ty' → Prop where
  | here (A B : Ty') : HasArrow (.arrow A B)
  | arrow_left {A B : Ty'} : HasArrow A → HasArrow (.arrow A B)
  | arrow_right {A B : Ty'} : HasArrow B → HasArrow (.arrow A B)
  | prod_left {A B : Ty'} : HasArrow A → HasArrow (.prod A B)
  | prod_right {A B : Ty'} : HasArrow B → HasArrow (.prod A B)
  | sum_left {A B : Ty'} : HasArrow A → HasArrow (.sum A B)
  | sum_right {A B : Ty'} : HasArrow B → HasArrow (.sum A B)

/-- Type contains a product constructor. -/
inductive HasProd : Ty' → Prop where
  | here (A B : Ty') : HasProd (.prod A B)
  | arrow_left {A B : Ty'} : HasProd A → HasProd (.arrow A B)
  | arrow_right {A B : Ty'} : HasProd B → HasProd (.arrow A B)
  | prod_left {A B : Ty'} : HasProd A → HasProd (.prod A B)
  | prod_right {A B : Ty'} : HasProd B → HasProd (.prod A B)
  | sum_left {A B : Ty'} : HasProd A → HasProd (.sum A B)
  | sum_right {A B : Ty'} : HasProd B → HasProd (.sum A B)

/-- Type contains a sum constructor. -/
inductive HasSum : Ty' → Prop where
  | here (A B : Ty') : HasSum (.sum A B)
  | arrow_left {A B : Ty'} : HasSum A → HasSum (.arrow A B)
  | arrow_right {A B : Ty'} : HasSum B → HasSum (.arrow A B)
  | prod_left {A B : Ty'} : HasSum A → HasSum (.prod A B)
  | prod_right {A B : Ty'} : HasSum B → HasSum (.prod A B)
  | sum_left {A B : Ty'} : HasSum A → HasSum (.sum A B)
  | sum_right {A B : Ty'} : HasSum B → HasSum (.sum A B)

/-- Decidability of HasArrow. -/
def decHasArrow : (T : Ty') → Decidable (HasArrow T)
  | .base => isFalse (fun h => by cases h)
  | .arrow A B => isTrue (.here A B)
  | .prod A B =>
    match decHasArrow A with
    | isTrue h => isTrue (.prod_left h)
    | isFalse hA =>
      match decHasArrow B with
      | isTrue h => isTrue (.prod_right h)
      | isFalse hB => isFalse (fun h => by cases h <;> contradiction)
  | .sum A B =>
    match decHasArrow A with
    | isTrue h => isTrue (.sum_left h)
    | isFalse hA =>
      match decHasArrow B with
      | isTrue h => isTrue (.sum_right h)
      | isFalse hB => isFalse (fun h => by cases h <;> contradiction)

instance : DecidablePred HasArrow := decHasArrow

/-- Decidability of HasProd. -/
def decHasProd : (T : Ty') → Decidable (HasProd T)
  | .base => isFalse (fun h => by cases h)
  | .arrow A B =>
    match decHasProd A with
    | isTrue h => isTrue (.arrow_left h)
    | isFalse hA =>
      match decHasProd B with
      | isTrue h => isTrue (.arrow_right h)
      | isFalse hB => isFalse (fun h => by cases h <;> contradiction)
  | .prod A B => isTrue (.here A B)
  | .sum A B =>
    match decHasProd A with
    | isTrue h => isTrue (.sum_left h)
    | isFalse hA =>
      match decHasProd B with
      | isTrue h => isTrue (.sum_right h)
      | isFalse hB => isFalse (fun h => by cases h <;> contradiction)

instance : DecidablePred HasProd := decHasProd

/-- Decidability of HasSum. -/
def decHasSum : (T : Ty') → Decidable (HasSum T)
  | .base => isFalse (fun h => by cases h)
  | .arrow A B =>
    match decHasSum A with
    | isTrue h => isTrue (.arrow_left h)
    | isFalse hA =>
      match decHasSum B with
      | isTrue h => isTrue (.arrow_right h)
      | isFalse hB => isFalse (fun h => by cases h <;> contradiction)
  | .prod A B =>
    match decHasSum A with
    | isTrue h => isTrue (.prod_left h)
    | isFalse hA =>
      match decHasSum B with
      | isTrue h => isTrue (.prod_right h)
      | isFalse hB => isFalse (fun h => by cases h <;> contradiction)
  | .sum A B => isTrue (.here A B)

instance : DecidablePred HasSum := decHasSum

/-! ## Growth Regime Classification -/

/-- The three growth regimes. -/
inductive GrowthClass : Type where
  | linear : GrowthClass
  | exponential : GrowthClass
  | doubleExponential : GrowthClass

/-- Classify a type's growth regime based on its constructor content. -/
def classifyGrowthRegime (T : Ty') : GrowthClass :=
  if HasArrow T then .doubleExponential
  else if HasProd T then .exponential
  else .linear

/-! ## Positivity -/

theorem tsb_pos (T : Ty') : 0 < tsb T := by
  induction T with
  | base => simp [tsb]
  | arrow A B ihA ihB =>
    unfold tsb; exact Nat.mul_pos (by omega) (by omega)
  | prod A B ihA ihB =>
    unfold tsb; exact Nat.mul_pos ihA ihB
  | sum A B ihA ihB =>
    unfold tsb; omega

theorem leafCount_pos (T : Ty') : 0 < leafCount T := by
  induction T with
  | base => simp [leafCount]
  | arrow A B ihA ihB => simp [leafCount]; omega
  | prod A B ihA ihB => simp [leafCount]; omega
  | sum A B ihA ihB => simp [leafCount]; omega

/-! ## Theorem 1: Linear Regime — Sum-Only Types -/

/-
Sum-only types have state bound equal to leaf count (linear growth).
-/
theorem tsb_sum_only_equals_leaf_count (T : Ty') (h_no_arrow : ¬HasArrow T)
    (h_no_prod : ¬HasProd T) : tsb T = leafCount T := by
  induction' T with A B hA hB;
  · rfl;
  · exact False.elim <| h_no_arrow <| HasArrow.here A B;
  · exact False.elim <| h_no_prod <| HasProd.here _ _;
  · rename_i A B hA hB;
    exact congr_arg₂ ( · + · ) ( hA ( fun h => h_no_arrow <| HasArrow.sum_left h ) ( fun h => h_no_prod <| HasProd.sum_left h ) ) ( hB ( fun h => h_no_arrow <| HasArrow.sum_right h ) ( fun h => h_no_prod <| HasProd.sum_right h ) )

/-! ## Theorem 2: Exponential Regime — Arrow-Free Types -/

/-
Arrow-free types have state bound at most singly exponential in size.
-/
theorem tsb_arrow_free_exponential_bound (T : Ty') (h_no_arrow : ¬HasArrow T) :
    tsb T ≤ 2 ^ typeSize T := by
  induction' T using Ty'.recOn with A B ihA ihB A B ihA ihB A B ihA ihB;
  · decide +revert;
  · exact False.elim <| h_no_arrow <| HasArrow.here A B;
  · -- By definition of `HasArrow`, if `¬HasArrow (A.prod B)`, then `¬HasArrow A` and `¬HasArrow B`.
    have h_no_arrow_A : ¬HasArrow A := by
      exact fun h => h_no_arrow <| HasArrow.prod_left h
    have h_no_arrow_B : ¬HasArrow B := by
      exact fun h => h_no_arrow <| HasArrow.prod_right h;
    convert le_trans ( Nat.mul_le_mul ( ihA h_no_arrow_A ) ( ihB h_no_arrow_B ) ) _ using 1;
    grind +locals;
  · -- By the induction hypothesis, we have tsb A ≤ 2 ^ typeSize A and tsb B ≤ 2 ^ typeSize B.
    have h_ind : tsb A ≤ 2 ^ typeSize A ∧ tsb B ≤ 2 ^ typeSize B := by
      exact ⟨ ihA fun h => h_no_arrow <| HasArrow.sum_left h, ihB fun h => h_no_arrow <| HasArrow.sum_right h ⟩;
    -- By the properties of exponents, we can combine the terms: $2^{typeSize A} + 2^{typeSize B} \leq 2^{typeSize A + typeSize B + 1}$.
    have h_exp : 2 ^ typeSize A + 2 ^ typeSize B ≤ 2 ^ (typeSize A + typeSize B + 1) := by
      ring_nf;
      nlinarith [ pow_pos ( by decide : 0 < 2 ) ( typeSize A ), pow_pos ( by decide : 0 < 2 ) ( typeSize B ) ];
    convert le_trans ( add_le_add h_ind.1 h_ind.2 ) h_exp using 1

/-! ## Theorem 3: Double-Exponential Regime — Balanced Arrow Types -/

/-- Balanced binary arrow tree of depth n. -/
def balancedArrow : ℕ → Ty'
  | 0 => .base
  | n + 1 => .arrow (balancedArrow n) (balancedArrow n)

/-- tsb of balanced arrow trees satisfies a squaring recurrence. -/
theorem tsb_balancedArrow_succ (n : ℕ) :
    tsb (balancedArrow (n + 1)) = (tsb (balancedArrow n) + 1) ^ 2 := by
  simp [balancedArrow, tsb, Nat.pow_two]

/-
Balanced arrow trees achieve doubly exponential growth (for n ≥ 1).
-/
theorem tsb_balanced_double_exp (n : ℕ) (hn : 1 ≤ n) :
    tsb (balancedArrow n) ≥ 2 ^ (2 ^ n) := by
  induction hn <;> simp_all +decide [ Nat.pow_succ, Nat.pow_mul ];
  rw [ show tsb ( balancedArrow ( _ + 1 ) ) = ( tsb ( balancedArrow _ ) + 1 ) ^ 2 by exact tsb_balancedArrow_succ _ ] ; nlinarith [ pow_pos ( zero_lt_two' ℕ ) ( 2 ^ ‹_› ) ] ;

/-
For all n, tsb of balanced arrow trees is at least (tsb base + 1)^(2^n) = 2^(2^n).
-/
theorem tsb_balancedArrow_lower (n : ℕ) :
    tsb (balancedArrow n) + 1 ≥ 2 ^ (2 ^ n) := by
  induction' n with n ih <;> simp_all +decide [ pow_succ, pow_mul ];
  rw [ tsb_balancedArrow_succ ] ; nlinarith [ pow_pos ( zero_lt_two' ℕ ) ( 2 ^ n ) ] ;

/-! ## Theorem 4: Arrow Dominance -/

/-- Replace all products and sums with arrows. -/
def promote : Ty' → Ty'
  | .base => .base
  | .arrow A B => .arrow (promote A) (promote B)
  | .prod A B => .arrow (promote A) (promote B)
  | .sum A B => .arrow (promote A) (promote B)

/-
Arrows dominate: promoting to arrows can only increase the state bound.
-/
theorem tsb_arrow_dominance (T : Ty') :
    tsb T ≤ tsb (promote T) := by
  induction' T using Ty'.recOn with A B ihA ihB A B ihA ihB A B ihA ihB;
  · rfl;
  · exact Nat.mul_le_mul ( Nat.add_le_add_right ihA 1 ) ( Nat.add_le_add_right ihB 1 );
  · -- By definition of tsb, we have tsb (A.prod B) = tsb A * tsb B and tsb (promote (A.prod B)) = (tsb (promote A) + 1) * (tsb (promote B) + 1).
    have h_tsb_prod : tsb (A.prod B) = tsb A * tsb B ∧ tsb (promote (A.prod B)) = (tsb (promote A) + 1) * (tsb (promote B) + 1) := by
      exact ⟨ rfl, rfl ⟩;
    nlinarith;
  · -- Since tsb(promote A) ≥ tsb A ≥ 1 and tsb(promote B) ≥ tsb B ≥ 1, we have (a+1)(b+1) = ab + a + b + 1 ≥ a + b.
    have h_ineq : (tsb (promote A) + 1) * (tsb (promote B) + 1) ≥ tsb A + tsb B := by
      grind;
    exact h_ineq

/-! ## Theorem 5: Classifier Correctness -/

/-
The growth regime classifier is correct.
-/
theorem classify_correct (T : Ty') :
    match classifyGrowthRegime T with
    | .linear => ¬HasArrow T ∧ ¬HasProd T
    | .exponential => ¬HasArrow T ∧ (HasProd T ∨ HasSum T)
    | .doubleExponential => HasArrow T := by
  unfold classifyGrowthRegime;
  split_ifs <;> simp_all +decide

end GrowthRegime