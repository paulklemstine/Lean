# Future Directions: Torsion-Aware Tropical Morse Theory

## Synthesis

The integer simplex insertion trichotomy reveals that local topological moves carry arithmetic content — divisibility, saturation, prime-power structure — that is entirely invisible to field-coefficient analysis. This opens a new frontier at the intersection of computational topology, number theory, and applications. The five directions below exploit this arithmetic layer in complementary ways: Direction 1 builds the computational infrastructure for torsion-sensitive persistence, Direction 2 attacks the central open conjecture, Direction 3 bridges to quantum information, Direction 4 connects to random topology, and Direction 5 develops the primewise structure into a new invariant theory. Together, they constitute a program for **arithmetic topological data analysis** — a field that does not yet exist but is now within reach.

---

## Direction 1: Arithmetic Persistent Homology

**Conjecture**: There exists a persistence module structure over ℤ, equipped with an "arithmetic barcode" consisting of (birth, death, torsion-label) triples, that strictly refines the field-coefficient barcode and is computable in polynomial time for bounded-dimension complexes.

**Test**: Implement arithmetic persistence for 2-complexes arising from point cloud data (protein structures, molecular surfaces). Compare the discriminating power of arithmetic barcodes vs. standard barcodes on benchmark datasets (e.g., SHREC, ModelNet). A positive result: arithmetic barcodes distinguish pairs of shapes that standard barcodes cannot. A negative result: the torsion information adds no discriminating power for real-world data, falsifying practical relevance.

**Impact**: This would create a new computational topology tool — "persistent homology with arithmetic memory" — that leverages the entire integer homology structure rather than discarding torsion. Applications in drug discovery, materials science, and computational biology would follow directly.

**Catalog References**: `Pythagorean/TropicalMorse/IntegerTrichotomy.lean` (trichotomy theorem), `Pythagorean/TropicalMorse/Defs.lean` (tropical spectrum definitions).

**Proof Strategy**: Model the filtered chain complex over ℤ, compute Smith normal forms at each filtration step, and track invariant factor changes using the trichotomy to label each event. The key technical challenge is defining a suitable notion of "interval" for torsion features, since torsion can be created in one step and modified (not destroyed) in later steps.

**Domain Bridges**: Topological data analysis, computational biology, materials science.

**Lineage**: Extends the classical persistent homology framework of Edelsbrunner-Letscher-Zomorodian by incorporating the torsion layer revealed by the trichotomy.

**Ambition**: Grand challenge — creating a new computational paradigm.

**The key insight is** that the trichotomy provides a natural event classifier for each step of the filtration, converting a global algebraic computation into a sequence of local arithmetic events that can be tracked and displayed as a barcode with richer labels.

**Why now?** The trichotomy theorem provides the mathematical foundation (previously missing) for classifying filtration events over ℤ, and Smith normal form algorithms are now fast enough for moderate-size complexes thanks to advances in computational number theory.

---

## Direction 2: The Single-Factor Torsion Pulse Conjecture

**Conjecture**: For a single d-simplex insertion into a finite simplicial complex (with all faces present), the total number of changed invariant factors in the torsion spectrum of H_{d-1} is at most one.

**Test**: Systematic computational search for counterexamples in the Linial-Meshulam model for n = 10, 12, 15, 20 vertices, checking every triangle insertion in at least 1000 random orderings per size. A single robust counterexample (changing ≥ 2 invariant factors in one insertion) falsifies the conjecture. If no counterexample is found up to n = 20, the evidence strongly supports the conjecture and motivates a proof attempt.

**Impact**: If true, the conjecture implies that integer simplex insertion is "rank-1 in the arithmetic sense" — the strongest possible locality result for topological surgery over ℤ. This would enable efficient incremental updates of torsion spectra (O(1) factor changes per insertion).

**Catalog References**: `Pythagorean/TropicalMorse/IntegerTrichotomy.lean` (conjecture definition `singleFactorTorsionPulseConjecture`).

**Proof Strategy**: Analyze the column-adjunction operation on Smith normal form directly. The key would be to show that adding one column to a matrix in Smith normal form can change at most one diagonal entry, using properties of the lattice extension ℤ^n / (S + ℤv) relative to ℤ^n / S. The result may follow from the theory of elementary divisors under rank-1 perturbations.

**Domain Bridges**: Matrix perturbation theory, algebraic number theory, lattice algorithms.

**Lineage**: Directly extends the trichotomy theorem to a quantitative refinement about the structure of individual torsion events.

**Ambition**: Solid extension — proving or disproving a clean combinatorial conjecture.

**The key insight is** that a single column adjunction is a rank-1 perturbation of the boundary matrix, and rank-1 perturbations of Smith normal forms should have controlled effects on the invariant factors by interlacing-type theorems.

**Why now?** The trichotomy theorem makes the conjecture precisely statable, and computational tools are now available to test it systematically.

---

## Direction 3: Torsion-Sensitive Quantum Code Design

**Conjecture**: For CSS-type quantum codes built from chain complexes of simplicial complexes, the torsion spectrum of H_1(K; ℤ) determines a "hidden degeneracy dimension" that affects the logical error rate. Specifically, there exist pairs of codes with identical parameters (n, k, d) over 𝔽₂ but different torsion spectra over ℤ, and the code with larger torsion mass has a measurably different logical error rate under depolarizing noise.

**Test**: Construct explicit CSS code pairs from small simplicial complexes (10-30 qubits) with matching 𝔽₂ parameters but different ℤ-torsion. Simulate decoding under depolarizing noise using minimum-weight perfect matching. Compare logical error rates at physical error rates p = 0.01, 0.05, 0.10. A positive result: statistical significance (p < 0.01) in error rate difference. A negative result: no measurable difference, suggesting torsion is irrelevant for code performance.

