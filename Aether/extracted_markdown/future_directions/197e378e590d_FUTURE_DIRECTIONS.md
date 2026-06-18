# Future Directions: Tropical Composition Diagrams

## Synthesis

The theory of tropical composition diagrams establishes that deep ReLU networks possess a combinatorial invariant — the diagram encoding sign patterns and valuation profiles — that determines activation structure. Our verified results on tropical matrix associativity, distributivity, and the sign-pattern activation theorem create a foundation for five interconnected research directions. These range from extending the current invariance results to full geometric isomorphism (Directions 1–2), to building bridges with matroid theory and information theory (Directions 3–4), to developing practical compression algorithms (Direction 5). Together, they chart a path toward a complete "tropical theory of deep learning" where network complexity is understood through arithmetic invariants.

---

## Direction 1: Full Active-Set Complex Isomorphism

**Conjecture**: Two k-layer ReLU networks with identical tropical composition diagrams have isomorphic active-set complexes — not just equal activation counts, but combinatorially equivalent arrangements of linear regions.

**Test**: For pairs of 3-layer networks with 4 neurons per layer and matching tropical composition diagrams:
1. Enumerate all input regions by solving the system of linear inequalities defining each activation pattern
2. Build the face lattice (Hasse diagram) of the resulting polyhedral complex
3. Check poset isomorphism between the face lattices of the two networks
4. Run for 100 random weight perturbations at each of 10 valuation profiles
5. A single pair with non-isomorphic Hasse diagrams refutes the conjecture

**Impact**: This would elevate the tropical composition diagram from a scalar invariant (activation counts) to a full combinatorial invariant, completing the program initiated in this work.

**Catalog References**: `Pythagorean/TropicalComposition.lean` — Theorem `activation_determined_by_sign`, Definition `TropicalCompositionDiagram`

**Proof Strategy**: Extend the sign-pattern argument layer by layer. At each layer, use the tropical composition structure (associativity + distributivity) to show that the activation pattern at layer $i+1$ is determined by the activation pattern at layer $i$ and the diagram data at layer $i+1$. Induction on depth. The key new lemma needed: a vector's sign pattern after tropical composition is determined by the input sign pattern and the diagram.

**Domain Bridges**: Tropical Geometry → Polyhedral Combinatorics → Deep Learning Theory

**Lineage**: Extends `activation_determined_by_sign` from counts to full complexes

**Ambition**: ★★★★☆ (Grand challenge — requires substantial new infrastructure)

---

## Direction 2: Multi-Prime Adelic Composition Diagrams

**Conjecture**: For each prime $p$, the $p$-adic tropical composition diagram captures different aspects of the network's combinatorial structure. The full information is captured by the *adelic* diagram — the tuple of diagrams across all relevant primes.

**Test**: 
1. Construct networks where the 2-adic and 3-adic diagrams agree but the 5-adic diagrams differ
2. Check whether activation patterns can differ despite agreement at 2 and 3
3. Find the minimal set of primes needed for full invariance for networks with entries bounded by $B$

**Impact**: Would connect neural network theory to adelic number theory, potentially importing powerful tools from algebraic number theory.

**Catalog References**: `Pythagorean/TropicalComposition.lean` — `TropicalLayer.valuation`, `sign_universality_conjecture_needs_valuation`

**Proof Strategy**: For integer weights bounded by $B$, only primes $p \leq B$ contribute nontrivially. The product formula $\prod_p |x|_p = |x|^{-1}$ constrains the valuations. Use the Chinese Remainder Theorem structure to decompose the analysis prime by prime.

**Domain Bridges**: Tropical Geometry → Algebraic Number Theory → Deep Learning

**Lineage**: Builds on the counterexample showing signs alone are insufficient

**Ambition**: ★★★★★ (Paradigm-shifting — connects AI to number theory)

---

## Direction 3: Tropical Matroid Structure of Active-Set Complexes

**Conjecture**: The active-set complex of a ReLU network satisfies the matroid exchange axiom: if activation sets $A$ and $B$ are both realizable (there exist inputs achieving exactly these active neurons), and $|A| > |B|$, then there exists a neuron $a \in A \setminus B$ such that $B \cup \{a\}$ is also realizable.

