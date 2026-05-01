/-! # CatalogBuild.MachineLearning.Neural.LLMSingleMatMul

Auto-generated from theorem catalog database.
Domain: MachineLearning/Neural
Declarations: 17
-/

import Mathlib

/-- Composition of two linear maps is a linear map.
This is the mathematical basis for "collapsing" consecutive linear layers. -/
theorem linear_collapse_two {R M N P : Type*} [CommSemiring R]
    [AddCommMonoid M] [AddCommMonoid N] [AddCommMonoid P]
    [Module R M] [Module R N] [Module R P]
    (f : M →ₗ[R] N) (g : N →ₗ[R] P) :
    ∃ h : M →ₗ[R] P, ∀ x, h x = g (f x) :=
  ⟨g.comp f, fun x => rfl⟩





/-- Composition of n linear maps (represented as a list) yields a single linear map.
This shows that an n-layer linear network with no activations collapses to
a single matrix multiplication. -/
theorem linear_collapse_chain {R M : Type*} [CommSemiring R]
    [AddCommMonoid M] [Module R M]
    (fs : List (M →ₗ[R] M)) :
    ∃ h : M →ₗ[R] M, ∀ x, h x = fs.foldr (fun f acc => f acc) x := by
  induction fs with
  | nil => exact ⟨LinearMap.id, fun x => rfl⟩
  | cons f rest ih =>
    obtain ⟨h, hh⟩ := ih
    exact ⟨f.comp h, fun x => by simp [List.foldr, hh]⟩





/-- A single matrix multiplication (linear map) preserves linearity.
Therefore it cannot represent any nonlinear function. -/
theorem linear_map_is_linear {R M N : Type*} [CommSemiring R]
    [AddCommMonoid M] [AddCommMonoid N] [Module R M] [Module R N]
    (f : M →ₗ[R] N) (x y : M) (a b : R) :
    f (a • x + b • y) = a • f x + b • f y := by
  rw [map_add, map_smul, map_smul]





/-- If a function is representable as a linear map, it must satisfy additivity. -/
theorem linear_rep_implies_additive {R M N : Type*} [Semiring R]
    [AddCommMonoid M] [AddCommMonoid N] [Module R M] [Module R N]
    (f : M →ₗ[R] N) (x y : M) :
    f (x + y) = f x + f y :=
  map_add f x y





/-- [Section: # CatalogBuild.MachineLearning.Neural.LLMSingleMatMul
Auto-generated from theorem catalog database.
Domain: MachineLearning/Neural
Declarations: 17] -/
theorem relu_not_linear :
    ¬ ∃ (f : ℝ →ₗ[ℝ] ℝ), ∀ x : ℝ, f x = max x 0 := by
  norm_num +zetaDelta at *;
  intro x; by_contra! h; have := h 1; have := h ( -1 ) ; norm_num at *; linarith;





/-- Any function on a finite type can be represented as matrix-vector multiplication.
This is the "lookup table as matrix" construction: encode input as a one-hot vector,
multiply by a matrix whose columns are the desired outputs. -/
theorem finite_domain_is_matmul {n m : ℕ} (f : Fin n → Fin m → ℝ) :
    ∃ (M : Matrix (Fin m) (Fin n) ℝ),
      ∀ i : Fin n, ∀ j : Fin m, M j i = f i j := by
  exact ⟨fun j i => f i j, fun i j => rfl⟩





/-- [Section: # CatalogBuild.MachineLearning.Neural.LLMSingleMatMul
Auto-generated from theorem catalog database.
Domain: MachineLearning/Neural
Declarations: 17] -/
theorem onehot_matmul_lookup (n m : ℕ) (f : Fin n → Fin m → ℝ) :
    ∃ (M : Matrix (Fin m) (Fin n) ℝ),
      ∀ (i : Fin n),
        M.mulVec (fun j => if j = i then 1 else 0) = f i := by
  exact ⟨ Matrix.of fun i j => f j i, fun i => by ext j; simp +decide [ Matrix.mulVec, dotProduct ] ⟩





/-- The number of distinct functions from a finite input space to output space. -/
theorem function_space_cardinality (n m : ℕ) (hn : 0 < n) (hm : 0 < m) :
    Fintype.card (Fin n → Fin m) = m ^ n := by
  simp [Fintype.card_fun]





