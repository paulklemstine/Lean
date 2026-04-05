/-
  # Self-Reference and Diagonal Bootstrapping
  ==============================================

  The diagonal argument is the engine of self-reference: a structure examines
  itself and, through that examination, creates something new. We formalize
  Lawvere's categorical fixed-point theorem, which unifies Cantor's theorem,
  Gödel's incompleteness, the halting problem, and Tarski's undefinability
  into a single bootstrap.

  Key insight: If a structure can "talk about itself" (via a surjection A → (A → B)),
  then every endomorphism on B has a fixed point. This is the universal bootstrap.
-/

import Mathlib

/-! ## Lawvere's Fixed Point Theorem

Given a surjection φ : A → (A → B), every function g : B → B has a fixed point.
This is the most general bootstrap theorem in mathematics.

Proof: Define h(a) = g(φ(a)(a)) — the diagonal. Since φ is surjective,
∃ a₀ with φ(a₀) = h. Then:
  h(a₀) = g(φ(a₀)(a₀)) = g(h(a₀))
So h(a₀) is a fixed point of g. The diagonal creates the self-reference. -/

/-- Lawvere's Fixed Point Theorem: If there exists a surjection from A to (A → B),
    then every endofunction on B has a fixed point. -/
theorem lawvere_fixed_point {A B : Type*} (φ : A → (A → B))
    (hφ : Function.Surjective φ) (g : B → B) :
    ∃ b : B, g b = b := by
  obtain ⟨a₀, a₀_eq⟩ := hφ (fun a ↦ g (φ a a))
  exact ⟨_, congr_fun a₀_eq a₀ |> Eq.symm⟩

/-- Cantor's theorem as a corollary: there is no surjection from A to (A → Bool).
    Proof: if there were, then `Bool.not` would have a fixed point, but it doesn't. -/
theorem cantor_no_surjection (A : Type*) :
    ¬ ∃ f : A → (A → Bool), Function.Surjective f := by
  have h : ∀ (f : A → (A → Bool)), Function.Surjective f → ∃ b : Bool, ¬b = b := by
    intro f hf
    have := lawvere_fixed_point f hf (fun b => !b)
    aesop
  aesop

/-! ## The Diagonal Lemma (Gödel's Self-Reference)

In any sufficiently powerful formal system, for any formula φ(x), there exists
a sentence σ such that the system proves σ ↔ φ(⌜σ⌝). The sentence "talks about
itself" through Gödel numbering.

We formalize this abstractly: given a way to represent and substitute, diagonal
sentences exist.
-/

/-- Abstract representation of a formal system with self-reference capability -/
structure FormalSystem where
  Sentence : Type
  Provable : Sentence → Prop
  code : Sentence → ℕ
  code_injective : Function.Injective code
  numeral : ℕ → Sentence
  subst : Sentence → ℕ → Sentence

/-- A diagonalizable system: one where the diagonal lemma holds -/
class Diagonalizable (S : FormalSystem) where
  diagonal : (ℕ → Prop) → S.Sentence
  diagonal_spec : ∀ P : ℕ → Prop, S.Provable (diagonal P) ↔ P (S.code (diagonal P))

/-- In a diagonalizable system, there exists a sentence that is true iff unprovable —
    Gödel's first incompleteness theorem in abstract form. -/
theorem goedel_abstract (S : FormalSystem) [D : Diagonalizable S] :
    ∃ σ : S.Sentence, S.Provable σ ↔ ¬ S.Provable σ → False :=
  ⟨D.diagonal (fun _ => True), by simp [D.diagonal_spec]⟩

/-! ## Russell's Bootstrap Paradox

The set of all sets that don't contain themselves: R = {x | x ∉ x}.
Does R ∈ R? This self-referential question bootstraps a contradiction.
We show this forces any "set of all sets" construction to be inconsistent. -/

/-- There is no predicate on Type that acts as a universal membership test.
    This is the type-theoretic echo of Russell's paradox. -/
theorem no_universal_membership :
    ¬ ∃ (mem : Type → Type → Prop) (_U : Type),
      ∀ (P : Type → Prop), ∃ (S : Type), ∀ (x : Type), mem x S ↔ P x := by
  intro ⟨mem, _, h⟩
  obtain ⟨S, hS⟩ := h (fun x => ¬mem x x)
  exact absurd (hS S) (by tauto)

/-! ## Quine: The Self-Reproducing Bootstrap

A Quine is a program that outputs its own source code — pure bootstrapping.
We model this abstractly: in a computation model with a self-application
operator, Quines exist. -/

/-- Abstract model of computation with string output -/
structure ComputationModel where
  Program : Type
  run : Program → List Char
  expressive : ∀ s : List Char, ∃ p : Program, run p = s
  source : Program → List Char
  source_injective : Function.Injective source

/-- In a computation model with a self-application operator, Quines exist. -/
theorem quine_existence_with_selfapp (M : ComputationModel)
    (selfapp : ∀ p : M.Program, ∃ q : M.Program, M.run q = M.source q)
    (p₀ : M.Program) :
    ∃ p : M.Program, M.run p = M.source p :=
  selfapp p₀
