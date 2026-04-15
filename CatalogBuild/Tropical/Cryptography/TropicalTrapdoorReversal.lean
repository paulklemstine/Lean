/-! # CatalogBuild.Tropical.Cryptography.TropicalTrapdoorReversal

Auto-generated from theorem catalog database.
Domain: Tropical/Cryptography
Declarations: 29
-/

import Mathlib

noncomputable section

/-- Characterization of min preimage -/
theorem min_preimage_char (a b c : ℝ) :
    min a b = c ↔ (a = c ∧ c ≤ b) ∨ (b = c ∧ c ≤ a) := by
  constructor
  · intro h
    rcases le_or_gt a b with hab | hab
    · left; exact ⟨by rw [min_eq_left hab] at h; exact h,
                    by rw [min_eq_left hab] at h; linarith⟩
    · right; exact ⟨by rw [min_eq_right (le_of_lt hab)] at h; exact h,
                     by rw [min_eq_right (le_of_lt hab)] at h; linarith⟩
  · rintro (⟨rfl, hcb⟩ | ⟨rfl, hca⟩)
    · exact min_eq_left hcb
    · exact min_eq_right hca


/-- Characterization of max preimage -/
theorem max_preimage_char (a b c : ℝ) :
    max a b = c ↔ (a = c ∧ b ≤ c) ∨ (b = c ∧ a ≤ c) := by
  constructor
  · intro h
    rcases le_or_gt a b with hab | hab
    · right; exact ⟨by rw [max_eq_right hab] at h; exact h,
                     by rw [max_eq_right hab] at h; linarith⟩
    · left; exact ⟨by rw [max_eq_left (le_of_lt hab)] at h; exact h,
                    by rw [max_eq_left (le_of_lt hab)] at h; linarith⟩
  · rintro (⟨rfl, hbc⟩ | ⟨rfl, hac⟩)
    · exact max_eq_left hbc
    · exact max_eq_right hac


/-- Add gate reversal: a + b = c gives b = c - a -/
theorem add_preimage_char (a b c : ℝ) :
    a + b = c ↔ b = c - a := by constructor <;> intro h <;> linarith


/-- Add gate preserves full information (invertible given one input) -/
theorem add_no_info_loss (a b c : ℝ) (h : a + b = c) :
    b = c - a ∧ a = c - b := by constructor <;> linarith


/-- A tropical half-space constraint -/
inductive TropConstraint where
  | LeShift (i j : ℕ) (c : ℝ) : TropConstraint  -- x_i ≤ x_j + c
  | EqSum (i j : ℕ) (c : ℝ) : TropConstraint     -- x_i + x_j = c
  | EqConst (i : ℕ) (c : ℝ) : TropConstraint      -- x_i = c


/-- Satisfaction of a tropical constraint -/
def satisfiesConstraint (x : ℕ → ℝ) : TropConstraint → Prop
  | .LeShift i j c => x i ≤ x j + c
  | .EqSum i j c => x i + x j = c
  | .EqConst i c => x i = c


/-- A tropical polyhedron is defined by a list of constraints -/
abbrev TropPolyhedron := List TropConstraint


/-- The feasible set of a tropical polyhedron -/
def feasibleSet (poly : TropPolyhedron) : Set (ℕ → ℝ) :=
  {x | ∀ c ∈ poly, satisfiesConstraint x c}


/-- Empty constraint list gives the whole space -/
theorem feasible_empty : feasibleSet ([] : TropPolyhedron) = Set.univ := by
  ext x; simp [feasibleSet]


/-- Adding a constraint can only shrink the feasible set -/
theorem feasible_mono (poly : TropPolyhedron) (c : TropConstraint) :
    feasibleSet (c :: poly) ⊆ feasibleSet poly := by
  intro x hx constr hconstr
  exact hx constr (List.mem_cons_of_mem c hconstr)


/-- A linearized gate: after fixing selections, each gate is either
"take left", "take right", or "add" -/
inductive LinearizedGate where
  | TakeLeft : LinearizedGate
  | TakeRight : LinearizedGate
  | Add : LinearizedGate


/-- Evaluate a linearized gate -/
def evalLinearized (lg : LinearizedGate) (a b : ℝ) : ℝ :=
  match lg with
  | .TakeLeft => a
  | .TakeRight => b
  | .Add => a + b


/-- Linearized min gate (select left) agrees with min when a ≤ b -/
theorem linearize_min_left (a b : ℝ) (h : a ≤ b) :
    evalLinearized .TakeLeft a b = min a b := by
  simp [evalLinearized, min_eq_left h]


