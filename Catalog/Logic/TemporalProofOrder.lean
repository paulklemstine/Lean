import Mathlib

/-!
# The Temporal Order of Proof Discovery

Standard provability logic treats proofs as timeless, and the catalog's
`Catalog/Logic/TemporalGL.lean` *axiomatises* a time-stamped provability predicate
(`TemporalGL.TempProv`) together with its semantic Kripke counterpart
(`TemporalGL.TempFrame`), proving Löb soundness, Gödel II and persistence on top of an
assumed converse-well-founded accessibility relation. The companion
`Catalog/Logic/FormalTime.lean` models time itself as a dense linear order.

This file isolates the single combinatorial mechanism underneath that whole program: a
**discovery clock** `time : L → ℕ` on a library of lemmas `L` that strictly decreases
along the dependency relation `dep` (`dep a b` = "`a` depends on `b`", so `b` must be
discovered *before* `a`). The theory of "when you prove something matters" collapses, in
the finite case, to one crisp equivalence:

> **A valid temporal proof schedule exists iff the dependency graph is acyclic.**

## Catalog synthesis

* Extends `Catalog/Logic/TemporalGL.lean`: the well-foundedness used here
  (`ProofSchedule.dep_chain_wf`) is the order-theoretic shadow of the
  converse-well-foundedness `TempFrame.R_wf` that validates `TemporalGL.loeb_box_sound`;
  `ProofSchedule.provBy_persist` realises the abstract `TempProv.persist` axiom with a
  concrete clock rather than an assumption.
* Complements `Catalog/Logic/FormalTime.lean`: `dep` is the discrete, discovery-relevant
  skeleton of that dense model of time.

## Theorem index

1. `ProofSchedule.time_lt_of_transGen` — the clock strictly decreases along every
   dependency *chain*, not just single edges.
2. `ProofSchedule.dep_transGen_irrefl` / `dep_irrefl` / `dep_asymm` — "no time travel":
   a strictly-decreasing clock forbids dependency cycles and mutual dependence.
3. `ProofSchedule.dep_chain_wf` — the prerequisite relation is well-founded (no infinite
   regress of dependencies).
4. `ProofSchedule.proof_induction` — the bottom-up proof-discovery induction principle.
5. `ProofSchedule.provBy_persist` — "proofs are never lost": realises
   `TemporalGL.TempProv.persist`.
6. `exists_valid_schedule` — constructive converse: over a finite library, ranking each
   lemma by its number of transitive prerequisites yields a valid clock.
7. `schedulable_iff_acyclic` — the headline characterisation: a valid schedule exists iff
   the dependency graph is acyclic.

-- !-- Lab Notebook -- !--
* **Hypothesis.** The entire temporal-provability edifice (Löb, Gödel II, persistence) is
  powered by one finite combinatorial fact: a clock that strictly decreases along
  dependencies exists exactly when there are no dependency cycles.
* **Result.** `schedulable_iff_acyclic` proves the equivalence over any finite library;
  the witness clock counts transitive prerequisites (`{b | TransGen dep a b}.ncard`).
* **Insight.** A dependency *edge* `dep a b` strictly shrinks the (finite) prerequisite
  cone — `b` is a prerequisite of `a` but, by acyclicity, not of itself — so the cone's
  cardinality is automatically a strict-monotone clock. Well-foundedness of dependencies
  is then `Subrelation.wf` of `InvImage (·<·) time`, the order-theoretic twin of GL's
  converse well-foundedness.
* **Failure analysis.** The finiteness hypothesis is essential: over `ℕ` with `dep n m :=
  m = n+1` the graph is acyclic yet no ℕ-clock exists (it would be an infinite descending
  chain), so the prerequisite cone must be *finite* for the count to be defined and to
  strictly decrease. This boundary is recorded as Conjecture 3 in `FUTURE_DIRECTIONS.md`.
-/

namespace TemporalProofOrder

open Relation

variable {L : Type*}

/-- A **proof schedule** for a library `L` with dependency relation `dep`
(`dep a b` means "`a` depends on `b`", so `b` must be discovered first): a discovery
clock `time : L → ℕ` that strictly decreases along every dependency edge. -/
structure ProofSchedule (L : Type*) (dep : L → L → Prop) where
  /-- The discovery clock: the stage at which each lemma is proved. -/
  time : L → ℕ
  /-- Prerequisites are discovered strictly earlier. -/
  mono : ∀ {a b : L}, dep a b → time b < time a

/-- The dependency graph is **acyclic**: no lemma transitively depends on itself. -/
def Acyclic (dep : L → L → Prop) : Prop := ∀ a, ¬ TransGen dep a a

namespace ProofSchedule

variable {dep : L → L → Prop}

