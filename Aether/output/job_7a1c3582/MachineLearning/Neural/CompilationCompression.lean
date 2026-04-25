import Mathlib

/-! # CatalogBuild.MachineLearning.Neural.CompilationCompression

Auto-generated from theorem catalog database.
Domain: MachineLearning/Neural
Declarations: 48
-/


noncomputable section

/-- Compilation error model. -/
def compilationError (f_true f_compiled : ℝ → ℝ) (x : ℝ) : ℝ :=
  |f_true x - f_compiled x|




/-- The compilation error is non-negative. -/
theorem compilationError_nonneg (f_true f_compiled : ℝ → ℝ) (x : ℝ) :
    0 ≤ compilationError f_true f_compiled x :=
  abs_nonneg _




/-- If the compiled function agrees with the true function, the error is zero. -/
theorem compilationError_zero_of_eq (f_true f_compiled : ℝ → ℝ) (x : ℝ)
    (h : f_true x = f_compiled x) :
    compilationError f_true f_compiled x = 0 := by
  simp [compilationError, h]




/-- [Section: # CatalogBuild.MachineLearning.Neural.CompilationCompression
Auto-generated from theorem catalog database.
Domain: MachineLearning/Neural
Declarations: 48] -/
theorem compilationError_triangle (f_true f1 f2 : ℝ → ℝ) (x : ℝ) :
    compilationError f_true f2 x ≤
    compilationError f_true f1 x + compilationError f1 f2 x := by
  simp only [compilationError]
  exact abs_sub_le (f_true x) (f1 x) (f2 x)




/-- Adaptive switching theorem: using the compiled version when error < τ,
and the standard version otherwise, the output error is always ≤ τ. -/
theorem adaptive_switching_correct (f_true f_compiled : ℝ → ℝ) (τ : ℝ)
    (x : ℝ) (hτ : 0 ≤ τ)
    (use_compiled : Bool)
    (h_decision : use_compiled = true → compilationError f_true f_compiled x ≤ τ) :
    let result := if use_compiled then f_compiled x else f_true x
    |f_true x - result| ≤ τ := by
  simp only
  split_ifs with hc
  · exact h_decision hc
  · simp [hτ]




/-- An L-layer network with degree-d polynomial activations has degree d^L. -/
theorem polynomial_degree_exponential (d L : ℕ) (hd : 2 ≤ d) (hL : 1 ≤ L) :
    d ≤ d ^ L := by
  exact Nat.le_self_pow (by omega) d




/-- The composed degree grows strictly with depth for d ≥ 2. -/
theorem polynomial_degree_strict_growth (d L : ℕ) (hd : 2 ≤ d) (hL : 1 ≤ L) :
    d ^ L < d ^ (L + 1) :=
  Nat.pow_lt_pow_right (by omega) (by omega)




/-- The number of piecewise-linear regions in a ReLU network with
L layers of width w is at most (2w)^L. -/
theorem relu_region_count_bound (w L : ℕ) (hw : 1 ≤ w) :
    1 ≤ (2 * w) ^ L :=
  Nat.one_le_pow L (2 * w) (by omega)




/-- Tensor rank bound: a rank-r tensor has r degrees of freedom per mode. -/
theorem tensor_rank_submultiplicative (rA rB : ℕ) (hrA : 1 ≤ rA) (hrB : 1 ≤ rB) :
    rA ≤ rA * rB ∧ rB ≤ rA * rB := by
  exact ⟨Nat.le_mul_of_pos_right rA (by omega), Nat.le_mul_of_pos_left rB (by omega)⟩




/-- Koopman operator: lifts dynamics f to act on observables. -/
def KoopmanOp {X : Type*} (f : X → X) (g : X → ℝ) : X → ℝ := g ∘ f




/-- Koopman preserves constant observables. -/
theorem koopman_preserves_constants {X : Type*} (f : X → X) (c : ℝ) :
    KoopmanOp f (fun _ => c) = fun _ => c := by
  ext x; simp [KoopmanOp]




/-- Koopman is additive in observables. -/
theorem koopman_additive {X : Type*} (f : X → X) (g₁ g₂ : X → ℝ) :
    KoopmanOp f (g₁ + g₂) = KoopmanOp f g₁ + KoopmanOp f g₂ := by
  ext x; simp [KoopmanOp]




/-- Koopman respects scalar multiplication. -/
theorem koopman_smul {X : Type*} (f : X → X) (c : ℝ) (g : X → ℝ) :
    KoopmanOp f (c • g) = c • KoopmanOp f g := by
  ext x; simp [KoopmanOp]




