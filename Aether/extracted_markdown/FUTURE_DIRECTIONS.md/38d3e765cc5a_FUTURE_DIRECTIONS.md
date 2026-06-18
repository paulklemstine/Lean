# Future Directions

## Synthesis

The defect decomposition law δ(S₁ ∪ S₂) = δ(S₁) + δ(S₂) + 1 for root-separated pieces establishes the structural defect as a compositional invariant. This opens a research program along five directions: characterizing non-separated interactions, extending to weighted graphs, building a full Mayer–Vietoris exact sequence, connecting to tropical moduli, and applications to network algorithms. All directions share the theme of understanding when and how graph invariants decompose under topological separation.

---

## Direction 1: Interaction Classification for Non-Separated Pairs

**Conjecture:** The defect interaction I_q(S₁,S₂) = δ(S₁∪S₂) − δ(S₁) − δ(S₂) for disjoint S₁, S₂ (not necessarily root-separated) satisfies:
$$I_q(S_1,S_2) = 1 - c_{cross}(S_1,S_2,q)$$
where c_cross counts the number of connected components of G[S₁ ∪ S₂] that contain vertices from both S₁ and S₂.

**Test:** Enumerate all connected graphs with n ≤ 7, all roots q, all disjoint pairs (S₁,S₂) with q ∉ S₁ ∪ S₂. Compute I_q and c_cross. A single pair where I_q ≠ 1 − c_cross refutes the conjecture.

**Impact:** A complete formula for I_q would extend the decomposition law from the root-separated case to all disjoint pairs, creating a universal gluing formula.

**Catalog References:** `Pythagorean/TropicalBridge/DefectTheory.lean` (structuralDefect definition), `Pythagorean/TropicalBridge/RootSeparatedDecomposition.lean` (defectInteraction).

**Proof Strategy:** Extend the component equivalence construction by tracking cross-components explicitly. The forward bijection on connected components would gain a correction for components spanning both pieces.

**Domain Bridges:** Statistical mechanics (interaction energy classification), algebraic topology (relative homology).

**Lineage:** Direct extension of `defectInteraction_eq_one_of_rootSeparated`.

**Ambition:** Medium — extends the core result to the general case.

---

## Direction 2: Mayer–Vietoris Exact Sequence for Graph Defect

**Conjecture:** There exists a short exact sequence of abelian groups:
$$0 \to H_1(G[S_1 \cap S_2]) \to H_1(G[S_1]) \oplus H_1(G[S_2]) \to H_1(G[S_1 \cup S_2]) \to H_0(G[S_1 \cap S_2]) \to \cdots$$
whose Euler characteristic gives the defect decomposition law as a numerical shadow.

**Test:** For overlapping (non-disjoint) subsets, compute all terms of the proposed sequence on graphs with n ≤ 8. Verify exactness by checking that the image of each map equals the kernel of the next.

**Impact:** Paradigm-shifting — this would embed graph defect theory into simplicial homology, providing systematic tools for arbitrarily complex decompositions (not just root-separated ones).

**Catalog References:** `Pythagorean/TropicalBridge/DefectTheory.lean` (cycle rank = first Betti number), `Pythagorean/TropicalBridge/RootSeparatedDecomposition.lean` (additivity lemmas).

**Proof Strategy:** Define simplicial chain complexes for induced subgraphs, construct the Mayer–Vietoris connecting homomorphism, verify exactness via snake lemma.

**Domain Bridges:** Algebraic topology (Mayer–Vietoris theorem), homological algebra (exact sequences), topological data analysis (persistent homology).

**Lineage:** Extends Direction 1 to overlapping subsets.

**Ambition:** Grand challenge — requires developing simplicial homology infrastructure in Lean.

---

## Direction 3: Weighted Graph Extension and Tropical Divisor Rank

**Conjecture:** For edge-weighted graphs (G,w) with weight function w : E → ℝ₊, define the weighted defect δ_w(G,q,S) using weighted cycle rank and weighted root-component count. Then for root-separated pieces:
$$\delta_w(S_1 \cup S_2) = \delta_w(S_1) + \delta_w(S_2) + 1$$
with the same universal +1 correction, independent of edge weights.

**Test:** Generate random weighted connected graphs with n ≤ 10, random weight assignments. Verify the identity computationally on all root-separated pairs.

**Impact:** Extends the decomposition law to metric graphs and tropical curves, connecting to Baker–Norine theory on metric graphs.

**Catalog References:** `Pythagorean/TropicalBridge/Defs.lean` (graphLaplacian), `Pythagorean/TropicalBridge/Theorems.lean` (Laplacian structural properties).

**Proof Strategy:** The proof should transfer because root-separation depends only on topology (connectivity), not weights. The correction term is topological.

**Domain Bridges:** Tropical geometry (metric graphs), spectral graph theory (weighted Laplacians).

**Lineage:** Builds on the main decomposition theorem.

**Ambition:** Solid extension — moderate difficulty, high value for tropical geometry applications.

---

## Direction 4: Defect Spectrum Decomposition

**Conjecture:** The higher defect spectrum δ_d(G,q,S) = d·β₁(G[S]) + κ(G,q,S) − 1 satisfies:
$$\delta_d(G,q, S_1 \cup S_2) = \delta_d(G,q, S_1) + \delta_d(G,q, S_2) + 1$$
for all degrees d ≥ 1 and root-separated pieces S₁, S₂.

**Test:** Verify on all connected graphs with n ≤ 6, all roots, all root-separated pairs, for d = 1,2,...,10.

**Impact:** Extends the decomposition law from the degree-1 defect to the entire defect spectrum, preserving the +1 correction across all degrees.

**Catalog References:** `Pythagorean/TropicalBridge/HigherDefectTheory.lean` (higherStructuralDefect), `Pythagorean/TropicalBridge/RootSeparatedDecomposition.lean`.

**Proof Strategy:** The proof follows immediately from β₁ and κ additivity (already proved) plus the higher defect formula δ_d = d·β₁ + κ − 1. The correction is still +1 because only the −1 contributes.

**Domain Bridges:** Algebraic geometry (Hilbert polynomials), discrete analysis (higher-order invariants).

**Lineage:** Direct combination of HigherDefectTheory and RootSeparatedDecomposition.

**Ambition:** Solid extension — follows from existing infrastructure with minimal new work.

---

## Direction 5: Network Resilience via Defect Localization

**Conjecture:** In a network with root q, the vertex with maximum defect contribution (defined as the maximum δ(G,q,{v}) over v ∈ V \ {q}) lies in the sector with the largest cycle rank. Moreover, removing this vertex reduces the total defect by at most 1 + β₁(G[sector]).

**Test:** Compute defect contributions on random graphs with n = 20,...,100. Track which sectors contribute most. Verify the bound by exhaustive vertex removal.

**Impact:** Creates a practical algorithm for network vulnerability assessment based on defect localization.

**Catalog References:** `Pythagorean/TropicalBridge/DefectTheory.lean` (structuralDefect_nonneg, structuralDefect_eq_zero_iff).

**Proof Strategy:** Use the decomposition law to bound defect changes under vertex removal. The sector structure constrains how much defect can be concentrated.

**Domain Bridges:** Network science (centrality measures), reliability engineering (critical infrastructure identification).

**Lineage:** Applies the decomposition law as an algorithmic tool.

**Ambition:** Medium — requires combining theoretical bounds with computational validation.
