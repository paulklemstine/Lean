# Future Directions: Tropical Morse Spectra and Quantum Graph Codes

## Synthesis

The results established in this work — the logical qubit correspondence (k = β₁), the tropical distance bound (fcb ≤ d), and the exact distance theorem in the simple-cycle regime (d = girth) — create a new interface between tropical geometry and quantum error correction. This interface is not merely analogical: it provides computationally efficient, certified bounds on code parameters through spectral invariants of the interaction graph.

The five directions below extend this interface along complementary axes: (1) generalizing the exact distance theorem beyond the simple-cycle regime, (2) using the full spectrum for decoding, (3) connecting to persistent homology for richer topological invariants, (4) bridging to statistical mechanics of error correction, and (5) extending to higher-dimensional codes and quantum LDPC codes. Together, they chart a research program that could transform how quantum codes are designed, analyzed, and decoded.

---

## Direction 1: Weighted Distance Equality via Tropical Cycle Optimization

**Conjecture:** For graph-derived CSS codes with arbitrary positive edge weights, the code distance equals the minimum total weight of a simple cycle in the interaction graph. Under an appropriate "girth-adapted" filtration (edges ordered by a cycle-aware criterion), the first cycle birth value equals this minimum cycle weight.

**Test:** Construct random weighted graphs on 8–20 vertices with weights drawn from {1, 2, ..., 10}. Compute:
- The minimum-weight simple cycle (by exhaustive search for small graphs).
- The first cycle birth under Kruskal filtration.
- The first cycle birth under a modified filtration that orders edges by their contribution to shortest cycles.
If the girth-adapted FCB equals the minimum cycle weight in >95% of cases, the conjecture is supported. If it fails, identify the structural obstruction.

**Impact:** Would extend the exact distance theorem from unit weights to arbitrary weights, making the tropical approach directly applicable to quantum hardware with non-uniform coupling strengths.

**Catalog References:**
- `Pythagorean/TropicalMorse/QuantumGraphCodes.lean`: `codeDistance_eq_firstCycleBirth_of_simpleCycle`
- `Pythagorean/TropicalMorse/Theorems.lean`: `redundant_edges_eq_cycle_rank`

**Proof Strategy:** Define a "cycle-adapted" weight ordering that processes edges in order of their minimum-cycle-weight contribution. Prove that under this ordering, the first cycle birth equals the minimum cycle weight. Use the monotonicity theorem to bootstrap from the unit-weight case.

**Domain Bridges:** Tropical geometry ↔ combinatorial optimization ↔ quantum hardware design.

**Lineage:** Direct extension of Theorem 3 (exact distance in simple-cycle regime).

**Ambition:** Solid extension — requires new combinatorial arguments but builds directly on established foundations.

**The key insight is** that the filtration ordering determines which cycle appears first, and an intelligently chosen ordering can make the first cycle birth coincide with the minimum-weight cycle.

**Why now?** The monotonicity theorem provides the key tool: if we can show that the girth-adapted filtration maximizes the first cycle birth among all filtrations, the result follows.

---

## Direction 2: Spectral Decoding via Tropical Morse Barcodes

**Conjecture:** The full tropical Morse spectrum (not just the first cycle birth) encodes sufficient information to construct an efficient minimum-weight decoder for graph-CSS codes. Specifically, the barcode structure — the persistence intervals of cycle events — identifies likely error patterns and guides syndrome-based correction.

**Test:** Implement a "tropical decoder" that uses the TMS barcode to weight the edges of the decoding graph. Compare decoder performance (logical error rate vs. physical error rate) against:
- Minimum-weight perfect matching (MWPM) decoder.
- Union-find decoder.
Test on surface codes of sizes 3×3, 5×5, 7×7 under depolarizing noise at rates p = 0.01, 0.05, 0.10. If the tropical decoder achieves comparable or better logical error rates, the conjecture is supported.

**Impact:** Would provide a new class of decoders inspired by tropical geometry, potentially with better scaling or simpler implementation than existing approaches.

**Catalog References:**
- `Pythagorean/TropicalMorse/Defs.lean`: `TMSpectrum`, `tropicalMorseComplexity`
- `Pythagorean/TropicalMorse/Theorems.lean`: `spectral_gap_distinguishes`

**Proof Strategy:** Show that the barcode persistence intervals correspond to "error vulnerability windows" — ranges of error weights where specific logical operators become active. Use this to construct a weight function for the decoding graph that penalizes edges in high-vulnerability regions.

**Domain Bridges:** Persistent homology ↔ quantum error correction ↔ algorithmic graph theory.

**Lineage:** Extends the spectral classification theorem (Theorem 5) from static classification to dynamic error correction.

**Ambition:** Grand challenge — connects two major research programs (persistent homology and quantum decoding) through a concrete algorithmic proposal.

**The key insight is** that the tropical Morse barcode encodes not just the *number* of logical operators but their *weight hierarchy*, which is exactly the information a decoder needs to distinguish likely from unlikely errors.

**Why now?** The TMS computation is O(E log E), making it feasible to run in real-time as a preprocessing step for decoding. Recent advances in barcode-guided algorithms in topological data analysis provide the technical toolkit.

---

## Direction 3: Higher-Dimensional Tropical Morse Theory for Quantum LDPC Codes

**Conjecture:** The tropical Morse theory framework extends to simplicial complexes of dimension ≥ 2, and the resulting higher-dimensional tropical Morse spectrum determines the parameters of CSS codes derived from chain complexes (including hypergraph product codes, fiber bundle codes, and balanced product codes).

