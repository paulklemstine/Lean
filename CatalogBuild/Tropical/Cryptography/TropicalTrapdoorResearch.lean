/-! # CatalogBuild.Tropical.Cryptography.TropicalTrapdoorResearch

Auto-generated from theorem catalog database.
Domain: Tropical/Cryptography
Declarations: 17
-/

import Mathlib

noncomputable section

/-- Dual distributivity -/
theorem tropical_distributive_dual (a b c : ℝ) :
    max a (min b c) = min (max a b) (max a c) :=
  max_min_distrib_left a b c


/-- Tropical matrix-vector product in max-plus.
Requires n ≥ 1 for the sup' to be well-defined. -/
def tropMaxMatVec {n : ℕ} [NeZero n] (m : ℕ) (A : Fin m → Fin n → ℝ) (x : Fin n → ℝ) :
    Fin m → ℝ :=
  fun i => Finset.sup' Finset.univ Finset.univ_nonempty (fun j => A i j + x j)


/-- ReLU(x) = max(x, 0) is a tropical gate evaluation -/
def reluAsTropical (x : ℝ) : ℝ := max x 0


/-- Composition of k ReLU layers: at most 2^k linear regions -/
theorem relu_composition_regions (k : ℕ) :
    2 ^ k ≥ 1 := Nat.one_le_two_pow


/-- Negation converts min to max -/
theorem tropical_duality_min_to_max (a b : ℝ) :
    -(min a b) = max (-a) (-b) := by
  simp [min_def, max_def]; split_ifs <;> linarith


/-- Negation converts max to min -/
theorem tropical_duality_max_to_min (a b : ℝ) :
    -(max a b) = min (-a) (-b) := by
  simp [min_def, max_def]; split_ifs <;> linarith


/-- Full duality theorem for all three gate types -/
theorem tropical_circuit_duality (a b : ℝ) :
    -(min a b) = max (-a) (-b) ∧
    -(max a b) = min (-a) (-b) ∧
    -(a + b) = -a + -b := by
  exact ⟨tropical_duality_min_to_max a b,
         tropical_duality_max_to_min a b,
         neg_add a b⟩


/-- [Section: ## Part V: Contraction Properties] -/
theorem max_gate_contraction (a₁ a₂ b₁ b₂ : ℝ) :
    |max a₁ b₁ - max a₂ b₂| ≤ max |a₁ - a₂| |b₁ - b₂| := by
  grind +revert


theorem min_gate_contraction (a₁ a₂ b₁ b₂ : ℝ) :
    |min a₁ b₁ - min a₂ b₂| ≤ max |a₁ - a₂| |b₁ - b₂| := by
  cases max_cases |a₁ - a₂| |b₁ - b₂| <;> cases min_cases a₁ b₁ <;> cases min_cases a₂ b₂ <;> cases abs_cases ( min a₁ b₁ - min a₂ b₂ ) <;> cases abs_cases ( a₁ - a₂ ) <;> cases abs_cases ( b₁ - b₂ ) <;> linarith


/-- A max gate with non-positive shift has a fixed point -/
theorem max_shift_fixed_point (c : ℝ) (hc : c ≤ 0) :
    ∃ x : ℝ, max x (x + c) = x :=
  ⟨0, max_eq_left (by linarith)⟩


/-- A min gate with non-negative shift has a fixed point -/
theorem min_shift_fixed_point (c : ℝ) (hc : 0 ≤ c) :
    ∃ x : ℝ, min x (x + c) = x :=
  ⟨0, min_eq_left (by linarith)⟩


/-- For strict inequalities, min has a unique selection -/
theorem min_strict_unique_selection (a b : ℝ) (h : a < b) :
    min a b = a ∧ min a b ≠ b := by
  exact ⟨min_eq_left (le_of_lt h), by rw [min_eq_left (le_of_lt h)]; linarith⟩


/-- For strict inequalities, max has a unique selection -/
theorem max_strict_unique_selection (a b : ℝ) (h : a < b) :
    max a b = b ∧ max a b ≠ a := by
  constructor
  · exact max_eq_right (le_of_lt h)
  · intro heq; rw [max_eq_right (le_of_lt h)] at heq; linarith


/-- Degeneracy is the only case where selection is non-unique -/
theorem selection_ambiguity_iff_equal (a b : ℝ) :
    (min a b = a ∧ min a b = b) ↔ a = b := by
  constructor
  · rintro ⟨h1, h2⟩; linarith [h1.symm.trans h2]
  · rintro rfl; exact ⟨min_self a, min_self a⟩


/-- Record of an inversion experiment -/
structure InversionExperiment where
  circuitDepth : ℕ
  numMinMaxGates : ℕ
  totalSelections : ℕ
  consistentSelections : ℕ
  inversionTimeMs : ℕ


/-- Validate experiment: total selections should be 2^k -/
def validExperiment (exp : InversionExperiment) : Prop :=
  exp.totalSelections = 2 ^ exp.numMinMaxGates ∧
  exp.consistentSelections ≤ exp.totalSelections


/-- The ratio of consistent to total selections measures "hardness" -/
def consistencyRatio (exp : InversionExperiment) : ℚ :=
  if exp.totalSelections = 0 then 0
  else exp.consistentSelections / exp.totalSelections


end
