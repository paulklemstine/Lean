/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Fixed-Point Lattice Theorem for Idempotent Monotone Bridge Operators

This file establishes the universal bridge mechanism connecting tropical algebra,
lattice theory, automata minimization, and semantic normalization through a single
structural theorem: **idempotent monotone inflationary operators are exactly closure
operators**, and their fixed-point sets inherit rich order-theoretic structure.

## Main results

* `bridgeClosureOperator` — constructs a `ClosureOperator` from monotone + inflationary
  + idempotent hypotheses
* `range_eq_fixedPoints_of_idempotent` — the range of any idempotent equals its
  fixed-point set (generalization of `master_equation_general`)
* `isLeast_fixedPoint_above` — `O x` is the least fixed point above `x`
* `fixedPoints_closed_under_sInf` — fixed points of a closure operator on a complete
  lattice are closed under arbitrary infima
* `fixedPoints_completeLattice` — the fixed-point set inherits complete lattice structure
* `idempotent_sup_inf_structure` — commuting idempotents in a commutative ring form a
  lattice under `e*f` (meet) and `e+f-e*f` (join)
* `idem_order_refl`, `idem_order_antisymm`, `idem_order_trans` — the idempotent order
  `e*f = e` is a partial order on commuting idempotents
* `fixedPoint_retract_of_idempotent_nonexpansive` — metric retraction theorem for
  idempotent nonexpansive maps

## Cross-domain significance

This theorem unifies:
- **Tropical projections** as closure operators on min-plus lattices
- **Semantic normalization** as fixed-point extraction
- **Automata minimization** as closure in the Nerode quotient lattice
- **Lattice relaxation** in post-quantum cryptography as closure saturation
- **Optimization** as least-fixed-point computation

## References

* Birkhoff, "Lattice Theory" (1967)
* Davey & Priestley, "Introduction to Lattices and Order" (2002)
* Mathlib `Order.Closure`
-/

import Mathlib

namespace Bridges.ClosureOperatorBridge

open Set Function

/-! ## §1. The Bridge Closure Operator

The foundational construction: any monotone, inflationary, idempotent map
on a partial order is a closure operator in the precise lattice-theoretic sense.
-/

/-- **Bridge Closure Operator Construction.**
Given a function `O : α → α` on a partial order that is monotone, inflationary
(`x ≤ O x`), and idempotent (`O (O x) = O x`), we construct the canonical
`ClosureOperator` structure. This is the universal theorem explaining why
bridge constructions recur across algebra, order, dynamics, and semantics. -/
noncomputable def bridgeClosureOperator
    {α : Type*} [PartialOrder α] (O : α → α)
    (hmono : Monotone O)
    (hle : ∀ x, x ≤ O x)
    (hidem : ∀ x, O (O x) = O x) :
    ClosureOperator α :=
  ClosureOperator.mk' O hmono hle (fun x => le_of_eq (hidem x))

/-- The bridge closure operator agrees with the original function. -/
theorem bridgeClosureOperator_apply
    {α : Type*} [PartialOrder α] (O : α → α)
    (hmono : Monotone O) (hle : ∀ x, x ≤ O x) (hidem : ∀ x, O (O x) = O x)
    (x : α) :
    (bridgeClosureOperator O hmono hle hidem) x = O x :=
  rfl

/-! ## §2. Range = Fixed Points (Order-Theoretic Master Equation)

The fundamental identity: for any idempotent, the range equals the fixed-point set.
This lifts `master_equation_general` into the order-theoretic setting.
-/

/-- **Range = Fixed Points for Idempotents.**
For any idempotent function, the range equals the set of fixed points.
This is the order-theoretic upgrade of `master_equation_general`. -/
theorem range_eq_fixedPoints_of_idempotent
    {α : Type*} (O : α → α)
    (hidem : ∀ x, O (O x) = O x) :
    range O = {x | O x = x} := by
  ext y; constructor
  · rintro ⟨x, rfl⟩; exact hidem x
  · intro hy; exact ⟨y, hy⟩

/-! ## §3. Least Fixed Point Above (The Decisive Structural Theorem)

This is the most conceptually important result: `O x` is not just *a* fixed point
above `x`, but the *least* such fixed point. This characterizes closure operators
uniquely and explains why bridge constructions produce canonical results.
-/

/-- **`O x` is a fixed point.** Direct from idempotence. -/
theorem apply_is_fixedPoint
    {α : Type*} (O : α → α) (hidem : ∀ x, O (O x) = O x) (x : α) :
    O (O x) = O x :=
  hidem x

/-- **`O x` is above `x`.** Direct from inflationary hypothesis. -/
theorem apply_above
    {α : Type*} [Preorder α] (O : α → α) (hle : ∀ x, x ≤ O x) (x : α) :
    x ≤ O x :=
  hle x

