/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Temporal Adjunction: Core Theorems

This file proves the main theorems of the Temporal Adjunction framework:

## Main Results

* `diamond_left_adjoint` — ⟨a⟩ is left adjoint to (ext_a)^*
* `box_right_adjoint` — [a] is right adjoint to (ext_a)^*
* `diamond_compose` — Beck-Chevalley: ⟨b⟩∘⟨a⟩ = ⟨a,b⟩
* `box_compose` — Beck-Chevalley: [b]∘[a] = [a,b]
* `heytingImpl_temporal_unless` — Heyting implication = temporal unless
* `heytingNeg_eq_heytingImpl_bot` — Heyting negation is implication to ⊥
* `lts_deMorgan` — LTS box = ¬⟨a⟩¬ (De Morgan duality)
* `lts_diamond_conj_of_det` — Diamond distributes over ∧ for deterministic LTS
* `hm_diamond_eq_ltsDiamond` — HM formula diamond = LTS diamond
* `hm_box_eq_ltsBox` — HM formula box = LTS box
* `sieve_nonBoolean` — The sieve Heyting algebra is non-Boolean (cross-domain)

## Cross-Domain Connections

The non-Boolean nature of the sieve Heyting algebra connects process algebra
(temporal logic, bisimulation) to quantum foundations (non-distributive logic)
and sheaf cohomology (obstructions to classical reasoning).
-/

import Pythagorean.TemporalAdjunction.Defs

namespace TemporalAdjunction

open List

variable {Act : Type*}

/-! ## The Fundamental Adjunction Triple: ⟨a⟩ ⊣ (ext_a)^* ⊣ [a] -/

/-- **Temporal Adjunction Theorem (Left)**: The diamond modality ⟨a⟩ is left adjoint
    to the pullback (ext_a)^*. This is half of the fundamental adjunction triple
    ⟨a⟩ ⊣ (ext_a)^* ⊣ [a] in the presheaf topos PSh(Exp_Act).

    Concretely: `⟨a⟩P ⊆ Q ↔ P ⊆ (ext_a)^*Q`, which states that the diamond modality
    is the "cheapest" way to lift a trace property through the extension morphism. -/
theorem diamond_left_adjoint (a : Act) (P Q : TraceProp Act) :
    (∀ τ, diamond a P τ → Q τ) ↔ (∀ σ, P σ → pullbackExt a Q σ) := by
  constructor
  · intro h σ hp
    exact h (σ ++ [a]) ⟨σ, rfl, hp⟩
  · rintro h τ ⟨σ, rfl, hp⟩
    exact h σ hp

/-- **Temporal Adjunction Theorem (Right)**: The box modality [a] is right adjoint
    to the pullback (ext_a)^*. Combined with the left adjunction, this establishes
    the full adjunction triple ⟨a⟩ ⊣ (ext_a)^* ⊣ [a].

    Concretely: `(ext_a)^*P ⊆ Q ↔ P ⊆ [a]Q`, which states that the box modality
    is the "most generous" way to project a trace property through the extension. -/
theorem box_right_adjoint (a : Act) (P Q : TraceProp Act) :
    (∀ σ, pullbackExt a P σ → Q σ) ↔ (∀ τ, P τ → box a Q τ) := by
  constructor
  · intro h τ hp σ hτ
    subst hτ; exact h σ hp
  · intro h σ hp
    exact h (σ ++ [a]) hp σ rfl

/-- The diamond modality is monotone: if P ⊆ Q then ⟨a⟩P ⊆ ⟨a⟩Q. -/
theorem diamond_mono (a : Act) {P Q : TraceProp Act} (h : ∀ σ, P σ → Q σ) :
    ∀ τ, diamond a P τ → diamond a Q τ := by
  rintro τ ⟨σ, rfl, hp⟩
  exact ⟨σ, rfl, h σ hp⟩

