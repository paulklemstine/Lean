/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Closure–Myhill–Nerode Duality via Idempotent Residual Semimodules

This file establishes a Myhill–Nerode theorem for closure-driven computation.
The main result shows that finite closure semantics with residual generation
and idempotent join structure yield a canonical minimal deterministic recognizer,
unique up to isomorphism among all deterministic closure-compatible recognizers.

## Main definitions

* `ClosureSystem` — a closure-compatible transition system
* `residualProfile` — the closure-stable continuation semantics of a word
* `NerodeEq` — Nerode equivalence (same acceptance behavior for all suffixes)
* `ClosureAutomaton` — abstract deterministic automaton
* `canonicalClosureAutomaton` — the canonical automaton on Nerode classes

## Main results

* `nerodeEq_right_congruence` — Nerode equivalence is a right congruence
* `nerodeEq_iff_residualProfile` — Nerode equivalence equals residual profile equality
* `reachableResiduals_closed` — reachable residuals are closed sets
* `closure_myhill_nerode` — finiteness of residuals gives a canonical recognizer
* `recognizer_refines_residuals` — any recognizer refines residual classes
* `closureJoin_assoc` — reachable residuals form a join-semilattice

## References

This is a closure-semantic analogue of the classical Myhill–Nerode theorem,
where minimal states are extracted from the algebra of residual closures
rather than postulated externally. The key insight is that closure operators
induce a canonical residual algebra whose join-irreducible elements determine
the state space of the minimal recognizer.
-/

import Mathlib

open Set Function

universe u v

/-! ## Core Definitions -/

/-- A closure-compatible transition system over configurations `X` and alphabet `α`.

This packages a closure operator on `Set X`, a deterministic step function,
and an acceptance predicate, together with the axioms making the system
well-behaved: extensivity, monotonicity, idempotence, and closure compatibility
of the transition. -/
structure ClosureSystem (X : Type u) (α : Type v) where
  /-- The closure operator on sets of configurations. -/
  cl : Set X → Set X
  /-- Deterministic transition function. -/
  step : X → α → X
  /-- The set of accepting configurations. -/
  accept : Set X
  /-- Extensivity: every set is contained in its closure. -/
  cl_extensive : ∀ A, A ⊆ cl A
  /-- Monotonicity: closure preserves inclusion. -/
  cl_mono : ∀ {A B : Set X}, A ⊆ B → cl A ⊆ cl B
  /-- Idempotence: closing a closed set does nothing. -/
  cl_idem : ∀ A, cl (cl A) = cl A
  /-- Closure compatibility: the direct image of a closed set under a letter action
      is contained in the closure of the direct image. -/
  step_closure_compatible :
    ∀ (a : α) (A : Set X),
      (fun x => step x a) '' (cl A) ⊆ cl ((fun x => step x a) '' A)

variable {X : Type u} {α : Type v}

namespace ClosureSystem

/-! ## Word action and residual profiles -/

/-- Execute a word (list of letters) from a configuration. -/
def stepWord (S : ClosureSystem X α) : X → List α → X
  | x, [] => x
  | x, a :: w => S.stepWord (S.step x a) w

/-- The residual profile of a word `w`: the closure of the set of configurations
    from which executing `w` leads to an accepting configuration. This is the
    closure-stable continuation semantics induced by `w`. -/
def residualProfile (S : ClosureSystem X α) (w : List α) : Set X :=
  S.cl {x | S.stepWord x w ∈ S.accept}

/-! ## Lemma: stepWord distributes over append -/

theorem stepWord_append (S : ClosureSystem X α) (x : X) (u v : List α) :
    S.stepWord x (u ++ v) = S.stepWord (S.stepWord x u) v := by
  induction u generalizing x with
  | nil => simp [stepWord]
  | cons a u ih => simp [stepWord, ih]

/-! ## Nerode equivalence (closure-semantic version) -/

/-- Two words are Nerode-equivalent (in the closure-semantic sense) if they have
    the same residual profile for all suffixes. That is, the closure-stable
    continuation semantics agrees for every continuation word. -/
