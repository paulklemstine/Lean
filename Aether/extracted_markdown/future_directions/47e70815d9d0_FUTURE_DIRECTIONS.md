# Future Directions: Tropical Hypergraph Counterpoint

## Overview

This document outlines breakthrough-level research opportunities opened by the formalization of SATB counterpoint as tropical optimization on weighted hypergraphs. Each direction includes concrete hypotheses, proof strategies, and cross-domain connections.

---

## Direction 1: Min-Plus Factor Graph Inference for Finite-Horizon SATB Harmonization

### Hypothesis
Finite-horizon SATB harmonization is equivalent to min-plus inference on a factor graph where factors correspond to voice pairs and variables correspond to per-voice pitch sequences.

### Proof Strategy
1. Formalize factor graphs over the min-plus semiring (ℝ ∪ {+∞}, min, +).
2. Show that `totalPenalty6` decomposes into six factors, each depending on two voice variables.
3. Prove that the min-plus belief propagation algorithm on this factor graph converges in one pass (since the temporal graph is acyclic).
4. Establish that the resulting Viterbi-style decoding produces an optimal SATB harmonization.

### Complexity Analysis
- Brute-force over `|P|^4` chords × `n` steps: O(n · |P|^8).
- Factor-graph elimination with treewidth 2: O(n · |P|^4) — exponential compression in voice count.
- Formal theorem target: prove the treewidth bound on the SATB factor graph.

### Cross-Domain Connections
- Probabilistic graphical models and Bayesian inference
- Viterbi decoding in hidden Markov models
- Constraint satisfaction and arc consistency
- Weighted model counting in SAT

---

## Direction 2: Stylistic Energies from Chorale Statistics

### Hypothesis
Replacing hard legality indicators (0/1 penalties) with soft statistical energies learned from a corpus (e.g., Bach chorales) preserves the tropical algebraic structure while enabling style-specific optimization.

### Proof Strategy
1. Define parameterized pairwise energies `E_θ(i, j, v, w) : ℝ≥0` learned from data.
2. Show that the zero-locus theorem generalizes: the penalty is zero only on the empirical support of legal transitions.
3. Prove that the Boltzmann distribution over progressions in the low-temperature limit concentrates on tropical geodesics.
4. Formalize the connection between max-likelihood estimation of `θ` and tropical regression.

### Key Formalization Targets
- `softPenalty_converges_to_hard`: As temperature → 0, soft penalties converge to hard indicators.
- `tropicalRegression_consistency`: MLE on the parameterized tropical model is consistent.

### Cross-Domain Connections
- Statistical mechanics and Gibbs distributions
- Tropical regression and max-plus statistics
- Neural network loss surfaces as tropical hypersurfaces
- Style transfer in generative AI

---

## Direction 3: Tropical Variety Structure on the Legal Chord-Transition Set

### Hypothesis
The set of legal SATB transitions forms a tropical variety — the corner locus of a tropical polynomial system in pitch coordinates.

### Proof Strategy
1. Express each pairwise penalty as a tropical polynomial in voice pitches.
2. Show that `NoParallelFifthsPair` defines a tropical hypersurface in ℤ^8 (two 4-voice chords).
3. Prove that the intersection of these six tropical hypersurfaces gives the legal set.
4. Compute the tropical dimension and degree of this variety.

### Key Formalization Targets
- `legal_set_is_tropical_prevariety`: The legal set equals ⋂ᵢ V_trop(fᵢ) for tropical polynomials fᵢ.
- `tropical_dimension_legal_set`: The tropical dimension equals 8 - rank of the constraint Jacobian (generically).

### Mathematical Significance
This would be the first instance of a musical constraint system identified as a tropical algebraic variety, opening connections to:
- Tropical intersection theory
- Berkovich analytic spaces
- Non-Archimedean amoebas
- Algebraic complexity theory

---

## Direction 4: Existence and Uniqueness of Minimal-Cost Reharmonizations

### Hypothesis
Given boundary conditions (fixed first and last chords) and a finite pitch set, there exists a minimum-cost SATB progression, and under genericity conditions on the penalties, it is unique.

### Proof Strategy
1. Prove existence by compactness: the space of progressions over a finite pitch set is finite, hence the infimum is attained.
2. For uniqueness, define a strict convexity condition on the penalty functional (or use a lexicographic tiebreaker).
3. Characterize when multiple optimal progressions exist (degenerate tropical polytope structure).

