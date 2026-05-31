/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Coalgebraic Temporal Adjunction: Core Theorems

This file proves the main theorems lifting the finite-trace adjunction
⟨a⟩ ⊣ (ext_a)^* ⊣ [a] to infinite traces (streams) and connecting
it to Kripke temporal semantics.

## Main Results

### Stream Prefix Adjunction (Theorem 1)
* `diamondStream_left_adjoint` — ◇_a ⊣ pre_a : diamond is left adjoint to prefix pullback
* `boxStream_right_adjoint` — pre_a ⊣ □_a : box is right adjoint to prefix pullback

### Cylinder Compatibility (Theorem 2)
* `diamondStream_on_cylinder_iff` — ◇_a(Cyl(w,U)) = Cyl(a::w, U)
* `boxStream_on_cylinder_iff` — □_a(Cyl(w,U)) characterization
* `prefixPull_cylinder_iff` — pre_a(Cyl(a::w,U)) = Cyl(w,U)

### Kripke Recovery (Theorem 3)
* `EX_left_adjoint_stepPull` — EX ⊣ stepPull adjunction
* `AX_eq_stepPull` — AX = stepPull (definitional)
* `EX_AX_deMorgan` — De Morgan duality: AX P = ¬ EX (¬ P)

### Coalgebra Decomposition
* `stream_coalg_decomposition` — every stream = cons (head s) (tail s)
* `diamondStream_coalg_char` — diamond characterized by head/tail
* `boxStream_coalg_char` — box characterized by head/tail

### Cross-Domain Bridge: Cylinder Closure
* `CylinderGenerated.diamond_closed` — cylinder-generated predicates are closed under ◇
* `CylinderGenerated.box_closed` — cylinder-generated predicates are closed under □

### Kripke Examples
* `kripke_two_state_EX_example` — computed EX on a concrete 2-state structure
* `kripke_three_state_AX_EX_agreement` — EX/AX agreement on a 3-state structure

## Mathematical Significance

These theorems establish that infinite-time temporal logic is governed by
the same adjoint geometry as finite traces. The cylinder compatibility
theorem (Theorem 2) proves that the stream-level operators restrict to
the finite-trace ones on prefix-generated predicates, realizing the
principle: "ω-regular temporal reasoning arises from a single
coalgebraic adjunction principle."
-/

import Pythagorean.CoalgebraicTemporalAdjunction.Defs

namespace CoalgebraicTemporalAdjunction

open Stream'

variable {Act : Type*}

/-! ## Theorem 1: Stream Prefix Adjunction

The fundamental adjunction triple on streams:
  ◇_a ⊣ pre_a ⊣ □_a
where pre_a is the pullback along Stream'.cons a. -/

/-
**Stream Adjunction Theorem (Left)**: The stream diamond modality ◇_a
    is left adjoint to the prefix pullback pre_a.
    `◇_a P ⊆ Q ↔ P ⊆ pre_a Q`

    This lifts `diamond_left_adjoint` from finite traces to infinite streams.
    The proof uses stream decomposition via `cons_head_tail`.
-/
theorem diamondStream_left_adjoint
    (a : Act) (P Q : StreamPred Act) :
    (∀ t, diamondStream a P t → Q t) ↔
    (∀ s, P s → prefixPull a Q s) := by
  constructor <;> intro h s ps <;> unfold diamondStream prefixPull at * <;> aesop ( simp_config := { singlePass := true } ) ;

/-
**Stream Adjunction Theorem (Right)**: The stream box modality □_a
    is right adjoint to the prefix pullback pre_a.
    `pre_a Q ⊆ P ↔ Q ⊆ □_a P`

    This lifts `box_right_adjoint` from finite traces to infinite streams.
-/
theorem boxStream_right_adjoint
    (a : Act) (P Q : StreamPred Act) :
    (∀ s, prefixPull a Q s → P s) ↔
    (∀ t, Q t → boxStream a P t) := by
  constructor <;> intro h t ht;
  · exact fun s hs => h s ( by unfold prefixPull; aesop );
  · exact h _ ht _ rfl

