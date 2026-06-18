# Future Directions: Verified Topological Algorithms with Semantic Certificates

## Synthesis

The verified Kruskal TMS computation establishes a new paradigm: **certified topological event calculi**, where every computational step in a graph algorithm carries a machine-verified proof of its topological meaning. The five directions below extend this paradigm along complementary axes — higher dimensions (Direction 1), richer algebraic structures (Direction 2), dynamism (Direction 3), connections to physics (Direction 4), and practical ML applications (Direction 5). Together, they chart a path from our current 1-dimensional graph result toward a comprehensive framework where topological computation is inseparable from topological certification.

The key theorems enabling these directions are:
- `kruskal_homology_conservation` (global event accounting)
- `event_type_captures_homology` (local homological semantics)
- `eventTypeStability` (order-theoretic invariance)
- `kruskal_tree_detection` (structural classification from events)

Each direction builds directly on at least one of these, extending the certified event framework into new mathematical territory.

---

## Direction 1: Higher-Dimensional Simplicial Filtration Certificates

**Conjecture:** For a simplicial complex filtration in dimension d, there exist certified event types (one per dimension 0 ≤ k ≤ d) such that each simplex insertion produces exactly one homological change, and the generalized Euler relation Σ(-1)^k β_k = Σ(-1)^k f_k holds at every step, where f_k counts k-simplices.

**The key insight is** that our 1-dimensional result (merge decreases β₀, cycle increases β₁) is the k=0,1 case of a general phenomenon: inserting a k-simplex either increases β_k or decreases β_{k-1}, with no other possibilities in generic position. This is the discrete Morse theory perspective of Forman (1998).

**Why now?** The verified Kruskal framework provides the template: define event types, prove local delta theorems, accumulate to global conservation. Extending from edges (1-simplices) to triangles (2-simplices) and beyond is structurally parallel. Mathlib's growing simplicial complex library makes this increasingly tractable.

**Test:** Implement a 2-dimensional filtration on a triangulated torus. Verify that the certified event sequence produces β₀ = 1, β₁ = 2, β₂ = 1 with the correct Euler characteristic χ = 0. A single counterexample (wrong Betti number) would refute the conjecture.

**Impact:** Would provide the first verified implementation of full persistent homology computation, replacing empirical trust with mathematical certainty for the core TDA pipeline.

**Catalog References:** `Pythagorean/TropicalMorse/Theorems.lean` (filtration theory), `KruskalTMS.lean` (event certification framework)

**Proof Strategy:** Induction on the simplex dimension. At dimension k, insertion of a k-simplex σ either:
(a) All faces of σ are already present and σ closes a k-cycle → β_k increases by 1
(b) Some boundary relation is new → β_{k-1} decreases by 1
Use the long exact sequence of the pair (K ∪ σ, K) to formalize this dichotomy.

**Domain Bridges:** Algebraic topology ↔ computational geometry ↔ scientific computing

**Lineage:** Extends kruskal_homology_conservation and event_type_captures_homology from k=0,1 to arbitrary k.

**Ambition:** Grand challenge — would establish the standard for verified TDA.

---

## Direction 2: Matroidal Tropical Morse Spectra

**Conjecture:** For any matroid M with a weight function w, the greedy algorithm produces a certified event sequence where independent element additions correspond to rank increases and dependent additions correspond to circuit closures. The event type sequence is an invariant of the matroid and weight order, not of the specific representation.

**The key insight is** that our eventTypeStability theorem is a theorem about the graphic matroid: the event types depend only on the matroid structure and weight ordering. This should generalize to arbitrary matroids, where "merge" becomes "rank increase" and "cycle" becomes "circuit closure."

**Why now?** The stability theorem (eventTypeStability) already proves the graphic matroid case. The extension requires formalizing matroid axioms and the greedy algorithm, both of which have clean Lean 4 formulations.

**Test:** Implement the greedy algorithm on the uniform matroid U(k,n) and the Fano matroid F₇. Verify that event types match matroid-theoretic predictions. If the event sequence for F₇ depends on representation (over GF(2) vs ℝ), the conjecture is falsified in its strongest form.

**Impact:** Would connect verified algorithms to the rich theory of matroid optimization, opening applications in combinatorial optimization and coding theory.

**Catalog References:** `KruskalTMS.lean` (eventTypeStability), `Pythagorean/TropicalMorse/Defs.lean` (graph structure)

**Proof Strategy:** Formalize matroid independence axioms. Show that the greedy algorithm on a weighted matroid produces an event sequence satisfying rank(M|_{prefix}) + nullity(M|_{prefix}) = |prefix| at each step. The local delta theorem becomes: independent addition increases rank by 1, dependent addition increases nullity by 1.

**Domain Bridges:** Matroid theory ↔ tropical geometry ↔ optimization ↔ coding theory

**Lineage:** Generalizes eventTypeStability from graphic matroids to all matroids.

**Ambition:** Paradigm-shifting — would unify verified graph algorithms with matroid optimization theory.

---

## Direction 3: Certified Dynamic Persistence for Streaming Graphs

**Conjecture:** There exists an O(α(n)) amortized certified update procedure for the TMS that, given an edge insertion or deletion, emits a certified event (or event reversal) and maintains the global conservation law in O(1) additional verification time.

**The key insight is** that our static Kruskal framework processes edges in batch, but the conservation law β₀ - β₁ = V - E is maintained step-by-step. This suggests a dynamic version where edges arrive (or depart) in real time, with each update producing a certified topological delta.

**Why now?** The processEdge function and its certificates are already incremental — they update the state one edge at a time. The missing piece is handling edge deletions (which may convert a cycle edge into a merge edge elsewhere) and maintaining the amortized complexity guarantee.

