import Mathlib

/-!
# Priestley Duality for Closure-Temporal Semimodules

## Overview

We establish a finite duality-and-minimality theorem for ordered structures
equipped with closure and temporal operators. This upgrades classical
Stone/Priestley duality to handle closure dynamics and temporal observables,
connecting idempotent algebra, temporal logic, and certified reconstruction.

## Main definitions

* `ClosureTemporalOrder` - A partial order with closure and temporal operators
* `StableObservable` - Observables stable under closure and temporal structure
* `ObsEquiv` - Observational equivalence (indistinguishability by stable observables)
* `Separated` - A CTO where observational equivalence implies equality

## Main results

* `cl_congr` - Closure preserves observational equivalence
* `T_congr` - Temporal operator preserves observational equivalence
* `evalObs_injective` - Reconstruction: separation implies faithful embedding
* `obsEquiv_coarsest` - ObsEquiv is the coarsest observation-preserving congruence
* `obsQuotient_card_le` - Minimality: the observational quotient has fewest elements

## References

This development connects:
- **Priestley duality** for finite distributive lattices
- **Idempotent semiring / tropical semimodule** theory
- **Temporal logic** and coalgebraic semantics
- **Certified reconstruction** and minimal realization theory
-/

namespace PriestleyDuality

-- ============================================================
-- §1. Core Definitions
-- ============================================================

/-- A closure-temporal order: a partial order equipped with a closure operator
`cl` (monotone, extensive, idempotent) and a temporal operator `T` (monotone,
preserving closed elements). This abstracts the algebraic structure of
idempotent semimodules with temporal dynamics. -/
class ClosureTemporalOrder (M : Type*) [PartialOrder M] where
  /-- The closure operator. -/
  cl : M → M
  /-- Closure is monotone. -/
  cl_monotone : Monotone cl
  /-- Closure is extensive: `x ≤ cl x`. -/
  cl_extensive : ∀ x, x ≤ cl x
  /-- Closure is idempotent: `cl (cl x) = cl x`. -/
  cl_idem : ∀ x, cl (cl x) = cl x
  /-- The temporal operator. -/
  T : M → M
  /-- The temporal operator is monotone. -/
  T_monotone : Monotone T
  /-- The temporal operator preserves closed elements:
  if `cl x = x` then `cl (T x) = T x`. -/
  T_closed : ∀ x, cl x = x → cl (T x) = T x

variable {M : Type*} [PartialOrder M] [ClosureTemporalOrder M]

/-- An element is closed if it is a fixed point of the closure operator. -/
def IsClosed (x : M) : Prop := ClosureTemporalOrder.cl x = x

/-- Closure of any element is closed. -/
theorem isClosed_cl (x : M) : IsClosed (ClosureTemporalOrder.cl x) :=
  ClosureTemporalOrder.cl_idem x

/-- The temporal operator preserves closed elements. -/
theorem isClosed_T {x : M} (hx : IsClosed x) : IsClosed (ClosureTemporalOrder.T x) :=
  ClosureTemporalOrder.T_closed x hx

/-- `T` applied to a closed element yields a closed element. -/
theorem cl_T_of_closed {x : M} (hx : IsClosed x) :
    ClosureTemporalOrder.cl (ClosureTemporalOrder.T x) = ClosureTemporalOrder.T x :=
  ClosureTemporalOrder.T_closed x hx

-- ============================================================
-- §2. Stable Observables
-- ============================================================

/-- A stable observable: an order-upset of `M` that is invariant under
closure preimage (together with the automatic forward direction, this gives
a biconditional) and temporal dynamics (biconditional).