/-- Linearized min gate (select right) agrees with min when b ≤ a -/
theorem linearize_min_right (a b : ℝ) (h : b ≤ a) :
    evalLinearized .TakeRight a b = min a b := by
  simp [evalLinearized, min_eq_right h]


/-- Linearized max gate (select left) agrees with max when b ≤ a -/
theorem linearize_max_left (a b : ℝ) (h : b ≤ a) :
    evalLinearized .TakeLeft a b = max a b := by
  simp [evalLinearized, max_eq_left h]


/-- Linearized max gate (select right) agrees with max when a ≤ b -/
theorem linearize_max_right (a b : ℝ) (h : a ≤ b) :
    evalLinearized .TakeRight a b = max a b := by
  simp [evalLinearized, max_eq_right h]


/-- Add gate linearization is trivial -/
theorem linearize_add (a b : ℝ) :
    evalLinearized .Add a b = a + b := rfl


/-- A min-gate selection is consistent if the selected value is indeed the minimum -/
def minSelectionConsistent (a b : ℝ) (selectLeft : Bool) : Prop :=
  if selectLeft then a ≤ b else b ≤ a


/-- A max-gate selection is consistent if the selected value is indeed the maximum -/
def maxSelectionConsistent (a b : ℝ) (selectLeft : Bool) : Prop :=
  if selectLeft then b ≤ a else a ≤ b


/-- Every min has at least one consistent selection -/
theorem min_has_consistent_selection (a b : ℝ) :
    minSelectionConsistent a b true ∨ minSelectionConsistent a b false := by
  simp [minSelectionConsistent]
  exact le_total a b


/-- Every max has at least one consistent selection -/
theorem max_has_consistent_selection (a b : ℝ) :
    maxSelectionConsistent a b true ∨ maxSelectionConsistent a b false := by
  simp [maxSelectionConsistent]
  exact le_total b a


/-- When inputs are equal, both selections are consistent for min -/
theorem min_equal_both_consistent (a : ℝ) :
    minSelectionConsistent a a true ∧ minSelectionConsistent a a false := by
  simp [minSelectionConsistent]


/-- When inputs are equal, both selections are consistent for max -/
theorem max_equal_both_consistent (a : ℝ) :
    maxSelectionConsistent a a true ∧ maxSelectionConsistent a a false := by
  simp [maxSelectionConsistent]


/-- n-gate composition: reversal complexity is 2^n -/
theorem n_gate_selections (n : ℕ) :
    Fintype.card (Fin n → Bool) = 2 ^ n := by
  simp [Fintype.card_fin, Fintype.card_bool]


/-- The max of two affine functions expressed as a conditional -/
theorem max_affine_conditional (a₁ b₁ a₂ b₂ x : ℝ) :
    max (a₁ * x + b₁) (a₂ * x + b₂) =
      if a₂ * x + b₂ ≤ a₁ * x + b₁ then a₁ * x + b₁ else a₂ * x + b₂ := by
  simp only [max_def]; split_ifs with h <;> linarith


/-- The min of two affine functions expressed as a conditional -/
theorem min_affine_conditional (a₁ b₁ a₂ b₂ x : ℝ) :
    min (a₁ * x + b₁) (a₂ * x + b₂) =
      if a₁ * x + b₁ ≤ a₂ * x + b₂ then a₁ * x + b₁ else a₂ * x + b₂ := by
  simp only [min_def]


/-- [Section: ## Section 8: Boundary Points] -/
theorem max_boundary_point (a₁ b₁ a₂ b₂ : ℝ) (hne : a₁ ≠ a₂) :
    ∃! x : ℝ, a₁ * x + b₁ = a₂ * x + b₂ := by
      exact ⟨ ( b₂ - b₁ ) / ( a₁ - a₂ ), by linarith [ mul_div_cancel₀ ( b₂ - b₁ ) ( sub_ne_zero_of_ne hne ) ], by intro x hx; rw [ eq_div_iff ( sub_ne_zero_of_ne hne ) ] at *; linarith ⟩


/-- For strict inequalities, min has a unique selection -/
theorem min_strict_unique (a b : ℝ) (h : a < b) :
    min a b = a ∧ min a b ≠ b := by
  exact ⟨min_eq_left (le_of_lt h), by rw [min_eq_left (le_of_lt h)]; linarith⟩


/-- For strict inequalities, max has a unique selection -/
theorem max_strict_unique (a b : ℝ) (h : a < b) :
    max a b = b ∧ max a b ≠ a := by
  exact ⟨max_eq_right (le_of_lt h), by rw [max_eq_right (le_of_lt h)]; linarith⟩


end
