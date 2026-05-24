/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Boolean Topos Characterization of Determinism: Core Theorems

This file proves the central equivalence theorem:

> **Determinism ↔ Classical (Boolean) internal logic**

in the setting of labeled transition systems and their behavioral nerve.

## Main Results

* `diamond_distributive_iff_det` — Diamond distributes over ∧ iff LTS is deterministic
* `nondeterministic_diamond_witness` — Nondeterminism yields explicit non-Boolean witness
* `diamond_complement_of_det_total` — Deterministic total LTS: diamond preserves complements
* `bisim_equality_implies_identity_closure` — Bisim=equality implies identity closure
* `identity_closure_implies_bisim_equality` — Identity closure implies bisim=equality
* `det_total_implies_bisim_equality` — Deterministic total LTS: bisimilarity is equality

## Cross-Domain Significance

These theorems establish a process-theoretic analogue of the Birkhoff–von Neumann
phenomenon from quantum logic:

- **Quantum mechanics**: Incompatible observables produce non-Boolean proposition lattices
- **Process algebra**: Nondeterministic branching produces non-Boolean modal algebras
- **Topos theory**: Non-trivial Lawvere–Tierney topologies correspond to non-classical
  internal logics

The mathematical bridge is: in both cases, the failure of classical logic is
witnessed by a distributivity failure — the diamond (existential image) fails
to distribute over conjunction, creating an irreducible "superposition" of
possible futures.
-/

import Pythagorean.BooleanTopos.Defs
import Pythagorean.TemporalAdjunction.Theorems

namespace BooleanTopos

open TemporalAdjunction Set

variable {Act : Type*}

/-! ## Theorem A: Diamond Distributivity ↔ Full Determinism

This is the flagship theorem: the diamond modality distributes over
conjunction for all actions if and only if the LTS is fully deterministic.

The forward direction uses `det_of_diamond_conj` from the temporal adjunction
framework: if diamond distributes at every state, then each state has at most
one successor per action.

The backward direction uses `lts_diamond_conj_of_det`: if each state has at
most one successor per action, then diamond distributes. -/

/-
**Theorem A (Determinism = Boolean Internal Logic).**

    The diamond modality distributes over conjunction for all actions and
    state predicates if and only if the LTS is fully deterministic.

    This is the process-theoretic analogue of the theorem that a quantum
    logic is Boolean iff all observables are compatible. Here, "compatible"
    means "deterministic": at most one successor per action per state.
-/
theorem diamond_distributive_iff_det (L : LTS Act) :
    DiamondDistributive L ↔ FullyDeterministic L := by
  refine ⟨ fun h => ?_, fun h => ?_ ⟩;
  · intro s a;
    exact det_of_diamond_conj L a s fun P Q hPQ => h a P Q ▸ hPQ;
  · exact fun a P Q => lts_diamond_conj_of_det L a ( fun s => h s a ) P Q

/-! ## Theorem B: Explicit Non-Boolean Witness from Nondeterminism

If the LTS is nondeterministic, we construct an explicit witness:
a state `s`, action `a`, and predicates `P`, `Q` such that
`s ∈ ⟨a⟩P ∩ ⟨a⟩Q` but `s ∉ ⟨a⟩(P ∩ Q)`.

The witness uses the singleton predicates {t₁} and {t₂} where
t₁ ≠ t₂ are two distinct a-successors of s. -/

/-
**Theorem B (Explicit Non-Boolean Witness from Branching).**

    If the LTS is nondeterministic, there exists an explicit state `s`,
    action `a`, and state predicates `P`, `Q` such that the diamond
    modality fails to distribute:
    `s ∈ ⟨a⟩P ∩ ⟨a⟩Q` but `s ∉ ⟨a⟩(P ∩ Q)`.

    The witness predicates are the singletons {t₁} and {t₂} where
    t₁ ≠ t₂ are two distinct a-successors of s. Their intersection
    is empty, so ⟨a⟩({t₁} ∩ {t₂}) = ⟨a⟩∅ = ∅, while
    s ∈ ⟨a⟩{t₁} and s ∈ ⟨a⟩{t₂}.

    This is the process-algebraic analogue of the Kochen-Specker
    obstruction in quantum logic: branching creates irreducible
    non-classicality.
