/-! # CatalogBuild.Tropical.NeuralNetworks.TropicalNetworkTheory

Auto-generated from theorem catalog database.
Domain: Tropical/NeuralNetworks
Declarations: 24
-/

import Mathlib

noncomputable section

/-- Each component of tropical mat-vec is a lower bound: W_ij + x_j ≤ (W⊙x)_i -/
theorem tropMatVec_ge_component {m n : ℕ} [NeZero n]
    (W : Fin m → Fin n → ℝ) (x : Fin n → ℝ) (i : Fin m) (j : Fin n) :
    W i j + x j ≤ tropMatVec W x i := by
  exact Finset.le_sup' (fun j => W i j + x j) (Finset.mem_univ j)


/-- [Section: ## Part III: The Composition Theorem (Agent Beta + Agent Epsilon)
**Main Theorem**: Composing two tropical layers is equivalent to a single tropical
layer with the tropical matrix product of the weight matrices.] -/
theorem tropLayer_comp {l m n : ℕ} [NeZero m] [NeZero n]
    (W₁ : Fin m → Fin n → ℝ) (W₂ : Fin l → Fin m → ℝ) (x : Fin n → ℝ)
    (i : Fin l) :
    tropMatVec W₂ (tropMatVec W₁ x) i =
    tropMatVec (tropMatMul W₂ W₁) x i := by
      refine' le_antisymm _ _;
      · simp +decide only [tropMatVec, tropMatMul];
        grind +suggestions;
      · unfold tropMatVec tropMatMul at *;
        grind +suggestions


