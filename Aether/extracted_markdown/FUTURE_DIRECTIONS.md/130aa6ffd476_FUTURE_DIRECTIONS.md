# Future Directions: Defect Deletion Calculus

## Synthesis

The exact deletion law δ(G−e) = δ(G) − 1 for non-bridge internal edges establishes the structural defect as a cycle-sensitive minor-monotone invariant. This opens five interconnected research directions: extending the calculus to edge contraction (Direction 1), testing submodularity in the subset variable (Direction 2), connecting to matroid theory (Direction 3), generalizing to higher dimensions (Direction 4), and closing the tropical bridge gap conjecture (Direction 5).

These directions form a coherent program: Directions 1–2 extend the graph-theoretic foundations, Direction 3 provides algebraic-structural depth, Direction 4 gives topological generalization, and Direction 5 closes the motivating conjecture. Success in any one direction would significantly advance the field; progress in multiple directions would establish defect calculus as a fundamental tool in structural graph theory.

---

## Direction 1: Edge Contraction and Full Minor Monotonicity

**Conjecture**: If e = {u,v} is an internal edge of (G,q,S) not incident to q, and G/e denotes the graph with e contracted (u and v identified to a single vertex w), and π(S) is the image of S under the identification, then:
$$\delta(G/e, q, \pi(S)) \leq \delta(G, q, S).$$

Moreover, the exact contraction formula should be:
- If e is a non-bridge of G[S]: δ(G/e, q, π(S)) = δ(G, q, S) − 1 (same as deletion, since non-bridge contraction also reduces β₁ by 1 and preserves κ).
- If e is a bridge of G[S]: δ(G/e, q, π(S)) = δ(G, q, S) (contraction of a bridge reduces |S| by 1, c by 1, and preserves β₁, keeping the defect constant).

**Test**: Exhaustive computation on all connected graphs with n ≤ 6 vertices, all roots q, all subsets S ⊆ V \ {q}, all internal edges e. Compute δ before and after contraction. Check:
1. Monotonicity δ(G/e) ≤ δ(G).
2. Exact formula matches the bridge/non-bridge classification.

**Impact**: Combined with the deletion law, this would establish a complete deletion-contraction calculus for the structural defect — analogous to the Tutte polynomial's deletion-contraction recurrence. This would place defect theory firmly within the framework of matroid-like invariants.

**Catalog References**: `Pythagorean/TropicalBridge/DeletionCalculus.lean` — extends the deletion calculus to contraction.

**Proof Strategy**: For the non-bridge case, contraction reduces β₁ by 1 (same as deletion in matroids). The κ analysis is more subtle: contracting an edge inside S creates a new vertex w that should remain connected to the same root components. For bridges, contraction merges two components into one, reducing c and |S| each by 1, preserving β₁.

**Domain Bridges**: Matroid theory (contraction in graphic matroids), topological graph theory (graph minors).

**Lineage**: Directly extends Theorem 4 (exact deletion law) of the current work.

**Ambition**: ★★★☆☆ (Solid extension — requires careful but straightforward analysis)

---

## Direction 2: Submodularity of Defect in the Subset Variable

**Conjecture**: For fixed G and q, the defect is submodular in S:
$$\delta(G, q, S \cup T) + \delta(G, q, S \cap T) \leq \delta(G, q, S) + \delta(G, q, T)$$
for all nonempty S, T ⊆ V \ {q} with S ∩ T ≠ ∅.

**Test**: Exhaustive computation on all connected graphs with n ≤ 7 vertices. For each pair of subsets (S, T) with S ∩ T ≠ ∅ and S ∪ T not containing q, compute all four defect values and check the inequality.

**Impact**: Submodularity would make the defect a polymatroidal function, connecting it to submodular optimization and potentially enabling polynomial-time algorithms for defect-related optimization problems. It would also suggest deep structural properties of the tropical rank gap.

**Catalog References**: `Pythagorean/TropicalBridge/DeletionCalculus.lean` — the definitions of structural defect and its components.

**Proof Strategy**: Decompose δ = β₁ + κ − 1 and analyze submodularity of each component:
- β₁(G,S) = e(G,S) − |S| + c(G,S): The edge count e is supermodular (|E(G[S∪T])| + |E(G[S∩T])| ≥ |E(G[S])| + |E(G[T])|), |S| is modular, and c is... complex. The submodularity of β₁ is non-trivial.
- κ(G,q,S): This is submodular (the number of root-components touching S is a monotone submodular function of S by matroid-type arguments).

**Domain Bridges**: Submodular optimization, polymatroid theory, combinatorial optimization.

**Lineage**: New direction, motivated by the additive structure of δ.

**Ambition**: ★★★★☆ (Challenging — submodularity of c(G,S) is subtle and may require new techniques)

---

## Direction 3: Matroidal Extension — Defect as Matroid Nullity Correction