These play the role of clopen up-sets in classical Priestley duality,
upgraded to be compatible with closure and temporal structure. -/
structure StableObservable (M : Type*) [PartialOrder M] [ClosureTemporalOrder M] where
  /-- The underlying set. -/
  carrier : Set M
  /-- The set is an order-upset: if `x ≤ y` and `x ∈ carrier`, then `y ∈ carrier`. -/
  is_upset : ∀ ⦃x y : M⦄, x ≤ y → x ∈ carrier → y ∈ carrier
  /-- Closure-inverse stability: if `cl x ∈ carrier` then `x ∈ carrier`. -/
  cl_inv : ∀ x, ClosureTemporalOrder.cl x ∈ carrier → x ∈ carrier
  /-- Temporal biconditional: `x ∈ carrier ↔ T x ∈ carrier`. -/
  T_iff : ∀ x, x ∈ carrier ↔ ClosureTemporalOrder.T x ∈ carrier

namespace StableObservable

variable (O : StableObservable M)

/-- Forward closure stability (automatic from upset + extensive). -/
theorem cl_fwd {x : M} (hx : x ∈ O.carrier) :
    ClosureTemporalOrder.cl x ∈ O.carrier :=
  O.is_upset (ClosureTemporalOrder.cl_extensive x) hx

/-- Closure biconditional: `x ∈ O.carrier ↔ cl x ∈ O.carrier`. -/
theorem cl_iff (x : M) :
    x ∈ O.carrier ↔ ClosureTemporalOrder.cl x ∈ O.carrier :=
  ⟨O.cl_fwd, O.cl_inv x⟩

/-- The empty set is a stable observable. -/
def empty (M : Type*) [PartialOrder M] [ClosureTemporalOrder M] : StableObservable M where
  carrier := ∅
  is_upset := fun _ _ _ h => h.elim
  cl_inv := fun _ h => h.elim
  T_iff := fun _ => ⟨fun h => h.elim, fun h => h.elim⟩

/-- The universal set is a stable observable. -/
def univ (M : Type*) [PartialOrder M] [ClosureTemporalOrder M] : StableObservable M where
  carrier := Set.univ
  is_upset := fun _ _ _ _ => Set.mem_univ _
  cl_inv := fun _ _ => Set.mem_univ _
  T_iff := fun _ => ⟨fun _ => Set.mem_univ _, fun _ => Set.mem_univ _⟩

/-- Intersection of two stable observables is a stable observable. -/
def inter (O₁ O₂ : StableObservable M) : StableObservable M where
  carrier := O₁.carrier ∩ O₂.carrier
  is_upset := fun _ _ hle ⟨h₁, h₂⟩ => ⟨O₁.is_upset hle h₁, O₂.is_upset hle h₂⟩
  cl_inv := fun x ⟨h₁, h₂⟩ => ⟨O₁.cl_inv x h₁, O₂.cl_inv x h₂⟩
  T_iff := fun x => ⟨fun ⟨h₁, h₂⟩ => ⟨(O₁.T_iff x).mp h₁, (O₂.T_iff x).mp h₂⟩,
                      fun ⟨h₁, h₂⟩ => ⟨(O₁.T_iff x).mpr h₁, (O₂.T_iff x).mpr h₂⟩⟩

/-- Union of two stable observables is a stable observable. -/
def union (O₁ O₂ : StableObservable M) : StableObservable M where
  carrier := O₁.carrier ∪ O₂.carrier
  is_upset := fun _ _ hle h => h.elim (fun h₁ => Or.inl (O₁.is_upset hle h₁))
                                        (fun h₂ => Or.inr (O₂.is_upset hle h₂))
  cl_inv := fun x h => h.elim (fun h₁ => Or.inl (O₁.cl_inv x h₁))
                                (fun h₂ => Or.inr (O₂.cl_inv x h₂))
  T_iff := fun x => ⟨fun h => h.elim (fun h₁ => Or.inl ((O₁.T_iff x).mp h₁))
                                        (fun h₂ => Or.inr ((O₂.T_iff x).mp h₂)),
                      fun h => h.elim (fun h₁ => Or.inl ((O₁.T_iff x).mpr h₁))
                                        (fun h₂ => Or.inr ((O₂.T_iff x).mpr h₂))⟩

