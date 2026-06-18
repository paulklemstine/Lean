# Future Directions: Proof Phase Transitions — Length & Hypergraph Layers

## Synthesis

The previous cycle built the *existence* layer of the proof–phase–transition program in
`Catalog/Logic/ProofPhaseTransitions.lean`: implicational theories as binary relations,
`Derivable` as reflexive–transitive closure, and the two structural pillars
`theory_extension_monotone` (monotonicity) and `refl_trans_gen_closed` (the barrier
method), with the chain theory as the extremal minimal-density witness
(`chain_derivable_iff`, `chain_axiom_critical`). That layer answers *whether* a
conclusion is derivable but is blind to *how long* the proof is and to *multi-premise*
rules.

This cycle adds the two missing dimensions called for in the prior FUTURE_DIRECTIONS, on
the very same `Derivable` object, in two new self-contained files.

`Catalog/Logic/ImplicationalThreshold.lean` introduces the **length-graded** layer
`DerivOfLen T a b k` ("a derivation of `b` from `a` using exactly `k` axiom steps") and
the minimal-proof-length function `minDerivLen`. The key insight is that on the chain
theory the proof length is *rigid* — `DerivOfLen chainT a b k ↔ b = a + k` forces the
achievable-length set of `0 ⊢ n` to be the singleton `{n}` — so the diameter theorem
`minDerivLen chainT 0 n = n` is not a minimum over many lengths but the only length. The
graded layer inherits the existence layer's monotonicity *length-preservingly*
(`derivOfLen_theory_monotone`), which immediately yields `minDerivLen_theory_anti`:
adding axioms can only shorten proofs. This is exactly the deterministic core needed
before any random diameter estimate, and the monotonicity base case for criticality
indices.

`Catalog/Logic/HypergraphThreshold.lean` lifts the whole framework from binary edges to
**`k`-premise rules** (directed hypergraphs) via the least-fixed-point closure `HDeriv`.
The two pillars survive verbatim — `hderiv_axioms_monotone` and `hderiv_hyps_monotone`
(monotone in both rules and assumptions) and `hderiv_barrier` (a closed set absorbing the
whole closure, premise-arity-agnostic) — and the cross-domain bridge
`hderiv_singlePremise_iff_derivable` proves the catalog's binary `Derivable` is *exactly*
the single-premise slice of `HDeriv`. The structural insight, again, is that the entire
program factors through **monotonicity ⊕ barriers**, and neither pillar cares about
premise arity; the conserved set in a barrier certificate has the same format for `k = 1`
(chains) and arbitrary `k` (random SAT-like ensembles).

## Results Summary

In `Catalog/Logic/ImplicationalThreshold.lean`:
- `derivable_iff_exists_len` — the graded layer refines `Derivable`: derivability is
  existence of *some* finite-length derivation.
- `derivOfLen_theory_monotone` — theory extension preserves a derivation *and its length*.
- `chain_derivOfLen_iff` — sharp graded boundary: in the chain, the unique proof length of
  `a ⊢ b` is the index gap `b − a`.
- `minDerivLen_chain` — **diameter theorem**: the minimal proof length of `0 ⊢ n` is `n`.
- `minDerivLen_theory_anti` — **proofs only get shorter**: enlarging axioms never increases
  minimal proof length.

In `Catalog/Logic/HypergraphThreshold.lean`:
- `hderiv_axioms_monotone`, `hderiv_hyps_monotone` — hypergraph closure is monotone in the
  rule set and the assumption set.
- `hderiv_barrier` — the barrier method for multi-premise rules.
- `hderiv_singlePremise_iff_derivable` — **cross-domain bridge**: single-premise hypergraph
  derivability coincides exactly with the catalog's `Derivable`.

All main results are `sorry`-free and depend only on the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).

## Research Directions

### Direction 1: A length lower bound by graph distance, then random diameters
**Hypothesis**: For *any* theory `T`, `minDerivLen T a b` is bounded below by the
shortest-path distance from `a` to `b` in the axiom digraph, with equality on the chain.
Above the random threshold `p*`, the typical `minDerivLen 0 (n−1) = Θ(log n / log(np))`.
**Test**: Refine `chain_derivOfLen_iff` into a general `DerivOfLen T a b k → dist a b ≤ k`
by inducting on the derivation, then specialize to recover `minDerivLen_chain` as the
tight case; layer the random small-world diameter estimate on top.
**The key insight is** that `minDerivLen` is already monotone (`minDerivLen_theory_anti`),
so the lower bound only needs the *single* fact that each axiom step advances distance by
at most one — the dual of the barrier conservation law.
**Why now**: `DerivOfLen` and `minDerivLen` now exist and the chain case is pinned exactly,
so the general inequality is a direct induction rather than new infrastructure.
**If true**: imports random-graph diameter concentration into proof complexity, separating
existence and length thresholds quantitatively.
**If false**: short proofs below the existence threshold would mean length and existence
thresholds genuinely decouple — a proof-theoretic anomaly.

