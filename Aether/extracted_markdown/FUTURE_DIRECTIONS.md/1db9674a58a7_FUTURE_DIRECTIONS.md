# Future Directions: Proof Phase Transitions

This cycle established the *deterministic skeleton* of derivability phase
transitions in `Catalog/Computation/ProofPhaseTransitions.lean`: an implicational
theory is a relation `T`, its consequences are `Derivable T = ReflTransGen T`,
and on finite edge sets the reachability predicate `EDeriv E src tgt` is a genuine
**monotone Boolean function** (`ederiv_mono`, `ederiv_upward_closed`). We proved the
barrier method for non-derivability (`barrier_not_derivable`), that the length-`n`
chain derives `0 ⟶ n` with exactly `n` axioms (`chain_derivable`, `chain_card`), and
that the chain is a **minimal certificate** — every axiom is critical
(`chain_edge_critical`, `chain_minimal_certificate`) — with a boundary case
(`redundant_edge_not_critical`) showing minimality is essential. These results are the
exact monotonicity-and-minimal-certificate inputs that a probabilistic threshold
theorem consumes.

## 1. Friedgut's sharp threshold for random implicational theories

Formalize the random model `G(n,p)` on `Fin n` where each directed edge is kept
independently with probability `p`, and prove that `ℙ[EDeriv 0 (n-1)]` jumps from
`o(1)` to `1 - o(1)` inside a window of vanishing width around a critical `p*(n)`.
The monotonicity hypothesis is *already discharged* by `ederiv_upward_closed`; what
remains is Friedgut's theorem itself.

The key insight is that `EDeriv E src tgt`, as `E` ranges over the cube
`{0,1}^{n²}`, is precisely a monotone Boolean function, so Friedgut's hypercontractive
/ Fourier-analytic argument applies verbatim once that machinery exists in Lean.

Why now? `ederiv_mono` and `chain_minimal_certificate` give both the monotonicity and
an explicit minimal certificate (the threshold's lower-bound witness); the only gap is
Fourier analysis on the Boolean cube, a reusable, broadly applicable formalization
target.

## 2. Proof-length phase transitions and resolution complexity

Refine derivability to *short* derivability: a sharp threshold for the existence of
derivations of length `≤ L(n)`. `chain_reach` already exhibits a length-`n` derivation;
conjecture that below `p*` minimum proofs are super-polynomial (or absent) and above
`p*` they are polynomial with high probability.

The key insight is that this implicational system is monotone resolution, so resolution
lower bounds for random CNF transfer directly to derivation-length lower bounds here.

Why now? `chain_minimal_certificate` pins the tight proof structure of minimal-density
theories; extending it needs only a formal `graph-diameter ↦ derivation-length` bridge,
built on the existing `chain_reach` prefix lemma.

## 3. Multi-premise theories and hypergraph thresholds

Generalize axioms `a → b` to `(a₁ ∧ … ∧ a_k) → b`, i.e. directed hypergraphs, so that
`Derivable` becomes `k`-uniform hyper-reachability. Re-establish the barrier method and
minimal-certificate theorems in this richer setting and study the `k`-dependence of the
threshold.

The key insight is that for `k ≥ 2` the critical window should sharpen as `k` grows,
mirroring the random `k`-SAT threshold; the down-set barrier of `chain_edge_critical`
generalizes to *closed* hypergraph barriers (sets closed under firing a hyperedge only
when all premises are inside).

Why now? `closed_preserved` + `barrier_not_derivable` are stated for arbitrary
relations, so the closure-under-firing template lifts almost mechanically to the
hypergraph closure operator.

## 4. Giant derivability component and order entropy

View derivability as a preorder on atoms and study, for random theories at density `p`,
the structural transition of the induced partial order on strongly connected
components: many small antichains below criticality, a giant derivability class above.
Conjecture a non-analytic point of the linear-extension entropy at `p*`.

The key insight is that the derivability order is the condensation of a random digraph,
so the emergence of a giant strongly connected component at `p ≈ 1/n` drives the
order-theoretic transition.

Why now? The clean `ImplTheory`/`Derivable` split formalized this cycle is exactly the
abstraction that lets random-digraph theory act on the derived order without entangling
the random object with its consequence relation.

## 5. Axiom criticality index and the proof-theoretic backbone

Define the criticality index of an axiom as the least number of axioms (including it)
whose removal breaks some derivation; in minimal theories this is `1`
(`chain_edge_critical`). Prove the monotonicity law — adding axioms can only decrease
existing criticality indices — and conjecture a power-law index distribution at the
critical density.

The key insight is that critical axioms are the proof-theoretic analogue of SAT
*backbone* variables (those fixed across all proofs), and phase-transition universality
predicts the same heavy-tailed statistics.

Why now? `chain_minimal_certificate` already isolates index-`1` axioms, and the
monotonicity law follows from `ederiv_mono` plus a `Finset.sdiff` bookkeeping argument,
making this the most immediate extension of the current infrastructure.
