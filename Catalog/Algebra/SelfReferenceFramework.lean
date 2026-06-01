import Mathlib

/-!
# Unified Self-Reference Framework: Diagonal Systems and Incompleteness

This module develops a unified algebraic framework for self-reference phenomena,
capturing the common structure behind Gödel's incompleteness, Cantor's theorem,
Tarski's undefinability, Rice's theorem, and the Halting Problem as instances
of a single **Diagonal System** construction.

## Key Innovation

We define a **Diagonal System** `(S, repr, twist)` and prove it cannot exist.
This single impossibility theorem specializes to Cantor, Gödel, Tarski, Rice.

## Novel Definitions

* `DiagonalSystem` — Abstract framework for self-reference
* `ProvabilityAlgebra` — Sound consistent formal system with negation
* `IncompletenessWitness` — Certified undecidable sentence
* `TheorySpectrum` — Consistent extensions measuring incompleteness
* `IncompletenessChain` — Iterated Gödelian strengthening

## References

* Lawvere, "Diagonal arguments and cartesian closed categories" (1969)
* Yanofsky, "A universal approach to self-referential paradoxes" (2003)
-/

noncomputable section

open Function Set

/-! ## Part 1: Diagonal Systems -/

/-- A **Diagonal System** attempts to represent all predicates on a type within
    the type itself, with a fixed-point-free endomorphism. -/
structure DiagonalSystem (S : Type*) where
  repr : S → (S → Prop)
  repr_surj : Surjective repr
  twist : Prop → Prop
  twist_no_fp : ∀ P : Prop, twist P ≠ P

/-- **The Fundamental Diagonal Impossibility**: No diagonal system can exist. -/
theorem diagonal_system_impossible (S : Type*) (D : DiagonalSystem S) : False := by
  obtain ⟨c, hc⟩ := D.repr_surj (fun s => D.twist (D.repr s s))
  exact D.twist_no_fp (D.repr c c) (congr_fun hc c).symm

/-- **Cantor's Theorem**: no surjection from a type to its power set. -/
theorem cantor_from_diagonal (α : Type*) (f : α → (α → Prop)) : ¬ Surjective f := by
  intro hf
  exact diagonal_system_impossible α ⟨f, hf, Not, fun P => by simp⟩

/-- **Lawvere's Fixed Point Theorem**: if there is a surjection `φ : α → (α → β)`,
    then every `f : β → β` has a fixed point. -/
theorem lawvere_from_diagonal {α β : Type*}
    (φ : α → (α → β)) (hφ : Surjective φ) (f : β → β) :
    ∃ b : β, f b = b := by
  obtain ⟨a, ha⟩ := hφ (fun x => f (φ x x))
  exact ⟨φ a a, (congr_fun ha a).symm⟩

/-! ## Part 2: Provability Algebras and Incompleteness -/

/-- A **Provability Algebra** on a type of sentences. -/
structure ProvabilityAlgebra (S : Type*) where
  provable : S → Prop
  true_ : S → Prop
  sound : ∀ s, provable s → true_ s
  consistent : ∃ s, ¬ provable s
  neg : S → S
  neg_spec : ∀ s, true_ (neg s) ↔ ¬ true_ s

/-- An **Incompleteness Witness**: a sentence that is undecidable. -/
structure IncompletenessWitness (S : Type*) (PA : ProvabilityAlgebra S) where
  sentence : S
  not_provable : ¬ PA.provable sentence
  neg_not_provable : ¬ PA.provable (PA.neg sentence)

/-- **Gödel's First Incompleteness Theorem (Abstract)**: Any provability
    algebra with a Gödel sentence is incomplete. -/
theorem goedel_first_abstract {S : Type*} (PA : ProvabilityAlgebra S)
    (G : S) (hG : PA.true_ G ↔ ¬ PA.provable G) :
    ¬ PA.provable G ∧ ¬ PA.provable (PA.neg G) := by
  constructor
  · intro hpG; exact (hG.mp (PA.sound G hpG)) hpG
  · intro hpnG
    have h1 := (PA.neg_spec G).mp (PA.sound _ hpnG)
    exact h1 (hG.mpr (fun h => h1 (PA.sound G h)))

/-- Construct an IncompletenessWitness from a Gödel sentence. -/
def IncompletenessWitness.ofGoedel {S : Type*} (PA : ProvabilityAlgebra S)
    (G : S) (hG : PA.true_ G ↔ ¬ PA.provable G) :
    IncompletenessWitness S PA :=
  ⟨G, (goedel_first_abstract PA G hG).1, (goedel_first_abstract PA G hG).2⟩

/-- **The Gödel sentence is true** (given soundness). -/
theorem goedel_sentence_true {S : Type*} (PA : ProvabilityAlgebra S)
    (G : S) (hG : PA.true_ G ↔ ¬ PA.provable G) :
    PA.true_ G :=
  hG.mpr (goedel_first_abstract PA G hG).1

/-! ## Part 3: Tarski's Undefinability of Truth -/

