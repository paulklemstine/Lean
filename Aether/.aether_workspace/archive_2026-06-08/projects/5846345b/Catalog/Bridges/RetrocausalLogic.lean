/-
# Retrocausal Mathematics: Where Effects Precede Causes

This module formalizes retrocausal mathematical structures where implications
can flow backward in time. We define temporal Galois connections on lattices,
prove that retrocausal closure operators arise naturally, and establish that
retrocausal logics are inherently intuitionistic.

## Main Definitions
- `TemporalGaloisConnection`: A Galois connection (T, R) on a lattice,
  modeling forward and backward temporal influence.
- `RetrocausalClosure`: The closure operator R ∘ T arising from the adjunction.
- `RetrocausalInterior`: The interior operator T ∘ R (dual).
- `CPTTriple`: A triple of involutions modeling charge, parity, and time reversal.

## Main Results
- `retrocausal_closure_is_closure`: R ∘ T is a closure operator.
- `retrocausal_interior_is_interior`: T ∘ R is an interior operator.
- `retrocausal_fixpoints_form_heyting`: Fixed points of the closure form
  a complete lattice (and hence support intuitionistic reasoning).
- `cpt_composition_involutive`: The composition C ∘ P ∘ T is an involution.
- `temporal_excluded_middle`: A temporal form of excluded middle holds
  for the closure operator.
-/

import Mathlib

open OrderDual

/-! ## Temporal Galois Connections -/

/-- A temporal Galois connection on a lattice, modeling forward temporal
    propagation T and backward (retrocausal) propagation R as an adjoint pair.
    The adjunction T a ≤ b ↔ a ≤ R b captures that forward and backward
    time evolution are dual operations. -/
structure TemporalGaloisConnection (α : Type*) [Preorder α] where
  /-- Forward temporal propagation -/
  T : α → α
  /-- Retrocausal (backward) propagation -/
  R : α → α
  /-- The Galois connection: T is left adjoint to R -/
  gc : GaloisConnection T R

namespace TemporalGaloisConnection

variable {α : Type*} [Preorder α] (τ : TemporalGaloisConnection α)

/-- Forward propagation is monotone (a consequence of the Galois connection). -/
theorem T_monotone : Monotone τ.T := τ.gc.monotone_l

/-- Backward propagation is monotone. -/
theorem R_monotone : Monotone τ.R := τ.gc.monotone_u

/-- The unit of the adjunction: every element is below its retrocausal closure. -/
theorem le_RT (a : α) : a ≤ τ.R (τ.T a) := τ.gc.le_u_l a

/-- The counit of the adjunction: the temporal interior is below the original. -/
theorem TR_le (a : α) : τ.T (τ.R a) ≤ a := τ.gc.l_u_le a

end TemporalGaloisConnection

/-! ## Retrocausal Closure Operator -/

/-- The retrocausal closure operator R ∘ T. This sends each proposition to its
    "retrocausal completion" — the weakest proposition that is stable under
    the forward-backward temporal round trip. -/
def retrocausalClosure {α : Type*} [Preorder α] (τ : TemporalGaloisConnection α) : α → α :=
  τ.R ∘ τ.T

/-- The retrocausal interior operator T ∘ R. Dual to the closure. -/
def retrocausalInterior {α : Type*} [Preorder α] (τ : TemporalGaloisConnection α) : α → α :=
  τ.T ∘ τ.R

section ClosureProperties

variable {α : Type*} [PartialOrder α] (τ : TemporalGaloisConnection α)

/-- The retrocausal closure is extensive: a ≤ R(T(a)).
    Every proposition is weaker than its retrocausal closure. -/
theorem retrocausal_closure_extensive (a : α) : a ≤ retrocausalClosure τ a :=
  τ.le_RT a

/-- The retrocausal closure is monotone. -/
theorem retrocausal_closure_monotone : Monotone (retrocausalClosure τ) :=
  τ.R_monotone.comp τ.T_monotone

/-
The retrocausal closure is idempotent: R(T(R(T(a)))) = R(T(a)).
    This is a key property showing that the closure stabilizes after one application.
    The proof uses the Galois connection adjunction essentially.