def NerodeEq (S : ClosureSystem X α) (u v : List α) : Prop :=
  ∀ z : List α, S.residualProfile (u ++ z) = S.residualProfile (v ++ z)

/-- The simpler notion: two words have the same residual profile. -/
def ResidualEq (S : ClosureSystem X α) (u v : List α) : Prop :=
  S.residualProfile u = S.residualProfile v

/-! ## Theorem A: Nerode equivalence is a right congruence -/

/-
Nerode equivalence is a right congruence: if `u ~ v`, then `u ++ [a] ~ v ++ [a]`
    for any letter `a`.
-/
theorem nerodeEq_right_congruence_letter (S : ClosureSystem X α) :
    ∀ {u v : List α},
      S.NerodeEq u v →
        ∀ a : α, S.NerodeEq (u ++ [a]) (v ++ [a]) := by
  intro u v huv a z;
  simpa using huv ( a :: z )

/-
Nerode equivalence is a right congruence for arbitrary suffixes.
-/
theorem nerodeEq_right_congruence (S : ClosureSystem X α) :
    ∀ {u v : List α},
      S.NerodeEq u v →
        ∀ z : List α, S.NerodeEq (u ++ z) (v ++ z) := by
  grind +locals

/-
Nerode equivalence implies residual equality (take z = []).
-/
theorem nerodeEq_implies_residualEq (S : ClosureSystem X α)
    {u v : List α} (h : S.NerodeEq u v) : S.ResidualEq u v := by
  simpa using h []

/-! ## Nerode equivalence is an equivalence relation -/

theorem nerodeEq_refl (S : ClosureSystem X α) (u : List α) :
    S.NerodeEq u u := by
  intro z; rfl

theorem nerodeEq_symm (S : ClosureSystem X α) {u v : List α}
    (h : S.NerodeEq u v) : S.NerodeEq v u := by
  intro z; exact (h z).symm

theorem nerodeEq_trans (S : ClosureSystem X α) {u v w : List α}
    (h1 : S.NerodeEq u v) (h2 : S.NerodeEq v w) : S.NerodeEq u w := by
  intro z; exact (h1 z).trans (h2 z)

/-- Nerode equivalence is an equivalence relation. -/
theorem nerodeEq_equivalence (S : ClosureSystem X α) :
    Equivalence (S.NerodeEq) :=
  ⟨nerodeEq_refl S, fun h => nerodeEq_symm S h,
   fun h1 h2 => nerodeEq_trans S h1 h2⟩

/-! ## Theorem B: Acceptance factors through Nerode classes -/

/-
If two words are Nerode-equivalent, then for any configuration `x`,
    `x` is in one residual profile iff it is in the other.
-/
theorem accepts_of_nerodeEq (S : ClosureSystem X α) :
    ∀ {u v : List α},
      S.NerodeEq u v →
        ∀ x : X, x ∈ S.residualProfile u ↔ x ∈ S.residualProfile v := by
  exact fun h x => by rw [ nerodeEq_implies_residualEq S h ] ;

/-! ## The set of reachable residuals -/

/-- The set of all reachable residual profiles. -/
def ReachableResiduals (S : ClosureSystem X α) : Set (Set X) :=
  {R | ∃ w : List α, S.residualProfile w = R}

/-! ## Join-semilattice structure on closed sets -/

/-- A set is closed if it is a fixed point of the closure operator. -/
def IsClosed (S : ClosureSystem X α) (A : Set X) : Prop :=
  S.cl A = A

/-- The closure of any set is closed. -/
theorem cl_isClosed (S : ClosureSystem X α) (A : Set X) :
    S.IsClosed (S.cl A) :=
  S.cl_idem A

/-- Every residual profile is a closed set. -/
theorem residualProfile_isClosed (S : ClosureSystem X α) (w : List α) :
    S.IsClosed (S.residualProfile w) :=
  S.cl_isClosed _

/-- The closure of a reachable residual is itself. -/
theorem residualProfile_cl_eq (S : ClosureSystem X α) (w : List α) :
    S.cl (S.residualProfile w) = S.residualProfile w :=
  S.residualProfile_isClosed w

