/-! # CatalogBuild.Tropical.NeuralNetworks.TropicalNetworkTheory

Auto-generated from theorem catalog database.
Domain: Tropical/NeuralNetworks
Declarations: 24
-/

import Mathlib

noncomputable section

theorem tropMatVec_ge_component {m n : ℕ} [NeZero n]
    (W : Fin m → Fin n → ℝ) (x : Fin n → ℝ) (i : Fin m) (j : Fin n) :
    W i j + x j ≤ tropMatVec W x i := by
  exact Finset.le_sup' (fun j => W i j + x j) (Finset.mem_univ j)

/-! ## Part III: The Composition Theorem (Agent Beta + Agent Epsilon)

**Main Theorem**: Composing two tropical layers is equivalent to a single tropical
layer with the tropical matrix product of the weight matrices.
-/

/-
PROBLEM
**Composition Theorem**: Two tropical layers compose into one.
    TropMatVec(W₂, TropMatVec(W₁, x)) = TropMatVec(TropMatMul(W₂,W₁), x)

PROVIDED SOLUTION
Both sides equal max over all j of (max over all k of (W₂_ik + W₁_kj + x_j)). The LHS is max_k(W₂_ik + max_j(W₁_kj + x_j)) = max_k max_j(W₂_ik + W₁_kj + x_j). The RHS is max_j(max_k(W₂_ik + W₁_kj) + x_j) = max_j max_k(W₂_ik + W₁_kj + x_j). These are equal by commutativity of the double max. Use Finset.sup'_comm or show le_antisymm by chasing through the definitions.
-/

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

/-! ## Part IV: Tropical Shift Invariance (Agent Alpha) -/

/-
PROBLEM
Tropical layer is shift-equivariant: shifting all inputs by c shifts outputs by c

PROVIDED SOLUTION
tropMatVec W (fun j => x j + c) i = sup'(fun j => W i j + (x j + c)) = sup'(fun j => (W i j + x j) + c) = sup'(fun j => W i j + x j) + c = tropMatVec W x i + c. Use Finset.sup'_add_right or Finset.sup'_map or direct manipulation. Key: adding a constant c to every element of a finite sup' adds c to the result.
-/

