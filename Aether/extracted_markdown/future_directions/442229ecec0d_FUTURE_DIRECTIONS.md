# Future Directions: Proof Phase Transitions

## Synthesis

This cycle established the *deterministic skeleton* of derivability phase transitions in
`Catalog/Computation/ProofPhaseTransitions.lean`. The abstraction is deliberately thin:
an implicational theory is a binary relation `T : α → α → Prop`, its consequences are the
reflexive–transitive closure `Derivable T = Relation.ReflTransGen T`, and on a finite
edge set `E : Finset (α × α)` the reachability predicate `EDeriv E src tgt` is the
derivability relation of the digraph `E`. The central structural fact is that, as `E`
ranges over subsets of a fixed ground set, `EDeriv E src tgt` is a genuine **monotone
Boolean function**: this is `ederiv_mono` / `ederiv_upward_closed`, both falling straight
out of `Relation.ReflTransGen.mono`. Monotonicity is exactly the hypothesis a
probabilistic sharp-threshold theorem (Friedgut) consumes, so discharging it cleanly is
the point.

The dual side is the **barrier method**: a set `S` closed under firing (`a ∈ S` and
`T a b` imply `b ∈ S`) is invariant along every derivation (`closed_preserved`), so a
closed `S` with `src ∈ S` and `tgt ∉ S` certifies non-derivability
(`barrier_not_derivable`). Specialized to the length-`n` chain `0 → 1 → ⋯ → n`, the
down-set `{x ≤ i}` is the unique cut isolating the edge `(i, i+1)`. This delivers the
**minimal-certificate** theorems: the chain derives `0 ⟶ n` with exactly `n` axioms
(`chain_card`, `chain_derivable`), and deleting *any* single axiom destroys the
derivation (`chain_edge_critical`, `chain_minimal_certificate`). The boundary case
`redundant_edge_not_critical` shows the converse fails without minimality: adding the
shortcut `(0,2)` to the 2-chain produces a non-critical axiom, so "every axiom is
critical" genuinely characterizes minimal certificates rather than being automatic.

What failed / what we learned: the natural "minimum proof length" formulation is awkward
on `Relation.ReflTransGen`, which carries no length witness, so all minimality results
were routed through the length-free down-set barrier instead of step counting. That
suggests the next quantitative refinement (short derivability) needs a *graded* closure
with an explicit length parameter, not the bare transitive closure. The two halves —
monotonicity and an explicit minimal certificate — are precisely the upper- and
lower-bound inputs a threshold theorem needs; the remaining gap is purely probabilistic /
Fourier-analytic, not order-theoretic.

## Results Summary

- `derivable_refl`: proved — reflexivity of the consequence relation (basic infrastructure).
- `derivable_trans`: proved — derivations compose; the consequence relation is a preorder.
- `ederiv_mono`: proved — reachability is monotone in the edge set (the monotone-Boolean-function core).
- `ederiv_upward_closed`: proved — curried monotonicity, the exact form a threshold theorem consumes.
- `closed_preserved`: proved — closed sets are invariant along derivations (the barrier invariant).
- `barrier_not_derivable`: proved — closed separating set certifies non-derivability (barrier method).
- `chain_card`: proved — the length-`n` chain uses exactly `n` axioms.
- `mem_chainEdges`: proved — membership characterization of the chain edge set.
- `chain_reach` / `chain_derivable`: proved — the chain derives every prefix `0 ⟶ k`, in particular `0 ⟶ n`.
- `chain_edge_critical`: proved — deleting edge `(i,i+1)` breaks `0 ⟶ n` via the down-set barrier.
- `chain_minimal_certificate`: proved — every chain axiom is critical (minimal certificate).
- `redundant_edge_not_critical`: proved — boundary case: a redundant shortcut is not critical, so minimality is essential.

## Research Directions

