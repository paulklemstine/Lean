/-
# Proof Phase Transitions II: Completeness of the Barrier Method and the
  Derivability Closure Operator

This module **extends** `Catalog/Logic/ProofPhaseTransitions.lean`.  That file modelled an
*implicational theory* as a binary relation `ImplTheory α := α → α → Prop` and *derivability*
as its reflexive–transitive closure (`Derivable T := ReflTransGen T`), and isolated the
*barrier / invariant-cut lemma* `refl_trans_gen_closed` as the universal certificate for
**non**-derivability.  Here we close the loop on that program:

* `Closed` — the notion of a set closed under the axioms of a theory.
* `derivable_iff_forall_closed` — **soundness *and* completeness of the barrier method.**
  `a` derives `b` *iff* `b` lies in every axiom-closed set containing `a`.  The `→`
  direction is the catalog's `refl_trans_gen_closed`; the `←` direction (completeness) is
  new: the derivable-set is itself closed, so it is the *least* closed set containing the
  source.  This is the universal property of `ReflTransGen` as a closure.
* `not_derivable_iff_exists_barrier` — the **complete non-derivability certificate** (an
  LP-duality / Menger-flavoured statement): `a` fails to derive `b` *iff* there is an
  explicit closed "barrier" set separating them.  Every true non-derivability has a finite
  reason of exactly the shape the catalog's barrier proofs used by hand.
* `Cl`, `subset_cl`, `cl_mono`, `cl_idem` — derivability induces a **Kuratowski-style
  closure operator** on sets of atoms: extensive, monotone, and **idempotent**.
  Idempotence is precisely transitivity of derivation, packaged as `Cl ∘ Cl = Cl`.
* `chainSeg`, `chainSeg_isChain`, `chainSeg_length` — a **constructive** generalization of
  the catalog's `chainPath`: the explicit derivation `a → a+1 → ⋯ → a+n` as a concrete list,
  for *every* source `a`, of length exactly `n+1`.
* `chain_derivable_iff`, `instDecidableDerivableChainT`, `chain_decide_example` — derivability
  in the chain theory is **decidable** and computes by `decide`, anchoring the program in
  effective computation.

-- !-- Lab Notebook -- !--
-- Hypothesis: The catalog's barrier lemma `refl_trans_gen_closed` is only the *soundness*
--   half of a duality. Its converse should hold — the derivable set is itself axiom-closed —
--   yielding a completeness theorem: derivability = membership in every closed superset of
--   the source. This would make non-derivability certificates (closed barriers) complete,
--   and reveal derivability as the least-closed-set (Kuratowski) closure operator.
-- Result: Both halves formalize. `derivable_iff_forall_closed` packages soundness
--   (`refl_trans_gen_closed`) with completeness (instantiate the universal at the derivable
--   set, which is closed by `ReflTransGen.tail`). `not_derivable_iff_exists_barrier` is the
--   contrapositive via `push_neg`/`grind`. The closure operator `Cl` is extensive (refl),
--   monotone, and idempotent (`ReflTransGen.trans`). The chain witness generalizes to any
--   source `a`, and the chain boundary is decidable, so derivability runs under `decide`.
-- Insight: The single fact "the conclusion-set of a fixed source is axiom-closed" is the
--   hinge: it gives completeness of the barrier method AND idempotence of the closure
--   operator. Phase-transition / non-derivability arguments thus *never lose information* by
--   restricting to closed-set (potential-function) certificates — they are complete.
-- Failure analysis: The subagent's `aesop`/`grind` closed the duality directly; an earlier
--   manual route needed `Set.mem_setOf_eq` unfolds before `exact`/`omega` since the
--   conclusion-set and chain cut are `setOf`. For `chainSeg` the `· + a` map shifts the base
--   point; `List.getElem_map` + `List.getElem_range` reduce the chain condition to `omega`.
-- !-- end Lab Notebook -- !--
-/
import Mathlib

open Relation

namespace ProofPhaseTransitionsII

/-- An **implicational theory** on atoms `α` (mirrors the catalog `ProofPhaseTransitions`). -/
abbrev ImplTheory (α : Type*) := α → α → Prop

/-- **Derivability**: reflexive–transitive closure of the axiom relation (catalog
`ProofPhaseTransitions.Derivable`). -/
def Derivable {α : Type*} (T : ImplTheory α) : α → α → Prop := ReflTransGen T

/-- A set `S` is **closed** under the axioms of `T` if every axiom out of a member of `S`
lands back in `S`. This is the hypothesis of the catalog's `refl_trans_gen_closed`. -/
def Closed {α : Type*} (T : ImplTheory α) (S : Set α) : Prop :=
  ∀ x ∈ S, ∀ y, T x y → y ∈ S

-- !-- Soundness is the catalog barrier lemma `refl_trans_gen_closed` (induction on
-- ReflTransGen); completeness instantiates the universal at the conclusion-set
-- `{x | Derivable T a x}`, which is closed by `ReflTransGen.tail`. -- !--
/-- **Completeness of the barrier method.** `a` derives `b` *iff* `b` belongs to every
axiom-closed set containing `a`. Equivalently, the set of conclusions of `a` is the *least*
closed set containing `a` — the universal property of `ReflTransGen` as a closure. -/
theorem derivable_iff_forall_closed {α} (T : ImplTheory α) (a b : α) :
    Derivable T a b ↔ ∀ S : Set α, a ∈ S → Closed T S → b ∈ S := by
  refine ⟨fun h S ha hS => ?_, fun h => ?_⟩
  · induction h <;> aesop
  · exact h _ ReflTransGen.refl fun x hx y hy => ReflTransGen.tail hx hy