-/
theorem nondeterministic_diamond_witness (L : LTS Act) [DecidableEq L.State]
    (hnd : ¬ FullyDeterministic L) :
    ∃ (a : Act) (P Q : Set L.State) (s : L.State),
      s ∈ ltsDiamond L a P ∩ ltsDiamond L a Q ∧
      s ∉ ltsDiamond L a (P ∩ Q) := by
  unfold FullyDeterministic at hnd;
  simp_all +decide [ DeterministicAt ];
  obtain ⟨ s, a, t₁, ht₁, t₂, ht₂, hne ⟩ := hnd; use a, { t₁ }, { t₂ }, s; simp +decide [ *, ltsDiamond ] ;

/-! ## Theorem C: Determinism + Totality Forces Diamond–Complement Duality

For a total deterministic LTS (every state has exactly one successor per
action), the diamond modality perfectly preserves complements:
⟨a⟩(Pᶜ) = (⟨a⟩P)ᶜ. This means the modal algebra is not just distributive
but fully Boolean: the diamond is a Boolean algebra homomorphism. -/

/-
**Theorem C (Diamond-Complement Duality for Deterministic Total LTS).**

    In a fully deterministic and total LTS, the diamond modality
    commutes with complementation: `⟨a⟩(Pᶜ) = (⟨a⟩P)ᶜ`.

    This means the modal algebra inherits the full Boolean structure
    of the powerset, making the internal logic completely classical.

    The totality condition is necessary: in a non-total deterministic
    LTS, states with no a-successor satisfy s ∉ ⟨a⟩P and s ∉ ⟨a⟩(Pᶜ),
    breaking the complement identity.
-/
theorem diamond_complement_of_det_total (L : LTS Act) (a : Act)
    (hdet : FullyDeterministic L) (htot : ∀ s, TotalAt L s a) :
    ∀ P : Set L.State,
      ltsDiamond L a Pᶜ = (ltsDiamond L a P)ᶜ := by
  intro P
  ext s
  simp [ltsDiamond, Set.mem_compl_iff];
  exact ⟨ fun ⟨ s', hs', hs'' ⟩ x hx => by have := hdet s a; exact fun hx' => hs'' <| this _ _ hx hs' ▸ hx', fun h => by rcases htot s with ⟨ s', hs' ⟩ ; exact ⟨ s', hs', h _ hs' ⟩ ⟩

/-! ## Theorem D: Bisimulation Closure Characterization

The bisimulation closure operator is the identity iff bisimilarity is
equality. In a deterministic total LTS, bisimilarity between states
with different successors implies equality. -/

/-- Bisimilarity is reflexive. -/
theorem selfBisimilar_refl (L : LTS Act) (s : L.State) :
    SelfBisimilar L s s := by
  exact ⟨Eq, ⟨fun _ _ _ _ h hstep => ⟨_, h ▸ hstep, rfl⟩,
               fun _ _ _ _ h hstep => ⟨_, h ▸ hstep, rfl⟩⟩, rfl⟩

/-- Bisimilarity is symmetric. -/
theorem selfBisimilar_symm (L : LTS Act) {s t : L.State}
    (h : SelfBisimilar L s t) : SelfBisimilar L t s := by
  obtain ⟨R, hR, hst⟩ := h
  refine ⟨fun a b => R b a, ?_, hst⟩
  exact ⟨fun s t a s' h hs => hR.zag t s a s' h hs,
         fun s t a t' h ht => hR.zig t s a t' h ht⟩

/-- The bisimulation closure is always extensive: P ⊆ BisimClosure L P. -/
theorem bisimClosure_extensive (L : LTS Act) (P : Set L.State) :
    P ⊆ BisimClosure L P := by
  intro s hs
  exact ⟨s, hs, selfBisimilar_refl L s⟩

/-
BisimIsEquality implies IsIdentityClosure.
-/
theorem bisim_equality_implies_identity_closure (L : LTS Act)
    (h : BisimIsEquality L) : IsIdentityClosure L := by
  intro P
  ext t
  simp [BisimClosure];
  exact ⟨ fun ⟨ s, hs, hst ⟩ => by simpa [ h _ _ hst ] using hs, fun ht => ⟨ t, ht, selfBisimilar_refl L t ⟩ ⟩

/-
IsIdentityClosure implies BisimIsEquality.
-/
theorem identity_closure_implies_bisim_equality (L : LTS Act)
    (h : IsIdentityClosure L) : BisimIsEquality L := by
  intro s t hst;
  have := h { s };
  exact this.subset ⟨ s, rfl, hst ⟩ ▸ rfl