**Conjecture**: There exists a matroid-theoretic defect function δ_M defined on rooted subsets of a matroid M such that:
1. When M = M(G) is the cycle matroid of G, δ_M specializes to δ(G,q,S).
2. The deletion law generalizes: for non-coloop elements e, δ_M(M\e) = δ_M(M) − 1.
3. The contraction law generalizes: for non-loop elements e, δ_M(M/e) satisfies an analogous formula.

**Test**: Evaluate candidate formulas on graphic matroids of small graphs and compare with the graph-theoretic defect. Also test on small non-graphic matroids (e.g., U_{2,4}, the Fano matroid) to see if the formula extends.

**Impact**: This would establish defect theory as a matroid invariant, massively expanding its scope. It would connect to the theory of Tutte polynomials, matroid Betti numbers, and algebraic combinatorics.

**Catalog References**: `Pythagorean/TropicalBridge/DeletionCalculus.lean` — the cycle rank β₁ is the matroid nullity.

**Proof Strategy**: Define δ_M = nullity(M|_S) + κ_M(q, S) − 1, where nullity(M|_S) is the nullity of the restriction of M to S, and κ_M(q, S) is an appropriately defined root-component count for matroids (using the matroid's lattice of flats). Verify the deletion law using matroid deletion properties.

**Domain Bridges**: Matroid theory, algebraic combinatorics, Tutte polynomials.

**Lineage**: Motivated by the matroidal interpretation of Theorem 4.

**Ambition**: ★★★★★ (Grand challenge — requires novel matroid-theoretic constructions)

---

## Direction 4: Higher-Dimensional Defect via Simplicial Complexes

**Conjecture**: For a simplicial complex Δ with a distinguished vertex q and a subcomplex Σ ⊆ Δ:
$$\delta_k(\Delta, q, \Sigma) = \beta_k(\Sigma) + \kappa_k(\Delta, q, \Sigma) − 1$$
where β_k is the k-th Betti number and κ_k is an appropriate higher-dimensional root-separation measure. The deletion law should generalize: removing a k-cell that is not a "higher bridge" reduces δ_k by 1.

**Test**: Compute β_k and κ_k for small simplicial complexes (triangulations of surfaces, skeleta of polytopes) and verify the deletion law for 2-cells on surfaces.

**Impact**: This would extend defect theory from 1-dimensional topology (graphs) to arbitrary dimensions, connecting to homological algebra, persistent homology, and topological data analysis.

**Catalog References**: `Pythagorean/TropicalBridge/DeletionCalculus.lean` — the 1-dimensional case β₁.

**Proof Strategy**: The 1-dimensional proof uses: (1) removing a non-bridge 1-cell reduces β₁ by 1, (2) the root-separation κ is invariant. For higher dimensions: (1) follows from the long exact sequence in homology; (2) requires defining κ_k appropriately (perhaps using relative homology H_k(Δ, Δ \ {q})).

**Domain Bridges**: Algebraic topology, persistent homology, topological data analysis.

**Lineage**: Inspired by the topological interpretation of β₁ as the first Betti number.

**Ambition**: ★★★★★ (Grand challenge — paradigm-shifting if successful)

---

## Direction 5: Closing the Tropical Bridge Gap

**Conjecture**: The structural defect δ(G,q,S) exactly equals the tropical bridge gap:
$$\text{tropRank}(L_S) − 1 − r(D_S) = \delta(G,q,S)$$
where tropRank is the tropical rank of the restricted Laplacian and r(D_S) is the Baker–Norine divisor rank.

**Test**: Compute both sides explicitly for all connected graphs with n ≤ 6, all roots q, all subsets S. This requires implementing:
1. The tropical rank of the restricted Laplacian (compute the tropical determinant or use the tropical rank formula).
2. The Baker–Norine chip-firing rank (use Dhar's burning algorithm).
3. Compare with δ = β₁ + κ − 1.

**Impact**: This would resolve the main motivating conjecture of defect theory, establishing the structural defect as the exact gap in the tropical bridge. Combined with the deletion law, it would give the first exact formula for how the tropical rank gap responds to graph modification.

**Catalog References**: `Catalog/Pythagorean/TropicalBridge/DefectTheory.lean` — states the defect formula.

**Proof Strategy**: Use the deletion calculus inductively. If the gap satisfies the same deletion law as δ (gap drops by 1 under non-bridge deletion, gap preserved under bridge deletion), then by induction on β₁, it suffices to prove the conjecture for forest graphs (β₁ = 0). For forests, the tropical rank and chip-firing rank can be computed directly.

**Domain Bridges**: Tropical geometry, algebraic graph theory, chip-firing games.

**Lineage**: The original motivation for defect theory, as described in Baker–Norine (2007) and Develin–Santos–Sturmfels (2005).

**Ambition**: ★★★★☆ (High-impact — would close the central conjecture)
