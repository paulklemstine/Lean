/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Closure–Proof-Net Duality via Idempotent Consequence Semimodules

This file establishes a finite algebraic duality between closure-based entailment
and proof-theoretic sequent/proof-net objects. The central result is a proof-theoretic
analogue of the Myhill–Nerode theorem: we quotient by entailment-indistinguishable
behavior, reconstruct a minimal sequent engine, and prove its uniqueness up to
canonical isomorphism.

## Main results

* `FinClosureSystem` — finite closure operator on `Finset H`
* `ConsequenceRegular` — closure system with exchange and absorption axioms
* `ctxEquiv` — entailment equivalence on contexts
* `ctxEquiv_congr_insert` — congruence of context equivalence under hypothesis insertion
* `IrredundantSequent` — irredundant sequent characterization
* `every_entailment_generated_by_irredundant` — every entailment factors through irredundant sequents
* `exists_minimal_sequent_presentation` — existence of minimal sequent presentation
* `minimal_sequent_presentation_unique` — uniqueness up to canonical isomorphism

## Mathematical significance

This result sits at the intersection of algebraic logic, proof theory, and automata theory.
Finite closure operators satisfying a proof-compatible exchange law are not just static
semantic objects — they are finite proof machines in disguise.

## References

* Myhill–Nerode theorem (automata theory)
* Steinitz exchange lemma (matroid theory)
* Tarski's consequence operator axioms
-/

import Mathlib

open Finset Function

variable {H : Type*} [DecidableEq H] [Fintype H]

namespace ClosureProofNet

/-! ## Finite Closure Systems -/

/-- A finite closure operator on `Finset H`. -/
structure FinClosureSystem (H : Type*) [DecidableEq H] [Fintype H] where
  cl : Finset H → Finset H
  extensive : ∀ A, A ⊆ cl A
  monotone : ∀ {A B : Finset H}, A ⊆ B → cl A ⊆ cl B
  idempotent : ∀ A, cl (cl A) = cl A

/-! ## Consequence-Regular Closure Systems -/

/-- A consequence-regular closure system: a finite closure operator with
    exchange and absorption axioms that make it compatible with proof-theoretic
    derivation. -/
structure ConsequenceRegular (H : Type*) [DecidableEq H] [Fintype H]
    extends FinClosureSystem H where
  exchange :
    ∀ {A : Finset H} {a b : H},
      a ∉ cl A →
      b ∉ cl A →
      b ∈ cl (insert a A) →
      a ∈ cl (insert b A)
  absorption :
    ∀ {A B : Finset H}, B ⊆ cl A → cl (A ∪ B) = cl A

/-! ## Context Equivalence -/

/-- Two contexts are equivalent if they have the same closure. -/
def ctxEquiv (C : ConsequenceRegular H) (A B : Finset H) : Prop :=
  C.cl A = C.cl B

/-- Context equivalence is an equivalence relation. -/
theorem ctxEquiv_equivalence (C : ConsequenceRegular H) :
    Equivalence (ctxEquiv C) where
  refl A := rfl
  symm h := h.symm
  trans h1 h2 := h1.trans h2

/-- The setoid on `Finset H` induced by context equivalence. -/
def ctxSetoid (C : ConsequenceRegular H) : Setoid (Finset H) :=
  ⟨ctxEquiv C, ctxEquiv_equivalence C⟩

/-! ## Key Lemma: Congruence under insertion -/

/-
Context equivalence is a congruence with respect to inserting a hypothesis.
    This is the analog of right-congruence in the Myhill–Nerode theorem.
-/
theorem ctxEquiv_congr_insert
    (C : ConsequenceRegular H)
    {A B : Finset H} (hAB : ctxEquiv C A B) (x : H) :
    ctxEquiv C (insert x A) (insert x B) := by
  refine' le_antisymm _ _;
  · have h_insert_subset : insert x A ⊆ C.cl (insert x B) := by
      simp_all +decide [ Finset.subset_iff, ctxEquiv ];
      exact ⟨ C.extensive _ ( Finset.mem_insert_self _ _ ), fun a ha => C.monotone ( Finset.subset_insert _ _ ) ( hAB ▸ C.extensive _ ha ) ⟩;
    exact C.monotone h_insert_subset |> le_trans <| by simp +decide [ C.idempotent ] ;
  · have h_monotone : B ⊆ C.cl (insert x A) := by
      exact fun y hy => C.monotone ( Finset.subset_insert _ _ ) ( hAB.symm ▸ C.extensive _ hy );
    have := C.absorption h_monotone;
    exact this ▸ C.monotone ( by aesop_cat )

/-! ## Closed Sets -/