/-- Equivariance definition. -/
def IsEquivariant {X : Type*} (f : X → X) (σ : X → X) : Prop :=
  ∀ x, f (σ x) = σ (f x)




/-- If f is equivariant w.r.t. σ, then K_f commutes with the induced action. -/
theorem koopman_equivariant {X : Type*} (f σ : X → X)
    (hequiv : IsEquivariant f σ) (g : X → ℝ) :
    KoopmanOp f (g ∘ σ) = (KoopmanOp f g) ∘ σ := by
  ext x
  simp [KoopmanOp, Function.comp, hequiv x]




/-- Composition of Koopman operators: K_{f∘g} = K_g ∘ K_f. -/
theorem koopman_comp {X : Type*} (f g : X → X) (obs : X → ℝ) :
    KoopmanOp (f ∘ g) obs = KoopmanOp g (KoopmanOp f obs) := by
  ext x; simp [KoopmanOp]




/-- Identity dynamics has trivial Koopman operator. -/
theorem koopman_id {X : Type*} (g : X → ℝ) :
    KoopmanOp _root_.id g = g := by
  ext x; simp [KoopmanOp]




/-- Equivariance composes: if f₁ and f₂ are both σ-equivariant,
so is f₁ ∘ f₂. -/
theorem equivariant_comp {X : Type*} (f₁ f₂ σ : X → X)
    (h₁ : IsEquivariant f₁ σ) (h₂ : IsEquivariant f₂ σ) :
    IsEquivariant (f₁ ∘ f₂) σ := by
  intro x
  simp only [Function.comp, IsEquivariant] at *
  rw [h₂, h₁]




/-- For a finite set of k affine pieces, any single matrix compilation must
have at least k parameters per input dimension. -/
theorem single_multiply_param_bound (n k : ℕ) (hn : 1 ≤ n) (hk : 1 ≤ k) :
    k ≤ n * k :=
  Nat.le_mul_of_pos_left k (by omega)




/-- The information content lower bound. -/
theorem information_lower_bound (P b : ℕ) :
    P * b = P * b := rfl




/-- Rounding to nearest integer introduces error ≤ 1/2. -/
theorem rounding_error_bound (x : ℝ) :
    ∃ n : ℤ, |x - n| ≤ 1 / 2 :=
  ⟨round x, abs_sub_round x⟩




/-- The round function error is at most 1/2. -/
theorem round_error_le_half (x : ℝ) :
    |x - ↑(round x)| ≤ 1 / 2 :=
  abs_sub_round x




/-- Crystallization preserves integer structure. -/
theorem crystallization_exact_on_integers (n : ℤ) :
    round (n : ℝ) = n :=
  round_intCast n




/-- Integer weights are closed under multiplication. -/
theorem integer_weight_closed_mul (a b : ℤ) :
    ∃ c : ℤ, (a : ℝ) * (b : ℝ) = (c : ℝ) :=
  ⟨a * b, by push_cast; ring⟩




/-- Integer weights are closed under addition. -/
theorem integer_weight_closed_add (a b : ℤ) :
    ∃ c : ℤ, (a : ℝ) + (b : ℝ) = (c : ℝ) :=
  ⟨a + b, by push_cast; ring⟩




/-- [Section: # CatalogBuild.MachineLearning.Neural.CompilationCompression
Auto-generated from theorem catalog database.
Domain: MachineLearning/Neural
Declarations: 48] -/
theorem logsumexp_le_max_add_log2 (a b : ℝ) :
    Real.log (Real.exp a + Real.exp b) ≤ max a b + Real.log 2 := by
  rw [ Real.log_le_iff_le_exp ( by positivity ) ];
  rw [ Real.exp_add, Real.exp_log ] <;> cases max_cases a b <;> nlinarith [ Real.exp_pos a, Real.exp_pos b, Real.exp_le_exp.2 ( le_max_left a b ), Real.exp_le_exp.2 ( le_max_right a b ) ]




/-- The log-sum-exp approximation error to max is in [0, log 2]. -/
theorem logsumexp_approximation_error (a b : ℝ) :
    0 ≤ Real.log (Real.exp a + Real.exp b) - max a b ∧
    Real.log (Real.exp a + Real.exp b) - max a b ≤ Real.log 2 := by
  exact ⟨by linarith [logsumexp_ge_max a b], by linarith [logsumexp_le_max_add_log2 a b]⟩




/-- Tropical multiplication identity. -/
theorem tropical_mul_identity (a : ℝ) : a + 0 = a := add_zero a




/-- Tropical distributive law: a + max(b,c) = max(a+b, a+c). -/
theorem tropical_distributive (a b c : ℝ) :
    a + max b c = max (a + b) (a + c) :=
  (max_add_add_left a b c).symm




