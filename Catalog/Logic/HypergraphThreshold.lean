/-
# Implicational Thresholds III: Multi-Premise (Hypergraph) Theories

This module **generalizes** the single-conclusion implicational machinery of
`Logic.ProofPhaseTransitions` (`ImplTheory`, `Derivable = ReflTransGen`,
`theory_extension_monotone`, `refl_trans_gen_closed`) from binary axioms `a → b` to
**`k`-premise rules** `(a₁ ∧ … ∧ aₘ) → b`, i.e. directed hypergraphs.  This is exactly the
content of Research Direction 3 ("Hypergraph (multi-premise) theories") of the cycle's
FUTURE_DIRECTIONS: re-establish the two structural pillars — *monotonicity* and the
*barrier method* — for the hypergraph closure, and then bridge back to the catalog's
single-premise model.

A **hypertheory** `R : Set (List α × α)` is a set of rules `(premises, conclusion)`.
Starting from a set `S` of assumed atoms, `HDeriv R S a` is the least set closed under
"`S` and every rule all of whose premises are already derived" — the standard forward
hypergraph closure / least fixed point.

Headline results:

* `hderiv_axioms_monotone` / `hderiv_hyps_monotone` — the **two monotonicities**: the
  hypergraph closure is monotone in *both* the rule set and the assumption set. The first is
  the hypergraph analogue of `ProofPhaseTransitions.theory_extension_monotone` (the
  threshold hypothesis) and generalizes it from edges to hyperedges.
* `hderiv_barrier` — the **hypergraph barrier method**: any set `C` containing the
  assumptions and closed under every rule whose premises lie in `C` absorbs the whole
  closure. The verbatim generalization of `ProofPhaseTransitions.refl_trans_gen_closed`
  ("closed under any rule all of whose premises lie in `C`"), the universal non-derivability
  certificate.
* `hderiv_singlePremise_iff_derivable` — the **cross-domain bridge**: when every rule has a
  single premise, hypergraph derivability collapses *exactly* onto the catalog's binary
  `ProofPhaseTransitions.Derivable`. This certifies that the hypergraph layer is a
  conservative generalization, connecting Direction 3 back to the original `Derivable`.

-- !-- Lab Notebook -- !--
-- Hypothesis: The monotonicity ⊕ barrier factorization of the proof-phase-transition program
--   is not special to binary edges; it should survive verbatim for multi-premise rules if
--   `Derivable` is replaced by the least fixed point `HDeriv` of "all premises derived ⇒
--   conclusion".  The single-premise specialization should recover `ReflTransGen` exactly.
-- Result: Both pillars generalize.  Monotonicity in rules and in assumptions are independent
--   structural inductions on `HDeriv`; the barrier lemma needs only "closed under any rule all
--   of whose premises lie in C", literally the FUTURE_DIRECTIONS prediction.  The single-premise
--   bridge is a clean iff with `Derivable`, so the catalog model embeds as the `m = 1` slice.
-- Insight: The barrier lemma is the *only* engine and it is premise-arity-agnostic: the closed
--   set `C` is the conserved quantity regardless of how many premises a rule consumes.  This is
--   why the same `{x ≤ m}`-style cuts that prove non-derivability for chains will prove it for
--   random hypergraphs — the certificate format does not change with `k`.
-- Failure analysis: The nested `∀ p ∈ prems, HDeriv R S p` constructor makes the auto-generated
--   recursor pass the inductive hypothesis as `∀ p ∈ prems, motive p`; one must use `induction`
--   (not `cases`) and feed *that* family, not re-derive premise facts.  `Set` membership again
--   blocks `omega`/`simp` until `Set.mem_setOf_eq` / `Set.mem_singleton_iff` normalization.
-- !-- end Lab Notebook -- !--
-/
import Mathlib

open Relation

namespace HypergraphThreshold

/-! ### Mirrored base infrastructure

`ImplTheory` and `Derivable` mirror `Logic.ProofPhaseTransitions`; they are reproduced
here so this file is self-contained and are *definitionally identical* to the catalog
versions (`Derivable` = reflexive–transitive closure of the axiom relation).  The
single-premise bridge below therefore connects the hypergraph layer to the very same
`Derivable` object studied in the catalog. -/

/-- An **implicational theory** (binary axioms), mirroring
`ProofPhaseTransitions.ImplTheory`. -/
abbrev ImplTheory (α : Type*) := α → α → Prop

/-- **Derivability**: reflexive–transitive closure of the axioms, mirroring
`ProofPhaseTransitions.Derivable`. -/
def Derivable {α : Type*} (T : ImplTheory α) : α → α → Prop := ReflTransGen T

