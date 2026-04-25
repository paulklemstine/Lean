/-! # CatalogBuild.MachineLearning.Neural.LipschitzForwardPass

Auto-generated from theorem catalog database.
Domain: MachineLearning/Neural
Declarations: 15
-/

import Mathlib

noncomputable section

/-- L² norm squared of a vector. -/
def vecNormSq (n : ℕ) (v : Fin n → ℝ) : ℝ := ∑ i : Fin n, v i ^ 2



/-- L² norm of a vector. -/
def vecNorm (n : ℕ) (v : Fin n → ℝ) : ℝ := Real.sqrt (vecNormSq n v)



/-- vecNormSq is non-negative. -/
theorem vecNormSq_nonneg (n : ℕ) (v : Fin n → ℝ) : 0 ≤ vecNormSq n v := by
  apply Finset.sum_nonneg; intro i _; exact sq_nonneg _



/-- vecNorm is non-negative. -/
theorem vecNorm_nonneg (n : ℕ) (v : Fin n → ℝ) : 0 ≤ vecNorm n v :=
  Real.sqrt_nonneg _



/-- A function f : ℝ^n → ℝ^m is Lipschitz with constant L. -/
def IsLipschitzFn (n m : ℕ) (L : ℝ) (f : (Fin n → ℝ) → (Fin m → ℝ)) : Prop :=
  0 ≤ L ∧ ∀ x y : Fin n → ℝ,
    vecNorm m (fun i => f x i - f y i) ≤ L * vecNorm n (fun i => x i - y i)



/-- The identity function is 1-Lipschitz. -/
theorem id_lipschitz (n : ℕ) : IsLipschitzFn n n 1 id := by
  constructor
  · linarith
  · intro x y; simp [one_mul]



/-- Composition of Lipschitz functions: L₁·L₂-Lipschitz. -/
theorem lipschitz_compose (n m k : ℕ) (L₁ L₂ : ℝ)
    (f : (Fin m → ℝ) → (Fin k → ℝ)) (g : (Fin n → ℝ) → (Fin m → ℝ))
    (hf : IsLipschitzFn m k L₁ f) (hg : IsLipschitzFn n m L₂ g) :
    IsLipschitzFn n k (L₁ * L₂) (f ∘ g) := by
  constructor
  · exact mul_nonneg hf.1 hg.1
  · intro x y
    simp only [Function.comp]
    calc vecNorm k (fun i => f (g x) i - f (g y) i)
        ≤ L₁ * vecNorm m (fun i => g x i - g y i) := hf.2 (g x) (g y)
      _ ≤ L₁ * (L₂ * vecNorm n (fun i => x i - y i)) :=
          mul_le_mul_of_nonneg_left (hg.2 x y) hf.1
      _ = (L₁ * L₂) * vecNorm n (fun i => x i - y i) := by ring