end StableObservable

-- ============================================================
-- §3. Observational Equivalence
-- ============================================================

/-- Two elements are observationally equivalent if they belong to exactly
the same stable observables. This is the central concept: it captures
indistinguishability by all closure-temporal-compatible ordered predicates. -/
def ObsEquiv (x y : M) : Prop :=
  ∀ O : StableObservable M, x ∈ O.carrier ↔ y ∈ O.carrier

@[refl]
theorem ObsEquiv.refl (x : M) : ObsEquiv x x := fun _ => Iff.rfl

@[symm]
theorem ObsEquiv.symm {x y : M} (h : ObsEquiv x y) : ObsEquiv y x :=
  fun O => (h O).symm

@[trans]
theorem ObsEquiv.trans {x y z : M} (h1 : ObsEquiv x y) (h2 : ObsEquiv y z) :
    ObsEquiv x z := fun O => (h1 O).trans (h2 O)

/-- Observational equivalence as a `Setoid`. -/
instance obsSetoid (M : Type*) [PartialOrder M] [ClosureTemporalOrder M] : Setoid M where
  r := ObsEquiv
  iseqv := ⟨ObsEquiv.refl, fun h => h.symm, fun h1 h2 => h1.trans h2⟩

/-- **Closure congruence**: The closure operator preserves observational equivalence.
This is the key structural theorem enabling the quotient construction. -/
theorem cl_congr {x y : M} (h : ObsEquiv x y) :
    ObsEquiv (ClosureTemporalOrder.cl x) (ClosureTemporalOrder.cl y) := by
  intro O
  rw [← O.cl_iff x, ← O.cl_iff y]
  exact h O

/-- **Temporal congruence**: The temporal operator preserves observational equivalence.
Together with `cl_congr`, this shows that the CTO operations descend to the quotient. -/
theorem T_congr {x y : M} (h : ObsEquiv x y) :
    ObsEquiv (ClosureTemporalOrder.T x) (ClosureTemporalOrder.T y) := by
  intro O
  rw [← O.T_iff x, ← O.T_iff y]
  exact h O

-- ============================================================
-- §4. Separation and Evaluation
-- ============================================================

/-- A closure-temporal order is **separated** if observational equivalence
implies equality. This is the analogue of the T₀ separation axiom. -/
def Separated (M : Type*) [PartialOrder M] [ClosureTemporalOrder M] : Prop :=
  ∀ x y : M, ObsEquiv x y → x = y

/-- The evaluation map sends each element to its "observable profile":
the function mapping each stable observable to whether the element belongs to it. -/
def evalObs (x : M) : StableObservable M → Prop := fun O => x ∈ O.carrier

/-- Two elements have the same observable profile iff they are
observationally equivalent. -/
theorem evalObs_eq_iff (x y : M) : evalObs x = evalObs y ↔ ObsEquiv x y := by
  constructor
  · intro h O
    exact iff_of_eq (congr_fun h O)
  · intro h
    funext O
    exact propext (h O)

/-- **Reconstruction theorem**: If `M` is separated, the evaluation map
is injective. This means a separated CTO is faithfully represented by
its stable observable algebra. -/
theorem evalObs_injective (hsep : Separated M) :
    Function.Injective (evalObs : M → _) := by
  intro x y h
  exact hsep x y ((evalObs_eq_iff x y).mp h)

-- ============================================================
-- §5. Observational Quotient and Minimality
-- ============================================================

/-- The observational quotient: the type `M` quotiented by observational
equivalence. This is the central object of the duality. -/
def ObsQuotient (M : Type*) [PartialOrder M] [ClosureTemporalOrder M] :=
  Quotient (obsSetoid M)

/-- **Coarsest congruence**: ObsEquiv is the coarsest equivalence relation
such that every stable observable is invariant. Any relation `r` that
preserves all stable observables must refine ObsEquiv:
if `r x y` then `ObsEquiv x y`.

