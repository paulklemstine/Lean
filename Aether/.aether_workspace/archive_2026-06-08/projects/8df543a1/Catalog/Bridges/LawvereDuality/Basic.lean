/-
Copyright (c) 2025 Lawvere Metric Duality Project. All rights reserved.

# Closure-Cost Systems and Lawvere Computation: Core Definitions

Foundational structures for a duality between closure-cost systems and
Lawvere-enriched computation systems. The key insight: a closure operator
paired with a residuated cost function on a finite type internally generates
a computational metric space whose points are distinguishing observables.

## Main Definitions

* `ClosureCostSystem` — Finite type with closure operator and Lawvere cost
* `CostObservable` — Closure-compatible nonexpansive observable
* `LawvereCompSystem` — Generalized (asymmetric) metric space
* `specDist` — Lawvere metric on observables via residuation
* `yonedaObs` — Yoneda embedding: each point → cost observable
-/

import Mathlib

namespace LawvereDuality

open ENNReal

noncomputable section

/-! ## Closure-Cost Systems -/

/-- A closure-cost system: a closure operator with compatible Lawvere cost.
    The closure captures computational coarse-graining; the cost captures
    program distance / transformation cost.
    The closure acts as a metric retraction: both `cost x (cl x) = 0`
    and `cost (cl x) x = 0`, so x and cl(x) are at distance zero. -/
structure ClosureCostSystem (α : Type*) where
  cl : α → α
  cost : α → α → ℝ≥0∞
  cl_idem : ∀ x, cl (cl x) = cl x
  cl_cost_zero : ∀ x, cost x (cl x) = 0
  cl_cost_zero_rev : ∀ x, cost (cl x) x = 0
  cost_refl : ∀ x, cost x x = 0
  cost_triangle : ∀ x y z, cost x z ≤ cost x y + cost y z
  cl_nonexpansive : ∀ x y, cost (cl x) (cl y) ≤ cost x y

/-- Separation: distinct closed elements have positive directed cost. -/
def ClosureCostSystem.Separated {α : Type*} (S : ClosureCostSystem α) : Prop :=
  ∀ x y, S.cl x = x → S.cl y = y → S.cost x y = 0 → S.cost y x = 0 → x = y

/-- An element is closed (fixed by closure). -/
def ClosureCostSystem.IsClosed {α : Type*} (S : ClosureCostSystem α) (x : α) : Prop :=
  S.cl x = x

/-! ## Cost Observables -/

/-- A cost observable: closure-compatible and nonexpansive w.r.t. cost.
    Nonexpansiveness means: φ(y) ≤ φ(x) + cost(x, y). -/
structure CostObservable {α : Type*} (S : ClosureCostSystem α) where
  toFun : α → ℝ≥0∞
  map_cl : ∀ x, toFun (S.cl x) = toFun x
  nonexpansive : ∀ x y, toFun y ≤ toFun x + S.cost x y

instance {α : Type*} {S : ClosureCostSystem α} :
    CoeFun (CostObservable S) (fun _ => α → ℝ≥0∞) := ⟨CostObservable.toFun⟩

/-! ## Lawvere Computation Systems -/

/-- A Lawvere computation system: asymmetric generalized metric space
    valued in ℝ≥0∞. Distances may be asymmetric and may be ∞. -/
structure LawvereCompSystem (β : Type*) where
  dist : β → β → ℝ≥0∞
  dist_refl : ∀ x, dist x x = 0
  dist_triangle : ∀ x y z, dist x z ≤ dist x y + dist y z

/-! ## Spectrum Distance -/

/-- The Lawvere metric on observables:
    d(φ, ψ) = sup_x (φ(x) - ψ(x)).
    This is the enriched Kantorovich-style metric. -/
def specDist {α : Type*} [Fintype α] (S : ClosureCostSystem α)
    (φ ψ : CostObservable S) : ℝ≥0∞ :=
  Finset.univ.sup fun x => φ x - ψ x

/-! ## Yoneda Embedding -/

/-- Each point `a` gives a cost observable φ_a(x) = cost(a, x).
    This is the enriched Yoneda embedding into the tropical function space. -/
def yonedaObs {α : Type*} (S : ClosureCostSystem α) (a : α) : CostObservable S where
  toFun := S.cost a
  map_cl := by
    intro x
    apply le_antisymm
    · calc S.cost a (S.cl x)
          ≤ S.cost a x + S.cost x (S.cl x) := S.cost_triangle a x (S.cl x)
        _ = S.cost a x + 0 := by rw [S.cl_cost_zero x]
        _ = S.cost a x := add_zero _
    · calc S.cost a x
          ≤ S.cost a (S.cl x) + S.cost (S.cl x) x := S.cost_triangle a (S.cl x) x
        _ = S.cost a (S.cl x) + 0 := by rw [S.cl_cost_zero_rev x]
        _ = S.cost a (S.cl x) := add_zero _
  nonexpansive := fun x y => S.cost_triangle a x y

/-! ## ClosureCost ↔ Lawvere Conversions -/

/-- A closure-cost system is naturally a Lawvere system (forgetting closure). -/
def toLawvere {α : Type*} (S : ClosureCostSystem α) : LawvereCompSystem α where
  dist := S.cost
  dist_refl := S.cost_refl
  dist_triangle := S.cost_triangle