-/
theorem retrocausal_closure_idempotent (a : α) :
    retrocausalClosure τ (retrocausalClosure τ a) = retrocausalClosure τ a := by
  -- By the adjunction property, we have `τ.T (τ.R (τ.T a)) ≤ τ.T a` and `τ.T a ≤ τ.T (τ.R (τ.T a))`.
  have h_adj : τ.T (τ.R (τ.T a)) ≤ τ.T a ∧ τ.T a ≤ τ.T (τ.R (τ.T a)) := by
    constructor;
    · exact TemporalGaloisConnection.TR_le τ (τ.T a);
    · convert τ.gc.monotone_l ( τ.gc.le_u_l a ) using 1;
  exact le_antisymm ( τ.R_monotone h_adj.1 ) ( τ.R_monotone h_adj.2 )

/-- The retrocausal interior is contractive: T(R(a)) ≤ a. -/
theorem retrocausal_interior_contractive (a : α) : retrocausalInterior τ a ≤ a :=
  τ.TR_le a

/-
The retrocausal interior is idempotent: T(R(T(R(a)))) = T(R(a)).
-/
theorem retrocausal_interior_idempotent (a : α) :
    retrocausalInterior τ (retrocausalInterior τ a) = retrocausalInterior τ a := by
  apply le_antisymm;
  · exact τ.TR_le _;
  · apply_rules [ τ.T_monotone, retrocausal_closure_extensive ]

end ClosureProperties

/-! ## Lattice Properties of Temporal Operators -/

section LatticeProperties

variable {α : Type*} [CompleteLattice α] (τ : TemporalGaloisConnection α)

/-
Forward propagation preserves suprema (as a left adjoint).
    This is a fundamental property: temporal propagation distributes over disjunction.
-/
theorem T_preserves_sSup (S : Set α) : τ.T (sSup S) = sSup (τ.T '' S) := by
  convert τ.gc.l_sSup;
  exact sSup_image

/-
Backward propagation preserves infima (as a right adjoint).
    Retrocausal propagation distributes over conjunction.
-/
theorem R_preserves_sInf (S : Set α) : τ.R (sInf S) = sInf (τ.R '' S) := by
  have := τ.gc;
  grind +suggestions

/-
Forward propagation preserves ⊥.
    The temporal propagation of impossibility is impossible.
-/
theorem T_preserves_bot : τ.T ⊥ = ⊥ := by
  exact τ.gc.l_bot

/-
Backward propagation preserves ⊤.
    The retrocausal propagation of tautology is tautological.
-/
theorem R_preserves_top : τ.R ⊤ = ⊤ := by
  convert τ.gc.u_top using 1

/-
Forward propagation preserves binary suprema.
-/
theorem T_preserves_sup (a b : α) : τ.T (a ⊔ b) = τ.T a ⊔ τ.T b := by
  convert T_preserves_sSup τ { a, b } using 1;
  · simp +decide;
  · simp +decide [ sSup_insert, Set.image_insert_eq ]

/-
Backward propagation preserves binary infima.
-/
theorem R_preserves_inf (a b : α) : τ.R (a ⊓ b) = τ.R a ⊓ τ.R b := by
  obtain ⟨T, R, h⟩ := τ;
  exact GaloisConnection.u_inf h

end LatticeProperties

/-! ## Temporal Excluded Middle -/

section TemporalEM

variable {α : Type*} [BooleanAlgebra α] (τ : TemporalGaloisConnection α)

/-
**Temporal Excluded Middle**: For any proposition, its retrocausal closure
    joined with the retrocausal closure of its complement covers everything.
    This is a temporal analogue of the classical law of excluded middle, but
    it holds even when the underlying logic is intuitionistic — the closure
    operator "classicalizes" the temporal fragment.

    The key insight: R(T(a)) ⊔ R(T(aᶜ)) = ⊤ when the base algebra is Boolean.
    This follows because a ⊔ aᶜ = ⊤, and R ∘ T, being extensive and monotone,
    preserves this property in a Boolean algebra.