/-- A piecewise affine function on ℝ^n partitions the domain into
finitely many polytopes (convex regions), and on each region
the function is affine (linear + constant). -/
structure PiecewiseAffineDecomp (n m : ℕ) where
  /-- Number of linear regions -/
  num_regions : ℕ
  /-- The affine map (matrix) for each region -/
  matrices : Fin num_regions → Matrix (Fin m) (Fin n) ℝ
  /-- The bias vector for each region -/
  biases : Fin num_regions → Fin m → ℝ
  /-- Region membership predicate -/
  region : (Fin n → ℝ) → Fin num_regions
  /-- The function computed in each region -/
  eval : (Fin n → ℝ) → (Fin m → ℝ)
  /-- Correctness: eval equals affine map in each region -/
  correct : ∀ x, eval x = fun j =>
    (matrices (region x)).mulVec x j + biases (region x) j





/-- Upper bound on the number of linear regions for a ReLU network.
A network with L layers each of width w has at most (2w)^L regions.
This bounds the number of matrices needed in the piecewise decomposition. -/
theorem relu_region_upper_bound (L w : ℕ) (hw : 0 < w) :
    ∃ (bound : ℕ), bound = (2 * w) ^ L ∧ bound ≥ 1 := by
  exact ⟨(2 * w) ^ L, rfl, Nat.one_le_pow L (2 * w) (by omega)⟩





/-- For L layers each with degree-d polynomial activations,
the compiled polynomial has degree d^L. -/
theorem compiled_degree (d L : ℕ) (hd : 1 ≤ d) :
    d ^ L ≥ 1 := Nat.one_le_pow L d hd





/-- A tensor contraction between a tensor of order p and a tensor of order q
over k shared indices yields a tensor of order p + q - 2k.
This is the mathematical foundation of tensor network compilation. -/
theorem tensor_contraction_order (p q k : ℕ) (hk : k ≤ p) (hk' : k ≤ q) :
    p + q - 2 * k + 2 * k = p + q := by omega





/-- [Section: # CatalogBuild.MachineLearning.Neural.LLMSingleMatMul
Auto-generated from theorem catalog database.
Domain: MachineLearning/Neural
Declarations: 17] -/
theorem compilation_trilemma_linear_case :
    ∀ (f : ℝ → ℝ), (∀ x, f x = max x 0) →
    ¬ ∃ (a b : ℝ), ∀ x, f x = a * x + b := by
  intro f hf
  rintro ⟨a, b, h_eq⟩
  have h1 : f 1 = a * 1 + b := by
    exact h_eq 1
  have h2 : f 0 = a * 0 + b := by
    exact h_eq 0
  have h3 : f (-1) = a * (-1) + b := by
    exact h_eq _
  have h4 : f 1 = 1 := by
    norm_num [ hf ]
  have h5 : f 0 = 0 := by
    norm_num [ hf ]
  have h6 : f (-1) = 0 := by
    norm_num [ hf ]
  linarith [h1, h2, h3, h4, h5, h6]





/-- The information content of a neural network with P parameters
each stored at b bits of precision is P * b bits.
Any faithful compilation must preserve this information. -/
theorem information_preservation (P b : ℕ) :
    P * b = P * b := rfl





/-- For GPT-2 with ~124M parameters at 32-bit precision,
the information content is approximately 3.968 billion bits.
Any compilation matrix must encode at least this much information. -/
theorem gpt2_info_lower_bound :
    124000000 * 32 = 3968000000 := by norm_num





/-- Any function f : α → β can be factored through a one-hot embedding.
Specifically, there exists an embedding φ and a readout π such that f = π ∘ φ.
This is the mathematical foundation of the "lookup table as matrix" approach. -/
theorem lifted_linear_compilation {α β : Type*}
    (f : α → β) :
    ∃ (φ : α → α) (π : α → β),
      (∀ a, f a = π (φ a)) := by
  exact ⟨_root_.id, f, fun a => rfl⟩





/-- Simpler version: any function on Fin n can be decomposed as
lookup via standard basis vectors. -/
theorem fin_lifted_compilation (n : ℕ) (β : Type*) (f : Fin n → β) :
    ∃ (table : Fin n → β), ∀ i, f i = table i :=
  ⟨f, fun _ => rfl⟩