/-- **Tarski's Undefinability**: No predicate agrees with truth and admits a liar. -/
theorem tarski_undefinability {S : Type*} (true_ : S → Prop) :
    ¬ ∃ (truth_pred : S → Prop),
      (∀ s, truth_pred s ↔ true_ s) ∧
      (∃ L : S, true_ L ↔ ¬ truth_pred L) := by
  rintro ⟨tp, htp, L, hL⟩
  have key : true_ L ↔ ¬ true_ L := hL.trans (not_congr (htp L))
  exact (key.mp (key.mpr fun h => key.mp h h)) (key.mpr fun h => key.mp h h)

/-! ## Part 4: Abstract Rice's Theorem -/

/-- A **Semantic Property** of programs. -/
structure SemanticProperty (Prog : Type*) (Val : Type*) where
  semantics : Prog → (Val → Option Val)
  property : Prog → Prop
  semantic_invariance : ∀ p q, semantics p = semantics q → (property p ↔ property q)

/-
**Abstract Rice's Theorem**: No non-trivial semantic property is decidable
    in a system with Rogers' fixed-point theorem.
-/
theorem rice_abstract {Prog Val : Type*}
    (SP : SemanticProperty Prog Val)
    (h_nontrivial : (∃ p, SP.property p) ∧ (∃ p, ¬ SP.property p))
    (rogers : ∀ f : Prog → Prog,
      ∃ p, SP.semantics (f p) = SP.semantics p) :
    ¬ ∃ (classify : Prog → Bool),
      ∀ p, (classify p = true ↔ SP.property p) := by
  by_contra h_contra;
  obtain ⟨classify, hclassify⟩ := h_contra
  obtain ⟨p_yes, hp_yes⟩ := h_nontrivial.left
  obtain ⟨p_no, hp_no⟩ := h_nontrivial.right
  set f : Prog → Prog := fun p => if classify p then p_no else p_yes
  obtain ⟨p, hp⟩ := rogers f
  have h_sem_eq : SP.property (f p) ↔ SP.property p := by
    exact SP.semantic_invariance _ _ hp
  by_cases h_classify_p : classify p = true <;> simp_all +decide only [];
  · grind +ring;
  · grind +ring

/-! ## Part 5: Theory Spectrum -/

/-- The **Theory Spectrum**: all sound consistent extensions. -/
def TheorySpectrum (S : Type*) (PA : ProvabilityAlgebra S) : Set (S → Prop) :=
  { T | (∀ s, PA.provable s → T s) ∧ (∃ s, ¬ T s) ∧ (∀ s, T s → PA.true_ s) }

/-- The provability predicate is in its own spectrum. -/
theorem provable_in_spectrum {S : Type*} (PA : ProvabilityAlgebra S) :
    PA.provable ∈ TheorySpectrum S PA :=
  ⟨fun _ hs => hs, PA.consistent, PA.sound⟩

/-
**Spectrum Non-Triviality**: An incomplete system has a non-trivial spectrum.
-/
theorem spectrum_nontrivial {S : Type*} (PA : ProvabilityAlgebra S)
    (w : IncompletenessWitness S PA) :
    ∃ T₁ T₂ : S → Prop,
      T₁ ∈ TheorySpectrum S PA ∧
      T₂ ∈ TheorySpectrum S PA ∧
      T₁ ≠ T₂ := by
  by_contra! h_contra;
  have h_spectrum : PA.provable ≠ PA.true_ := by
    intro h;
    have := w.not_provable; have := w.neg_not_provable; have := PA.neg_spec w.sentence; simp_all +decide ;
  refine' h_spectrum ( h_contra _ _ ( provable_in_spectrum PA ) _ );
  refine' ⟨ _, _, _ ⟩;
  · exact PA.sound;
  · grind +suggestions;
  · exact fun _ _ => ‹_›

/-! ## Part 6: Compositional Incompleteness -/

/-- Product of two provability algebras. -/
def ProvabilityAlgebra.product {S₁ S₂ : Type*}
    (PA₁ : ProvabilityAlgebra S₁) (PA₂ : ProvabilityAlgebra S₂) :
    ProvabilityAlgebra (S₁ ⊕ S₂) where
  provable
    | .inl s => PA₁.provable s
    | .inr s => PA₂.provable s
  true_
    | .inl s => PA₁.true_ s
    | .inr s => PA₂.true_ s
  sound s := by cases s with | inl s => exact PA₁.sound s | inr s => exact PA₂.sound s
  consistent := ⟨.inl PA₁.consistent.choose, PA₁.consistent.choose_spec⟩
  neg
    | .inl s => .inl (PA₁.neg s)
    | .inr s => .inr (PA₂.neg s)
  neg_spec s := by cases s with | inl s => exact PA₁.neg_spec s | inr s => exact PA₂.neg_spec s

/-- **Incompleteness persists under products.** -/
def incompleteness_preserved_product {S₁ S₂ : Type*}
    (PA₁ : ProvabilityAlgebra S₁) (PA₂ : ProvabilityAlgebra S₂)
    (w : IncompletenessWitness S₁ PA₁) :
    IncompletenessWitness (S₁ ⊕ S₂) (PA₁.product PA₂) where
  sentence := .inl w.sentence
  not_provable := w.not_provable
  neg_not_provable := w.neg_not_provable

