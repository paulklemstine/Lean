/-
# Proof Phase Transitions: Implicational Theories as Monotone Reachability

This module lays the *formal infrastructure* underpinning the program of "proof phase
transitions" for random implicational theories.  An **implicational theory** on a type
of atoms `α` is a set of single-conclusion axioms `a → b`, modelled as a binary relation
`ImplTheory α := α → α → Prop`.  **Derivability** is the reflexive–transitive closure of
the axiom relation — i.e. exactly graph reachability in the directed graph of axioms.

The headline structural facts proved here are:

* `theory_extension_monotone` / `derivable_monotone` — derivability is a **monotone**
  property of the axiom set.  This is the precise hypothesis required by Friedgut's sharp
  threshold theorem: `fun T => Derivable T a b` is a monotone Boolean function on the
  hypercube of potential edges.
* `refl_trans_gen_closed` — the **barrier method**: any set closed under the axioms and
  containing the source contains every derivable conclusion.  This is the canonical tool
  for proving *non*-derivability.
* `chain_derivable_iff` — a sharp **boundary characterization** for the linear chain
  theory: in `chainT` (the axioms `k → k+1`), `a` derives `b` iff `a ≤ b`.
* `chain_axiom_critical` — every axiom of a minimal (chain) theory is **critical**:
  deleting a single axiom destroys a derivation, while the full theory still derives it
  (`chain_axiom_restorable`).
* `chainPath_chain` / `chainPath_length` — a **constructive** witness: the explicit
  derivation `0 → 1 → ⋯ → n` of length `n`, realising the derivation as a concrete list.

-- !-- Lab Notebook -- !--
-- Hypothesis: Single-conclusion implicational derivability is *definitionally* reflexive–
--   transitive closure, hence a monotone graph-reachability property; the whole "phase
--   transition" narrative should rest on (a) monotonicity and (b) a barrier (closure)
--   lemma for non-derivability, with chains as the extremal minimal-density witnesses.
-- Result: All five pillars formalize cleanly. Monotonicity is `ReflTransGen.mono`; the
--   barrier lemma is a one-line induction on `ReflTransGen`; the chain boundary is a tight
--   iff; criticality and constructive length both follow from the barrier/chain machinery.
-- Insight: The barrier lemma `refl_trans_gen_closed` is the single reusable engine — both
--   "no backward derivation" and "deleted axiom blocks the proof" are instances of picking
--   the right closed set (`{k | a ≤ k}` resp. `{k | k ≤ m}`). Non-derivability proofs
--   reduce to exhibiting an invariant cut, exactly mirroring potential-function arguments.
-- Failure analysis: Initial `omega` calls failed because the edge relation `chainT x y`
--   was not unfolded in the closure hypothesis; `simp only [chainT]` before `omega` fixes
--   it. `List.Chain'` is deprecated in this toolchain — `List.IsChain` +
--   `List.isChain_iff_getElem` is the current API for the constructive path witness.
-- !-- end Lab Notebook -- !--
-/
import Mathlib

open Relation

namespace ProofPhaseTransitions

/-- An **implicational theory** on atoms of type `α`: the set of single-conclusion axioms
`a → b`, encoded as a binary relation. -/
abbrev ImplTheory (α : Type*) := α → α → Prop

/-- **Derivability** in a theory `T`: the reflexive–transitive closure of the axiom
relation. Equivalently, reachability in the directed graph whose edges are the axioms. -/
def Derivable {α : Type*} (T : ImplTheory α) : α → α → Prop := ReflTransGen T

/-- Reflexivity of derivability (the empty derivation). -/
theorem derivable_refl {α} (T : ImplTheory α) (a : α) : Derivable T a a := ReflTransGen.refl

/-- Transitivity of derivability (concatenation of derivations). -/
theorem derivable_trans {α} (T : ImplTheory α) {a b c}
    (h₁ : Derivable T a b) (h₂ : Derivable T b c) : Derivable T a c := h₁.trans h₂

/-- A single axiom yields a one-step derivation. -/
theorem derivable_of_axiom {α} (T : ImplTheory α) {a b} (h : T a b) : Derivable T a b :=
  ReflTransGen.single h

-- !-- Monotonicity: enlarging the axiom set can only enlarge the set of derivable pairs;
-- this is `ReflTransGen.mono`, the exact hypothesis Friedgut's sharp-threshold theorem
-- requires of a monotone Boolean function on the edge hypercube. -- !--
/-- **Theory extension monotonicity.** If every axiom of `T` is an axiom of `T'`, then
everything derivable in `T` is derivable in `T'`. -/
theorem theory_extension_monotone {α} {T T' : ImplTheory α} (h : ∀ a b, T a b → T' a b)
    {a b} (hab : Derivable T a b) : Derivable T' a b := hab.mono h

