/-! # CatalogBuild.Speculative.Millennium.PvsNP

Auto-generated from theorem catalog database.
Domain: Speculative/Millennium
Declarations: 7
-/

import Mathlib

/-- A decision problem is a subset of binary strings (modeled as lists of Bool). -/
def DecisionProblem := List Bool → Prop


/-- A witness-based problem: given input x, witness w proves x is a "yes" instance. -/
structure WitnessProblem where
  /-- The language: which inputs are "yes" instances -/
  language : List Bool → Prop
  /-- The verification relation: w is a valid witness for x -/
  verify : List Bool → List Bool → Prop
  /-- Soundness: if there is a valid witness, x is in the language -/
  sound : ∀ x w, verify x w → language x
  /-- Completeness: if x is in the language, there exists a valid witness -/
  complete : ∀ x, language x → ∃ w, verify x w


/-- NP problems have polynomially-bounded witnesses. -/
structure NPProblem extends WitnessProblem where
  /-- There is a polynomial bound on witness length -/
  witnessBound : ∃ (c : ℕ), ∀ x, language x →
    ∃ w, verify x w ∧ w.length ≤ x.length ^ c + c


/-- [Section: # P vs NP — Formal Foundations
We formalize key concepts related to computational complexity theory,
including basic results about polynomial-time verification and search.
While the P vs NP problem itself remains open, we can formally verify
foundational results that any resolution must build upon.] -/
theorem witness_enumeration_finite (n k : ℕ) :
    Finite {w : List Bool | w.length ≤ k} := by
  -- The set of all binary strings of length up to $k$ is finite because there are only $2^k$ possible strings.
  have h_finite_strings : Set.Finite {w : List Bool | w.length ≤ k} := by
    exact?
  exact h_finite_strings.to_subtype


theorem binary_strings_count (n : ℕ) :
    Fintype.card (Fin n → Bool) = 2 ^ n := by
  norm_num +zetaDelta at *


theorem poly_compose (p q : Polynomial ℕ) :
    ∃ r : Polynomial ℕ, ∀ n : ℕ, p.eval (q.eval n) ≤ r.eval n := by
  use p.comp q;
  aesop


theorem brute_force_decides {α : Type*} [Fintype α] [DecidableEq α]
    (P : α → Prop) [DecidablePred P] :
    (∃ x, P x) ∨ (∀ x, ¬P x) := by
  exact Classical.or_iff_not_imp_left.2 fun h => by push_neg at h; exact h;
