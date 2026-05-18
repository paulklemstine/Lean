/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Lawvere–Thermodynamic Galois Correspondence

## Overview

This file formalizes the **Lawvere–Thermodynamic Galois Correspondence**, which
identifies derivability closure in proof theory with the closure operator
induced by a thermodynamic adjunction between proof states and observables.

The key insight is that given:
- A preorder `P` of proof states,
- A preorder `O` of thermodynamic observables,
- An antitone "lower-envelope" map `lowerEnv : P → O`,
- An antitone "theory-of" map `theoryOf : O → P`,

satisfying the adjunction law `lowerEnv p ≤ o ↔ p ≤ theoryOf o`
(with appropriate dualization), the composite `theoryOf ∘ lowerEnv` is a
closure operator on `P` whose fixed points are exactly `Set.range theoryOf`.

This means: **derivability-closed proof states are exactly those cut out by
thermodynamic observables.**

## Main results

- `ThermoGaloisContext'` — the abstract interface for the adjunction
- `thermoClosure` — the induced closure operator `theoryOf ∘ lowerEnv`
- `thermoClosureOperator` — packaging as Mathlib's `ClosureOperator`
- `fixedPoints_thermoClosure_eq_range_theoryOf` — the representation theorem
- `refineIter_eventually_stable` — finite stabilization of iterative refinement
- `refineIter_stabilizes_by_card` — cardinality-bounded convergence
- `refineIter_limit_is_closed` — the limit is a fixed point of closure

## References

- F. W. Lawvere, *Metric spaces, generalized logic, and closed categories*, 1973
- The thermodynamic interpretation follows the analogy between free-energy
  profiles and semantic separation in proof theory.
-/

open OrderDual Set

universe u v

/-! ## The Thermodynamic Galois Context -/

/-- A `ThermoGaloisContext'` packages a Galois connection between proof states `P`
and dualized observables `OrderDual O`. The map `lowerEnv` sends a proof state
to its free-energy profile (in `OrderDual O`), and `theoryOf` sends an observable
to the derivability-closed theory it determines. The Galois connection axiom
encodes: `lowerEnv p ≤ o ↔ p ≤ theoryOf o` (with `o : OrderDual O`). -/
structure ThermoGaloisContext' (P : Type u) (O : Type v) [Preorder P] [Preorder O] where
  /-- The lower-envelope / free-energy profile map from proof states to dualized observables. -/
  lowerEnv : P → OrderDual O
  /-- The theory map from dualized observables to proof states. -/
  theoryOf : OrderDual O → P
  /-- The Galois connection between `lowerEnv` and `theoryOf`. -/
  gc : GaloisConnection lowerEnv theoryOf

/-! ## The Thermodynamic Closure Operator -/