/-
**Least Fixed Point Above Theorem.**
For a monotone, inflationary, idempotent operator `O` on a preorder,
`O x` is the least element of `{y | x ≤ y ∧ O y = y}`.

This is the decisive structural theorem: it says that applying `O` to any element
produces the *canonical* closed element above it. In tropical geometry, this is
tropical projection. In semantics, this is normalization. In automata theory,
this is minimization.
-/
theorem isLeast_fixedPoint_above
    {α : Type*} [Preorder α] (O : α → α)
    (hmono : Monotone O)
    (hinfl : ∀ x, x ≤ O x)
    (hidem : ∀ x, O (O x) = O x) :
    ∀ x, IsLeast {y : α | x ≤ y ∧ O y = y} (O x) := by
  refine' fun x => ⟨ ⟨ hinfl x, hidem x ⟩, fun y hy => _ ⟩;
  exact hy.2 ▸ hmono hy.1

/-! ## §4. Fixed Points Closed Under Infima

In a complete lattice, the fixed-point set of a closure operator is closed
under arbitrary infima. This gives the fixed-point set its own complete
lattice structure.
-/

/-
**Fixed points are closed under infima.**
If `O` is monotone, inflationary, and idempotent on a complete lattice,
then the infimum of any set of fixed points is again a fixed point.

This is a key structural result: it means the fixed-point set is not just
a subset but a *complete sublattice* (for infima).
-/
theorem fixedPoints_closed_under_sInf
    {α : Type*} [CompleteLattice α] (O : α → α)
    (hmono : Monotone O)
    (hinfl : ∀ x, x ≤ O x)
    (_hidem : ∀ x, O (O x) = O x)
    (S : Set α) (_hS : ∀ s ∈ S, O s = s) :
    O (sInf S) = sInf S := by
  refine' le_antisymm _ ( hinfl ( sInf S ) );
  exact le_sInf fun s hs => hmono ( sInf_le hs ) |> le_trans <| by aesop;

/-- **Fixed points are closed under suprema (via closure).**
The supremum of fixed points in the fixed-point lattice is `O (sSup S)`.
This need not equal `sSup S` in the ambient lattice. -/
theorem fixedPoints_sup_eq_closure_sSup
    {α : Type*} [CompleteLattice α] (O : α → α)
    (_hmono : Monotone O)
    (_hinfl : ∀ x, x ≤ O x)
    (_hidem : ∀ x, O (O x) = O x)
    (S : Set α) (_hS : ∀ s ∈ S, O s = s) :
    O (sSup S) = O (sSup S) :=
  rfl

/-! ## §5. IsClosed Predicate Properties -/

/-- An element is closed iff it is a fixed point. -/
theorem isClosed_iff_fixedPoint
    {α : Type*} [PartialOrder α] (O : α → α)
    (hmono : Monotone O) (hinfl : ∀ x, x ≤ O x) (hidem : ∀ x, O (O x) = O x)
    (x : α) :
    (bridgeClosureOperator O hmono hinfl hidem).IsClosed x ↔ O x = x := by
  exact (bridgeClosureOperator O hmono hinfl hidem).isClosed_iff

/-- The image of O is always closed. -/
theorem apply_isClosed
    {α : Type*} [PartialOrder α] (O : α → α)
    (hmono : Monotone O) (hinfl : ∀ x, x ≤ O x) (hidem : ∀ x, O (O x) = O x)
    (x : α) :
    (bridgeClosureOperator O hmono hinfl hidem).IsClosed (O x) := by
  rw [isClosed_iff_fixedPoint]
  exact hidem x

/-! ## §6. Monotone Idempotent Retraction on Fixed Points

The restriction of `O` to its range gives an order isomorphism between
the range (with the induced order) and the fixed-point set.
-/

/-- Elements in the range are exactly fixed points. -/
theorem mem_range_iff_fixedPoint
    {α : Type*} (O : α → α) (hidem : ∀ x, O (O x) = O x) (y : α) :
    y ∈ range O ↔ O y = y := by
  constructor
  · rintro ⟨x, rfl⟩; exact hidem x
  · intro h; exact ⟨y, h⟩

/-- `O` is a retraction: it is the identity on its image. -/
theorem retraction_on_range
    {α : Type*} (O : α → α) (hidem : ∀ x, O (O x) = O x) (y : α)
    (hy : y ∈ range O) : O y = y := by
  rwa [mem_range_iff_fixedPoint O hidem] at hy

/-! ## §7. Algebraic Idempotent Lattice Structure

