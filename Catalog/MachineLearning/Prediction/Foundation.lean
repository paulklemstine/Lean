/-! # CatalogBuild.MachineLearning.Prediction.Foundation

Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 8
-/

import Mathlib

noncomputable section

/-- Bayes' theorem preserves total probability -/
theorem bayes_preserves_total (p₁ p₂ pB₁ pB₂ pB : ℝ)
    (_hprior : p₁ + p₂ = 1)
    (htotal : pB₁ * p₁ + pB₂ * p₂ = pB)
    (hB : pB ≠ 0) :
    pB₁ * p₁ / pB + pB₂ * p₂ / pB = 1 := by
  rw [div_add_div_same, htotal, div_self hB]




/-- [Section: # CatalogBuild.MachineLearning.Prediction.Foundation
Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 8] -/
def avgIndividualError (predictions : Fin n → ℝ) (truth : ℝ) (w : Fin n → ℝ) : ℝ :=
  ∑ i, w i * (predictions i - truth) ^ 2

-- Ensemble prediction



/-- [Section: # CatalogBuild.MachineLearning.Prediction.Foundation
Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 8] -/
def ensemblePred (predictions : Fin n → ℝ) (w : Fin n → ℝ) : ℝ :=
  ∑ i, w i * predictions i

-- Diversity: weighted variance of predictions around ensemble mean



def diversity (predictions : Fin n → ℝ) (w : Fin n → ℝ) : ℝ :=
  ∑ i, w i * (predictions i - ensemblePred predictions w) ^ 2




theorem diversity_theorem (n : ℕ) (predictions : Fin n → ℝ)
    (truth : ℝ) (w : Fin n → ℝ)
    (hw_nonneg : ∀ i, 0 ≤ w i) (hw_sum : ∑ i, w i = 1) :
    (ensemblePred predictions w - truth) ^ 2 ≤
    avgIndividualError predictions truth w := by
  rw [ ambiguity_decomposition ];
  · exact sub_le_self _ ( Finset.sum_nonneg fun i _ => mul_nonneg ( hw_nonneg i ) ( sq_nonneg _ ) );
  · exact hw_sum




theorem self_consistent_prediction_unique
    (f : ℝ → ℝ) (c : ℝ) (_hc0 : 0 ≤ c) (hc1 : c < 1)
    (hf : ∀ x y, |f x - f y| ≤ c * |x - y|)
    (p q : ℝ) (hp : f p = p) (hq : f q = q) : p = q := by
  exact le_antisymm ( le_of_not_gt fun h => by cases abs_cases ( p - q ) <;> cases abs_cases ( f p - f q ) <;> nlinarith [ hf p q ] ) ( le_of_not_gt fun h => by cases abs_cases ( p - q ) <;> cases abs_cases ( f p - f q ) <;> nlinarith [ hf p q ] )




theorem prediction_pythagorean {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (proj : E →L[ℝ] E)
    (_hproj : ∀ x, proj (proj x) = proj x)
    (hsa : ∀ x y, @inner ℝ E _ (proj x) (y - proj y) = 0) :
    ∀ x, ‖x‖ ^ 2 = ‖proj x‖ ^ 2 + ‖x - proj x‖ ^ 2 := by
  intro x
  have h_pyth : ‖x‖^2 = ‖proj x + (x - proj x)‖^2 := by
    rw [ add_sub_cancel ];
  rw [ h_pyth, @norm_add_sq ℝ ];
  specialize hsa x x ; aesop




theorem tower_property_finite (n : ℕ) (x w : Fin n → ℝ)
    (_hw_nonneg : ∀ i, 0 ≤ w i)
    (hw_sum : ∑ i, w i = 1) :
    ∑ i, w i * (∑ j, w j * x j) = ∑ j, w j * x j := by
  rw [ ← Finset.sum_mul, hw_sum, one_mul ]




end
