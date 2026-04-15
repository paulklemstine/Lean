/-! # CatalogBuild.Tropical.Core.TropicalAlphabet

Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 22
-/

import Mathlib

noncomputable section

def tropInv (a : ℝ) : ℝ := -a

/-- Tropical division is subtraction -/

def tropDiv (a b : ℝ) : ℝ := a - b

/-- Tropical absolute value -/

def tropAbs (a : ℝ) : ℝ := max a (-a)

/-- ReLU function -/

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

end