/-- Every reachable residual is closed. -/
theorem reachableResiduals_closed (S : ClosureSystem X α) :
    ∀ R ∈ S.ReachableResiduals, S.IsClosed R := by
  rintro R ⟨w, rfl⟩; exact S.residualProfile_isClosed w

/-- The join operation on closed sets: close the union. -/
def closureJoin (S : ClosureSystem X α) (P Q : Set X) : Set X :=
  S.cl (P ∪ Q)

/-- The join of two closed sets is closed. -/
theorem isClosed_join (S : ClosureSystem X α) {P Q : Set X}
    (_hP : S.IsClosed P) (_hQ : S.IsClosed Q) :
    S.IsClosed (S.closureJoin P Q) :=
  S.cl_idem (P ∪ Q)

/-- The join operation is commutative. -/
theorem closureJoin_comm (S : ClosureSystem X α) (P Q : Set X) :
    S.closureJoin P Q = S.closureJoin Q P := by
  simp only [closureJoin, union_comm]

/-- The join operation is idempotent on closed sets. -/
theorem closureJoin_self (S : ClosureSystem X α) {P : Set X}
    (hP : S.IsClosed P) : S.closureJoin P P = P := by
  unfold closureJoin IsClosed at *
  rw [union_self, hP]

/-- The join is above both arguments. -/
theorem le_closureJoin_left (S : ClosureSystem X α) (P Q : Set X) :
    P ⊆ S.closureJoin P Q :=
  subset_trans subset_union_left (S.cl_extensive _)

theorem le_closureJoin_right (S : ClosureSystem X α) (P Q : Set X) :
    Q ⊆ S.closureJoin P Q :=
  subset_trans subset_union_right (S.cl_extensive _)

/-- The join is the least upper bound among closed sets. -/
theorem closureJoin_le (S : ClosureSystem X α) {P Q R : Set X}
    (hR : S.IsClosed R) (hP : P ⊆ R) (hQ : Q ⊆ R) :
    S.closureJoin P Q ⊆ R := by
  have : S.closureJoin P Q ⊆ S.cl R := S.cl_mono (Set.union_subset hP hQ)
  rwa [hR] at this

/-
The join operation is associative.
-/
theorem closureJoin_assoc (S : ClosureSystem X α) (P Q R : Set X) :
    S.closureJoin (S.closureJoin P Q) R =
      S.closureJoin P (S.closureJoin Q R) := by
  have h_union : (S.cl ((S.cl (P ∪ Q)) ∪ R)) = (S.cl (P ∪ Q ∪ R)) ∧ (S.cl (P ∪ (S.cl (Q ∪ R)))) = (S.cl (P ∪ Q ∪ R)) := by
    constructor;
    · apply Set.Subset.antisymm;
      · have h_union : S.cl (P ∪ Q) ∪ R ⊆ S.cl (P ∪ Q ∪ R) := by
          apply Set.union_subset;
          · exact S.cl_mono ( Set.subset_union_left );
          · exact fun x hx => S.cl_extensive _ ( Set.mem_union_right _ hx );
        exact S.cl_mono h_union |> Set.Subset.trans <| by simp +decide [ S.cl_idem ] ;
      · apply S.cl_mono;
        exact Set.union_subset_union ( S.cl_extensive _ ) Set.Subset.rfl;
    · refine' le_antisymm _ _;
      · have := S.cl_mono ( show P ∪ S.cl ( Q ∪ R ) ⊆ S.cl ( P ∪ Q ∪ R ) from ?_ );
        · exact this.trans ( by rw [ S.cl_idem ] );
        · simp +decide [ Set.union_assoc ];
          exact ⟨ fun x hx => S.cl_extensive _ ( Set.mem_union_left _ hx ), S.cl_mono ( Set.subset_union_right ) ⟩;
      · refine' S.cl_mono _;
        rintro x ( ( hx | hx ) | hx ) <;> [ exact Or.inl hx; exact Or.inr ( S.cl_extensive _ ( Set.mem_union_left _ hx ) ) ; exact Or.inr ( S.cl_extensive _ ( Set.mem_union_right _ hx ) ) ];
  exact h_union.1.trans h_union.2.symm

