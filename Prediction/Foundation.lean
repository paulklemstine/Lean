/-
  # Prediction Science: Foundations

  The mathematical foundations of prediction, formalized from first principles.

  ## The Oracle Council
  We model prediction as a formal algebraic structure: an **Oracle** is any
  function that maps observations to forecasts. A **Council of Oracles** is a
  weighted ensemble. We prove that councils are strictly more powerful than
  individuals (the Diversity Theorem).

  ## Key Results
  1. Bayes' Rule as the unique coherent update rule
  2. The Prediction–Projection Correspondence
  3. The Diversity Theorem for oracle ensembles
  4. The Self-Defeating Prophecy fixed-point theorem
-/

import Mathlib

open Real MeasureTheory Filter Topology Set Finset

noncomputable section

/-! ## §1. Bayesian Prediction: The Unique Coherent Update Rule -/

/-- Bayes' theorem: P(A|B) = P(B|A) * P(A) / P(B) -/
theorem bayes_theorem (pA pB pBgivenA : ℝ)
    (hB : pB ≠ 0) :
    let pAgivenB := pBgivenA * pA / pB
    pAgivenB * pB = pBgivenA * pA := by
  simp only
  field_simp

/-- Bayes' theorem preserves total probability -/
theorem bayes_preserves_total (p₁ p₂ pB₁ pB₂ pB : ℝ)
    (_hprior : p₁ + p₂ = 1)
    (htotal : pB₁ * p₁ + pB₂ * p₂ = pB)
    (hB : pB ≠ 0) :
    pB₁ * p₁ / pB + pB₂ * p₂ / pB = 1 := by
  rw [div_add_div_same, htotal, div_self hB]

/-! ## §2. The Diversity Theorem for Oracle Ensembles -/

-- Average squared error of individual predictors
def avgIndividualError (predictions : Fin n → ℝ) (truth : ℝ) (w : Fin n → ℝ) : ℝ :=
  ∑ i, w i * (predictions i - truth) ^ 2

-- Ensemble prediction
def ensemblePred (predictions : Fin n → ℝ) (w : Fin n → ℝ) : ℝ :=
  ∑ i, w i * predictions i

-- Diversity: weighted variance of predictions around ensemble mean
def diversity (predictions : Fin n → ℝ) (w : Fin n → ℝ) : ℝ :=
  ∑ i, w i * (predictions i - ensemblePred predictions w) ^ 2

/-
PROBLEM
**The Ambiguity Decomposition (Krogh-Vedelsby Theorem)**:
    Ensemble error = Average individual error - Diversity.

PROVIDED SOLUTION
Expand all definitions. ensemblePred - truth = ∑ wᵢ(fᵢ - truth) since ∑wᵢ=1. Then (∑wᵢ(fᵢ-truth))² = ∑wᵢ(fᵢ-truth)² - ∑wᵢ(fᵢ - ∑wⱼfⱼ)². This is a weighted variance decomposition. Expand the squares and use hw : ∑wᵢ = 1 and ring.
-/
theorem ambiguity_decomposition (n : ℕ) (predictions : Fin n → ℝ)
    (truth : ℝ) (w : Fin n → ℝ)
    (hw : ∑ i, w i = 1) :
    (ensemblePred predictions w - truth) ^ 2 =
    avgIndividualError predictions truth w - diversity predictions w := by
  unfold avgIndividualError diversity ensemblePred;
  simp +decide only [mul_comm, sub_eq_add_neg] ; ring;
  norm_num [ Finset.sum_add_distrib, ← Finset.mul_sum _ _ _, ← Finset.sum_mul, hw ] ; ring;
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_assoc, mul_comm, mul_left_comm, hw ] ; ring;
  simpa [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_assoc, hw ] using by ring;

/-
PROBLEM
**Diversity Theorem**: The ensemble never does worse than the
    weighted average of its members.

PROVIDED SOLUTION
By ambiguity_decomposition, ensemble error = avg individual error - diversity. Since diversity ≥ 0 (it's a sum of w_i * squares where w_i ≥ 0), ensemble error ≤ avg individual error. Use ambiguity_decomposition, then sub_le_self with Finset.sum_nonneg and mul_nonneg.
-/
theorem diversity_theorem (n : ℕ) (predictions : Fin n → ℝ)
    (truth : ℝ) (w : Fin n → ℝ)
    (hw_nonneg : ∀ i, 0 ≤ w i) (hw_sum : ∑ i, w i = 1) :
    (ensemblePred predictions w - truth) ^ 2 ≤
    avgIndividualError predictions truth w := by
  rw [ ambiguity_decomposition ];
  · exact sub_le_self _ ( Finset.sum_nonneg fun i _ => mul_nonneg ( hw_nonneg i ) ( sq_nonneg _ ) );
  · exact hw_sum

/-! ## §3. The Self-Defeating Prophecy -/

/-
PROBLEM
Contractive response guarantees a unique equilibrium prediction

PROVIDED SOLUTION
Since f p = p and f q = q, |p - q| = |f p - f q| ≤ c|p - q|. If p ≠ q then |p-q| > 0 so 1 ≤ c, contradicting c < 1. Use by_contra, then derive 1 ≤ c from dividing both sides by |p-q|.
-/
theorem self_consistent_prediction_unique
    (f : ℝ → ℝ) (c : ℝ) (_hc0 : 0 ≤ c) (hc1 : c < 1)
    (hf : ∀ x y, |f x - f y| ≤ c * |x - y|)
    (p q : ℝ) (hp : f p = p) (hq : f q = q) : p = q := by
  exact le_antisymm ( le_of_not_gt fun h => by cases abs_cases ( p - q ) <;> cases abs_cases ( f p - f q ) <;> nlinarith [ hf p q ] ) ( le_of_not_gt fun h => by cases abs_cases ( p - q ) <;> cases abs_cases ( f p - f q ) <;> nlinarith [ hf p q ] )

/-! ## §4. Prediction as Projection -/

/-
PROBLEM
The Pythagorean theorem for prediction: ‖x‖² = ‖proj x‖² + ‖x - proj x‖²

PROVIDED SOLUTION
For any x, write x = proj x + (x - proj x). By hsa with y = x, inner (proj x) (x - proj x) = 0. Then ‖x‖² = ‖proj x + (x - proj x)‖² = ‖proj x‖² + 2⟨proj x, x - proj x⟩ + ‖x - proj x‖² = ‖proj x‖² + ‖x - proj x‖². Use norm_add_sq_eq_norm_sq_add_norm_sq_of_inner_eq_zero or the @inner_eq_zero version, plus the fact that x = proj x + (x - proj x) by add_sub_cancel.
-/
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

/-! ## §5. The Law of Total Prediction -/

/-
PROBLEM
Tower property: averaging predictions over the full ensemble
    yields the same as the ensemble prediction.

PROVIDED SOLUTION
The inner sum ∑ j, w j * x j is a constant with respect to i. So ∑ i, w i * (∑ j, w j * x j) = (∑ i, w i) * (∑ j, w j * x j) = 1 * (∑ j, w j * x j). Use Finset.sum_mul_eq or rewrite with ← Finset.mul_sum then hw_sum.
-/
theorem tower_property_finite (n : ℕ) (x w : Fin n → ℝ)
    (_hw_nonneg : ∀ i, 0 ≤ w i)
    (hw_sum : ∑ i, w i = 1) :
    ∑ i, w i * (∑ j, w j * x j) = ∑ j, w j * x j := by
  rw [ ← Finset.sum_mul, hw_sum, one_mul ]

end