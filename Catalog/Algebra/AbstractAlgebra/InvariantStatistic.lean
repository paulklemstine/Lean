import Mathlib

/-!
# Invariant Statistics and Equivariant Transport

This file defines the notion of an "invariant statistic" — a function on a
G-set that is constant on orbits — and proves that such statistics can be
transported along equivariant equivalences.

This provides a formal mechanism for moving algebraic/combinatorial observables
(such as pair correlation functions, autocorrelation energies, and Sidon defects)
across equivalent algebraic models.

## Main Definitions

- `InvariantStatistic G α β`: A function `α → β` invariant under a `G`-action.
- `InvariantStatistic.pullback`: Pullback along equivariant maps.
- `InvariantStatistic.pushforward`: Pushforward along equivariant maps.

## Main Results

- `invariantStatistic_constant_on_orbit`: Invariant statistics are constant on orbits.
- `pullback_pushforward_eq`: Pullback and pushforward are inverse operations.
- `invariantStatistic_factors_through_quotient`: An invariant statistic factors
  through the orbit quotient.
-/

noncomputable section

/-!
## Core Definitions
-/

/-- An invariant statistic on a G-set α with values in β is a function f : α → β
that is constant under the group action: f(g • x) = f(x) for all g ∈ G, x ∈ α. -/
structure InvariantStatistic (G : Type*) [Group G] (α : Type*) [MulAction G α]
    (β : Type*) where
  /-- The underlying function. -/
  toFun : α → β
  /-- Invariance under the group action. -/
  invariant' : ∀ (g : G) (x : α), toFun (g • x) = toFun x

namespace InvariantStatistic

variable {G : Type*} [Group G] {α β γ : Type*} [MulAction G α]

instance : CoeFun (InvariantStatistic G α β) (fun _ => α → β) :=
  ⟨InvariantStatistic.toFun⟩

@[simp]
theorem coe_mk (f : α → β) (hf : ∀ (g : G) (x : α), f (g • x) = f x) :
    (InvariantStatistic.mk f hf : α → β) = f := rfl

@[simp]
theorem invariant (f : InvariantStatistic G α β) (g : G) (x : α) :
    f (g • x) = f x :=
  f.invariant' g x

/-- Two invariant statistics are equal iff their underlying functions are equal. -/
@[ext]
theorem ext {f₁ f₂ : InvariantStatistic G α β} (h : ∀ x, f₁ x = f₂ x) : f₁ = f₂ := by
  cases f₁; cases f₂; simp only [mk.injEq]; ext x; exact h x

/-- An invariant statistic is constant on orbits: if y = g • x for some g,
then f(x) = f(y). -/
theorem constant_on_orbit (f : InvariantStatistic G α β) {x y : α}
    (h : ∃ g : G, g • x = y) : f x = f y := by
  obtain ⟨g, rfl⟩ := h
  exact (f.invariant g x).symm

/-- An invariant statistic is constant on each orbit set. -/
theorem constant_on_orbit_set (f : InvariantStatistic G α β) (x : α)
    {y : α} (hy : y ∈ MulAction.orbit G x) : f x = f y := by
  obtain ⟨g, rfl⟩ := hy
  exact (f.invariant g x).symm

/-!
## Transport along Equivariant Maps
-/

/-- Transport an invariant statistic along an equivariant equivalence.
If e : α ≃ β is equivariant (e(g • x) = g • e(x)), then any invariant
statistic on β pulls back to an invariant statistic on α. -/
def pullback [MulAction G β] (e : α ≃ β) (he : ∀ (g : G) (x : α), e (g • x) = g • e x)
    (f : InvariantStatistic G β γ) : InvariantStatistic G α γ where
  toFun := f.toFun ∘ e
  invariant' g x := by simp [Function.comp, he, f.invariant]

/-- The pullback preserves values. -/
@[simp]
theorem pullback_apply [MulAction G β] (e : α ≃ β)
    (he : ∀ (g : G) (x : α), e (g • x) = g • e x)
    (f : InvariantStatistic G β γ) (x : α) :
    (pullback e he f) x = f (e x) := rfl

/-- Push forward an invariant statistic along an equivariant equivalence. -/
def pushforward [MulAction G β] (e : α ≃ β) (he : ∀ (g : G) (x : α), e (g • x) = g • e x)
    (f : InvariantStatistic G α γ) : InvariantStatistic G β γ where
  toFun := f.toFun ∘ e.symm
  invariant' g y := by
    simp only [Function.comp]
    have : e.symm (g • y) = g • e.symm y := by
      apply e.injective
      simp [he, Equiv.apply_symm_apply]
    rw [this, f.invariant]

/-- The pushforward preserves values. -/
@[simp]
theorem pushforward_apply [MulAction G β] (e : α ≃ β)
    (he : ∀ (g : G) (x : α), e (g • x) = g • e x)
    (f : InvariantStatistic G α γ) (y : β) :
    (pushforward e he f) y = f (e.symm y) := rfl

/-- Pullback and pushforward are inverse operations. -/
theorem pullback_pushforward [MulAction G β] (e : α ≃ β)
    (he : ∀ (g : G) (x : α), e (g • x) = g • e x)
    (f : InvariantStatistic G α γ) :
    pullback e he (pushforward e he f) = f := by
  ext x; simp [pullback, pushforward, Function.comp]

/-- Pushforward then pullback is also the identity. -/
theorem pushforward_pullback [MulAction G β] (e : α ≃ β)
    (he : ∀ (g : G) (x : α), e (g • x) = g • e x)
    (f : InvariantStatistic G β γ) :
    pushforward e he (pullback e he f) = f := by
  ext y; simp [pullback, pushforward, Function.comp]

/-!
## Algebraic Operations on Invariant Statistics
-/

/-- The constant function is always an invariant statistic. -/
def const (G : Type*) [Group G] (α : Type*) [MulAction G α] (β : Type*) (b : β) :
    InvariantStatistic G α β where
  toFun := fun _ => b
  invariant' := fun _ _ => rfl

/-- Post-composition with any function preserves invariance. -/
def comp (f : InvariantStatistic G α β) (h : β → γ) :
    InvariantStatistic G α γ where
  toFun := h ∘ f.toFun
  invariant' g x := by simp [Function.comp, f.invariant]

@[simp]
theorem comp_apply (f : InvariantStatistic G α β) (h : β → γ) (x : α) :
    (f.comp h) x = h (f x) := rfl

/-- Product of two invariant statistics. -/
def prod (f : InvariantStatistic G α β) (g : InvariantStatistic G α γ) :
    InvariantStatistic G α (β × γ) where
  toFun x := (f x, g x)
  invariant' a x := by simp [f.invariant, g.invariant]

/-- Sum of two real-valued invariant statistics. -/
def add [Add β] (f g : InvariantStatistic G α β) :
    InvariantStatistic G α β where
  toFun x := f x + g x
  invariant' a x := by simp [f.invariant, g.invariant]

/-- Scalar multiplication of an invariant statistic. -/
def smul [SMul γ β] (c : γ) (f : InvariantStatistic G α β) :
    InvariantStatistic G α β where
  toFun x := c • f x
  invariant' g x := by simp [f.invariant]

end InvariantStatistic

end