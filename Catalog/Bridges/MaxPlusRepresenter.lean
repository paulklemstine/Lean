/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Max-Plus Representer Theorem for Idempotent Kernel Regression

This file formalizes the idempotent representer theorem for max-plus kernel regression.
The main result states that whenever a projection-to-span operator exists that preserves
training values and does not increase regularization, every minimizer of a regularized
empirical risk can be replaced by one in the tropical kernel span — with the same objective
value.

This is the idempotent/tropical analogue of the classical RKHS representer theorem:
instead of Hilbert-space orthogonal projection, the key mechanism is order-theoretic
residuation. The finite case formalized here already captures the full algorithmic content:
infinite-dimensional optimization over functions collapses to finite coefficient optimization
over the training set.

## Main results

* `representer_theorem_of_projection`: any minimizer admits a span-supported minimizer
  with the same objective value, given a suitable projection.
* `exists_span_minimizer_of_exists_minimizer`: the stronger corollary that a global
  minimizer exists in the kernel span whenever one exists at all.
* `representerProjOfInterp_is_projection`: a concrete projection built from training
  interpolation.
* `optimization_reduces_to_coefficients`: the algorithmic reduction from function-space
  optimization to finite coefficient-space optimization.
* `exists_kernel_span_interpolant_of_trainKronecker`: exact interpolation for Kronecker
  tropical kernels.

## Mathematical context

In the max-plus semiring (ℝ ∪ {-∞}, max, +):
- **Tropical addition** is `max` (i.e., `⊔` in lattice notation)
- **Tropical multiplication** is classical `+`

The tropical span of kernel sections uses tropical multiplication (`+`) to combine
kernel values with coefficients, and tropical addition (`sup`) to aggregate over
the training set:
  `f(z) = ⊕_{x ∈ train} K(z,x) ⊗ c(x) = sup_{x ∈ train} (K(z,x) + c(x))`

## References

* Litvinov, Maslov, Shpiz — "Idempotent functional analysis: an algebraic approach"
* Cohen, Gaubert, Quadrat — "Duality and separation theorems in idempotent semimodules"
* Singer — "Abstract Convex Analysis"
-/

import Mathlib

open scoped BigOperators

variable {X Y α : Type*}

/-! ## Tropical span and kernel sections -/

/-- A kernel section: the function `z ↦ K z x` for a fixed input `x`. -/
def kernelSection (K : X → X → α) (x : X) : X → α := fun z => K z x

/-- The tropical span of kernel sections over a training set.
A function `f` lies in the span if it can be written as
`f(z) = sup_{x ∈ train} (K(z,x) + c(x))` for some coefficients `c`.
Here `+` is the tropical multiplication (classical addition in max-plus)
and `sup` is the tropical summation (max). -/
def tropicalSpanOn
    [SemilatticeSup α] [OrderBot α] [Add α]
    (K : X → X → α) (train : Finset X) : Set (X → α) :=
  {f | ∃ c : X → α,
      f = fun z => train.sup fun x => K z x + c x}

/-! ## Empirical risk and objective -/

/-- Empirical risk: the supremum of pointwise losses over the training set. -/
def empiricalRisk
    [SemilatticeSup α] [OrderBot α]
    (train : Finset X) (loss : X → α → Y → α) (y : X → Y) (f : X → α) : α :=
  train.sup fun x => loss x (f x) (y x)

/-- The regularized objective: supremum of empirical risk and regularization.
In the max-plus semiring, addition is `⊔`, so this is the "sum" of the two terms. -/
def objective
    [SemilatticeSup α] [OrderBot α]
    (train : Finset X) (loss : X → α → Y → α) (y : X → Y)
    (reg : (X → α) → α) (f : X → α) : α :=
  (empiricalRisk train loss y f) ⊔ (reg f)

/-! ## Representer projection -/

/-- A function `P` is a representer projection if:
1. It maps every function into the tropical kernel span.
2. It preserves function values on the training set.
3. It does not increase the regularizer. -/
def IsRepresenterProjection
    [SemilatticeSup α] [OrderBot α] [Add α]
    (K : X → X → α) (train : Finset X) (reg : (X → α) → α)
    (P : (X → α) → (X → α)) : Prop :=
  (∀ f, P f ∈ tropicalSpanOn K train) ∧
  (∀ f x, x ∈ train → P f x = f x) ∧
  (∀ f, reg (P f) ≤ reg f)

/-! ## Helper lemmas -/

/-- Extraction: projection maps into the span. -/
lemma tropicalSpanOn_contains_proj
    [SemilatticeSup α] [OrderBot α] [Add α]
    {K : X → X → α} {train : Finset X} {reg : (X → α) → α}
    {P : (X → α) → (X → α)}
    (hP : IsRepresenterProjection K train reg P) (f : X → α) :
    P f ∈ tropicalSpanOn K train := hP.1 f

