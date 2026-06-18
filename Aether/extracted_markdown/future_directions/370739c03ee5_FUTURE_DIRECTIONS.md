# Future Research Directions: Fiber Graphs of Additive Scoring Functions

## Synthesis

This research cycle established a rigorous formal theory of fiber graphs arising from additive scoring functions on Hamming spaces. We proved 12 theorems organized around three pillars: (1) the Score Delta Algebra, establishing that per-position score changes obey antisymmetry, the triangle identity, and a global conservation law; (2) the Bridge Duality Theorem, showing that for configurations differing at exactly two positions, bridge existence through one position is logically equivalent to bridge existence through the other; and (3) Position Separation Rigidity, proving that injective weight systems force fibers to be rigid under single-position modifications. We introduced the Score Kernel as a novel algebraic invariant and proved it is closed under negation.

The most significant cross-domain connection discovered is between fiber graph connectivity and spectral graph theory. The bridge duality theorem provides a concrete structural tool: it rules out one-sided bottlenecks at the 2-position level, which is precisely the kind of local symmetry that supports spectral gap lower bounds. This connects to the spectral theory developed in `Algebra/Bridges.lean` and `Algebra/Apollonian/SpectralTransfer.lean` in the Catalog. The score kernel, as a subgroup-like structure within the direct product of delta ranges, connects to the algebraic theory in `Algebra/SpectralArithmetic/Core.lean`.

The direction with the highest breakthrough potential is Direction 1 (Spectral Gap of Fiber Graphs). A proof of the Fiber Expansion Conjecture would immediately yield polynomial-time sampling algorithms for fibers of generic additive maps, with applications in coding theory, statistical physics, and computational biology. The formal infrastructure established in this cycle — particularly the total delta conservation law and bridge duality — provides the foundation for a spectral approach via the trace method or Cheeger inequality.

---

### Direction 1: Spectral Gap of Fiber Graphs via Bridge Duality

**Conjecture**: For an additive scoring function S: α^n → G with n ≥ 3, alphabet size q ≥ 2, and weight system w where each wᵢ is not injective (i.e., has a collision), the fiber graph of any non-empty fiber F_g has spectral gap λ₁ ≥ c/(n·q) for a constant c > 0 depending only on the number of collisions per weight function.

**Test**: Compute the spectral gap of the fiber graph Laplacian for all weight systems with n = 4, |α| = 3 over ℤ. Verify that λ₁ ≥ 1/(12) = 1/(n·q) for every non-empty fiber with |F_g| ≥ 2. A single counterexample refutes the conjecture.

**Impact**: If true, this yields O(n·q · log|F_g|) mixing time for the natural random walk on any fiber, giving efficient sampling algorithms. If false, the failure mode reveals which weight system structures create bottlenecks, guiding the search for tighter bounds.

**Catalog References**: `Algebra/Bridges.lean` (spectral_energy_trace_bound), `Algebra/Apollonian/SpectralTransfer.lean` (spectral_gap_contraction_lt_one), `Algebra/SpectralArithmetic/Core.lean` (additive_energy_diagonal_lower_bound)

**Proof Strategy**: (1) Use bridge duality to establish that the fiber graph has no 2-position bottlenecks. (2) Apply the trace method: bound Tr(A^{2k}) where A is the adjacency matrix, using the score kernel to count closed walks. (3) The score kernel's negation closure (Theorem 6.1) constrains the walk structure. (4) Combine with a Cheeger-type inequality to convert edge expansion to spectral gap.

**Domain Bridges**: Fiber graph spectral theory ↔ Additive combinatorics (via score kernel structure) ↔ Markov chain mixing (via spectral gap)

**Lineage**: Builds on this cycle's bridge duality theorem, total delta conservation, and score kernel negation closure. Extends the spectral transfer machinery from `Algebra/Apollonian/SpectralTransfer.lean`.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Fiber Graphs and Min-Plus Scoring

**Conjecture**: When the additive scoring function is replaced by a tropical (min-plus) scoring function S_trop(x) = min_i w_i(x_i), the tropical fiber {x | S_trop(x) = g} has a natural graph structure where two configurations are adjacent if they differ at one position and the "achieving index" (argmin) can transition between them. The tropical bridge duality theorem holds in the modified form: for configurations differing at two positions, bridge existence through one depends on whether the minimum is achieved at the same positions in both configurations.

**Test**: Implement the tropical fiber graph for n = 4, q = 3 with random integer weights. Compute whether the tropical analogue of bridge duality holds for all qualifying pairs. Count violations — if any exist, characterize which weight system configurations produce them.

**Impact**: A working tropical fiber graph theory would connect to the tropical mixing theory already in the Catalog (`Tropical/MixingTheory.lean`), providing a unified framework for both additive (sum) and tropical (min) scoring. This bridges classical and tropical combinatorics via fiber graph structure.

**Catalog References**: `Tropical/MixingTheory.lean` (tropical_cycle_gap_mixing_lower_bound), `Tropical/SymbolicDynamics/Core.lean` (tropical_spectral_gap_implies_mixing_and_extraction)

**Proof Strategy**: (1) Define the tropical score delta as min(w_i(b), M) - min(w_i(a), M) where M is a regularization parameter. (2) The tropical delta does NOT satisfy the triangle identity in general — identify the precise conditions under which it does. (3) Formalize the "achieving index" concept and prove that tropical bridge duality holds when the achieving index is unique. (4) Connect to the tropical mixing bounds via the spectral gap.

**Domain Bridges**: Tropical algebra ↔ Fiber graph theory ↔ Symbolic dynamics (via tropical mixing)