**Test:** On a stream of 10^6 random edge insertions/deletions on 10^4 vertices, verify that the conservation law holds after every operation. Measure the amortized cost per operation. If any operation violates β₀ - β₁ = V - E, the conjecture is falsified.

**Impact:** Would enable verified topological monitoring of real-time networks — social media, financial markets, sensor networks — with guaranteed correctness of the topological summary.

**Catalog References:** `KruskalTMS.lean` (processEdge, certificates), `Pythagorean/TropicalBridge/FiltrationPersistence.lean` (persistence framework)

**Proof Strategy:** For insertions: use processEdge directly. For deletions: if the deleted edge was a cycle edge, simply remove it (β₁ decreases). If it was a merge edge, the components may split — use a link-cut tree to determine the new connectivity and emit the appropriate certificate.

**Domain Bridges:** Streaming algorithms ↔ network monitoring ↔ TDA ↔ real-time systems

**Lineage:** Extends processEdge from batch processing to online/dynamic setting.

**Ambition:** Solid extension — practically important for streaming TDA applications.

---

## Direction 4: Topological Phase Transitions in Random Graphs

**Conjecture:** For the Erdős-Rényi random graph G(n, p), the expected TMS exhibits a sharp phase transition at p = 1/n: below the threshold, almost all events are merges; above it, the fraction of cycle events increases as Θ(np - 1). The transition is detectable from the certified event stream in O(E) time.

**The key insight is** that our conservation law merges + cycles = E, combined with the known Erdős-Rényi phase transition, implies that the merge/cycle ratio undergoes a sharp transition. Below the critical threshold, the graph is a forest (all merges, no cycles). Above it, cycles appear at a rate determined by the excess edge count.

**Why now?** The formal connection between TMS events and Betti numbers (kruskal_cycle_rank, kruskal_beta0_recovery) provides exact formulas linking the event stream to the phase transition. The random graph theory needed is classical (Erdős-Rényi 1960).

**Test:** Generate G(n, p) for n = 1000 and p ranging from 0.5/n to 5/n in steps of 0.1/n. For each, compute the TMS and measure the cycle fraction. Plot the cycle fraction vs. p. The conjecture predicts a sigmoid-like curve centered at p = 1/n with width O(1/n). If the transition is smooth rather than sharp, the conjecture needs refinement.

**Impact:** Would provide a new perspective on random graph phase transitions, connecting percolation theory to tropical geometry through the certified event stream.

**Catalog References:** `Pythagorean/TropicalMorse/Theorems.lean` (percolation_transition_count, giant_component_threshold), `KruskalTMS.lean` (conservation laws)

**Proof Strategy:** Use the tree characterization (kruskal_tree_detection): below threshold, β₁ = 0. Above threshold, β₁ = E - V + β₀. The expected value of β₁ for G(n, p) is E[E] - n + E[β₀] ≈ n²p/2 - n + ne^{-np} (using the known formula for expected component count).

**Domain Bridges:** Random graph theory ↔ statistical physics ↔ tropical geometry ↔ percolation theory

**Lineage:** Applies kruskal_tree_detection and conservation laws to probabilistic graph models.

**Ambition:** Solid extension with cross-domain impact.

---

## Direction 5: TMS Kernels for Graph Neural Networks with Expressiveness Guarantees

**Conjecture:** A graph kernel based on the TMS fingerprint (the sequence of event types) is strictly more expressive than the WL subtree kernel, and can be computed in O(E log E) time. Moreover, the kernel value between two graphs can be certified: if the TMS fingerprints differ, the kernel certifies that the graphs are topologically distinguishable.

**The key insight is** that the TMS fingerprint is a complete invariant of the 1-dimensional persistence barcode (up to weight-order equivalence), while the WL kernel captures only local neighborhood structure. The formal proof that TMS separates WL1-equivalent graphs (tms_strictly_expressive_over_WL1) provides the expressiveness guarantee.

**Why now?** Graph neural networks (GNNs) are bounded by the WL hierarchy in expressiveness. The TMS provides a complementary topological signal that captures global structural features (loops, connectivity) that local message-passing cannot see. The formal verification ensures that the expressiveness claim is not empirical but mathematically proven.

**Test:** On the ZINC, ogbg-molhiv, and CSL benchmark datasets, compare classification accuracy of TMS kernel vs. WL subtree kernel vs. combined kernel. The conjecture predicts that TMS kernel alone matches or exceeds WL on datasets with significant topological variation, and the combined kernel strictly dominates both.

**Impact:** Would provide the first formally verified expressiveness guarantee for a graph ML method, bridging the gap between theoretical expressiveness results and practical ML performance.

**Catalog References:** `Pythagorean/TropicalMorse/Theorems.lean` (tms_strictly_expressive_over_WL1), `KruskalTMS.lean` (compute_tms, eventTypeStability)

**Proof Strategy:** Define the TMS kernel as K(G₁, G₂) = similarity(fingerprint(G₁), fingerprint(G₂)). Prove that K(G₁, G₂) = 1 implies fingerprint equality implies same TMS. Use tms_strictly_expressive_over_WL1 to show that K separates WL1-equivalent pairs. The positive-definiteness of K follows from the kernel trick on sequence similarity.

**Domain Bridges:** Machine learning ↔ algebraic topology ↔ graph theory ↔ cheminformatics

**Lineage:** Applies tms_strictly_expressive_over_WL1 and eventTypeStability to ML kernel design.

**Ambition:** Grand challenge — would establish a new standard for verified ML expressiveness.