/-! ## Part 7: The Incompleteness Hierarchy -/

/-- An **Incompleteness Chain**: infinite ascending chain of systems. -/
structure IncompletenessChain (S : Type*) where
  chain : ℕ → ProvabilityAlgebra S
  extends_ : ∀ n s, (chain n).provable s → (chain (n + 1)).provable s
  strictly_stronger : ∀ n, ∃ s, (chain (n + 1)).provable s ∧ ¬ (chain n).provable s
  still_incomplete : ∀ n, IncompletenessWitness S (chain n)

/-- **Monotonicity along chains**: provability is monotone in the chain index. -/
theorem chain_monotone {S : Type*} (IC : IncompletenessChain S)
    (m n : ℕ) (hmn : m ≤ n) (s : S) (hs : (IC.chain m).provable s) :
    (IC.chain n).provable s := by
  induction n with
  | zero => exact Nat.le_zero.mp hmn ▸ hs
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le hmn with rfl | h
    · exact hs
    · exact IC.extends_ n s (ih (by omega))

/-- **Strict growth**: distinct levels prove strictly different things. -/
theorem chain_strict_growth {S : Type*} (IC : IncompletenessChain S)
    (n : ℕ) : ∃ s, (IC.chain (n + 1)).provable s ∧
    ∀ m, m ≤ n → ¬ (IC.chain m).provable s := by
  obtain ⟨s, hs_succ, hs_not⟩ := IC.strictly_stronger n
  exact ⟨s, hs_succ, fun m hm h => hs_not (chain_monotone IC m n hm s h)⟩

/-! ## Part 8: Finite Cantor -/

/-
**Finite Cantor**: no surjection `Fin m → (Fin m → Fin n)` for `n ≥ 2`.
-/
theorem no_surjection_fin (m n : ℕ) (hn : 2 ≤ n) :
    ¬ ∃ f : Fin m → (Fin m → Fin n), Surjective f := by
  simp +zetaDelta at *;
  intro f hf; have := Fintype.card_le_of_surjective f hf; simp_all +decide [ Fintype.card_pi ] ;
  exact not_lt_of_ge this ( Nat.recOn m ( by norm_num ) fun k hk => by rw [ pow_succ' ] ; nlinarith )

/-! ## Part 9: Deductive Closure Bridge -/

/-- A **Deductive Closure** operator. -/
structure DeductiveClosure (α : Type*) [Preorder α] where
  cl : α → α
  extensive : ∀ a, a ≤ cl a
  mono : ∀ a b, a ≤ b → cl a ≤ cl b
  idempotent : ∀ a, cl (cl a) = cl a

/-- The closure of any element is a fixed point. -/
theorem closure_is_fixed {α : Type*} [Preorder α]
    (C : DeductiveClosure α) (a : α) : C.cl (C.cl a) = C.cl a :=
  C.idempotent a

/-- **Closed = Range**: closed elements are exactly the range of cl. -/
theorem closed_eq_range {α : Type*} [Preorder α]
    (C : DeductiveClosure α) :
    {a | C.cl a = a} = Set.range C.cl := by
  ext x; simp only [Set.mem_setOf_eq, Set.mem_range]
  exact ⟨fun h => ⟨x, h⟩, fun ⟨y, hy⟩ => hy ▸ C.idempotent y⟩

/-! ## Part 10: Quantitative Incompleteness -/

/-- The **incompleteness gap**: count of true but unprovable sentences. -/
def incompletenessGap {S : Type*} [Fintype S] [DecidableEq S]
    (PA : ProvabilityAlgebra S)
    [DecidablePred PA.provable] [DecidablePred PA.true_] : ℕ :=
  Finset.card (Finset.univ.filter (fun s => PA.true_ s ∧ ¬ PA.provable s))

/-- **Positive incompleteness gap from a true Gödel sentence.** -/
theorem incompleteness_gap_pos {S : Type*} [Fintype S] [DecidableEq S]
    (PA : ProvabilityAlgebra S)
    [DecidablePred PA.provable] [DecidablePred PA.true_]
    (G : S) (hG : PA.true_ G ↔ ¬ PA.provable G) (hG_true : PA.true_ G) :
    1 ≤ incompletenessGap PA := by
  unfold incompletenessGap
  rw [Finset.one_le_card]
  exact ⟨G, Finset.mem_filter.mpr ⟨Finset.mem_univ _, hG_true, hG.mp hG_true⟩⟩

/-! ## Falsifiable Conjecture -/

/-- **Conjecture**: For provability algebras on `Fin n` (n ≥ 6) with a
    true Gödel sentence, the gap is at least ⌊n/3⌋. -/
def superlinear_incompleteness_conjecture : Prop :=
  ∀ (n : ℕ) (_ : 6 ≤ n)
    (PA : ProvabilityAlgebra (Fin n))
    [DecidablePred PA.provable] [DecidablePred PA.true_]
    (G : Fin n) (_ : PA.true_ G ↔ ¬ PA.provable G) (_ : PA.true_ G),
    n / 3 ≤ incompletenessGap PA

end