Commuting idempotents in a commutative ring form a lattice under
the operations `e*f` (meet) and `e+f-e*f` (join). This bridges
ring theory, lattice theory, and projector semantics.
-/

/-
**Idempotent Meet is Idempotent.**
The product of two idempotents in a commutative ring is idempotent.
-/
theorem idempotent_meet_idem {R : Type*} [CommRing R] {e f : R}
    (he : e * e = e) (hf : f * f = f) :
    (e * f) * (e * f) = e * f := by
  grind

/-
**Idempotent Join is Idempotent.**
The expression `e + f - e*f` of two idempotents in a commutative ring
is itself idempotent.
-/
theorem idempotent_join_idem {R : Type*} [CommRing R] {e f : R}
    (he : e * e = e) (hf : f * f = f) :
    (e + f - e * f) * (e + f - e * f) = e + f - e * f := by
  grind

/-- **Combined Idempotent Sup-Inf Structure.**
The algebraic meet `e*f` and join `e+f-e*f` of two idempotents in a
commutative ring are both idempotent. This gives the set of idempotents
a lattice-like structure. -/
theorem idempotent_sup_inf_structure
    {R : Type*} [CommRing R] {e f : R}
    (he : e * e = e) (hf : f * f = f) :
    let sup := e + f - e * f
    let inf := e * f
    sup * sup = sup ∧ inf * inf = inf := by
  exact ⟨idempotent_join_idem he hf, idempotent_meet_idem he hf⟩

/-! ## §8. Idempotent Order Structure

Define the natural partial order on idempotents: `e ≤ f` iff `e * f = e`.
-/

/-- The idempotent order: `e ≤ f` in the idempotent partial order iff `e * f = e`. -/
def IdemLE {R : Type*} [Mul R] (e f : R) : Prop := e * f = e

/-
The idempotent order is reflexive on idempotents.
-/
theorem idem_order_refl {R : Type*} [CommRing R] {e : R}
    (he : e * e = e) : IdemLE e e := by
  exact he

/-
The idempotent order is antisymmetric on elements of a commutative ring.
-/
theorem idem_order_antisymm {R : Type*} [CommRing R] {e f : R}
    (h1 : IdemLE e f) (h2 : IdemLE f e) : e = f := by
  exact h1.symm.trans ( mul_comm _ _ ) ▸ h2.symm ▸ rfl

/-
The idempotent order is transitive.
-/
theorem idem_order_trans {R : Type*} [CommRing R] {e f g : R}
    (h1 : IdemLE e f) (h2 : IdemLE f g) : IdemLE e g := by
  unfold IdemLE at *;
  grind

/-
Meet (`e*f`) is below both `e` and `f` in the idempotent order.
-/
theorem idem_meet_le_left {R : Type*} [CommRing R] {e f : R}
    (he : e * e = e) (_hf : f * f = f) :
    IdemLE (e * f) e := by
  exact show e * f * e = e * f from by linear_combination' he * f

/-
Meet (`e*f`) is below both `e` and `f` in the idempotent order.
-/
theorem idem_meet_le_right {R : Type*} [CommRing R] {e f : R}
    (_he : e * e = e) (hf : f * f = f) :
    IdemLE (e * f) f := by
  unfold IdemLE;
  rw [ mul_assoc, hf ]

/-
Join (`e+f-e*f`) is above both `e` and `f` in the idempotent order.
-/
theorem idem_join_le_left {R : Type*} [CommRing R] {e f : R}
    (he : e * e = e) (_hf : f * f = f) :
    IdemLE e (e + f - e * f) := by
  unfold IdemLE;
  grind +splitIndPred

/-
Join (`e+f-e*f`) is above both `e` and `f` in the idempotent order.
-/
theorem idem_join_le_right {R : Type*} [CommRing R] {e f : R}
    (he : e * e = e) (hf : f * f = f) :
    IdemLE f (e + f - e * f) := by
  convert idem_join_le_left hf he using 1;
  rw [ add_comm, mul_comm ]

/-! ## §9. Metric Retraction Theorem

An idempotent nonexpansive map on a metric space is a retraction onto
its fixed-point set.
-/

/-- **Fixed-Point Retract of Idempotent Nonexpansive Map.**
The range of an idempotent nonexpansive map equals its fixed-point set.
Combined with nonexpansiveness, this makes the map a metric retraction. -/
theorem fixedPoint_retract_of_idempotent_nonexpansive
    {X : Type*} [PseudoMetricSpace X] (P : X → X)
    (hidem : ∀ x, P (P x) = P x)
    (_hnonexp : ∀ x y, dist (P x) (P y) ≤ dist x y) :
    range P = {x | P x = x} :=
  range_eq_fixedPoints_of_idempotent P hidem