**Impact**: If torsion affects code performance, this would establish a new design principle for quantum error correction: optimize not just the 𝔽₂ parameters but also the integer torsion spectrum. This bridges algebraic topology, number theory, and quantum information.

**Catalog References**: `Pythagorean/TropicalMorse/IntegerTrichotomy.lean` (torsion_event_detects_css_degeneracy_change, codeDegeneracyProxy).

**Proof Strategy**: Use the trichotomy to track how code parameters evolve under simplex insertion. The key step is relating the ℤ-torsion spectrum to the 𝔽₂ homology via the universal coefficient theorem, then analyzing how the connecting homomorphism affects logical operators.

**Domain Bridges**: Quantum error correction, condensed matter physics, information theory.

**Lineage**: Extends the cross-domain bridge theorem in IntegerTrichotomy.lean from a structural statement to a performance prediction.

**Ambition**: Grand challenge — establishing a new paradigm for quantum code design.

**The key insight is** that the torsion of integer homology records information about the chain complex that is lost when reducing mod 2, and this information may affect the structure of logical operators and error correction performance.

**Why now?** The recent surge in topological quantum codes (e.g., hyperbolic surface codes, balanced product codes) creates immediate demand for new design principles, and the trichotomy provides the mathematical framework to study how torsion enters code design.

---

## Direction 4: Microscopic Theory of the Linial-Meshulam Torsion Phase Transition

**Conjecture**: In the Linial-Meshulam model on n vertices, near the torsion threshold (c ≈ 2 log n / n triangles per edge), the torsion spectrum of H_1 grows by at most one invariant factor per triangle insertion, and the distribution of saturation indices follows a power law with exponent depending on the distance from threshold.

**Test**: For n = 10, 15, 20, 30, generate 100 random triangle orderings per size. At each insertion near the threshold, record: (a) the event type, (b) the saturation index if torsion, (c) the number of invariant factors changed. Test the power law hypothesis via maximum likelihood estimation and Kolmogorov-Smirnov goodness-of-fit. Falsification: if the saturation index distribution is concentrated (e.g., always 2) or has no power-law tail.

**Impact**: A microscopic description of the torsion phase transition would be a breakthrough in random topology, providing a "single-event resolution" picture of a phenomenon currently understood only in aggregate (threshold + giant torsion group).

**Catalog References**: `Pythagorean/TropicalMorse/IntegerTrichotomy.lean` (trichotomy theorem), `Pythagorean/TropicalMorse/Defs.lean` (tropical Morse spectrum).

**Proof Strategy**: Use the trichotomy to decompose the phase transition into individual events. The threshold behavior should arise from the transition between a "mostly birth" regime (few cycles, boundaries are redundant) and a "mixed birth/torsion/kill" regime (boundaries become non-trivial). The critical window may be analyzable via second-moment methods on the saturation index.

**Domain Bridges**: Random topology, statistical physics (percolation), probability theory.

**Lineage**: Extends the Linial-Meshulam threshold theorem by providing local event-level resolution.

**Ambition**: Solid extension building toward a grand challenge in random topology.

**The key insight is** that the global torsion phase transition is a macroscopic consequence of microscopic arithmetic events, and the trichotomy provides the language to study these events individually.

**Why now?** The trichotomy theorem makes it possible for the first time to classify each individual triangle insertion as birth/kill/torsion, enabling event-resolution analysis of the phase transition.

---

## Direction 5: Primewise Tropical Event Signatures and p-adic Topology

**Conjecture**: The prime decomposition of the torsion spectrum defines a "p-adic torsion barcode" for each prime p, and the total torsion event signature of a filtration decomposes as a direct product over primes. Furthermore, for "generic" filtrations (formalized via a suitable measure), the p-adic barcodes for distinct primes are statistically independent.

**Test**: For random 2-complexes on n = 8, 10, 12 vertices, compute the p-primary torsion spectrum for p = 2, 3, 5, 7 at each step. Test statistical independence of p-primary event sequences using chi-squared tests on joint vs. marginal distributions. Falsification: strong correlation (p < 0.01 in chi-squared test) between 2-primary and 3-primary event times.

**Impact**: If the primewise decomposition is independent, this gives a "multiplicative structure" for torsion events: the total torsion event at a simplex insertion is a product of independent p-primary events. This would connect tropical Morse theory to p-adic analysis and arithmetic geometry, opening a new chapter of "arithmetic topology" in the computational setting.

**Catalog References**: `Pythagorean/TropicalMorse/IntegerTrichotomy.lean` (pPrimaryPart, primeLocalTorsionPulseConjecture).

**Proof Strategy**: Use the Chinese Remainder Theorem to decompose the invariant factors, then show that the p-primary component of the saturation index is determined locally by the p-adic valuation of the boundary vector coordinates. Independence may follow from the randomness of boundary orientations in the Linial-Meshulam model.

**Domain Bridges**: p-adic analysis, arithmetic geometry, analytic number theory, probabilistic combinatorics.

**Lineage**: Extends the prime witness theorem (torsion_event_has_prime_witness) to a full primewise decomposition theory.

**Ambition**: Grand challenge — connecting computational topology to p-adic mathematics.

**The key insight is** that the Chinese Remainder Theorem decomposes the torsion spectrum into independent p-primary components, and if this decomposition extends to the event level, the entire torsion dynamics factors over primes.

**Why now?** The prime witness theorem in the trichotomy framework shows that each torsion event has a prime label. The question of whether these labels are independent is now precisely statable and computationally testable.