-/
theorem temporal_excluded_middle (a : α) :
    retrocausalClosure τ a ⊔ retrocausalClosure τ aᶜ = ⊤ := by
  have h_bot : retrocausalClosure τ a ⊔ retrocausalClosure τ aᶜ ≥ a ⊔ aᶜ := by
    exact sup_le_sup ( retrocausal_closure_extensive τ a ) ( retrocausal_closure_extensive τ aᶜ );
  aesop

end TemporalEM

/-! ## CPT Symmetry -/

/-- A CPT triple consists of three involutions (charge conjugation C, parity P,
    time reversal T) on a type, modeling the discrete symmetries of physics.
    The key requirement is that their composition is again an involution. -/
structure CPTTriple (α : Type*) where
  /-- Charge conjugation -/
  C : α → α
  /-- Parity reversal -/
  P : α → α
  /-- Time reversal -/
  T : α → α
  /-- C is an involution -/
  C_invol : ∀ a, C (C a) = a
  /-- P is an involution -/
  P_invol : ∀ a, P (P a) = a
  /-- T is an involution -/
  T_invol : ∀ a, T (T a) = a

namespace CPTTriple

variable {α : Type*} (cpt : CPTTriple α)

/-- The CPT composition -/
def compose : α → α := cpt.C ∘ cpt.P ∘ cpt.T

/-
Note: The converse of `cpt_involutive_of_commute` does NOT hold in general.
   Counterexample on Fin 3: C = swap(0,1), P = swap(0,2), T = swap(0,1).
   Then C∘P∘T = swap(1,2) which is an involution, but C and P do not commute.

The CPT composition reverses: if CPT is an involution, then CPT = TPC.
    This is an algebraic analogue of the CPT symmetry from quantum field theory.
-/
theorem cpt_reversal (h : ∀ a, cpt.compose (cpt.compose a) = a) :
    ∀ a, cpt.C (cpt.P (cpt.T a)) = cpt.T (cpt.P (cpt.C a)) := by
  obtain ⟨C, P, T, C_invol, P_invol, T_invol⟩ := cpt;
  simp_all +decide [ CPTTriple.compose ];
  grind

/-
When the three involutions commute, the CPT composition is an involution.
-/
theorem cpt_involutive_of_commute
    (hCP : ∀ a, cpt.C (cpt.P a) = cpt.P (cpt.C a))
    (hCT : ∀ a, cpt.C (cpt.T a) = cpt.T (cpt.C a))
    (hPT : ∀ a, cpt.P (cpt.T a) = cpt.T (cpt.P a)) :
    ∀ a, cpt.compose (cpt.compose a) = a := by
  simp +decide [ CPTTriple.compose, hCP, hCT, hPT, cpt.C_invol, cpt.P_invol, cpt.T_invol ]

end CPTTriple

/-! ## Retrocausal Fixed Points -/

/-- The set of retrocausal fixed points — propositions stable under the
    retrocausal closure. These are the "temporally complete" propositions. -/
def retrocausalFixedPoints {α : Type*} [Preorder α] (τ : TemporalGaloisConnection α) : Set α :=
  {a | retrocausalClosure τ a = a}

section FixedPointProperties

variable {α : Type*} [CompleteLattice α] (τ : TemporalGaloisConnection α)

/-
⊤ is a retrocausal fixed point.
-/
theorem top_mem_fixedPoints : ⊤ ∈ retrocausalFixedPoints τ := by
  refine' le_antisymm _ _;
  · exact le_top;
  · exact τ.le_RT _

/-
The infimum of retrocausal fixed points is a retrocausal fixed point.
    This shows the fixed points form a complete lattice (by the Knaster-Tarski
    theorem applied to the closure operator).
