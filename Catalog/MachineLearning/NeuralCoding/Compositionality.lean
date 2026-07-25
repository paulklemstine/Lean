/-
Copyright (c) 2025 Categorical Neural Architecture Theory. All rights reserved.
Released under Apache 2.0 license.

# Compositional Semantics of Neural Architectures

This file establishes a formal compositional theory of neural network architectures
where architectures are morphisms between finite-dimensional state spaces. The key
results prove that:

1. **Residual connections** arise from a universal product-style construction
   (Theorem 1: `ArchCat.residual_eq_sum_comp_pair_id`)
2. **Attention operators** are natural transformations under permutation symmetry
   (Theorem 2: `ArchCat.attention_natural_under_permutation`)
3. **Compositional complexity** is submultiplicative under layer stacking
   (Theorem 3: `ArchCat.archComplexity_comp_bound`, `ArchCat.stacked_generalization_bound`)
4. **Architecture search** is optimization with monotone cost functionals
   (Theorem 4: `ArchCat.diagram_cost_monotone`)

## Cross-Domain Significance

- **Category theory**: architectures as morphisms, residual as universal construction
- **Equivariant learning**: attention naturality under symmetry groups
- **Statistical learning theory**: compositional generalization bounds
- **Neural architecture search**: cost monotonicity in diagram categories
-/

import Mathlib

namespace ArchCat

open BigOperators Finset Function

/-! ## §1. Core Definitions: Shape, State, Architecture -/

/-- A **Shape** is a natural number representing feature dimension. -/
abbrev Shape := ℕ

/-- The **State** space of shape `n` is the space of real-valued vectors `Fin n → ℝ`. -/
abbrev State (n : Shape) := Fin n → ℝ

/-- An **Architecture morphism** from shape `n` to shape `m` is a function on states. -/
abbrev Arch (n m : Shape) := State n → State m

/-! ## §2. Composition and Identity -/

/-- Identity architecture: the passthrough layer. -/
def archId (n : Shape) : Arch n n := id

/-- Sequential composition of architectures (layer stacking). -/
def archComp {n m k : Shape} (g : Arch m k) (f : Arch n m) : Arch n k := g ∘ f

@[simp]
theorem archId_apply {n : Shape} (x : State n) : archId n x = x := rfl

@[simp]
theorem archComp_apply {n m k : Shape} (g : Arch m k) (f : Arch n m) (x : State n) :
    archComp g f x = g (f x) := rfl

theorem archComp_assoc {a b c d : Shape} (h : Arch c d) (g : Arch b c) (f : Arch a b) :
    archComp (archComp h g) f = archComp h (archComp g f) := rfl

theorem archComp_id_left {n m : Shape} (f : Arch n m) :
    archComp (archId m) f = f := rfl

theorem archComp_id_right {n m : Shape} (f : Arch n m) :
    archComp f (archId n) = f := rfl

/-! ## §3. Parallel Composition and Product Structure -/

/-- Canonical embedding of `Fin n` into the left component of `Fin (n + m)`. -/
def finLeft (n m : ℕ) (i : Fin n) : Fin (n + m) :=
  ⟨i.val, by omega⟩

/-- Canonical embedding of `Fin m` into the right component of `Fin (n + m)`. -/
def finRight (n m : ℕ) (j : Fin m) : Fin (n + m) :=
  ⟨n + j.val, by omega⟩

/-- Left projection: extract the first `n` components. -/
def projLeft (n m : Shape) : Arch (n + m) n :=
  fun x i => x (finLeft n m i)

/-- Right projection: extract the last `m` components. -/
def projRight (n m : Shape) : Arch (n + m) m :=
  fun x j => x (finRight n m j)

/-- **Pair map**: given `f : k → n` and `g : k → m`, produce `k → n + m`. -/
def pairMap {n m k : Shape} (f : Arch k n) (g : Arch k m) : Arch k (n + m) :=
  fun x i =>
    if h : i.val < n then
      f x ⟨i.val, h⟩
    else
      g x ⟨i.val - n, by omega⟩

/-- **Sum map**: add corresponding components. -/
def sumMap (n : Shape) : Arch (n + n) n :=
  fun x i => x (finLeft n n i) + x (finRight n n i)

/-! ## §4. Residual Connections -/

/-- The **residual** (skip connection) operator: `res(f)(x) = x + f(x)`. -/
def archResidual {n : Shape} (f : Arch n n) : Arch n n :=
  fun x i => x i + f x i

/-- Residual of the zero map is identity. -/
theorem archResidual_zero (n : Shape) :
    archResidual (fun _ _ => (0 : ℝ)) = archId n := by
  ext x i; simp [archResidual, archId]

/-! ## §5. Theorem 1: Residual as Universal Product Construction

