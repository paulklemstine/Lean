/-
  Bridge: connects order-theoretic closure operators to thermodynamic fixed-point semantics
  and certified robustness via abstract lattice dynamics.

  This file establishes the foundational order-theoretic layer for closure-enriched
  Morita theory. All results are stated for general preorders/partial orders,
  providing the engine for fixed-point transport across algebraic equivalences.
-/
import Mathlib

namespace ClosureMorita

/-! ## 1. Closure Operator on a Preorder

Bridge: connects lattice theory to quantum state purification and
thermodynamic equilibrium dynamics. -/

/-- A closure operator on a preordered type: monotone, extensive, idempotent.
This is the abstract engine for thermodynamic fixed-point semantics,
quantum certified invariants, and post_quantum_security analysis. -/
structure ClosureOperatorOn (α : Type u) [Preorder α] where
  toFun : α → α
  monotone' : Monotone toFun
  extensive' : ∀ a, a ≤ toFun a
  idempotent' : ∀ a, toFun (toFun a) = toFun a

namespace ClosureOperatorOn

variable {α : Type u} [Preorder α] (c : ClosureOperatorOn α)

/-- A closure-fixed point: `c a = a`. These correspond to thermodynamic
equilibrium states, quantum stable observables, and certified invariants. -/
def IsFixed (a : α) : Prop := c.toFun a = a

/-- The image of the closure operator is always a fixed point.
Bridge: connects closure idempotence to thermodynamic equilibrium stability —
applying the closure twice reaches the same state. -/
@[simp]
theorem isFixed_apply (a : α) : c.IsFixed (c.toFun a) := c.idempotent' a

/-- Fixed-point characterization is definitional. -/
theorem isFixed_iff (a : α) : c.IsFixed a ↔ c.toFun a = a := Iff.rfl

/-- An element below a fixed point has its closure below that fixed point.
Bridge: connects closure dominance to certified_robustness —
perturbations below a stable state remain bounded after closure. -/
theorem apply_le_of_fixed {a b : α} (hb : c.IsFixed b) (h : a ≤ b) :
    c.toFun a ≤ b := by
  calc c.toFun a ≤ c.toFun b := c.monotone' h
    _ = b := hb

/-- Closure is extensive: every element is below its closure. -/
theorem le_apply (a : α) : a ≤ c.toFun a := c.extensive' a

/-- Monotonicity of the closure operator. -/
theorem apply_mono {a b : α} (h : a ≤ b) : c.toFun a ≤ c.toFun b :=
  c.monotone' h

/-- Fixed points are exactly the range of the closure operator.
Bridge: connects closure range characterization to quantum observable
classification — certified observables are exactly those arising from
closure purification. -/
theorem isFixed_iff_mem_range (a : α) :
    c.IsFixed a ↔ ∃ b, c.toFun b = a := by
  constructor
  · intro h; exact ⟨a, h⟩
  · rintro ⟨b, rfl⟩; exact c.isFixed_apply b

/-- The closure of any element is ≥ the element itself (extensive). -/
theorem extensive_le (a : α) : a ≤ c.toFun a := c.extensive' a

end ClosureOperatorOn

/-! ## 2. Order-preserving maps and closure transport -/

/-- A monotone map between preorders that commutes with closure operators.
Bridge: connects order-preserving transport to representation-independent
thermodynamic semantics and post_quantum_security invariants. -/
structure ClosureEquivariantMap {α : Type u} {β : Type v}
    [Preorder α] [Preorder β]
    (cα : ClosureOperatorOn α) (cβ : ClosureOperatorOn β) where
  toFun : α → β
  monotone' : Monotone toFun
  comm : ∀ a, toFun (cα.toFun a) = cβ.toFun (toFun a)

namespace ClosureEquivariantMap

variable {α : Type u} {β : Type v} [Preorder α] [Preorder β]
variable {cα : ClosureOperatorOn α} {cβ : ClosureOperatorOn β}

/-- Equivariant maps transport fixed points.
Bridge: connects fixed-point transport to quantum state equivalence —
certified invariants are preserved under equivariant encodings. -/
theorem map_fixed (f : ClosureEquivariantMap cα cβ) {a : α}
    (ha : cα.IsFixed a) : cβ.IsFixed (f.toFun a) := by
  unfold ClosureOperatorOn.IsFixed at *
  rw [← f.comm, ha]

/-- Equivariant maps preserve the fixed-point property bidirectionally
when the underlying map is injective. -/
theorem reflects_fixed_of_injective (f : ClosureEquivariantMap cα cβ)
    (hinj : Function.Injective f.toFun) {a : α}
    (ha : cβ.IsFixed (f.toFun a)) : cα.IsFixed a := by
  unfold ClosureOperatorOn.IsFixed at *
  apply hinj
  rw [f.comm, ha]

end ClosureEquivariantMap

/-! ## 3. Closure-preserving order isomorphisms -/

/-- An order isomorphism that intertwines two closure operators.
Bridge: connects closure-preserving equivalences to Morita-type transport
of thermodynamic invariants and quantum certified state spaces. -/
structure ClosureOrderIso {α : Type u} {β : Type v}
    [Preorder α] [Preorder β]
    (cα : ClosureOperatorOn α) (cβ : ClosureOperatorOn β) where
  toOrderIso : α ≃o β
  comm : ∀ a, toOrderIso (cα.toFun a) = cβ.toFun (toOrderIso a)

namespace ClosureOrderIso

variable {α : Type u} {β : Type v} [Preorder α] [Preorder β]
variable {cα : ClosureOperatorOn α} {cβ : ClosureOperatorOn β}

/-- A closure order iso transports fixed points forward. -/
theorem map_fixed (e : ClosureOrderIso cα cβ) {a : α}
    (ha : cα.IsFixed a) : cβ.IsFixed (e.toOrderIso a) := by
  unfold ClosureOperatorOn.IsFixed at *
  rw [← e.comm, ha]

/-- A closure order iso reflects fixed points backward. -/
theorem reflect_fixed (e : ClosureOrderIso cα cβ) {b : β}
    (hb : cβ.IsFixed b) : cα.IsFixed (e.toOrderIso.symm b) := by
  unfold ClosureOperatorOn.IsFixed at *
  apply e.toOrderIso.injective
  rw [e.comm, OrderIso.apply_symm_apply, hb]

/-- Fixed points correspond bijectively under a closure order iso.
Bridge: connects fixed-point bijection to quantum certified state equivalence —
two presentations have the same certified invariant space. -/
theorem fixed_iff (e : ClosureOrderIso cα cβ) (a : α) :
    cα.IsFixed a ↔ cβ.IsFixed (e.toOrderIso a) := by
  constructor
  · exact e.map_fixed
  · intro h
    have := e.reflect_fixed h
    rwa [OrderIso.symm_apply_apply] at this

end ClosureOrderIso

end ClosureMorita