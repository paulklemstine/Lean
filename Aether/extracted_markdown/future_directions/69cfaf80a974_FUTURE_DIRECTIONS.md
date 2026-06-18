# Future Directions: Weighted Tropical Cycle Optimization

## Synthesis

The weighted systole theorem establishes that quantum code distance on non-uniform hardware is governed by a single tropical optimization invariant: the minimum-weight simple cycle. This creates a precise bridge between three previously separate domains — tropical geometry (min-plus optimization), persistent homology (filtration-dependent births), and quantum error correction (weighted logical operators). The directions below exploit this bridge in both the theoretical and applied directions, ranging from new decoder architectures that operate natively in the tropical semiring, to systolic inequalities that could constrain hardware design, to weighted matroid persistence that generalizes the framework beyond graphs.

---

## Direction 1: Tropical Quantum Decoding via Min-Plus Belief Propagation

**Conjecture:** There exists a message-passing decoder for graph-derived CSS codes that operates in the min-plus semiring $(\mathbb{R}_{\geq 0} \cup \{\infty\}, \min, +)$, whose decoding radius equals the weighted systole $\text{sys}_w(G) / 2$, and whose per-round complexity is $O(|E|)$.

**Test:** Implement a min-plus belief propagation decoder on toric codes with non-uniform weights. Compare its logical error rate against standard MWPM (minimum-weight perfect matching) decoders. The tropical decoder should match or exceed MWPM performance on hardware graphs with ≥15% weight variation, at lower computational cost.

**Impact:** Current decoders (MWPM, union-find) operate on uniform-weight assumptions and require post-hoc weight adjustments. A natively tropical decoder would be the first decoder architecture where non-uniform weights are a feature, not a bug. This could reduce logical error rates by 10-30% on real hardware.

**Catalog References:**
- `Pythagorean/TropicalMorse/WeightedCycleDistance.lean`: `firstCycleBirth_eq_minCycleWeight`, `weightedCodeDistance_eq_minCycleWeight`
- `Pythagorean/TropicalMorse/Theorems.lean`: `redundant_edges_eq_cycle_rank`

**Proof Strategy:** Formalize min-plus message passing on cycle spaces. Show that fixed-point messages encode shortest-path distances. Connect fixed-point condition to cycle optimality via the tropical cycle support weight characterization.

**Domain Bridges:** Tropical geometry ↔ Quantum error correction ↔ Probabilistic graphical models

**Lineage:** Extends Theorem B (weighted code distance = systole) to algorithmic territory.

**Ambition:** Grand challenge — would create an entirely new class of quantum decoders.

---

## Direction 2: Spectral-Systolic Inequalities for Hardware Graphs

**Conjecture:** For any connected weighted graph $G$ with $n$ vertices and spectral gap $\lambda_1$ (smallest nonzero Laplacian eigenvalue):
$$\text{sys}_w(G) \geq \frac{2\lambda_1 \cdot \text{wt}_{\min}}{\Delta_{\max}}$$
where $\text{wt}_{\min}$ is the minimum edge weight and $\Delta_{\max}$ is the maximum degree.

**The key insight is** that the spectral gap constrains expansion, which limits how short a cycle can be (in terms of total weight). Graphs with large spectral gap force long minimum cycles.

**Why now?** The weighted systole theorem gives the first formal handle on weighted cycle length in graph codes. Combined with spectral graph theory, this could yield the first hardware-relevant lower bounds on code distance.

**Test:** Compute both sides for families of expander graphs (Ramanujan graphs, random regular graphs) with random positive weights. The inequality should hold with a gap that shrinks as $n \to \infty$.

**Impact:** Would provide the first a priori lower bounds on weighted code distance from spectral data alone, enabling hardware designers to guarantee minimum distance without exhaustive cycle enumeration.

**Catalog References:**
- `Pythagorean/TropicalMorse/WeightedCycleDistance.lean`: `minCycleWeight_pos`, `cycleSupportWeight_eq_min_of_minCycle`

**Proof Strategy:** Use Cheeger's inequality to relate spectral gap to edge expansion. Show that high expansion forces long cycles. Translate cycle length lower bound into weight lower bound via minimum weight.

**Domain Bridges:** Spectral graph theory ↔ Systolic geometry ↔ Quantum LDPC codes

**Lineage:** Builds on Theorem A (systolic realization) and the cycle support weight characterization.

**Ambition:** Solid extension — connects established spectral theory to the new weighted framework.

---

## Direction 3: Weighted Matroid Persistence and Multi-Parameter Filtrations

**Conjecture:** The weighted cycle birth theory extends from graphic matroids to arbitrary matroids: for any matroid $M$ with positive weight function $w$ on the ground set, the first circuit encountered in a support-weight-adapted ordering has minimum total weight among all circuits.

**The key insight is** that the forest/cycle dichotomy in graphs is an instance of the independent-set/circuit dichotomy in matroids. The girth-adapted filtration generalizes to a matroid-theoretic construction.

**Why now?** The formal verification of the graph case provides the template. Matroids give the natural level of generality.

