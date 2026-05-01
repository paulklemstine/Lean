/-! # CatalogBuild.Tropical.Tropical_Hecke_Trace_Formula_for_GL₂

Auto-generated from theorem catalog database.
Domain: Tropical
Declarations: 22
-/

import Mathlib

noncomputable section

/-- A 2×2 matrix over ℚ, interpreted in the max-plus tropical semiring.
Tropical addition is `max`, tropical multiplication is `+`. -/
structure Mat2 where
  a₁₁ : ℚ
  a₁₂ : ℚ
  a₂₁ : ℚ
  a₂₂ : ℚ
  deriving DecidableEq, Repr


/-- Tropical (max-plus) matrix multiplication for 2×2 matrices.
Each entry is the tropical inner product of the corresponding row and column:
`(M ⊗ N)ᵢⱼ = max_k (Mᵢₖ + Nₖⱼ)` -/
def tmul (M N : Mat2) : Mat2 where
  a₁₁ := max (M.a₁₁ + N.a₁₁) (M.a₁₂ + N.a₂₁)
  a₁₂ := max (M.a₁₁ + N.a₁₂) (M.a₁₂ + N.a₂₂)
  a₂₁ := max (M.a₂₁ + N.a₁₁) (M.a₂₂ + N.a₂₁)
  a₂₂ := max (M.a₂₁ + N.a₁₂) (M.a₂₂ + N.a₂₂)


/-- Tropical trace: the tropical sum (= max) of diagonal entries. -/
def ttrace (M : Mat2) : ℚ := max M.a₁₁ M.a₂₂


/-- Tropical determinant: the max-weight perfect matching in the
complete bipartite graph K_{2,2}. This solves the 2×2 assignment problem. -/
def tdet (M : Mat2) : ℚ := max (M.a₁₁ + M.a₂₂) (M.a₁₂ + M.a₂₁)


/-- Tropical square: `M ⊗ M` in the max-plus algebra. -/
def tsquare (M : Mat2) : Mat2 := tmul M M


/-- Maximum cycle mean for a 2×2 matrix viewed as a weighted directed graph.
- **Length-1 cycles**: self-loops at vertices 1 and 2, with means `a₁₁` and `a₂₂`
- **Length-2 cycle**: the cycle 1→2→1, with mean `(a₁₂ + a₂₁) / 2`
The maximum cycle mean is the tropical analogue of the spectral radius. -/
def maxCycleMean (M : Mat2) : ℚ :=
  max (max M.a₁₁ M.a₂₂) ((M.a₁₂ + M.a₂₁) / 2)


/-- The identity permutation matching: σ = id, weight = a₁₁ + a₂₂ -/
def identityMatchingWeight (M : Mat2) : ℚ := M.a₁₁ + M.a₂₂


/-- The swap permutation matching: σ = (12), weight = a₁₂ + a₂₁ -/
def swapMatchingWeight (M : Mat2) : ℚ := M.a₁₂ + M.a₂₁


/-- **Tropical determinant = assignment problem.**
The tropical determinant equals the maximum over all perfect matchings. -/
theorem tdet_eq_max_matching (M : Mat2) :
    tdet M = max (identityMatchingWeight M) (swapMatchingWeight M) := by
  rfl


/-- **Diagonal entry of the tropical square.** The (1,1) entry of M² encodes
all closed walks of length 2 starting and ending at vertex 1. -/
theorem tsquare_a₁₁ (M : Mat2) :
    (tsquare M).a₁₁ = max (2 * M.a₁₁) (M.a₁₂ + M.a₂₁) := by
  simp [tsquare, tmul]; ring_nf


/-- **Diagonal entry of the tropical square.** The (2,2) entry of M² encodes
all closed walks of length 2 starting and ending at vertex 2. -/
theorem tsquare_a₂₂ (M : Mat2) :
    (tsquare M).a₂₂ = max (M.a₂₁ + M.a₁₂) (2 * M.a₂₂) := by
  simp [tsquare, tmul]; ring_nf


