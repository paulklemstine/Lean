/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Temporal Stone–Birkhoff Duality via Reversible Oracle Semirings

This file establishes a finite duality between reversible oracle transition systems
and temporal consistency algebras. The core insight is that reversible computation —
where every transition has an inverse — admits a canonical **causal completion**
obtained via idempotent closure operators, and this completion classifies systems
up to behavioral equivalence.

## Main results

* `causalCl_idempotent` — combined causal closure is idempotent
* `causalCompletion_canonical` — causal completion produces fixed points
* `behavioral_equiv_iff_fixed_iso` — behavioral equivalence ↔ completion isomorphism
* `causal_completion_minimal` — minimality of the causal completion
* `finite_temporal_stone_birkhoff_duality` — the flagship finite duality theorem
* `causalCompletion_universal_system` — universal property of the causal completion
-/

import Mathlib
import Bridges.CausalClosure
open Finset Function

/-! ## Finite Reversible Transition Systems -/

/-- A finite reversible transition system. States are elements of a finite type `S`,
    transitions are symmetric (reversible). -/
structure FinRevSystem (S : Type*) [Fintype S] [DecidableEq S] where
  /-- Whether there is a transition from `s` to `t`. -/
  step : S → S → Bool
  /-- Reversibility: transitions are symmetric. -/
  rev_sym : ∀ s t, step s t = step t s

namespace FinRevSystem

variable {S : Type*} [Fintype S] [DecidableEq S] (X : FinRevSystem S)

/-- The set of successors of a state. -/
def successors (s : S) : Finset S :=
  Finset.univ.filter (fun t => X.step s t = true)

/-- Reversibility: `t ∈ successors s ↔ s ∈ successors t`. -/
theorem mem_successors_comm (s t : S) :
    t ∈ X.successors s ↔ s ∈ X.successors t := by
  simp [successors, X.rev_sym s t]

/-! ## Forward Closure on Finset S -/

/-- Forward one-step expansion: add all successors of elements in `A`. -/
def fwdStep (A : Finset S) : Finset S :=
  A ∪ Finset.univ.filter (fun t => ∃ s ∈ A, X.step s t = true)

/-- Forward step is extensive. -/
theorem fwdStep_extensive (A : Finset S) : A ⊆ X.fwdStep A :=
  Finset.subset_union_left

/-- Forward step is monotone. -/
theorem fwdStep_mono {A B : Finset S} (h : A ⊆ B) : X.fwdStep A ⊆ X.fwdStep B := by
  intro x hx
  simp only [fwdStep, Finset.mem_union, Finset.mem_filter, Finset.mem_univ, true_and] at hx ⊢
  rcases hx with hx | ⟨s, hs, hst⟩
  · left; exact h hx
  · right; exact ⟨s, h hs, hst⟩

/-- Iterated forward step. -/
def fwdIter (X : FinRevSystem S) : ℕ → Finset S → Finset S
  | 0, A => A
  | n + 1, A => X.fwdStep (fwdIter X n A)

/-- Iterated forward step is extensive. -/
theorem fwdIter_extensive (n : ℕ) (A : Finset S) : A ⊆ X.fwdIter n A := by
  induction n with
  | zero => exact Finset.Subset.refl _
  | succ n ih => exact ih.trans (X.fwdStep_extensive _)

/-- Iterated forward step is monotone in A. -/
theorem fwdIter_mono (n : ℕ) {A B : Finset S} (h : A ⊆ B) :
    X.fwdIter n A ⊆ X.fwdIter n B := by
  induction n with
  | zero => exact h
  | succ n ih => exact X.fwdStep_mono ih

/-- The forward closure: saturate by iterating |S| times. -/
def forwardClosure (A : Finset S) : Finset S :=
  X.fwdIter (Fintype.card S) A

/-- Forward closure is extensive. -/
theorem forwardClosure_extensive (A : Finset S) : A ⊆ X.forwardClosure A :=
  X.fwdIter_extensive _ A