**Test**:
1. For 2-layer networks with $n = 5$ neurons per layer, enumerate all realizable activation sets
2. Check the exchange axiom for all pairs $(A, B)$ with $|A| = |B| + 1$
3. If exchange holds, compute the matroid's Tutte polynomial and check it agrees across diagram-equivalent networks
4. Repeat for $n = 3, 4, 5, 6$ to detect dimension-dependent failures

**Impact**: Would establish a fundamental connection between deep learning and matroid theory, importing the rich toolkit of matroid invariants (Tutte polynomial, connectivity, duality) for analyzing networks.

**Catalog References**: `Pythagorean/TropicalComposition.lean` — `activationCount`, `isActive`

**Proof Strategy**: The key insight is that the set of realizable activation patterns forms a convex set in a suitable sense (intersection of halfspaces). Show that convexity implies the exchange axiom. Use the tropical composition structure to establish that convexity is preserved under layer composition.

**Domain Bridges**: Tropical Geometry → Matroid Theory → Combinatorial Optimization → Deep Learning

**Lineage**: Extends `activation_determined_by_sign` to structural (matroid) invariance

**Ambition**: ★★★★☆ (Grand challenge)

---

## Direction 4: Tropical Information-Theoretic Capacity

**Conjecture**: The *tropical capacity* of a network architecture — defined as the logarithm of the number of distinct tropical composition diagrams achievable by varying weights — provides an upper bound on the network's Rademacher complexity and hence its generalization gap.

**Test**:
1. For architectures with $k$ layers and $n$ neurons per layer, count the number of distinct tropical composition diagrams with valuations bounded by $V$
2. Compare to empirical Rademacher complexity estimates
3. Check whether $\log(\text{diagram count})$ scales as $O(k n^2 \log V)$ (the number of valuation entries)
4. Verify the bound for specific trained networks on MNIST/CIFAR

**Impact**: Would provide a new, architecturally meaningful complexity measure that bridges tropical geometry and statistical learning theory.

**Catalog References**: `Pythagorean/TropicalComposition.lean` — `TropicalCompositionDiagram`, `tropMul_assoc`

**Proof Strategy**: Count diagrams combinatorially (product of sign choices × valuation choices per entry). Use the associativity of tropical multiplication to show that distinct diagrams produce distinct activation structures. The covering number argument then gives Rademacher bounds.

**Domain Bridges**: Tropical Geometry → Information Theory → Statistical Learning Theory

**Lineage**: New direction building on the diagram definition

**Ambition**: ★★★★★ (Paradigm-shifting — connects tropical algebra to generalization theory)

---

## Direction 5: Tropical-Preserving Network Compression

**Conjecture**: For any ReLU network with integer weights bounded by $B$, there exists a network with weights in $\{0, \pm 1, \pm 2, \pm 4, \ldots, \pm 2^{\lfloor \log_2 B \rfloor}\}$ (powers of 2) that has the same tropical composition diagram and hence the same activation structure.

**Test**:
1. Take trained networks on standard benchmarks
2. Round each weight to the nearest power of 2 with the same sign
3. Verify the tropical composition diagram is preserved
4. Measure accuracy degradation
5. Compare to standard quantization methods (uniform rounding, k-means)

**Impact**: Would provide a principled, theory-backed compression method that guarantees preservation of the network's combinatorial structure.

**Catalog References**: `Pythagorean/TropicalComposition.lean` — `TropicalLayer`, `tropMul_tropAdd_distrib`, `sign_universality_conjecture_needs_valuation`

**Proof Strategy**: The 2-adic valuation of any integer $w$ equals the 2-adic valuation of the nearest power of 2 with the same sign. The sign is preserved by construction. Therefore the tropical composition diagram is preserved. The challenge is showing that the accuracy impact is bounded.

**Domain Bridges**: Tropical Geometry → Model Compression → Practical Deep Learning

**Lineage**: Direct application of the invariance theory

**Ambition**: ★★★☆☆ (Solid extension with immediate practical impact)
