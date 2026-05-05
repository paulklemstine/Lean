/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Tropical Functional Infrastructure

Core definitions for tropical (max-plus) continuous functions and functionals.

## Main definitions

- `TropCont X`: continuous functions `X → WithBot ℝ` (tropical continuous functions)
- `TropicalFunctional X`: max-plus linear functionals on `TropCont X`
- `UCTropicalFunctional X`: upper-continuous tropical functionals

## Mathematical context

In tropical (idempotent) mathematics, the max-plus semiring `(ℝ ∪ {-∞}, max, +)` replaces
the usual `(ℝ, +, ×)`. A tropical functional is the idempotent analogue of a positive
linear functional in classical analysis, satisfying `Λ(f ⊔ g) = Λ(f) ⊔ Λ(g)` (maxitivity)
and `Λ(c + f) = c + Λ(f)` (tropical homogeneity).
-/

import Mathlib

noncomputable section

open scoped Classical

/-! ## Topology on WithBot ℝ -/

instance : TopologicalSpace (WithBot ℝ) := Preorder.topology (WithBot ℝ)
instance : OrderTopology (WithBot ℝ) := ⟨rfl⟩

/-! ## Tropical continuous functions -/

/-- A tropical continuous function on a topological space `X`:
a continuous function `X → WithBot ℝ`. Here `WithBot ℝ = ℝ ∪ {⊥}` where `⊥ = -∞`. -/
abbrev TropCont (X : Type*) [TopologicalSpace X] := ContinuousMap X (WithBot ℝ)

namespace TropCont

variable {X : Type*} [TopologicalSpace X]

/-- Pointwise supremum (tropical addition) of two tropical continuous functions. -/
def tsup (f g : TropCont X) : TropCont X :=
  ⟨fun x => f x ⊔ g x, by
    apply Continuous.sup f.continuous g.continuous⟩

@[simp]
theorem tsup_apply (f g : TropCont X) (x : X) : tsup f g x = f x ⊔ g x := rfl

/-- Support of a tropical continuous function: the set where it is not `⊥`. -/
def support (f : TropCont X) : Set X :=
  {x | f x ≠ ⊥}

@[simp]
theorem mem_support_iff (f : TropCont X) (x : X) : x ∈ f.support ↔ f x ≠ ⊥ := Iff.rfl

end TropCont

/-! ## Tropical functionals -/

/-- A tropical (max-plus linear) functional on `TropCont X`.
This is a function `Λ : TropCont X → WithBot ℝ` satisfying:
- **Maxitivity**: `Λ(f ⊔ g) = Λ(f) ⊔ Λ(g)`
- **Tropical homogeneity**: `Λ(c + f) = c + Λ(f)` for constants `c`
- **Monotonicity**: `f ≤ g → Λ(f) ≤ Λ(g)`
- **Normalization on constants**: `Λ(const c) = c` -/
structure TropicalFunctional (X : Type*) [TopologicalSpace X] where
  /-- The underlying function. -/
  toFun : TropCont X → WithBot ℝ
  /-- Maxitivity: commutes with pointwise sup. -/
  map_sup' : ∀ f g : TropCont X, toFun (TropCont.tsup f g) = toFun f ⊔ toFun g
  /-- Normalization: sends constant functions to their value. -/
  map_const' : ∀ c : WithBot ℝ, toFun (ContinuousMap.const _ c) = c
  /-- Tropical homogeneity: adding a constant to a function translates the functional value.
  We state this as: if `g = c + f` pointwise, then `Λ(g) = c + Λ(f)`. -/
  map_addConst' : ∀ (c : WithBot ℝ) (f g : TropCont X),
    (∀ x, g x = c + f x) → toFun g = c + toFun f
  /-- Monotonicity: pointwise `≤` implies functional value `≤`. -/
  monotone' : ∀ {f g : TropCont X}, (∀ x, f x ≤ g x) → toFun f ≤ toFun g

attribute [simp] TropicalFunctional.map_const'

instance {X : Type*} [TopologicalSpace X] : CoeFun (TropicalFunctional X)
    (fun _ => TropCont X → WithBot ℝ) :=
  ⟨TropicalFunctional.toFun⟩

@[ext]
theorem TropicalFunctional.ext {X : Type*} [TopologicalSpace X]
    {Λ Γ : TropicalFunctional X} (h : ∀ f, Λ.toFun f = Γ.toFun f) : Λ = Γ := by
  cases Λ; cases Γ; simp only [mk.injEq]; ext f; exact h f

/-! ## Upper-continuous tropical functional -/

/-- An upper-continuous tropical functional: if a monotone sequence of functions converges
pointwise, the functional values converge. This is the tropical analogue of the
monotone convergence theorem. -/
structure UCTropicalFunctional (X : Type*) [TopologicalSpace X]
    extends TropicalFunctional X where
  /-- Upper continuity: commutes with directed suprema of monotone sequences. -/
  upper_continuous' :
    ∀ {f : ℕ → TropCont X} {g : TropCont X},
      Monotone f →
      (∀ x, Filter.Tendsto (fun n => f n x) Filter.atTop (nhds (g x))) →
      Filter.Tendsto (fun n => toFun (f n)) Filter.atTop (nhds (toFun g))

instance {X : Type*} [TopologicalSpace X] : CoeFun (UCTropicalFunctional X)
    (fun _ => TropCont X → WithBot ℝ) :=
  ⟨fun Λ => Λ.toFun⟩

@[ext]
theorem UCTropicalFunctional.ext {X : Type*} [TopologicalSpace X]
    {Λ Γ : UCTropicalFunctional X} (h : ∀ f, Λ.toFun f = Γ.toFun f) : Λ = Γ := by
  cases Λ; cases Γ; simp only [mk.injEq]; exact TropicalFunctional.ext h

end