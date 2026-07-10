import Mathlib

/-!
# Strange Loops, Part II: A Chain of Self-Reference Results (with a Non-Vacuous Gödel)

This file is a *self-contained* development that builds a single dependency chain of
theorems around self-reference, diagonalization, and Gödelian incompleteness. Each
result feeds the next.

The organizing insight is a **soundness correction** over the naive "semantic strange
loop": a system whose diagonal operator returns, for *every* predicate `P`, a sentence
whose *truth* is equivalent to `P` applied to itself is **contradictory** — it is just
the Liar paradox (`no_semantic_diagonal`). Real Gödelian incompleteness avoids this by
diagonalizing against the *syntactic provability* predicate, not the truth predicate,
and by only requiring the fixed point for the single unprovability predicate. We make
that precise with an **inhabited** `GodelSystem` structure and derive genuine,
*non-vacuous* incompleteness and undecidability from it.

## The chain

1. `liar_paradox` — the pure propositional seed `(p ↔ ¬p) → False`.
2. `no_semantic_diagonal` — a total semantic diagonal is inconsistent (Liar, generalized).
3. `abstract_incompleteness` / `abstract_undecidable` — the propositional core of Gödel.
4. `lawvere_fixed_point` — the categorical heart of every diagonal argument.
5. `cantor_no_surjection`, `tarski_truth_undefinable`, `rice_trivial` — Lawvere corollaries.
6. `GodelSystem` (+ `GodelSystem.inhabited`) — a *consistent, inhabited* provability model.
7. `GodelSystem.goedel_true_unprovable`, `.incomplete`, `.not_complete` — Gödel I.
8. `GodelSystem.goedel_undecidable` — both `G` and `¬G` are unprovable.
9. `GodelSystem.loeb_consistency_unprovable` — a second-incompleteness / Löb-style corollary.
10. `provability_operator_has_fixed_point`, `lfp_gfp_gap_incomplete` — the provability lattice.

## References
- Lawvere, F.W. "Diagonal arguments and cartesian closed categories" (1969)
- Gödel, K. "Über formal unentscheidbare Sätze …" (1931)
- Hofstadter, D. "Gödel, Escher, Bach" (1979)
-/

open Function

namespace StrangeLoopsChain

/-! ## Part 1: The Liar seed -/

/-- **The Liar paradox.** No proposition can be equivalent to its own negation.
    This single lemma is the seed of the entire chain. -/
theorem liar_paradox {p : Prop} (h : p ↔ ¬ p) : False := by
  have hnp : ¬ p := fun hp => (h.mp hp) hp
  exact hnp (h.mpr hnp)

/-! ## Part 2: The naive semantic strange loop is inconsistent -/

/-- **No total semantic diagonal.** There is *no* truth predicate `True_` together with a
    diagonal operator `diag` such that, for **every** predicate `P`, the truth of `diag P`
    is equivalent to `P (diag P)`. Taking `P := ¬ True_ ·` reduces to the Liar paradox.

    Consequence: a `StrangeLoop` structure demanding this for all `P` is uninhabited, and
    incompleteness proved from it would be vacuous. Real Gödel diagonalizes only against
    the syntactic provability predicate (Parts 6–9). -/
theorem no_semantic_diagonal {S : Type*} (True_ : S → Prop) (diag : (S → Prop) → S) :
    ¬ ∀ P : S → Prop, True_ (diag P) ↔ P (diag P) := by
  intro h
  exact liar_paradox (h (fun s => ¬ True_ s))

/-! ## Part 3: The abstract (propositional) core of Gödel -/

/-- **Abstract incompleteness.** If a sentence's truth `T` is equivalent to its own
    unprovability `¬ P`, and the system is sound (`P → T`), then it is unprovable (`¬ P`).
    This is the propositional skeleton of Gödel's First Incompleteness Theorem. -/
theorem abstract_incompleteness {P T : Prop} (hfix : T ↔ ¬ P) (hsound : P → T) : ¬ P := by
  intro hp
  exact (hfix.mp (hsound hp)) hp

/-- **Abstract incompleteness, truth half.** Under the same hypotheses the Gödel
    sentence is moreover *true*. -/
theorem abstract_true {P T : Prop} (hfix : T ↔ ¬ P) (hsound : P → T) : T :=
  hfix.mpr (abstract_incompleteness hfix hsound)

/-- **Abstract undecidability.** With a negation sentence whose truth `Tn` is `¬ T`
    and which is also sound (`Pn → Tn`), *neither* the sentence nor its negation is
    provable. This is Gödel's undecidability, needing only soundness (no ω-consistency). -/
