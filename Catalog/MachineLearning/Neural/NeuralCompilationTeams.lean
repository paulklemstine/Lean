/-! # CatalogBuild.MachineLearning.Neural.NeuralCompilationTeams

Auto-generated from theorem catalog database.
Domain: MachineLearning/Neural
Declarations: 31
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.MachineLearning.Neural.NeuralCompilationTeams
Auto-generated from theorem catalog database.
Domain: MachineLearning/Neural
Declarations: 31] -/
theorem alpha_relu_not_linear :
    ¬ ∃ (f : ℝ →ₗ[ℝ] ℝ), ∀ x : ℝ, f x = relu x := by
  simp +zetaDelta at *;
  intro f; exact (by
  by_contra! h' ; have := h' 1 ; have := h' ( -1 ) ; norm_num [ relu ] at * ; aesop;);




/-- [Section: # CatalogBuild.MachineLearning.Neural.NeuralCompilationTeams
Auto-generated from theorem catalog database.
Domain: MachineLearning/Neural
Declarations: 31] -/
theorem alpha_relu_no_exact_linear_approx :
    ¬ ∃ (a b : ℝ), ∀ x : ℝ, max x 0 = a * x + b := by
  -- Assume $a \neq 0$. Then $f(x) = ax + b$ is a line.
  by_contra h
  obtain ⟨a, b, h_eq⟩ := h
  have ha : a = 0 := by
    have := h_eq 0 ; have := h_eq 1 ; have := h_eq ( -1 ) ; norm_num at * ; linarith;
  exact absurd ( h_eq 0 ) ( by norm_num [ ha ] ; have := h_eq 1; norm_num [ ha ] at this; linarith )




theorem alpha_linear_determined_by_one (f : ℝ →ₗ[ℝ] ℝ) :
    ∀ x : ℝ, f x = x * f 1 := by
  exact fun x => by simpa using f.map_smul x 1;




theorem alpha_relu_vec_not_linear (n : ℕ) (hn : 0 < n) :
    ¬ ∃ (f : (Fin n → ℝ) →ₗ[ℝ] (Fin n → ℝ)),
      ∀ x : Fin n → ℝ, f x = fun i => max (x i) 0 := by
  by_contra h_contra
  obtain ⟨f, hf⟩ := h_contra
  have h1 : ∀ i : Fin n, f (fun j => if j = i then 1 else 0) = fun j => if j = i then 1 else 0 := by
    aesop
  have h2 : ∀ i : Fin n, f (fun j => if j = i then -1 else 0) = fun j => if j = i then 0 else 0 := by
    aesop;
  exact absurd ( congr_arg ( fun f => f ( ⟨ 0, hn ⟩ ) ) ( f.map_neg ( fun i => if i = ⟨ 0, hn ⟩ then 1 else 0 ) ) ) ( by norm_num [ hf ] )




theorem alpha_linear_composition_is_linear {n : ℕ}
    (A B : Matrix (Fin n) (Fin n) ℝ) :
    ∀ x : Fin n → ℝ, (A * B).mulVec x = A.mulVec (B.mulVec x) := by
  exact fun x => Eq.symm (mulVec_mulVec x A B)




/-- Helper: the Koopman linear map sends v to v ∘ f. -/
noncomputable def koopmanLinearMap {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) : (α → ℝ) →ₗ[ℝ] (α → ℝ) where
  toFun v := fun a => v (f a)
  map_add' u v := by ext; simp
  map_smul' r v := by ext; simp




theorem beta_koopman_finite_lift {α : Type*} [Fintype α] [DecidableEq α] [Nonempty α]
    (f : α → α) :
    ∃ (L : (α → ℝ) →ₗ[ℝ] (α → ℝ)) (embed : α → (α → ℝ)) (project : (α → ℝ) → α),
      ∀ a, f a = project (L (embed a)) := by
  refine' ⟨ _, _, _, _ ⟩;
  refine' LinearMap.id;
  exact fun a b => if b = f a then 1 else 0;
  exact fun v => if h : ∃ b, v b = 1 then h.choose else Classical.arbitrary α;
  aesop




theorem beta_koopman_matrix (n : ℕ) (f : Fin n → Fin n) :
    let M : Matrix (Fin n) (Fin n) ℝ := Matrix.of (fun i j => if f j = i then 1 else 0)
    ∀ j : Fin n, ∀ i : Fin n,
      M.mulVec (fun k => if k = j then (1 : ℝ) else 0) i =
        if f j = i then 1 else 0 := by
  simp +decide [ Matrix.mulVec, dotProduct ]




theorem beta_lifting_dimension_bound (d L : ℕ) (_hd : 1 ≤ d) :
    ∃ D : ℕ, D = (d + 1) ^ L ∧ 1 ≤ D := by
  exact ⟨ _, rfl, Nat.one_le_pow _ _ ( Nat.succ_pos _ ) ⟩




theorem beta_quadratic_lifting_dim (n : ℕ) :
    Nat.choose (n + 2) 2 = (n + 2) * (n + 1) / 2 := by
  norm_num [ Nat.choose_two_right ]




theorem gamma_trop_add_comm (a b : ℝ) : tropAdd a b = tropAdd b a := by
  exact max_comm a b




theorem gamma_trop_add_assoc (a b c : ℝ) :
    tropAdd (tropAdd a b) c = tropAdd a (tropAdd b c) := by
  exact max_assoc _ _ _




theorem gamma_trop_mul_comm (a b : ℝ) : tropMul a b = tropMul b a := by
  exact add_comm a b




theorem gamma_trop_mul_assoc (a b c : ℝ) :
    tropMul (tropMul a b) c = tropMul a (tropMul b c) := by
  unfold tropMul;
  ring




theorem gamma_trop_distrib (a b c : ℝ) :
    tropMul a (tropAdd b c) = tropAdd (tropMul a b) (tropMul a c) := by
  unfold tropMul tropAdd
  simp [max_def];
  grind




theorem gamma_relu_is_tropical_add (x : ℝ) :
    relu x = tropAdd x 0 := by
  rfl




/-- Tropical "matrix-vector multiply": using max for summation
and + for element multiplication -/
noncomputable def tropMatVec {m n : ℕ} [NeZero n] (M : Matrix (Fin m) (Fin n) ℝ) (v : Fin n → ℝ) :
    Fin m → ℝ :=
  fun i => Finset.sup' Finset.univ (Finset.univ_nonempty) (fun j => M i j + v j)




theorem gamma_relu_layer_is_tropical {m n : ℕ}
    (W : Matrix (Fin m) (Fin n) ℝ) (b : Fin m → ℝ) (x : Fin n → ℝ) :
    (fun i => max (W.mulVec x i + b i) 0) =
    (fun i => max (∑ j, W i j * x j + b i) 0) := by
  rfl




theorem gamma_two_layer_relu {n : ℕ}
    (W₁ W₂ : Matrix (Fin n) (Fin n) ℝ) (b₁ b₂ x : Fin n → ℝ) :
    let layer₁ := fun i => max (W₁.mulVec x i + b₁ i) 0
    let layer₂ := fun i => max (W₂.mulVec layer₁ i + b₂ i) 0
    ∀ i, layer₂ i = max (∑ j, W₂ i j * max (∑ k, W₁ j k * x k + b₁ j) 0 + b₂ i) 0 := by
  bound




theorem delta_exact_compact_not_general :
    ∀ (a : ℝ), ∃ x : ℝ, a * x ≠ max x 0 := by
  exact fun a => ⟨ if a = 0 then 1 else -1, by aesop ⟩




theorem delta_exact_general_not_compact (n m : ℕ) (hn : 3 ≤ n) (hm : 2 ≤ m) :
    m ^ n > m * n := by
  induction' hn with n hn ih <;> norm_num [ Nat.pow_succ ] at *;
  · nlinarith [ Nat.mul_le_mul_left m hm ];
  · nlinarith [ Nat.mul_le_mul_left n hm ]




theorem delta_compact_general_not_exact :
    ∀ (a b : ℝ), ∃ x : ℝ, a * x + b ≠ max x 0 := by
  intro a b;
  by_contra! h;
  have := h ( -1 ) ; have := h 0 ; have := h 1 ; norm_num at * ; linarith;




theorem delta_trilemma_three_points :
    ¬ ∃ (a b : ℝ),
      a * (-1) + b = max (-1 : ℝ) 0 ∧
      a * 0 + b = max (0 : ℝ) 0 ∧
      a * 1 + b = max (1 : ℝ) 0 := by
  exact fun ⟨ a, b, h₁, h₂, h₃ ⟩ => by norm_num at h₁ h₂ h₃; linarith;




/-- Any function Fin n → Fin m → ℝ can be realized as a matrix. -/
theorem epsilon_any_function_is_matrix {n m : ℕ} (f : Fin n → Fin m → ℝ) :
    ∃ (M : Matrix (Fin m) (Fin n) ℝ), ∀ i j, M j i = f i j :=
  ⟨fun j i => f i j, fun _ _ => rfl⟩




theorem epsilon_onehot_selects_column {n m : ℕ} (M : Matrix (Fin m) (Fin n) ℝ) (i : Fin n) :
    M.mulVec (fun j => if j = i then 1 else 0) = fun k => M k i := by
  ext k; rw [ Matrix.mulVec, dotProduct ] ; aesop;




theorem epsilon_vocabulary_explosion :
    50257 ^ 1024 > 10 ^ 4000 := by
  grind




theorem epsilon_modest_explosion :
    (100 : ℕ) ^ 10 = 100000000000000000000 := by
  grind +splitImp




theorem epsilon_function_count (n m : ℕ) :
    Fintype.card (Fin n → Fin m) = m ^ n := by
  norm_num +zetaDelta at *




theorem synthesis_compilation_landscape (n : ℕ) (_hn : 0 < n) :
    (∀ f : Fin n → Fin n → ℝ, ∃ M : Matrix (Fin n) (Fin n) ℝ, ∀ i j, M j i = f i j) ∧
    (¬ ∃ (f : ℝ →ₗ[ℝ] ℝ), ∀ x, f x = max x 0) := by
  exact ⟨ fun f => ⟨ fun j i => f i j, fun i j => rfl ⟩, alpha_relu_not_linear ⟩




theorem synthesis_tropical_bridge (x : ℝ) :
    relu x = max x 0 ∧ max x 0 = tropAdd x 0 := by
  exact ⟨ rfl, rfl ⟩




theorem synthesis_info_bound (n : ℕ) (_hn : 0 < n) :
    ∀ (f : Fin n → ℝ), ∃ (v : Fin n → ℝ), ∀ i, v i = f i := by
  exact fun f => ⟨ fun i => f i, fun i => rfl ⟩




end