### Key Formalization Targets
- `exists_min_cost_progression`: Existence of an optimizer over `Fin P → Chord`.
- `unique_optimal_under_perturbation`: Generic uniqueness after infinitesimal penalty perturbation.
- `optimal_progression_bellman`: The optimizer satisfies the Bellman equation from `SATBTropicalDP.lean`.

### Cross-Domain Connections
- Discrete optimal transport
- Shortest path algorithms (Dijkstra, Bellman-Ford)
- Linear programming duality in tropical geometry
- Network flow optimization

---

## Direction 5: Certified Decoding in Sequence Models via Tropical Factorization

### Hypothesis
The pairwise tensor factorization of SATB cost generalizes to any sequence model whose transition penalties decompose over pairwise interactions, enabling certified decoding with formal correctness guarantees.

### Proof Strategy
1. Abstract the SATB framework to a general `k`-agent system with pairwise penalties.
2. Prove that the factorization theorem (`progression_cost_factorizes_over_pairs`) holds for arbitrary `k`.
3. Show that certified decoding (finding the zero-cost path or proving none exists) reduces to solving `k(k-1)/2` coupled 2-agent problems.
4. Formalize the connection to tensor networks and prove that contraction order determines computational complexity.

### Key Formalization Targets
- `k_agent_factorization`: Generalization of `progression_cost_factorizes_over_pairs` to `Fin k`.
- `certified_decode_correctness`: If the decoder returns a path, it is optimal; if it returns ⊥, no legal path exists.
- `tensor_network_contraction`: Optimal contraction order gives O(k² · |P|²) per step.

### Cross-Domain Connections
- Tensor network contraction in quantum computing
- Beam search and A* with admissible heuristics
- Certified compilation and verified code generation
- Safe multi-robot coordination with pairwise collision avoidance

---

## Direction 6: Tropical Automata and Weighted Language Theory for Counterpoint

### Hypothesis
Legal SATB progressions form a weighted language over a tropical semiring, and the associated weighted automaton has a factored state space whose structure mirrors the pairwise decomposition.

### Proof Strategy
1. Define a weighted finite automaton over (ℝ≥0, +, ·) where states are chords and transitions carry `totalPenalty6` weights.
2. Prove that the accepted language (zero-weight paths) equals the set of legal progressions.
3. Show that the automaton factors as a synchronous product of six 2-voice automata.
4. Compute the Myhill-Nerode index of the legal language restricted to a finite pitch set.

### Key Formalization Targets
- `satb_automaton_accepts_legal`: Formal automaton-language equivalence.
- `automaton_product_decomposition`: Factored state space theorem.
- `myhill_nerode_bound`: Upper bound on the number of equivalence classes.

### Cross-Domain Connections
- Weighted automata and transducers
- Formal language theory and regular expressions
- Symbolic dynamics and shifts of finite type
- Model checking and temporal logic verification

---

## Direction 7: Multi-Agent Safety Constraints as Tropical Energy Landscapes

### Hypothesis
The SATB framework generalizes to multi-agent systems where safety constraints (collision avoidance, communication bounds, formation maintenance) are modeled as pairwise tropical penalties, and safe trajectories are tropical geodesics.

### Proof Strategy
1. Abstract `Voice → ℤ` to `Agent → State` for a finite set of agents.
2. Define pairwise safety predicates (e.g., minimum distance, maximum communication range).
3. Prove that the zero-locus theorem transfers: safe configurations are exactly the zero set of the aggregate tropical penalty.
4. Show that safe trajectory planning reduces to shortest-path computation in the induced tropical hypergraph.

### Applications
- Drone swarm coordination with collision avoidance
- Autonomous vehicle platoon management
- Robotic assembly with clearance constraints
- Distributed protocol verification

---

## Implementation Priorities

### Phase 1 (Immediate, 1-3 months)
- Direction 1: Factor graph formalization and Viterbi-style decoding
- Direction 4: Existence of optimal progressions via finiteness

### Phase 2 (Medium-term, 3-6 months)
- Direction 5: Generalization to k-agent systems
- Direction 6: Weighted automaton formalization

### Phase 3 (Long-term, 6-12 months)
- Direction 3: Tropical variety computation
- Direction 2: Statistical learning of tropical energies
- Direction 7: Multi-agent safety applications

### Validation Strategy
Each direction should be validated by:
1. Computational experiments (Python implementations demonstrating the theorems)
2. Formal proofs in Lean 4 (extending the existing `TropicalHypergraphCounterpoint.lean`)
3. At least one concrete worked example (specific chord progressions, specific agent configurations)
4. Complexity analysis comparing the tropical approach to brute-force alternatives