theorem abstract_undecidable {P T Pn Tn : Prop}
    (hfix : T ↔ ¬ P) (hsound : P → T) (hnegtruth : Tn ↔ ¬ T) (hnegsound : Pn → Tn) :
    ¬ P ∧ ¬ Pn := by
  refine ⟨abstract_incompleteness hfix hsound, ?_⟩
  intro hpn
  exact (hnegtruth.mp (hnegsound hpn)) (abstract_true hfix hsound)

/-! ## Part 4: Lawvere's fixed-point theorem — the categorical heart -/

/-- **Lawvere's Fixed-Point Theorem.** If there is a point-surjective map
    `φ : A → (A → B)`, then every self-map `g : B → B` has a fixed point. Every
    diagonal argument (Cantor, Russell, Tarski, Gödel, Rice) is an instance. -/
theorem lawvere_fixed_point {A B : Type*}
    (φ : A → (A → B)) (hφ : Surjective φ) (g : B → B) :
    ∃ b : B, g b = b := by
  obtain ⟨a₀, ha₀⟩ := hφ (fun a => g (φ a a))
  exact ⟨φ a₀ a₀, (congr_fun ha₀ a₀).symm⟩

/-! ## Part 5: Corollaries of Lawvere -/

/-- **Cantor's theorem** via Lawvere: no surjection from a type onto its predicate space.
    If one existed, negation `¬ ·` on `Prop` would have a fixed point — a Liar. -/
theorem cantor_no_surjection (A : Type*) : ¬ ∃ f : A → (A → Prop), Surjective f := by
  rintro ⟨f, hf⟩
  obtain ⟨b, hb⟩ := lawvere_fixed_point f hf (¬ ·)
  exact liar_paradox (Iff.of_eq hb.symm)

/-- **Tarski's undefinability of truth** via Lawvere: if `φ : A → (A → Prop)` is
    surjective there is a predicate not represented by any `φ a`; contrapositively no
    surjective "truth coding" exists, so truth is not definable inside the system. -/
theorem tarski_truth_undefinable {A : Type*}
    (φ : A → (A → Prop)) (hφ : Surjective φ) : ∃ Q : A → Prop, ∀ a, φ a ≠ Q := by
  exact absurd ⟨φ, hφ⟩ (cantor_no_surjection A)

/-- A property of predicates is **trivial** if it holds of all of them or of none. -/
def IsTrivial {α : Type*} (P : α → Prop) : Prop := (∀ a, P a) ∨ (∀ a, ¬ P a)

/-- **Rice's theorem, abstract form** via Lawvere: if predicates on `A` are all coded by
    a surjection `φ`, then no property distinguishes them — every property is trivial.
    (Vacuously so, since such a surjection cannot exist by `cantor_no_surjection`.) -/
theorem rice_trivial {A : Type*}
    (φ : A → (A → Prop)) (hφ : Surjective φ) (P : (A → Prop) → Prop) :
    IsTrivial (P ∘ φ) :=
  absurd ⟨φ, hφ⟩ (cantor_no_surjection A)

/-! ## Part 6: A consistent, inhabited Gödel provability model -/

/-- A **`GodelSystem`** separates *syntactic provability* from *truth*, avoiding the
    Liar collapse of `no_semantic_diagonal`. It carries an explicit Gödel sentence `G`
    with the diagonal fixed point stated only for the unprovability predicate, together
    with a negation sentence and soundness. Unlike the "semantic strange loop", this is
    consistent — see `GodelSystem.inhabited`. -/
structure GodelSystem where
  /-- The type of sentences. -/
  Sentence : Type
  /-- Syntactic provability. -/
  Provable : Sentence → Prop
  /-- Meta-level truth (truth in the standard model). -/
  Holds : Sentence → Prop
  /-- Soundness: everything provable is true. -/
  sound : ∀ s, Provable s → Holds s
  /-- Syntactic negation on sentences. -/
  neg : Sentence → Sentence
  /-- Truth commutes with negation. -/
  neg_holds : ∀ s, Holds (neg s) ↔ ¬ Holds s
  /-- The Gödel sentence. -/
  G : Sentence
  /-- The diagonal fixed point: `G` asserts its own unprovability. -/
  G_fix : Holds G ↔ ¬ Provable G

namespace GodelSystem

/-- **Non-vacuity.** A `GodelSystem` exists. Take a one-sentence system where nothing
    is provable and the sentence is true: then `Holds G ↔ ¬ Provable G` is `True ↔ True`.
    This certifies that the incompleteness results below are not vacuous. -/
theorem inhabited : Nonempty GodelSystem := by
  refine ⟨{
    Sentence := Bool
    Provable := fun _ => False
    Holds := fun b => b = true
    sound := by intro s h; exact h.elim
    neg := fun b => !b
    neg_holds := by intro s; cases s <;> simp
    G := true
    G_fix := by simp }⟩

