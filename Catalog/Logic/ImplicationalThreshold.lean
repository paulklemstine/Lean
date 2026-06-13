/-
# Implicational Thresholds II: Proof Length and the Diameter Bound

This module **extends** the proof–phase–transition infrastructure of
`Logic.ProofPhaseTransitions` (the `ImplTheory` / `Derivable` package: `Derivable`,
`theory_extension_monotone`, `refl_trans_gen_closed`, `chainT`, `chain_derivable`,
`chain_axiom_critical`) with a *length-graded* notion of derivation.  Where
`Derivable T a b := Relation.ReflTransGen T a b` only records *existence* of a
derivation, `DerivOfLen T a b k` records that there is a derivation using **exactly `k`
axiom applications**.  This is precisely the missing ℕ-valued infrastructure called for in
Research Direction 2 ("Proof-length thresholds and the diameter bound") of the cycle's
FUTURE_DIRECTIONS.

Headline results:

* `derivable_iff_exists_len` — `DerivOfLen` refines `Derivable`: `a` derives `b` iff some
  length-`k` derivation exists.  This pins the graded layer to the catalog's `Derivable`.
* `derivOfLen_theory_monotone` — the graded analogue of
  `ProofPhaseTransitions.theory_extension_monotone`: a length-`k` derivation survives any
  theory extension, *with the same length*.
* `chain_derivOfLen_iff` — the **sharp graded boundary** for the chain theory: in `chainT`,
  the only derivation of `b` from `a` has length exactly `b - a` (formally, a length-`k`
  derivation exists iff `b = a + k`).  This is the graded refinement of
  `ProofPhaseTransitions.chain_derivable_iff`.
* `minDerivLen_chain` — the **diameter theorem**: the minimal proof length of `0 ⊢ n` in
  the chain theory equals `n`, the graph diameter.  This is the deterministic anchor of the
  proof-length phase-transition program.
* `minDerivLen_theory_anti` — **proofs only get shorter**: enlarging the axiom set can never
  increase the minimal proof length.  A graded strengthening of catalog monotonicity and
  the base case for Direction 5's criticality-index monotonicity.

-- !-- Lab Notebook -- !--
-- Hypothesis: Existence-only `Derivable` (= `ReflTransGen`) hides the proof-length structure
--   needed for a *proof-length* phase transition.  A length-indexed inductive `DerivOfLen`
--   graded by the number of axiom steps should (a) refine `Derivable` exactly, (b) inherit
--   monotonicity length-preservingly, and (c) on the chain pin the length to the graph
--   distance, making `minDerivLen (chain) 0 n = n` (diameter) a theorem.
-- Result: All five results formalize.  The chain length is *rigid*: `DerivOfLen chainT a b k`
--   holds iff `b = a + k`, so the length set of `0 ⊢ n` is the singleton `{n}` and its `sInf`
--   is `n`.  Monotonicity of the minimal length follows from set-inclusion of length sets plus
--   `Nat.sInf_mem` on the (nonempty) achievable-length set.
-- Insight: Because each chain axiom strictly increases the index, there is a *unique* proof
--   length, not merely a minimal one — the chain has no "proof slack".  This rigidity is what
--   makes the chain the extremal minimal-density witness for both existence (catalog) and
--   length (here) thresholds; random theories should instead exhibit a *band* of lengths.
-- Failure analysis: `omega` cannot see through `DerivOfLen`; the forward chain direction must
--   induct on the `DerivOfLen` derivation, not on `k`, to expose the `+1` per step.  `sInf` on
--   ℕ needs the length set proven nonempty before `Nat.sInf_mem` applies.
-- !-- end Lab Notebook -- !--
-/
import Mathlib

open Relation

namespace ImplicationalThreshold

/-! ### Mirrored base infrastructure

The following three declarations mirror `Logic.ProofPhaseTransitions` (`ImplTheory`,
`Derivable`, `chainT`).  They are reproduced here so that this file is self-contained;
they are *definitionally identical* to the catalog versions (`Derivable` is the
reflexive–transitive closure of the axiom relation, `chainT` the successor relation on
`ℕ`), so all results below extend the catalog package on the very same objects. -/

/-- An **implicational theory** on atoms `α`: the single-conclusion axioms `a → b`,
encoded as a binary relation (mirrors `ProofPhaseTransitions.ImplTheory`). -/
abbrev ImplTheory (α : Type*) := α → α → Prop

/-- **Derivability**: the reflexive–transitive closure of the axiom relation (mirrors
`ProofPhaseTransitions.Derivable`). -/
def Derivable {α : Type*} (T : ImplTheory α) : α → α → Prop := ReflTransGen T

/-- The **chain theory** on `ℕ`: axioms `k → k+1` (mirrors `ProofPhaseTransitions.chainT`). -/
def chainT : ImplTheory ℕ := fun a b => b = a + 1

/-- **Length-graded derivability.** `DerivOfLen T a b k` asserts the existence of a
derivation of `b` from `a` in the theory `T` using *exactly* `k` axiom applications. It
refines `ProofPhaseTransitions.Derivable` (which forgets the length) and is the basic
object of the proof-length phase-transition program. -/
inductive DerivOfLen {α : Type*} (T : ImplTheory α) : α → α → ℕ → Prop
  | refl (a : α) : DerivOfLen T a a 0
  | tail {a b c : α} {n : ℕ} : DerivOfLen T a b n → T b c → DerivOfLen T a c (n + 1)

