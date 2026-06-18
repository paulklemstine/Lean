# Future Directions: Tropical-Topological Decoding Theory

## Synthesis

The four theorems proved in this work — monotonicity, spectral separation, refinement invariance, and zero-temperature selection — establish that barcode-derived vulnerability is a mathematically well-founded decoder observable. These results open a research program at the intersection of tropical geometry, persistent homology, quantum error correction, and statistical mechanics. The directions below build on these foundations in two modes: *grand challenges* that could reshape how we think about decoding, and *solid extensions* that immediately deepen the theory using available tools.

The unifying principle across all directions is that **global topological information, encoded in persistence barcodes, can be algorithmically converted into local correction decisions**. Each direction below explores a different facet of this principle.

---

## Direction 1: Barcode-Guided MWPM for Hypergraph-Product Codes

**Conjecture:** For hypergraph-product codes built from expander graphs, the higher-dimensional tropical Morse barcode (tracking H₁ and H₂ persistence simultaneously) defines a vulnerability profile on 2-cells that improves decoder performance over standard BP-OSD when integrated as edge weights in a generalized matching decoder.

**Test:** Implement the tropical barcode decoder for Tillich–Zémor hypergraph-product codes at blocklengths n = 100, 400, 900. Compare logical error rates against BP-OSD at p = 0.01–0.05. The conjecture is falsified if the barcode decoder shows no improvement at any λ calibration across these sizes.

**Impact:** Hypergraph-product codes are the most promising route to asymptotically good quantum LDPC codes. Current decoders struggle with their non-planar structure. If barcode vulnerability can identify dangerous higher-dimensional cycles, this would provide a geometry-aware decoder for the most important class of next-generation quantum codes.

**Catalog References:**
- `Catalog/Pythagorean/TropicalMorse/Theorems.lean` — `spectral_gap_distinguishes`, `euler_char_from_filtration`
- `Catalog/Pythagorean/TropicalMorse/Defs.lean` — `TMSpectrum`, `CriticalEventType`

**Proof Strategy:** Extend `edgeVulnerability_mono` from 1-dimensional (edge) barcodes to 2-dimensional (face) barcodes using the simplicial filtration machinery. The key lemma would be a higher-dimensional analogue of `Finset.sum_le_sum_of_subset_of_nonneg` applied to simplicial chain complexes.

**Domain Bridges:** Algebraic topology (simplicial homology) ↔ quantum LDPC codes ↔ tropical geometry.

**Lineage:** Extends Theorem 1 (monotonicity) and Theorem 2 (separation) to higher dimensions.

**Ambition:** Grand challenge — would establish barcode-guided decoding as a viable paradigm for the most important class of quantum codes.

**The key insight is** that higher-dimensional persistence carries strictly more information than 1-dimensional persistence, and this information is precisely what is needed to navigate the complex homological structure of hypergraph-product codes.

**Why now?** The recent breakthroughs in quantum LDPC codes (fiber bundles, lifted products) have created an urgent need for decoders that understand higher-dimensional topology. Our monotonicity and separation theorems provide the mathematical tools to extend barcode decoding to this setting.

---

## Direction 2: Persistence Threshold Phenomena and Code Capacity

**Conjecture:** For the surface code family, there exists a critical persistence threshold τ*(p) such that the barcode-weighted decoder with corridor penalty at threshold τ* achieves the code capacity (optimal threshold) of the depolarizing channel, and τ* satisfies a scaling law τ*(p) ~ -log(p) as p → 0.

**Test:** Compute τ* numerically for surface codes L = 5, 7, 9, 11, 13 at p = 0.01, 0.02, ..., 0.10 by optimizing logical error rate over τ. Fit the scaling relation. The conjecture is falsified if τ* shows no systematic dependence on p or if the optimized decoder fails to approach the known code capacity.

**Impact:** Would establish a rigorous connection between barcode geometry and the information-theoretic limits of quantum error correction. The scaling law would be a new universality result connecting tropical persistence to channel capacity.

**Catalog References:**
- `Catalog/Pythagorean/TropicalMorse/Theorems.lean` — `tree_iff_no_cycles`, `redundant_edges_eq_cycle_rank`
- `Pythagorean/TropicalMorse/SpectralDecoding.lean` — `logicalCorridor_antitone`, `zero_temperature_selection`

**Proof Strategy:** Use the antitone property of logical corridors (`logicalCorridor_antitone`) to establish that τ → LC(τ) is a decreasing family of sets. Combine with the zero-temperature selection theorem to show that optimal τ balances over-penalization (empty corridor, no benefit) against under-penalization (full corridor, no selectivity).

**Domain Bridges:** Information theory (channel capacity) ↔ tropical geometry (persistence thresholds) ↔ statistical mechanics (critical phenomena).

**Lineage:** Extends Theorem 4 (zero-temperature selection) and the logical corridor framework.

**Ambition:** Grand challenge — would connect barcode geometry to fundamental information-theoretic limits.

**The key insight is** that the optimal persistence threshold is not a free parameter but is determined by the noise rate, and this determination follows a universal scaling law rooted in the geometry of the tropical Morse filtration.

**Why now?** The free-energy framework from Theorem 4 provides the first rigorous variational principle for barcode-weighted decoding. Combined with the monotonicity of logical corridors, this creates the mathematical infrastructure needed to study threshold optimization.

---

## Direction 3: Tropical Free-Energy Decoding and Renormalization

**Conjecture:** A multiscale renormalization scheme — coarsening the barcode at progressively larger persistence scales while updating the vulnerability profile — converges to a fixed-point decoder whose performance is independent of the initial barcode resolution, and this fixed point achieves near-optimal decoding in O(n log n) time.