/-- The box modality is monotone: if P ⊆ Q then [a]P ⊆ [a]Q. -/
theorem box_mono (a : Act) {P Q : TraceProp Act} (h : ∀ σ, P σ → Q σ) :
    ∀ τ, box a P τ → box a Q τ := by
  intro τ hbox σ hτ
  exact h σ (hbox σ hτ)

/-- The unit of the diamond adjunction: P ⊆ (ext_a)^*(⟨a⟩P). -/
theorem diamond_unit (a : Act) (P : TraceProp Act) :
    ∀ σ, P σ → pullbackExt a (diamond a P) σ := by
  intro σ hp
  exact ⟨σ, rfl, hp⟩

/-- The counit of the diamond adjunction: ⟨a⟩((ext_a)^*Q) ⊆ Q. -/
theorem diamond_counit (a : Act) (Q : TraceProp Act) :
    ∀ τ, diamond a (pullbackExt a Q) τ → Q τ := by
  rintro τ ⟨σ, rfl, hq⟩
  exact hq

/-- The pullback preserves conjunction. -/
theorem pullback_conj (a : Act) (P Q : TraceProp Act) :
    ∀ σ, pullbackExt a (TraceProp.conj P Q) σ ↔
      TraceProp.conj (pullbackExt a P) (pullbackExt a Q) σ := by
  intro σ; exact Iff.rfl

/-! ## Beck-Chevalley: Composition of Modal Operators

The Beck-Chevalley condition ensures that composing modal operators
corresponds to the multi-step modality. This connects to sheaf cohomology:
the failure of Beck-Chevalley in more general settings gives rise to
cohomological obstructions. -/

/-- **Beck-Chevalley for Diamond**: `⟨b⟩(⟨a⟩P) = ⟨[a,b]⟩P`.
    Composing two single-step diamond modalities equals the two-step diamond.
    This is the functoriality of the left Kan extension, ensuring that the
    existential image commutes with composition of extension morphisms. -/
theorem diamond_compose (a b : Act) (P : TraceProp Act) :
    ∀ τ, diamond b (diamond a P) τ ↔ diamondMulti [a, b] P τ := by
  intro τ
  simp only [diamond, diamondMulti]
  constructor
  · rintro ⟨σ₁, rfl, σ₀, rfl, hp⟩
    exact ⟨σ₀, by simp [List.append_assoc], hp⟩
  · rintro ⟨σ₀, hτ, hp⟩
    refine ⟨σ₀ ++ [a], ?_, σ₀, rfl, hp⟩
    simp [List.append_assoc] at hτ ⊢; exact hτ

/-- **Beck-Chevalley for Box**: `[b]([a]P) = [[a,b]]P`.
    Composing two single-step box modalities equals the two-step box.
    This is the functoriality of the right Kan extension. -/
theorem box_compose (a b : Act) (P : TraceProp Act) :
    ∀ τ, box b (box a P) τ ↔ boxMulti [a, b] P τ := by
  intro τ
  simp only [box, boxMulti]
  constructor
  · intro h σ₀ hτ
    have h₁ := h (σ₀ ++ [a]) (by simp [List.append_assoc] at hτ ⊢; exact hτ)
    exact h₁ σ₀ rfl
  · intro h σ₁ hτ₁ σ₀ hτ₀
    apply h σ₀
    subst hτ₀; simp [List.append_assoc] at hτ₁ ⊢; exact hτ₁

/-! ## Heyting Algebra: Temporal Unless

The Heyting implication in the subobject classifier of the presheaf topos
recovers the temporal "unless" operator from process algebra. -/

/-- The Heyting negation is Heyting implication to the empty predicate (⊥). -/
theorem heytingNeg_eq_heytingImpl_bot (P : TraceProp Act) :
    ∀ σ, heytingNeg P σ ↔ heytingImpl P (fun _ => False) σ := by
  intro σ; simp [heytingNeg, heytingImpl]