variable (L : GodelSystem)

/-- **Gödel's First Incompleteness Theorem** (this model): the Gödel sentence `G` is
    *true but unprovable*. Instantiates `abstract_true`/`abstract_incompleteness`. -/
theorem goedel_true_unprovable : L.Holds L.G ∧ ¬ L.Provable L.G :=
  ⟨abstract_true L.G_fix (L.sound L.G), abstract_incompleteness L.G_fix (L.sound L.G)⟩

/-- **Incompleteness.** There is a true sentence that is not provable. -/
theorem incomplete : ∃ s, L.Holds s ∧ ¬ L.Provable s :=
  ⟨L.G, L.goedel_true_unprovable⟩

/-- **No complete sound system.** The system cannot prove all truths. -/
theorem not_complete : ¬ ∀ s, L.Holds s → L.Provable s := by
  intro hc
  obtain ⟨s, ht, hnp⟩ := L.incomplete
  exact hnp (hc s ht)

/-- **Undecidability of `G`.** Neither `G` nor its negation `neg G` is provable — the
    system is essentially incomplete. Needs only soundness (via `abstract_undecidable`). -/
theorem goedel_undecidable : ¬ L.Provable L.G ∧ ¬ L.Provable (L.neg L.G) :=
  abstract_undecidable L.G_fix (L.sound L.G) (L.neg_holds L.G) (L.sound (L.neg L.G))

/-! ## Part 7: A second-incompleteness / Löb-style corollary -/

/-- **Consistency is unprovable** (second-incompleteness analog). Suppose the system has
    a consistency sentence `Con` whose truth means exactly "`G` is unprovable", and that
    the formalized derivability condition `Provable Con → Provable G` holds (the crux of
    Gödel II / Löb). Then `Con` is not provable: a sound system cannot prove its own
    consistency. Chains off `goedel_true_unprovable`. -/
theorem loeb_consistency_unprovable
    (Con : L.Sentence)
    (hCon : L.Holds Con ↔ ¬ L.Provable L.G)
    (hderiv : L.Provable Con → L.Provable L.G) :
    ¬ L.Provable Con := by
  intro hp
  exact (hCon.mp (L.sound Con hp)) (hderiv hp)

end GodelSystem

/-! ## Part 8: The provability lattice (Knaster–Tarski fixed points) -/

/-- **Every monotone provability operator has a fixed point** (Knaster–Tarski). Reading a
    monotone `f : α → α` on a complete lattice as "close a theory under one round of
    inference", its fixed points are exactly the *deductively closed theories*, and at
    least one exists — a strange loop in the lattice of theories. -/
theorem provability_operator_has_fixed_point {α : Type*} [CompleteLattice α]
    (f : α → α) (hf : Monotone f) : ∃ x, f x = x :=
  ⟨OrderHom.lfp ⟨f, hf⟩, OrderHom.isFixedPt_lfp ⟨f, hf⟩⟩

/-- The least fixed point (the minimal deductively closed theory containing the axioms)
    lies below every pre-fixed point. -/
theorem lfp_le_prefixed {α : Type*} [CompleteLattice α]
    (f : α → α) (hf : Monotone f) {a : α} (ha : f a ≤ a) :
    OrderHom.lfp ⟨f, hf⟩ ≤ a :=
  OrderHom.lfp_le ⟨f, hf⟩ ha

/-- **A gap between least and greatest fixed points forces incompleteness.** If the least
    and greatest deductively closed theories differ, the least is strictly below the
    greatest: there are sentences true in the maximal consistent extension but absent from
    the provable core — true-but-unprovable statements at the lattice level. -/
theorem lfp_gfp_gap_incomplete {α : Type*} [CompleteLattice α]
    (f : α → α) (hf : Monotone f)
    (hgap : OrderHom.lfp ⟨f, hf⟩ ≠ OrderHom.gfp ⟨f, hf⟩) :
    OrderHom.lfp ⟨f, hf⟩ < OrderHom.gfp ⟨f, hf⟩ :=
  lt_of_le_of_ne (OrderHom.lfp_le_gfp ⟨f, hf⟩) hgap

/-! ## Axiom audit -/

#print axioms liar_paradox
#print axioms no_semantic_diagonal
#print axioms abstract_undecidable
#print axioms lawvere_fixed_point
#print axioms cantor_no_surjection
#print axioms tarski_truth_undefinable
#print axioms rice_trivial
#print axioms GodelSystem.inhabited
#print axioms GodelSystem.goedel_true_unprovable
#print axioms GodelSystem.goedel_undecidable
#print axioms GodelSystem.loeb_consistency_unprovable
#print axioms provability_operator_has_fixed_point
#print axioms lfp_gfp_gap_incomplete

end StrangeLoopsChain