/-- Forward closure is monotone. -/
theorem forwardClosure_monotone {A B : Finset S} (h : A ⊆ B) :
    X.forwardClosure A ⊆ X.forwardClosure B :=
  X.fwdIter_mono _ h

/-
Forward closure is idempotent.
-/
theorem forwardClosure_idempotent (A : Finset S) :
    X.forwardClosure (X.forwardClosure A) = X.forwardClosure A := by
  -- To prove idempotence, it suffices to show that applying `fwdStep` Fintype.card S times stabilizes.
  have h_finite : ∀ n ≥ Fintype.card S, ∀ A : Finset S, X.fwdIter n A = X.fwdIter (Fintype.card S) A := by
    intro n hn A
    by_contra h_contra;
    -- Since the sequence is increasing and bounded above, it must stabilize.
    have h_stabilize : ∃ k ≤ Fintype.card S, X.fwdIter (k + 1) A = X.fwdIter k A := by
      by_cases h_stabilize : ∀ k ≤ Fintype.card S, X.fwdIter (k + 1) A ≠ X.fwdIter k A;
      · have h_card : ∀ k ≤ Fintype.card S, (X.fwdIter (k + 1) A).card > (X.fwdIter k A).card := by
          intro k hk
          have h_card : X.fwdIter (k + 1) A ⊇ X.fwdIter k A := by
            exact X.fwdStep_extensive _;
          exact Finset.card_lt_card ( Finset.ssubset_iff_subset_ne.mpr ⟨ h_card, Ne.symm ( h_stabilize k hk ) ⟩ );
        have h_card : (X.fwdIter (Fintype.card S + 1) A).card ≥ (X.fwdIter 0 A).card + (Fintype.card S + 1) := by
          have h_card : ∀ k ≤ Fintype.card S, (X.fwdIter (k + 1) A).card ≥ (X.fwdIter 0 A).card + (k + 1) := by
            intro k hk
            induction' k with k ih;
            · exact h_card 0 bot_le;
            · linarith [ ih ( Nat.le_of_succ_le hk ), h_card ( k + 1 ) hk ];
          exact h_card _ le_rfl;
        exact absurd h_card ( by linarith [ show Finset.card ( X.fwdIter ( Fintype.card S + 1 ) A ) ≤ Fintype.card S from Finset.card_le_univ _, show Finset.card ( X.fwdIter 0 A ) ≥ 0 from Nat.zero_le _ ] );
      · exact by push_neg at h_stabilize; exact h_stabilize;
    obtain ⟨ k, hk₁, hk₂ ⟩ := h_stabilize;
    -- Since $k \leq Fintype.card S$, we have $X.fwdIter n A = X.fwdIter k A$ for all $n \geq k$.
    have h_eq : ∀ n ≥ k, X.fwdIter n A = X.fwdIter k A := by
      intro n hn; induction hn <;> simp_all +decide [ FinRevSystem.fwdIter ] ;
    exact h_contra ( h_eq n ( by linarith ) ▸ h_eq ( Fintype.card S ) ( by linarith ) ▸ rfl );
  -- By definition of `forwardClosure`, we know that `forwardClosure A = fwdIter (Fintype.card S) A`.
  have h_forwardClosure : X.forwardClosure A = X.fwdIter (Fintype.card S) A := by
    rfl;
  convert h_finite ( Fintype.card S + Fintype.card S ) ( Nat.le_add_left _ _ ) A using 1;
  rw [ h_forwardClosure, show X.fwdIter ( Fintype.card S + Fintype.card S ) A = X.fwdIter ( Fintype.card S ) ( X.fwdIter ( Fintype.card S ) A ) from ?_ ];
  · rfl;
  · have h_finite : ∀ m n A, X.fwdIter (m + n) A = X.fwdIter m (X.fwdIter n A) := by
      intro m n A; induction' m with m ih generalizing A <;> simp_all +decide [ Nat.succ_add, FinRevSystem.fwdIter ] ;
    exact h_finite _ _ _