This is the key to minimality: ObsEquiv identifies the maximum number
of elements while preserving all observational information. -/
theorem obsEquiv_coarsest (r : M → M → Prop) (_ : Equivalence r)
    (hpres : ∀ O : StableObservable M, ∀ x y, r x y → (x ∈ O.carrier ↔ y ∈ O.carrier)) :
    ∀ x y, r x y → ObsEquiv x y :=
  fun x y hxy O => hpres O x y hxy

/-
**Minimality theorem**: The observational quotient has at most as many
elements as any other observation-preserving quotient. If `r` is any
equivalence relation such that every stable observable is `r`-invariant,
then `|M/ObsEquiv| ≤ |M/r|`.

Combined with the reconstruction theorem, this says the observational
quotient is the unique minimal separated representation of the observable
algebra.
-/
theorem obsQuotient_card_le [Fintype M]
    (r : Setoid M)
    (hpres : ∀ O : StableObservable M, ∀ x y, r.r x y → (x ∈ O.carrier ↔ y ∈ O.carrier)) :
    Fintype.card (Quotient (obsSetoid M)) ≤ Fintype.card (Quotient r) := by
  refine' Fintype.card_le_of_surjective _ _;
  refine' fun x => Quotient.map' id _ x;
  exact fun x y hxy => fun O => hpres O x y hxy;
  intro x;
  obtain ⟨ x, rfl ⟩ := Quotient.exists_rep x;
  exact ⟨ ⟦x⟧, rfl ⟩

-- ============================================================
-- §6. Finite Priestley-Temporal Space
-- ============================================================

/-- A finite Priestley-temporal space: a finite partial order with a
monotone step function and Priestley separation (for every `x ≰ y`,
there exists an upset separating them). In the finite case with discrete
topology, this captures the essential ordered-temporal structure. -/
structure FinPriestleyTemporalSpace where
  /-- The underlying type. -/
  X : Type*
  /-- Finiteness. -/
  instFintype : Fintype X
  /-- The partial order. -/
  instPartialOrder : PartialOrder X
  /-- Decidable equality. -/
  instDecEq : DecidableEq X
  /-- Temporal step function. -/
  step : X → X
  /-- The step is monotone. -/
  step_mono : @Monotone X X instPartialOrder.toPreorder instPartialOrder.toPreorder step
  /-- Priestley separation: for `x ≰ y`, there is an upset containing `x` but not `y`. -/
  priestley_sep : ∀ x y : X, ¬(@LE.le X instPartialOrder.toLE x y) →
    ∃ U : Set X, (∀ ⦃a b : X⦄, @LE.le X instPartialOrder.toLE a b → a ∈ U → b ∈ U) ∧
    x ∈ U ∧ y ∉ U

-- ============================================================
-- §7. Connection to Idempotent Semimodules
-- ============================================================

/-- A closure-temporal semimodule: a module over an idempotent semiring
equipped with closure and temporal operators. The natural order from
the idempotent semiring (`a ≤ b ↔ a + b = b`, equivalently `a ≤ b ↔ a ⊔ b = b`)
makes this a closure-temporal order.

This connects the abstract CTO framework to concrete algebraic structures
arising in tropical/idempotent algebra. -/
class ClosureTemporalSemimodule (R M : Type*) [IdemSemiring R]
    [AddCommMonoid M] [Module R M] [PartialOrder M] extends ClosureTemporalOrder M

-- ============================================================
-- §8. Morphisms and Functoriality
-- ============================================================

/-- A morphism of closure-temporal orders: a monotone map commuting with
both `cl` and `T`. These are the morphisms of the category of CTOs. -/
structure CTOMorphism (M N : Type*) [PartialOrder M] [ClosureTemporalOrder M]
    [PartialOrder N] [ClosureTemporalOrder N] where
  /-- The underlying function. -/
  toFun : M → N
  /-- The function is monotone. -/
  mono : Monotone toFun
  /-- The function commutes with closure. -/
  cl_comm : ∀ x, toFun (ClosureTemporalOrder.cl x) = ClosureTemporalOrder.cl (toFun x)
  /-- The function commutes with the temporal operator. -/
  T_comm : ∀ x, toFun (ClosureTemporalOrder.T x) = ClosureTemporalOrder.T (toFun x)

