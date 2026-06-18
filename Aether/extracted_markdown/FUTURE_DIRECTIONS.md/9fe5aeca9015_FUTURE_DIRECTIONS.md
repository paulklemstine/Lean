# Future Directions — The Temporal Order of Proof Discovery

## Synthesis

This cycle adds `Catalog/Logic/TemporalProofOrder.lean`, the order-theoretic /
scheduling layer of the project's *Temporal Logic of Proofs* program. Where the existing
`Catalog/Logic/TemporalGL.lean` *axiomatizes* time-stamped provability (Löb, Gödel II,
persistence) and `Catalog/Logic/FormalTime.lean` models time as a dense order with
discrete clocks, this file isolates the single combinatorial mechanism underneath all of
it: a discovery clock `time : L → ℕ` on a library of lemmas `L` that strictly decreases
along the dependency relation `dep`. The whole theory of "when you prove something
matters" collapses, in the finite case, to one crisp equivalence.

## Results Summary

* **`schedulable_iff_acyclic`** — over a finite library, a valid temporal proof schedule
  exists **iff** the dependency graph is acyclic. This is the headline characterization.
* **`exists_valid_schedule`** — the constructive converse: rank each lemma by its number
  of transitive prerequisites (`ncard {b | TransGen dep a b}`); a dependency edge
  strictly shrinks this finite set, so the count is a valid clock.
* **`ProofSchedule.dep_transGen_irrefl` / `dep_asymm` / `dep_irrefl`** — the "no time
  travel" direction: a strictly-decreasing clock forbids dependency cycles and mutual
  dependence.
* **`ProofSchedule.dep_chain_wf` / `proof_induction`** — the prerequisite relation is
  well-founded (no infinite regress), yielding the bottom-up proof-discovery induction
  principle. This is the order-theoretic shadow of the converse-well-foundedness that
  validates Löb in `TemporalGL.loeb_box_sound`.
* **`ProofSchedule.provBy_persist`** — a `ProofSchedule` *realizes* the abstract
  `TempProv.persist` axiom of `TemporalGL.lean`, grounding "proofs are never lost" in a
  concrete clock rather than an assumption.

All main results compile with `sorry`-free proofs depending only on `propext`,
`Classical.choice`, and `Quot.sound`.

## Conjectures for the Next Cycle

### 1. Quantitative depth bound: discovery time dominates proof depth

In any valid `ProofSchedule`, the length of the longest dependency chain ending at a
lemma `a` should be bounded above by `S.time a`, and the prerequisite-count clock built
in `exists_valid_schedule` should be *optimal* in that it equals the longest-chain depth
exactly when the dependency graph is a tree. Concretely: `chainDepth a ≤ S.time a`, with
equality realizable. **The key insight is** that the prerequisite-count clock and the
longest-chain clock are the two canonical solutions of the same strict-monotonicity
constraint, and they coincide precisely on graphs with no "diamond" of shared
dependencies. **Why now?** `dep_chain_wf` already provides the well-founded recursion
needed to *define* `chainDepth`, so the only missing ingredient is a single
`WellFounded.fix` and a monotonicity comparison — the infrastructure is in place this
cycle.

### 2. Minimal schedule length equals critical-path length

Define the *makespan* of a finite acyclic library as the minimum over all valid clocks of
`(max time) − (min time)`. Conjecture: the makespan equals the number of vertices on the
longest dependency chain minus one, i.e. parallel proof development can compress wall-clock
discovery time down to the critical-path length and no further. **The key insight is** that
proofs with disjoint prerequisite cones can be discovered *simultaneously*, so the only
irreducible serial cost is the longest chain — a proof-theoretic analogue of the
critical-path theorem in scheduling. **Why now?** `schedulable_iff_acyclic` gives the
existence of *some* clock; upgrading from "a clock exists" to "an optimal clock exists with
a closed-form length" is the natural next rung and directly reuses `exists_valid_schedule`.

### 3. Infinite libraries: schedulability ⇔ well-foundedness, not mere acyclicity

For infinite `L`, acyclicity (`Acyclic dep`) is *strictly weaker* than the existence of an
ℕ-valued discovery clock: the integers under `n → n+1` form an acyclic chain with no valid
ℕ-clock. Conjecture: for arbitrary `L`, a valid `ℕ`-clock exists **iff** the transitive
closure of `dep` is well-founded *and* of height `< ω`; allowing ordinal-valued clocks
recovers the full equivalence with well-foundedness. **The key insight is** that the
finiteness hypothesis in `exists_valid_schedule` secretly encodes "every prerequisite cone
is finite," and replacing it by an ordinal rank generalizes the count clock verbatim.
**Why now?** Mathlib's `WellFounded.rank` into ordinals is available and `dep_chain_wf`
already exhibits the well-founded relation, so the generalization is a clean target rather
than a from-scratch development.

### 4. Bridge to Löb: a schedule induces a converse-well-founded GL frame

Every finite acyclic `ProofSchedule` should yield a `TemporalGL.TempFrame` whose
GL-accessibility relation `R` is the (reverse) dependency relation, with the
prerequisite-count clock furnishing both the converse-well-foundedness witnessing Löb and
the time order `T` witnessing persistence. Conjecture: under this translation,
`TemporalGL.loeb_box_sound` and `TemporalProofOrder.proof_induction` become the *same*
theorem viewed through the modal vs. order-theoretic lens. **The key insight is** that
Löb's "no infinite proof-counterexample chain" and scheduling's "no infinite dependency
regress" are one well-foundedness fact wearing two notations. **Why now?** Both endpoints
now exist and are `sorry`-free in the same library (`TempFrame`, `dep_chain_wf`), so the
bridge is a construction-plus-naturality proof rather than new mathematics.

### 5. Self-reference is exactly the obstruction: Gödel sentences as forced cycles

Conjecture: a lemma `g` whose statement asserts its own underivability forces a dependency
cycle `TransGen dep g g` in any honest dependency assignment, and `dep_transGen_irrefl`
then explains *why* such a `g` is unschedulable — it can never be assigned a finite
discovery time. This would recast `TemporalGL.godel_second_at_time` as a corollary of pure
acyclicity. **The key insight is** that incompleteness is the statement "the dependency
graph of arithmetic, completed honestly, would contain a cycle," and acyclicity of any
*actual* schedule is precisely what keeps the system consistent. **Why now?** With
`dep_transGen_irrefl` and the time-stamped `godel_second_at_time` both proved, the
remaining work is the encoding lemma turning a self-referential sentence into a `TransGen`
cycle — a focused, falsifiable target.
