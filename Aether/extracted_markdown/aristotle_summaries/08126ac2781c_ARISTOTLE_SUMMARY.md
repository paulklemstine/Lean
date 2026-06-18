# Summary of changes for run 9d2e0285-77f1-4b44-be8b-bf3aaf0801e2
Added a new self-contained Lean file `Catalog/Logic/TemporalProofOrder.lean` formalizing the order-theoretic / scheduling layer of the project's *Temporal Logic of Proofs* program, plus `FUTURE_DIRECTIONS.md`.

**What the file proves.** It introduces a `ProofSchedule` structure — a discovery clock `time : L → ℕ` on a library of lemmas with dependency relation `dep` that strictly decreases along every dependency edge — and `Acyclic dep` (no lemma transitively depends on itself). The headline result characterizes when proof discovery can be scheduled in time:

- `schedulable_iff_acyclic` — over a finite library, a valid schedule exists **iff** the dependency graph is acyclic.
- `exists_valid_schedule` — constructive converse: ranking each lemma by its number of transitive prerequisites (`{b | TransGen dep a b}.ncard`) gives a valid clock, since each dependency edge strictly shrinks the finite prerequisite cone.
- `ProofSchedule.time_lt_of_transGen`, `dep_transGen_irrefl`, `dep_irrefl`, `dep_asymm` — "no time travel": a strictly decreasing clock forbids dependency cycles and mutual dependence.
- `ProofSchedule.dep_chain_wf` and `proof_induction` — the prerequisite relation is well-founded (no infinite regress), giving a bottom-up proof-discovery induction principle; this is the order-theoretic shadow of the converse well-foundedness behind Löb in `TemporalGL.lean`.
- `ProofSchedule.provBy_persist` — realizes the abstract `TempProv.persist` axiom of `TemporalGL.lean` with a concrete clock ("proofs are never lost").

**Catalog synthesis.** The file explicitly extends `Catalog/Logic/TemporalGL.lean` (relating `dep_chain_wf` to `TempFrame.R_wf`/`loeb_box_sound`, and `provBy_persist` to `TempProv.persist`) and complements `Catalog/Logic/FormalTime.lean` (the discrete dependency skeleton of its dense time model).

**Quality.** The file compiles cleanly. It contains 9 theorems (well above the 2–4 main-results bar), with zero `sorry`. The main results depend only on the allowed axioms — `schedulable_iff_acyclic` and `exists_valid_schedule` use `propext, Classical.choice, Quot.sound`, while `dep_chain_wf`, `proof_induction`, and `provBy_persist` use no axioms at all. The file includes a `-- !-- Lab Notebook -- !--` block (Hypothesis, Result, Insight, Failure analysis) and one-to-two-sentence `-- !-- ... -- !--` proof sketches above each theorem.

`FUTURE_DIRECTIONS.md` gives the synthesis, a results summary, and five falsifiable conjectures (quantitative depth bound, critical-path makespan, infinite-library well-foundedness, a bridge to Löb via induced GL frames, and Gödel sentences as forced dependency cycles), each with a "The key insight is..." sentence and a "Why now?" justification.