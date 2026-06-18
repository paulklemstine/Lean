# Future Directions: Executable Recomputation Kernels with Verified Complexity Bounds

## Overview

The formalized incremental recomputation kernel establishes a foundational link between **semantic locality** (only a bounded "cone" of vertices is affected by an update) and **computational locality** (the algorithm's work scales with the cone, not the ambient graph). This opens several concrete research frontiers.

---

## Direction 1: Query-Optimal Lower Bounds for Cone-Local Recomputation

**Hypothesis:** Any correct incremental recomputation algorithm for DAG levels must inspect at least every vertex in the affected cone and every edge entering it. The cone-linear upper bound is therefore *tight*.

**Approach:**
- Model the recomputation problem as an adaptive query process where each query reveals a predecessor set or a predecessor's level.
- Construct an adversarial family of DAGs where any algorithm that skips a cone vertex or predecessor edge can be fooled into producing an incorrect level.
- Formalize this as a certified lower bound theorem: `∀ algorithm, ∃ input, work(algorithm, input) ≥ |cone| + |E_cone|`.

**Cross-domain connection:** This connects incremental computation to communication complexity and information-theoretic lower bounds. A formal gap between upper and lower bounds would be the first certified optimality result for dynamic graph algorithms.

**Concrete next step:** Define an `OracleAlgorithm` type that interacts with a predecessor oracle, prove that any such algorithm producing correct levels must query at least `|cone|` vertices.

---

## Direction 2: Monotone Semiring Valuations and Tropical Generalization

**Hypothesis:** The level function `v ↦ 1 + sup(predecessors)` is a special case of a max-plus (tropical) linear recurrence. The incremental kernel generalizes to arbitrary monotone semiring valuations over acyclic dependency graphs.

**Approach:**
- Replace `ℕ` with an arbitrary ordered semiring `(S, ⊕, ⊗, ≤)` where `⊕` is the "join" and `⊗` is the "combine" operation.
- Define `recomputeLevel` as `⊗(unit, ⊕{s(u) | u ∈ pred(v)})` for an appropriate unit.
- Prove the same fold-correctness and complexity theorems in this abstract setting.
- Instantiate to recover: DAG levels (max-plus over ℕ), shortest paths (min-plus over ℝ≥0 ∪ {∞}), widest paths (max-min), Boolean reachability (OR-AND).

**Cross-domain connection:** This bridges to tropical geometry, where semiring valuations over graphs connect to Newton polytopes and algebraic geometry. A certified tropical Bellman propagation kernel would be new.

**Concrete next step:** Define a `MonotoneSemiringValuation` typeclass, generalize `recomputeLevel`, and prove the fold invariant in the abstract setting.

---

## Direction 3: Localized Fixpoint Maintenance for Temporal Logic

**Hypothesis:** Model checking a temporal logic formula (CTL, μ-calculus) on a finite Kripke structure is a fixpoint computation on a dependency graph. When the Kripke structure is locally modified, the truth values can be incrementally maintained by recomputing only within the affected cone.

**Approach:**
- Formalize the connection between DAG level computation and monotone fixpoint iteration on finite lattices.
- Show that the incremental fold is equivalent to one-pass fixpoint stabilization on the restricted cone operator.
- Extend from DAG levels to nested fixpoints (alternation depth > 1) by layering cone computations.
- Prove that incremental model checking of μ-calculus formulas on locally-modified Kripke structures has complexity proportional to the affected region, not the full structure.

**Cross-domain connection:** This creates a formal bridge between verified compilation (dependency maintenance) and verified model checking (temporal logic evaluation). The same kernel architecture serves both domains.

**Concrete next step:** Define a `KripkeStructure` type with local modification operations, formalize the cone induced by a formula + modification pair, and prove incremental model checking correctness.

---

## Direction 4: Certified Self-Adjusting Computation Framework

**Hypothesis:** The incremental fold pattern generalizes to a *self-adjusting computation* framework where arbitrary pure functions over DAG-structured inputs can be incrementally maintained under local input changes.

**Approach:**
- Define a `Computation` type that records the dependency graph of a pure functional computation.
- Instrument computations with automatic dependency tracking (analogous to Acar's self-adjusting computation, but with machine-checked correctness).
- Prove that the `incrementalFold` pattern, when applied to the recorded dependency graph, correctly updates the computation's output.
- Prove complexity bounds showing that the update cost is proportional to the "change propagation region" — the set of intermediate values that actually change.

**Cross-domain connection:** This connects to adaptive algorithms, incremental view maintenance in databases, and reactive programming. A formally verified self-adjusting computation library would be the first of its kind.

**Concrete next step:** Define a `TrackedComputation V S` monad that records dependencies, prove that replay via `incrementalFold` is correct, and demonstrate on a concrete example (e.g., incremental list sorting).

---

## Direction 5: Sparse Neural Update Certificates

**Hypothesis:** Message-passing neural networks (GNNs) compute vertex features by iterating a local aggregation rule over a graph — mathematically identical to iterated level computation. When the graph is locally modified, the network's output can be incrementally updated by recomputing only within the receptive field cone.

**Approach:**
- Formalize the connection between GNN message-passing rounds and iterated `recomputeLevel` with a general aggregation function.
- Define the "receptive field cone" of depth `k` around a modified vertex as the set of vertices whose `k`-hop neighborhood intersects the modification.
- Prove that the incremental kernel correctly updates GNN features with work proportional to the receptive field size.
- Extend to attention-based aggregation (transformers on graphs) where the "predecessor function" depends on the current feature values.

**Cross-domain connection:** This bridges formal verification to machine learning systems. A certified sparse update theorem for GNNs would enable provably efficient incremental inference in dynamic graph neural networks — relevant to recommendation systems, molecular dynamics, and traffic prediction.

**Concrete next step:** Define a `MessagePassingLayer` structure parameterized by aggregation and update functions, prove that `incrementalFold` correctly implements sparse feature updates for a single layer, then compose across layers.

---

## Summary Table

| Direction | Domain Bridge | Key Formalization Target | Estimated Difficulty |
|-----------|--------------|--------------------------|---------------------|
| 1. Query lower bounds | Complexity theory ↔ algorithms | `∀ alg, ∃ input, work ≥ |cone| + |E|` | Medium |
| 2. Tropical generalization | Algebra ↔ graph algorithms | `MonotoneSemiringValuation` typeclass | Medium |
| 3. Temporal logic | Verification ↔ model checking | Incremental μ-calculus evaluation | Hard |
| 4. Self-adjusting computation | PL theory ↔ dynamic algorithms | `TrackedComputation` monad | Hard |
| 5. Sparse neural updates | ML ↔ formal methods | `MessagePassingLayer` correctness | Medium |

Each direction is independent and can be pursued in parallel. Directions 1–2 are the most immediately tractable; directions 3–5 require more infrastructure but have higher impact.