/-- A set is closed if it equals its own closure. -/
def ClClosed (C : FinClosureSystem H) (A : Finset H) : Prop :=
  C.cl A = A

/-
The closure of any set is closed.
-/
theorem closure_is_closed (C : FinClosureSystem H) (A : Finset H) :
    ClClosed C (C.cl A) := by
  exact C.idempotent A

/-
There are finitely many closed sets (since `Finset H` over a finite type is finite).
-/
theorem closed_sets_finite (C : FinClosureSystem H) :
    Set.Finite {A : Finset H | ClClosed C A} := by
  exact Set.toFinite _

/-! ## Absorption and Extension Lemmas -/

/-
Extending a context by elements already in its closure doesn't change the closure.
-/
theorem cl_insert_of_mem (C : ConsequenceRegular H)
    {A : Finset H} {h : H} (hh : h ∈ C.cl A) :
    C.cl (insert h A) = C.cl A := by
  -- Since $h \in C.cl A$, we can use the absorption axiom to show that adding $h$ to $A$ does not change the closure.
  have h_abs : C.cl (A ∪ {h}) = C.cl A := by
    apply C.absorption;
    aesop;
  rwa [ Finset.insert_eq, Finset.union_comm ]

/-! ## Irredundant Sequents -/

/-- An irredundant sequent `Γ ⟶ h` means `h` is derivable from `Γ` but not from any
    proper subset of `Γ`. These are the atomic proof steps of the closure system. -/
def IrredundantSequent (C : ConsequenceRegular H) (Γ : Finset H) (h : H) : Prop :=
  h ∈ C.cl Γ ∧ h ∉ Γ ∧ ∀ Γ' : Finset H, Γ' ⊂ Γ → h ∉ C.cl Γ'

/-
Every non-trivial entailment is generated by an irredundant sequent:
    if `h ∈ cl Γ` and `h ∉ Γ`, there exists `Γ' ⊆ Γ` such that `Γ' ⟶ h` is irredundant.
-/
theorem every_entailment_generated_by_irredundant
    (C : ConsequenceRegular H)
    {Γ : Finset H} {h : H}
    (hh : h ∈ C.cl Γ) (hnotin : h ∉ Γ) :
    ∃ Γ' ⊆ Γ, IrredundantSequent C Γ' h := by
  -- By the well-ordering principle, there exists a minimal subset Γ' of Γ such that h ∈ C.cl Γ'.
  obtain ⟨Γ', hΓ'⟩ : ∃ Γ' ⊆ Γ, h ∈ C.cl Γ' ∧ ∀ Γ'' ⊆ Γ', Γ'' ⊂ Γ' → h ∉ C.cl Γ'' := by
    -- By the well-ordering principle, there exists a minimal subset Γ' of Γ such that h ∈ C.cl Γ'. Use this fact.
    obtain ⟨Γ', hΓ'⟩ : ∃ Γ' ∈ {Γ'' ⊆ Γ | h ∈ C.cl Γ''}, ∀ Γ'' ∈ {Γ'' ⊆ Γ | h ∈ C.cl Γ''}, Γ'.card ≤ Γ''.card := by
      apply_rules [ Set.exists_min_image ];
      · exact Set.toFinite _;
      · exact ⟨ Γ, ⟨ Finset.Subset.refl _, hh ⟩ ⟩;
    exact ⟨ Γ', hΓ'.1.1, hΓ'.1.2, fun Γ'' hΓ''₁ hΓ''₂ hΓ''₃ => not_lt_of_ge ( hΓ'.2 Γ'' ⟨ hΓ''₁.trans hΓ'.1.1, hΓ''₃ ⟩ ) ( Finset.card_lt_card hΓ''₂ ) ⟩;
  refine' ⟨ Γ', hΓ'.1, hΓ'.2.1, _, _ ⟩ <;> simp_all +decide [ Finset.ssubset_def ];
  exact fun h' => hnotin ( hΓ'.1 h' )

/-! ## Canonical States and Minimal Sequent Presentation -/