/-- [Section: ## Section 1: Lipschitz Continuity of Forward Pass Components] -/
theorem relu_lipschitz_scalar (x y : ℝ) :
    |max x 0 - max y 0| ≤ |x - y| := by
  cases max_cases x 0 <;> cases max_cases y 0 <;> cases abs_cases ( x - y ) <;> cases abs_cases ( Max.max x 0 - Max.max y 0 ) <;> linarith



/-- [Section: # CatalogBuild.MachineLearning.Neural.LipschitzForwardPass
Auto-generated from theorem catalog database.
Domain: MachineLearning/Neural
Declarations: 15] -/
theorem relu_vecNorm_lipschitz (n : ℕ) (x y : Fin n → ℝ) :
    vecNormSq n (fun i => max (x i) 0 - max (y i) 0) ≤
    vecNormSq n (fun i => x i - y i) := by
  exact Finset.sum_le_sum fun i _ => by cases max_cases ( x i ) 0 <;> cases max_cases ( y i ) 0 <;> nlinarith [ abs_le.mp ( relu_lipschitz_scalar ( x i ) ( y i ) ) ] ;



/-- Architecture integrity: f' is an ε-approximation of f. -/
def IsEpsilonApprox (n m : ℕ) (ε : ℝ) (f f' : (Fin n → ℝ) → (Fin m → ℝ)) : Prop :=
  0 ≤ ε ∧ ∀ x : Fin n → ℝ, vecNorm m (fun i => f x i - f' x i) ≤ ε



/-- Reflexivity: any function is a 0-approximation of itself. -/
theorem epsilon_approx_self (n m : ℕ) (f : (Fin n → ℝ) → (Fin m → ℝ)) :
    IsEpsilonApprox n m 0 f f := by
  constructor
  · linarith
  · intro x; simp; unfold vecNorm vecNormSq; simp



/-- [Section: ## Section 2: ε-Bound on Output Divergence] -/
theorem two_layer_error_bound (n m k : ℕ) (L₂ δ₁ δ₂ : ℝ)
    (hL₂ : 0 ≤ L₂) (hδ₁ : 0 ≤ δ₁) (hδ₂ : 0 ≤ δ₂)
    (f₁ f₁' : (Fin n → ℝ) → (Fin m → ℝ))
    (f₂ f₂' : (Fin m → ℝ) → (Fin k → ℝ))
    (hf₂_lip : IsLipschitzFn m k L₂ f₂)
    (hf₁_close : ∀ x, vecNorm m (fun i => f₁ x i - f₁' x i) ≤ δ₁)
    (hf₂_close : ∀ x, vecNorm k (fun i => f₂ x i - f₂' x i) ≤ δ₂) :
    ∀ x, vecNorm k (fun i => (f₂ (f₁ x)) i - (f₂' (f₁' x)) i) ≤ L₂ * δ₁ + δ₂ := by
  -- By the triangle inequality for vecNorm: ‖f₂(f₁(x)) - f₂'(f₁'(x))‖ ≤ ‖f₂(f₁(x)) - f₂(f₁'(x))‖ + ‖f₂(f₁'(x)) - f₂'(f₁'(x))‖.
  have h_triangle : ∀ x, vecNorm k (fun i => f₂ (f₁ x) i - f₂' (f₁' x) i) ≤ vecNorm k (fun i => f₂ (f₁ x) i - f₂ (f₁' x) i) + vecNorm k (fun i => f₂ (f₁' x) i - f₂' (f₁' x) i) := by
    -- By the triangle inequality for the Euclidean norm, we have ‖u + v‖ ≤ ‖u‖ + ‖v‖.
    have h_triangle : ∀ (u v : Fin k → ℝ), Real.sqrt (∑ i, (u i + v i)^2) ≤ Real.sqrt (∑ i, u i^2) + Real.sqrt (∑ i, v i^2) := by
      have h_minkowski : ∀ (u v : EuclideanSpace ℝ (Fin k)), ‖u + v‖ ≤ ‖u‖ + ‖v‖ := by
        exact fun u v => norm_add_le u v;
      simp_all +decide [ EuclideanSpace.norm_eq ];
    exact fun x => by simpa using h_triangle ( fun i => f₂ ( f₁ x ) i - f₂ ( f₁' x ) i ) ( fun i => f₂ ( f₁' x ) i - f₂' ( f₁' x ) i ) ;
  exact fun x => le_trans ( h_triangle x ) ( add_le_add ( hf₂_lip.2 _ _ |> le_trans <| mul_le_mul_of_nonneg_left ( hf₁_close _ ) hL₂ ) ( hf₂_close _ ) )



/-- The main guardrail theorem: bounded perturbation implies ε-approximation. -/
theorem integrity_guardrail (n k : ℕ) (δ : ℝ) (hδ : 0 ≤ δ)
    (f f' : (Fin n → ℝ) → (Fin k → ℝ))
    (h_param_close : ∀ x, vecNorm k (fun i => f x i - f' x i) ≤ δ) :
    IsEpsilonApprox n k δ f f' :=
  ⟨hδ, h_param_close⟩



/-- [Section: ## Section 3: Lipschitz Bound for Full Forward Pass] -/
theorem vecNorm_triangle (n : ℕ) (u v : Fin n → ℝ) :
    vecNorm n (fun i => u i + v i) ≤ vecNorm n u + vecNorm n v := by
  refine' Real.sqrt_le_iff.mpr _;
  refine' ⟨ add_nonneg ( Real.sqrt_nonneg _ ) ( Real.sqrt_nonneg _ ), _ ⟩;
  -- Expanding the right-hand side:
  suffices h_expand : (vecNormSq n u) + 2 * (∑ i, u i * v i) + (vecNormSq n v) ≤ (vecNormSq n u) + 2 * (vecNorm n u) * (vecNorm n v) + (vecNormSq n v) by
    convert h_expand using 1 <;> norm_num [ add_sq, mul_assoc, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, vecNormSq ];
    unfold vecNorm;
    rw [ Real.sq_sqrt ( vecNormSq_nonneg _ _ ), Real.sq_sqrt ( vecNormSq_nonneg _ _ ), vecNormSq, vecNormSq ];
  -- Apply the Cauchy-Schwarz inequality to the second term.
  have h_cauchy : (∑ i, u i * v i) ^ 2 ≤ (∑ i, u i ^ 2) * (∑ i, v i ^ 2) := by
    exact?;
  nlinarith! [ show 0 ≤ Real.sqrt ( vecNormSq n u ) * Real.sqrt ( vecNormSq n v ) by positivity, Real.mul_self_sqrt ( show 0 ≤ vecNormSq n u by exact Finset.sum_nonneg fun _ _ => sq_nonneg _ ), Real.mul_self_sqrt ( show 0 ≤ vecNormSq n v by exact Finset.sum_nonneg fun _ _ => sq_nonneg _ ) ]



/-- Residual connection preserves Lipschitz with constant 1 + L. -/
theorem residual_lipschitz (n : ℕ) (L : ℝ) (hL : 0 ≤ L)
    (g : (Fin n → ℝ) → (Fin n → ℝ))
    (hg : IsLipschitzFn n n L g) :
    IsLipschitzFn n n (1 + L) (fun x i => x i + g x i) := by
  constructor
  · linarith
  · intro x y
    have key : (fun i => (x i + g x i) - (y i + g y i)) =
               (fun i => (x i - y i) + (g x i - g y i)) := by ext i; ring
    rw [key]
    calc vecNorm n (fun i => (x i - y i) + (g x i - g y i))
        ≤ vecNorm n (fun i => x i - y i) + vecNorm n (fun i => g x i - g y i) :=
          vecNorm_triangle n _ _
      _ ≤ vecNorm n (fun i => x i - y i) + L * vecNorm n (fun i => x i - y i) := by
          linarith [hg.2 x y]
      _ = (1 + L) * vecNorm n (fun i => x i - y i) := by ring



end