/-- Extraction: projection preserves training values. -/
lemma proj_agrees_on_train
    [SemilatticeSup α] [OrderBot α] [Add α]
    {K : X → X → α} {train : Finset X} {reg : (X → α) → α}
    {P : (X → α) → (X → α)}
    (hP : IsRepresenterProjection K train reg P) (f : X → α) :
    ∀ x, x ∈ train → P f x = f x := hP.2.1 f

/-- Extraction: projection does not increase the regularizer. -/
lemma proj_reg_le
    [SemilatticeSup α] [OrderBot α] [Add α]
    {K : X → X → α} {train : Finset X} {reg : (X → α) → α}
    {P : (X → α) → (X → α)}
    (hP : IsRepresenterProjection K train reg P) (f : X → α) :
    reg (P f) ≤ reg f := hP.2.2 f

/-- The objective does not increase under projection, given training-value preservation. -/
lemma objective_le_of_projection
    [SemilatticeSup α] [OrderBot α] [Add α]
    {K : X → X → α} {train : Finset X} {y : X → Y}
    {loss : X → α → Y → α}
    {reg : (X → α) → α}
    {P : (X → α) → (X → α)}
    (hP : IsRepresenterProjection K train reg P)
    (hloss_trainwise :
      ∀ f g, (∀ x, x ∈ train → f x = g x) →
        empiricalRisk train loss y f = empiricalRisk train loss y g)
    (f : X → α) :
    objective train loss y reg (P f) ≤ objective train loss y reg f := by
  have hemp_risk_eq : empiricalRisk train loss y (P f) = empiricalRisk train loss y f :=
    hloss_trainwise _ _ fun x hx => hP.2.1 f x hx
  exact sup_le_sup hemp_risk_eq.le (hP.2.2 f)

/-! ## Main representer theorem -/

/-- **Idempotent Representer Theorem (projection form).**
Any minimizer of the regularized objective admits a span-supported function
with the same objective value. This is the tropical analogue of the classical
RKHS representer theorem.

The proof is a clean order-theoretic argument:
1. Project the minimizer `f` to get `g = P f` in the span.
2. The empirical risk is unchanged (training values preserved).
3. The regularizer does not increase.
4. So `objective g ≤ objective f`.
5. By minimality of `f`, `objective f ≤ objective g`.
6. Antisymmetry gives equality. -/
theorem representer_theorem_of_projection
    [SemilatticeSup α] [OrderBot α] [Add α]
    (K : X → X → α) (train : Finset X) (y : X → Y)
    (loss : X → α → Y → α)
    (reg : (X → α) → α)
    (P : (X → α) → (X → α))
    (hP : IsRepresenterProjection K train reg P)
    (hloss_trainwise :
      ∀ f g, (∀ x, x ∈ train → f x = g x) →
        empiricalRisk train loss y f = empiricalRisk train loss y g)
    {f : X → α}
    (hmin : ∀ g, objective train loss y reg f ≤ objective train loss y reg g) :
    ∃ g, g ∈ tropicalSpanOn K train ∧
      objective train loss y reg g = objective train loss y reg f := by
  exact ⟨P f, hP.1 f, le_antisymm (objective_le_of_projection hP hloss_trainwise f) (hmin _)⟩

/-- **Span minimizer existence.**
If a global minimizer exists, then there exists a minimizer in the tropical kernel span. -/
theorem exists_span_minimizer_of_exists_minimizer
    [SemilatticeSup α] [OrderBot α] [Add α]
    (K : X → X → α) (train : Finset X) (y : X → Y)
    (loss : X → α → Y → α)
    (reg : (X → α) → α)
    (P : (X → α) → (X → α))
    (hP : IsRepresenterProjection K train reg P)
    (hloss_trainwise :
      ∀ f g, (∀ x, x ∈ train → f x = g x) →
        empiricalRisk train loss y f = empiricalRisk train loss y g)
    (hex : ∃ f, ∀ g, objective train loss y reg f ≤ objective train loss y reg g) :
    ∃ g, g ∈ tropicalSpanOn K train ∧
      ∀ h, objective train loss y reg g ≤ objective train loss y reg h := by
  obtain ⟨f, hf⟩ := hex
  exact ⟨_, tropicalSpanOn_contains_proj hP f,
    fun g => le_trans (objective_le_of_projection hP hloss_trainwise f) (hf g)⟩

/-! ## Training interpolation and concrete projection -/

/-- A kernel has training interpolation if every function's values on the training set
can be exactly reproduced by some element of the tropical kernel span. -/
def HasTrainInterpolation
    [SemilatticeSup α] [OrderBot α] [Add α]
    (K : X → X → α) (train : Finset X) : Prop :=
  ∀ f : X → α, ∃ c : X → α,
    ∀ x, x ∈ train →
      (train.sup fun z => K x z + c z) = f x

/-- Concrete projection: given training interpolation, project any function
to a span element that agrees on the training set. Uses classical choice. -/
noncomputable def representerProjOfInterp
    [SemilatticeSup α] [OrderBot α] [Add α]
    (K : X → X → α) (train : Finset X)
    (hinterp : HasTrainInterpolation K train)
    (f : X → α) : X → α :=
  fun z => train.sup fun x => K z x + (hinterp f).choose x