-- !-- Contrapositive of completeness via `push_neg`: a complete, explicit certificate for
-- non-derivability, generalizing the catalog's hand-built barrier cuts. -- !--
/-- **Complete non-derivability certificate.** `a` fails to derive `b` *iff* there is a
closed "barrier" set containing `a` but not `b`. Every non-derivability has a witnessing
invariant cut. -/
theorem not_derivable_iff_exists_barrier {α} (T : ImplTheory α) (a b : α) :
    ¬ Derivable T a b ↔ ∃ S : Set α, a ∈ S ∧ Closed T S ∧ b ∉ S := by
  rw [derivable_iff_forall_closed]
  push_neg
  rfl

/-! ### The derivability closure operator -/

/-- The **derivability closure** of a set `A`: all atoms derivable from some member of `A`. -/
def Cl {α : Type*} (T : ImplTheory α) (A : Set α) : Set α := {b | ∃ a ∈ A, Derivable T a b}

-- !-- Extensivity: every point derives itself (`ReflTransGen.refl`). -- !--
/-- The closure operator is **extensive**: `A ⊆ Cl T A`. -/
theorem subset_cl {α} (T : ImplTheory α) (A : Set α) : A ⊆ Cl T A :=
  fun x hx => ⟨x, hx, ReflTransGen.refl⟩

-- !-- Monotonicity: a witness in `A` is a witness in `B`. -- !--
/-- The closure operator is **monotone**. -/
theorem cl_mono {α} (T : ImplTheory α) {A B : Set α} (h : A ⊆ B) : Cl T A ⊆ Cl T B :=
  fun _ hx => by obtain ⟨a, ha, hx⟩ := hx; exact ⟨a, h ha, hx⟩

-- !-- Idempotence IS transitivity of derivation: chaining a derivation from `A` to the
-- closure with one from the closure to `b` (`ReflTransGen.trans`). -- !--
/-- The closure operator is **idempotent**: `Cl T (Cl T A) = Cl T A`. Derivability therefore
defines a Kuratowski-style closure operator, with idempotence packaging transitivity. -/
theorem cl_idem {α} (T : ImplTheory α) (A : Set α) : Cl T (Cl T A) = Cl T A := by
  refine le_antisymm ?_ ?_ <;> intro x hx <;> rcases hx with ⟨y, hy, hy'⟩
  · rcases hy with ⟨z, hz, hz'⟩; exact ⟨z, hz, hz'.trans hy'⟩
  · exact ⟨y, ⟨y, hy, ReflTransGen.refl⟩, hy'⟩

/-! ### Constructive generalized chain witness and decidability -/

/-- The **chain theory** on `ℕ`: axioms `k → k+1` (catalog `chainT`). -/
def chainT : ImplTheory ℕ := fun a b => b = a + 1

/-- The explicit derivation segment `a → a+1 → ⋯ → a+n`, as a concrete list. Generalizes the
catalog's `chainPath`: `chainPath n = chainSeg 0 n`. -/
def chainSeg (a n : ℕ) : List ℕ := (List.range (n + 1)).map (· + a)

-- !-- Consecutive entries of `chainSeg` differ by one: `getElem_map`/`getElem_range` reduce
-- the chain condition to arithmetic. -- !--
/-- `chainSeg a n` is a genuine chain for the chain axiom relation, from any source `a`. -/
theorem chainSeg_isChain (a n : ℕ) :
    List.IsChain (fun x y => y = x + 1) (chainSeg a n) := by
  simp +arith +decide [chainSeg, List.isChain_iff_getElem]

-- !-- `length_map` + `length_range` collapse to `n+1`. -- !--
/-- The constructive derivation from `a` to `a+n` has length exactly `n+1`. -/
theorem chainSeg_length (a n : ℕ) : (chainSeg a n).length = n + 1 := by
  simp [chainSeg]

-- !-- Forward by induction on the derivation (each axiom step adds one); backward by
-- induction on `b`, extending shorter derivations (catalog `chain_derivable_iff`). -- !--
/-- **Sharp boundary** for the chain theory: `a` derives `b` iff `a ≤ b` (catalog
`chain_derivable_iff`, re-established here to power decidability). -/
theorem chain_derivable_iff (a b : ℕ) : Derivable chainT a b ↔ a ≤ b := by
  constructor
  · intro h
    induction' h with x hx y hy ih
    · rfl
    · exact ih.trans (hy.symm ▸ Nat.le_succ _)
  · induction' b with b ih
    · exact fun h => by cases a <;> tauto
    · exact fun h => if h' : a ≤ b then (ih h').tail (by tauto)
        else by rw [show a = b + 1 by linarith]; exact ReflTransGen.refl

/-- Derivability in the chain theory is **decidable** and computes by `decide`. -/
instance instDecidableDerivableChainT (a b : ℕ) : Decidable (Derivable chainT a b) :=
  decidable_of_iff _ (chain_derivable_iff a b).symm

/-- Effective check: `2` derives `7` in the chain theory, verified by `decide`. -/
theorem chain_decide_example : Derivable chainT 2 7 := by decide

end ProofPhaseTransitionsII