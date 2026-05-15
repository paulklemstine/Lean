/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Predicate Transport Along Invariant-Preserving Morphisms

This file establishes a general calculus of **predicate transport** across
theory morphisms. The central abstraction is `InvariantDetermined`: a
predicate on a theory's carrier that depends only on the invariant value.
Such predicates factor through the invariant, transport covariantly along
morphisms (existential push-forward), and pull back contravariantly
(universal pullback). Lower and upper bound predicates become special cases.

## Main Definitions

* `InvariantDetermined T P` — `P` depends only on `T.Inv`
* `PredicateFactorsThroughInvariant T P` — `P` factors as `R ∘ T.Inv`
* `TransferablePredicate f P Q` — `f` maps `P`-witnesses to `Q`-witnesses
* `SatisfiesLowerBound T n` / `SatisfiesUpperBound T n` — threshold predicates
* `InvariantPredicatePush f R` — push an invariant-side predicate to the codomain

## Main Results

* `invariantDetermined_iff_factorsThroughInvariant` — characterization
* `transferablePredicate_exists` — existential transport
* `TransferablePredicate.id` / `.comp` — functoriality
* `satisfiesLowerBound_invariantDetermined` — lower bounds are invariant-determined
* `satisfiesUpperBound_invariantDetermined` — upper bounds are invariant-determined
* `certified_lower_bound_transfer_via_predicates` — old theorem as corollary
* `invariant_determined_transfer` — invariant-determined predicates are stable
* `upper_bound_pullback` — contravariant transport of upper bounds
* `forall_pullback_of_transfer` — universal pullback principle
* `transferablePredicate_exists_comp` — compositional existential transport

## Design Philosophy

This replaces isolated transfer lemmas with a reusable transport machine.
Any property determined by an invariant automatically inherits transfer,
composition, and duality properties. The old `transfer_lower_bound` theorem
becomes a one-line corollary.
-/

import Mathlib
import Bridges.TheoryMorphisms
import Bridges.ComposableTransfer

/-! ## §1. Invariant-Determined Predicates -/

/-- A predicate `P` on a theory's carrier is **invariant-determined** if
    objects with equal invariant values satisfy `P` iff each other does.
    This is the right notion of "P factors through the invariant." -/
def InvariantDetermined (T : ResearchTheory) (P : T.Carrier → Prop) : Prop :=
  ∀ ⦃x y : T.Carrier⦄, T.Inv x = T.Inv y → (P x ↔ P y)

/-- A predicate **factors through the invariant** if there exists a predicate
    `R` on `ℕ` (the invariant type) such that `P x ↔ R (T.Inv x)` for all `x`. -/
def PredicateFactorsThroughInvariant (T : ResearchTheory) (P : T.Carrier → Prop) : Prop :=
  ∃ R : ℕ → Prop, ∀ x, P x ↔ R (T.Inv x)

/-
**Key characterization**: a predicate is invariant-determined if and only if
    it factors through the invariant. This identifies the semantic class of
    transportable predicates as those living on invariant space.
-/
theorem invariantDetermined_iff_factorsThroughInvariant
    (T : ResearchTheory) (P : T.Carrier → Prop) :
    InvariantDetermined T P ↔ PredicateFactorsThroughInvariant T P := by
  refine ⟨ ?_, fun ⟨ R, hR ⟩ x y h ↦ by aesop ⟩;
  intro hP
  use fun n => ∃ x, T.Inv x = n ∧ P x;
  intro x
  constructor;
  · exact fun hx => ⟨ x, rfl, hx ⟩;
  · rintro ⟨ y, hy, hy' ⟩ ; specialize hP hy; aesop;

/-! ## §2. Transferable Predicates -/

/-- A predicate `P` on `T` is **transferable** to `Q` on `U` along `f`
    if every `P`-witness maps to a `Q`-witness. This is the fundamental
    unit of predicate transport. -/
def TransferablePredicate
    {T U : ResearchTheory} (f : TheoryHom T U)
    (P : T.Carrier → Prop) (Q : U.Carrier → Prop) : Prop :=
  ∀ x, P x → Q (f.toFun x)

/-
**Existential transport**: transferable predicates push forward existence.
-/
theorem transferablePredicate_exists
    {T U : ResearchTheory} (f : TheoryHom T U)
    {P : T.Carrier → Prop} {Q : U.Carrier → Prop} :
    TransferablePredicate f P Q → ((∃ x, P x) → ∃ y, Q y) := by
  exact fun h ⟨ x, hx ⟩ => ⟨ f.toFun x, h x hx ⟩

/-! ## §3. Functoriality of Transferable Predicates -/

