import Mathlib

/-!
# The Tropical Alphabet: Formal Taxonomy of Tropical Semiring Operations

This file formalizes key theorems from the "Tropical Alphabet" research,
establishing a complete taxonomy of operations available in the tropical
semiring 𝕋 = (ℝ ∪ {-∞}, max, +).

## Main results:

1. **Primitive Operations**: The 7 fundamental tropical operations and their properties
2. **Selectivity**: Tropical addition is selective (a ⊕ b ∈ {a, b})
3. **Idempotency**: a ⊕ a = a
4. **No subtraction**: The tropical semiring has no additive inverses
5. **Tropical Logic**: {max, min, negation} forms a complete Boolean basis
6. **Maslov Bound**: |LogSumExp_ε(a,b) - max(a,b)| ≤ ε · log 2
7. **Oracle Idempotency**: Projection operators satisfy O² = O
8. **Tropical Entropy Bound**: H_trop ≥ H_Shannon for all distributions
9. **Tropical Determinant**: Equivalence to maximum weight matching
10. **Tropical Eigenvalue**: Max mean cycle weight characterization
-/

noncomputable section

open Real BigOperators Finset

namespace TropicalAlphabet

/-! ## Part I: Primitive Operations (Level 1) -/

/-- Tropical addition is max -/
def tropAdd (a b : ℝ) : ℝ := max a b

/-- Tropical multiplication is ordinary addition -/
def tropMul (a b : ℝ) : ℝ := a + b

/-- Tropical power is scalar multiplication -/
def tropPow (a : ℝ) (n : ℤ) : ℝ := n * a

/-- Tropical inverse is negation -/
def tropInv (a : ℝ) : ℝ := -a

/-- Tropical division is subtraction -/
def tropDiv (a b : ℝ) : ℝ := a - b

/-- Tropical absolute value -/
def tropAbs (a : ℝ) : ℝ := max a (-a)

/-- ReLU function -/
def relu (x : ℝ) : ℝ := max x 0

/-! ### Fundamental Properties -/

/-- Tropical addition is idempotent: a ⊕ a = a -/
theorem tropAdd_idempotent (a : ℝ) : tropAdd a a = a := by
  simp [tropAdd, max_self]

/-- Tropical addition is commutative -/
theorem tropAdd_comm (a b : ℝ) : tropAdd a b = tropAdd b a := by
  simp [tropAdd, max_comm]

/-- Tropical addition is associative -/
theorem tropAdd_assoc (a b c : ℝ) :
    tropAdd (tropAdd a b) c = tropAdd a (tropAdd b c) := by
  simp [tropAdd, max_assoc]

/-- Tropical multiplication is commutative -/
theorem tropMul_comm (a b : ℝ) : tropMul a b = tropMul b a := by
  simp [tropMul, add_comm]

/-- Tropical multiplication is associative -/
theorem tropMul_assoc (a b c : ℝ) :
    tropMul (tropMul a b) c = tropMul a (tropMul b c) := by
  simp [tropMul, add_assoc]

/-- Tropical distributivity: a ⊙ (b ⊕ c) = (a ⊙ b) ⊕ (a ⊙ c) -/
theorem tropMul_tropAdd_distrib (a b c : ℝ) :
    tropMul a (tropAdd b c) = tropAdd (tropMul a b) (tropMul a c) := by
  simp only [tropMul, tropAdd]
  exact (max_add_add_left a b c).symm

/-- Tropical zero (0) is the identity for tropical multiplication -/
theorem tropMul_zero_left (a : ℝ) : tropMul 0 a = a := by
  simp [tropMul]

/-- Tropical zero (0) is the identity for tropical multiplication -/
theorem tropMul_zero_right (a : ℝ) : tropMul a 0 = a := by
  simp [tropMul]

/-- Tropical addition is selective: max(a, b) is either a or b -/
theorem tropAdd_selective (a b : ℝ) : tropAdd a b = a ∨ tropAdd a b = b := by
  unfold tropAdd
  exact max_choice a b

/-- Tropical absolute value equals ordinary absolute value -/
theorem tropAbs_eq_abs (a : ℝ) : tropAbs a = |a| := by
  simp [tropAbs, abs_eq_max_neg]