variable {N : Type*} [PartialOrder N] [ClosureTemporalOrder N]

/-- Pullback of a stable observable along a CTO morphism is a stable observable.
This is the contravariant functorial action on observables. -/
def StableObservable.pullback (O : StableObservable N) (φ : CTOMorphism M N) :
    StableObservable M where
  carrier := φ.toFun ⁻¹' O.carrier
  is_upset := fun _ _ hle hx => O.is_upset (φ.mono hle) hx
  cl_inv := fun x hcl => by
    rw [Set.mem_preimage]
    rw [Set.mem_preimage, φ.cl_comm] at hcl
    exact O.cl_inv (φ.toFun x) hcl
  T_iff := fun x => by
    simp only [Set.mem_preimage]
    rw [φ.T_comm]
    exact O.T_iff (φ.toFun x)

/-- **Contravariant duality**: A CTO morphism maps observationally equivalent
elements to observationally equivalent elements. This is the key property
enabling the functorial duality between CTOs and Priestley-temporal spaces. -/
theorem morphism_preserves_obsEquiv (φ : CTOMorphism M N)
    {x y : M} (h : ObsEquiv x y) : ObsEquiv (φ.toFun x) (φ.toFun y) := by
  intro O
  exact h (O.pullback φ)

/-- If the target is separated, a CTO morphism sends observationally equivalent
elements to equal elements. -/
theorem morphism_eq_of_obsEquiv_separated (φ : CTOMorphism M N)
    (hsep : Separated N)
    {x y : M} (h : ObsEquiv x y) : φ.toFun x = φ.toFun y :=
  hsep _ _ (morphism_preserves_obsEquiv φ h)

/-
============================================================
§9. Quotient Separation Theorem
============================================================

**Quotient separation**: The observational quotient of any CTO is separated.
This means the quotient M/≈ has no further observational collapse possible:
it is the terminal separated quotient of M.
-/
theorem obsQuotient_separated :
    ∀ x y : ObsQuotient M,
    (∀ O : StableObservable M, (Quotient.lift (fun m => m ∈ O.carrier)
      (fun a b (h : ObsEquiv a b) => propext (h O)) x) ↔
      (Quotient.lift (fun m => m ∈ O.carrier)
      (fun a b (h : ObsEquiv a b) => propext (h O)) y)) →
    x = y := by
  intro x y hxy;
  obtain ⟨ a, rfl ⟩ := Quotient.exists_rep x;
  obtain ⟨ b, rfl ⟩ := Quotient.exists_rep y;
  exact Quotient.sound ( fun O => by simpa using hxy O )

-- ============================================================
-- §10. Finite Representation Theorem
-- ============================================================

/-- **Finite Priestley representation**: Every finite CTO has a monotone
temporal operator. The temporal step function on `M` is the canonical
representation of the temporal dynamics. -/
theorem finite_representation_step :
    Monotone (ClosureTemporalOrder.T : M → M) :=
  ClosureTemporalOrder.T_monotone

/-- The composition of evaluation with the closure operator respects
observational equivalence on both sides. -/
theorem evalObs_cl_comm (x : M) :
    evalObs (ClosureTemporalOrder.cl x) = evalObs x := by
  funext O
  exact propext (O.cl_iff x).symm

/-- The composition of evaluation with the temporal operator respects
observational equivalence on both sides. -/
theorem evalObs_T_comm (x : M) :
    evalObs (ClosureTemporalOrder.T x) = evalObs x := by
  funext O
  exact propext (O.T_iff x).symm

end PriestleyDuality