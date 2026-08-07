/-
# Computable-Bound Escape for Shortest Proofs

This file settles, for a concrete and fully general notion of *proof system*, Future
Direction 1 of the "Proof Complexity and Thermodynamic Cost" thread: **no computable
function uniformly bounds shortest-proof cost.**

## Set-up

A *budget verifier* on a type of statements `α` is a decidable relation
`V : α → ℕ → Bool`, where `V s b = true` means "a proof of `s` is found within budget
`b`".  Every realistic proof system induces such a verifier: enumerate candidate proofs
in length order and let `b` be the number of candidates inspected (or the length bound,
or the number of inference steps).  The only structural property we use is
`Cumulative`: increasing the budget never loses a proof.

The **shortest-proof cost** of `s` is `proofCost V s = sInf {b | V s b}`, the least
budget at which a proof appears.

## Main results

* `provable_iff_verifier_bound` — a cumulative verifier with a bounding function `B`
  collapses the unbounded search `∃ b, V s b` into the single test `V s (B s)`.
* `computablePred_provable_of_computable_bound` — **bounded ⇒ decidable**: if `V` and a
  bound `B` are computable, provability is a decidable predicate.
* `haltVerifier` — the concrete proof system: `s` is the code of a partial recursive
  program, and `V s k` says "the program halts on input `n` within `k` steps"
  (`Nat.Partrec.Code.evaln`).  It is cumulative (`haltVerifier_cumulative`), computable
  (`computable₂_haltVerifier`), and *sound and complete* for halting
  (`provable_haltVerifier_iff`).
* `no_computable_bound` — **main theorem**: for this system no computable `B` bounds
  `proofCost` on provable statements.  Equivalently
  (`shortest_proof_escapes_computable_bound`): *every* computable `B` is escaped —
  some theorem needs strictly more search than `B` predicts.
* `escape_set_infinite` — the escape is not sporadic: the set of theorems escaping a
  fixed computable bound is infinite (a finite exceptional set could be absorbed into a
  computable additive correction).
* `proofCost_unbounded` — in particular shortest-proof cost is unbounded, and no
  constant works.
* `no_computable_bound_of_undecidable` — the abstract principle behind the main theorem:
  cumulative computable verifier + undecidable provability ⇒ no computable bound.
* `proofCost_not_computable` — shortest-proof cost is itself not a computable function.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the counting/pigeonhole obstruction of `ChaitinBerry` should upgrade
  to a *recursion-theoretic* obstruction once the verifier is required to be computable:
  a computable bound would convert the Σ₁ predicate "provable" into a Δ₀ test.
Experiment (Stage 2): formalised budget verifiers, proved the collapse
  `Provable s ↔ V s (B s)` (this is where `Cumulative` is load-bearing), and instantiated
  with Kleene's step-indexed evaluator `evaln`, whose halting predicate is undecidable.
Analysis (Stage 3): the proof needs *no* diagonalisation of its own — the diagonal is
  imported wholesale from `ComputablePred.halting_problem`.  What the formalisation
  isolates is the exact interface a proof system must satisfy for the argument to run:
  cumulativity + computability of the verifier.  Dropping cumulativity breaks
  `provable_iff_verifier_bound` (one would need a bounded search instead, which is still
  computable but requires extra machinery); dropping computability of `B` makes the
  statement false, since `proofCost` itself is a (non-computable) bound.
Critique (Stage 4): the theorem is not vacuous — `haltVerifier` is an explicit verifier,
  `proofCost` is finite on every provable statement (`verify_proofCost`), and the
  *non-computable* bound `proofCost` itself shows the hypothesis `Computable B` cannot be
  dropped (`noncomputable_bound_exists`).
Synthesis (Stage 5): "shortest-proof complexity escapes every computable bound" is the
  recursion-theoretic completion of the finite scarcity axiom used in the thermodynamic
  ensemble theorems: the search cost of proof is not merely large, it is not even
  computably estimable.
-/
import Mathlib

open Nat.Partrec Nat.Partrec.Code

namespace ShortestProofEscape

variable {α : Type}

/-- A **budget verifier**: `V s b = true` means a proof of statement `s` is found within
search budget `b`. -/
abbrev BudgetVerifier (α : Type) := α → ℕ → Bool

/-- Increasing the budget never destroys a proof. -/
def Cumulative (V : BudgetVerifier α) : Prop :=
  ∀ s b b', b ≤ b' → V s b = true → V s b' = true

/-- `s` is provable if some finite budget suffices. -/
def Provable (V : BudgetVerifier α) (s : α) : Prop := ∃ b, V s b = true