/-- **Monotone Boolean function form.** For fixed endpoints `a b`, the map sending a theory
to the proposition "`a` derives `b`" is monotone in the (pointwise) order on theories. This
is the precise statement that derivability is a monotone property of the edge set. -/
theorem derivable_monotone {α} (a b : α) :
    Monotone (fun T : ImplTheory α => Derivable T a b) := by
  intro T T' hTT' hab
  exact ReflTransGen.mono (fun x y h => hTT' x y h) hab

-- !-- Barrier method: a one-step induction on the reflexive-transitive closure shows any
-- set closed under the axioms and containing the source absorbs every conclusion; this is
-- the universal certificate for NON-derivability. -- !--
/-- **Barrier / invariant-cut lemma.** If `S` is closed under the axioms of `T` (any axiom
out of a member of `S` lands back in `S`) and contains `a`, then every `T`-derivable
conclusion of `a` lies in `S`. Picking a suitable `S` is the standard way to certify that
something is *not* derivable. -/
theorem refl_trans_gen_closed {α} (T : ImplTheory α) (S : Set α)
    (hclosed : ∀ a ∈ S, ∀ b, T a b → b ∈ S) {a b} (ha : a ∈ S)
    (hab : Derivable T a b) : b ∈ S := by
  induction hab with
  | refl => exact ha
  | tail _ hbc ih => exact hclosed _ ih _ hbc

/-! ### The linear chain theory — the minimal-density extremal case -/

/-- The **chain theory** on `ℕ`: the axioms are exactly `k → k+1`. This is the minimal
theory making `0` derive `n`, with a derivation of length precisely `n`. -/
def chainT : ImplTheory ℕ := fun a b => b = a + 1

-- !-- Forward direction of the chain boundary: induct on the target; either the source is
-- already strictly below and we extend a shorter derivation, or source = target. -- !--
/-- In the chain theory, `a ≤ b` implies `a` derives `b`. -/
theorem chain_derivable_le {a b : ℕ} (h : a ≤ b) : Derivable chainT a b := by
  induction b with
  | zero => simp_all; exact ReflTransGen.refl
  | succ n ih =>
    rcases Nat.lt_or_ge a (n + 1) with h1 | h1
    · exact (ih (Nat.lt_succ_iff.mp h1)).tail rfl
    · have : a = n + 1 := le_antisymm h h1
      subst this; exact ReflTransGen.refl

/-- The chain theory derives `n` from `0`. -/
theorem chain_derivable (n : ℕ) : Derivable chainT 0 n := chain_derivable_le (Nat.zero_le n)

-- !-- Backward direction via the barrier lemma with the upward-closed cut `{k | a ≤ k}`:
-- the axioms only ever increase the index, so derivability cannot decrease it. -- !--
/-- In the chain theory, derivability forces `a ≤ b`: no derivation can go "backward". -/
theorem chain_barrier_closed {a b : ℕ} (hab : Derivable chainT a b) : a ≤ b := by
  have := refl_trans_gen_closed chainT {k | a ≤ k}
    (by intro x hx y hy; simp only [Set.mem_setOf_eq, chainT] at *; omega) (by simp) hab
  simpa using this

/-- **Sharp boundary characterization** for the chain theory: `a` derives `b` iff `a ≤ b`.
A complete, decidable description of the consequence relation. -/
theorem chain_derivable_iff (a b : ℕ) : Derivable chainT a b ↔ a ≤ b :=
  ⟨chain_barrier_closed, chain_derivable_le⟩

/-- No backward derivation: `1` does not derive `0` in the chain theory. -/
theorem chain_no_backward : ¬ Derivable chainT 1 0 := by
  intro h; have := chain_barrier_closed h; omega

/-! ### Axiom criticality -/

/-- The chain theory with the single axiom `m → m+1` **deleted**. -/
def chainMinus (m : ℕ) : ImplTheory ℕ := fun a b => b = a + 1 ∧ a ≠ m

/-- The punctured chain is a sub-theory of the full chain (monotonicity input). -/
theorem chainMinus_le_chain (m : ℕ) : ∀ a b, chainMinus m a b → chainT a b :=
  fun _ _ h => h.1

-- !-- Criticality via the barrier lemma with the downward-closed cut `{k | k ≤ m}`: with the
-- axiom `m → m+1` removed, no remaining axiom can escape the prefix `{0,…,m}`, so any target
-- `n > m` is unreachable. -- !--
/-- **Axiom criticality.** Removing the single axiom `m → m+1` from the chain destroys the
derivation of any `n > m` from `0`. Every axiom of the minimal theory is therefore critical
(criticality index `1`). -/
theorem chain_axiom_critical (m n : ℕ) (h : m < n) : ¬ Derivable (chainMinus m) 0 n := by
  intro hd
  have := refl_trans_gen_closed (chainMinus m) {k | k ≤ m}
    (by intro x hx y hy; simp only [Set.mem_setOf_eq, chainMinus] at *
        obtain ⟨rfl, hne⟩ := hy; omega) (by simp) hd
  simp only [Set.mem_setOf_eq] at this; omega

/-- **Criticality is exactly the gap between minimal and full theory.** For `m < n`, the
punctured theory cannot derive `n` from `0`, yet the full chain theory can: deleting the
axiom is both necessary (it breaks the proof) and reversible (restoring it recovers the
proof). -/
theorem chain_axiom_restorable (m n : ℕ) (h : m < n) :
    ¬ Derivable (chainMinus m) 0 n ∧ Derivable chainT 0 n :=
  ⟨chain_axiom_critical m n h, chain_derivable n⟩

/-! ### Constructive derivation witness -/

/-- The explicit derivation path `0 → 1 → ⋯ → n`, as a concrete list of atoms. -/
def chainPath (n : ℕ) : List ℕ := List.range (n + 1)

-- !-- The list `[0,1,…,n]` is a genuine `chainT`-chain since consecutive entries of
-- `List.range` differ by one; computed directly from `getElem_range`. -- !--
/-- The explicit path `chainPath n` is a valid chain for the chain axiom relation. -/
theorem chainPath_chain (n : ℕ) :
    List.IsChain (fun a b => b = a + 1) (chainPath n) := by
  unfold chainPath
  rw [List.isChain_iff_getElem]
  intro i hi
  simp [List.getElem_range]

/-- The constructive derivation of `n` from `0` has length exactly `n` (i.e. `n+1` atoms).
This is the proof-length witness anchoring the "proof length phase transition" program. -/
theorem chainPath_length (n : ℕ) : (chainPath n).length = n + 1 := by
  simp [chainPath]

end ProofPhaseTransitions