/-
**Identity**: every predicate is transferable to itself along the identity.
-/
theorem TransferablePredicate.id
    {T : ResearchTheory} {P : T.Carrier → Prop} :
    TransferablePredicate (TheoryHom.id T) P P := by
  -- By definition of transferable predicate, we need to show that for all x, P x implies P (TheoryHom.id T x).
  intro x hPx
  exact hPx

/-
**Composition**: transferable predicates compose along morphism chains.
-/
theorem TransferablePredicate.comp
    {T U V : ResearchTheory}
    (f : TheoryHom T U) (g : TheoryHom U V)
    {P : T.Carrier → Prop} {Q : U.Carrier → Prop} {R : V.Carrier → Prop}
    (hfg : TransferablePredicate f P Q)
    (hgh : TransferablePredicate g Q R) :
    TransferablePredicate (TheoryHom.comp f g) P R := by
  exact fun x hx => hgh ( f.toFun x ) ( hfg x hx )

/-
**Compositional existential transport**: existence witnesses survive
    composed transfers. Combines composition with existential transport.
-/
theorem transferablePredicate_exists_comp
    {T U V : ResearchTheory}
    (f : TheoryHom T U) (g : TheoryHom U V)
    {P : T.Carrier → Prop} {Q : U.Carrier → Prop} {R : V.Carrier → Prop}
    (hf : TransferablePredicate f P Q)
    (hg : TransferablePredicate g Q R) :
    ((∃ x, P x) → ∃ z, R z) := by
  exact fun ⟨ x, hx ⟩ => ⟨ _, hg _ ( hf _ hx ) ⟩

/-! ## §4. Lower and Upper Bound Predicates -/

/-- An element **satisfies the lower bound** `n` if its invariant is ≥ `n`.
    Note: this is a pointwise predicate, complementing the existential
    `SatisfiesLowerBound` from `TheoryMorphisms`. -/
def SatisfiesLowerBoundPred (T : ResearchTheory) (n : ℕ) : T.Carrier → Prop :=
  fun x => n ≤ T.Inv x

/-- An element **satisfies the upper bound** `n` if its invariant is ≤ `n`. -/
def SatisfiesUpperBound (T : ResearchTheory) (n : ℕ) : T.Carrier → Prop :=
  fun x => T.Inv x ≤ n

/-
Lower-bound predicates are invariant-determined.
-/
theorem satisfiesLowerBound_invariantDetermined
    (T : ResearchTheory) (n : ℕ) :
    InvariantDetermined T (SatisfiesLowerBoundPred T n) := by
  exact fun x y h => by unfold SatisfiesLowerBoundPred; aesop;

/-
Upper-bound predicates are invariant-determined.
-/
theorem satisfiesUpperBound_invariantDetermined
    (T : ResearchTheory) (n : ℕ) :
    InvariantDetermined T (SatisfiesUpperBound T n) := by
  -- By definition of `SatisfiesUpperBound`, if `T.Inv x = T.Inv y`, then `T.Inv x ≤ n` if and only if `T.Inv y ≤ n`.
  intros x y hxy
  simp [SatisfiesUpperBound, hxy]

/-! ## §5. Lower Bound Transfer as a Corollary -/

/-
**Lower bound transfer via the predicate framework**: the monotonicity
    of theory morphisms makes lower-bound predicates transferable.
    This subsumes the old `transfer_lower_bound` theorem.
-/
theorem certified_lower_bound_transfer_via_predicates
    {T U : ResearchTheory} (f : TheoryHom T U) (n : ℕ) :
    TransferablePredicate f (SatisfiesLowerBoundPred T n) (SatisfiesLowerBoundPred U n) := by
  exact fun x hx => le_trans hx ( f.monotone_inv x )

/-- The old `transfer_lower_bound` is now a one-line corollary
    of the general predicate transport framework. -/
theorem transfer_lower_bound_as_corollary
    {T U : ResearchTheory} (f : TheoryHom T U) (n : ℕ) :
    SatisfiesLowerBound T n → SatisfiesLowerBound U n := by
  exact transferablePredicate_exists f (certified_lower_bound_transfer_via_predicates f n)

/-! ## §6. Invariant Predicate Push and Transport -/

/-- **Invariant predicate push**: given a predicate `R` on invariant values,
    push it to the codomain carrier via the codomain invariant. -/
def InvariantPredicatePush
    {T U : ResearchTheory} (_f : TheoryHom T U)
    (R : ℕ → Prop) : U.Carrier → Prop :=
  fun y => R (U.Inv y)

/-
**Invariant predicate transport for exact morphisms**: when a morphism
    preserves invariants exactly (not just monotonically), every
    invariant-determined predicate induces a transferable predicate pair
    via its factorization through the invariant.

    Note: this requires exact invariant preservation (`U.Inv (f.toFun x) = T.Inv x`),
    which is stronger than the monotonicity in `TheoryHom`. For the general
    monotone case, see `invariant_determined_transfer` which uses a different
    construction.