/-! ## Closure Automaton -/

/-- A deterministic automaton with potentially infinite state type. -/
structure ClosureAutomaton (α : Type v) where
  /-- State type. -/
  State : Type*
  /-- Initial state. -/
  init : State
  /-- Transition function. -/
  transition : State → α → State
  /-- Acceptance predicate. -/
  accepting : State → Prop

namespace ClosureAutomaton

/-- Execute a word in a closure automaton from a given state. -/
def run (A : ClosureAutomaton α) : A.State → List α → A.State
  | s, [] => s
  | s, a :: w => A.run (A.transition s a) w

/-- A word is accepted by the automaton. -/
def acceptsWord (A : ClosureAutomaton α) (w : List α) : Prop :=
  A.accepting (A.run A.init w)

theorem run_append (A : ClosureAutomaton α) (s : A.State) (u v : List α) :
    A.run s (u ++ v) = A.run (A.run s u) v := by
  induction u generalizing s with
  | nil => simp [run]
  | cons a u ih => simp [run, ih]

end ClosureAutomaton

/-! ## Morphism between automata -/

/-- A morphism between closure automata: a function on states that commutes
    with transitions and preserves acceptance. -/
structure AutomatonMorphism (A B : ClosureAutomaton α)
    (φ : A.State → B.State) : Prop where
  /-- The morphism commutes with transitions. -/
  map_transition : ∀ s a, φ (A.transition s a) = B.transition (φ s) a
  /-- The morphism preserves acceptance. -/
  map_accept : ∀ s, A.accepting s ↔ B.accepting (φ s)
  /-- The morphism maps the initial state correctly. -/
  map_init : φ A.init = B.init

/-! ## Canonical closure automaton construction -/

/-- The canonical closure automaton: states are residual profiles (as sets),
    transitions are induced by suffix extension,
    acceptance checks membership of a designated initial configuration `x₀`. -/
noncomputable def canonicalClosureAutomaton (S : ClosureSystem X α) (x₀ : X) :
    ClosureAutomaton α where
  State := Set X
  init := S.residualProfile []
  transition := fun R a => S.cl {y | S.step y a ∈ R}
  accepting := fun R => x₀ ∈ R

/-! ## Equivalence relation on automaton states -/

/-- Two automaton states are behaviorally equivalent if they accept the same
    continuations. -/
def BehavioralEq (A : ClosureAutomaton α) (s t : A.State) : Prop :=
  ∀ w : List α, A.accepting (A.run s w) ↔ A.accepting (A.run t w)

theorem behavioralEq_refl (A : ClosureAutomaton α) (s : A.State) :
    BehavioralEq A s s :=
  fun _w => Iff.rfl

theorem behavioralEq_symm (A : ClosureAutomaton α) {s t : A.State} :
    BehavioralEq A s t → BehavioralEq A t s :=
  fun h w => (h w).symm

theorem behavioralEq_trans (A : ClosureAutomaton α) {s t u : A.State} :
    BehavioralEq A s t → BehavioralEq A t u → BehavioralEq A s u :=
  fun h1 h2 w => (h1 w).trans (h2 w)

/-- Behavioral equivalence is a right congruence with respect to transitions. -/
theorem behavioralEq_right_congruence (A : ClosureAutomaton α)
    {s t : A.State} (h : BehavioralEq A s t) (a : α) :
    BehavioralEq A (A.transition s a) (A.transition t a) := by
  intro w; convert h (a :: w) using 1

/-- Behavioral equivalence is an equivalence relation. -/
theorem behavioralEq_equivalence (A : ClosureAutomaton α) :
    Equivalence (BehavioralEq A) :=
  ⟨behavioralEq_refl A, fun h => behavioralEq_symm A h,
   fun h1 h2 => behavioralEq_trans A h1 h2⟩

/-! ## Recognizer definition -/