**Test:** Implement a simplicial tropical filtration for:
- The 2D toric code (as a simplicial complex on the torus).
- Hypergraph product codes HP(H₁, H₂) for random LDPC matrices H₁, H₂ of size 10×20.
- Balanced product codes for small group algebras.
Compute β₁ and β₂ from the filtration and compare with known code parameters. If the higher-dimensional β values correctly predict k and d bounds for ≥90% of test cases, the conjecture is supported.

**Impact:** Would extend the tropical Morse framework to the most promising class of quantum codes for fault-tolerant computing (quantum LDPC codes), where asymptotically good parameters have been recently demonstrated.

**Catalog References:**
- `Bridges/Catalog/Pythagorean/TropicalMorse/HigherSimplicial.lean`: higher-dimensional extensions
- `Pythagorean/TropicalMorse/QuantumGraphCodes.lean`: `filtration_exclusive_dichotomy`

**Proof Strategy:** Define the higher-dimensional filtration as the sublevel set filtration of the weight function on the simplicial complex. The key technical challenge is proving the analogue of the exclusive dichotomy: each simplex addition changes exactly one Betti number. This follows from the long exact sequence in homology for the pair (K_≤t, K_≤t').

**Domain Bridges:** Higher-dimensional tropical geometry ↔ homological algebra ↔ quantum LDPC codes ↔ expander theory.

**Lineage:** Natural generalization of all four main theorems to higher dimensions.

**Ambition:** Grand challenge — requires substantial new mathematical development and connects to the frontier of quantum LDPC code theory.

**The key insight is** that the exclusive dichotomy theorem (each edge addition changes exactly one Betti number) generalizes to simplices of all dimensions, and this generalization is exactly what's needed to extend the logical qubit and distance theorems.

**Why now?** The recent breakthroughs in quantum LDPC codes (achieving constant rate and polynomial distance) create urgent demand for new analytical tools. Tropical Morse theory provides a natural framework that has been waiting for this application.

---

## Direction 4: Statistical Mechanics of Decoding via Tropical Percolation

**Conjecture:** The tropical Morse spectrum of a quantum code's interaction graph determines the critical error threshold for maximum-likelihood decoding, analogous to the bond percolation threshold in the random-bond Ising model. Specifically, the "tropical percolation threshold" — the weight at which half of all cycle events have occurred — predicts the threshold error rate within 10%.

**Test:** For surface codes of sizes n = 5, 7, 9, 11:
- Compute the tropical percolation threshold t_trop = median cycle birth value.
- Run Monte Carlo simulations to estimate the ML decoding threshold p_c.
- Compare t_trop / max_weight with p_c.
If the correlation is > 0.9 across all sizes, the conjecture is supported.

**Impact:** Would provide a new analytical prediction for decoding thresholds, bypassing expensive Monte Carlo simulations and potentially explaining why certain code families have higher thresholds than others.

**Catalog References:**
- `Pythagorean/TropicalMorse/Theorems.lean`: `percolation_transition_count`, `giant_component_threshold`

**Proof Strategy:** The tropical filtration is formally isomorphic to the bond percolation process. The cycle events correspond to loop formations in percolation. Show that the density of cycle events near the percolation threshold controls the error-correction capacity, using duality between the Nishimori line and the tropical critical surface.

**Domain Bridges:** Statistical mechanics ↔ tropical geometry ↔ quantum error correction ↔ percolation theory.

**Lineage:** Extends the percolation connection already established in `percolation_transition_count` to a quantitative prediction.

**Ambition:** Grand challenge — connects three deep theories (statistical mechanics, tropical geometry, quantum error correction) through a falsifiable quantitative prediction.

**The key insight is** that the tropical filtration is literally a percolation process, and the statistics of cycle events in the filtration directly control the code's error-correction capacity.

**Why now?** Recent work on the statistical mechanics of quantum error correction (the random-bond Ising model approach) provides the theoretical context, and the tropical Morse computation provides the efficient computational tool.

---

## Direction 5: Tropical Optimization of Quantum Hardware Layouts

**Conjecture:** For a fixed graph topology, the edge weight assignment that maximizes the first cycle birth value in the tropical filtration also maximizes the code distance. Moreover, this optimal weight assignment can be found in polynomial time via linear programming.

**Test:** For grid graphs of size 3×3, 4×4, 5×5:
- Formulate the FCB maximization as an LP: maximize fcb subject to weight constraints (e.g., total weight budget, individual weight bounds).
- Compare the optimal FCB from the LP with the actual code distance under the optimal weights.
- Compare with random weight assignments to quantify the improvement.
If the LP-optimal FCB equals the code distance in all test cases and improves over random weights by ≥ 20%, the conjecture is supported.

**Impact:** Would provide a practical optimization algorithm for quantum hardware design: given physical constraints (qubit locations, coupler strengths), find the weight assignment that maximizes error tolerance.

**Catalog References:**
- `Pythagorean/TropicalMorse/QuantumGraphCodes.lean`: `monotone_weights_monotone_distanceBound`, `distance_rate_tradeoff`

**Proof Strategy:** Show that FCB maximization under linear constraints is a linear program (the FCB function is piecewise-linear in the weights). Prove that the LP solution gives the true distance optimum by combining the monotonicity theorem with the distance lower bound.

**Domain Bridges:** Combinatorial optimization ↔ tropical geometry ↔ quantum hardware engineering ↔ linear programming.

**Lineage:** Direct application of the monotonicity theorem (Theorem 4) to optimization.

**Ambition:** Solid extension — the mathematical tools are in place; the main challenge is the LP formulation and proof of optimality.

**The key insight is** that the monotonicity theorem converts a combinatorial optimization problem (maximize code distance) into a continuous optimization problem (maximize FCB over weight assignments), which can be solved efficiently.

**Why now?** The monotonicity theorem provides the theoretical justification, and the near-linear-time TMS computation makes the approach scalable to hardware-relevant graph sizes (hundreds to thousands of qubits).
