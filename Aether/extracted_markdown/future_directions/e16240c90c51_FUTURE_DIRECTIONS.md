# Future Directions: Defect-Theoretic Tropical Brill–Noether Theory

## Synthesis

The structural defect δ(G,q,S) = β₁(G[S]) + κ(G,q,S) − 1 provides the first quantitative decomposition of the tropical bridge gap into topological (cycle rank) and combinatorial (root separation) contributions. This opens five research directions, ranging from completing the bridge to the full equality defect (Direction 1), through structural decomposition theorems (Directions 2–3), to extensions into continuous tropical geometry (Direction 4) and higher-rank theory (Direction 5). Together, these directions would establish *defect-theoretic tropical Brill–Norine theory* as a coherent field with computable invariants, obstruction calculus, and connections to algebraic geometry, spectral theory, and network science.

---

## Direction 1: Full Equality Defect Identification

**Conjecture:** For every finite connected graph G, root q ∈ V(G), and nonempty S ⊆ V \ {q}:
$$\text{tropRank}(L_S) - 1 - r(D_S) = \beta_1(G[S]) + \kappa(G,q,S) - 1$$

That is, the structural defect equals the equality defect between tropical Laplacian rank and Baker–Norine divisor rank.

**Test:** Implement tropical rank computation (via optimal assignment) and Baker–Norine rank computation (via chip-firing game simulation) in Python. Run exhaustive comparison on all connected graphs with n ≤ 7 vertices. A single counterexample disproves the conjecture. If confirmed for n ≤ 7, attempt formal proof via Laplacian kernel analysis.

**Impact:** Establishes a universal formula converting the binary equality question into a computable topological invariant. Would unify tropical linear algebra and chip-firing theory through a single defect equation.

**Catalog References:** `Pythagorean/TropicalBridge/Defs.lean` (Laplacian definition), `Pythagorean/TropicalBridge/Theorems.lean` (divisor decomposition), `Pythagorean/TropicalBridge/DefectTheory.lean` (structural defect theorems).

**Proof Strategy:** (A) Use the existing `rootedSubsetDivisor_decomposition` to split D_S along root-separated components and track how each component contributes to rank. (B) Show the tropical rank of L_S decomposes as a sum over components plus cycle correction. (C) Reassemble to obtain the full formula.

**Domain Bridges:** Tropical linear algebra ↔ chip-firing theory ↔ algebraic topology.

**Lineage:** Extends Baker–Norine [2007] and builds on the zero-defect case from the existing catalog.

**Ambition:** ★★★★★ Grand Challenge — this is the central conjecture of the theory.

---

## Direction 2: Defect Additivity over Root-Separated Pieces

**Conjecture:** If S = S₁ ⊔ S₂ where S₁ and S₂ lie in distinct connected components of G − {q}, then:
$$\delta(G,q,S_1 \cup S_2) = \delta(G,q,S_1) + \delta(G,q,S_2) + 1$$

**Test:** Exhaustive verification on all connected graphs with n ≤ 7, all roots q, and all splittings S = S₁ ⊔ S₂ across root-separated components. Check whether the additivity formula holds or needs a correction term.

**Impact:** Would establish that the defect has a "direct sum" structure, decomposing along the rooted graph decomposition. This is analogous to the Mayer–Vietoris sequence in algebraic topology.

**Catalog References:** `Pythagorean/TropicalBridge/DefectTheory.lean` (rootComponentCount definition), `Pythagorean/TropicalBridge/Theorems.lean` (rootedSubsetDivisor_decomposition).

**Proof Strategy:** Show that β₁(G[S₁ ∪ S₂]) = β₁(G[S₁]) + β₁(G[S₂]) when S₁, S₂ are in separate components (no cross-edges). Show κ(G,q,S₁ ∪ S₂) = κ(G,q,S₁) + κ(G,q,S₂). Combine.

**Domain Bridges:** Graph decomposition theory ↔ homological algebra (Künneth formula analogue).

**Lineage:** Direct extension of the zero-defect rigidity theorem.

**Ambition:** ★★★☆☆ Solid extension.

---

## Direction 3: Minor Monotonicity of Defect

