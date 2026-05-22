/-
# Tropical Residuation: Compositional Adjunction Laws for Tropical Algebra

This module formalizes the residuated structure of tropical (max-plus) algebra over ℝ,
establishing that tropical translation maps and finite tropical aggregation maps are
left adjoints in an ordered setting, with explicitly computable residuals.

The central results form a "tropical cut-elimination" principle: composition of
residuated tropical maps yields a residuated map whose residual is computed by
reversing the order of residuals. This is the algebraic core of compositional
stability for tropical proof systems and certified neural architectures.

## Main Results

- `tropical_translation_residuation`: The scalar adjunction `a + y ≤ c ↔ y ≤ c - a`.
- `tropical_finset_aggregation_residuation`: Finite sup-aggregation residuation
  `sup'_i (x i + w i) ≤ c ↔ ∀ i, x i ≤ c - w i`.
- `residual_comp`: Abstract cut-elimination for residuated maps on preorders.
- `tropical_matrix_residuation_pointwise`: Matrix-level residuation
  `(∀ j, sup'_i (x i + W i j) ≤ y j) ↔ (∀ i j, x i ≤ y j - W i j)`.
- `tropical_matrix_residuation`: Matrix residuation with inf on the RHS.
- `tropical_matmul_gc`: Galois connection form `tropicalMatMul W x ≤ y ↔ x ≤ tropicalBackward W y`.
- `residuated_monotone_left`: Any residuated map is monotone.
- `tropical_two_layer_composition_residuation`: Compositional residuation for two tropical layers.

## Cross-Domain Significance

These theorems bridge:
1. **Quantitative logic**: Residuation is the defining axiom of substructural logic;
   composition of residuals is cut-elimination.
2. **Certified ML**: Backward certificates for max-plus networks become exact algebraic
   objects via matrix residuation.
3. **Mathematical morphology**: Tropical aggregation/residuation coincides with
   dilation/erosion adjunctions.
4. **Dynamic programming**: Max-plus linear maps encode Bellman operators;
   residuation gives backward reachability constraints.
5. **Scheduling**: Tropical matrix algebra models synchronization;
   residuals compute latest admissible start times.
-/

import Mathlib

open Finset

/-! ## Scalar Tropical Residuation -/

/-
**Scalar tropical residuation (atomic adjunction law).**
In the tropical semiring, multiplication is ordinary addition.
The residuation law `a + y ≤ c ↔ y ≤ c - a` is the foundational
Galois connection on which all tropical backward reasoning depends.

This is the linear-logic axiom `a ⊗ x ≤ c ↔ x ≤ a ⊸ c`
specialized to the tropical setting where `⊗ = +` and `⊸ = −`.
-/
theorem tropical_translation_residuation (a y c : ℝ) :
    a + y ≤ c ↔ y ≤ c - a := by
  grind +splitImp

/-! ## Finite Tropical Aggregation Residuation -/

/-
**Finite tropical aggregation residuation.**
For a finite family of offsets `w : ι → ℝ`, the tropical aggregation map
`x ↦ sup'_i (x i + w i)` is a left adjoint with right adjoint `c ↦ (i ↦ c - w i)`.

Concretely: `sup'_i (x i + w i) ≤ c ↔ ∀ i, x i ≤ c - w i`.