/-- The concrete projection is a representer projection, given training interpolation
and a regularizer that does not increase under projection. -/
theorem representerProjOfInterp_is_projection
    [SemilatticeSup α] [OrderBot α] [Add α]
    (K : X → X → α) (train : Finset X)
    (hinterp : HasTrainInterpolation K train)
    (reg : (X → α) → α)
    (hreg : ∀ f, reg (representerProjOfInterp K train hinterp f) ≤ reg f) :
    IsRepresenterProjection K train reg (representerProjOfInterp K train hinterp) := by
  refine ⟨?_, ?_, ?_⟩
  · exact fun f => ⟨_, rfl⟩
  · exact fun f x hx => (hinterp f).choose_spec x hx
  · exact hreg

/-! ## Kronecker tropical kernel -/

/-- A kernel is train-Kronecker if it has zero diagonal entries (identity for tropical
multiplication) on the training set and bottom (absorbing element, i.e., tropical zero)
off-diagonal entries within the training set.

In the max-plus semiring (ℝ ∪ {-∞}, max, +), the identity for `+` is `0` and the
absorbing element is `-∞` (= ⊥). A Kronecker kernel has `K(x,x) = 0` on diagonal
and `K(z,x) = -∞` off diagonal. -/
def IsTrainKroneckerKernel
    [Preorder α] [OrderBot α] [Add α] [Zero α]
    (K : X → X → α) (train : Finset X) : Prop :=
  (∀ x, x ∈ train → K x x = 0) ∧
  (∀ x z, x ∈ train → z ∈ train → x ≠ z → K z x = ⊥)

/-
For a Kronecker tropical kernel over a type with absorbing ⊥ and additive identity 0,
every function can be interpolated exactly on the training set by an element of the
tropical kernel span.

The key insight: set `c(x) = f(x)` for all `x`. Then at training point `x₀`:
- The `x₀` term contributes `K(x₀,x₀) + f(x₀) = 0 + f(x₀) = f(x₀)`
- Every other term `x ≠ x₀` contributes `K(x₀,x) + f(x) = ⊥ + f(x) = ⊥`
- So the sup equals `f(x₀)`.
-/
theorem exists_kernel_span_interpolant_of_trainKronecker
    [DecidableEq X] [LinearOrder α] [OrderBot α] [Add α] [Zero α]
    (K : X → X → α) (train : Finset X)
    (hK : IsTrainKroneckerKernel K train)
    (hbot_add : ∀ a : α, ⊥ + a = ⊥)
    (hzero_add : ∀ a : α, 0 + a = a) :
    HasTrainInterpolation K train := by
  intro f
  use fun x => f x;
  intro x hx;
  refine' le_antisymm _ _;
  · refine' Finset.sup_le _;
    intro y hy; by_cases h : x = y <;> simp_all +decide [ IsTrainKroneckerKernel ] ;
    rw [ hK.2 _ _ hy hx ( Ne.symm h ) ] ; aesop;
  · exact Finset.le_sup ( f := fun z => K x z + f z ) hx |> le_trans ( by simp +decide [ hK.1 x hx, hzero_add ] )

/-! ## Coefficient-space objective and algorithmic reduction -/

/-- The coefficient-space objective: the regularized empirical risk as a function
of the coefficient vector `c`, with the function reconstructed from the kernel span. -/
def coeffObjective
    [SemilatticeSup α] [OrderBot α] [Add α]
    (K : X → X → α) (train : Finset X) (y : X → Y)
    (loss : X → α → Y → α) (reg : (X → α) → α) (c : X → α) : α :=
  let f : X → α := fun z => train.sup fun x => K z x + c x
  objective train loss y reg f

/-- **Algorithmic reduction theorem.**
If a global minimizer of the function-space objective exists, then there exists a
coefficient vector that globally minimizes the coefficient-space objective.
This reduces infinite-dimensional optimization to finite coefficient optimization. -/
theorem optimization_reduces_to_coefficients
    [SemilatticeSup α] [OrderBot α] [Add α]
    (K : X → X → α) (train : Finset X) (y : X → Y)
    (loss : X → α → Y → α)
    (reg : (X → α) → α)
    (P : (X → α) → (X → α))
    (hP : IsRepresenterProjection K train reg P)
    (hloss_trainwise :
      ∀ f g, (∀ x, x ∈ train → f x = g x) →
        empiricalRisk train loss y f = empiricalRisk train loss y g) :
    (∃ f, ∀ g, objective train loss y reg f ≤ objective train loss y reg g) →
    ∃ c : X → α,
      ∀ d : X → α, coeffObjective K train y loss reg c ≤ coeffObjective K train y loss reg d := by
  intro hex
  obtain ⟨f, hf⟩ := hex
  obtain ⟨g, hg_span, hg_min⟩ :=
    exists_span_minimizer_of_exists_minimizer K train y loss reg P hP hloss_trainwise ⟨f, hf⟩
  obtain ⟨c, rfl⟩ := hg_span
  exact ⟨c, fun d => by simpa only [coeffObjective] using hg_min _⟩