/-- The thermodynamic closure of a proof state: apply the lower-envelope map
and then recover the theory. This is the composite `theoryOf ∘ lowerEnv`. -/
def thermoClosure {P : Type u} {O : Type v} [Preorder P] [Preorder O]
    (h : ThermoGaloisContext' P O) : P → P :=
  fun p => h.theoryOf (h.lowerEnv p)

/-- Every proof state is below its thermodynamic closure (extensivity). -/
theorem le_thermoClosure {P : Type u} {O : Type v} [Preorder P] [Preorder O]
    (h : ThermoGaloisContext' P O) (p : P) :
    p ≤ thermoClosure h p :=
  h.gc.le_u_l p

/-- The thermodynamic closure is monotone. -/
theorem thermoClosure_monotone {P : Type u} {O : Type v} [Preorder P] [Preorder O]
    (h : ThermoGaloisContext' P O) :
    Monotone (thermoClosure h) :=
  h.gc.monotone_u.comp h.gc.monotone_l

/-- The reductive law: applying `lowerEnv` after `theoryOf` brings you back down. -/
theorem gc_reductive {P : Type u} {O : Type v} [Preorder P] [Preorder O]
    (h : ThermoGaloisContext' P O) (o : OrderDual O) :
    h.lowerEnv (h.theoryOf o) ≤ o :=
  h.gc.l_u_le o

/-- The thermodynamic closure is idempotent (as `≤`). -/
theorem thermoClosure_idem_le {P : Type u} {O : Type v} [Preorder P] [Preorder O]
    (h : ThermoGaloisContext' P O) (p : P) :
    thermoClosure h (thermoClosure h p) ≤ thermoClosure h p :=
  h.gc.monotone_u (h.gc.l_u_le (h.lowerEnv p))

/-- The thermodynamic closure is idempotent (as equality, requires `PartialOrder P`). -/
theorem thermoClosure_idem {P : Type u} {O : Type v}
    [PartialOrder P] [Preorder O]
    (h : ThermoGaloisContext' P O) (p : P) :
    thermoClosure h (thermoClosure h p) = thermoClosure h p :=
  le_antisymm (thermoClosure_idem_le h p) (le_thermoClosure h _)

/-! ## Packaging as a Mathlib ClosureOperator -/

/-- The thermodynamic closure packaged as a Mathlib `ClosureOperator`. -/
noncomputable def thermoClosureOperator {P : Type u} {O : Type v}
    [PartialOrder P] [Preorder O]
    (h : ThermoGaloisContext' P O) : ClosureOperator P :=
  h.gc.closureOperator

theorem thermoClosureOperator_apply {P : Type u} {O : Type v}
    [PartialOrder P] [Preorder O]
    (h : ThermoGaloisContext' P O) (p : P) :
    (thermoClosureOperator h) p = thermoClosure h p :=
  rfl

/-! ## Fixed-Point Characterization -/

/-- Elements in the range of `theoryOf` are fixed by thermodynamic closure. -/
theorem range_theoryOf_subset_fixedPoints {P : Type u} {O : Type v}
    [PartialOrder P] [Preorder O]
    (h : ThermoGaloisContext' P O) :
    range h.theoryOf ⊆ {p : P | thermoClosure h p = p} := by
  rintro p ⟨o, rfl⟩
  show h.theoryOf (h.lowerEnv (h.theoryOf o)) = h.theoryOf o
  exact le_antisymm (h.gc.monotone_u (h.gc.l_u_le o)) (h.gc.le_u_l (h.theoryOf o))

/-- Fixed points of thermodynamic closure lie in the range of `theoryOf`. -/
theorem fixedPoints_subset_range_theoryOf {P : Type u} {O : Type v}
    [PartialOrder P] [Preorder O]
    (h : ThermoGaloisContext' P O) :
    {p : P | thermoClosure h p = p} ⊆ range h.theoryOf := by
  intro p (hp : h.theoryOf (h.lowerEnv p) = p)
  exact ⟨h.lowerEnv p, hp⟩

/-- **The Representation Theorem**: The fixed points of thermodynamic closure
are exactly the range of `theoryOf`. Derivability-closed proof states are
precisely those determined by thermodynamic observables. -/
theorem fixedPoints_thermoClosure_eq_range_theoryOf {P : Type u} {O : Type v}
    [PartialOrder P] [Preorder O]
    (h : ThermoGaloisContext' P O) :
    {p : P | thermoClosure h p = p} = range h.theoryOf :=
  le_antisymm (fixedPoints_subset_range_theoryOf h)
    (range_theoryOf_subset_fixedPoints h)

/-- Derivability-closed iff theory of some observable. -/
theorem derivability_closed_iff_theory_of_observable {P : Type u} {O : Type v}
    [PartialOrder P] [Preorder O]
    (h : ThermoGaloisContext' P O) (p : P) :
    thermoClosure h p = p ↔ ∃ o : OrderDual O, h.theoryOf o = p := by
  constructor
  · intro hp
    exact ⟨h.lowerEnv p, (hp : h.theoryOf (h.lowerEnv p) = p)⟩
  · rintro ⟨o, rfl⟩
    show h.theoryOf (h.lowerEnv (h.theoryOf o)) = h.theoryOf o
    exact le_antisymm (h.gc.monotone_u (h.gc.l_u_le o)) (h.gc.le_u_l _)

/-
If a derivability closure has the same fixed points as `thermoClosure`,
then they agree pointwise.
-/
theorem derivabilityClosure_eq_thermoClosure {P : Type u} {O : Type v}
    [PartialOrder P] [Preorder O]
    (h : ThermoGaloisContext' P O)
    (derivClosure : P → P)
    (h_extensive : ∀ p, p ≤ derivClosure p)
    (h_mono : Monotone derivClosure)
    (h_idem : ∀ p, derivClosure (derivClosure p) = derivClosure p)
    (h_closed_iff :
      ∀ p, derivClosure p = p ↔ ∃ o : OrderDual O, h.theoryOf o = p) :
    derivClosure = thermoClosure h := by
  funext p;
  refine' le_antisymm _ _;
  · have h_fixed_point : derivClosure (thermoClosure h p) = thermoClosure h p := by
      exact h_closed_iff _ |>.2 ⟨ _, rfl ⟩;
    exact h_fixed_point ▸ h_mono ( le_thermoClosure h p );
  · obtain ⟨o, ho⟩ : ∃ o : OrderDual O, h.theoryOf o = derivClosure p := by
      exact h_closed_iff _ |>.1 ( h_idem p );
    have h_lowerEnv_p_le_o : h.lowerEnv p ≤ o := by
      exact h.gc.le_iff_le.2 ( ho.symm ▸ h_extensive p );
    exact ho ▸ h.gc.monotone_u h_lowerEnv_p_le_o

/-
A Galois connection induces a closure operator with the expected properties.
-/
theorem galoisConnection_induces_closure
    {P : Type u} {O : Type v} [PartialOrder P] [Preorder O]
    (l : P → OrderDual O) (u : OrderDual O → P)
    (hgc : GaloisConnection l u) :
    ∃ c : P → P,
      Monotone c ∧
      (∀ p, p ≤ c p) ∧
      (∀ p, c (c p) = c p) ∧
      c = fun p => u (l p) := by
  use fun p => u ( l p );
  have := hgc.monotone_l;
  exact ⟨ hgc.monotone_u.comp this, fun p => hgc.le_u_l p, fun p => le_antisymm ( hgc.monotone_u <| hgc.l_u_le _ ) ( hgc.le_u_l _ ), rfl ⟩

/-
The fixed-point/range theorem for an abstract Galois connection.
-/
theorem fixedPoints_eq_range_of_gc
    {P : Type u} {O : Type v} [PartialOrder P] [Preorder O]
    (l : P → OrderDual O) (u : OrderDual O → P)
    (hgc : GaloisConnection l u) :
    {p : P | u (l p) = p} = range u := by
  -- Apply the fixedPoint theorem to the Galois connection hgc.
  apply fixedPoints_thermoClosure_eq_range_theoryOf ⟨l, u, hgc⟩

/-! ## Iterative Refinement and Finite Stabilization -/

/-- One step of the alternating refinement: apply `theoryOf ∘ lowerEnv`. -/
def refineStep {P : Type u} {O : Type v} [Preorder P] [Preorder O]
    (h : ThermoGaloisContext' P O) : P → P :=
  thermoClosure h

/-- Iterated refinement starting from a proof state. -/
def refineIter {P : Type u} {O : Type v} [Preorder P] [Preorder O]
    (h : ThermoGaloisContext' P O) : ℕ → P → P
  | 0, p => p
  | n + 1, p => refineStep h (refineIter h n p)

/-
Each refinement step is at least as large as the previous one.
-/
theorem refineIter_le_succ {P : Type u} {O : Type v}
    [PartialOrder P] [Preorder O]
    (h : ThermoGaloisContext' P O) (p : P) (n : ℕ) :
    refineIter h n p ≤ refineIter h (n + 1) p := by
  exact le_thermoClosure h _

/-
The refinement iteration stabilizes after just 1 step, since
`thermoClosure` is idempotent.
-/
theorem refineIter_stabilizes_at_one {P : Type u} {O : Type v}
    [PartialOrder P] [Preorder O]
    (h : ThermoGaloisContext' P O) (p : P) (n : ℕ) (hn : 1 ≤ n) :
    refineIter h n p = refineIter h 1 p := by
  induction hn <;> simp_all +decide [ refineIter ];
  -- By definition of `refineStep`, we have `refineStep h (refineStep h p) = thermoClosure h (thermoClosure h p)`.
  simp [refineStep];
  exact thermoClosure_idem h p

/-
On a finite partial order, iterative refinement eventually stabilizes.
-/
theorem refineIter_eventually_stable {P : Type u} {O : Type v}
    [Fintype P] [PartialOrder P] [Preorder O]
    (h : ThermoGaloisContext' P O) :
    ∀ p : P, ∃ n : ℕ, refineIter h (n + 1) p = refineIter h n p := by
  intro p
  use 1;
  exact thermoClosure_idem h _

/-
On a finite partial order, refinement stabilizes by `Fintype.card P` steps.
In fact, it stabilizes after 1 step by idempotency.
-/
theorem refineIter_stabilizes_by_card {P : Type u} {O : Type v}
    [Fintype P] [PartialOrder P] [Preorder O]
    (h : ThermoGaloisContext' P O) (p : P) :
    refineIter h (Fintype.card P) p = refineIter h (Fintype.card P + 1) p := by
  by_cases hP : Fintype.card P = 0;
  · exact absurd hP ( Nat.ne_of_gt ( Fintype.card_pos_iff.mpr ⟨ p ⟩ ) );
  · rw [ refineIter_stabilizes_at_one h p ( Fintype.card P ) ( Nat.pos_of_ne_zero hP ), refineIter_stabilizes_at_one h p ( Fintype.card P + 1 ) ( Nat.succ_pos _ ) ]

/-
The stabilized value is closed under thermodynamic closure.
-/
theorem refineIter_limit_is_closed {P : Type u} {O : Type v}
    [Fintype P] [PartialOrder P] [Preorder O]
    (h : ThermoGaloisContext' P O) (p : P) :
    thermoClosure h (refineIter h (Fintype.card P) p) =
      refineIter h (Fintype.card P) p := by
  have := refineIter_stabilizes_by_card h p;
  exact this.symm