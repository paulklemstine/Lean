# Future Directions: Topological Descriptive Complexity

## Synthesis

The results in this work establish that tropical Morse spectra can detect topological invariants (β₁) invisible to every fixed level of the Weisfeiler–Leman hierarchy. This opens a new research program at the intersection of finite model theory, persistent homology, and tropical geometry. The directions below span three levels of ambition: extending the current cycle-based separation to full CFI generality (Directions 1–2), connecting to practical graph learning (Direction 3), and exploring deep structural questions about logic vs. topology (Directions 4–5).

---

## Direction 1: Full k-WL Separation via CFI over High-Treewidth Base Graphs

**Conjecture:** For every k ≥ 2, the CFI construction over a base graph with treewidth ≥ k+1 (e.g., K_{k+2}) produces graph pairs that are k-WL equivalent in the STANDARD sense and TMS-separated via β₁ asymmetry.

**Test:** Implement the CFI construction for K₄ (treewidth 3) and verify:
1. The two CFI graphs are 2-WL equivalent (check by running the 2-WL algorithm)
2. Their filtrations with non-uniform gadget weights produce different β₁
3. TMS separates them

**Impact:** This would complete the program: TMS escapes EVERY level of the WL hierarchy in the standard (not just atomic-type) sense. It would be the first theorem connecting descriptive complexity lower bounds directly to topological persistence.

**Catalog References:** `Pythagorean/TropicalMorse/KWLSeparation.lean` — `cycle_counts_differ`, `same_edges_diff_merge_diff_cycle`

**Proof Strategy:** Formalize the CFI construction as a Lean definition. Prove k-WL equivalence via the bijective pebble game (Duplicator strategy on the base graph). Prove β₁ separation by analyzing the homology of the CFI expansion.

**Domain Bridges:** Finite model theory ↔ Algebraic topology ↔ Combinatorial optimization

**Lineage:** Direct extension of `cycle_counts_differ`

**Ambition:** Grand challenge — would unify two major mathematical theories

---

## Direction 2: Higher-Dimensional Homological Separation

**Conjecture:** For every d ≥ 1 and k ≥ 1, there exist simplicial complexes (or clique complexes of graphs) that are k-WL equivalent but separated by β_d — the d-th Betti number computed from the tropical Morse filtration.

**Test:** Construct weighted flag complexes from CFI-type graphs. Compute β₂ for the two variants. If β₂ differs while k-WL colorings agree, the conjecture holds at d=2.

**Impact:** Would show that the entire persistence barcode in all dimensions is a richer invariant than any fixed WL level, not just the first Betti number.

**Catalog References:** `Pythagorean/TropicalMorse/KWLSeparation.lean` — `quantitative_gap`; `Bridges/Catalog/Pythagorean/TropicalMorse/HigherSimplicial.lean`

**Proof Strategy:** Use the Künneth formula and Mayer-Vietoris sequences to compute higher homology of CFI-like simplicial complexes. The key insight is that CFI twists induce torsion in higher homology groups.

**Domain Bridges:** Algebraic topology ↔ Descriptive complexity ↔ Computational topology

**Lineage:** Builds on `tms_event_separation` and higher-simplicial work

**Ambition:** Solid extension — technically demanding but conceptually clear

---

## Direction 3: TMS-Augmented Graph Neural Networks

**Conjecture:** Graph neural networks augmented with tropical Morse features (cycle-death count, merge sequence, critical values) achieve strictly better classification accuracy than unaugmented networks on standard benchmarks (MUTAG, PROTEINS, IMDB).

The key insight is that TMS features capture global topological information (β₁) that message-passing layers fundamentally cannot compute, as proven by our separation theorem.

Why now? The theoretical gap between WL expressiveness and topological invariants is now precisely characterized. Implementing TMS features is O(m log m) via Kruskal's algorithm, negligible compared to GNN training cost.

