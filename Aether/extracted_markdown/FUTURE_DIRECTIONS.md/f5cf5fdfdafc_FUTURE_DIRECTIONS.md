# Future Directions: Tropical Morse Theory for Graph Neural Networks

## Synthesis

The tropical Morse spectrum bridges three mathematical worlds: tropical geometry (min-plus algebra and weight filtrations), algebraic topology (persistent homology and Betti numbers), and theoretical computer science (Weisfeiler-Leman expressiveness hierarchy). Our formal verification of the strict expressiveness theorem, stability theorem, and Morse-Betti correspondence establishes a rigorous foundation for using topological features in machine learning. The five directions below radiate outward from this foundation, each attacking a different frontier: the full WL hierarchy separation (Direction 1), differentiable computation for end-to-end learning (Direction 2), quantum-topological connections (Direction 3), practical algorithm engineering (Direction 4), and higher-dimensional generalization (Direction 5). Together, they constitute a research program for **Tropical Topological Deep Learning** — a new paradigm where graph neural networks are augmented with formally verified topological invariants that provably exceed the expressiveness of message-passing.

---

## Direction 1: Full k-WL Separation via Non-Uniform CFI Weights

**Conjecture:** For every fixed k ∈ ℕ, there exist edge-weighted graphs G₁, G₂ such that k-WL(G₁) = k-WL(G₂) but TMS(G₁) ≠ TMS(G₂). Specifically, the Cai-Fürer-Immerman graph pairs built from n-cycles with n > k, equipped with non-uniform gadget weights w_gadget = 1/(2i+1) for gadget i, achieve TMS separation through differing H₁ barcode lengths.

**Test:** (1) Implement CFI construction with non-uniform weights for k = 2, 3, 4. (2) Verify k-WL equivalence using the pebble game. (3) Compute TMS and check that exactly one H₁ barcode endpoint differs. (4) Falsified if all weight assignments yield identical TMS for any k.

**Impact:** Would establish TMS as the first single, efficiently computable graph invariant that provably exceeds the entire WL hierarchy for weighted graphs. This would be a landmark result in descriptive complexity theory.

**Catalog References:**
- `Pythagorean/TropicalMorse/Theorems.lean`: `tms_strictly_expressive_over_WL1` (1-WL case)
- `Pythagorean/TropicalMorse/Theorems.lean`: `spectral_gap_contrapositive` (separation mechanism)
- `Pythagorean/TropicalMorse/Defs.lean`: `TMSpectrum`, `WL1Equiv`

**Proof Strategy:** Extend the formal framework to include k-WL equivalence (defined as the k-variable counting logic equivalence). Use the CFI symmetry lemma: CFI pairs are k-WL equivalent for k < dim(base graph). Then show that non-uniform weights break the parity symmetry in the weight filtration, producing a critical value gap in the H₁ barcode at the "parity cycle" threshold.

**Domain Bridges:** Descriptive complexity ↔ Tropical geometry ↔ Finite model theory

**Lineage:** Builds on Cai-Fürer-Immerman (1992) + our strict expressiveness theorem

**Ambition:** Grand challenge — would resolve a major open question in GNN expressiveness theory

---

## Direction 2: Differentiable Tropical Morse Features for End-to-End Learning

**Conjecture:** The tropical Morse spectrum, while piecewise-constant in edge weights, admits a smooth relaxation via the soft-min function: replacing the hard threshold t with a temperature-parameterized sigmoid produces a differentiable approximation whose gradient has O(E) sparsity and O(E log E) computation time.

**Test:** (1) Implement the soft-TMS with temperature parameter τ. (2) Verify that as τ → 0, soft-TMS → hard TMS. (3) Train a GNN on MUTAG with soft-TMS features; compare test accuracy against standard GNN and GNN + hard-TMS. (4) Falsified if soft-TMS gradients are dense (O(E²) nonzeros) or if convergence requires τ → 0 faster than O(1/√epoch).

**Impact:** Would enable fully differentiable training of GNNs with topological features, resolving the main practical barrier to adoption.

**Catalog References:**
- `Pythagorean/TropicalMorse/Theorems.lean`: `sublevel_perturbation_containment` (stability foundation)
- `Pythagorean/TropicalMorse/Defs.lean`: `sublevelAdj` (threshold mechanism to relax)

**Proof Strategy:** Define soft-sublevel adjacency: softAdj(G, t, i, j) = σ((t - w(i,j))/τ) where σ is the sigmoid. Show that the soft Betti numbers are differentiable in w and t, with Lipschitz constant 1/τ. Use the stability theorem to bound the approximation error.

**Domain Bridges:** Optimization theory ↔ Tropical geometry ↔ Deep learning

**Lineage:** Extends stability theorem + connects to differentiable rendering literature

**Ambition:** Solid extension — engineering challenge with clear theoretical grounding

---

## Direction 3: Tropical Morse Spectra as Quantum Graph State Classifiers

**Conjecture:** The tropical Morse spectrum of the interaction graph of a quantum error-correcting code determines the code distance and the number of logical qubits. Specifically, for CSS codes built from a graph G, the code distance equals the minimum critical value gap in TMS(G), and the number of logical qubits equals β₁(G).

