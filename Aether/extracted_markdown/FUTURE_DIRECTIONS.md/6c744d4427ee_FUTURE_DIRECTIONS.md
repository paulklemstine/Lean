# Future Directions: Verified Extremal Combinatorics

## Synthesis

The framework established here — Turán bounds, degree energy, triangle removal, and the additive combinatorics bridge — forms the foundation of a verified extremal graph theory platform. The key insight is that degree energy serves as a universal mediator: it connects local structure (clique-freeness) to global bounds (edge counts) via Cauchy-Schwarz, and it connects algorithmic procedures (greedy removal) to certified guarantees. The five directions below extend this platform along complementary axes: deeper Turán bounds, quantitative removal, additive combinatorics, hypergraph generalization, and stability/reconstruction.

---

## Direction 1: Full Turán Theorem via Degree-Counting Induction

**Conjecture**: For all r ≥ 2 and n ≥ 1, every K_r-free graph G on n vertices satisfies (r-1) · 2|E(G)| ≤ (r-2) · n².

**Test**: Verify computationally for all K_r-free graphs with n ≤ 12 and r ≤ 6 by exhaustive enumeration. The bound should hold with equality achieved only by the Turán graph T(n, r-1).

**Impact**: This would be the first machine-checked proof of the general Turán theorem, a cornerstone of extremal combinatorics. It unlocks all downstream applications (supersaturation, stability, counting).

**Catalog References**: `Algebra/ExtremalGraph/Theorems.lean` — `neighborhood_cliqueFree` provides the inductive step; `mantel_theorem` proves the base case r=3.

**Proof Strategy**: Induction on r. For a K_r-free graph G, pick a vertex v of maximum degree d. By `neighborhood_cliqueFree`, the subgraph induced on N(v) is K_{r-1}-free. By inductive hypothesis, N(v) has ≤ (r-3)/(r-2) · d²/2 edges. Sum over all vertices using double counting and optimize via Cauchy-Schwarz to obtain the global bound.

**Domain Bridges**: Extremal graph theory → number theory (Turán-type bounds on sum-free sets), coding theory (bounds on constant-weight codes).

**Lineage**: Extends `mantel_theorem` and `neighborhood_cliqueFree` from the current framework.

**Ambition**: ★★★★☆ — Technically demanding but conceptually clear. The proof strategy is well-understood; the challenge is in formalizing the optimization step.

---

## Direction 2: Quantitative Triangle Removal via Regularity

**Conjecture**: There exists an explicit function δ(ε) = ε^C for some constant C such that: every graph on n vertices with at most δ(ε)·n³ triangles can be made triangle-free by removing at most ε·n² edges. A tower-type bound δ(ε) = 1/tower(1/ε) should be provable via a formalized regularity lemma.

**Test**: For random graphs G(n, p) with n ≤ 20 and p near the triangle threshold, verify that the greedy removal algorithm achieves edit distance consistent with the predicted δ-ε tradeoff. Specifically, test whether δ = ε³ suffices for n ≤ 15.

**Impact**: A formalized regularity lemma would be a landmark in verified combinatorics, enabling proofs of the hypergraph removal lemma, property testing bounds, and Szemerédi's theorem.

**Catalog References**: `Algebra/ExtremalGraph/Theorems.lean` — `greedy_triangle_removal` provides the algorithmic certificate; `triangle_free_degree_energy_bound` provides the energy framework.

**Proof Strategy**: Formalize Szemerédi's regularity lemma for graphs (partition into ε-regular pairs), then derive the counting lemma (regular pairs with sufficient density contain the expected number of triangles), and finally prove the removal lemma by contradiction: a graph with few triangles but many edges far from triangle-free would contradict the counting lemma in its regular partition.

**Domain Bridges**: Extremal graph theory → property testing (ε-testing for triangle-freeness), additive combinatorics (arithmetic regularity), theoretical computer science (algorithmic regularity).

**Lineage**: Extends `greedy_triangle_removal` and `edgeEditDistance` from the current framework.

**Ambition**: ★★★★★ (Grand Challenge) — Formalizing the regularity lemma is one of the most significant open targets in verified mathematics. Previous attempts exist but are incomplete.

---

## Direction 3: Formalized 3-AP/Triangle Correspondence and Roth's Theorem

**Conjecture**: The tripartite graph encoding of A ⊆ Z/NZ satisfies: triangle_count(encoding(A)) = |{(a,b,c) ∈ A³ : a+c = 2b, a ≠ b ≠ c ≠ a}| / 6, and applying the triangle removal lemma to this encoding yields Roth's theorem: r₃(N) = o(N) where r₃(N) is the maximum size of a 3-AP-free subset of {1,...,N}.

**Test**: Verify the exact triangle count equals the 3-AP count (up to normalization) for all A ⊆ Z/NZ with N ≤ 20 by exhaustive computation. The ratio should be exactly 1 after accounting for the ordering convention.