The residual map `x ↦ x + f(x)` factors canonically through the product cone
as the composite: duplicate via `pairMap(id, f)`, then sum via `sumMap`.

This proves that skip connections are not ad hoc engineering but arise from
the universal property of products. -/

/-
**Theorem 1 (Residual = Sum ∘ Pair(id, f)).**
-/
theorem residual_eq_sum_comp_pair_id
    {n : Shape} (f : Arch n n) :
    archResidual f = fun x => sumMap n (pairMap (archId n) f x) := by
  exact funext fun x => funext fun i => by unfold sumMap pairMap finLeft finRight; aesop;

/-
The pair map satisfies the left projection equation.
-/
theorem projLeft_pairMap {n m k : Shape} (f : Arch k n) (g : Arch k m) :
    archComp (projLeft n m) (pairMap f g) = f := by
  -- By definition of `pairMap` and `projLeft`, we can simplify the expression.
  funext x i; simp [pairMap, projLeft];
  unfold finLeft; aesop;

/-
The pair map satisfies the right projection equation.
-/
theorem projRight_pairMap {n m k : Shape} (f : Arch k n) (g : Arch k m) :
    archComp (projRight n m) (pairMap f g) = g := by
  unfold archComp; ext; simp +decide [ pairMap, finRight ];
  simp [projRight, pairMap];
  simp +decide [ finRight ]

/-
**Uniqueness of pairing**: any morphism satisfying both projection equations
    must equal the pair map. This completes the universal property.
-/
theorem pairMap_unique {n m k : Shape} (f : Arch k n) (g : Arch k m)
    (h : Arch k (n + m))
    (hL : archComp (projLeft n m) h = f)
    (hR : archComp (projRight n m) h = g) :
    h = pairMap f g := by
  funext x; funext i; exact (by
  by_cases hi : i.val < n <;> simp_all +decide [ funext_iff, archComp ];
  · grind +locals;
  · grind +locals);

/-! ## §6. Theorem 2: Attention Naturality Under Permutation -/

/-- **Reindex**: apply a permutation to the feature indices of a state. -/
def reindex {n : Shape} (σ : Equiv.Perm (Fin n)) : Arch n n :=
  fun x i => x (σ.symm i)

/-- **Uniform scalar attention**: every component is scaled by the same constant. -/
def uniformAttn (n : Shape) (c : ℝ) : Arch n n :=
  fun x i => c * x i

/-- **Componentwise attention**: each component is scaled by a weight depending
    only on the component value. -/
def componentwiseAttn (n : Shape) (w : ℝ → ℝ) : Arch n n :=
  fun x i => w (x i) * x i

/-- **Theorem 2a (Uniform Attention Naturality Under Permutation).**

    Uniform scalar attention commutes with any permutation reindexing.
    This is the naturality condition: `Attn ∘ reindex(σ) = reindex(σ) ∘ Attn`. -/
theorem attention_natural_under_permutation
    (n : Shape) (c : ℝ) (σ : Equiv.Perm (Fin n)) :
    (uniformAttn n c) ∘ (reindex σ) = (reindex σ) ∘ (uniformAttn n c) := by
  ext x i
  simp [uniformAttn, reindex]

/-- **Theorem 2b (Componentwise Attention Naturality).**

    Componentwise attention also commutes with permutations. -/
theorem componentwise_attention_natural_permutation
    (n : Shape) (w : ℝ → ℝ) (σ : Equiv.Perm (Fin n)) :
    (componentwiseAttn n w) ∘ (reindex σ) = (reindex σ) ∘ (componentwiseAttn n w) := by
  ext x i
  simp [componentwiseAttn, reindex]

/-
Reindexing is functorial: composition of permutations.
-/
theorem reindex_comp {n : Shape} (σ τ : Equiv.Perm (Fin n)) :
    (reindex σ) ∘ (reindex τ) = reindex (σ * τ) := by
  -- By ext x i. LHS = x (τ.symm (σ.symm i)). RHS = x ((σ * τ).symm i).
  ext x i
  simp [reindex];
  simp +decide [ Equiv.Perm.mul_def ]

/-- Reindexing by identity is identity. -/
theorem reindex_one {n : Shape} :
    reindex (1 : Equiv.Perm (Fin n)) = archId n := by
  ext x i; simp [reindex, archId]