/-- **Heyting Implication = Temporal Unless (Characterization Theorem).**
    The Heyting implication `heytingImpl P Q` at trace σ holds iff
    for all future extensions τ of σ, P(τ) implies Q(τ).
    This is the temporal "unless" operator: Q holds unless P fails,
    at all future points.

    This theorem establishes that the internal logic of the presheaf topos
    naturally produces the temporal unless connective, providing a
    topos-theoretic foundation for temporal logic. -/
theorem heytingImpl_temporal_unless (P Q : TraceProp Act) (σ : List Act) :
    heytingImpl P Q σ ↔ ∀ τ, σ <+: τ → P τ → Q τ := by
  exact Iff.rfl

/-- The Heyting implication is upward-closed (a sieve property). -/
theorem heytingImpl_upward_closed {P Q : TraceProp Act}
    (_hQ : IsUpwardClosed Q) :
    IsUpwardClosed (heytingImpl P Q) := by
  intro σ τ hσ hpre ρ hτρ hPρ
  exact hσ ρ (List.IsPrefix.trans hpre hτρ) hPρ

/-- The Heyting implication satisfies the adjunction: for upward-closed predicates,
    `R ∧ P ⊆ Q ↔ R ⊆ (P ⇒ Q)` when restricted to extensions of a base trace. -/
theorem heytingImpl_adjunction (P Q R : TraceProp Act) (base : List Act)
    (hR_uc : IsUpwardClosed R) :
    (∀ τ, base <+: τ → R τ → P τ → Q τ) ↔
    (∀ τ, base <+: τ → R τ → heytingImpl P Q τ) := by
  constructor
  · intro h τ hbase hR ρ hτρ hPρ
    exact h ρ (List.IsPrefix.trans hbase hτρ) (hR_uc τ ρ hR hτρ) hPρ
  · intro h τ hbase hR hP
    exact h τ hbase hR τ (List.prefix_rfl) hP

/-! ## LTS Modalities: De Morgan Duality and Distribution -/

/-- **De Morgan Duality**: The box modality is the De Morgan dual of the diamond.
    `[a]P = ¬⟨a⟩¬P`: all a-successors satisfy P iff it's not the case that
    some a-successor fails P.

    This duality is a fundamental principle connecting modal logic to
    classical logic, and its failure in the intuitionistic (Heyting) setting
    is precisely what makes temporal logic non-classical. -/
theorem lts_deMorgan (L : LTS Act) (a : Act) (P : Set L.State) :
    ltsBox L a P = (ltsDiamond L a Pᶜ)ᶜ := by
  ext s
  simp only [ltsBox, ltsDiamond, Set.mem_setOf_eq, Set.mem_compl_iff]
  constructor
  · intro h ⟨s', hs, hns⟩
    exact hns (h s' hs)
  · intro h s' hs
    by_contra hns
    exact h ⟨s', hs, hns⟩

/-- The diamond modality distributes over disjunction (union). -/
theorem lts_diamond_union (L : LTS Act) (a : Act) (P Q : Set L.State) :
    ltsDiamond L a (P ∪ Q) = ltsDiamond L a P ∪ ltsDiamond L a Q := by
  ext s
  simp only [ltsDiamond, Set.mem_setOf_eq, Set.mem_union]
  constructor
  · rintro ⟨s', hs, h | h⟩
    · exact Or.inl ⟨s', hs, h⟩
    · exact Or.inr ⟨s', hs, h⟩
  · rintro (⟨s', hs, h⟩ | ⟨s', hs, h⟩)
    · exact ⟨s', hs, Or.inl h⟩
    · exact ⟨s', hs, Or.inr h⟩

/-- The box modality distributes over conjunction (intersection). -/
theorem lts_box_inter (L : LTS Act) (a : Act) (P Q : Set L.State) :
    ltsBox L a (P ∩ Q) = ltsBox L a P ∩ ltsBox L a Q := by
  ext s
  simp only [ltsBox, Set.mem_setOf_eq, Set.mem_inter_iff]
  constructor
  · intro h
    exact ⟨fun s' hs => (h s' hs).1, fun s' hs => (h s' hs).2⟩
  · intro ⟨h1, h2⟩ s' hs
    exact ⟨h1 s' hs, h2 s' hs⟩

