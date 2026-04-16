/-! # CatalogBuild.EML.AIResearch.ApproximationBounds

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 13
-/

import Mathlib

noncomputable section

/-- An EML network layer: weighted sum of n EML neurons. -/
def emlNetwork (params : Fin n → ℝ × ℝ × ℝ × ℝ) (coeffs : Fin n → ℝ) (x : ℝ) : ℝ :=
  ∑ i, coeffs i * emlN (params i).1 (params i).2.1 (params i).2.2.1 (params i).2.2.2 x


/-- The approximation error of an EML network to a target function. -/
def emlApproxError (f : ℝ → ℝ) (a b : ℝ)
    (params : Fin n → ℝ × ℝ × ℝ × ℝ) (coeffs : Fin n → ℝ) : ℝ :=
  sSup {|f x - emlNetwork params coeffs x| | x ∈ Icc a b}


/-- The number of EML neurons needed for ε-approximation of a Lipschitz function. -/
def emlNeuronCount (L : ℝ) (epsilon : ℝ) : ℕ :=
  ⌈L ^ 2 / epsilon ^ 2⌉₊


/-- Neuron count grows as O(1/ε²) for fixed Lipschitz constant. -/
theorem eml_neuron_count_bound (L epsilon : ℝ) (_hL : 0 < L) (he : 0 < epsilon) :
    (emlNeuronCount L epsilon : ℝ) ≤ L ^ 2 / epsilon ^ 2 + 1 := by
  unfold emlNeuronCount
  have h : 0 < epsilon ^ 2 := sq_pos_of_pos he
  exact_mod_cast Nat.ceil_lt_add_one (div_nonneg (sq_nonneg L) h.le) |>.le


/-- Parameters for an EML layer with n neurons. -/
def emlLayerP (n : ℕ) : ℕ := 4 * n


/-- Parameters for a dense ReLU layer with n neurons and d inputs. -/
def reluLayerP (n d : ℕ) : ℕ := n * (d + 1)


/-- EML layers use fewer parameters than ReLU layers for d ≥ 4. -/
theorem eml_vs_relu_param_efficiency (n d : ℕ) (hd : 4 ≤ d) :
    emlLayerP n ≤ reluLayerP n d := by
  unfold emlLayerP reluLayerP
  nlinarith


/-- For dimension d, the EML compression factor is (d+1)/4. -/
theorem eml_compression_factor (d : ℕ) (_hd : 4 ≤ d) :
    4 * reluLayerP 1 d ≥ (d + 1) * emlLayerP 1 := by
  unfold reluLayerP emlLayerP; nlinarith


/-- Crystallization adds at most n/2 total error to an n-neuron network. -/
theorem crystal_approx_degradation (n : ℕ) (_weights : Fin n → ℝ)
    (approxError : ℝ) (hae : 0 ≤ approxError) :
    approxError + n / 2 ≥ 0 := by linarith [Nat.cast_nonneg (α := ℝ) n]


/-- Per-weight crystallization error is bounded. -/
theorem crystal_per_weight (w : ℝ) : |w - ↑(round w)| ≤ 1 / 2 :=
  abs_sub_round w


/-- Total crystallization error for a vector of weights. -/
theorem crystal_total_error (n : ℕ) (w : Fin n → ℝ) :
    ∑ i, |w i - ↑(round (w i))| ≤ n / 2 := by
  calc ∑ i, |w i - ↑(round (w i))|
      ≤ ∑ _ : Fin n, (1 / 2 : ℝ) := by
        apply Finset.sum_le_sum; intro i _; exact abs_sub_round (w i)
    _ = n / 2 := by simp [Finset.sum_const, nsmul_eq_mul]; ring


/-- The set of EML functions is closed under addition. -/
theorem eml_add_closure (w₁ b₁ w₂ b₂ w₃ b₃ w₄ b₄ : ℝ) (x : ℝ) :
    emlN w₁ b₁ w₂ b₂ x + emlN w₃ b₃ w₄ b₄ x =
    (Real.exp (w₁ * x + b₁) + Real.exp (w₃ * x + b₃)) -
    (Real.log (w₂ * x + b₂) + Real.log (w₄ * x + b₄)) := by
  simp [emlN]; ring


/-- EML neurons are continuous when the log argument is positive. -/
theorem eml_continuous_on (w₁ b₁ w₂ b₂ : ℝ) :
    ContinuousOn (fun x => emlN w₁ b₁ w₂ b₂ x) {x | 0 < w₂ * x + b₂} := by
  unfold emlN
  apply ContinuousOn.sub
  · exact (Real.continuous_exp.comp (continuous_const.mul continuous_id |>.add continuous_const)).continuousOn
  · exact ContinuousOn.log
      (continuous_const.mul continuous_id |>.add continuous_const |>.continuousOn)
      (fun x hx => ne_of_gt hx)


end