### Direction 2: Premise-arity sharpening of the barrier window
**Hypothesis**: For random `k`-premise hypertheories, the non-derivability barrier
certificate `hderiv_barrier` becomes harder to satisfy as `k` grows, narrowing the
critical window — the proof-theoretic mirror of the sharpening random-`k`-SAT threshold.
**Test**: Instantiate `hderiv_barrier` with explicit down-set cuts on `Fin n` for fixed
`k`, count the rules a cut must respect as a function of `k`, and track how the largest
"safe" assumption set shrinks; formalize the monotone window-width bound in `k`.
**The key insight is** that `hderiv_barrier` is premise-arity-agnostic, so the *same*
certificate format measures difficulty across all `k`; only the closure condition's arity
changes, isolating `k` as the sole window parameter.
**Why now**: `HDeriv` and `hderiv_barrier` are in place and already stated purely via
forward-closure under premises-in-`C`, exactly the form a `k`-uniform analysis needs.
**If true**: connects this framework to random `k`-SAT thresholds, the central object of
probabilistic combinatorics.
**If false**: a `k`-independent window would show single-conclusion reachability intuition
fails for hypergraphs.

### Direction 3: Criticality index from the length and barrier layers
**Hypothesis**: Define `critIndex T a b` = least number of axioms whose removal kills
`Derivable T a b`. Then (i) `critIndex` is monotone non-increasing under theory extension,
and (ii) every chain edge has index `1`, recovering `chain_axiom_critical`.
**Test**: Build `critIndex` on top of `Derivable`; prove monotonicity as a corollary of
`theory_extension_monotone` (catalog) plus `hderiv_barrier`/`refl_trans_gen_closed`, using
`minDerivLen_theory_anti` to control how removal interacts with length.
**The key insight is** that a critical axiom is precisely one whose deletion creates a
barrier cut, so `critIndex` is the minimal number of edges needed to *complete* a
conserved set separating `a` from `b` — a min-cut read of criticality.
**Why now**: `chain_axiom_critical` is the `critIndex = 1` base case and the
monotonicity-⊕-barrier proof scheme now exists in both the binary and hypergraph layers.
**If true**: yields a Menger-type min-cut = criticality theorem and a backbone law across
theory ensembles.
**If false**: a non-monotone or bimodal index distribution would expose theory-specific
proof structure violating constraint-satisfaction universality.

### Direction 4: A length-band theorem for branching theories
**Hypothesis**: Unlike the rigid chain (a single proof length), theories with branching
(multiple axioms out of a node) admit a *band* of proof lengths `[dist a b, L]`; the band
width is an order parameter that vanishes at the chain and grows with average out-degree.
**Test**: Define the achievable-length set `{k | DerivOfLen T a b k}` (already the object
inside `minDerivLen`) and prove for a two-branch toy theory that it is an interval of width
> 0, contrasting with the singleton of `chain_derivOfLen_iff`.
**The key insight is** that the chain's *singleton* length set is the degenerate extreme of
a general interval, so "proof slack" is literally the diameter of this set — a directly
formalizable quantity.
**Why now**: the achievable-length set is already exposed by `minDerivLen`, so studying its
*spread* (not just its `sInf`) needs no new definitions.
**If true**: gives a clean scalar ("proof slack") tracking the existence→length transition.
**If false**: a singleton length set even with branching would mean redundancy never
shortens proofs — surprising and worth isolating.

### Direction 5: Probabilistic sharp threshold via the monotone-function bridge
**Hypothesis**: On `Fin n` with each directed edge present independently with probability
`p`, `Pr[Derivable T 0 (n−1)]` jumps from `≤ ε` to `≥ 1−ε` over an `o(1)` window around
`p*(n) ≈ log n / n`.
**Test**: Encode the event as a monotone Boolean function on `{0,1}^{n²}` (monotonicity is
`theory_extension_monotone`/`derivable_monotone` from the catalog and survives to `HDeriv`
via `hderiv_axioms_monotone`), then feed it to a to-be-formalized Friedgut/Bourgain
coarse-threshold theorem; estimate `p*` numerically for small `n`.
**The key insight is** that both the binary and hypergraph layers now expose derivability
as a genuinely *monotone* set function, so the only missing ingredient is the abstract
threshold theorem itself — the proof-theoretic content is fully discharged.
**Why now**: monotonicity is a one-liner in both layers, and the barrier lemmas supply the
low-density lower bound a sharp-threshold proof consumes.
**If true**: turns "proof phase transition" from metaphor into theorem, linking formal
proof theory to random-graph threshold machinery.
**If false**: a coarse threshold would reveal a genuine proof-theoretic obstruction (a
pivotal-axiom cluster) absent in ordinary connectivity.