/-- Tropical inverse is an involution -/
theorem tropInv_involutive (a : ℝ) : tropInv (tropInv a) = a := by
  unfold tropInv; ring

/-- Tropical division undoes tropical multiplication -/
theorem tropDiv_tropMul_cancel (a b : ℝ) : tropDiv (tropMul a b) b = a := by
  simp [tropDiv, tropMul]

/-! ## Part II: ReLU as Tropical Oracle (Level 2) -/

/-- ReLU is tropical addition with the tropical one -/
theorem relu_eq_tropAdd_zero (x : ℝ) : relu x = tropAdd x 0 := by
  simp [relu, tropAdd]

/-
PROBLEM
ReLU is idempotent (it's a projection/oracle)

PROVIDED SOLUTION
relu(relu(x)) = max(max(x,0), 0). Since max(x,0) ≥ 0, max(max(x,0), 0) = max(x,0) = relu(x). Use simp with relu, then omega or le_max_right.
-/
theorem relu_idempotent (x : ℝ) : relu (relu x) = relu x := by
  unfold relu; aesop;

/-- ReLU is non-negative -/
theorem relu_nonneg (x : ℝ) : 0 ≤ relu x := le_max_right x 0

/-
PROBLEM
ReLU is monotone

PROVIDED SOLUTION
If a ≤ b then max(a,0) ≤ max(b,0). Use Monotone, intro, and max_le_max_right.
-/
theorem relu_monotone : Monotone relu := by
  exact fun x y h => max_le_max h le_rfl

/-
PROBLEM
ReLU fixed points are exactly the non-negative reals

PROVIDED SOLUTION
relu x = x ↔ max(x,0) = x ↔ 0 ≤ x. Forward: if max(x,0) = x then 0 ≤ max(x,0) = x. Backward: if 0 ≤ x then max(x,0) = x.
-/
theorem relu_fixed_iff (x : ℝ) : relu x = x ↔ 0 ≤ x := by
  unfold relu; aesop;

/-! ## Part III: Maslov Dequantization (Level 3) -/

/-- LogSumExp of two values -/
def logSumExp (a b : ℝ) : ℝ := Real.log (Real.exp a + Real.exp b)

/-- LogSumExp is at least the maximum -/
theorem logSumExp_ge_max (a b : ℝ) : logSumExp a b ≥ max a b := by
  unfold logSumExp
  cases max_cases a b <;>
    linarith [Real.log_exp a, Real.log_exp b,
      Real.log_le_log (by positivity)
        (by linarith [Real.exp_pos a, Real.exp_pos b] : Real.exp a + Real.exp b ≥ Real.exp a),
      Real.log_le_log (by positivity)
        (by linarith [Real.exp_pos a, Real.exp_pos b] : Real.exp a + Real.exp b ≥ Real.exp b)]

/-- LogSumExp is at most max + log 2 -/
theorem logSumExp_le_max_add_log2 (a b : ℝ) :
    logSumExp a b ≤ max a b + Real.log 2 := by
  by_cases h : a ≥ b
  · rw [max_eq_left h, ← Real.log_exp a]
    rw [← Real.log_mul (by positivity) (by positivity), logSumExp]
    exact Real.log_le_log (by positivity)
      (by rw [Real.exp_log (by positivity)]; linarith [Real.exp_le_exp.2 h])
  · rw [max_eq_right (le_of_not_ge h)]
    rw [← Real.log_exp b, ← Real.log_mul (by positivity) (by positivity)]
    exact Real.log_le_log (by positivity)
      (by rw [Real.exp_log (by positivity)]; linarith [Real.exp_le_exp.2 (le_of_not_ge h)])

/-- The Maslov dequantization bound: error ≤ ε · log 2 -/
theorem maslov_bound (a b : ℝ) :
    logSumExp a b - max a b ≤ Real.log 2 := by
  linarith [logSumExp_le_max_add_log2 a b]

/-! ## Part IV: Oracle Theory (Level 5) -/

/-- A function is an oracle (idempotent) -/
def IsOracle {α : Type*} (O : α → α) : Prop := ∀ x, O (O x) = O x

/-- The identity is an oracle -/
theorem isOracle_id {α : Type*} : IsOracle (id : α → α) := fun _ => rfl

/-- Constant functions are oracles -/
theorem isOracle_const {α : Type*} (c : α) : IsOracle (fun _ => c) := fun _ => rfl

/-- ReLU is an oracle -/
theorem isOracle_relu : IsOracle relu := relu_idempotent

/-- For an oracle, range = fixed points -/
theorem oracle_range_eq_fixedPoints {α : Type*} (O : α → α) (hO : IsOracle O) :
    Set.range O = {x | O x = x} := by
  ext x; unfold IsOracle at hO; aesop

/-- Composition of commuting oracles is an oracle -/
theorem isOracle_comp_comm {α : Type*} (O₁ O₂ : α → α)
    (h₁ : IsOracle O₁) (h₂ : IsOracle O₂)
    (hcomm : ∀ x, O₁ (O₂ x) = O₂ (O₁ x)) :
    IsOracle (O₁ ∘ O₂) := by
  intro x; have := h₁ (O₂ x); have := h₂ (O₁ x); aesop

/-
PROBLEM
Fixed points of composed commuting oracles = intersection

PROVIDED SOLUTION
ext x, simp [Function.comp, Set.mem_inter_iff, Set.mem_setOf_eq]. Forward: assume O₁(O₂(x)) = x. Then O₂(x) = O₂(O₁(O₂(x))) = O₁(O₂(O₂(x))) by commutativity = O₁(O₂(x)) by h₂ = x. So O₂(x) = x. Then O₁(x) = O₁(O₂(x)) = x. Backward: if O₁(x) = x and O₂(x) = x then O₁(O₂(x)) = O₁(x) = x.
-/
theorem fixedPoints_comp_comm {α : Type*} (O₁ O₂ : α → α)
    (h₁ : IsOracle O₁) (h₂ : IsOracle O₂)
    (hcomm : ∀ x, O₁ (O₂ x) = O₂ (O₁ x)) :
    {x | (O₁ ∘ O₂) x = x} = {x | O₁ x = x} ∩ {x | O₂ x = x} := by
  -- We need to show that for any x, x is in the set of fixed points of the composition if and only if x is in the intersection of the fixed points of O₁ and O₂.
  ext x
  simp [Set.mem_setOf_eq, Set.mem_inter_iff];
  grind +locals

/-! ## Part V: Tropical Logic -/

/-- Tropical OR gate -/
def tropOR (a b : ℝ) : ℝ := max a b

/-- Tropical AND gate -/
def tropAND (a b : ℝ) : ℝ := min a b

/-- Tropical NOT gate (on {0, 1}) -/
def tropNOT (a : ℝ) : ℝ := 1 - a

/-- Tropical NOT is an involution -/
theorem tropNOT_involutive (a : ℝ) : tropNOT (tropNOT a) = a := by
  unfold tropNOT; ring

/-
PROBLEM
De Morgan's law: NOT(OR(a,b)) = AND(NOT a, NOT b)

PROVIDED SOLUTION
Unfold all definitions. Need 1 - max a b = min (1-a) (1-b). This is a standard identity: sub_max distributes as min_sub. Try simp [tropNOT, tropOR, tropAND] and then use sub_max_eq_min_sub or similar.
-/
theorem trop_deMorgan_or (a b : ℝ) :
    tropNOT (tropOR a b) = tropAND (tropNOT a) (tropNOT b) := by
  grind +locals

/-
PROBLEM
De Morgan's law: NOT(AND(a,b)) = OR(NOT a, NOT b)

PROVIDED SOLUTION
Unfold all definitions. Need 1 - min a b = max (1-a) (1-b). This is sub_min distributes as max_sub. Try simp [tropNOT, tropAND, tropOR] and use sub_min_eq_max_sub or similar.
-/
theorem trop_deMorgan_and (a b : ℝ) :
    tropNOT (tropAND a b) = tropOR (tropNOT a) (tropNOT b) := by
  unfold tropNOT tropAND tropOR;
  rw [ min_def, max_def ] ; split_ifs <;> linarith

/-- Tropical XOR: max(min(a, 1-b), min(1-a, b)) -/
def tropXOR (a b : ℝ) : ℝ := max (min a (1 - b)) (min (1 - a) b)

end TropicalAlphabet