/-- A Lawvere system gives a closure-cost system with identity closure. -/
def fromLawvere {β : Type*} (L : LawvereCompSystem β) : ClosureCostSystem β where
  cl := id
  cost := L.dist
  cl_idem := fun _ => rfl
  cl_cost_zero := L.dist_refl
  cl_cost_zero_rev := L.dist_refl
  cost_refl := L.dist_refl
  cost_triangle := L.dist_triangle
  cl_nonexpansive := fun _ _ => le_refl _

/-! ## Morphisms -/

/-- Morphism of closure-cost systems. -/
structure ClosureCostHom {α β : Type*}
    (S : ClosureCostSystem α) (T : ClosureCostSystem β) where
  toFun : α → β
  map_cl : ∀ x, toFun (S.cl x) = T.cl (toFun x)
  nonexpansive : ∀ x y, T.cost (toFun x) (toFun y) ≤ S.cost x y

/-- Morphism of Lawvere systems: nonexpansive map. -/
structure LawvereCompHom {α β : Type*}
    (L : LawvereCompSystem α) (M : LawvereCompSystem β) where
  toFun : α → β
  nonexpansive : ∀ x y, M.dist (toFun x) (toFun y) ≤ L.dist x y

/-! ## Products -/

/-- Product of closure-cost systems. -/
def ClosureCostSystem.prod {α β : Type*}
    (S : ClosureCostSystem α) (T : ClosureCostSystem β) :
    ClosureCostSystem (α × β) where
  cl := fun p => (S.cl p.1, T.cl p.2)
  cost := fun p q => S.cost p.1 q.1 ⊔ T.cost p.2 q.2
  cl_idem := by intro ⟨a, b⟩; simp [S.cl_idem, T.cl_idem]
  cl_cost_zero := by intro ⟨a, b⟩; simp [S.cl_cost_zero, T.cl_cost_zero]
  cl_cost_zero_rev := by intro ⟨a, b⟩; simp [S.cl_cost_zero_rev, T.cl_cost_zero_rev]
  cost_refl := by intro ⟨a, b⟩; simp [S.cost_refl, T.cost_refl]
  cost_triangle := by
    intro ⟨a₁, b₁⟩ ⟨a₂, b₂⟩ ⟨a₃, b₃⟩
    apply sup_le
    · calc S.cost a₁ a₃ ≤ S.cost a₁ a₂ + S.cost a₂ a₃ := S.cost_triangle a₁ a₂ a₃
        _ ≤ (S.cost a₁ a₂ ⊔ T.cost b₁ b₂) + (S.cost a₂ a₃ ⊔ T.cost b₂ b₃) := by
            gcongr <;> exact le_sup_left
    · calc T.cost b₁ b₃ ≤ T.cost b₁ b₂ + T.cost b₂ b₃ := T.cost_triangle b₁ b₂ b₃
        _ ≤ (S.cost a₁ a₂ ⊔ T.cost b₁ b₂) + (S.cost a₂ a₃ ⊔ T.cost b₂ b₃) := by
            gcongr <;> exact le_sup_right
  cl_nonexpansive := by
    intro ⟨a₁, b₁⟩ ⟨a₂, b₂⟩
    exact sup_le_sup (S.cl_nonexpansive a₁ a₂) (T.cl_nonexpansive b₁ b₂)

/-- Product of Lawvere systems. -/
def LawvereCompSystem.prod {α β : Type*}
    (L : LawvereCompSystem α) (M : LawvereCompSystem β) :
    LawvereCompSystem (α × β) where
  dist := fun p q => L.dist p.1 q.1 ⊔ M.dist p.2 q.2
  dist_refl := by intro ⟨a, b⟩; simp [L.dist_refl, M.dist_refl]
  dist_triangle := by
    intro ⟨a₁, b₁⟩ ⟨a₂, b₂⟩ ⟨a₃, b₃⟩
    apply sup_le
    · calc L.dist a₁ a₃ ≤ L.dist a₁ a₂ + L.dist a₂ a₃ := L.dist_triangle a₁ a₂ a₃
        _ ≤ (L.dist a₁ a₂ ⊔ M.dist b₁ b₂) + (L.dist a₂ a₃ ⊔ M.dist b₂ b₃) := by
            gcongr <;> exact le_sup_left
    · calc M.dist b₁ b₃ ≤ M.dist b₁ b₂ + M.dist b₂ b₃ := M.dist_triangle b₁ b₂ b₃
        _ ≤ (L.dist a₁ a₂ ⊔ M.dist b₁ b₂) + (L.dist a₂ a₃ ⊔ M.dist b₂ b₃) := by
            gcongr <;> exact le_sup_right

/-! ## Realization -/

/-- A Lawvere system realizes a closure-cost system via an isometric embedding. -/
structure Realizes {α β : Type*} (S : ClosureCostSystem α) (L : LawvereCompSystem β)
    (embed : α → β) : Prop where
  preserves_cost : ∀ x y, L.dist (embed x) (embed y) = S.cost x y

end

end LawvereDuality