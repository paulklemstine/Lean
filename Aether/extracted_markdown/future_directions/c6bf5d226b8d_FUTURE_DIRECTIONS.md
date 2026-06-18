# Future Directions: Hadwiger's Conjecture and Graph Minor Theory

## Synthesis

This cycle established the foundational infrastructure for graph minor theory in Lean 4, filling a significant gap in Mathlib. The key novelty was the `MinorModel` structure (branch-set characterization) and the `hadwigerNumber` graph invariant. We proved 7 non-trivial theorems covering structural properties of minors, the low-k cases of Hadwiger's conjecture (k ≤ 2), Wagner's forward implication, and the greedy coloring theorem for degenerate graphs.

The most promising cross-domain connection is between **degeneracy** and **minor structure**: k-degenerate graphs are (k+1)-colorable (proved), and minor-free graph families tend to be degenerate (e.g., K_t-minor-free graphs have bounded degeneracy). This chain—minor-freeness → degeneracy → colorability—is the structural backbone of Hadwiger's conjecture for small k. Connecting our `IsDegenerate` definition to minor-freeness would unlock proofs of Hadwiger for k = 3 and k = 4.

The highest breakthrough potential lies in Direction 1 (Hadwiger for k = 3), which is the next natural step and requires only the odd-cycle characterization of bipartite graphs—a result that should be within reach of current tools. Direction 2 (minor transitivity) is a foundational result needed for nearly all future work. Direction 3 (density-based approach) connects to the Kostochka-Thomason theorem and could yield quantitative results even without resolving Hadwiger's conjecture.

---

### Direction 1: Hadwiger's Conjecture for k = 3

**Conjecture**: Every graph with chromatic number ≥ 3 (i.e., not 2-colorable, equivalently not bipartite) contains K₃ as a minor.

**Test**: Verify computationally for all graphs on ≤ 8 vertices using `HadwigerSmall`. Then prove formally by establishing: (1) a graph is 2-colorable iff it is bipartite, (2) a graph is bipartite iff it has no odd cycle, (3) every odd cycle can be contracted to K₃. Step (3) is the key: in an odd cycle v₁-v₂-...-v_{2k+1}-v₁, contract edges {v₁,v₂}, {v₃,v₄}, ..., {v_{2k-1},v_{2k}} to reduce to a triangle.

**Impact**: This would be the first non-trivial case of Hadwiger's conjecture formalized in any proof assistant. It demonstrates that the conjecture is not just about small cases but captures genuine graph structure.

**Catalog References**: `Geometry/HadwigerConjecture.lean` (MinorModel, IsMinor, hadwiger_of_adj), Mathlib `SimpleGraph.Colorable`, `SimpleGraph.Walk`

**Proof Strategy**:
1. Define `SimpleGraph.IsBipartite` (or locate in Mathlib) as admitting a 2-coloring
2. Prove: not bipartite ⟹ contains an odd cycle (use BFS tree argument)
3. Prove: odd cycle of length 2k+1 can be contracted to K₃ by contracting k edges
4. Construct the minor model: branch sets are singletons for the three remaining vertices after contraction, connected by the remaining edges

Key lemma needed: `odd_cycle_to_K3_minor : ∀ (C : SimpleGraph.Walk G v v), C.IsCycle → Odd C.length → IsMinor G (completeGraph (Fin 3))`

**Domain Bridges**: Graph Theory ↔ Topology (odd cycles relate to homology of the graph seen as a simplicial complex)

**Lineage**: Builds directly on `hadwiger_of_adj` (K₂ minor from edge) and the `MinorModel` infrastructure from this cycle.

**Ambition**: extension

---

### Direction 2: Transitivity of the Minor Relation

**Conjecture**: The minor relation is transitive: if G ≽ H and H ≽ K, then G ≽ K.

**Test**: Construct explicit composed minor models for K₃ ≽ K₂ ≽ K₁ and verify the composition works. The formal statement is: `IsMinor G H → IsMinor H K → IsMinor G K`.

**Impact**: Transitivity is essential for the entire theory of graph minors. Without it, minor-closed families cannot be reasoned about inductively. Proving it would unlock formalization of the Robertson-Seymour Graph Minor Theorem.

**Catalog References**: `Geometry/HadwigerConjecture.lean` (MinorModel, IsMinor, isMinor_of_isMinor_of_le)

**Proof Strategy**: Given minor models β_H : W → P(V) of H in G and β_K : U → P(W) of K in H, construct a minor model of K in G with branch sets γ(u) = ⋃_{w ∈ β_K(u)} β_H(w).

Key challenges:
1. **Nonemptiness**: Each β_K(u) is nonempty (has some w₀), and β_H(w₀) is nonempty.
2. **Disjointness**: If u₁ ≠ u₂, then β_K(u₁) ∩ β_K(u₂) = ∅, and the β_H sets for different w's are disjoint, so the unions are disjoint.
3. **Connectivity**: This is the hardest part. Each γ(u) = ⋃_{w ∈ β_K(u)} β_H(w). The β_K(u) set is connected in H, meaning there are H-paths between elements. Each H-edge between w₁, w₂ ∈ β_K(u) gives a G-edge between β_H(w₁) and β_H(w₂). So the union is connected in G.
4. **Adjacency**: If K.Adj u₁ u₂, then ∃ w₁ ∈ β_K(u₁), w₂ ∈ β_K(u₂) with H.Adj w₁ w₂, and then ∃ x ∈ β_H(w₁), y ∈ β_H(w₂) with G.Adj x y.

