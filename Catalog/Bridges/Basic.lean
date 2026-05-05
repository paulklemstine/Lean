import Mathlib

/-!
# Tropical Functionals: Basic Definitions

This file defines the foundational structures for the tropical Riesz representation theory:
- `TropCont X`: continuous functions from `X` to `WithBot ℝ` (the max-plus semiring)
- `TropicalFunctional X`: max-plus linear functionals on `TropCont X`
- Basic lemmas about extensionality and monotonicity

## Mathematical context

In the max-plus (tropical) semiring `(WithBot ℝ, sup, +)`, the element `⊥ = -∞` is the
additive zero and `0` is the multiplicative unit. A *tropical functional* is a map
`Λ : TropCont X → WithBot ℝ` that preserves `sup` (tropical addition), commutes with
translation by constants (tropical scalar multiplication), and normalizes constants.

This is the tropical analogue of a positive linear functional in classical analysis.
-/

noncomputable section

/-! ## Topology on `WithBot ℝ` -/

instance WithBot.Real.topologicalSpace : TopologicalSpace (WithBot ℝ) :=
  Preorder.topology (WithBot ℝ)
instance WithBot.Real.orderTopology : OrderTopology (WithBot ℝ) := ⟨rfl⟩

/-! ## The function space `TropCont X` -/

/-- Continuous functions from `X` to `WithBot ℝ` with the order topology.
In the tropical setting, these are the analogues of continuous real-valued functions. -/
abbrev TropCont (X : Type*) [TopologicalSpace X] := C(X, WithBot ℝ)

/-! ## Operations on `TropCont X` -/

/-- Pointwise supremum of two tropical continuous functions. -/
def TropCont.tsup {X : Type*} [TopologicalSpace X]
    (f g : TropCont X) : TropCont X :=
  ⟨fun x => f x ⊔ g x, f.continuous.sup g.continuous⟩

@[simp] theorem TropCont.tsup_apply {X : Type*} [TopologicalSpace X]
    (f g : TropCont X) (x : X) : (TropCont.tsup f g) x = f x ⊔ g x := rfl

/-! ## Tropical Functional -/

/-- A max-plus linear functional on continuous functions `X → WithBot ℝ`.

This structure captures the tropical analogue of a positive linear functional:
- `map_sup'`: preserves tropical addition (= pointwise sup)
- `map_const'`: normalizes constant functions
- `map_addConst'`: commutes with tropical scalar multiplication (= translation by constants)
- `monotone'`: order-preserving -/
structure TropicalFunctional (X : Type*) [TopologicalSpace X] where
  /-- The underlying function on `TropCont X`. -/
  toFun : TropCont X → WithBot ℝ
  /-- Preservation of pointwise supremum (tropical addition). -/
  map_sup' : ∀ f g : TropCont X, toFun (TropCont.tsup f g) = toFun f ⊔ toFun g
  /-- Normalization of constant functions. -/
  map_const' : ∀ c : WithBot ℝ, toFun (ContinuousMap.const _ c) = c
  /-- Commutation with additive translation (tropical scalar action).
  The function `g` must satisfy `g x = c + f x` for all `x`. -/
  map_addConst' : ∀ (c : WithBot ℝ) (f g : TropCont X),
    (∀ x, g x = c + f x) → toFun g = c + toFun f
  /-- Monotonicity (order-preservation). -/
  monotone' : ∀ {f g : TropCont X}, (∀ x, f x ≤ g x) → toFun f ≤ toFun g

namespace TropicalFunctional

variable {X : Type*} [TopologicalSpace X]

/-- Extensionality: two tropical functionals are equal iff they agree on all functions. -/
@[ext]
theorem ext {Λ₁ Λ₂ : TropicalFunctional X}
    (h : ∀ f, Λ₁.toFun f = Λ₂.toFun f) : Λ₁ = Λ₂ := by
  cases Λ₁; cases Λ₂; simp only [mk.injEq]; ext f; exact h f

/-- Monotonicity restated as a named lemma. -/
theorem monotone (Λ : TropicalFunctional X) {f g : TropCont X}
    (h : ∀ x, f x ≤ g x) : Λ.toFun f ≤ Λ.toFun g :=
  Λ.monotone' h

/-- Evaluation of a tropical functional on a constant function. -/
@[simp]
theorem map_const (Λ : TropicalFunctional X) (c : WithBot ℝ) :
    Λ.toFun (ContinuousMap.const _ c) = c :=
  Λ.map_const' c

/-- A tropical functional preserves sup of a pair. -/
theorem map_sup (Λ : TropicalFunctional X) (f g : TropCont X) :
    Λ.toFun (TropCont.tsup f g) = Λ.toFun f ⊔ Λ.toFun g :=
  Λ.map_sup' f g

end TropicalFunctional

end