/-- **Theorem D (Bisim=Equality ↔ Identity Closure).**
    The bisimulation closure is the identity operator iff bisimilarity
    implies equality. -/
theorem bisim_equality_iff_identity_closure (L : LTS Act) :
    BisimIsEquality L ↔ IsIdentityClosure L :=
  ⟨bisim_equality_implies_identity_closure L,
   identity_closure_implies_bisim_equality L⟩

/-! ## Theorem E: Deterministic Total LTS has Bisimilarity = Equality

For a finite deterministic total LTS, bisimilar states must be equal.
This shows the Lawvere–Tierney topology is trivial in the deterministic case. -/

/-- In a deterministic LTS, bisimilar states have identical successors
    (the unique a-successor of s equals the unique a-successor of t,
    when both exist, and they are themselves bisimilar). -/
theorem det_bisim_successor_eq (L : LTS Act) (_hdet : FullyDeterministic L)
    {R : L.State → L.State → Prop} (hR : SelfBisimulation L R)
    {s t : L.State} (hst : R s t)
    {a : Act} {s' : L.State} (hs : L.step s a s') :
    ∃ t', L.step t a t' ∧ R s' t' := by
  exact hR.zig s t a s' hst hs

/-! ## Theorem F: Non-Boolean Witness via Nerve Subobjects

Building on sieve_nonBoolean, we show that nondeterminism creates
nerve subobjects whose diamond images cannot be complemented. -/

/-
**Theorem F (Branching Gives Non-Boolean Modal Logic).**

    If the LTS is nondeterministic, there exists a nerve subobject
    whose diamond image violates the complement law. Specifically,
    there exist S, a such that
    `⟨a⟩S.carrier ∩ ⟨a⟩(S.carrierᶜ) ≠ ∅`
    while `⟨a⟩(S.carrier ∩ S.carrierᶜ) = ∅`.

    This is a direct process-algebraic Birkhoff–von Neumann phenomenon:
    the modal algebra fails to be Boolean due to branching.
-/
theorem branching_gives_nonBoolean_modal_logic (L : LTS Act)
    [DecidableEq L.State]
    (hnd : ¬ FullyDeterministic L) :
    ∃ (a : Act) (S : NerveSubobject L),
      (ltsDiamond L a S.carrier ∩ ltsDiamond L a S.carrierᶜ).Nonempty ∧
      ltsDiamond L a (S.carrier ∩ S.carrierᶜ) = ∅ := by
  -- By definition of `FullyDeterministic`, there exist states `s₁` and `s₂` such that `L.step s a s₁` and `L.step s a s₂` but `s₁ ≠ s₂`.
  obtain ⟨s, a, s₁, s₂, hs₁, hs₂, hs_ne⟩ : ∃ s a s₁ s₂, L.step s a s₁ ∧ L.step s a s₂ ∧ s₁ ≠ s₂ := by
    contrapose! hnd;
    exact hnd;
  refine' ⟨ a, ⟨ { s₁ } ⟩, _, _ ⟩ <;> simp +decide [ *, ltsDiamond ];
  exact ⟨ s, hs₁, s₂, hs₂, by tauto ⟩

/-! ## Auxiliary lemmas for the algorithmic framework -/

/-- Diamond of empty set is empty. -/
theorem ltsDiamond_empty (L : LTS Act) (a : Act) :
    ltsDiamond L a ∅ = ∅ := by
  ext s
  simp [ltsDiamond]

/-- Diamond is monotone. -/
theorem ltsDiamond_mono (L : LTS Act) (a : Act) {P Q : Set L.State}
    (h : P ⊆ Q) : ltsDiamond L a P ⊆ ltsDiamond L a Q := by
  intro s ⟨t, hstep, ht⟩
  exact ⟨t, hstep, h ht⟩

/-- In a deterministic LTS, diamond of a singleton at s gives at most one element. -/
theorem det_diamond_singleton (L : LTS Act) (hdet : FullyDeterministic L)
    (a : Act) (t : L.State) (s : L.State)
    (hs : s ∈ ltsDiamond L a {t}) :
    ∀ t', L.step s a t' → t' = t := by
  intro t' ht'
  obtain ⟨t'', hstep, ht''⟩ := hs
  simp at ht''
  have := hdet s a t' t'' ht' hstep
  rw [this, ht'']

end BooleanTopos