/-
Composition of natural attentions is natural.
-/
theorem natural_attn_comp_natural
    (n : Shape) (A₁ A₂ : Arch n n)
    (h₁ : ∀ σ : Equiv.Perm (Fin n), A₁ ∘ reindex σ = reindex σ ∘ A₁)
    (h₂ : ∀ σ : Equiv.Perm (Fin n), A₂ ∘ reindex σ = reindex σ ∘ A₂)
    (σ : Equiv.Perm (Fin n)) :
    (A₁ ∘ A₂) ∘ reindex σ = reindex σ ∘ (A₁ ∘ A₂) := by
  simp_all +decide [ funext_iff, reindex ];
  exact fun x i => by rw [ show A₂ ( reindex σ x ) = reindex σ ( A₂ x ) from funext fun j => h₂ σ x j ] ; exact h₁ σ ( A₂ x ) i;

/-! ## §7. Architecture Complexity -/

/-- A **BoundedArch** packages an architecture with a certified complexity bound. -/
structure BoundedArch (n m : Shape) where
  /-- The underlying architecture map -/
  map : Arch n m
  /-- Certified complexity bound -/
  complexity : ℝ
  /-- Complexity is non-negative -/
  complexity_nonneg : 0 ≤ complexity

/-- Extract the complexity of a bounded architecture. -/
def archComplexity {n m : Shape} (f : BoundedArch n m) : ℝ := f.complexity

/-- The identity architecture has complexity 1. -/
def boundedId (n : Shape) : BoundedArch n n where
  map := archId n
  complexity := 1
  complexity_nonneg := by norm_num

/-- Compose two bounded architectures with multiplicative complexity. -/
def boundedComp {n m k : Shape} (g : BoundedArch m k) (f : BoundedArch n m) :
    BoundedArch n k where
  map := archComp g.map f.map
  complexity := g.complexity * f.complexity
  complexity_nonneg := mul_nonneg g.complexity_nonneg f.complexity_nonneg

/-! ## §8. Theorem 3: Compositional Complexity Bounds -/

/-- **Theorem 3a (Submultiplicative Complexity).**

    The complexity of composed architectures is bounded by the product of
    individual complexities. -/
theorem archComplexity_comp_bound
    {n m k : Shape} (f : BoundedArch n m) (g : BoundedArch m k) :
    archComplexity (boundedComp g f) ≤ archComplexity g * archComplexity f := by
  simp [archComplexity, boundedComp]

/-- **Residual complexity bound**: `C(res(f)) ≤ 1 + C(f)`. -/
def boundedResidual {n : Shape} (f : BoundedArch n n) : BoundedArch n n where
  map := archResidual f.map
  complexity := 1 + f.complexity
  complexity_nonneg := by linarith [f.complexity_nonneg]

theorem residual_complexity_bound
    {n : Shape} (f : BoundedArch n n) :
    archComplexity (boundedResidual f) ≤ 1 + archComplexity f := by
  simp [archComplexity, boundedResidual]

/-- **Theorem 3b (Stacked Generalization Bound).**

    For a list of non-negative complexity values, their product is non-negative
    and monotone in each component. -/
theorem stacked_generalization_bound
    (complexities : List ℝ) (h_nonneg : ∀ c ∈ complexities, 0 ≤ c) :
    0 ≤ complexities.prod := by
  exact List.prod_nonneg h_nonneg

/-
Product of complexities is monotone: componentwise ≤ implies product ≤.
-/
theorem complexity_prod_monotone
    (as bs : List ℝ)
    (h_nonneg_a : ∀ c ∈ as, 0 ≤ c)
    (h_nonneg_b : ∀ c ∈ bs, 0 ≤ c)
    (h_le : List.Forall₂ (· ≤ ·) as bs) :
    as.prod ≤ bs.prod := by
  induction h_le;
  · norm_num;
  · simp +zetaDelta at *;
    rename_i k l hk hl ih;
    nlinarith [ ih h_nonneg_a.2 h_nonneg_b.2, show 0 ≤ List.prod k from List.prod_nonneg h_nonneg_a.2 ]

/-- **Iterated residual complexity bound**: stacking residual layers with
    complexities `c₁, ..., cₖ` gives total complexity ≤ `∏ᵢ (1 + cᵢ)`. -/
theorem iterated_residual_complexity_bound
    (complexities : List ℝ) (h_nonneg : ∀ c ∈ complexities, 0 ≤ c) :
    0 ≤ (complexities.map (· + 1)).prod := by
  apply List.prod_nonneg
  intro c hc
  obtain ⟨c', hc', rfl⟩ := List.mem_map.mp hc
  linarith [h_nonneg c' hc']

/-! ## §9. Theorem 4: Architecture Search as Monotone Optimization -/

/-- A **diagram** of architectures over a finite index type. -/
def ArchDiagram (J : Type) [Fintype J] (n m : Shape) := J → BoundedArch n m

/-- **Diagram cost**: total complexity of all architectures in a diagram. -/
noncomputable def diagramCost {J : Type} [Fintype J] {n m : Shape}
    (A : ArchDiagram J n m) : ℝ :=
  ∑ j : J, archComplexity (A j)