**Test:** Implement the matroid persistence framework for:
1. Graphic matroids (recovering our theorem)
2. Cographic matroids (minimum cut duality)
3. Linear matroids over $\mathbb{F}_2$ (relevant to CSS codes)
Verify computationally that the minimum-circuit-weight property holds in all cases.

**Impact:** Would unify weighted code distance computation across all matroid-representable code families, including quantum LDPC codes, bicycle codes, and lifted product codes.

**Catalog References:**
- `Pythagorean/TropicalMorse/WeightedCycleDistance.lean`: `firstCycleBirth_eq_minCycleWeight`
- `Pythagorean/TropicalMorse/Theorems.lean`: `cycle_rank_additive_over_filtration`

**Proof Strategy:** Formalize matroid circuits and independent sets. Prove the matroid analogue of the forest-path-uniqueness lemma. Transfer the girth-adapted argument.

**Domain Bridges:** Matroid theory ↔ Tropical geometry ↔ Coding theory ↔ Persistent homology

**Lineage:** Directly generalizes Theorem A from graphs to matroids.

**Ambition:** Solid extension — natural generalization of the core result.

---

## Direction 4: Statistical Mechanics of Logical Operator Formation

**Conjecture:** In the random weighted graph $G(n, p, W)$ where edge weights are i.i.d. from distribution $W$ on $\mathbb{R}_{>0}$, the weighted systole concentrates:
$$\text{sys}_w(G) = g(n, p) \cdot \mathbb{E}[W] \cdot (1 + o(1))$$
where $g(n, p)$ is the unweighted girth. Moreover, the girth-adapted filtration reaches the systole at a "critical temperature" $\beta_c$ in the percolation sense.

**The key insight is** that the filtration of a random weighted graph is equivalent to a bond percolation process with non-uniform thresholds. The systole corresponds to the first loop in the percolation cluster.

**Why now?** The connection between tropical Morse filtration and percolation was established in `Pythagorean/TropicalMorse/Theorems.lean` (`percolation_transition_count`). Weighted filtrations add a natural "temperature" parameter.

**Test:** Simulate random graphs with $n = 100$, $p \in \{0.1, 0.2, 0.3\}$, weights from Exp(1). Measure concentration of $\text{sys}_w / (g \cdot \mathbb{E}[W])$ over 1000 trials. Predict the critical density where Kruskal failure probability exceeds 50%.

**Impact:** Would connect quantum code distance theory to the rich machinery of random graph theory and statistical mechanics, enabling probabilistic guarantees on code performance.

**Catalog References:**
- `Pythagorean/TropicalMorse/Theorems.lean`: `percolation_transition_count`, `giant_component_threshold`
- `Pythagorean/TropicalMorse/WeightedCycleDistance.lean`: `exists_obstruction_of_kruskal_neq_min`

**Proof Strategy:** Use first-moment methods to bound expected systole. Apply concentration inequalities (Azuma-Hoeffding) to show concentration. Connect critical threshold to the Kruskal failure obstruction.

**Domain Bridges:** Statistical mechanics ↔ Random graph theory ↔ Quantum error correction ↔ Percolation theory

**Lineage:** Extends Theorem C (obstruction) to the probabilistic setting.

**Ambition:** Grand challenge — would create a statistical theory of weighted code distance.

---

## Direction 5: Efficient Weighted Girth via Tropical Filtration Heuristics

**Conjecture:** The girth-adapted filtration concept can be converted into a polynomial-time heuristic for the weighted girth (shortest simple cycle) problem that achieves an approximation ratio of $O(\log n)$ on general weighted graphs.

**The key insight is** that while exact cycle enumeration is expensive, the cycle support weight can be *approximated* using shortest-path computations: $\text{csw}(e) \approx w(e) + d_{G \setminus e}(u, v)$ where $d_{G \setminus e}$ is the shortest-path distance in $G$ with edge $e$ removed.

**Why now?** The exact algorithm (with full cycle enumeration) verifies the concept. The shortest-path approximation of csw reduces the problem to $|E|$ Dijkstra computations, each $O(|E| + |V| \log |V|)$.

**Test:** Compare the approximate girth-adapted filtration against:
1. Exact weighted girth (for small graphs)
2. Itani-Roth $O(mn)$ algorithm
3. Alon-Yuster-Zwick color-coding approach
Measure approximation ratio and runtime on graphs with 100–10000 vertices.

**Impact:** Would provide a practical algorithm for weighted girth that scales to hardware-relevant graph sizes (thousands of qubits), enabling real-time code distance computation during quantum chip calibration.

**Catalog References:**
- `Pythagorean/TropicalMorse/WeightedCycleDistance.lean`: `cycleSupportWeight_eq_min_of_minCycle`, `edgeSetWeight_insert_lt`

**Proof Strategy:** Show that the shortest-path approximation of csw is within a multiplicative factor of the true csw. Use this to bound the quality of the approximate girth-adapted ordering. Prove the approximation ratio via a charging argument.

**Domain Bridges:** Combinatorial optimization ↔ Algorithm design ↔ Quantum hardware calibration

**Lineage:** Extends the girth-adapted filtration concept to the algorithmic/approximation setting.

**Ambition:** Solid extension — practical algorithmic contribution with clear benchmarks.
