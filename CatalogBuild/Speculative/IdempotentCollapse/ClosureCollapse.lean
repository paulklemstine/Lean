/-! # CatalogBuild.Speculative.IdempotentCollapse.ClosureCollapse

Auto-generated from theorem catalog database.
Domain: Speculative/IdempotentCollapse
Declarations: 11
-/

import Mathlib

/-- Topological closure is idempotent. -/
theorem topological_closure_idempotent [TopologicalSpace α] (S : Set α) :
    closure (closure S) = closure S :=
  isClosed_closure.closure_eq

/-- Interior is idempotent. -/

theorem interior_idempotent [TopologicalSpace α] (S : Set α) :
    interior (interior S) = interior S :=
  isOpen_interior.interior_eq

/-! ### Convex Hull is Idempotent -/

/-
PROBLEM
The convex hull is idempotent.

PROVIDED SOLUTION
The convex hull of a convex set is itself. convexHull ℝ S is convex, so convexHull ℝ (convexHull ℝ S) = convexHull ℝ S. Use that convex_convexHull or (convexHull ℝ S).convexHull_eq or similar.
-/

theorem convex_hull_idempotent {V : Type*} [AddCommMonoid V] [Module ℝ V] (S : Set V) :
    convexHull ℝ (convexHull ℝ S : Set V) = convexHull ℝ S := by
  exact?

/-! ### Linear Span is Idempotent -/

/-
PROBLEM
Submodule span is idempotent.

PROVIDED SOLUTION
Submodule.span of a submodule is itself. Use Submodule.span_eq for the submodule (Submodule.span R S).
-/

theorem span_idempotent {R M : Type*} [Semiring R] [AddCommMonoid M] [Module R M]
    (S : Set M) :
    Submodule.span R (Submodule.span R S : Set M) = Submodule.span R S := by
  norm_num +zetaDelta at *

/-! ### Abstract Closure Operators -/

/-- An abstract closure operator on a partial order. -/

def ClosureOp.Closed {α : Type*} [Preorder α] (c : ClosureOp α) (x : α) : Prop :=
  c.cl x = x

/-- Every closure value is closed. -/

theorem ClosureOp.cl_is_closed {α : Type*} [Preorder α] (c : ClosureOp α) (x : α) :
    c.Closed (c.cl x) := c.idempotent x

/-- Closed elements are exactly the range of the closure operator. -/

theorem ClosureOp.closed_eq_range {α : Type*} [Preorder α] (c : ClosureOp α) :
    {x | c.Closed x} = range c.cl := by
  ext x; constructor
  · intro h; exact ⟨x, h⟩
  · rintro ⟨y, rfl⟩; exact c.idempotent y

/-- The closure of x is the smallest closed element above x. -/

theorem ClosureOp.cl_le_of_closed_above {α : Type*} [PartialOrder α]
    (c : ClosureOp α) (x y : α) (hy : c.Closed y) (hxy : x ≤ y) :
    c.cl x ≤ y := by
  calc c.cl x ≤ c.cl y := c.monotone x y hxy
    _ = y := hy

/-! ### Galois Connections Yield Closure Operators -/

/-- Every Galois connection (f, g) induces a closure operator g ∘ f. -/

theorem galois_closure_idempotent {α β : Type*} [PartialOrder α] [Preorder β]
    (f : α → β) (g : β → α)
    (gc : GaloisConnection f g) :
    ∀ x, g (f (g (f x))) = g (f x) := by
  intro x
  apply le_antisymm
  · exact gc.monotone_u (gc.l_u_le (f x))
  · exact gc.le_u_l (g (f x))

/-! ### Composing Closures -/

/-
PROBLEM
Composing two closure operators (when they commute) gives an idempotent.

PROVIDED SOLUTION
(c₁ ∘ c₂)(c₁(c₂(x))) = c₁(c₂(c₁(c₂(x)))) = c₁(c₁(c₂(c₂(x)))) by h_comm = c₁(c₂(c₂(x))) by c₁.idempotent = c₁(c₂(x)) by c₂.idempotent.
-/

theorem closure_comp_comm_is_closure {α : Type*} [PartialOrder α]
    (c₁ c₂ : ClosureOp α)
    (h_comm : ∀ x, c₁.cl (c₂.cl x) = c₂.cl (c₁.cl x)) :
    ∀ x, (c₁.cl ∘ c₂.cl) ((c₁.cl ∘ c₂.cl) x) = (c₁.cl ∘ c₂.cl) x := by
  simp +decide [ h_comm, c₁.idempotent, c₂.idempotent ]

/-! ### Transitive Closure as Idempotent Collapse -/

/-- The transitive closure of a relation is idempotent. -/

theorem transitive_closure_idempotent {α : Type*} (r : α → α → Prop) :
    Relation.TransGen (Relation.TransGen r) = Relation.TransGen r := by
  ext x y
  constructor
  · intro h
    induction h with
    | single h => exact h
    | tail _ h ih => exact ih.trans h
  · intro h; exact Relation.TransGen.single h