-/
theorem invariant_predicate_transport
    {T U : ResearchTheory} (f : TheoryHom T U)
    {P : T.Carrier → Prop}
    (hP : InvariantDetermined T P)
    (hf_exact : ∀ x, U.Inv (f.toFun x) = T.Inv x) :
    ∃ R : ℕ → Prop,
      (∀ x, P x ↔ R (T.Inv x)) ∧
      TransferablePredicate f P (fun y => R (U.Inv y)) := by
  -- By definition of invariant-determined, there exists a predicate R such that P x ↔ R (T.Inv x) for all x.
  obtain ⟨R, hR⟩ : ∃ R : ℕ → Prop, ∀ x, P x ↔ R (T.Inv x) := by
    apply (invariantDetermined_iff_factorsThroughInvariant T P).mp hP;
  exact ⟨ R, hR, fun x hx => by simpa [ hf_exact ] using hR x |>.1 hx ⟩

/-
**Invariant-determined transfer**: invariant-determined predicates on `T`
    produce invariant-determined transferable predicates on `U`.
    The transported predicate is itself invariant-determined.
-/
theorem invariant_determined_transfer
    {T U : ResearchTheory} (f : TheoryHom T U)
    {P : T.Carrier → Prop}
    (_hP : InvariantDetermined T P) :
    ∃ Q : U.Carrier → Prop,
      TransferablePredicate f P Q ∧
      InvariantDetermined U Q := by
  refine' ⟨ fun y => ∃ x, P x ∧ T.Inv x ≤ U.Inv y, _, _ ⟩;
  · exact fun x hx => ⟨ x, hx, f.monotone_inv x ⟩;
  · intro y z hyz;
    grind

/-! ## §7. Contravariant Transport: Universal Pullback -/

/-
**Universal pullback principle**: universal properties pull back
    along any map. If every element of `U` satisfies `Q`, then every
    element in the image of `f` satisfies `Q`.
-/
theorem forall_pullback_of_transfer
    {T U : ResearchTheory} (f : TheoryHom T U)
    {Q : U.Carrier → Prop} :
    (∀ y, Q y) → ∀ x, Q (f.toFun x) := by
  exact fun h x => h _

/-
**Upper bound pullback**: if every element of `U` has invariant ≤ `n`,
    then every element of `T` has invariant ≤ `n` (via the monotonicity
    of the morphism). This is the contravariant dual of lower-bound
    pushforward.
-/
theorem upper_bound_pullback
    {T U : ResearchTheory} (f : TheoryHom T U) (n : ℕ) :
    (∀ y : U.Carrier, U.Inv y ≤ n) → ∀ x : T.Carrier, T.Inv x ≤ n := by
  exact fun h x => le_trans ( f.monotone_inv x ) ( h _ )

/-- **Upper bound pullback using predicates**: codomain-wide upper bounds
    pull back to domain-wide upper bounds. -/
theorem upper_bound_pullback_pred
    {T U : ResearchTheory} (f : TheoryHom T U) (n : ℕ) :
    (∀ y, SatisfiesUpperBound U n y) → ∀ x, SatisfiesUpperBound T n x := by
  exact upper_bound_pullback f n

/-! ## §8. Boolean Closure of Invariant-Determined Predicates -/

/-
Invariant-determined predicates are closed under conjunction.
-/
theorem invariantDetermined_and
    {T : ResearchTheory} {P Q : T.Carrier → Prop}
    (hP : InvariantDetermined T P)
    (hQ : InvariantDetermined T Q) :
    InvariantDetermined T (fun x => P x ∧ Q x) := by
  exact fun x y h => ⟨ fun h' => ⟨ hP h |>.1 h'.1, hQ h |>.1 h'.2 ⟩, fun h' => ⟨ hP h |>.2 h'.1, hQ h |>.2 h'.2 ⟩ ⟩

/-
Invariant-determined predicates are closed under disjunction.
-/
theorem invariantDetermined_or
    {T : ResearchTheory} {P Q : T.Carrier → Prop}
    (hP : InvariantDetermined T P)
    (hQ : InvariantDetermined T Q) :
    InvariantDetermined T (fun x => P x ∨ Q x) := by
  grind +locals

/-
Invariant-determined predicates are closed under negation.
-/
theorem invariantDetermined_not
    {T : ResearchTheory} {P : T.Carrier → Prop}
    (hP : InvariantDetermined T P) :
    InvariantDetermined T (fun x => ¬P x) := by
  -- We’ll now express the general statement of closure under negation by introducing arbitrary $x,y$ and assuming the invariant condition, then derive the negated predicates are equivalent.
  intro x y hT
  exact not_congr (hP hT)