**Impact**: A formalized Roth's theorem via the graph-theoretic method would be the first machine-checked proof of this fundamental result in additive combinatorics.

**Catalog References**: `Algebra/ExtremalGraph/Defs.lean` — `isThreeAP`, `threeAPCount`, `orderedTriangleFinset` provide the basic definitions.

**Proof Strategy**: (1) Define the tripartite encoding precisely in Lean. (2) Prove the bijection between triangles and 3-APs. (3) Apply the triangle removal lemma (Direction 2) to derive: if |A| ≥ δN, the encoding has Ω(δ³N³) triangles, so removing O(εN²) edges suffices to destroy them, which means removing O(ε/δ) fraction of A removes all APs. For δ >> ε, this is a contradiction.

**Domain Bridges**: Additive combinatorics → analytic number theory (density bounds on AP-free sets), harmonic analysis (Fourier-analytic proofs of Roth for comparison), ergodic theory (Furstenberg's approach).

**Lineage**: Builds on `threeAPCount` and `triangleCount` definitions, uses `greedy_triangle_removal` as algorithmic infrastructure.

**Ambition**: ★★★★★ (Grand Challenge) — Requires Direction 2 as a prerequisite. The encoding itself is straightforward; the deep content is in the removal lemma application.

---

## Direction 4: Kruskal-Katona Theorem via Compression

**Conjecture**: For any k-uniform family F on [n] with |F| = m, the shadow satisfies |∂F| ≥ |∂C_m^k| where C_m^k is the initial segment of the colex (squashed) ordering of k-sets of size m. Furthermore, left-compression does not increase shadow size: |∂(compress_{ij}(F))| ≤ |∂F|.

**Test**: For n = 8, k = 3, verify for all m ≤ C(8,3) = 56 that: (a) the initial segment achieves the minimum shadow, and (b) random compressions never increase shadow size. Test 1000 random families per value of m.

**Impact**: The Kruskal-Katona theorem is the foundation of extremal set theory. A formalized version would enable proofs of the Bollobás set-pairs inequality, the Lovász version of KK, and applications to coding theory.

**Catalog References**: `Algebra/ExtremalGraph/Defs.lean` — `lowerShadow`, `uniformFamily` definitions; `Algebra/ExtremalGraph/Theorems.lean` — `lowerShadow_mono` proves basic monotonicity.

**Proof Strategy**: (1) Define colex ordering on k-sets. (2) Define left-compression operators. (3) Prove compression does not increase shadow (the key technical lemma). (4) Show that repeated compression converges to the initial segment. (5) Conclude by showing the initial segment minimizes shadow.

**Domain Bridges**: Extremal set theory → coding theory (bounds on code sizes), discrete isoperimetry (Harper's theorem on the cube), algebraic topology (simplicial complex theory).

**Lineage**: Extends `lowerShadow` and `uniformFamily` from the current framework.

**Ambition**: ★★★★☆ — Well-understood proof, but compression arguments require careful bookkeeping in Lean.

---

## Direction 5: Turán Stability and Degree Energy Descent

**Conjecture**: Every K_r-free graph G on n vertices with |E(G)| ≥ ex(n, K_r) - t can be made into the Turán graph T(n, r-1) by adding and removing at most C·t edges, for an explicit constant C depending on r. Equivalently, the degree energy of near-extremal K_r-free graphs is close to that of the Turán graph: |E(G) - E(T(n,r-1))| ≤ C'·t·n.

**Test**: For n ≤ 20 and r = 3, enumerate K_3-free graphs with edge count within 3 of ex(n,K_3) and measure their edit distance to T(n,2). Verify that the edit distance is at most 6t in all cases.

**Impact**: Stability theorems are the bridge between extremal bounds and structural characterizations. They enable approximate structure theorems and are essential for counting (how many near-extremal graphs exist?).

**Catalog References**: `Algebra/ExtremalGraph/Defs.lean` — `degreeEnergy`, `edgeEditDistance`, `TuranGraph`; `Algebra/ExtremalGraph/Theorems.lean` — `mantel_theorem`, `turanGraph_cliqueFree`.

**Proof Strategy**: Simonovits stability theorem proof: (1) Assume G is K_r-free with many edges. (2) Use degree energy bound to show most vertices have degree close to (1-1/(r-1))n. (3) Use the neighborhood clique-free lemma to show the "heavy" vertices form an approximate (r-1)-partition. (4) Bound the number of edges violating the partition by the deficit t.

**Domain Bridges**: Stability → graph limits (graphon characterization of extremal sequences), algorithms (reconstruction of hidden partitions), statistical physics (ground state perturbation theory).

**Lineage**: Extends `mantel_theorem`, `degreeEnergy`, and `edgeEditDistance` from the current framework.

**Ambition**: ★★★☆☆ — The stability theorem for r=3 (Simonovits, 1968) has a clean proof that should be formalizable given the current infrastructure.