/-- **Cross-Domain Theorem: Diamond distributes over conjunction for deterministic LTS.**
    In a deterministic LTS, `⟨a⟩(P ∩ Q) = ⟨a⟩P ∩ ⟨a⟩Q`.

    This connects process algebra (determinism of labeled transition systems) to
    quantum foundations: the failure of this distributive law in nondeterministic
    systems mirrors the failure of distributivity in quantum logic. In both cases,
    the underlying lattice of propositions is non-Boolean precisely because of
    "branching" — either nondeterministic choice (in process algebra) or
    superposition (in quantum mechanics). -/
theorem lts_diamond_conj_of_det (L : LTS Act) (a : Act)
    (hdet : ∀ s, DeterministicAt L s a)
    (P Q : Set L.State) :
    ltsDiamond L a (P ∩ Q) = ltsDiamond L a P ∩ ltsDiamond L a Q := by
  ext s
  simp only [ltsDiamond, Set.mem_setOf_eq, Set.mem_inter_iff]
  constructor
  · rintro ⟨s', hs, hp, hq⟩
    exact ⟨⟨s', hs, hp⟩, ⟨s', hs, hq⟩⟩
  · rintro ⟨⟨s₁, hs₁, hp⟩, ⟨s₂, hs₂, hq⟩⟩
    have heq := hdet s s₁ s₂ hs₁ hs₂
    subst heq
    exact ⟨s₁, hs₁, hp, hq⟩

/-- The converse: if diamond distributes over all conjunctions for action a at state s,
    then the LTS is deterministic at s for action a. -/
theorem det_of_diamond_conj (L : LTS Act) (a : Act) (s : L.State)
    (h_dist : ∀ P Q : Set L.State,
      s ∈ ltsDiamond L a P ∩ ltsDiamond L a Q →
      s ∈ ltsDiamond L a (P ∩ Q)) :
    DeterministicAt L s a := by
  intro s₁ s₂ hs₁ hs₂
  have hmem : s ∈ ltsDiamond L a ({s₁} ∩ {s₂}) := by
    apply h_dist
    exact ⟨⟨s₁, hs₁, rfl⟩, ⟨s₂, hs₂, rfl⟩⟩
  obtain ⟨s', _, hs'₁, hs'₂⟩ := hmem
  simp only [Set.mem_singleton_iff] at hs'₁ hs'₂
  rw [← hs'₁, ← hs'₂]

/-! ## Connection to HM Logic

These theorems bridge the trace-level modalities with the Hennessy-Milner
formula satisfaction from the YonedaBisimulation catalog. -/

/-- The HM formula diamond corresponds to the LTS diamond modality. -/
theorem hm_diamond_eq_ltsDiamond (L : LTS Act) (a : Act) (φ : HMFormula Act) :
    {s | HMSatisfies L s (HMFormula.diamond a φ)} =
    ltsDiamond L a {s | HMSatisfies L s φ} := by
  ext s
  simp only [HMSatisfies, ltsDiamond, Set.mem_setOf_eq]