**Test:** (1) Construct the interaction graphs of the [[7,1,3]] Steane code, [[9,1,3]] Shor code, and surface codes on n×n grids for n = 3,5,7. (2) Compute TMS and extract critical value gaps. (3) Verify that min gap = code distance. (4) Falsified if the relationship breaks for any CSS code.

**Impact:** Would establish a direct bridge between tropical geometry and quantum error correction, potentially enabling topological optimization of quantum codes via TMS gradient descent.

**Catalog References:**
- `Pythagorean/TropicalMorse/Theorems.lean`: `redundant_edges_eq_cycle_rank` (β₁ computation)
- `Pythagorean/TropicalMorse/Theorems.lean`: `morse_betti_correspondence` (topological invariants)

**Proof Strategy:** For CSS codes, the logical operators correspond to non-trivial cycles in the code graph. The code distance is the minimum-weight logical operator, which corresponds to the shortest non-trivial cycle in the weight filtration. Show that this equals the minimum critical value at which a cycle event occurs.

**Domain Bridges:** Quantum information theory ↔ Tropical geometry ↔ Algebraic topology

**Lineage:** Novel cross-domain connection enabled by the Morse-Betti correspondence

**Ambition:** Grand challenge — paradigm-shifting if correct, connects two major fields

---

## Direction 4: Verified O(E log E) Implementation with Correctness Certificate

**Conjecture:** The Kruskal-based TMS algorithm can be fully formalized in Lean 4 with a machine-checked proof that (1) it terminates, (2) it produces a valid TMSpectrum (sorted, complete), and (3) the event types correctly reflect the topology changes (each merge reduces β₀ by 1, each cycle increases β₁ by 1).

**Test:** (1) Formalize union-find with path compression in Lean 4. (2) Prove the O(E α(V)) amortized bound. (3) Formalize the Kruskal loop with the invariant that β₀ + β₁ counts correctly. (4) Extract executable code via Lean's compiler. (5) Falsified if the extracted code disagrees with the Python implementation on any test case.

**Impact:** Would produce the first formally verified topological data analysis algorithm, establishing a new standard for trustworthy scientific computing.

**Catalog References:**
- `Pythagorean/TropicalMorse/Defs.lean`: `FiltrationStep`, `TMSpectrum`
- `Pythagorean/TropicalMorse/Theorems.lean`: `cycle_rank_additive_over_filtration` (correctness invariant)
- `Pythagorean/TropicalBridge/FiltrationPersistence.lean`: `tropicalKernelDim_of_barcode` (barcode reconstruction)

**Proof Strategy:** Use the existing `Filtration` structure as the specification. Define a computable function `computeTMS : EdgeWeightedGraph n → TMSpectrum` and prove it produces the same event sequence as the abstract specification. The key lemma is that Kruskal's edge ordering is a valid filtration ordering.

**Domain Bridges:** Verified programming ↔ Algorithm design ↔ Topological data analysis

**Lineage:** Direct extension of current formalization + catalog filtration theory

**Ambition:** Solid extension — tractable with current Lean 4 tooling

---

## Direction 5: Higher-Dimensional Tropical Morse Theory for Simplicial Complexes

**Conjecture:** The tropical Morse spectrum generalizes from graphs (1-skeleta) to simplicial complexes of arbitrary dimension, yielding a complete invariant for the persistent homology barcode in all dimensions. For a weighted d-dimensional simplicial complex K with weight function w on simplices, the d-dimensional TMS records critical values where H_k changes for 0 ≤ k ≤ d, and the resulting invariant is strictly more expressive than the d-WL test.

**Test:** (1) Define the TMS for weighted 2-complexes (triangulated surfaces). (2) Compute TMS for the torus, Klein bottle, and projective plane with random edge/face weights. (3) Verify that TMS distinguishes them while 2-WL does not. (4) Falsified if 2-WL already distinguishes all weighted 2-complexes tested.

**Impact:** Would extend the entire tropical Morse framework from graph theory to computational topology, opening applications in mesh analysis, computational geometry, and topological materials science.

**Catalog References:**
- `Pythagorean/TropicalMorse/Theorems.lean`: `euler_char_from_filtration` (1D case to generalize)
- `Pythagorean/TropicalMorse/Theorems.lean`: `dehn_sommerville_1d` (Dehn-Sommerville to generalize)

**Proof Strategy:** The key challenge is defining "merge" and "cycle birth" in higher dimensions. Use discrete Morse theory (Forman, 1998): a simplex σ is critical if it is not paired in a discrete gradient field. The tropical Morse spectrum becomes the sequence of critical simplices ordered by weight, with event types determined by the dimension of the critical simplex.

**Domain Bridges:** Algebraic topology ↔ Tropical geometry ↔ Computational geometry ↔ Discrete Morse theory

**Lineage:** Generalization of all current results from dimension 1 to arbitrary dimension

**Ambition:** Grand challenge — requires substantial new theory, but the framework is clear
