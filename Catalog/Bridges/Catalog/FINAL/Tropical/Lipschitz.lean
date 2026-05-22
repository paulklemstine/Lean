/-
# Tropical Network Compositional Stability

This module formalizes the fundamental stability theorem for tropical (max-plus)
neural network aggregation: **depth does not amplify Lipschitz constant**.

## Mathematical Content

A tropical aggregation layer is defined as:
  (tropicalAgg W x) j = sup_i (W i j + x i)

The main results are:
1. Each layer is 1-Lipschitz in the sup norm (nonexpansive).
2. Composition of layers remains 1-Lipschitz at any depth.
3. Tropical composition equals max-plus matrix multiplication.
4. Max-plus matrix multiplication is associative.
5. Translation equivariance: tropicalAgg W (x + c) = tropicalAgg W x + c.

## Significance

This is the tropical analogue of nonexpansive semantics. Unlike standard neural
networks where Lipschitz constants multiply with depth, tropical layers compose
without amplification. This has consequences for:
- Certified robustness of tropical architectures
- Dynamic programming / Bellman operator stability
- Compositional verification of layered systems
-/

import Mathlib

open Finset

/-! ## Definitions -/

/-- Tropical aggregation: the max-plus analogue of matrix-vector multiplication.
    Given weights W : ι → κ → ℝ and input x : ι → ℝ, produces output
    (tropicalAgg W x) j = sup_{i ∈ ι} (W i j + x i). -/
noncomputable def tropicalAgg {ι κ : Type*} [Fintype ι] [Nonempty ι]
    [Fintype κ] [Nonempty κ]
    (W : ι → κ → ℝ) (x : ι → ℝ) : κ → ℝ :=
  fun j => Finset.univ.sup' Finset.univ_nonempty (fun i => W i j + x i)

/-- Finite sup norm: ‖x‖_∞ = sup_i |x i|. -/
noncomputable def supNorm {ι : Type*} [Fintype ι] [Nonempty ι] (x : ι → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun i => |x i|)

/-- Tropical matrix composition (max-plus matrix multiplication):
    (tropicalCompose W₁ W₂) i k = sup_j (W₁ i j + W₂ j k). -/
noncomputable def tropicalCompose {ι κ η : Type*} [Fintype ι] [Nonempty ι]
    [Fintype κ] [Nonempty κ] [Fintype η] [Nonempty η]
    (W₁ : ι → κ → ℝ) (W₂ : κ → η → ℝ) : ι → η → ℝ :=
  fun i k => Finset.univ.sup' Finset.univ_nonempty (fun j => W₁ i j + W₂ j k)

/-! ## Helper Lemmas -/

/-
sup' is monotone: if f i ≤ g i for all i, then sup' f ≤ sup' g.
-/
lemma sup'_le_sup'_of_le {ι : Type*} [Fintype ι] [Nonempty ι] {f g : ι → ℝ}
    (h : ∀ i, f i ≤ g i) :
    Finset.univ.sup' Finset.univ_nonempty f ≤ Finset.univ.sup' Finset.univ_nonempty g := by
  exact sup'_mono_fun fun b a => h b

/-
Each element is ≤ the sup'.
-/
lemma le_sup'_of_mem {ι : Type*} [Fintype ι] [Nonempty ι] (f : ι → ℝ) (i : ι) :
    f i ≤ Finset.univ.sup' Finset.univ_nonempty f := by
  exact Finset.le_sup' f ( Finset.mem_univ i )

/-
sup' of (f + c) = sup' f + c for constant c.
-/
lemma sup'_add_const {ι : Type*} [Fintype ι] [Nonempty ι] (f : ι → ℝ) (c : ℝ) :
    Finset.univ.sup' Finset.univ_nonempty (fun i => f i + c) =
    Finset.univ.sup' Finset.univ_nonempty f + c := by
  refine' le_antisymm _ _ <;> norm_num [ Finset.sup'_eq_sup, Finset.sup_le_iff ] at *;
  · exact fun i => ⟨ i, le_rfl ⟩;
  · simpa using Finset.exists_max_image Finset.univ f ( Finset.univ_nonempty )

/-
Pointwise bound: if ∀ i, f i ≤ c, then sup' f ≤ c.
-/
lemma sup'_le_of_forall_le {ι : Type*} [Fintype ι] [Nonempty ι] (f : ι → ℝ) (c : ℝ)
    (h : ∀ i, f i ≤ c) :
    Finset.univ.sup' Finset.univ_nonempty f ≤ c := by
  -- Apply the definition of supremum to find such an element.
  apply Finset.sup'_le; aesop

/-! ## Translation Equivariance -/

/-
**Translation equivariance**: tropical aggregation commutes with adding a constant.
    tropicalAgg W (x + c) = tropicalAgg W x + c.
    This is a key structural identity: max-plus layers are "affine" in the tropical sense.