/-
!-- The graded layer refines the catalog's `Derivable`: forward by induction on
`ReflTransGen`, backward by induction on the `DerivOfLen` witness, matching `refl`/`tail`. -- !--

`DerivOfLen` refines `Derivable`: `a` derives `b` in `T` iff some length-`k` derivation
exists. This pins the graded layer onto `ProofPhaseTransitions.Derivable`.
-/
theorem derivable_iff_exists_len {α : Type*} (T : ImplTheory α) (a b : α) :
    Derivable T a b ↔ ∃ k, DerivOfLen T a b k := by
      constructor;
      · intro h;
        induction h;
        · exact ⟨ 0, DerivOfLen.refl a ⟩;
        · obtain ⟨ k, hk ⟩ := ‹_›;
          exact ⟨ k + 1, DerivOfLen.tail hk ‹_› ⟩;
      · rintro ⟨ k, hk ⟩;
        induction hk <;> [ tauto; exact ReflTransGen.tail ‹_› ‹_› ]

/-
!-- Graded monotonicity: induct on the derivation, reapplying each axiom through the
inclusion `T ⊆ T'`; length is preserved step-for-step. -- !--

**Graded theory monotonicity.** A length-`k` derivation in `T` is still a length-`k`
derivation in any extension `T'`. This is the length-preserving refinement of
`ProofPhaseTransitions.theory_extension_monotone`.
-/
theorem derivOfLen_theory_monotone {α : Type*} {T T' : ImplTheory α}
    (h : ∀ a b, T a b → T' a b) {a b : α} {k : ℕ} (hd : DerivOfLen T a b k) :
    DerivOfLen T' a b k := by
      induction' hd with a b k hd ih;
      · constructor;
      · exact DerivOfLen.tail ‹_› ( h _ _ ih )

/-
!-- Each chain axiom adds exactly one to the index, so the length equals the index gap:
forward by induction on the derivation, backward by induction on `k`. -- !--

**Sharp graded boundary for the chain theory.** In `ProofPhaseTransitions.chainT`, a
length-`k` derivation of `b` from `a` exists iff `b = a + k`. The chain has no "proof
slack": the proof length is the index gap, uniquely determined. Graded refinement of
`ProofPhaseTransitions.chain_derivable_iff`.
-/
theorem chain_derivOfLen_iff (a b k : ℕ) :
    DerivOfLen chainT a b k ↔ b = a + k := by
      constructor;
      · induction' k with k ih generalizing a b;
        · rintro ⟨ ⟩ ; tauto;
        · rintro ⟨ c, hc ⟩;
          grind +locals;
      · intro h;
        induction' k with k ih generalizing a b;
        · exact h.symm ▸ DerivOfLen.refl _;
        · convert DerivOfLen.tail ( ih a ( a + k ) rfl ) _ using 1;
          exact h.symm ▸ rfl

/-- The **minimal proof length** of `a ⊢ b` in theory `T`: the least number of axiom
applications among all derivations (`0`-by-convention when none exists, via `Nat.sInf`). -/
noncomputable def minDerivLen {α : Type*} (T : ImplTheory α) (a b : α) : ℕ :=
  sInf {k | DerivOfLen T a b k}

/-
!-- The achievable-length set of `0 ⊢ n` in the chain is the singleton `{n}` (by
`chain_derivOfLen_iff`), so its infimum is `n`. -- !--

**Diameter theorem.** In the chain theory the minimal proof length of `0 ⊢ n` is exactly
`n` — the graph diameter. Combined with `ProofPhaseTransitions.chainPath_length` (a concrete
length-`n` witness) this is the deterministic anchor of the proof-length program.
-/
theorem minDerivLen_chain (n : ℕ) : minDerivLen chainT 0 n = n := by
  refine' le_antisymm ( csInf_le _ _ ) ( le_csInf _ _ ) <;> norm_num;
  · exact chain_derivOfLen_iff _ _ _ |>.2 ( by norm_num );
  · exact ⟨ n, by rw [ Set.mem_setOf_eq, chain_derivOfLen_iff ] ; simp +decide ⟩;
  · intro b hb; have := chain_derivOfLen_iff 0 n b; aesop;

/-
!-- The achievable-length set only grows under theory extension (graded monotonicity),
and `Nat.sInf_mem` puts the minimizer of the smaller set into the larger one. -- !--

**Proofs only get shorter.** Enlarging the axiom set can never increase the minimal proof
length: if `a ⊢ b` is derivable in `T` and `T ⊆ T'`, then `minDerivLen T' a b ≤
minDerivLen T a b`. The graded strengthening of catalog monotonicity and the base case for
the criticality-index monotonicity of Research Direction 5.
-/
theorem minDerivLen_theory_anti {α : Type*} {T T' : ImplTheory α}
    (h : ∀ a b, T a b → T' a b) {a b : α} (hex : ∃ k, DerivOfLen T a b k) :
    minDerivLen T' a b ≤ minDerivLen T a b := by
      obtain ⟨ k, hk ⟩ := hex;
      apply Nat.sInf_le;
      exact derivOfLen_theory_monotone h ( Nat.sInf_mem ( show { k | DerivOfLen T a b k }.Nonempty from ⟨ k, hk ⟩ ) )

end ImplicationalThreshold