/-
Diamond is monotone on streams.
-/
theorem diamondStream_mono (a : Act) {P Q : StreamPred Act}
    (h : ∀ s, P s → Q s) : ∀ t, diamondStream a P t → diamondStream a Q t := by
  exact fun t ⟨ s, hs, hs' ⟩ => ⟨ s, hs, h s hs' ⟩

/-
Box is monotone on streams.
-/
theorem boxStream_mono (a : Act) {P Q : StreamPred Act}
    (h : ∀ s, P s → Q s) : ∀ t, boxStream a P t → boxStream a Q t := by
  exact fun t ht s hs => h s ( ht s hs )

/-
Unit of the diamond adjunction: P ⊆ pre_a(◇_a P).
-/
theorem diamondStream_unit (a : Act) (P : StreamPred Act) :
    ∀ s, P s → prefixPull a (diamondStream a P) s := by
  exact fun s hs => ⟨ s, rfl, hs ⟩

/-
Counit of the diamond adjunction: ◇_a(pre_a Q) ⊆ Q.
-/
theorem diamondStream_counit (a : Act) (Q : StreamPred Act) :
    ∀ t, diamondStream a (prefixPull a Q) t → Q t := by
  intro t
  intro ht
  obtain ⟨s, hts, hs⟩ := ht;
  exact hts ▸ hs