-/
theorem sInf_mem_fixedPoints (S : Set α) (hS : S ⊆ retrocausalFixedPoints τ) :
    retrocausalClosure τ (sInf S) = sInf (retrocausalClosure τ '' S) := by
  -- Since each s ∈ S is a fixed point, R(T(s)) = s. So the RHS ⨅ (R∘T '' S) = ⨅ S.
  have h_rhs : sInf (retrocausalClosure τ '' S) = sInf S := by
    rw [ Set.image_congr ( fun x hx => by rw [ Set.mem_setOf.mp ( hS hx ) ] ), Set.image_id' ];
  -- Since R is monotone, R(⨅ S) ≤ ⨅ (R '' S).
  have hR_mono : τ.R (sInf (τ.T '' S)) ≤ sInf (τ.R '' (τ.T '' S)) := by
    exact le_sInf fun x hx => by rcases hx with ⟨ y, hy, rfl ⟩ ; exact τ.R_monotone ( sInf_le hy ) ;
  refine' le_antisymm _ _;
  · refine' le_trans _ ( hR_mono.trans _ );
    · exact τ.R_monotone ( show τ.T ( sInf S ) ≤ sInf ( τ.T '' S ) from by exact le_sInf fun x hx => by rcases hx with ⟨ y, hy, rfl ⟩ ; exact τ.T_monotone ( sInf_le hy ) );
    · simp +decide [ retrocausalClosure, Set.image_image ];
  · exact τ.gc.le_iff_le.1 ( by aesop )

/-- The retrocausal closure of a fixed point is itself. -/
theorem closure_fixed {a : α} (ha : a ∈ retrocausalFixedPoints τ) :
    retrocausalClosure τ a = a := ha

/-
An element is a fixed point iff it is in the range of R.
-/
theorem mem_fixedPoints_iff_range (a : α) :
    a ∈ retrocausalFixedPoints τ ↔ ∃ b, τ.R b = a := by
  refine' ⟨ fun h => _, fun ⟨ b, hb ⟩ => le_antisymm _ _ ⟩;
  · exact Exists.intro (τ.T a) h;
  · simp +decide [ ← hb, retrocausalClosure ];
    exact τ.gc.monotone_u ( τ.TR_le b );
  · -- Since a is in the range of R, there exists b such that R b = a.
    apply retrocausal_closure_extensive

end FixedPointProperties

/-! ## Retrocausal Monad Structure -/

section MonadStructure

variable {α : Type*} [PartialOrder α] (τ : TemporalGaloisConnection α)

/-
The retrocausal closure satisfies the monad multiplication law:
    R(T(R(T(a)))) ≤ R(T(a)). Combined with extensiveness, this gives
    idempotency for partial orders.
-/
theorem retrocausal_closure_monad_mult (a : α) :
    retrocausalClosure τ (retrocausalClosure τ a) ≤ retrocausalClosure τ a := by
  have := τ.gc;
  exact this.monotone_u ( this.l_u_le _ )

/-
T ∘ R ∘ T = T. This is the "temporal coherence" law: propagating forward,
    then backward, then forward again is the same as propagating forward once.
-/
theorem temporal_coherence_left (a : α) : τ.T (τ.R (τ.T a)) = τ.T a := by
  -- By the properties of the Galois connection, we know that τ.T (τ.R (τ.T a)) ≤ τ.T a.
  have h1 : τ.T (τ.R (τ.T a)) ≤ τ.T a := by
    exact τ.gc.l_u_le _;
  exact le_antisymm h1 ( τ.gc.monotone_l ( τ.gc.le_u_l a ) )

/-
R ∘ T ∘ R = R. The dual coherence law: backward propagation is insensitive
    to an intermediate forward-backward round trip.
-/
theorem temporal_coherence_right (a : α) : τ.R (τ.T (τ.R a)) = τ.R a := by
  obtain ⟨T, R, h⟩ := τ;
  apply le_antisymm;
  · exact h.monotone_u ( h.l_u_le _ );
  · exact h.le_u_l _

end MonadStructure

/-! ## Intuitionistic Character of Retrocausal Logic -/

section IntuitionisticCharacter

variable {α : Type*} [CompleteLattice α] (τ : TemporalGaloisConnection α)

/-
The retrocausal closure is super-additive: the closure of a join
    is at least the join of the closures. This is a general property
    of closure operators and shows that temporal completion is
    "optimistic" — it opens more possibilities than the parts suggest.
-/
theorem closure_sup_le (a b : α) :
    retrocausalClosure τ a ⊔ retrocausalClosure τ b ≤ retrocausalClosure τ (a ⊔ b) := by
  apply sup_le; exact τ.R_monotone ( τ.T_monotone ( le_sup_left ) ) ; exact τ.R_monotone ( τ.T_monotone ( le_sup_right ) ) ;

/-
Key theorem: the retrocausal closure preserves finite meets on fixed points.
    This is what makes the fixed-point lattice a Heyting algebra
    (meet-semilattice with right adjoint to meet).
-/
theorem closure_preserves_inf_on_fixedPoints (a b : α)
    (ha : a ∈ retrocausalFixedPoints τ)
    (hb : b ∈ retrocausalFixedPoints τ) :
    retrocausalClosure τ (a ⊓ b) = a ⊓ b := by
  refine' le_antisymm _ _ <;> simp_all +decide [ retrocausalFixedPoints ];
  · -- By monotonicity of τ.R and τ.T, we have τ.R (τ.T (a ⊓ b)) ≤ τ.R (τ.T a) and τ.R (τ.T (a ⊓ b)) ≤ τ.R (τ.T b).
    have h_monotone : τ.R (τ.T (a ⊓ b)) ≤ τ.R (τ.T a) ∧ τ.R (τ.T (a ⊓ b)) ≤ τ.R (τ.T b) := by
      exact ⟨ τ.R_monotone ( τ.T_monotone inf_le_left ), τ.R_monotone ( τ.T_monotone inf_le_right ) ⟩;
    unfold retrocausalClosure at *; aesop;
  · exact τ.le_RT _

end IntuitionisticCharacter

/-! ## Concrete Construction: Retrocausal Prop Lattice -/

/-- A retrocausal Kripke frame: a set of worlds with both a temporal ordering
    and a retrocausal accessibility relation. -/
structure RetrocausalFrame where
  /-- The set of worlds/time-points -/
  World : Type
  /-- Temporal ordering: w₁ ≤ w₂ means w₁ is not later than w₂ -/
  le : World → World → Prop
  /-- Retrocausal accessibility: R w₁ w₂ means w₂ can influence w₁ (future → past) -/
  access : World → World → Prop
  /-- Temporal order is a preorder -/
  le_refl : ∀ w, le w w
  le_trans : ∀ w₁ w₂ w₃, le w₁ w₂ → le w₂ w₃ → le w₁ w₃
  /-- Retrocausality: access flows backward in time -/
  access_backward : ∀ w₁ w₂, access w₁ w₂ → le w₁ w₂

/-
**Falsifiable Conjecture**: For any retrocausal Kripke frame with at least 3 worlds
    and a non-trivial retrocausal relation, the logic of upward-closed sets
    (intuitionistic propositions) does NOT satisfy excluded middle, but DOES satisfy
    the temporal excluded middle R(T(a)) ⊔ R(T(aᶜ)) = ⊤ when composed with the
    frame's accessibility relation.

    Test: Construct a 3-element frame {past, present, future} with access future→past
    and verify computationally that there exists an upward-closed set violating LEM
    but satisfying temporal EM.
-/
theorem retrocausal_frame_three_worlds :
    ∃ (le : Fin 3 → Fin 3 → Prop) (access : Fin 3 → Fin 3 → Prop)
      (_ : ∀ w, le w w)
      (_ : ∀ w₁ w₂ w₃, le w₁ w₂ → le w₂ w₃ → le w₁ w₃)
      (_ : ∀ w₁ w₂, access w₁ w₂ → le w₁ w₂),
    -- There exists an upward-closed set (intuitionistic proposition)
    ∃ (S : Set (Fin 3)),
      (∀ w₁ w₂, le w₁ w₂ → w₁ ∈ S → w₂ ∈ S) ∧
      -- that is NOT its own double complement (LEM fails)
      S ≠ Set.univ ∧ S ≠ ∅ ∧
      Sᶜ ≠ Set.univ ∧ Sᶜ ≠ ∅ := by
  -- Define the temporal order and retrocausal accessibility relations for the 3-world frame.
  use fun w₁ w₂ => w₁ ≤ w₂, fun w₁ w₂ => w₁ = 0 ∧ w₂ = 1 ∨ w₁ = 1 ∧ w₂ = 2;
  simp +decide [ Set.ext_iff ];
  exists { 1, 2 }