**Domain Bridges**: Order Theory ↔ Graph Theory (minor relation as a well-quasi-order, connecting to the Graph Minor Theorem)

**Lineage**: Builds on `isMinor_of_isMinor_of_le` (special case where one minor model uses singletons) from this cycle.

**Ambition**: extension

---

### Direction 3: Density-Based Hadwiger Bounds (Kostochka-Thomason)

**Conjecture**: There exists c > 0 such that every graph with average degree ≥ c · k · √(ln k) contains K_k as a minor. (This is the Kostochka-Thomason theorem, proved but not yet formalized.)

**Test**: Verify for random graphs: generate Erdős-Rényi G(n, p) with p chosen so average degree ≈ c · k · √(ln k), then search for K_k minors computationally. The theorem predicts minors should be found with high probability.

**Impact**: This would give the first formalized quantitative bound relating edge density to minor structure. It would also provide a "soft" approach to Hadwiger: since graphs with χ ≥ k have average degree ≥ k-1, the Kostochka-Thomason bound gives K_{f(k)} minors for f(k) ≈ k/√(ln k)—not K_k but close.

**Catalog References**: `Geometry/HadwigerConjecture.lean` (KostochkaThomason, avgDegree, IsMinor)

**Proof Strategy**: The proof uses probabilistic arguments (random contractions) combined with the Lovász Local Lemma. Key steps:
1. Formalize the probabilistic method for graph theory
2. Prove the key lemma: in a graph with minimum degree d, a random contraction to d/2 vertices preserves enough edges to find K_k for k ≈ d/√(ln d)
3. De-randomize using the Lovász Local Lemma

This is a long-term direction requiring significant infrastructure.

**Domain Bridges**: Probability Theory ↔ Graph Theory ↔ Combinatorial Optimization

**Lineage**: Builds on `KostochkaThomason` definition and `avgDegree` from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Hadwiger for k = 4 via Series-Parallel Graphs

**Conjecture**: Every K₄-minor-free graph is 3-colorable (equivalently, 2-degenerate).

**Test**: Verify for all K₄-minor-free graphs on ≤ 10 vertices by enumeration.

**Impact**: This would complete the formalization of Hadwiger(4), the last "elementary" case. The proof connects graph minors to the classical theory of series-parallel networks, which has applications in electrical engineering and VLSI design.

**Catalog References**: `Geometry/HadwigerConjecture.lean` (IsDegenerate, colorable_of_degenerate, IsMinor)

**Proof Strategy**: The key is the structural characterization of K₄-minor-free graphs:
1. Define series-parallel graphs (graphs of treewidth ≤ 2)
2. Prove: K₄-minor-free ⟹ series-parallel
3. Prove: series-parallel ⟹ 2-degenerate (every subgraph has a vertex of degree ≤ 2)
4. Apply `colorable_of_degenerate` (already proved in this cycle!) to conclude 3-colorability

Step 2 is the hardest and requires the theory of tree decompositions.

**Domain Bridges**: Graph Theory ↔ Circuit Design (series-parallel networks) ↔ Formal Verification (treewidth bounds complexity)

**Lineage**: Builds on `colorable_of_degenerate` and `IsDegenerate` from this cycle.

**Ambition**: grand_challenge

---

### Direction 5: Four Color Theorem Formalization and Wagner Reverse

**Conjecture**: The Four Color Theorem (every planar graph is 4-colorable) can be formalized in Lean 4, and combined with Robertson-Seymour-Thomas theory to prove the reverse Wagner equivalence: 4CT ⟹ Hadwiger(5).

**Test**: First milestone: formalize the discharging argument for a specific unavoidable set (e.g., the Birkhoff diamond). The full proof requires verifying ~600 reducible configurations.

**Impact**: This would be the most significant formalization in graph theory to date, establishing Hadwiger's conjecture for k = 5 in Lean 4 and demonstrating that deep structural graph theory is accessible to formal verification.

**Catalog References**: `Geometry/HadwigerConjecture.lean` (FourColorTheorem, HadwigerFive, wagner_forward, IsPlanar)

**Proof Strategy**: The 4CT has been formalized in Coq (Gonthier, 2005) and could potentially be ported. The key components are:
1. Formalize planar graph embeddings (beyond our combinatorial IsPlanar)
2. Port or re-prove the reducibility of ~600 configurations
3. Prove the unavoidability of the configuration set via discharging
4. For the Wagner reverse: prove the structural decomposition of K₅-minor-free graphs (Robertson-Seymour-Thomas)

**Domain Bridges**: Graph Theory ↔ Topology (planar embeddings) ↔ Computation (the 4CT computer verification)

**Lineage**: Builds on `wagner_forward` and `IsPlanar` from this cycle. Would complete the Wagner equivalence.

**Ambition**: grand_challenge