/-- A **hypertheory** on atoms `α`: a set of multi-premise rules
`(premises, conclusion)`, generalizing the binary `ProofPhaseTransitions.ImplTheory`. -/
abbrev HyperTheory (α : Type*) := Set (List α × α)

/-- **Hypergraph derivability.** `HDeriv R S a` is the least predicate containing the
assumption set `S` and closed under every rule of `R` all of whose premises are already
derived. The multi-premise generalization of `ProofPhaseTransitions.Derivable`. -/
inductive HDeriv {α : Type*} (R : HyperTheory α) (S : Set α) : α → Prop
  | base {a : α} : a ∈ S → HDeriv R S a
  | rule {prems : List α} {concl : α} :
      (prems, concl) ∈ R → (∀ p ∈ prems, HDeriv R S p) → HDeriv R S concl

/-
!-- Monotone in the rule set: induct on the closure, replaying each rule through `R ⊆ R'`. -- !--

**Rule-set monotonicity.** Enlarging the hypertheory enlarges the closure. The
hypergraph analogue (and generalization) of
`ProofPhaseTransitions.theory_extension_monotone`.
-/
theorem hderiv_axioms_monotone {α : Type*} {R R' : HyperTheory α} (hR : R ⊆ R')
    {S : Set α} {a : α} (h : HDeriv R S a) : HDeriv R' S a := by
      induction h;
      · exact HDeriv.base ‹_›;
      · exact HDeriv.rule ( hR ‹_› ) ‹_›

/-
!-- Monotone in the assumptions: induct on the closure, relaxing each `base` via `S ⊆ S'`. -- !--

**Assumption monotonicity.** Enlarging the assumption set enlarges the closure.
-/
theorem hderiv_hyps_monotone {α : Type*} {R : HyperTheory α} {S S' : Set α} (hS : S ⊆ S')
    {a : α} (h : HDeriv R S a) : HDeriv R S' a := by
      induction h;
      · exact HDeriv.base ( hS ‹_› );
      · exact HDeriv.rule ‹_› ‹_›

/-
!-- Barrier method, premise-arity-agnostic: induct on the closure; `base` lands in `C` by
`S ⊆ C`, `rule` lands in `C` since all its premises are in `C` by the IH. -- !--

**Hypergraph barrier method.** If `C` contains the assumptions `S` and is closed under
every rule all of whose premises lie in `C`, then `C` absorbs the entire closure. The
verbatim generalization of `ProofPhaseTransitions.refl_trans_gen_closed` and the universal
certificate for hypergraph non-derivability.
-/
theorem hderiv_barrier {α : Type*} (R : HyperTheory α) (S C : Set α) (hS : S ⊆ C)
    (hclosed : ∀ prems concl, (prems, concl) ∈ R → (∀ p ∈ prems, p ∈ C) → concl ∈ C)
    {a : α} (h : HDeriv R S a) : a ∈ C := by
      induction h <;> aesop

/-- The single-premise hypertheory induced by a binary `ImplTheory`: each axiom `a → b`
becomes the one-premise rule `([a], b)`. -/
def toHyper {α : Type*} (T : ImplTheory α) : HyperTheory α :=
  {x | ∃ a, x.1 = [a] ∧ T a x.2}

/-
!-- Cross-domain bridge: forward by induction on `HDeriv` (each one-premise rule is a single
axiom step appended via `ReflTransGen.tail`), backward by induction on `ReflTransGen` (each
step is the one-premise rule `([b], c)`). -- !--

**Cross-domain bridge.** With single-premise rules, hypergraph derivability from the
singleton assumption `{a}` coincides *exactly* with the catalog's binary
`ProofPhaseTransitions.Derivable`. The hypergraph layer is a conservative generalization:
the original model is its `m = 1` slice.
-/
theorem hderiv_singlePremise_iff_derivable {α : Type*} (T : ImplTheory α) (a b : α) :
    HDeriv (toHyper T) {a} b ↔ Derivable T a b := by
      constructor;
      · intro h;
        induction h;
        · cases ‹_› ; exact ReflTransGen.refl;
        · rename_i prems concl h₁ h₂ h₃;
          obtain ⟨ x, hx₁, hx₂ ⟩ := h₁;
          exact ReflTransGen.tail ( h₃ x ( by aesop ) ) hx₂;
      · intro h;
        induction h;
        · exact HDeriv.base ( Set.mem_singleton a );
        · exact HDeriv.rule ⟨ _, rfl, by assumption ⟩ ( by aesop )

end HypergraphThreshold