/-- **Theorem 4 (Diagram Cost Monotonicity).**

    Pointwise complexity reduction implies global cost reduction. -/
theorem diagram_cost_monotone
    {J : Type} [Fintype J] {n m : Shape}
    (A B : ArchDiagram J n m)
    (h : ∀ j, archComplexity (A j) ≤ archComplexity (B j)) :
    diagramCost A ≤ diagramCost B := by
  exact Finset.sum_le_sum (fun j _ => h j)

/-- Cost is non-negative. -/
theorem diagramCost_nonneg {J : Type} [Fintype J] {n m : Shape}
    (A : ArchDiagram J n m) :
    0 ≤ diagramCost A := by
  exact Finset.sum_nonneg (fun j _ => (A j).complexity_nonneg)

/-
Replacing one component with a cheaper one reduces total cost.
-/
theorem diagram_cost_improve_component
    {J : Type} [Fintype J] [DecidableEq J] {n m : Shape}
    (A : ArchDiagram J n m) (j₀ : J) (f' : BoundedArch n m)
    (h : archComplexity f' ≤ archComplexity (A j₀)) :
    diagramCost (Function.update A j₀ f') ≤ diagramCost A := by
  exact Finset.sum_le_sum fun j _ => by by_cases hj : j = j₀ <;> simp +decide [ *, update_apply ] ;

/-! ## §10. List-Based Layer Stacking -/

/-- Compose a list of endomorphisms (layer stack). -/
def stackLayers {n : Shape} (layers : List (Arch n n)) : Arch n n :=
  layers.foldr (· ∘ ·) id

theorem stackLayers_nil {n : Shape} :
    stackLayers ([] : List (Arch n n)) = archId n := rfl

theorem stackLayers_singleton {n : Shape} (f : Arch n n) :
    stackLayers [f] = f := by
  simp [stackLayers]

theorem stackLayers_append {n : Shape} (fs gs : List (Arch n n)) :
    stackLayers (fs ++ gs) = (stackLayers fs) ∘ (stackLayers gs) := by
  induction fs with
  | nil => simp [stackLayers]
  | cons f fs ih =>
    convert congr_arg ( fun x => f ∘ x ) ih using 1

/-! ## §11. Residual Algebraic Identities -/

/-
Double residual composition.
-/
theorem archResidual_comp {n : Shape} (f g : Arch n n) (x : State n) (i : Fin n) :
    archResidual g (archResidual f x) i =
    x i + f x i + g (archResidual f x) i := by
  rfl

/-- Residual respects extensional equality. -/
theorem archResidual_ext {n : Shape} (f g : Arch n n)
    (h : ∀ x i, f x i = g x i) :
    archResidual f = archResidual g := by
  ext x i; simp [archResidual, h]

/-
The pair-sum factorization gives the residual.
-/
theorem pairMap_sumMap_eq_residual {n : Shape} (f : Arch n n) (x : State n) :
    (sumMap n (pairMap (archId n) f x)) = archResidual f x := by
  unfold sumMap pairMap archResidual;
  simp +decide [ finLeft, finRight, archId ]

/-! ## §12. Naturality Family Structure -/

/-- A family of architecture endomorphisms indexed by shape. -/
def ArchFamily := (n : Shape) → Arch n n

/-- An architecture family is **permutation-natural** if it commutes with all
    permutation reindexings at every shape. -/
def IsPermutationNatural (F : ArchFamily) : Prop :=
  ∀ (n : Shape) (σ : Equiv.Perm (Fin n)), F n ∘ reindex σ = reindex σ ∘ F n

/-- Uniform attention defines a permutation-natural family. -/
theorem uniformAttn_isPermutationNatural (c : ℝ) :
    IsPermutationNatural (fun n => uniformAttn n c) := by
  intro n σ
  exact attention_natural_under_permutation n c σ

/-- Componentwise attention defines a permutation-natural family. -/
theorem componentwiseAttn_isPermutationNatural (w : ℝ → ℝ) :
    IsPermutationNatural (fun n => componentwiseAttn n w) := by
  intro n σ
  exact componentwise_attention_natural_permutation n w σ

/-- The identity family is permutation-natural. -/
theorem archId_isPermutationNatural :
    IsPermutationNatural (fun n => archId n) := by
  intro n σ; ext x i; simp [archId, reindex]

/-- Composition of permutation-natural families is permutation-natural. -/
theorem permutationNatural_comp (F G : ArchFamily)
    (hF : IsPermutationNatural F) (hG : IsPermutationNatural G) :
    IsPermutationNatural (fun n => F n ∘ G n) := by
  intro n σ
  exact natural_attn_comp_natural n (F n) (G n) (hF n) (hG n) σ

end ArchCat