/-- **Shortest-proof cost**: the least budget at which a proof of `s` appears
(`0` by convention when `s` is unprovable). -/
noncomputable def proofCost (V : BudgetVerifier α) (s : α) : ℕ := sInf {b | V s b = true}

/-- The shortest budget really does verify a provable statement. -/
theorem verify_proofCost {V : BudgetVerifier α} {s : α} (h : Provable V s) :
    V s (proofCost V s) = true :=
  Nat.sInf_mem h

/-- Minimality of the shortest-proof cost. -/
theorem proofCost_le {V : BudgetVerifier α} {s : α} {b : ℕ} (h : V s b = true) :
    proofCost V s ≤ b :=
  Nat.sInf_le h

/-- A function `B` is a **uniform bound** for `V` if every theorem is found within budget
`B s`. -/
def IsBound (V : BudgetVerifier α) (B : α → ℕ) : Prop :=
  ∀ s, Provable V s → proofCost V s ≤ B s

/-- **Collapse of the search.**  For a cumulative verifier, a uniform bound turns the
unbounded search `∃ b, V s b` into the single test `V s (B s)`. -/
theorem provable_iff_verifier_bound {V : BudgetVerifier α} (hV : Cumulative V) {B : α → ℕ}
    (hB : IsBound V B) (s : α) : Provable V s ↔ V s (B s) = true := by
  constructor
  · intro h
    exact hV s _ _ (hB s h) (verify_proofCost h)
  · intro h
    exact ⟨B s, h⟩

/-- **Bounded implies decidable.**  If a cumulative verifier is computable and admits a
computable uniform bound, then provability is a decidable predicate. -/
theorem computablePred_provable_of_computable_bound [Primcodable α] {V : BudgetVerifier α}
    (hcum : Cumulative V) (hVc : Computable₂ V) {B : α → ℕ} (hBc : Computable B)
    (hB : IsBound V B) : ComputablePred (Provable V) := by
  rw [ComputablePred.computable_iff]
  refine ⟨fun s => V s (B s), hVc.comp Computable.id hBc, ?_⟩
  funext s
  simpa using propext (provable_iff_verifier_bound hcum hB s)

/-- **General form of the escape principle.**  For any cumulative computable verifier whose
provability predicate is undecidable, no computable uniform bound on shortest-proof cost can
exist. -/
theorem no_computable_bound_of_undecidable [Primcodable α] {V : BudgetVerifier α}
    (hcum : Cumulative V) (hVc : Computable₂ V)
    (hund : ¬ ComputablePred (Provable V)) :
    ¬ ∃ B : α → ℕ, Computable B ∧ IsBound V B := by
  rintro ⟨B, hBc, hB⟩
  exact hund (computablePred_provable_of_computable_bound hcum hVc hBc hB)

/-! ## A concrete proof system: bounded halting -/

/-- The concrete budget verifier: statements are codes of partial recursive programs, and
`haltVerifier n c k` says that program `c` produces an output on input `n` within `k`
steps of Kleene's step-indexed evaluator. -/
def haltVerifier (n : ℕ) : BudgetVerifier Code := fun c k => (evaln k c n).isSome

theorem haltVerifier_cumulative (n : ℕ) : Cumulative (haltVerifier n) := by
  intro c k k' hk h
  unfold haltVerifier at h ⊢
  rcases hx : evaln k c n with _ | x
  · rw [hx] at h; simp at h
  · have : x ∈ evaln k' c n := evaln_mono hk (by rw [hx]; rfl)
    rw [Option.mem_def] at this
    rw [this]
    rfl

theorem computable₂_haltVerifier (n : ℕ) : Computable₂ (haltVerifier n) := by
  have h : Primrec₂ fun (c : Code) (k : ℕ) => evaln k c n :=
    Primrec.comp₂ primrec_evaln
      (Primrec₂.pair.comp₂ (Primrec₂.pair.comp₂ Primrec₂.right Primrec₂.left)
        (Primrec₂.const n))
  exact (Primrec.option_isSome.comp h).to_comp

/-- **Soundness and completeness** of the concrete system: `c` is provable exactly when
the program `c` halts on `n`. -/
theorem provable_haltVerifier_iff (n : ℕ) (c : Code) :
    Provable (haltVerifier n) c ↔ (eval c n).Dom := by
  constructor
  · rintro ⟨k, hk⟩
    unfold haltVerifier at hk
    obtain ⟨x, hx⟩ := Option.isSome_iff_exists.1 hk
    have : x ∈ eval c n := evaln_sound (by rw [hx]; rfl)
    exact Part.dom_iff_mem.2 ⟨x, this⟩
  · intro h
    obtain ⟨x, hx⟩ : ∃ x, x ∈ eval c n := ⟨_, Part.get_mem h⟩
    obtain ⟨k, hk⟩ := evaln_complete.1 hx
    refine ⟨k, ?_⟩
    unfold haltVerifier
    rw [Option.mem_def] at hk
    rw [hk]
    rfl

