# Future Research Directions

## Synthesis

This cycle established a suite of structural theorems about chip-firing on complete graphs $K_n$, building on the Baker-Norine foundations in `Catalog/EML/BakerNorine.lean` and `Catalog/Algebra/GraphRiemannRoch/Defs.lean`. The key discovery is that the chip-firing dynamics on $K_n$ decomposes into three interlocking structures: (1) a **conservation law** ($\Delta \mathbf{1} = 0$, i.e., fire-all triviality), which implies (2) a **complement firing duality** (firing $V \setminus \{v\}$ equals anti-firing $v$), which together with (3) the **$S_n$ symmetry** (permutation equivariance of linear equivalence) forces the canonical divisor to have maximal structural regularity — it is the unique constant divisor of degree $n(n-3)$.

The most promising cross-domain connection is the bridge between the **spectral gap theorem** (Laplacian kernel = constants on $K_n$) and information-theoretic capacity. The spectral gap of $K_n$ controls both the mixing time of random walks and the efficiency of chip-firing redistribution. This suggests a deeper connection between the Baker-Norine rank function and channel capacity — where the "capacity" of a graph $G$ measures how much redistribution freedom chip-firing allows. The complete graph $K_n$ achieves maximal capacity (information dimension $n-1$), and the spectral gap theorem provides the structural explanation: the 1-dimensional kernel means exactly one conservation law, maximizing degrees of freedom.

The direction with the highest breakthrough potential is **Direction 1** (full Baker-Norine Riemann-Roch formalization), because it would be the first complete machine-verified proof of the graph Riemann-Roch theorem. Directions 2 and 3 extend the spectral gap and symmetry results to broader graph classes, while Direction 4 builds the tropical-information bridge into a quantitative theory.

---

### Direction 1: Full Baker-Norine Riemann-Roch via Dhar's Burning Algorithm

**Conjecture**: The full Baker-Norine Riemann-Roch identity $r(D) - r(K_G - D) = \deg(D) - g + 1$ can be formalized and machine-verified for all finite connected graphs $G$, using Dhar's burning algorithm to construct $q$-reduced divisors and compute the rank function.

**Test**: Formalize Dhar's burning algorithm as a computable function on divisors, prove its termination and correctness (it produces the unique $q$-reduced representative), then use the $q$-reduced divisor theory to establish the rank formula. Verify the identity on $K_3$, $K_4$, $K_5$, and the Petersen graph.

**Impact**: If successful, this would be the first complete machine-verified proof of the graph Riemann-Roch theorem — a landmark result connecting combinatorics and algebraic geometry. The formalization would serve as a foundation for tropical Riemann-Roch on metric graphs and higher-dimensional tropical varieties.

**Catalog References**: `Catalog/EML/BakerNorine.lean` (defines `divRank`, `isQReduced`, `linEquiv`), `Catalog/Algebra/GraphRiemannRoch/Defs.lean` (degree conservation, canonical degree formula)

**Proof Strategy**:
1. Formalize Dhar's burning algorithm: given a divisor $D$ and distinguished vertex $q$, repeatedly fire maximal subsets until reaching the $q$-reduced form.
2. Prove the algorithm terminates (bounded by total chip count + graph size).
3. Prove uniqueness of the $q$-reduced representative in each linear equivalence class.
4. Establish the key inequality: $r(D) \geq 0$ iff the $q$-reduced form of $D$ has $D(q) \geq 0$.
5. Use the complement symmetry $K_G - D$ and the canonical degree formula to prove the full Riemann-Roch identity.

**Domain Bridges**: Chip-firing theory <-> Algebraic geometry (Riemann-Roch), Chip-firing <-> Sandpile models (statistical physics)

**Lineage**: Builds on `laplacian_kernel_constant`, `complement_fire_duality`, `linEquiv_preserves_deg`, `neg_deg_no_effective` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Spectral Gap Generalization to Strongly Regular Graphs

**Conjecture**: For a strongly regular graph $\text{srg}(n, k, \lambda, \mu)$, the Laplacian kernel is 1-dimensional (= constants) if and only if the graph is connected, and the kernel characterization on $K_n$ generalizes to an explicit spectral decomposition: the Laplacian of an srg has exactly 3 distinct eigenvalues ($0$, $n - r$, $n - s$ where $r, s$ are the adjacency eigenvalues), and the spectral gap $\min(n - r, n - s)$ controls the chip-firing redistribution efficiency.

**Test**: Formalize the spectral decomposition of strongly regular graphs. Prove that for a connected srg, the Laplacian kernel is exactly the constants. Compute the spectral gap for specific srg's: the Petersen graph $\text{srg}(10, 3, 0, 1)$, the Paley graph $\text{srg}(q, (q-1)/2, (q-5)/4, (q-1)/4)$, and the lattice graph $\text{srg}(n^2, 2(n-1), n-2, 2)$.

**Impact**: This would establish a hierarchy of chip-firing efficiency across graph families, with $K_n$ at the top. The spectral gap ratio controls how quickly chip-firing can redistribute chips, providing quantitative bounds on the "capacity" of different network topologies.

**Catalog References**: `Algebra/ChipFiringStructure.lean` (`laplacian_kernel_constant`, `laplacian_complete_eq`), `Catalog/Algebra/Apollonian/SpectralTransfer.lean` (`spectral_gap_contraction_lt_one`)

