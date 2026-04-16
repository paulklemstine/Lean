/-! # CatalogBuild.Tropical.Langlands.PAdicTropical

Auto-generated from theorem catalog database.
Domain: Tropical/Langlands
Declarations: 12
-/

import Mathlib

noncomputable section

/-- A Newton polygon: sorted slopes with multiplicities -/
structure NewtonPolygon where
  numSlopes : ℕ
  slopes : Fin numSlopes → ℝ
  sorted : ∀ i j : Fin numSlopes, i ≤ j → slopes i ≤ slopes j



/-- Total weight of a Newton polygon -/
def NewtonPolygon.totalWeight (NP : NewtonPolygon) : ℝ :=
  ∑ i : Fin NP.numSlopes, NP.slopes i



/-- The L¹ distance between slope sequences -/
def newtonPolygonDistance (n : ℕ) (s₁ s₂ : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, |s₁ i - s₂ i|



/-- [Section: # CatalogBuild.Tropical.Langlands.PAdicTropical
Auto-generated from theorem catalog database.
Domain: Tropical/Langlands
Declarations: 12] -/
theorem newtonPolygon_triangle (n : ℕ) (s₁ s₂ s₃ : Fin n → ℝ) :
    newtonPolygonDistance n s₁ s₃ ≤
    newtonPolygonDistance n s₁ s₂ + newtonPolygonDistance n s₂ s₃ := by
  unfold newtonPolygonDistance;
  simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_le_sum fun i _ => abs_sub_le _ _ _



/-- Symmetry -/
theorem newtonPolygon_dist_symm (n : ℕ) (s₁ s₂ : Fin n → ℝ) :
    newtonPolygonDistance n s₁ s₂ = newtonPolygonDistance n s₂ s₁ := by
  unfold newtonPolygonDistance
  congr 1; ext i; exact abs_sub_comm (s₁ i) (s₂ i)



theorem newtonPolygon_dist_zero (n : ℕ) (s₁ s₂ : Fin n → ℝ) :
    newtonPolygonDistance n s₁ s₂ = 0 ↔ s₁ = s₂ := by
  simp +decide only [newtonPolygonDistance];
  simp +contextual [ funext_iff, Finset.sum_eq_zero_iff_of_nonneg, abs_nonneg ];
  simp +decide only [sub_eq_zero]



/-- A tropical φ-module -/
structure TropicalPhiModule (n : ℕ) where
  frobSlopes : Fin n → ℝ
  sorted : ∀ i j : Fin n, i ≤ j → frobSlopes i ≤ frobSlopes j



/-- A tropical filtered module -/
structure TropicalFilteredModule (n : ℕ) extends TropicalPhiModule n where
  htWeights : Fin n → ℝ
  htSorted : ∀ i j : Fin n, i ≤ j → htWeights i ≤ htWeights j



/-- Weak admissibility -/
def isWeaklyAdmissible (n : ℕ) (M : TropicalFilteredModule n) : Prop :=
  (∑ i : Fin n, M.frobSlopes i = ∑ i : Fin n, M.htWeights i) ∧
  (∀ k : Fin n, ∑ i ∈ Finset.univ.filter (· ≤ k), M.frobSlopes i ≤
                 ∑ i ∈ Finset.univ.filter (· ≤ k), M.htWeights i)



/-- The trivial module is weakly admissible -/
theorem trivial_weakly_admissible (n : ℕ) :
    isWeaklyAdmissible n {
      frobSlopes := fun _ => 0
      sorted := fun _ _ _ => le_refl _
      htWeights := fun _ => 0
      htSorted := fun _ _ _ => le_refl _
    } := by
  constructor <;> simp



/-- Direct sum preserves total slope matching -/
theorem weaklyAdmissible_directSum (n₁ n₂ : ℕ)
    (M₁ : TropicalFilteredModule n₁) (M₂ : TropicalFilteredModule n₂)
    (h₁ : isWeaklyAdmissible n₁ M₁) (h₂ : isWeaklyAdmissible n₂ M₂) :
    ∑ i : Fin n₁, M₁.frobSlopes i + ∑ i : Fin n₂, M₂.frobSlopes i =
    ∑ i : Fin n₁, M₁.htWeights i + ∑ i : Fin n₂, M₂.htWeights i := by
  linarith [h₁.1, h₂.1]



/-- A Newton polygon with constant slope has no "break points" -/
theorem constant_slope_monotone (n : ℕ) (c : ℝ) (i j : Fin n) (h : i ≤ j) :
    (fun _ : Fin n => c) i ≤ (fun _ : Fin n => c) j := by
  simp



end