/-- **Main theorem (computable-bound escape).**  For the bounded-halting proof system there
is *no* computable function uniformly bounding shortest-proof cost.  A computable bound
would decide the halting problem. -/
theorem no_computable_bound (n : ℕ) :
    ¬ ∃ B : Code → ℕ, Computable B ∧ IsBound (haltVerifier n) B := by
  rintro ⟨B, hBc, hB⟩
  have hdec : ComputablePred (Provable (haltVerifier n)) :=
    computablePred_provable_of_computable_bound (haltVerifier_cumulative n)
      (computable₂_haltVerifier n) hBc hB
  have hEq : Provable (haltVerifier n) = fun c => (eval c n).Dom := by
    funext c; exact propext (provable_haltVerifier_iff n c)
  rw [hEq] at hdec
  exact ComputablePred.halting_problem n hdec

/-- **Escape, stated positively.**  Every computable candidate bound is beaten by some
theorem: shortest-proof cost outruns all computable estimates. -/
theorem shortest_proof_escapes_computable_bound (n : ℕ) (B : Code → ℕ) (hBc : Computable B) :
    ∃ c : Code, Provable (haltVerifier n) c ∧ B c < proofCost (haltVerifier n) c := by
  by_contra h
  push_neg at h
  exact no_computable_bound n ⟨B, hBc, fun c hc => h c hc⟩

/-- The escape set of a computable bound. -/
def EscapeSet (n : ℕ) (B : Code → ℕ) : Set Code :=
  {c | Provable (haltVerifier n) c ∧ B c < proofCost (haltVerifier n) c}

/-- **The escape is not sporadic.**  For every computable bound the set of theorems whose
shortest proof exceeds the bound is infinite: a finite escape set could be absorbed by
adding a constant, producing a computable bound and contradicting `no_computable_bound`. -/
theorem escape_set_infinite (n : ℕ) (B : Code → ℕ) (hBc : Computable B) :
    (EscapeSet n B).Infinite := by
  intro hfin
  -- a uniform correction for the finitely many exceptions
  obtain ⟨K, hK⟩ : ∃ K, ∀ c ∈ EscapeSet n B, proofCost (haltVerifier n) c ≤ K := by
    have : (proofCost (haltVerifier n) '' EscapeSet n B).Finite := hfin.image _
    obtain ⟨K, hKmem⟩ := this.bddAbove
    exact ⟨K, fun c hc => hKmem ⟨c, hc, rfl⟩⟩
  have hadd : Computable₂ (fun a b : ℕ => a + b) := Primrec₂.to_comp Primrec.nat_add
  have hB'c : Computable (fun c => B c + K) := hadd.comp hBc (Computable.const K)
  refine no_computable_bound n ⟨fun c => B c + K, hB'c, ?_⟩
  intro c hc
  by_cases hce : c ∈ EscapeSet n B
  · exact le_trans (hK c hce) (Nat.le_add_left _ _)
  · simp only [EscapeSet, Set.mem_setOf_eq, not_and, not_lt] at hce
    exact le_trans (hce hc) (Nat.le_add_right _ _)

/-- Shortest-proof cost is in particular unbounded: no constant bounds it. -/
theorem proofCost_unbounded (n : ℕ) (m : ℕ) :
    ∃ c : Code, Provable (haltVerifier n) c ∧ m < proofCost (haltVerifier n) c :=
  shortest_proof_escapes_computable_bound n (fun _ => m) (Computable.const m)

/-- **Non-vacuity / sharpness.**  A *non-computable* uniform bound always exists — namely
`proofCost` itself.  So the computability hypothesis in `no_computable_bound` carries the
whole content of the theorem. -/
theorem noncomputable_bound_exists (n : ℕ) :
    IsBound (haltVerifier n) (proofCost (haltVerifier n)) :=
  fun _ _ => le_rfl

/-- **Shortest-proof cost is not computable.**  It is its own uniform bound
(`noncomputable_bound_exists`), so if it were computable the escape theorem would fail. -/
theorem proofCost_not_computable (n : ℕ) :
    ¬ Computable (proofCost (haltVerifier n)) := by
  intro hc
  exact no_computable_bound n ⟨_, hc, noncomputable_bound_exists n⟩

end ShortestProofEscape