**Lineage**: Builds on this cycle's additive fiber graph theory, extending from abelian groups to tropical semirings. Connects to existing Catalog work on tropical mixing.

**Ambition**: grand_challenge

---

### Direction 3: Score Kernel Rank and Fiber Graph Diameter

**Conjecture**: The diameter of the fiber graph G_g is at most 2n / rank(K_w), where rank(K_w) is the dimension of the score kernel K_w viewed as a subset of G^n, and n is the number of positions. In particular, fiber graphs with full-rank kernels (rank = n-1, the maximum possible) have bounded diameter O(1).

**Test**: For weight systems with n = 5, |α| = 3 over ℤ, compute the fiber graph diameter and the "rank" of the score kernel (number of linearly independent achievable delta vectors). Plot diameter vs. rank for all non-empty fibers. If the conjecture holds, all points should lie below the line diameter = 2n/rank.

**Impact**: This would establish a quantitative relationship between the algebraic structure (kernel rank) and the geometric structure (graph diameter) of fibers. High kernel rank means many independent exchange patterns, which should provide short paths between any two configurations.

**Catalog References**: `Algebra/FiberGraph/Core.lean` (score_kernel_neg_closed, total_delta_zero)

**Proof Strategy**: (1) Formalize the rank of the score kernel as the dimension of the span of achievable delta vectors in G^n. (2) Show that if rank = r, then any configuration x can reach any configuration y in the same fiber using at most ⌈n/r⌉ intermediate steps, each involving r independent delta applications. (3) The conservation law (total_delta_zero) ensures the path stays in the fiber. (4) The key lemma: if the kernel has rank r, then any zero-sum vector in the delta product can be decomposed into at most ⌈n/r⌉ kernel elements with disjoint support.

**Domain Bridges**: Linear algebra over groups ↔ Graph diameter bounds ↔ Fiber graph connectivity

**Lineage**: Builds on this cycle's score kernel definition and negation closure. Extends the total delta conservation law to multi-step paths.

**Ambition**: extension

---

### Direction 4: Fiber Graph Isomorphism under Weight System Equivalence

**Conjecture**: Two weight systems w and w' produce isomorphic fiber graphs (for all fibers simultaneously) if and only if there exist permutations σ of positions, τ_i of alphabet values at each position, and a group automorphism φ of G such that w'_{σ(i)} ∘ τ_i = φ ∘ w_i + c_i for constants c_i ∈ G with Σ c_i = 0.

**Test**: Enumerate all weight systems with n = 3, |α| = 2 over ℤ/6ℤ (a finite group for tractability). For each pair, check whether their fiber graphs are isomorphic. Compare against the algebraic equivalence condition. A pair that satisfies one condition but not the other refutes the conjecture.

**Impact**: This would provide a complete algebraic classification of fiber graph isomorphism classes, reducing a graph-theoretic question to a purely algebraic one. It would also clarify which features of a weight system are "essential" (affecting fiber graph structure) versus "cosmetic" (preserving structure up to isomorphism).

**Catalog References**: `Algebra/FiberGraph/Core.lean` (score_uniform_perm, bridge_duality)

**Proof Strategy**: (1) The "if" direction: show that each transformation (position permutation, value permutation, group automorphism, constant shift) preserves the fiber graph up to isomorphism. Score_uniform_perm handles the uniform case; generalize. (2) The "only if" direction is harder: use bridge duality to constrain the possible isomorphisms. The key observation is that bridge duality is an intrinsic graph-theoretic property that must be preserved, and it encodes information about the weight function values.

**Domain Bridges**: Group theory (automorphisms) ↔ Graph isomorphism ↔ Weight system classification

**Lineage**: Builds on this cycle's permutation invariance theorem and bridge duality.

**Ambition**: extension

---

### Direction 5: Fiber Graphs of Interacting Scoring Functions

**Conjecture**: For a scoring function with pairwise interactions S(x) = Σ_i w_i(x_i) + ε · Σ_{i<j} w_{ij}(x_i, x_j), the fiber graph at coupling ε is connected whenever the additive fiber graph (ε = 0) is connected and ε is sufficiently small (depending on the interaction strength max|w_{ij}| and the additive spectral gap).

**Test**: For n = 4, |α| = 2, take the uniform weight system (counting 1s) and add random pairwise interactions with coupling ε. Compute the fiber graph connectivity for the fiber at score 2 (the middle fiber of the Johnson graph J(4,2)) as ε increases from 0. Identify the critical ε_c where connectivity is lost.

**Impact**: This extends the additive theory to the physically realistic case of interacting systems. Most real scoring functions have interactions (e.g., epistasis in genetics, frustrated interactions in spin glasses). Understanding how fiber graph connectivity degrades with interaction strength would bridge the gap between the tractable additive case and the intractable general case.

**Catalog References**: `Algebra/FiberGraph/Core.lean` (total_delta_zero — breaks for non-additive scoring), `Physics/` (potential connections to spin glass theory)

**Proof Strategy**: (1) Write S_ε(x) = S_0(x) + ε · I(x) where S_0 is additive and I is the interaction term. (2) The fiber of S_ε at g is approximately the fiber of S_0 at g when ε is small (perturbation argument). (3) Use the spectral gap of the additive fiber graph (Direction 1) to show that small perturbations cannot disconnect it. (4) The critical ε_c should scale as λ₁(G_0) / max|I|, where λ₁ is the additive spectral gap.

**Domain Bridges**: Perturbation theory ↔ Fiber graph connectivity ↔ Statistical physics (spin glasses) ↔ Evolutionary biology (epistasis)

**Lineage**: Builds on this cycle's additive theory as the ε = 0 base case. Connects to the spectral gap conjecture from Direction 1.

**Ambition**: grand_challenge