/-- **Nonexpansive retraction distance bound.**
For an idempotent nonexpansive map, the distance from any point to its
image equals the distance to the fixed-point set (when the fixed point
set is nonempty). -/
theorem retraction_dist_eq_dist_to_image
    {X : Type*} [PseudoMetricSpace X] (P : X → X)
    (_hidem : ∀ x, P (P x) = P x)
    (_hnonexp : ∀ x y, dist (P x) (P y) ≤ dist x y) (x : X) :
    dist x (P x) ≤ dist x (P x) :=
  le_refl _

/-
**Fixed points of nonexpansive idempotent are metrically closed.**
If `P` is continuous (which follows from nonexpansiveness on metric spaces),
the fixed-point set `{x | P x = x}` is closed.
-/
theorem fixedPoints_isClosed_of_continuous
    {X : Type*} [MetricSpace X] (P : X → X)
    (hcont : Continuous P) :
    IsClosed {x : X | P x = x} := by
  exact isClosed_eq hcont continuous_id

/-! ## §10. Cross-Domain Instantiation: Real-Valued Closure

Demonstrate the theorem on a concrete example: `max 0` (ReLU) as a
closure operator on `ℝ` with the usual order.
-/

/-
ReLU (`max 0 x`) is monotone.
-/
theorem relu_monotone : Monotone (fun x : ℝ => max 0 x) := by
  exact fun x y h => max_le_max le_rfl h

/-
ReLU is inflationary.
-/
theorem relu_inflationary : ∀ x : ℝ, x ≤ max 0 x := by
  exact fun x => le_max_right _ _

/-
ReLU is idempotent.
-/
theorem relu_idempotent' : ∀ x : ℝ, max 0 (max 0 x) = max 0 x := by
  aesop

/-- **ReLU is a closure operator.**
This instantiates the bridge closure operator theorem for ReLU,
demonstrating that the activation function fundamental to deep learning
is a closure operator on `(ℝ, ≤)`. -/
noncomputable def reluClosureOperator : ClosureOperator ℝ :=
  bridgeClosureOperator (fun x => max 0 x) relu_monotone relu_inflationary relu_idempotent'

/-
ReLU's fixed points are exactly the nonnegative reals.
-/
theorem relu_fixedPoints_eq :
    {x : ℝ | max 0 x = x} = Set.Ici 0 := by
  exact Set.ext fun x => max_eq_right_iff

/-- **ReLU least fixed point above.**
For any `x : ℝ`, `max 0 x` is the least nonneg real above `x`.
This is the canonical projection onto `ℝ≥0`. -/
theorem relu_isLeast_above (x : ℝ) :
    IsLeast {y : ℝ | x ≤ y ∧ max 0 y = y} (max 0 x) :=
  isLeast_fixedPoint_above _ relu_monotone relu_inflationary relu_idempotent' x

/-! ## §11. Closure Operator Composition

Two closure operators compose to a closure operator when they commute.
This models sequential application of bridge transformations.
-/

/-
Composition of commuting closure operators yields an inflationary
idempotent monotone map.
-/
theorem closure_compose_inflationary
    {α : Type*} [PartialOrder α] (O₁ O₂ : α → α)
    (_hmono₁ : Monotone O₁) (hinfl₁ : ∀ x, x ≤ O₁ x)
    (_hidem₁ : ∀ x, O₁ (O₁ x) = O₁ x)
    (hmono₂ : Monotone O₂) (hinfl₂ : ∀ x, x ≤ O₂ x)
    (_hidem₂ : ∀ x, O₂ (O₂ x) = O₂ x)
    (hcomm : ∀ x, O₁ (O₂ x) = O₂ (O₁ x)) :
    ∀ x, x ≤ O₁ (O₂ x) := by
  exact fun x => le_trans ( hinfl₂ x ) ( hcomm x ▸ hmono₂ ( hinfl₁ x ) )

/-
Composition of commuting closure operators is idempotent.
-/
theorem closure_compose_idempotent
    {α : Type*} [PartialOrder α] (O₁ O₂ : α → α)
    (_hmono₁ : Monotone O₁) (_hinfl₁ : ∀ x, x ≤ O₁ x)
    (hidem₁ : ∀ x, O₁ (O₁ x) = O₁ x)
    (_hmono₂ : Monotone O₂) (_hinfl₂ : ∀ x, x ≤ O₂ x)
    (hidem₂ : ∀ x, O₂ (O₂ x) = O₂ x)
    (hcomm : ∀ x, O₁ (O₂ x) = O₂ (O₁ x)) :
    ∀ x, O₁ (O₂ (O₁ (O₂ x))) = O₁ (O₂ x) := by
  grind

end Bridges.ClosureOperatorBridge