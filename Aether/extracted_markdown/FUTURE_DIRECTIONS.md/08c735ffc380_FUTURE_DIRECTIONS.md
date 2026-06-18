# Future Directions: Tropical Persistence Stability Theory

## Synthesis

The tropical interleaving distance framework established here creates a new algebraic stability theory with five proven pillars: pseudometric structure, algebraic stability, universal control, cross-domain graph bridge, and strict gap phenomenon. These results reveal that tropical persistence behaves fundamentally differently from classical persistence — the gap between pointwise and interleaving distances grows without bound, tropical modules cannot be compared by barcode matching alone, and the interleaving distance captures temporal-shift information invisible to pointwise methods.

The directions below build on these foundations in two modes: **extensions** that deepen the tropical persistence theory using the proven machinery, and **grand challenges** that connect to other mathematical domains through the bridge theorems. Each direction targets a specific formal conjecture that is daring enough to reshape our understanding and specific enough to be refuted.

---

## Direction 1: Tropical Interval Decomposition and the Isometry Problem

**The key insight is...** Classical persistence modules decompose into interval modules, and the bottleneck distance on interval decompositions equals the interleaving distance (the isometry theorem). In the tropical world, our strict gap theorem (Theorem 8 in `Pythagorean/TropicalBridge/Interleaving.lean`) proves that the naive pointwise distance differs from the interleaving distance. The question is whether there exists a *tropical interval decomposition* with an associated matching distance that *does* equal the interleaving distance, recovering an isometry.

**Why now?** The strict gap theorem identifies the exact obstruction: step position offsets. This suggests that the "correct" tropical barcode must encode step positions, not just heights — analogous to recording birth-death times rather than Betti numbers. The step modules defined in our framework provide the building blocks for any decomposition theory.

**Conjecture:** Every finite-type tropical persistence module with bounded local variation K decomposes as a finite sum of step modules, and the bottleneck matching distance on step positions equals the interleaving distance.

**Test:** Computationally enumerate all finite-type modules supported on [-n, n] with total variation ≤ V, compute both the matching distance on step decompositions and the interleaving distance, and check equality. Run for n ≤ 30, V ≤ 10.

**Impact:** Would complete the tropical analogue of the classical persistence structure theorem, providing the missing piece for a full isometry theory.

**Catalog References:** `Pythagorean/TropicalBridge/Interleaving.lean` (strict_gap, stepModule, interleavDist)

**Proof Strategy:** Define a greedy decomposition algorithm that extracts step modules from a tropical persistence module. Prove the decomposition is unique (up to reordering). Show the matching distance equals the interleaving distance by constructing optimal interleavings from optimal matchings and vice versa.

**Domain Bridges:** Algebraic combinatorics (matroid decomposition), optimization (matching theory)

**Lineage:** Extends strict_gap and stepModule theory from Interleaving.lean

**Ambition:** Solid extension — builds directly on established framework

---

## Direction 2: Tropical Sheaf Persistence on Networks

**The key insight is...** The graph bridge theorem (`graphTPM_stable` in `Pythagorean/TropicalBridge/Interleaving.lean`) shows that graph filtrations produce tropical persistence modules with controlled stability. But a graph filtration captures only *global* cumulative information. A tropical sheaf on a graph assigns a tropical persistence module to each vertex (or edge), with restriction maps encoding local-to-global consistency. The interleaving distance then lifts to a sheaf distance.

**Why now?** The graph bridge theorem provides the base case: each vertex contributes a "local" tropical module. The composition theorem (isInterleaved_comp) provides the algebraic machinery for composing local interleavings into global ones. The missing piece is the sheaf-theoretic formalization.

**Conjecture:** For a tropical sheaf on a graph G with n vertices, the sheaf interleaving distance satisfies a Mayer-Vietoris-type inequality:
```
d_I(F, G) ≤ max_{v ∈ V} d_I(F_v, G_v) + max_{e ∈ E} d_I(F_e, G_e)
```
where F_v, G_v are the stalks at vertices and F_e, G_e at edges.

**Test:** Implement tropical sheaves on small graphs (cycles, trees, complete graphs with n ≤ 10). Compute both sides of the inequality for random sheaf perturbations.

**Impact:** Would create a framework for distributed stability in sensor networks, multi-agent systems, and network optimization — each node carries a local persistence module, and the sheaf structure enforces global coherence.

**Catalog References:** `Pythagorean/TropicalBridge/Interleaving.lean` (graphTPM_stable, isInterleaved_comp), `Pythagorean/TropicalBridge/Stability.lean` (tropical_barcode_stability)

**Proof Strategy:** Define tropical cosheaves as functors from the face poset of a graph to the category of tropical persistence modules. Prove the Mayer-Vietoris inequality using the composition theorem and a nerve-theoretic argument.

**Domain Bridges:** Sheaf theory, distributed computing, sensor networks, multi-agent optimization

**Lineage:** Extends graphTPM_stable to local-to-global theory

**Ambition:** Grand challenge — requires new categorical infrastructure

---

## Direction 3: Idempotent Wasserstein Geometry

**The key insight is...** The interleaving distance is a "bottleneck-type" metric — it measures the worst-case shift. Classical TDA also studies Wasserstein distances, which measure the *average* cost of transporting one barcode to another. In the tropical (idempotent) world, there should be an analogous "tropical Wasserstein distance" where transport costs are computed using min-plus algebra rather than ordinary arithmetic.