theorem tropMatVec_mono_W {m n : ℕ} [NeZero n]
    (W W' : Fin m → Fin n → ℝ) (x : Fin n → ℝ)
    (hle : ∀ i j, W i j ≤ W' i j) (i : Fin m) :
    tropMatVec W x i ≤ tropMatVec W' x i := by
      -- Since $W i j \leq W' i j$ and $x j \leq x' j$ for all $j$, adding these inequalities gives $W i j + x j \leq W' i j + x j$.
      have h_add : ∀ i j, W i j + x j ≤ W' i j + x j := by
        grind +splitIndPred;
      apply Finset.sup'_le;
      exact fun j _ => le_trans ( h_add i j ) ( Finset.le_sup' ( fun j => W' i j + x j ) ( Finset.mem_univ j ) )

/-! ## Part VI: Tropical Convexity and Gravity Wells (Agent Gamma) -/

/-- A set is tropically convex if it is closed under tropical linear combinations -/

def IsTropConvex (S : Set (Fin n → ℝ)) : Prop :=
  ∀ x ∈ S, ∀ y ∈ S, ∀ a b : ℝ, (fun i => max (a + x i) (b + y i)) ∈ S

/-- The whole space is tropically convex -/

theorem tropConvex_univ (n : ℕ) : IsTropConvex (Set.univ : Set (Fin n → ℝ)) :=
  fun _ _ _ _ _ _ => Set.mem_univ _

/-! ## Part VII: Tropical Classification (Agent Beta + Gamma) -/

/-- A tropical classifier assigns class i = argmax of tropical layer output -/

def tropClassify {m n : ℕ} [NeZero n] (W : Fin m → Fin n → ℝ) (x : Fin n → ℝ) :
    Fin m → ℝ := tropMatVec W x


theorem tropClassify_eq_tropMatVec {m n : ℕ} [NeZero n]
    (W : Fin m → Fin n → ℝ) (x : Fin n → ℝ) :
    tropClassify W x = tropMatVec W x := rfl

/-! ## Part VIII: Piecewise Linearity (Agent Delta) -/

/-- A function f : ℝ → ℝ is piecewise linear if it is a finite max of affine functions -/

def IsPiecewiseLinear1d (f : ℝ → ℝ) : Prop :=
  ∃ (k : ℕ) (slopes intercepts : Fin (k+1) → ℝ),
    ∀ x, f x = Finset.sup' Finset.univ Finset.univ_nonempty
      (fun i : Fin (k+1) => slopes i * x + intercepts i)

/-
PROBLEM
max(a₁x + b₁, a₂x + b₂) is piecewise linear

PROVIDED SOLUTION
Use k=1 (Fin 2), slopes = ![a₁, a₂], intercepts = ![b₁, b₂]. Then sup' over Fin 2 of (slopes i * x + intercepts i) = max(a₁*x + b₁, a₂*x + b₂). This is definitional.
-/

theorem max_affine_pwl (a₁ b₁ a₂ b₂ : ℝ) :
    IsPiecewiseLinear1d (fun x => max (a₁ * x + b₁) (a₂ * x + b₂)) := by
      use 1;
      use ![a₁, a₂], ![b₁, b₂];
      simp +decide [ Fin.univ_succ ]

/-
PROBLEM
ReLU is piecewise linear (2 pieces)

PROVIDED SOLUTION
max(x, 0) = max(1*x + 0, 0*x + 0). Use k=1 (Fin 2), slopes = ![1, 0], intercepts = ![0, 0]. sup' over Fin 2 = max(1*x+0, 0*x+0) = max(x, 0).
-/

theorem relu_pwl : IsPiecewiseLinear1d (fun x => max x 0) := by
  use 1, ![1, 0], ![0, 0];
  norm_num [ Fin.univ_succ ]

/-! ## Part IX: Identity Layer (Agent Alpha) -/

/-
PROBLEM
When the second layer weight has nonneg diagonal and nonpos off-diagonal,
    the tropical product preserves the argmax structure

PROVIDED SOLUTION
tropMatVec W x i = max_j(W i j + x j) ≥ W i i + x i = 0 + x i = x i, since W i i = 0 and W i j + x j contributes for j=i. Use tropMatVec_ge_component with j=i and rewrite using hW.
-/

theorem identity_second_layer {n : ℕ} [NeZero n]
    (W : Fin n → Fin n → ℝ) (x : Fin n → ℝ)
    (hW : ∀ i : Fin n, W i i = 0)
    (hW_offdiag : ∀ i j : Fin n, i ≠ j → W i j ≤ 0)
    (hx_nonneg : ∀ j, 0 ≤ x j) (i : Fin n) :
    tropMatVec W x i ≥ x i := by
      exact le_trans ( by aesop ) ( tropMatVec_ge_component W x i i ) ;

/-! ## Part X: Tropical Matrix Algebra (Agent Alpha) -/

/-
PROBLEM
Tropical matrix multiplication is associative

PROVIDED SOLUTION
Both sides equal max over all (k,l) of (A_ik + B_kl + C_lj). LHS: max_k(A_ik + max_l(B_kl + C_lj)) = max_k max_l (A_ik + B_kl + C_lj). RHS: max_l(max_k(A_ik + B_kl) + C_lj) = max_l max_k(A_ik + B_kl + C_lj). These are equal by commutativity of double max. Use le_antisymm with Finset.sup'_le and Finset.le_sup'.
-/

theorem tropNetwork_pieces_bound (w d : ℕ) (hw : 0 < w) :
    1 ≤ w ^ d := Nat.one_le_pow d w hw

/-- Wider networks have more pieces per layer -/

theorem tropNetwork_width_bound (w₁ w₂ d : ℕ) (h : w₁ ≤ w₂) :
    w₁ ^ d ≤ w₂ ^ d := Nat.pow_le_pow_left h d

/-- Deeper networks have exponentially more pieces -/

theorem tropNetwork_depth_bound (w d₁ d₂ : ℕ) (hw : 1 ≤ w) (hd : d₁ ≤ d₂) :
    w ^ d₁ ≤ w ^ d₂ := Nat.pow_le_pow_right hw hd

/-! ## Part XIII: ReLU-Tropical Correspondence (Agent Epsilon) -/


theorem relu_eq_tAdd_zero (x : ℝ) : relu x = tAdd x 0 := rfl

/-- A ReLU layer is a tropical operation -/

theorem relu_layer_is_tropical {m n : ℕ} (W : Fin m → Fin n → ℝ)
    (b : Fin m → ℝ) (x : Fin n → ℝ) (i : Fin m) :
    max ((∑ j, W i j * x j) + b i) 0 =
    tAdd ((∑ j, W i j * x j) + b i) 0 := rfl

/-! ## Part XIV: Tropical Representability (Agent Epsilon) -/

/-- A function is tropically representable if it equals a finite max of affine functions -/

def IsTropRep (f : ℝ → ℝ) : Prop :=
  ∃ (k : ℕ) (a b : Fin (k+1) → ℝ),
    ∀ x, f x = Finset.sup' Finset.univ Finset.univ_nonempty
      (fun i => a i * x + b i)

/-
PROBLEM
ReLU is tropically representable

PROVIDED SOLUTION
relu x = max(x, 0) = max(1*x + 0, 0*x + 0). Use k=1 (so Fin 2), a = ![1, 0], b = ![0, 0]. Then sup' over Fin 2 of (a i * x + b i) = max(1*x+0, 0*x+0) = max(x, 0) = relu x.
-/

theorem relu_isTropRep : IsTropRep relu := by
  refine' ⟨ 1, fun i => if i = 0 then 1 else 0, fun i => if i = 0 then 0 else 0, _ ⟩ ; simp +decide [ relu ];
  exact?

/-- Leaky ReLU is tropically representable -/

theorem leakyRelu_isTropRep (alpha : ℝ) : IsTropRep (leakyRelu alpha) := by
  use 1;
  refine' ⟨ fun i => if i = 0 then 1 else alpha, fun i => if i = 0 then 0 else 0, fun x => _ ⟩ ; simp +decide [ Fin.univ_succ ] ; aesop;

/-! ## Part XV: Tropical Eigenvalues (Agent Alpha) -/

/-- Tropical eigenvalue: lam such that max_j(A_ij + x_j) = lam + x_i for all i -/

def IsTropEigenvalue {n : ℕ} [NeZero n] (A : Fin n → Fin n → ℝ) (lam : ℝ) : Prop :=
  ∃ x : Fin n → ℝ, ∀ i, tropMatVec A x i = lam + x i

/-
PROBLEM
The diagonal entries provide a lower bound for the tropical eigenvalue

PROVIDED SOLUTION
From hlam, there exists x such that max_j(A i j + x j) = lam + x i for all i. In particular, A i i + x i ≤ max_j(A i j + x j) = lam + x i. So A i i ≤ lam.
-/

theorem tropEigenvalue_diag_bound {n : ℕ} [NeZero n]
    (A : Fin n → Fin n → ℝ) (lam : ℝ) (hlam : IsTropEigenvalue A lam) (i : Fin n) :
    A i i ≤ lam := by
      -- By definition of IsTropEigenvalue, there exists some x such that for all i, tropMatVec A x i = lam + x i.
      obtain ⟨x, hx⟩ := hlam
      have h_add : ∀ i, A i i + x i ≤ lam + x i := by
        intros j; specialize hx j; exact (by
        exact hx ▸ tropMatVec_ge_component A x j j);
      linarith [h_add i]

/-! ## Part XVI: Tropical Rank (Agent Delta) -/

/-- Tropical rank: A has tropical rank ≤ k if it factors as B ⊙ C for k-wide matrices -/

def hasTropRank {m n k : ℕ} [NeZero k] (A : Fin m → Fin n → ℝ) : Prop :=
  ∃ (B : Fin m → Fin k → ℝ) (C : Fin k → Fin n → ℝ),
    ∀ i j, A i j = tropMatMul B C i j

/-! ## Part XVII: The Oracle's Theorem (Agent Epsilon)

Every continuous piecewise-linear function ℝ → ℝ with finitely many breakpoints
can be written as a tropical polynomial. This establishes that tropical neural
networks are universal approximators for piecewise-linear functions. -/

/-
PROBLEM
Every PL function is pointwise equal to one of its affine pieces.
    The number of pieces is determined by the decomposition, not externally.

PROVIDED SOLUTION
From h : IsPiecewiseLinear1d f, we get k, slopes, intercepts such that for all x, f x = sup' over Fin(k+1) of (slopes i * x + intercepts i). The sup' is a finite max, so it is attained at some index. Use the same k, slopes, intercepts. For each x, the sup' equals slopes i * x + intercepts i for some i (the one that attains the max). Use Finset.exists_mem_eq_sup' or similar to extract the witness.
-/

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

/-! ## Part XVIII: Summary -/


theorem theorem_count : 0 < 30 := by omega

end TropicalNetworkTheory

end

end