### Direction 1: Friedgut's sharp threshold for random implicational theories
**Hypothesis**: In the random model `G(n,p)` on `Fin n` (each directed edge kept
independently w.p. `p`), `ℙ[EDeriv E 0 (n-1)]` jumps from `o(1)` to `1 - o(1)` inside a
window of vanishing width around a critical `p*(n)`.
**Test**: Formalize the product measure on `Finset (Fin n × Fin n)`, then invoke a Lean
formalization of Friedgut's theorem (or the coarse `p ≈ log n / n` first/second-moment
bounds as a first milestone) using `ederiv_upward_closed` as the monotonicity input.
**Why now**: Monotonicity (`ederiv_mono`) and an explicit minimal-certificate witness
(`chain_minimal_certificate`) are both discharged; the only gap is probabilistic.
**If true**: First machine-checked sharp threshold for a proof-theoretic reachability
property, and a reusable Boolean-cube Fourier toolkit.
**If false**: A non-sharp (coarse) threshold would reveal that derivability lacks the
symmetry Friedgut requires, pointing to the role of the fixed endpoints `0, n-1`.

### Direction 2: Proof-length phase transitions
**Hypothesis**: Define `EDerivLen E src tgt L` = "there is a derivation of length `≤ L`".
Below `p*` the shortest derivation `0 ⟶ n-1` is super-polynomial or absent; above `p*`
it is poly-logarithmic w.h.p.
**Test**: Introduce a graded closure `ReflTransGen` replacement carrying an explicit
length (an inductive `Nat`-indexed reachability), re-prove `chain_reach` with length `= k`,
then study the length distribution.
**Why now**: `chain_reach` already builds the derivation prefix-by-prefix, so the
length-annotated version is a direct refactor; this cycle's failure analysis identified
the missing length parameter as the only obstruction.
**If true**: Connects derivation length to graph diameter and to resolution complexity.
**If false**: Would show short-derivability and derivability share a threshold, i.e. no
separate "proof-length" transition.

### Direction 3: Multi-premise theories and hypergraph thresholds
**Hypothesis**: Generalizing axioms `a → b` to `(a₁ ∧ ⋯ ∧ a_k) → b` (directed
hypergraphs), the barrier method and minimal-certificate theorems still hold, with a
threshold window that *sharpens* as `k` grows (mirroring random `k`-SAT).
**Test**: Define `HDerivable` as closure under firing a hyperedge only when all premises
are derived; re-prove `closed_preserved` / `barrier_not_derivable` for the hypergraph
closure operator; rebuild a `k`-uniform analogue of the chain.
**Why now**: `closed_preserved` and `barrier_not_derivable` are stated for an arbitrary
relation, so the closure-under-firing template lifts almost mechanically once "closed"
is upgraded to "closed under hyperedge firing".
**If true**: A uniform barrier theory across arities, unifying Horn-SAT and reachability.
**If false**: The arity-`k` closure would lack a finite invariant characterization,
isolating exactly where the relational abstraction breaks.

### Direction 4: Axiom criticality index and the proof-theoretic backbone
**Hypothesis**: Define the criticality index of an axiom `e` as the least `m` such that
some `m`-element axiom set containing `e` is critical for a derivation. In minimal
theories this is `1` (`chain_minimal_certificate`); adding axioms can only *decrease*
existing criticality indices (a monotonicity law).
**Test**: Formalize the index via `Finset.sdiff` bookkeeping and prove the monotonicity
law from `ederiv_mono`; then conjecture a heavy-tailed index distribution at `p*`.
**Why now**: `chain_edge_critical` already isolates index-`1` axioms; the monotonicity
law is a `Finset` argument on top of the proven `ederiv_mono`.
**If true**: Identifies the proof-theoretic analogue of SAT *backbone* variables.
**If false**: A non-monotone index would mean adding axioms can *create* criticality,
contradicting the intuition that redundancy only dilutes it.

### Direction 5: Giant derivability component and order entropy
**Hypothesis**: Viewing `Derivable` as a preorder on atoms, random theories at density
`p` exhibit a structural transition — many small antichains below `p ≈ 1/n`, a single
giant strongly-connected derivability class above — with a non-analytic point of the
linear-extension entropy at the transition.
**Test**: Define the SCC condensation of the random digraph `E`, relate its strongly
connected components to `EDeriv`-mutual-reachability, and track the largest component's
size as a function of `p`.
**Why now**: The clean `ImplTheory` / `Derivable` split lets random-digraph theory act on
the *derived* order without entangling the random object with its consequence relation.
**If true**: Ports the giant-component phenomenon into proof theory as an order-entropy
transition.
**If false**: Absence of a giant derivability class would show the endpoint-fixed
reachability question is governed by path existence, not bulk connectivity.