**Conjecture:** If H is obtained from G by deleting an edge e inside G[S] (with e not incident to q), then:
$$\delta(H,q,S) \leq \delta(G,q,S)$$

Moreover, equality holds if and only if e is a bridge of G[S].

**Test:** For each connected graph G with n ≤ 7, each root q, each S, and each eligible edge e ∈ E(G[S]), compute δ(G,q,S) and δ(G−e,q,S). Verify the inequality and check the equality condition.

**Impact:** Would establish that the defect is monotone under edge deletion inside G[S], making it a well-behaved complexity measure. This connects to graph minor theory and matroid theory.

**Catalog References:** `Pythagorean/TropicalBridge/DefectTheory.lean` (inducedCycleRank, structuralDefect).

**Proof Strategy:** Edge deletion inside G[S] decreases e(G[S]) by 1. If the deleted edge is a bridge, c(G[S]) increases by 1, so β₁ stays the same. If not a bridge, c stays the same, so β₁ decreases by 1. In both cases, κ is unchanged (edge deletion inside S doesn't affect G − {q} components). Combine to get δ(H) ≤ δ(G).

**Domain Bridges:** Matroid theory ↔ graph minor theory ↔ topological complexity measures.

**Lineage:** Extends the nonnegativity theorem.

**Ambition:** ★★★☆☆ Solid extension.

---

## Direction 4: Metrized Graph / Tropical Curve Extension

**Conjecture:** The structural defect extends to metrized graphs (tropical curves) Γ with edge lengths, where β₁ is defined via the first Betti number of the underlying topological space and κ counts connected components of Γ − {q} intersecting a given closed subset. The defect formula δ = β₁ + κ − 1 continues to hold in this continuous setting.

**Test:** Implement tropical curve chip-firing computation with rational edge lengths. Test on subdivisions of small graphs (replacing edges by paths of varying lengths). Verify that the defect depends only on the combinatorial type, not the edge lengths.

**Impact:** Would establish the defect as a *tropical* invariant — independent of metric refinement. This connects to tropical Brill–Noether theory and the work of Cools–Draisma–Payne–Robeva.

**Catalog References:** `Pythagorean/TropicalBridge/DefectTheory.lean`.

**Proof Strategy:** Show that edge subdivision (replacing an edge by a path) preserves β₁ and κ. Use the Baker–Norine specialization lemma to relate divisor rank on the metrized graph to rank on finite models. Conclude that the defect is a combinatorial type invariant.

**Domain Bridges:** Tropical geometry ↔ algebraic curves ↔ Berkovich analytification.

**Lineage:** Extends Baker–Norine to the continuous setting via Gathmann–Kerber and CDPR.

**Ambition:** ★★★★☆ Grand challenge.

---

## Direction 5: Higher-Rank Defect Theory

**Conjecture:** For divisors of higher degree d ≥ 2 on a graph G, define the *d-defect* by replacing r(D_S) with the rank of D_S + (d−1)·D_0 for an appropriate base divisor. The d-defect satisfies:
$$\delta_d(G,q,S) = d \cdot \beta_1(G[S]) + \kappa(G,q,S) - 1$$

with the cycle rank contribution scaling linearly with d.

**Test:** Compute higher-degree divisor ranks using the chip-firing game for d = 2, 3 on small graphs. Check whether the d-fold cycle scaling holds.

**Impact:** Would establish a family of defect invariants indexed by degree, creating a *defect spectrum* for each rooted graph. This connects to the full Brill–Norine theory and higher-rank vector bundles.

**Catalog References:** `Pythagorean/TropicalBridge/Defs.lean` (rootedSubsetDivisor), `Pythagorean/TropicalBridge/DefectTheory.lean`.

**Proof Strategy:** The key insight is that each independent cycle in G[S] contributes one dimension of rank defect per unit of degree. Formalize this via induction on cycle rank, using edge deletion/contraction.

**Domain Bridges:** Vector bundle theory ↔ higher-rank Brill–Norine ↔ K-theory of graphs.

**Lineage:** Natural generalization of the degree-1 theory.

**Ambition:** ★★★★☆ Paradigm-shifting if confirmed.