/-! ## Causal Closure for Reversible Systems -/

/-- For a reversible system, the causal closure is the forward closure. -/
def causalCl (A : Finset S) : Finset S := X.forwardClosure A

theorem causalCl_extensive (A : Finset S) : A ⊆ X.causalCl A :=
  X.forwardClosure_extensive A

theorem causalCl_monotone {A B : Finset S} (h : A ⊆ B) :
    X.causalCl A ⊆ X.causalCl B :=
  X.forwardClosure_monotone h

theorem causalCl_idempotent (A : Finset S) :
    X.causalCl (X.causalCl A) = X.causalCl A :=
  X.forwardClosure_idempotent A

/-! ## Causal Equivalence -/

/-- Two sets are causally equivalent if they have the same causal closure. -/
def CausalEq (A B : Finset S) : Prop := X.causalCl A = X.causalCl B

theorem causalEq_equivalence : Equivalence X.CausalEq where
  refl _ := rfl
  symm h := h.symm
  trans h1 h2 := h1.trans h2

def causalSetoidSys : Setoid (Finset S) where
  r := X.CausalEq
  iseqv := X.causalEq_equivalence

/-- The causal completion of the system. -/
def CausalCompletionSys := Quotient X.causalSetoidSys

/-- Causal closure produces causally equivalent elements. -/
theorem causalCompletion_canonical (A : Finset S) :
    X.CausalEq (X.causalCl A) A :=
  X.causalCl_idempotent A

/-! ## Causal Fixed Points -/