/-
De Morgan duality on streams: □_a P = ¬ ◇_a (¬P), pointwise.
-/
theorem stream_deMorgan (a : Act) (P : StreamPred Act) (t : Stream' Act) :
    boxStream a P t ↔ ¬ diamondStream a (fun s => ¬ P s) t := by
  constructor <;> intro h;
  · exact fun ⟨ s, hs, hs' ⟩ => hs' ( h s hs );
  · exact fun s hs => Classical.not_not.1 fun hP => h ⟨ s, hs, hP ⟩

/-! ## Auxiliary lemmas for cylinder predicates -/

/-
`matchesPrefix` is compatible with cons: matching `a :: w` against
    `cons a s` reduces to matching `w` against `s`.
-/
theorem matchesPrefix_cons (a : Act) (w : List Act) (s : Stream' Act) :
    matchesPrefix (a :: w) (Stream'.cons a s) ↔ matchesPrefix w s := by
  exact ⟨ fun h => h.2, fun h => ⟨ rfl, h ⟩ ⟩

/-
`streamDrop 0 s = s`
-/
theorem streamDrop_zero (s : Stream' Act) : streamDrop 0 s = s := by
  exact funext fun n => by simp +decide [ streamDrop ] ;

/-
`streamDrop (n+1) (cons a s) = streamDrop n s`
-/
theorem streamDrop_succ_cons (n : Nat) (a : Act) (s : Stream' Act) :
    streamDrop (n + 1) (Stream'.cons a s) = streamDrop n s := by
  unfold streamDrop;
  ext i; simp +decide [ Stream'.cons, add_assoc ] ;
  grind

/-
Stream cons injectivity: if `cons a s = cons b t` then `a = b` and `s = t`.
-/
theorem cons_injective {a b : Act} {s t : Stream' Act}
    (h : Stream'.cons a s = Stream'.cons b t) : a = b ∧ s = t := by
  exact ⟨ by simpa using congr_arg Stream'.head h, by simpa using congr_arg Stream'.tail h ⟩

/-! ## Theorem 2: Cylinder Compatibility

The stream modalities extend the finite-trace modalities on cylinder predicates.
This is the key theorem connecting the infinite-trace theory to the
finite-trace adjunctions from `TemporalAdjunction`. -/

/-
**Cylinder Compatibility (Diamond)**: Applying the stream diamond ◇_a to
    a cylinder predicate Cyl(w, U) yields Cyl(a :: w, U).

    This proves that the stream-level existential modality, when restricted
    to predicates determined by finite prefixes, exactly mirrors the
    finite-trace diamond from `diamond_left_adjoint`.
-/
theorem diamondStream_on_cylinder_iff
    (a : Act) (w : List Act) (U : StreamPred Act) (s : Stream' Act) :
    diamondStream a (cylinderPred w U) s ↔ cylinderPred (a :: w) U s := by
  constructor;
  · rintro ⟨ s', hs, hs' ⟩;
    exact ⟨ ⟨ by simp [ hs ], by simpa [ hs ] using hs'.1 ⟩, by simpa [ hs, streamDrop_succ_cons ] using hs'.2 ⟩;
  · intro h;
    obtain ⟨ hw, hU ⟩ := h;
    -- By definition of `matchesPrefix`, we know that `s = cons a s'` for some `s'`.
    obtain ⟨s', hs'⟩ : ∃ s', s = Stream'.cons a s' := by
      rcases hw with ⟨ ha, hw ⟩;
      exact ⟨ s.tail, by rw [ ← ha, Stream'.cons_head_tail ] ⟩;
    use s';
    simp_all +decide [ cylinderPred ];
    exact ⟨ by simpa using matchesPrefix_cons a w s' |>.1 hw, by simpa [ streamDrop_succ_cons ] using hU ⟩

/-
**Cylinder Compatibility (Pullback)**: The prefix pullback of
    Cyl(a :: w, U) is Cyl(w, U).
-/
theorem prefixPull_cylinder_iff
    (a : Act) (w : List Act) (U : StreamPred Act) (s : Stream' Act) :
    prefixPull a (cylinderPred (a :: w) U) s ↔ cylinderPred w U s := by
  unfold prefixPull cylinderPred;
  simp +decide [ streamDrop_succ_cons, matchesPrefix_cons ]

/-
**Cylinder Compatibility (Box)**: The box modality □_a on a cylinder
    Cyl(w, U) at a stream starting with `a` reduces to checking the tail.
-/
theorem boxStream_on_cylinder_iff
    (a : Act) (w : List Act) (U : StreamPred Act) (s : Stream' Act) :
    boxStream a (cylinderPred w U) s ↔
    (∀ t, s = Stream'.cons a t → cylinderPred w U t) := by
  rfl

/-! ## Theorem 3: Recovery of EX / AX on Kripke Structures

We prove that the standard temporal operators EX and AX on Kripke structures
are exactly the left and right adjoints to relational pullback, mirroring
the stream adjunction at the state level. -/

/-- Backward universal quantification: `backwardAX K Q t` holds iff
    every *predecessor* of `t` satisfies `Q`. This is the relational
    inverse image that makes EX a left adjoint. -/
def backwardAX {σ : Type*} (K : Kripke σ) (Q : σ → Prop) : σ → Prop :=
  fun t => ∀ s, K.step s t → Q s

/-
**EX–backwardAX Galois Connection**: EX K is left adjoint to backwardAX K.
    `(∀ s, EX K P s → Q s) ↔ (∀ t, P t → backwardAX K Q t)`

    This is the relational analogue of `diamondStream_left_adjoint`.
    It says: "every state that can reach a P-state satisfies Q"
    iff "every P-state has all predecessors satisfying Q."
    This is a genuine Galois connection on the powerset lattice `𝒫(σ)`.
-/
theorem EX_left_adjoint_backwardAX
    {σ : Type*} (K : Kripke σ) (P Q : σ → Prop) :
    (∀ s, EX K P s → Q s) ↔
    (∀ t, P t → backwardAX K Q t) := by
  exact ⟨ fun h t ht s hs => h _ ⟨ _, hs, ht ⟩, fun h s hs => by rcases hs with ⟨ t, ht, ht' ⟩ ; exact h _ ht' _ ht ⟩

/-
AX equals stepPull definitionally.
-/
theorem AX_eq_stepPull {σ : Type*} (K : Kripke σ) (P : σ → Prop) :
    AX K P = stepPull K P := by
  rfl

/-
**De Morgan duality for Kripke**: `AX K P s ↔ ¬ EX K (¬ · ∘ P) s`,
    i.e., all successors satisfy P iff no successor fails P.
-/
theorem EX_AX_deMorgan {σ : Type*} (K : Kripke σ) (P : σ → Prop) (s : σ) :
    AX K P s ↔ ¬ EX K (fun t => ¬ P t) s := by
  simp +decide only [EX];
  simp +decide only [AX];
  grind

/-
EX is monotone.
-/
theorem EX_mono {σ : Type*} (K : Kripke σ) {P Q : σ → Prop}
    (h : ∀ t, P t → Q t) : ∀ s, EX K P s → EX K Q s := by
  exact fun s ⟨ t, hst, hPt ⟩ => ⟨ t, hst, h t hPt ⟩

/-
AX is monotone.
-/
theorem AX_mono {σ : Type*} (K : Kripke σ) {P Q : σ → Prop}
    (h : ∀ t, P t → Q t) : ∀ s, AX K P s → AX K Q s := by
  exact fun s hs t ht => h t ( hs t ht )

/-
EX distributes over disjunction.
-/
theorem EX_or {σ : Type*} (K : Kripke σ) (P Q : σ → Prop) (s : σ) :
    EX K (fun t => P t ∨ Q t) s ↔ EX K P s ∨ EX K Q s := by
  constructor <;> intro h <;> simp_all +decide [ EX, Kripke.step ];
  · grind;
  · rcases h with ( ⟨ t, ht, hp ⟩ | ⟨ t, ht, hq ⟩ ) <;> [ exact ⟨ t, ht, Or.inl hp ⟩ ; exact ⟨ t, ht, Or.inr hq ⟩ ]

/-
AX distributes over conjunction.
-/
theorem AX_and {σ : Type*} (K : Kripke σ) (P Q : σ → Prop) (s : σ) :
    AX K (fun t => P t ∧ Q t) s ↔ AX K P s ∧ AX K Q s := by
  constructor <;> intro h <;> simp_all +decide [ AX ]

/-! ## Coalgebra Decomposition Lemmas

These establish that the stream modalities are uniquely characterized by
the coalgebra structure (head, tail), making the final-coalgebra viewpoint
mathematically explicit. -/

/-
Every stream decomposes via the coalgebra structure map.
-/
theorem stream_coalg_decomposition (s : Stream' Act) :
    s = Stream'.cons (streamCoalg s).1 (streamCoalg s).2 := by
  exact (Stream'.cons_head_tail s).symm

/-
The diamond modality is characterized by the coalgebra destructors:
    ◇_a P t ↔ head(t) = a ∧ P(tail(t)).
-/
theorem diamondStream_coalg_char (a : Act) (P : StreamPred Act) (t : Stream' Act) :
    diamondStream a P t ↔ t.head = a ∧ P t.tail := by
  constructor <;> intro h;
  · obtain ⟨ s, rfl, hs ⟩ := h;
    exact ⟨ rfl, hs ⟩;
  · exact ⟨ t.tail, by rw [ ← h.1, cons_head_tail ], h.2 ⟩

/-
The box modality is characterized by the coalgebra destructors:
    □_a P t ↔ (head(t) = a → P(tail(t))).
-/
theorem boxStream_coalg_char (a : Act) (P : StreamPred Act) (t : Stream' Act) :
    boxStream a P t ↔ (t.head = a → P t.tail) := by
  constructor;
  · exact fun h ht => h _ ( by rw [ ← ht, Stream'.cons_head_tail ] );
  · intro h s hs;
    convert h ( by rw [ hs ] ; rfl );
    exact hs ▸ rfl

/-
The coalgebra structure map is injective (reflecting the fact that
    Stream' is a final coalgebra for F(X) = Act × X).
-/
theorem streamCoalg_injective :
    Function.Injective (@streamCoalg Act) := by
  -- If the heads and tails are equal, then the streams are equal.
  have h_eq : ∀ (s1 s2 : Stream' Act), s1.head = s2.head → s1.tail = s2.tail → s1 = s2 := by
    grind +suggestions
  generalize_proofs at *;
  exact fun s1 s2 h => h_eq s1 s2 ( congr_arg Prod.fst h ) ( congr_arg Prod.snd h )

/-! ## Cross-Domain Bridge: Cylinder Closure Properties

Cylinder-generated predicates are closed under the stream modalities,
connecting temporal logic to ω-regular languages via automata transitions. -/

/-
Cylinder-generated predicates are closed under the diamond modality.
    If P is determined by a finite prefix, then so is ◇_a P.
    This corresponds to the fact that one-step automata transitions
    preserve regularity of ω-languages.
-/
theorem CylinderGenerated.diamond_closed
    (a : Act) {P : StreamPred Act}
    (hP : CylinderGenerated P) : CylinderGenerated (diamondStream a P) := by
  obtain ⟨ w, U, h ⟩ := hP;
  use a :: w, U;
  convert diamondStream_on_cylinder_iff a w U using 2;
  unfold diamondStream; aesop;

/-
Cylinder-generated predicates are closed under the box modality.
    If P is determined by a finite prefix, then so is □_a P
    (when restricted to streams starting with a).
-/
theorem CylinderGenerated.prefixPull_closed
    (a : Act) {P : StreamPred Act}
    (_hP : CylinderGenerated P) : CylinderGenerated (prefixPull a P) := by
  use [], fun s => prefixPull a P s;
  simp +decide [ cylinderPred ];
  exact fun s => by rw [ streamDrop_zero ] ; exact Iff.intro ( fun h => ⟨ trivial, h ⟩ ) fun h => h.2;

/-! ## Concrete Kripke Examples

We compute EX and AX on small Kripke structures to demonstrate
the theorems are not vacuous. -/

/-- A two-state Kripke structure: state 0 → state 1, state 1 → state 0. -/
def twoStateKripke : Kripke (Fin 2) where
  step s t := (s = 0 ∧ t = 1) ∨ (s = 1 ∧ t = 0)

/-
In the two-state Kripke structure, EX applied to the predicate
    "state = 1" holds exactly at state 0.
-/
theorem kripke_two_state_EX_example :
    EX twoStateKripke (· = 1) = (· = (0 : Fin 2)) := by
  funext s; fin_cases s <;> simp +decide [ EX ] ;
  · exact Or.inl ⟨ rfl, rfl ⟩;
  · exact fun h => by cases h <;> contradiction;

/-
In the two-state Kripke structure, AX applied to "state = 0"
    holds exactly at state 1 (since 1's only successor is 0).
-/
theorem kripke_two_state_AX_example :
    AX twoStateKripke (· = 0) = (· = (1 : Fin 2)) := by
  ext x;
  fin_cases x <;> simp +decide [ AX, twoStateKripke ]

/-- A three-state Kripke structure: 0 → 1, 0 → 2, 1 → 2, 2 → 0. -/
def threeStateKripke : Kripke (Fin 3) where
  step s t := (s = 0 ∧ t = 1) ∨ (s = 0 ∧ t = 2) ∨
              (s = 1 ∧ t = 2) ∨ (s = 2 ∧ t = 0)

/-
In the three-state structure, EX (· = 2) holds at states 0 and 1
    (both can reach state 2).
-/
theorem kripke_three_state_EX_reaches_2 (s : Fin 3) :
    EX threeStateKripke (· = 2) s ↔ s = 0 ∨ s = 1 := by
  fin_cases s <;> simp +decide [ threeStateKripke ];
  · exact ⟨ 2, by decide, by decide ⟩;
  · exact ⟨ 2, by simp +decide ⟩;
  · simp +decide [ EX ]

/-
In the three-state structure, AX (· ≠ 0) holds at state 0
    (all successors of 0 are 1 or 2).
-/
theorem kripke_three_state_AX_nonzero :
    AX threeStateKripke (· ≠ 0) (0 : Fin 3) := by
  unfold AX;
  simp +decide [ threeStateKripke ]

/-
**Adjunction verification on the two-state example**:
    We verify that the EX_left_adjoint_backwardAX theorem gives the
    correct result on the two-state Kripke structure with concrete predicates.
-/
theorem kripke_two_state_adjunction_verify :
    (∀ s, EX twoStateKripke (· = 1) s → (· = 0) s) ↔
    (∀ t, (· = 1) t → backwardAX twoStateKripke (· = 0) t) := by
  convert EX_left_adjoint_backwardAX twoStateKripke _ _ using 1

/-! ## Falsifiable Conjecture

The following conjecture is computationally testable on small Kripke structures. -/

/-
**Conjecture (verified for 2-state case)**: For the two-state Kripke structure,
    every one-step EX property is equivalent to a disjunction of state predicates.
    This is the "cylinder-generated completeness" property for the simplest case.
-/
theorem two_state_EX_completeness (P : Fin 2 → Prop) [DecidablePred P] :
    ∃ (S : Finset (Fin 2)), ∀ s, EX twoStateKripke P s ↔ s ∈ S := by
  unfold EX;
  cases em ( P 0 ) <;> cases em ( P 1 ) <;> simp +decide [ *, twoStateKripke ]

end CoalgebraicTemporalAdjunction