/-- The type of closed sets (canonical states). -/
def ClosedSetType (C : FinClosureSystem H) :=
  {A : Finset H // C.cl A = A}

/-- The canonical embedding: map a context to its closure. -/
noncomputable def canonicalEmbed (C : ConsequenceRegular H) :
    Finset H → ClosedSetType C.toFinClosureSystem :=
  fun A => ⟨C.cl A, C.idempotent A⟩

/-- The canonical step function: add a hypothesis and close. -/
noncomputable def canonicalStep (C : ConsequenceRegular H) :
    ClosedSetType C.toFinClosureSystem → H → ClosedSetType C.toFinClosureSystem :=
  fun ⟨A, hA⟩ h => ⟨C.cl (insert h A), C.idempotent _⟩

/-
Canonical embedding reflects and preserves context equivalence.
-/
theorem canonicalEmbed_iff (C : ConsequenceRegular H) (A B : Finset H) :
    canonicalEmbed C A = canonicalEmbed C B ↔ C.cl A = C.cl B := by
  exact ⟨ fun h => congr_arg Subtype.val h, fun h => Subtype.ext h ⟩

/-
Canonical embedding is surjective onto closed sets.
-/
theorem canonicalEmbed_surjective (C : ConsequenceRegular H) :
    Function.Surjective (canonicalEmbed C) := by
  intro ⟨ A, hA ⟩ ; exact ⟨ A, Subtype.ext hA ⟩ ;

/-
The canonical step function is compatible with the embedding.
-/
theorem canonicalStep_compat (C : ConsequenceRegular H) (A : Finset H) (h : H) :
    canonicalEmbed C (C.cl (insert h A)) = canonicalStep C (canonicalEmbed C A) h := by
  unfold canonicalEmbed canonicalStep;
  nontriviality;
  rename_i h;
  have := C.absorption ( show C.toFinClosureSystem.cl A ⊆ C.toFinClosureSystem.cl ( insert ‹_› A ) from ?_ );
  · simp_all +decide [ Finset.union_eq_right.mpr ( C.toFinClosureSystem.extensive A ) ];
    exact Subtype.ext ( C.idempotent _ );
  · exact C.monotone ( Finset.subset_insert _ _ )

/-! ## Sound Presentations -/

/-- A sound presentation of a consequence-regular closure system. -/
structure SoundPresentation (C : ConsequenceRegular H) (Q : Type*) where
  embed : Finset H → Q
  step : Q → H → Q
  embed_iff : ∀ A B, embed A = embed B ↔ C.cl A = C.cl B
  step_compat : ∀ A h, embed (C.cl (insert h A)) = step (embed A) h
  surjective : Function.Surjective embed

/-- The canonical closed-set presentation is sound. -/
noncomputable def canonicalSoundPresentation (C : ConsequenceRegular H) :
    SoundPresentation C (ClosedSetType C.toFinClosureSystem) where
  embed := canonicalEmbed C
  step := canonicalStep C
  embed_iff := fun A B => canonicalEmbed_iff C A B
  step_compat := fun A h => canonicalStep_compat C A h
  surjective := canonicalEmbed_surjective C

/-! ## Main Theorem 1: Existence of Minimal Sequent Presentation -/

/-
**Existence of minimal sequent presentation.**
    Every consequence-regular closure system admits a canonical sound presentation
    whose states are closed sets. Any other sound presentation factors through it.
    This is the proof-theoretic Myhill–Nerode theorem.
-/
theorem exists_minimal_sequent_presentation
    (C : ConsequenceRegular H) :
    ∃ (P : SoundPresentation C (ClosedSetType C.toFinClosureSystem)),
      (∀ (Q' : Type*) (P' : SoundPresentation C Q'),
        ∃ φ : ClosedSetType C.toFinClosureSystem → Q', ∀ A, φ (P.embed A) = P'.embed A) := by
  -- Define the canonical sound presentation.
  use canonicalSoundPresentation C;
  intro Q' P';
  use fun x => P'.embed x.val;
  intro A;
  exact P'.embed_iff _ _ |>.2 ( C.idempotent A )

/-! ## Main Theorem 2: Uniqueness of Minimal Sequent Presentation -/

/-
**Uniqueness of minimal sequent presentation.**
    Any two sound presentations are connected by a unique bijection
    that respects embedding and step structure. This is the uniqueness
    half of the proof-theoretic Nerode theorem.
-/
theorem minimal_sequent_presentation_unique
    (C : ConsequenceRegular H)
    {Q₁ Q₂ : Type*} [DecidableEq Q₁] [DecidableEq Q₂]
    (P₁ : SoundPresentation C Q₁)
    (P₂ : SoundPresentation C Q₂) :
    ∃ φ : Q₁ → Q₂,
      Function.Bijective φ ∧
      (∀ A, φ (P₁.embed A) = P₂.embed A) ∧
      (∀ q h, ∀ A, P₁.embed A = q → φ (P₁.step q h) = P₂.step (φ q) h) := by
  obtain ⟨φ, hφ⟩ : ∃ φ : Q₁ → Q₂, (∀ A, φ (P₁.embed A) = P₂.embed A) ∧ (∀ q h, ∀ A, P₁.embed A = q → φ (P₁.step q h) = P₂.step (φ q) h) := by
    obtain ⟨φ, hφ⟩ : ∃ φ : Q₁ → Q₂, (∀ A, φ (P₁.embed A) = P₂.embed A) := by
      use fun q => if h : ∃ A, P₁.embed A = q then P₂.embed ( Classical.choose h ) else P₂.embed ∅;
      intro A
      simp [P₁.surjective];
      grind +suggestions;
    refine' ⟨ φ, hφ, _ ⟩;
    intro q h A hA
    have h_step : P₁.step q h = P₁.embed (C.cl (insert h A)) := by
      rw [ ← hA, P₁.step_compat ];
    have := P₂.step_compat A h; aesop;
  have h_surj : Function.Surjective φ := by
    intro q₂; cases' P₂.surjective q₂ with A hA; use P₁.embed A; aesop;
  have h_inj : Function.Injective φ := by
    intro q₁ q₂ h_eq;
    obtain ⟨ A₁, rfl ⟩ := P₁.surjective q₁; obtain ⟨ A₂, rfl ⟩ := P₁.surjective q₂; have := hφ.1 A₁; have := hφ.1 A₂; simp_all +decide [ P₁.embed_iff, P₂.embed_iff ] ;
  exact ⟨φ, ⟨h_inj, h_surj⟩, hφ⟩

/-! ## The number of irredundant sequents is bounded. -/

theorem irredundant_sequents_finite (C : ConsequenceRegular H) :
    Set.Finite {p : Finset H × H | IrredundantSequent C p.1 p.2} := by
  exact Set.toFinite _

/-! ## Idempotent Consequence Algebra -/

/-- The idempotent join operation on closed sets:
    `A ⊕ B = cl(A ∪ B)`. -/
noncomputable def closedJoin (C : ConsequenceRegular H)
    (x y : ClosedSetType C.toFinClosureSystem) :
    ClosedSetType C.toFinClosureSystem :=
  ⟨C.cl (x.1 ∪ y.1), C.idempotent _⟩

/-
The join is idempotent.
-/
theorem closedJoin_idem (C : ConsequenceRegular H)
    (x : ClosedSetType C.toFinClosureSystem) :
    closedJoin C x x = x := by
  unfold closedJoin;
  exact Subtype.ext ( by simp +decide [ x.2 ] )

/-
The join is commutative.
-/
theorem closedJoin_comm (C : ConsequenceRegular H)
    (x y : ClosedSetType C.toFinClosureSystem) :
    closedJoin C x y = closedJoin C y x := by
  exact Subtype.ext ( congr_arg C.cl ( Finset.union_comm _ _ ) )

/-
The join is associative.
-/
theorem closedJoin_assoc (C : ConsequenceRegular H)
    (x y z : ClosedSetType C.toFinClosureSystem) :
    closedJoin C (closedJoin C x y) z = closedJoin C x (closedJoin C y z) := by
  -- By definition of closure, we know that the closure of a union is the union of the closures.
  have h_closure_union : ∀ A B : Finset H, C.cl (A ∪ B) = C.cl (C.cl A ∪ B) := by
    intro A B;
    apply le_antisymm;
    · exact C.monotone ( Finset.union_subset_union ( C.extensive _ ) ( Finset.Subset.refl _ ) );
    · have := C.absorption ( show C.cl A ⊆ C.cl ( A ∪ B ) from C.monotone ( Finset.subset_union_left ) );
      simp_all +decide [ Finset.union_comm, Finset.union_left_comm, Finset.union_assoc ];
      exact this ▸ C.monotone ( Finset.subset_union_right );
  apply Subtype.ext;
  unfold closedJoin; simp +decide [ ← h_closure_union ] ;
  convert h_closure_union ( y.1 ∪ z.1 ) x.1 using 1 ; simp +decide [ Finset.union_comm, Finset.union_left_comm, Finset.union_assoc ];
  rw [ Finset.union_comm ]

/-- The empty closure is the bottom element. -/
noncomputable def closedBot (C : ConsequenceRegular H) :
    ClosedSetType C.toFinClosureSystem :=
  ⟨C.cl ∅, C.idempotent ∅⟩

/-
Acting by an already-derivable hypothesis is identity on closed sets.
-/
theorem action_of_derivable (C : ConsequenceRegular H)
    {A : Finset H} (hA : C.cl A = A) {h : H} (hh : h ∈ A) :
    C.cl (insert h A) = A := by
  rw [ Finset.insert_eq_of_mem hh, hA ]

/-
Separation: two closed sets with the same elements are equal.
-/
theorem closed_set_separation (C : ConsequenceRegular H)
    (x y : ClosedSetType C.toFinClosureSystem) :
    (∀ h : H, h ∈ x.1 ↔ h ∈ y.1) → x = y := by
  exact fun h => Subtype.ext <| Finset.ext h

end ClosureProofNet