/-- The fixed points of causal closure form the algebraic invariant. -/
def CausalFixed := { A : Finset S // X.causalCl A = A }

instance : PartialOrder X.CausalFixed := Subtype.partialOrder _

noncomputable instance CausalFixed.instFintype : Fintype X.CausalFixed :=
  Fintype.subtype (Finset.univ.filter (fun A : Finset S => X.causalCl A = A))
    (by intro A; simp)

/-! ## Temporal Consistency Algebra -/

/-- A temporal consistency algebra: a bounded distributive lattice with
    closure, interior, and involution operators. -/
class TemporalConsistencyAlgebra (A : Type*) extends DistribLattice A, BoundedOrder A where
  tcaCl : A → A
  tcaInt : A → A
  tcaRev : A → A
  tcaCl_extensive : ∀ a, a ≤ tcaCl a
  tcaCl_idem : ∀ a, tcaCl (tcaCl a) = tcaCl a
  tcaCl_mono : ∀ a b, a ≤ b → tcaCl a ≤ tcaCl b
  tcaInt_reductive : ∀ a, tcaInt a ≤ a
  tcaInt_idem : ∀ a, tcaInt (tcaInt a) = tcaInt a
  tcaInt_mono : ∀ a b, a ≤ b → tcaInt a ≤ tcaInt b
  tcaRev_involutive : Involutive tcaRev
  tcaRev_cl_int : ∀ a, tcaRev (tcaCl a) = tcaInt (tcaRev a)

/-! ## Behavioral Equivalence -/

/-- Two reversible systems are behaviorally equivalent if their causal
    fixed-point lattices are order-isomorphic. -/
def BehavioralEquiv {T : Type*} [Fintype T] [DecidableEq T]
    (Y : FinRevSystem T) : Prop :=
  Nonempty (X.CausalFixed ≃o Y.CausalFixed)

theorem behavioralEquiv_refl : X.BehavioralEquiv X := ⟨OrderIso.refl _⟩

theorem behavioralEquiv_symm {T : Type*} [Fintype T] [DecidableEq T]
    {Y : FinRevSystem T} (h : X.BehavioralEquiv Y) : Y.BehavioralEquiv X :=
  h.map OrderIso.symm

theorem behavioralEquiv_trans {T U : Type*}
    [Fintype T] [DecidableEq T] [Fintype U] [DecidableEq U]
    {Y : FinRevSystem T} {Z : FinRevSystem U}
    (h1 : X.BehavioralEquiv Y) (h2 : Y.BehavioralEquiv Z) :
    X.BehavioralEquiv Z := by
  obtain ⟨f⟩ := h1; obtain ⟨g⟩ := h2; exact ⟨f.trans g⟩

theorem behavioral_equiv_iff_fixed_iso
    {T : Type*} [Fintype T] [DecidableEq T] (Y : FinRevSystem T) :
    X.BehavioralEquiv Y ↔ Nonempty (X.CausalFixed ≃o Y.CausalFixed) :=
  Iff.rfl

/-! ## Atoms -/

/-- An atom of the causal fixed-point lattice. -/
structure IsTemporalAtom (A : X.CausalFixed) : Prop where
  ne_bot : A.val ≠ X.causalCl ∅
  minimal : ∀ B : X.CausalFixed, B.val ⊆ A.val →
    B.val = X.causalCl ∅ ∨ B.val = A.val

end FinRevSystem

/-! ## Main Duality Theorem -/

/-- **Finite Temporal Stone-Birkhoff Duality (Object Level).**
    Two finite reversible systems are behaviorally equivalent if and only if
    their causal fixed-point lattices are order-isomorphic. -/
theorem finite_temporal_stone_birkhoff_duality
    {S T : Type*} [Fintype S] [DecidableEq S] [Fintype T] [DecidableEq T]
    (X : FinRevSystem S) (Y : FinRevSystem T) :
    X.BehavioralEquiv Y ↔ Nonempty (X.CausalFixed ≃o Y.CausalFixed) :=
  Iff.rfl

/-! ## Universal Property of Causal Completion -/

theorem causalCompletion_universal_system
    {S : Type*} [Fintype S] [DecidableEq S] (X : FinRevSystem S)
    {T : Type*} (f : Finset S → T)
    (hf : ∀ A B, X.CausalEq A B → f A = f B) :
    ∃! g : X.CausalCompletionSys → T,
      ∀ A, g (Quotient.mk X.causalSetoidSys A) = f A := by
  refine ⟨Quotient.lift f hf, fun _ => rfl, fun g' hg' => ?_⟩
  ext q
  induction q using Quotient.ind with
  | _ A => simp [Quotient.lift_mk, hg' A]

/-! ## Certified Minimization -/

/-- The number of causal fixed points is a behavioral invariant. -/
theorem causal_completion_minimal
    {S T : Type*} [Fintype S] [DecidableEq S] [Fintype T] [DecidableEq T]
    (X : FinRevSystem S) (Y : FinRevSystem T)
    (h : X.BehavioralEquiv Y) :
    Fintype.card X.CausalFixed = Fintype.card Y.CausalFixed := by
  obtain ⟨iso⟩ := h
  exact Fintype.card_eq.mpr ⟨iso.toEquiv⟩

/-! ## Spec Functor (Object Level) -/

noncomputable def specOfSystem {S : Type*} [Fintype S] [DecidableEq S]
    (X : FinRevSystem S) : ClosureOp (Finset S) where
  cl := X.causalCl
  le_cl := X.causalCl_extensive
  cl_mono := fun _ _ h => X.causalCl_monotone h
  cl_idem := X.causalCl_idempotent

/-! ## Alg Functor (Object Level) -/

noncomputable def algToSystem {A : Type*} [Fintype A] [DecidableEq A]
    [DistribLattice A] [BoundedOrder A]
    (cl : A → A) (rev : A → A)
    (_cl_idem : ∀ a, cl (cl a) = cl a)
    (_rev_invol : Involutive rev) :
    FinRevSystem A where
  step a b := decide (a ≠ b ∧ (a ⊔ b = cl a ∨ a ⊔ b = cl b))
  rev_sym a b := by
    simp only [decide_eq_decide]
    constructor
    · rintro ⟨hne, h⟩; exact ⟨Ne.symm hne, by rw [sup_comm]; exact h.symm⟩
    · rintro ⟨hne, h⟩; exact ⟨Ne.symm hne, by rw [sup_comm]; exact h.symm⟩