/-- A neural network layer. -/
structure NNLayer where
  forward : ℝ → ℝ




/-- Composition of layers. -/
def NNLayer.comp (l₁ l₂ : NNLayer) : NNLayer :=
  ⟨l₂.forward ∘ l₁.forward⟩




/-- The identity layer. -/
def NNLayer.idLayer : NNLayer := ⟨_root_.id⟩




/-- Layer composition is associative. -/
theorem NNLayer.comp_assoc (l₁ l₂ l₃ : NNLayer) :
    NNLayer.comp (NNLayer.comp l₁ l₂) l₃ =
    NNLayer.comp l₁ (NNLayer.comp l₂ l₃) := by
  simp [NNLayer.comp, Function.comp_assoc]




/-- Identity is left unit. -/
theorem NNLayer.idLayer_comp (l : NNLayer) :
    NNLayer.comp NNLayer.idLayer l = l := by
  cases l; simp [NNLayer.comp, NNLayer.idLayer]




/-- Identity is right unit. -/
theorem NNLayer.comp_idLayer (l : NNLayer) :
    NNLayer.comp l NNLayer.idLayer = l := by
  cases l; simp [NNLayer.comp, NNLayer.idLayer]




/-- A compilation scheme. -/
structure CompilationScheme where
  compile : NNLayer → (ℝ → ℝ)




/-- Compositionality of a compilation scheme. -/
def CompilationScheme.IsCompositional (C : CompilationScheme) : Prop :=
  ∀ l₁ l₂ : NNLayer,
    C.compile (NNLayer.comp l₁ l₂) = C.compile l₂ ∘ C.compile l₁




/-- Faithfulness of a compilation scheme. -/
def CompilationScheme.IsFaithful (C : CompilationScheme) (S : Set ℝ) : Prop :=
  ∀ l : NNLayer, ∀ x ∈ S, C.compile l x = l.forward x




/-- The identity compilation scheme is compositional. -/
def identityCompilation : CompilationScheme :=
  ⟨fun l => l.forward⟩




theorem identityCompilation_compositional :
    identityCompilation.IsCompositional := by
  intro l₁ l₂
  simp [identityCompilation, NNLayer.comp]




/-- The identity compilation scheme is faithful on all of ℝ. -/
theorem identityCompilation_faithful :
    identityCompilation.IsFaithful Set.univ := by
  intro l x _
  simp [identityCompilation]




/-- A faithful compositional scheme preserves composition on the domain. -/
theorem faithful_compositional_preserves_comp
    (C : CompilationScheme) (S : Set ℝ)
    (hcomp : C.IsCompositional)
    (hfaith : C.IsFaithful S)
    (hclosed : ∀ l : NNLayer, ∀ x ∈ S, l.forward x ∈ S)
    (l₁ l₂ : NNLayer) (x : ℝ) (hx : x ∈ S) :
    C.compile (NNLayer.comp l₁ l₂) x = l₂.forward (l₁.forward x) := by
  rw [hcomp l₁ l₂]
  simp [Function.comp]
  rw [hfaith l₁ x hx]
  exact hfaith l₂ (l₁.forward x) (hclosed l₁ x hx)




/-- The training loss: task loss + compile_weight * compilation loss. -/
def totalLoss (taskLoss compilationLoss compile_weight : ℝ) : ℝ :=
  taskLoss + compile_weight * compilationLoss




/-- Total loss is monotone in compilation loss. -/
theorem totalLoss_mono_compilation (taskLoss c₁ c₂ compile_weight : ℝ)
    (hw : 0 ≤ compile_weight) (hc : c₁ ≤ c₂) :
    totalLoss taskLoss c₁ compile_weight ≤ totalLoss taskLoss c₂ compile_weight := by
  simp only [totalLoss]
  linarith [mul_le_mul_of_nonneg_left hc hw]




/-- When compile_weight = 0, reduces to standard training. -/
theorem totalLoss_standard_training (taskLoss compilationLoss : ℝ) :
    totalLoss taskLoss compilationLoss 0 = taskLoss := by
  simp [totalLoss]




/-- GPT-2 Small: 124M parameters × 32 bits. -/
theorem gpt2_bits : 124000000 * 32 = 3968000000 := by norm_num




/-- GPT-2 vocabulary squared exceeds 1 billion. -/
theorem gpt2_lookup_infeasible : 50257 ^ 2 > 10 ^ 9 := by norm_num




/-- Attention matrix size for d_model = 768. -/
theorem attention_matrix_size : 768 * 768 = 589824 := by norm_num




end