This theorem internalizes the passage from a forward tropical layer
to a backward certificate: to verify that the aggregated output
stays below a threshold, it suffices to verify each input channel independently.
-/
theorem tropical_finset_aggregation_residuation
    {ι : Type*} [Fintype ι] [Nonempty ι]
    (x w : ι → ℝ) (c : ℝ) :
    (Finset.univ.sup' Finset.univ_nonempty fun i => x i + w i) ≤ c ↔
      ∀ i, x i ≤ c - w i := by
  simp +decide [ ← le_sub_iff_add_le, Finset.sup'_le_iff ]

/-! ## Abstract Residual Composition (Tropical Cut-Elimination) -/

/-
**Abstract cut-elimination for residuated maps.**
If `f : α → β` and `g : β → γ` are residuated maps (i.e., left adjoints
in the order-enriched sense), then their composition `g ∘ f` is also residuated,
with residual `f♯ ∘ g♯`.

This is the algebraic content of the cut-elimination theorem in a
tropical/quantitative proof system: composing two proof steps
(forward maps) and then asking for the strongest precondition
(residual) is the same as chaining the individual strongest
preconditions in reverse order.
-/
theorem residual_comp
    {α β γ : Type*}
    [Preorder α] [Preorder β] [Preorder γ]
    (f : α → β) (fsharp : β → α)
    (g : β → γ) (gsharp : γ → β)
    (hf : ∀ x y, f x ≤ y ↔ x ≤ fsharp y)
    (hg : ∀ y z, g y ≤ z ↔ y ≤ gsharp z) :
    ∀ x z, (g (f x) ≤ z) ↔ x ≤ fsharp (gsharp z) := by
  grind

/-! ## Matrix-Level Tropical Residuation -/

/-
**Pointwise matrix tropical residuation.**
For a matrix `W : m → n → ℝ`, the tropical matrix-vector product
`F_W(x)_j = sup'_i (x i + W i j)` satisfies:

`(∀ j, F_W(x)_j ≤ y j) ↔ (∀ i j, x i ≤ y j - W i j)`.

This is a tropical analogue of LP dual feasibility and the formal
strongest-postcondition/weakest-precondition bridge for one-layer
tropical neural networks.
-/
theorem tropical_matrix_residuation_pointwise
    {m n : Type*} [Fintype m] [Fintype n] [Nonempty m] [Nonempty n]
    (W : m → n → ℝ) (x : m → ℝ) (y : n → ℝ) :
    (∀ j, (Finset.univ.sup' Finset.univ_nonempty fun i => x i + W i j) ≤ y j) ↔
    (∀ i j, x i ≤ y j - W i j) := by
  constructor;
  · intro h i j; linarith [ h j, Finset.le_sup' ( fun i => x i + W i j ) ( Finset.mem_univ i ) ] ;
  · exact fun h j => Finset.sup'_le _ _ fun i _ => by linarith [ h i j ] ;

/-
**Matrix tropical residuation with inf.**
Equivalent to `tropical_matrix_residuation_pointwise` but with the RHS
expressed using `inf'`: `∀ i, x i ≤ inf'_j (y j - W i j)`.
-/
theorem tropical_matrix_residuation
    {m n : Type*} [Fintype m] [Fintype n] [Nonempty m] [Nonempty n]
    (W : m → n → ℝ) (x : m → ℝ) (y : n → ℝ) :
    (∀ j, (Finset.univ.sup' Finset.univ_nonempty fun i => x i + W i j) ≤ y j) ↔
    (∀ i, x i ≤ Finset.univ.inf' Finset.univ_nonempty fun j => y j - W i j) := by
  convert tropical_matrix_residuation_pointwise W x y using 1;
  simp +decide [ Finset.le_inf'_iff ]

/-! ## Tropical Definitions for Compositional Results -/

/-- Tropical translation by a scalar. -/
noncomputable def tropicalTranslate (a : ℝ) : ℝ → ℝ := fun x => x + a

/-- Residual of tropical translation. -/
noncomputable def tropicalResidual (a : ℝ) : ℝ → ℝ := fun c => c - a

/-- Tropical aggregation: `sup'_i (x i + w i)`. -/
noncomputable def tropicalAgg {ι : Type*} [Fintype ι] [Nonempty ι]
    (w : ι → ℝ) (x : ι → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty fun i => x i + w i

/-- Tropical matrix-vector multiply: `j ↦ sup'_i (x i + W i j)`. -/
noncomputable def tropicalMatMul {m n : Type*} [Fintype m] [Nonempty m]
    (W : m → n → ℝ) (x : m → ℝ) : n → ℝ :=
  fun j => Finset.univ.sup' Finset.univ_nonempty fun i => x i + W i j

/-- Backward (residual) map for tropical matrix multiply:
`i ↦ inf'_j (y j - W i j)`. -/
noncomputable def tropicalBackward {m n : Type*} [Fintype n] [Nonempty n]
    (W : m → n → ℝ) (y : n → ℝ) : m → ℝ :=
  fun i => Finset.univ.inf' Finset.univ_nonempty fun j => y j - W i j

/-! ## Galois Connection for Tropical MatMul -/

/-- **Tropical matrix Galois connection.**
`tropicalMatMul W x ≤ y ↔ x ≤ tropicalBackward W y` (pointwise).

This is the definitive adjunction theorem: the tropical matrix-vector
product and the backward residual map form a Galois connection. -/
theorem tropical_matmul_gc
    {m n : Type*} [Fintype m] [Fintype n] [Nonempty m] [Nonempty n]
    (W : m → n → ℝ) (x : m → ℝ) (y : n → ℝ) :
    (∀ j, tropicalMatMul W x j ≤ y j) ↔
    (∀ i, x i ≤ tropicalBackward W y i) := by
  unfold tropicalMatMul tropicalBackward
  exact tropical_matrix_residuation W x y

/-! ## Corollaries -/

/-
**Monotonicity of residuated maps.**
Any map that is the left part of a residuated pair is monotone.
This is a standard consequence of Galois connections.
-/
theorem residuated_monotone_left
    {α β : Type*} [Preorder α] [Preorder β]
    (f : α → β) (fsharp : β → α)
    (hf : ∀ x y, f x ≤ y ↔ x ≤ fsharp y) :
    Monotone f := by
  intro x y hxy;
  exact hf _ _ |>.2 ( hxy.trans ( hf _ _ |>.1 le_rfl ) )

/-
Tropical aggregation is monotone (pointwise in `x`).
-/
theorem tropicalAgg_monotone {ι : Type*} [Fintype ι] [Nonempty ι]
    (w : ι → ℝ) : Monotone (tropicalAgg w) := by
  exact fun x y hxy => Finset.sup'_mono_fun fun i _ => add_le_add ( hxy i ) le_rfl

/-
Tropical matrix-vector multiply is monotone (pointwise in `x`).
-/
theorem tropicalMatMul_monotone
    {m n : Type*} [Fintype m] [Fintype n] [Nonempty m] [Nonempty n]
    (W : m → n → ℝ) :
    ∀ x₁ x₂ : m → ℝ, (∀ i, x₁ i ≤ x₂ i) →
      ∀ j, tropicalMatMul W x₁ j ≤ tropicalMatMul W x₂ j := by
  simp +decide [ tropicalMatMul ];
  intro x₁ x₂ hx j;
  exact ⟨ Classical.choose ( Finset.exists_max_image Finset.univ ( fun i => x₂ i + W i j ) Finset.univ_nonempty ), fun i => le_trans ( add_le_add ( hx i ) le_rfl ) ( Classical.choose_spec ( Finset.exists_max_image Finset.univ ( fun i => x₂ i + W i j ) Finset.univ_nonempty ) |>.2 i ( Finset.mem_univ i ) ) ⟩

/-! ## Two-Layer Compositional Residuation -/

/-
**Two-layer tropical compositional residuation (tropical cut-elimination).**
For matrices `W₁ : m → n → ℝ` and `W₂ : n → p → ℝ`,
the two-layer tropical network `x ↦ tropicalMatMul W₂ (tropicalMatMul W₁ x)`
is residuated, with residual `tropicalBackward W₁ ∘ tropicalBackward W₂`:

`(∀ k, tropicalMatMul W₂ (tropicalMatMul W₁ x) k ≤ z k) ↔
 (∀ i, x i ≤ tropicalBackward W₁ (tropicalBackward W₂ z) i)`.

This is the concrete instantiation of abstract cut-elimination
(`residual_comp`) for two-layer tropical networks.
-/
theorem tropical_two_layer_composition_residuation
    {m n p : Type*} [Fintype m] [Fintype n] [Fintype p]
    [Nonempty m] [Nonempty n] [Nonempty p]
    (W₁ : m → n → ℝ) (W₂ : n → p → ℝ)
    (x : m → ℝ) (z : p → ℝ) :
    (∀ k, tropicalMatMul W₂ (tropicalMatMul W₁ x) k ≤ z k) ↔
    (∀ i, x i ≤ tropicalBackward W₁ (tropicalBackward W₂ z) i) := by
  convert tropical_matmul_gc W₂ ( tropicalMatMul W₁ x ) z using 1;
  convert tropical_matmul_gc W₁ x ( tropicalBackward W₂ z ) |> Iff.symm