**Test:** Implement TMS feature extraction as a PyTorch module. Train GIN (Graph Isomorphism Network) with and without TMS augmentation. Measure classification accuracy gap on standard benchmarks.

**Impact:** Would translate theoretical expressiveness gaps into practical ML improvements. Could establish a new standard feature engineering pipeline for graph learning.

**Catalog References:** `Pythagorean/TropicalMorse/KWLSeparation.lean` — `cycle_death_discriminates`, `tms_separation_family`

**Proof Strategy:** Not a proof but an empirical study. The theoretical backing comes from `different_cycle_count_different_tms`.

**Domain Bridges:** Machine learning ↔ Topological data analysis ↔ Descriptive complexity

**Lineage:** Application of `tms_separation_family`

**Ambition:** Solid extension — high practical impact, builds directly on theory

---

## Direction 4: Tropical Phase Transitions and Statistical Physics

**Conjecture:** The parity-critical value in the weighted CFI construction corresponds to a phase transition in an associated Ising-type model. Specifically, the gadget weight at which the parity cycle appears in the filtration is the critical temperature of a constraint satisfaction system on the base graph.

The key insight is that the filtration threshold where β₁ jumps can be reinterpreted as a percolation threshold, and percolation thresholds are phase transitions.

Why now? The percolation-topology bridge (`percolation_topology_bridge` in the Lean formalization) makes the connection between filtration events and percolation precise. Extending to statistical mechanics requires only the standard transfer matrix formalism.

**Test:** For the cycle base graph C_n with non-uniform weights, compute:
1. The filtration threshold τ where β₁ jumps
2. The partition function Z(β) of the nearest-neighbor Ising model on the CFI graph
3. Check if the free energy F(β) = -log Z(β)/β has a singularity at β = 1/τ

**Impact:** Would connect topological descriptive complexity to statistical physics, opening a new route to computational complexity lower bounds via phase transition barriers.

**Catalog References:** `Pythagorean/TropicalMorse/Theorems.lean` — `percolation_transition_count`; `KWLSeparation.lean` — `connected_cycle_count`

**Proof Strategy:** Use the transfer matrix for the Ising model on the cycle to compute Z exactly. Show that the free energy singularity structure reflects the filtration topology.

**Domain Bridges:** Statistical physics ↔ Topological data analysis ↔ Computational complexity

**Lineage:** Extends percolation-topology bridge

**Ambition:** Grand challenge — would create an entirely new theoretical framework

---

## Direction 5: Tropical Descriptive Complexity as a Formal Theory

**Conjecture:** There exists a formal logical system — "tropical counting logic" TCL^k — that extends C^k with tropical/min-plus aggregation operators, such that TCL^k captures exactly the TMS-computable invariants for k-tuple filtrations.

The key insight is that TMS computations are essentially tropical (min-plus) linear algebra operations on the edge weight matrix. A logical framework for these operations would characterize TMS expressiveness the same way C^k characterizes WL.

Why now? The separation results give the first examples where the gap between C^k and TMS is precise and formal. A logical characterization would systematize these examples into a general theory.

**Test:** Define TCL^2 (2-variable tropical counting logic). Show:
1. TCL^2 can express β₁ for 2-regular graphs
2. C^2 cannot express β₁
3. TCL^2 ⊆ PTIME (the invariants are polynomial-time computable)

**Impact:** Would found a new branch of descriptive complexity theory incorporating metric/topological semantics. Could lead to new characterizations of complexity classes via topological logics.

**Catalog References:** `Pythagorean/TropicalMorse/KWLSeparation.lean` — all main theorems

**Proof Strategy:** Start with the Immerman-Vardi theorem framework. Add tropical semiring operations (min, +) to the logic. Prove the equivalence with TMS computations via an Ehrenfeucht-Fraïssé game argument.

**Domain Bridges:** Mathematical logic ↔ Tropical geometry ↔ Computational complexity

**Lineage:** Builds on entire catalog

**Ambition:** Grand challenge — paradigm-shifting if successful