**Why now?** The pseudometric theorem (interleavDist_triangle) provides the metric foundation. The variation bound theorem provides the bridge between shifts and pointwise costs. The key gap is: we measure worst-case shifts, but many applications need average-case measures.

**Conjecture:** There exists a tropical Wasserstein distance W_p on finite-type tropical persistence modules satisfying:
```
W_∞(M, N) = interleavDist(M, N)
W_1(M, N) ≤ ∑_i |M.val(i) - N.val(i)|
```
and both W_1 and W_∞ are pseudometrics with the same stability properties.

**Test:** Define W_1 computationally as the sum of step-matching costs. Verify pseudometric properties and stability bounds for all pairs of finite-type modules supported on [-20, 20].

**Impact:** Would connect tropical persistence to optimal transport theory, opening applications in machine learning (Wasserstein GANs, distribution comparison) and economics (allocation problems).

**Catalog References:** `Pythagorean/TropicalBridge/Interleaving.lean` (interleavDist, variation_bound, pointwise_le_of_interleaved)

**Proof Strategy:** Define the transport plan between two tropical modules as an assignment between their step positions. Prove the triangle inequality using the composition of transport plans.

**Domain Bridges:** Optimal transport, machine learning, mathematical economics

**Lineage:** Generalizes interleavDist from bottleneck to transport metrics

**Ambition:** Grand challenge — paradigm-shifting connection between tropical algebra and optimal transport

---

## Direction 4: Tropical Stability of Hamilton–Jacobi Semigroups

**The key insight is...** The Hamilton-Jacobi equation ∂_t u + H(x, ∇u) = 0 has solutions that propagate via the Lax-Oleinik semigroup, which is a *tropical (min-plus) linear operator*. The value function u(t, x) at each time t can be viewed as a tropical persistence module over the spatial variable x. Our stability theory should therefore provide stability bounds for Hamilton-Jacobi solutions under perturbation of the Hamiltonian.

**Why now?** The variation bound theorem and algebraic stability theorem provide exactly the tools needed: if two Hamiltonians differ by ε, their value functions (tropical persistence modules) should differ by at most C · ε in interleaving distance, where C depends on the Hamiltonian's convexity.

**Conjecture:** For uniformly convex Hamiltonians H₁, H₂ on ℝⁿ with |H₁ - H₂| ≤ ε, the associated Lax-Oleinik semigroups S₁ᵗ, S₂ᵗ satisfy:
```
interleavDist(S₁ᵗ(u₀), S₂ᵗ(u₀)) ≤ C(t) · ε
```
where C(t) depends on the convexity constant and time.

**Test:** Discretize 1D Hamilton-Jacobi equations with quadratic Hamiltonians. Compute tropical interleaving distances between solution profiles under Hamiltonian perturbation. Verify the linear bound in ε.

**Impact:** Would create the first bridge between tropical persistence theory and PDE analysis, with applications in optimal control, differential games, and front propagation.

**Catalog References:** `Pythagorean/TropicalBridge/Interleaving.lean` (variation_bound, pointwise_le_of_interleaved, interleavDist_triangle)

**Proof Strategy:** Use the Lax-Oleinik formula to express the semigroup in min-plus form. Show that ε-perturbation of the Hamiltonian produces ε-perturbation of the value function at each time. Apply the graph bridge theorem (adapted to continuous indices) to conclude.

**Domain Bridges:** PDE theory, optimal control, viscosity solutions, dynamical systems

**Lineage:** Extends algebraic stability to continuous dynamics

**Ambition:** Grand challenge — paradigm-shifting bridge from algebra to analysis

---

## Direction 5: Tropical Persistence for Phylogenetic Recombination

**The key insight is...** Phylogenetic trees with branch lengths encode evolutionary distances. When recombination occurs (as in viral evolution or horizontal gene transfer), the "true" evolutionary history is not a single tree but a *network*. Different genomic regions have different tree topologies. The tropical persistence of the distance filtration on these trees provides a recombination-invariant summary.

**Why now?** The graph bridge theorem shows that perturbation of vertex distances by δ changes the persistence module by at most δ. In phylogenetics, recombination can be modeled as a perturbation of the effective distance metric. The stability theorem therefore bounds the impact of recombination on persistence signatures.

**Conjecture:** For two phylogenetic trees T₁, T₂ on the same leaf set, differing by a single subtree-prune-and-regraft (SPR) operation:
```
interleavDist(tropPersist(T₁), tropPersist(T₂)) ≤ 2 · max_branch_length
```

**Test:** Generate random phylogenetic trees with n ≤ 50 leaves, apply SPR moves, compute interleaving distances, and verify the bound.

**Impact:** Would provide the first topological stability guarantee for phylogenetic methods under recombination, with applications in viral epidemiology (tracking COVID-19 evolution), population genetics, and horizontal gene transfer analysis.

**Catalog References:** `Pythagorean/TropicalBridge/Interleaving.lean` (graphTPM_stable, interleavDist_triangle)

**Proof Strategy:** Model SPR as a bounded perturbation of the path-distance matrix. Apply the graph bridge theorem to the star graph (leaf distances from root). Use the triangle inequality to compose local perturbation bounds.

**Domain Bridges:** Phylogenetics, epidemiology, population genetics, combinatorial biology

**Lineage:** Applies graphTPM_stable to biological networks

**Ambition:** Solid extension with high practical impact