-/
theorem tropicalAgg_add_const
    {ι κ : Type*} [Fintype ι] [Nonempty ι] [Fintype κ] [Nonempty κ]
    (W : ι → κ → ℝ) (x : ι → ℝ) (c : ℝ) :
    tropicalAgg W (fun i => x i + c)
      = fun j => tropicalAgg W x j + c := by
  funext j;
  convert sup'_add_const _ _;
  exact congr_arg _ ( funext fun i => by ring );
  infer_instance

/-! ## Core Lipschitz Theorems -/

/-
**Pointwise nonexpansiveness**: for each output coordinate j,
    |tropicalAgg W x j - tropicalAgg W y j| ≤ sup_i |x i - y i|.

    Proof idea: From x i ≤ y i + δ (where δ = sup |x-y|), we get
    W i j + x i ≤ W i j + y i + δ, hence sup_i(W i j + x i) ≤ sup_i(W i j + y i) + δ.
    Symmetrize to get the absolute value bound.
-/
theorem tropicalAgg_lipschitz_one
    {ι κ : Type*} [Fintype ι] [Nonempty ι] [Fintype κ] [Nonempty κ]
    (W : ι → κ → ℝ) :
    ∀ x y : ι → ℝ,
      (∀ j, |tropicalAgg W x j - tropicalAgg W y j| ≤
            Finset.univ.sup' Finset.univ_nonempty (fun i => |x i - y i|)) := by
  intro x y j;
  -- Let's denote δ := sup_i |x_i - y_i|.
  set δ := (Finset.univ.sup' Finset.univ_nonempty (fun i => (abs ((x i) - (y i))))) with hδ_def;
  -- By definition of $δ$, we know that for all $i$, $x_i ≤ y_i + δ$ and $y_i ≤ x_i + δ$.
  have h_bounds : ∀ i, x i ≤ y i + δ ∧ y i ≤ x i + δ := by
    exact fun i => ⟨ by linarith [ abs_le.mp ( Finset.le_sup' ( fun i => |x i - y i| ) ( Finset.mem_univ i ) ) ], by linarith [ abs_le.mp ( Finset.le_sup' ( fun i => |x i - y i| ) ( Finset.mem_univ i ) ) ] ⟩;
  -- Applying the bounds to the supremum, we get $tropicalAgg W x j \leq tropicalAgg W y j + δ$ and $tropicalAgg W y j \leq tropicalAgg W x j + δ$.
  have h_tropical_bounds : tropicalAgg W x j ≤ tropicalAgg W y j + δ ∧ tropicalAgg W y j ≤ tropicalAgg W x j + δ := by
    constructor <;> unfold tropicalAgg;
    · simp_all +decide [ Finset.sup'_le_iff ];
      exact fun i => by linarith [ h_bounds i, Finset.le_sup' ( fun i => W i j + y i ) ( Finset.mem_univ i ) ] ;
    · simp +decide [ Finset.sup'_le_iff ];
      exact fun i => by linarith [ h_bounds i, Finset.le_sup' ( fun i => W i j + x i ) ( Finset.mem_univ i ) ] ;
  exact abs_sub_le_iff.mpr ⟨ by linarith, by linarith ⟩

/-
**Sup-norm nonexpansiveness**: the tropical aggregation operator is 1-Lipschitz
    in the finite sup norm.
    ‖tropicalAgg W x - tropicalAgg W y‖_∞ ≤ ‖x - y‖_∞
-/
theorem tropicalAgg_nonexpansive_supNorm
    {ι κ : Type*} [Fintype ι] [Nonempty ι] [Fintype κ] [Nonempty κ]
    (W : ι → κ → ℝ) :
    ∀ x y : ι → ℝ,
      (Finset.univ.sup' Finset.univ_nonempty
        (fun j => |tropicalAgg W x j - tropicalAgg W y j|))
      ≤
      (Finset.univ.sup' Finset.univ_nonempty
        (fun i => |x i - y i|)) := by
  exact fun x y => Finset.sup'_le _ _ fun j _ => tropicalAgg_lipschitz_one W x y j

/-
**Two-layer composition is 1-Lipschitz**: composing two tropical layers
    does not amplify the Lipschitz constant beyond 1.
-/
theorem tropicalAgg_comp_lipschitz
    {ι₀ ι₁ ι₂ : Type*} [Fintype ι₀] [Nonempty ι₀] [Fintype ι₁] [Nonempty ι₁]
    [Fintype ι₂] [Nonempty ι₂]
    (W₁ : ι₀ → ι₁ → ℝ) (W₂ : ι₁ → ι₂ → ℝ) :
    ∀ x y : ι₀ → ℝ,
      (Finset.univ.sup' Finset.univ_nonempty
        (fun k => |tropicalAgg W₂ (tropicalAgg W₁ x) k
                 - tropicalAgg W₂ (tropicalAgg W₁ y) k|))
      ≤
      (Finset.univ.sup' Finset.univ_nonempty
        (fun i => |x i - y i|)) := by
  intro x y;
  refine' le_trans ( tropicalAgg_nonexpansive_supNorm W₂ _ _ ) _;
  convert tropicalAgg_nonexpansive_supNorm W₁ x y using 1

/-! ## Algebraic Structure: Tropical Composition -/

/-
**Composition theorem**: composing two tropical layers equals one layer with
    tropically composed weights. This is the "depth compression" theorem:
    tropicalAgg W₂ (tropicalAgg W₁ x) = tropicalAgg (tropicalCompose W₁ W₂) x.

    This means any finite tropical network can be algebraically collapsed into
    a single max-plus linear operator.
-/
theorem tropicalAgg_compose
    {ι κ η : Type*} [Fintype ι] [Nonempty ι] [Fintype κ] [Nonempty κ]
    [Fintype η] [Nonempty η]
    (W₁ : ι → κ → ℝ) (W₂ : κ → η → ℝ) (x : ι → ℝ) :
    tropicalAgg W₂ (tropicalAgg W₁ x)
      = tropicalAgg (tropicalCompose W₁ W₂) x := by
  funext k;
  simp +decide [ tropicalAgg, tropicalCompose ];
  refine' le_antisymm ( Finset.sup'_le _ _ fun j _ => _ ) ( Finset.sup'_le _ _ fun i _ => _ );
  · obtain ⟨ b, hb ⟩ := Finset.exists_max_image Finset.univ ( fun i => W₁ i j + x i ) ⟨ Classical.arbitrary ι, Finset.mem_univ _ ⟩;
    grind +suggestions;
  · have := Finset.exists_max_image Finset.univ ( fun j => W₁ i j + W₂ j k ) ⟨ Classical.arbitrary κ, Finset.mem_univ _ ⟩;
    grind +suggestions

/-
**Associativity of tropical composition**: max-plus matrix multiplication
    is associative. This is essential for collapsing multi-layer networks.
-/
theorem tropicalAgg_assoc
    {ι κ η μ : Type*}
    [Fintype ι] [Nonempty ι] [Fintype κ] [Nonempty κ]
    [Fintype η] [Nonempty η] [Fintype μ] [Nonempty μ]
    (W₁ : ι → κ → ℝ) (W₂ : κ → η → ℝ) (W₃ : η → μ → ℝ) :
    tropicalCompose (tropicalCompose W₁ W₂) W₃
      = tropicalCompose W₁ (tropicalCompose W₂ W₃) := by
  unfold tropicalCompose at *;
  simp +decide [Finset.sup'_eq_csSup_image];
  ext i k;
  rw [ @csSup_eq_of_forall_le_of_forall_lt_exists_gt ];
  · exact ⟨ _, ⟨ Classical.arbitrary η, rfl ⟩ ⟩;
  · simp +decide [ Set.range ];
    intro a
    have h_le : ∀ y : κ, W₁ i y + W₂ y a + W₃ a k ≤ sSup {x | ∃ y, W₁ i y + sSup {x | ∃ y_1, W₂ y y_1 + W₃ y_1 k = x} = x} := by
      intro y
      have h_le : W₂ y a + W₃ a k ≤ sSup {x | ∃ y_1, W₂ y y_1 + W₃ y_1 k = x} := by
        exact le_csSup ( Set.finite_range _ |> Set.Finite.bddAbove ) ⟨ a, rfl ⟩;
      linarith [ le_csSup ( show BddAbove { x : ℝ | ∃ y : κ, W₁ i y + sSup { x : ℝ | ∃ y_1 : η, W₂ y y_1 + W₃ y_1 k = x } = x } from Set.finite_range _ |> Set.Finite.bddAbove ) ⟨ y, rfl ⟩ ];
    convert h_le ( Classical.choose ( show ∃ y, W₁ i y + W₂ y a = sSup { x | ∃ y, W₁ i y + W₂ y a = x } from by
                                        exact ( IsCompact.sSup_mem ( Set.finite_range _ |> Set.Finite.isCompact ) <| Set.nonempty_of_mem <| Set.mem_range_self <| Classical.arbitrary _ ) ) ) using 1
    generalize_proofs at *;
    rw [ Classical.choose_spec ‹∃ x, W₁ i x + W₂ x a = sSup { x | ∃ y, W₁ i y + W₂ y a = x } › ];
  · intro w hw;
    contrapose! hw;
    refine' csSup_le _ _;
    · exact ⟨ _, ⟨ Classical.arbitrary κ, rfl ⟩ ⟩;
    · rintro _ ⟨ x, rfl ⟩;
      refine' le_trans _ ( hw _ ⟨ Classical.choose ( show ∃ y, W₂ x y + W₃ y k = sSup ( Set.range fun j => W₂ x j + W₃ j k ) from ( IsCompact.sSup_mem ( Set.finite_range _ |> Set.Finite.isCompact ) <| Set.nonempty_of_mem <| Set.mem_range_self <| Classical.arbitrary _ ) ), rfl ⟩ );
      have := Classical.choose_spec ( show ∃ y, W₂ x y + W₃ y k = sSup ( Set.range fun j => W₂ x j + W₃ j k ) from ( IsCompact.sSup_mem ( Set.finite_range _ |> Set.Finite.isCompact ) <| Set.nonempty_of_mem <| Set.mem_range_self <| Classical.arbitrary _ ) );
      linarith [ le_csSup ( Set.finite_range ( fun j => W₁ i j + W₂ j ( Classical.choose ( show ∃ y, W₂ x y + W₃ y k = sSup ( Set.range fun j => W₂ x j + W₃ j k ) from ( IsCompact.sSup_mem ( Set.finite_range _ |> Set.Finite.isCompact ) <| Set.nonempty_of_mem <| Set.mem_range_self <| Classical.arbitrary _ ) ) ) ) |> Set.Finite.bddAbove ) ( Set.mem_range_self x ) ]

/-! ## Depth-Parametrized Stability -/

/-- **Iterated tropical aggregation**: n-fold composition of a homogeneous-width
    tropical layer with itself. -/
noncomputable def tropicalAgg_iter {ι : Type*} [Fintype ι] [Nonempty ι]
    (W : ι → ι → ℝ) : ℕ → (ι → ℝ) → (ι → ℝ)
  | 0 => id
  | n + 1 => tropicalAgg W ∘ tropicalAgg_iter W n

/-
**Depth-parametrized stability (homogeneous width)**: iterated tropical aggregation
    is 1-Lipschitz at any depth n.

    This is the breakthrough result: **depth does not amplify Lipschitz constant
    in max-plus layers**. Unlike standard neural networks where Lipschitz constants
    multiply (potentially exponential blowup), tropical composition is inherently
    stable at every depth.

    The proof proceeds by induction on n, using tropicalAgg_nonexpansive_supNorm
    at each step.
-/
theorem tropicalAgg_pow_lipschitz
    {ι : Type*} [Fintype ι] [Nonempty ι]
    (W : ι → ι → ℝ) :
    ∀ n : ℕ, ∀ x y : ι → ℝ,
      (Finset.univ.sup' Finset.univ_nonempty
        (fun i => |tropicalAgg_iter W n x i - tropicalAgg_iter W n y i|))
      ≤
      (Finset.univ.sup' Finset.univ_nonempty
        (fun i => |x i - y i|)) := by
  intro n;
  induction' n with n ih;
  · -- The base case is when $n = 0$. In this case, the tropical aggregation is just the identity function, so the inequality holds trivially.
    simp [tropicalAgg_iter];
  · intro x y;
    exact le_trans ( tropicalAgg_nonexpansive_supNorm W _ _ ) ( ih _ _ )

/-! ## Monotonicity -/

/-
**Monotonicity**: tropical aggregation preserves pointwise order.
    If x i ≤ y i for all i, then tropicalAgg W x j ≤ tropicalAgg W y j for all j.
-/
theorem tropicalAgg_monotone
    {ι κ : Type*} [Fintype ι] [Nonempty ι] [Fintype κ] [Nonempty κ]
    (W : ι → κ → ℝ) :
    ∀ x y : ι → ℝ, (∀ i, x i ≤ y i) →
      (∀ j, tropicalAgg W x j ≤ tropicalAgg W y j) := by
  -- By definition of tropicalAgg, we have that tropicalAgg W x j = sup_i (W i j + x i) and tropicalAgg W y j = sup_i (W i j + y i).
  intro x y hxy j
  simp [tropicalAgg];
  -- Since $W i j + x i \leq W i j + y i$ for all $i$, the supremum of $W i j + x i$ is less than or equal to the supremum of $W i j + y i$.
  have h_sup : ∃ b, ∀ i, W i j + x i ≤ W b j + y b := by
    have h_finite : ∃ b ∈ Finset.univ, ∀ i ∈ Finset.univ, W i j + x i ≤ W b j + y b := by
      exact Finset.exists_max_image _ ( fun i => W i j + y i ) ⟨ Classical.arbitrary ι, Finset.mem_univ _ ⟩ |> fun ⟨ b, hb₁, hb₂ ⟩ => ⟨ b, Finset.mem_univ _, fun i _ => by linarith [ hb₂ i ( Finset.mem_univ i ), hxy i ] ⟩
    aesop;
  exact h_sup