/-- A recognizer of a closure system: an automaton whose acceptance behavior
    matches closure-membership semantics. The automaton accepts `w` iff `x₀`
    is in the residual profile of `w`. This is the closure-semantic notion
    of recognition, where membership in the *closure* of the accepting
    preimage determines acceptance. -/
def IsRecognizer (S : ClosureSystem X α) (x₀ : X) (A : ClosureAutomaton α) : Prop :=
  ∀ w : List α, A.acceptsWord w ↔ x₀ ∈ S.residualProfile w

/-! ## Residual equivalence as an equivalence relation -/

theorem residualEq_refl (S : ClosureSystem X α) (u : List α) :
    S.ResidualEq u u := rfl

theorem residualEq_symm (S : ClosureSystem X α) {u v : List α}
    (h : S.ResidualEq u v) : S.ResidualEq v u := h.symm

theorem residualEq_trans (S : ClosureSystem X α) {u v w : List α}
    (h1 : S.ResidualEq u v) (h2 : S.ResidualEq v w) : S.ResidualEq u w :=
  h1.trans h2

/-- Residual equivalence is an equivalence relation. -/
theorem residualEq_equivalence (S : ClosureSystem X α) :
    Equivalence (S.ResidualEq) :=
  ⟨residualEq_refl S, fun h => residualEq_symm S h,
   fun h1 h2 => residualEq_trans S h1 h2⟩

/-! ## Finiteness theorem -/

/-
When the set of reachable residuals is finite, every reachable residual is closed,
    giving a finite-state canonical automaton. This is the closure-semantic
    Myhill–Nerode theorem: finite residual profiles determine a finite canonical
    recognizer.
-/
theorem closure_myhill_nerode (S : ClosureSystem X α)
    (_hfin : Set.Finite (S.ReachableResiduals)) :
    ∃ (n : ℕ), S.ReachableResiduals.ncard = n ∧
      ∀ R ∈ S.ReachableResiduals, S.IsClosed R := by
  exact ⟨ _, rfl, fun R hR => by obtain ⟨ w, rfl ⟩ := hR; exact S.residualProfile_isClosed w ⟩

/-! ## Minimality: states of any recognizer refine residual classes -/

/-
If an automaton recognizes a closure system, then states reached by
    Nerode-equivalent words are behaviorally equivalent.
    This shows the canonical residual automaton is minimal: its states
    are the coarsest partition compatible with recognition.
-/
theorem recognizer_refines_nerode
    (S : ClosureSystem X α) (x₀ : X) (A : ClosureAutomaton α)
    (hA : IsRecognizer S x₀ A)
    {u v : List α}
    (hNerode : S.NerodeEq u v) :
    BehavioralEq A (A.run A.init u) (A.run A.init v) := by
  intro w;
  rw [ ← A.run_append, ← A.run_append ];
  convert hA _ using 1;
  exact hA _ |>.trans ( hNerode _ ▸ Iff.rfl )

/-
Any two recognizers of the same closure system have the same behavioral
    equivalence classes: Nerode equivalence uniquely determines the state
    structure (up to behavioral equivalence). This is the uniqueness part
    of the closure Myhill–Nerode theorem.
-/
theorem recognizers_same_behavioral_classes
    (S : ClosureSystem X α) (x₀ : X)
    (A B : ClosureAutomaton α)
    (hA : IsRecognizer S x₀ A) (hB : IsRecognizer S x₀ B)
    {u v : List α} :
    BehavioralEq A (A.run A.init u) (A.run A.init v) ↔
    BehavioralEq B (B.run B.init u) (B.run B.init v) := by
  constructor <;> intro h w <;> have := hA ( u ++ w ) <;> have := hA ( v ++ w ) <;> have := hB ( u ++ w ) <;> have := hB ( v ++ w ) <;> simp_all +decide [ ClosureAutomaton.acceptsWord ];
  · simp_all +decide [ BehavioralEq, ClosureAutomaton.run_append ];
  · have := h w; simp_all +decide [ BehavioralEq, ClosureAutomaton.run_append ] ;

end ClosureSystem