/-
Invariant-determined predicates are closed under implication.
-/
theorem invariantDetermined_imp
    {T : ResearchTheory} {P Q : T.Carrier → Prop}
    (hP : InvariantDetermined T P)
    (hQ : InvariantDetermined T Q) :
    InvariantDetermined T (fun x => P x → Q x) := by
  -- By definition of invariant-determined predicates.
  intro x y h

  -- We have P x ↔ P y and Q x ↔ Q y.
  have hpx : P x ↔ P y := by
    exact hP h;
  have hpy : Q x ↔ Q y := hQ h;
  tauto

/-
Invariant-determined predicates are closed under biconditional.
-/
theorem invariantDetermined_iff
    {T : ResearchTheory} {P Q : T.Carrier → Prop}
    (hP : InvariantDetermined T P)
    (hQ : InvariantDetermined T Q) :
    InvariantDetermined T (fun x => P x ↔ Q x) := by
  exact fun x y h => by simp +decide [ hP h, hQ h ] ;

/-! ## §9. Connecting to ComposableTransfer -/

/-- `TransferablePredicate` and `PreservesProperty` are definitionally equal.
    This bridges the new and old frameworks. -/
theorem transferablePredicate_eq_preservesProperty
    {T U : ResearchTheory} (f : TheoryHom T U)
    (P : T.Carrier → Prop) (Q : U.Carrier → Prop) :
    TransferablePredicate f P Q = PreservesProperty f P Q :=
  rfl

/-! ## §10. Cross-Domain Instantiation: Recovering Existing Theorems -/

/-- The `HasBoundedDepth` predicate from `TheoryMorphisms` is an instance
    of the universal upper-bound principle. -/
theorem hasBoundedDepth_iff_forall_upper
    (T : ResearchTheory) (n : ℕ) :
    HasBoundedDepth T n ↔ ∀ x, SatisfiesUpperBound T n x :=
  Iff.rfl

/-- The `bounded_depth_pullback` theorem from `TheoryMorphisms` is a corollary
    of the general `upper_bound_pullback`. -/
theorem bounded_depth_pullback_as_corollary
    {T U : ResearchTheory} (f : TheoryHom T U) (n : ℕ) :
    HasBoundedDepth U n → HasBoundedDepth T n :=
  upper_bound_pullback f n

/-- **Interval predicates are invariant-determined**: the predicate
    `lo ≤ T.Inv x ∧ T.Inv x ≤ hi` is invariant-determined. -/
theorem invariantDetermined_interval
    (T : ResearchTheory) (lo hi : ℕ) :
    InvariantDetermined T (fun x => lo ≤ T.Inv x ∧ T.Inv x ≤ hi) :=
  invariantDetermined_and
    (satisfiesLowerBound_invariantDetermined T lo)
    (satisfiesUpperBound_invariantDetermined T hi)

/-
**Exact value predicates are invariant-determined**: the predicate
    `T.Inv x = n` is invariant-determined.
-/
theorem invariantDetermined_exact
    (T : ResearchTheory) (n : ℕ) :
    InvariantDetermined T (fun x => T.Inv x = n) := by
  exact fun x y h => by simp +decide [ h ] ;

/-- **Transferable lower bounds compose through pipelines**: lower bound
    certificates survive arbitrary chains of morphisms. -/
theorem lower_bound_transfer_chain
    {T U V : ResearchTheory}
    (f : TheoryHom T U) (g : TheoryHom U V) (n : ℕ) :
    TransferablePredicate (TheoryHom.comp f g)
      (SatisfiesLowerBoundPred T n) (SatisfiesLowerBoundPred V n) :=
  TransferablePredicate.comp f g
    (certified_lower_bound_transfer_via_predicates f n)
    (certified_lower_bound_transfer_via_predicates g n)

/-- **Existential lower bound transfer through pipelines**. -/
theorem lower_bound_exists_chain
    {T U V : ResearchTheory}
    (f : TheoryHom T U) (g : TheoryHom U V) (n : ℕ) :
    SatisfiesLowerBound T n → SatisfiesLowerBound V n :=
  transferablePredicate_exists_comp f g
    (certified_lower_bound_transfer_via_predicates f n)
    (certified_lower_bound_transfer_via_predicates g n)

/-- **Concrete demonstration**: height theory lower bounds transfer to
    stability theory through the pipeline, using only predicate transport. -/
theorem height_to_stability_via_predicates (n : ℕ) :
    SatisfiesLowerBound HeightTheory n → SatisfiesLowerBound StabilityTheory n :=
  lower_bound_exists_chain heightToDimension dimensionToStability n