/-- **Tropical trace of the square.** Collects all closed walks of length ≤ 2. -/
theorem ttrace_tsquare (M : Mat2) :
    ttrace (tsquare M) = max (max (2 * M.a₁₁) (M.a₁₂ + M.a₂₁)) (max (M.a₂₁ + M.a₁₂) (2 * M.a₂₂)) := by
  unfold ttrace
  rw [tsquare_a₁₁, tsquare_a₂₂]


/-- [Section: ## Core Theorems] -/
theorem ttrace_tsquare_simplified (M : Mat2) :
    ttrace (tsquare M) = max (max (2 * M.a₁₁) (2 * M.a₂₂)) (M.a₁₂ + M.a₂₁) := by
  rw [ ttrace_tsquare ];
  grind


theorem max_div_two (a b c : ℚ) :
    max (max (2 * a) (2 * b)) c / 2 = max (max a b) (c / 2) := by
  grind


theorem tropical_trace_formula (M : Mat2) :
    maxCycleMean M = ttrace (tsquare M) / 2 := by
  unfold maxCycleMean ttrace tsquare;
  unfold tmul; ring_nf;
  grind


theorem ttrace_le_maxCycleMean (M : Mat2) :
    ttrace M ≤ maxCycleMean M := by
  exact le_max_left _ _


theorem spectral_geometric_equiv (M : Mat2) :
    max (ttrace M) (ttrace (tsquare M) / 2) = maxCycleMean M := by
  rw [ ← tropical_trace_formula ];
  exact max_eq_right ( ttrace_le_maxCycleMean M )


/-- [Section: ## Tropical Multiplication Properties] -/
theorem tmul_assoc (A B C : Mat2) : tmul (tmul A B) C = tmul A (tmul B C) := by
  unfold tmul;
  congr 1 <;> norm_num [ add_assoc, max_add_add_right ];
  · grind;
  · grind;
  · grind;
  · grind


theorem ttrace_tsquare_ge_twice_ttrace (M : Mat2) :
    ttrace (tsquare M) ≥ 2 * ttrace M := by
  grind +locals


theorem tdet_le_ttrace_tsquare (M : Mat2) :
    tdet M ≤ ttrace (tsquare M) := by
  unfold tdet ttrace tsquare;
  unfold tmul;
  grind


/-- A rational number λ is a **tropical eigenvalue** of M if there exist
x₁, x₂ (not both zero in a suitable sense) satisfying the tropical
eigenvalue equation:
- `max(a₁₁ + x₁, a₁₂ + x₂) = λ + x₁`
- `max(a₂₁ + x₁, a₂₂ + x₂) = λ + x₂` -/
def IsTropicalEigenvalue (M : Mat2) (ev : ℚ) : Prop :=
  ∃ x₁ x₂ : ℚ, max (M.a₁₁ + x₁) (M.a₁₂ + x₂) = ev + x₁ ∧
                  max (M.a₂₁ + x₁) (M.a₂₂ + x₂) = ev + x₂


/-- [Section: ## Eigenvalue Characterization] -/
theorem maxCycleMean_is_eigenvalue (M : Mat2) :
    IsTropicalEigenvalue M (maxCycleMean M) := by
  -- Let's consider the three cases based on the definition of `maxCycleMean`.
  by_cases h_case1 : maxCycleMean M = M.a₁₁;
  · -- In this case, we can choose $x₁ = 0$ and $x₂ = M.a₂₁ - M.a₁₁$.
    use 0, M.a₂₁ - M.a₁₁;
    grind +suggestions;
  · by_cases h_case2 : maxCycleMean M = M.a₂₂;
    · unfold maxCycleMean at *;
      use M.a₁₂ - M.a₂₂, 0;
      grind;
    · use 0, (M.a₂₁ - M.a₁₂) / 2;
      unfold maxCycleMean at *;
      grind


end