**Test:** Implement a two-level renormalization: (1) compute fine barcode, (2) coarsen by merging intervals with persistence < ε, (3) decode. Test convergence of logical error rate as ε sweeps from 0 to max persistence for L = 7, 9, 11. The conjecture is falsified if performance degrades monotonically with coarsening (no fixed point).

**Impact:** Would establish a principled method for hierarchical decoding that automatically selects the relevant persistence scale, analogous to renormalization group methods in physics. Could yield near-linear-time decoders with topological intelligence.

**Catalog References:**
- `Pythagorean/TropicalMorse/SpectralDecoding.lean` — `pathWeight_refinement_invariant`, `free_energy_lambda_mono`
- `Catalog/Pythagorean/TropicalMorse/Theorems.lean` — `complexity_le_events`

**Proof Strategy:** The refinement invariance theorem (`pathWeight_refinement_invariant`) shows that barcode coarsening preserving total persistence does not change the decoder metric. The key new result needed is a *controlled perturbation bound*: coarsening that changes total persistence by at most ε changes decoder scores by at most O(ε × path_length).

**Domain Bridges:** Statistical mechanics (renormalization group) ↔ tropical geometry ↔ algorithmic graph theory.

**Lineage:** Directly extends Theorem 3 (refinement invariance) and Theorem 4 (free-energy functional).

**Ambition:** Solid extension — builds directly on proven invariance properties with a clear algorithmic deliverable.

**The key insight is** that refinement invariance is the discrete analogue of universality in the renormalization group: the decoder's macroscopic behavior depends only on the aggregate persistence, not on the microscopic interval structure.

**Why now?** The refinement invariance theorem provides the mathematical guarantee that coarsening does not change decoder behavior when total persistence is preserved. Extending this to approximate preservation creates a principled hierarchy.

---

## Direction 4: Energy Landscapes and Spin-Glass Analogies

**Conjecture:** The free-energy landscape F_λ(C) = E(C) + λ·Φ(C) over the space of corrections, for surface codes at noise rates near threshold, exhibits a spin-glass-like structure with exponentially many metastable states, and the logical corridors correspond precisely to the saddle points connecting distinct ground-state basins.

**Test:** Enumerate all syndrome-consistent corrections for small surface codes (L = 3, 4) and compute the full free-energy landscape. Identify local minima, saddle points, and barrier heights. Test whether saddle points consistently correspond to edges in logical corridors. The conjecture is falsified if saddle points show no correlation with barcode persistence.

**Impact:** Would establish a deep analogy between quantum decoding and disordered systems in statistical mechanics, potentially importing powerful tools (replica method, cavity method) for analyzing decoder performance.

**Catalog References:**
- `Pythagorean/TropicalMorse/SpectralDecoding.lean` — `freeEnergy`, `zero_temperature_selection`, `LogicalCorridor`
- `Catalog/Pythagorean/TropicalMorse/Theorems.lean` — `percolation_transition_count`

**Proof Strategy:** Use the percolation-transition correspondence from the catalog to relate critical filtration values to phase transitions. The free-energy monotonicity theorems provide the variational framework; the new ingredient is a barrier-height analysis using discrete Morse theory.

**Domain Bridges:** Spin glass theory ↔ quantum error correction ↔ tropical Morse theory ↔ optimization.

**Lineage:** Extends the free-energy framework (Theorems 4) and the percolation connection from the catalog.

**Ambition:** Grand challenge — would open a new interface between statistical mechanics and quantum coding theory.

**The key insight is** that the barcode-weighted free energy is not just an optimization objective but a physical energy landscape whose geometry (barriers, basins, saddle points) carries information about the difficulty of decoding at different noise rates.

**Why now?** The zero-temperature selection theorem and free-energy monotonicity results provide the first rigorous variational framework. The percolation connection from the catalog gives the bridge to statistical mechanics.

---

## Direction 5: Tropical Barcode Features for Neural Network Decoders

**Conjecture:** Augmenting a neural network decoder's input features with barcode-derived vulnerability scores and persistence statistics (total persistence, max persistence, number of intervals per edge) improves logical error rate by at least 10% compared to the same architecture trained on syndrome data alone, for surface codes at L ≥ 7 and p near threshold.

**Test:** Train a graph neural network decoder on surface codes L = 7, 9, 11 with and without barcode features. Compare logical error rates at p = 0.05, 0.08, 0.10. The conjecture is falsified if the barcode-augmented decoder shows less than 5% improvement.

**Impact:** Would demonstrate that barcode features carry information that is not easily extracted by standard neural architectures from raw syndrome data, validating the theoretical claim that topological persistence provides genuinely new decoding intelligence.

**Catalog References:**
- `Catalog/Pythagorean/TropicalMorse/Defs.lean` — `TMSpectrum`, `tropicalMorseComplexity`
- `Pythagorean/TropicalMorse/SpectralDecoding.lean` — `edgeVulnerability`, `LogicalCorridor`

**Proof Strategy:** Not a formal proof direction, but the monotonicity theorem guarantees that barcode features are well-ordered (more persistent ⟹ higher vulnerability), which provides a principled prior for the neural network.

**Domain Bridges:** Machine learning ↔ topological data analysis ↔ quantum error correction.

**Lineage:** Extends the vulnerability profile framework and connects to practical decoder design.

**Ambition:** Solid extension — directly applicable with existing ML infrastructure.

**The key insight is** that barcode features are provably monotone and refinement-invariant, making them high-quality input features for learning algorithms — they capture structural information that is stable under perturbation.

**Why now?** Neural network decoders are rapidly improving but struggle with global topological features. The barcode provides exactly the kind of global-to-local information bridge that neural architectures need.