/-- The HM formula box corresponds to the LTS box modality (via De Morgan). -/
theorem hm_box_eq_ltsBox (L : LTS Act) (a : Act) (φ : HMFormula Act) :
    {s | HMSatisfies L s (HMFormula.neg (HMFormula.diamond a (HMFormula.neg φ)))} =
    ltsBox L a {s | HMSatisfies L s φ} := by
  ext s
  simp only [HMSatisfies, ltsBox, Set.mem_setOf_eq]
  constructor
  · intro h s' hs
    by_contra hns
    exact h ⟨s', hs, hns⟩
  · intro h ⟨s', hs, hns⟩
    exact hns (h s' hs)

/-- **HM Soundness for Modalities**: HM-equivalent states agree on all
    diamond modalities. -/
theorem hm_equiv_preserves_diamond (L : LTS Act) {s₁ s₂ : L.State}
    (h : ∀ φ : HMFormula Act, HMSatisfies L s₁ φ ↔ HMSatisfies L s₂ φ) :
    ∀ a φ, s₁ ∈ ltsDiamond L a {s | HMSatisfies L s φ} ↔
           s₂ ∈ ltsDiamond L a {s | HMSatisfies L s φ} := by
  intro a φ
  exact h (HMFormula.diamond a φ)

/-! ## Non-Boolean Nature of the Sieve Algebra (Cross-Domain)

The Heyting algebra of sieves is non-Boolean in general, connecting
temporal logic to quantum logic and non-distributive lattice theory. -/

/-- The Heyting negation implies classical negation. -/
theorem heytingNeg_le_classical_neg (P : TraceProp Act) :
    ∀ σ, heytingNeg P σ → ¬ P σ := by
  intro σ h hp
  exact h σ List.prefix_rfl hp

/-- P implies not-Heyting-negation-of-P: the constructive content of
    the law of double negation. -/
theorem p_le_double_neg (P : TraceProp Act) :
    ∀ σ, P σ → ¬ heytingNeg P σ := by
  intro σ hp hneg
  exact hneg σ List.prefix_rfl hp

/-
**Non-Boolean Witness**: When the action set is nonempty, the Heyting
    algebra of upward-closed trace predicates is non-Boolean.

    Specifically, there exists an upward-closed predicate P such that
    ¬ₕ¬ₕP does not imply P. The witness is the predicate "the trace
    contains at least one occurrence of action a", which is upward-closed
    but whose double Heyting negation is strictly larger.

    This is the temporal logic analogue of the non-Boolean nature of
    quantum logic: just as quantum propositions fail the law of excluded
    middle due to superposition, temporal propositions fail it due to
    the branching structure of possible futures.
-/
theorem sieve_nonBoolean (a : Act) :
    ∃ P : TraceProp Act, IsUpwardClosed P ∧
      ¬ (∀ σ, (¬ heytingNeg P σ) → P σ) := by
  refine' ⟨ fun σ => a ∈ σ, _, _ ⟩;
  · intro σ τ hσ hτ;
    grind;
  · simp +decide [ heytingNeg ];
    exact ⟨ [ ], [ a ], by simp +decide ⟩

/-! ## Falsifiable Conjecture

The following conjecture states a relationship between the sieve cohomology
and the structural properties of LTS. It is stated as a concrete, testable
claim. -/

/-
**Conjecture (Finite Density Witness)**:
    For a finite deterministic LTS, every trace sieve property that is
    "dense" (double-negation closed) is already witnessed by a finite
    prefix of the trace tree.

    **Test**: For the two-action deterministic LTS with states {0,1,2}
    and transitions 0→ₐ1→ᵦ2, check that every dense upward-closed
    property on the 3-element trace tree {[], [a], [a,b]} is already
    a union of principal upward sets. If this fails for any 4-state LTS,
    the conjecture is falsified.

    This is stated as a theorem about a specific finite case
    to make it computationally verifiable.
-/
theorem finite_density_witness :
    let traces : List (List (Fin 2)) := [[], [0], [0, 1]]
    ∀ P : List (Fin 2) → Prop,
      (∀ σ τ, σ ∈ traces → τ ∈ traces → P σ → σ <+: τ → P τ) →
      (∀ σ, σ ∈ traces → (¬ ∀ τ, τ ∈ traces → σ <+: τ → ¬ P τ) → P σ) →
      ∀ σ, σ ∈ traces → P σ →
        ∃ ρ ∈ traces, ρ <+: σ ∧ ∀ τ, τ ∈ traces → ρ <+: τ → P τ := by
  grind

end TemporalAdjunction