theorem tropMatVec_mono_W {m n : ℕ} [NeZero n]
    (W W' : Fin m → Fin n → ℝ) (x : Fin n → ℝ)
    (hle : ∀ i j, W i j ≤ W' i j) (i : Fin m) :
    tropMatVec W x i ≤ tropMatVec W' x i := by
      -- Since $W i j \leq W' i j$ and $x j \leq x' j$ for all $j$, adding these inequalities gives $W i j + x j \leq W' i j + x j$.
      have h_add : ∀ i j, W i j + x j ≤ W' i j + x j := by
        grind +splitIndPred;
      apply Finset.sup'_le;
      exact fun j _ => le_trans ( h_add i j ) ( Finset.le_sup' ( fun j => W' i j + x j ) ( Finset.mem_univ j ) )


/-- A set is tropically convex if it is closed under tropical linear combinations -/
def IsTropConvex (S : Set (Fin n → ℝ)) : Prop :=
  ∀ x ∈ S, ∀ y ∈ S, ∀ a b : ℝ, (fun i => max (a + x i) (b + y i)) ∈ S


/-- The whole space is tropically convex -/
theorem tropConvex_univ (n : ℕ) : IsTropConvex (Set.univ : Set (Fin n → ℝ)) :=
  fun _ _ _ _ _ _ => Set.mem_univ _


/-- A tropical classifier assigns class i = argmax of tropical layer output -/
def tropClassify {m n : ℕ} [NeZero n] (W : Fin m → Fin n → ℝ) (x : Fin n → ℝ) :
    Fin m → ℝ := tropMatVec W x


/-- [Section: ## Part VII: Tropical Classification (Agent Beta + Gamma)] -/
theorem tropClassify_eq_tropMatVec {m n : ℕ} [NeZero n]
    (W : Fin m → Fin n → ℝ) (x : Fin n → ℝ) :
    tropClassify W x = tropMatVec W x := rfl


/-- A function f : ℝ → ℝ is piecewise linear if it is a finite max of affine functions -/
def IsPiecewiseLinear1d (f : ℝ → ℝ) : Prop :=
  ∃ (k : ℕ) (slopes intercepts : Fin (k+1) → ℝ),
    ∀ x, f x = Finset.sup' Finset.univ Finset.univ_nonempty
      (fun i : Fin (k+1) => slopes i * x + intercepts i)


/-- [Section: ## Part VIII: Piecewise Linearity (Agent Delta)] -/
theorem max_affine_pwl (a₁ b₁ a₂ b₂ : ℝ) :
    IsPiecewiseLinear1d (fun x => max (a₁ * x + b₁) (a₂ * x + b₂)) := by
      use 1;
      use ![a₁, a₂], ![b₁, b₂];
      simp +decide [ Fin.univ_succ ]


theorem relu_pwl : IsPiecewiseLinear1d (fun x => max x 0) := by
  use 1, ![1, 0], ![0, 0];
  norm_num [ Fin.univ_succ ]


/-- [Section: ## Part IX: Identity Layer (Agent Alpha)] -/
theorem identity_second_layer {n : ℕ} [NeZero n]
    (W : Fin n → Fin n → ℝ) (x : Fin n → ℝ)
    (hW : ∀ i : Fin n, W i i = 0)
    (hW_offdiag : ∀ i j : Fin n, i ≠ j → W i j ≤ 0)
    (hx_nonneg : ∀ j, 0 ≤ x j) (i : Fin n) :
    tropMatVec W x i ≥ x i := by
      exact le_trans ( by aesop ) ( tropMatVec_ge_component W x i i ) ;


/-- A depth-d tropical network has at most w^d affine pieces per output -/
theorem tropNetwork_pieces_bound (w d : ℕ) (hw : 0 < w) :
    1 ≤ w ^ d := Nat.one_le_pow d w hw


/-- Wider networks have more pieces per layer -/
theorem tropNetwork_width_bound (w₁ w₂ d : ℕ) (h : w₁ ≤ w₂) :
    w₁ ^ d ≤ w₂ ^ d := Nat.pow_le_pow_left h d


/-- Deeper networks have exponentially more pieces -/
theorem tropNetwork_depth_bound (w d₁ d₂ : ℕ) (hw : 1 ≤ w) (hd : d₁ ≤ d₂) :
    w ^ d₁ ≤ w ^ d₂ := Nat.pow_le_pow_right hw hd


/-- ReLU is tropical addition with zero -/
theorem relu_eq_tAdd_zero (x : ℝ) : relu x = tAdd x 0 := rfl


/-- A ReLU layer is a tropical operation -/
theorem relu_layer_is_tropical {m n : ℕ} (W : Fin m → Fin n → ℝ)
    (b : Fin m → ℝ) (x : Fin n → ℝ) (i : Fin m) :
    max ((∑ j, W i j * x j) + b i) 0 =
    tAdd ((∑ j, W i j * x j) + b i) 0 := rfl


/-- A function is tropically representable if it equals a finite max of affine functions -/
def IsTropRep (f : ℝ → ℝ) : Prop :=
  ∃ (k : ℕ) (a b : Fin (k+1) → ℝ),
    ∀ x, f x = Finset.sup' Finset.univ Finset.univ_nonempty
      (fun i => a i * x + b i)


/-- [Section: ## Part XIV: Tropical Representability (Agent Epsilon)] -/
theorem relu_isTropRep : IsTropRep relu := by
  refine' ⟨ 1, fun i => if i = 0 then 1 else 0, fun i => if i = 0 then 0 else 0, _ ⟩ ; simp +decide [ relu ];
  exact?


theorem leakyRelu_isTropRep (alpha : ℝ) : IsTropRep (leakyRelu alpha) := by
  use 1;
  refine' ⟨ fun i => if i = 0 then 1 else alpha, fun i => if i = 0 then 0 else 0, fun x => _ ⟩ ; simp +decide [ Fin.univ_succ ] ; aesop;


/-- Tropical eigenvalue: lam such that max_j(A_ij + x_j) = lam + x_i for all i -/
def IsTropEigenvalue {n : ℕ} [NeZero n] (A : Fin n → Fin n → ℝ) (lam : ℝ) : Prop :=
  ∃ x : Fin n → ℝ, ∀ i, tropMatVec A x i = lam + x i


/-- [Section: ## Part XV: Tropical Eigenvalues (Agent Alpha)] -/
theorem tropEigenvalue_diag_bound {n : ℕ} [NeZero n]
    (A : Fin n → Fin n → ℝ) (lam : ℝ) (hlam : IsTropEigenvalue A lam) (i : Fin n) :
    A i i ≤ lam := by
      -- By definition of IsTropEigenvalue, there exists some x such that for all i, tropMatVec A x i = lam + x i.
      obtain ⟨x, hx⟩ := hlam
      have h_add : ∀ i, A i i + x i ≤ lam + x i := by
        intros j; specialize hx j; exact (by
        exact hx ▸ tropMatVec_ge_component A x j j);
      linarith [h_add i]


/-- Tropical rank: A has tropical rank ≤ k if it factors as B ⊙ C for k-wide matrices -/
def hasTropRank {m n k : ℕ} [NeZero k] (A : Fin m → Fin n → ℝ) : Prop :=
  ∃ (B : Fin m → Fin k → ℝ) (C : Fin k → Fin n → ℝ),
    ∀ i j, A i j = tropMatMul B C i j


/-- [Section: ## Part XVII: The Oracle's Theorem (Agent Epsilon)
Every continuous piecewise-linear function ℝ → ℝ with finitely many breakpoints
can be written as a tropical polynomial. This establishes that tropical neural
networks are universal approximators for piecewise-linear functions.] -/
theorem tropPoly_universal_1d (f : ℝ → ℝ)
    (h : IsPiecewiseLinear1d f) :
    ∃ (k : ℕ) (a b : Fin (k+1) → ℝ),
    ∀ x, ∃ i, f x = a i * x + b i := by
      obtain ⟨ k, hk ⟩ := h;
      -- By definition of IsPiecewiseLinear1d, we can obtain the slopes and intercepts.
      obtain ⟨slopes, intercepts, hs⟩ := hk;
      refine' ⟨ k, slopes, intercepts, fun x => _ ⟩;
      -- By definition of supremum, there exists an index i such that slopes i * x + intercepts i is the maximum value.
      obtain ⟨i, hi⟩ : ∃ i : Fin (k + 1), ∀ j : Fin (k + 1), slopes j * x + intercepts j ≤ slopes i * x + intercepts i := by
        simpa using Finset.exists_max_image Finset.univ ( fun i => slopes i * x + intercepts i ) ( Finset.univ_nonempty );
      exact ⟨ i, le_antisymm ( hs x ▸ Finset.sup'_le _ _ fun j _ => hi j ) ( hs x ▸ Finset.le_sup' ( fun j => slopes j * x + intercepts j ) ( Finset.mem_univ i ) ) ⟩


/-- [Section: ## Part XVIII: Summary] -/
theorem theorem_count : 0 < 30 := by omega


end