**Proof Strategy**:
1. Define strongly regular graphs in Lean (parameters $n, k, \lambda, \mu$).
2. Prove the eigenvalue formula: adjacency eigenvalues are $k$, $r = \frac{(\lambda - \mu) + \sqrt{(\lambda - \mu)^2 + 4(k - \mu)}}{2}$, $s = \frac{(\lambda - \mu) - \sqrt{\cdots}}{2}$.
3. Transfer to Laplacian eigenvalues. Prove kernel = constants for connected srg.
4. Compare spectral gaps across families.

**Domain Bridges**: Spectral graph theory <-> Chip-firing efficiency, Strongly regular graphs <-> Coding theory (Delsarte bound)

**Lineage**: Extends `laplacian_kernel_constant` from $K_n$ to srg's.

**Ambition**: extension

---

### Direction 3: Permutation Equivariance for Cayley Graphs

**Conjecture**: For any finite group $\Gamma$ and symmetric generating set $S$, the chip-firing dynamics on the Cayley graph $\text{Cay}(\Gamma, S)$ is equivariant under the left-regular action of $\Gamma$: if $D_1 \sim D_2$ on $\text{Cay}(\Gamma, S)$, then $g \cdot D_1 \sim g \cdot D_2$ for all $g \in \Gamma$. Moreover, the canonical divisor of $\text{Cay}(\Gamma, S)$ is $\Gamma$-invariant (constant), and the Jacobian group $\text{Jac}(\text{Cay}(\Gamma, S))$ inherits a $\Gamma$-module structure.

**Test**: Formalize Cayley graphs in Lean. Prove the equivariance theorem. Compute the Jacobian as a $\Gamma$-module for small groups: $\mathbb{Z}/n$ (cycle graph), $\mathbb{Z}/2 \times \mathbb{Z}/2$ (square), $S_3$ (with generators $\{(12), (123), (132)\}$).

**Impact**: This connects chip-firing theory to representation theory. The $\Gamma$-module structure of the Jacobian is a new algebraic invariant that captures how the group symmetry interacts with divisor theory. For abelian groups, the Jacobian decomposes into eigenspaces indexed by characters of $\Gamma$.

**Catalog References**: `Algebra/ChipFiringStructure.lean` (`laplacian_perm_equivariant`, `linEquiv_perm_invariant`, `canonical_perm_fixed`)

**Proof Strategy**:
1. Define Cayley graphs as `SimpleGraph Γ` with adjacency $g \sim h$ iff $g^{-1}h \in S$.
2. Show the Laplacian commutes with left multiplication: $L_g \circ \Delta = \Delta \circ L_g$ where $(L_g f)(h) = f(g^{-1}h)$.
3. Transfer to linear equivalence: $D_1 \sim D_2$ implies $g \cdot D_1 \sim g \cdot D_2$ with witness $f \circ L_{g^{-1}}$.
4. For abelian $\Gamma$, decompose the Jacobian using characters.

**Domain Bridges**: Chip-firing <-> Representation theory, Cayley graphs <-> Algebraic combinatorics

**Lineage**: Generalizes `linEquiv_perm_invariant` from $S_n$ acting on $K_n$ to $\Gamma$ acting on $\text{Cay}(\Gamma, S)$.

**Ambition**: extension

---

### Direction 4: Chip-Firing Capacity as a Graph Invariant

**Conjecture**: Define the *chip-firing capacity* of a connected graph $G$ on $n$ vertices as $C(G) = (n - 1) / n$ (the ratio of information dimension to total dimension). Then:
1. $C(G) = (n - 1)/n$ for all connected graphs (the kernel is always 1-dimensional for connected graphs), making this a universal constant in the connected case.
2. The more refined invariant — the *redistribution diameter* $R(G)$, defined as the maximum over all degree-$d$ divisors of the minimum number of chip-firings needed to reach an effective divisor — satisfies $R(K_n) = 1$ (by direct redistribution on $K_n$) but $R(P_n) = \Theta(n)$ for the path graph.
3. The redistribution diameter is bounded by $R(G) \leq \text{diam}(G) \cdot \Delta(G)$ where $\Delta(G)$ is the maximum degree.

**Test**: Formalize the redistribution diameter. Prove $R(K_n) \leq 1$ for $n \geq 2$. Compute $R(P_n)$ for small $n$ and conjecture the exact formula. Test the upper bound conjecture for cycles, complete bipartite graphs, and hypercubes.

**Impact**: The redistribution diameter would be a new graph invariant measuring "how hard it is to eliminate debt" — a quantitative version of the effective threshold. This connects chip-firing to network flow theory and could have applications in distributed computing (load balancing).

**Catalog References**: `Algebra/ChipFiringStructure.lean` (`laplacian_kernel_constant`, `neg_deg_no_effective`), `Catalog/Tropical/SymbolicDynamics/Core.lean` (`tropical_spectral_gap_implies_mixing_and_extraction`)

**Proof Strategy**:
1. Define redistribution diameter formally.
2. For $K_n$: use the explicit Laplacian formula to construct an effective equivalent in one firing step.
3. For path $P_n$: prove a lower bound by exhibiting a divisor requiring $\Omega(n)$ firings.
4. Prove the diameter bound using a "routing" argument: each chip needs at most $\text{diam}(G)$ firings to reach its destination.

**Domain Bridges**: Chip-firing <-> Network flow / load balancing, Graph invariants <-> Computational complexity

**Lineage**: Extends the effective threshold analysis and spectral gap results from this cycle.

**Ambition**: grand_challenge