-- !-- Induction on the transitive-closure chain: a single edge decreases the clock by
--     `mono`; extending a chain by one more dependency composes two strict drops. -- !--
/-- The clock strictly decreases along an entire dependency chain. -/
theorem time_lt_of_transGen (S : ProofSchedule L dep) {a b : L}
    (h : TransGen dep a b) : S.time b < S.time a := by
  induction h with
  | single hab => exact S.mono hab
  | tail _ hbc ih => exact lt_trans (S.mono hbc) ih

-- !-- A cycle `TransGen dep a a` would force `time a < time a`. -- !--
/-- **No time travel (cycles).** A scheduled library has no dependency cycles. -/
theorem dep_transGen_irrefl (S : ProofSchedule L dep) (a : L) :
    ¬ TransGen dep a a := fun h => lt_irrefl _ (S.time_lt_of_transGen h)

-- !-- A self-loop `dep a a` would force `time a < time a`. -- !--
/-- **No self-dependence.** -/
theorem dep_irrefl (S : ProofSchedule L dep) (a : L) : ¬ dep a a :=
  fun h => lt_irrefl _ (S.mono h)

-- !-- Mutual dependence would give `time b < time a` and `time a < time b`. -- !--
/-- **No mutual dependence.** -/
theorem dep_asymm (S : ProofSchedule L dep) {a b : L} (h : dep a b) : ¬ dep b a :=
  fun h' => lt_asymm (S.mono h) (S.mono h')

-- !-- The dependency relation embeds (via `time`) into `<` on ℕ, which is well-founded;
--     `Subrelation.wf` of `InvImage (·<·) time` transfers well-foundedness. -- !--
/-- **No infinite regress.** The prerequisite relation `fun a b => dep b a` is
well-founded: there is no infinite chain of ever-deeper dependencies. This is the
order-theoretic shadow of `TemporalGL.TempFrame.R_wf`. -/
theorem dep_chain_wf (S : ProofSchedule L dep) :
    WellFounded (fun a b => dep b a) := by
  have hsub : Subrelation (fun a b => dep b a) (InvImage (· < ·) S.time) := by
    intro a b h; exact S.mono h
  exact hsub.wf (InvImage.wf S.time Nat.lt_wfRel.wf)

-- !-- Direct `WellFounded.induction` along `dep_chain_wf`. -- !--
/-- **Bottom-up proof-discovery induction.** To prove a property of every lemma it
suffices to prove it for a lemma assuming it for all of that lemma's direct
dependencies. -/
theorem proof_induction (S : ProofSchedule L dep) {P : L → Prop}
    (ih : ∀ a, (∀ b, dep a b → P b) → P a) : ∀ a, P a :=
  fun a => S.dep_chain_wf.induction a ih

/-- `provBy S t a` : lemma `a` has been discovered by stage `t`. -/
def provBy (S : ProofSchedule L dep) (t : ℕ) (a : L) : Prop := S.time a ≤ t

-- !-- `time a ≤ t ≤ s` by transitivity of `≤`. -- !--
/-- **Proofs are never lost.** Realises the abstract `TemporalGL.TempProv.persist`
axiom: anything discovered by stage `t` is discovered by every later stage `s`. -/
theorem provBy_persist (S : ProofSchedule L dep) {t s : ℕ} {a : L}
    (hts : t ≤ s) (h : S.provBy t a) : S.provBy s a :=
  le_trans h hts

end ProofSchedule

/-! ## The finite characterisation -/

variable [Finite L] {dep : L → L → Prop}

-- !-- Witness clock = number of transitive prerequisites. A dependency edge `dep a b`
--     makes `b`'s prerequisite cone a strict subset of `a`'s: `b` lies in `a`'s cone
--     (single edge) but not in its own (acyclicity), so the finite count strictly
--     drops. -- !--
/-- **Constructive converse.** Over a finite library, acyclicity yields a valid
schedule: rank each lemma by the number of its transitive prerequisites. -/
theorem exists_valid_schedule (dep : L → L → Prop) (h : Acyclic dep) :
    Nonempty (ProofSchedule L dep) := by
  refine ⟨{ time := fun a => {b | TransGen dep a b}.ncard, mono := ?_ }⟩
  intro a b hab
  have hsub : {c | TransGen dep b c} ⊆ {c | TransGen dep a c} := by
    intro c hc; exact (TransGen.single hab).trans hc
  apply Set.ncard_lt_ncard _ (Set.toFinite _)
  rw [Set.ssubset_iff_of_subset hsub]
  exact ⟨b, TransGen.single hab, fun hbb => h b hbb⟩

-- !-- Forward: a schedule forbids cycles (`dep_transGen_irrefl`). Backward:
--     `exists_valid_schedule`. -- !--
/-- **Headline characterisation.** Over a finite library, a valid temporal proof
schedule exists iff the dependency graph is acyclic. -/
theorem schedulable_iff_acyclic (dep : L → L → Prop) :
    Nonempty (ProofSchedule L dep) ↔ Acyclic dep := by
  constructor
  · rintro ⟨S⟩
    exact fun a => S.dep_transGen_irrefl a
  · exact exists_valid_schedule dep

end TemporalProofOrder