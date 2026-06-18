# Future Directions: Tropical Tensor Distributivity

## Synthesis

The theorems in this development establish that distributive rewriting is a *semiring-structural* operation: its termination and soundness depend only on expression tree shape, not on coefficient values. This opens a research program at the intersection of rewriting theory, tropical mathematics, and algorithmic optimization. The five directions below exploit different facets of this insight — from symbolic complexity theory (Direction 1) to quantum deformation (Direction 5) — but they share a common thread: **canonical algebraic normal forms encode computational structure across domains**.

The key unifying principle is that the distributive law `a × (b + c) = a × b + a × c` is a *structural rewriting rule* that works identically in any semiring. By changing the semiring, we change the *meaning* of the normal form without changing its *computation*. This is a fundamentally new interface between algebra and optimization.

---

## Direction 1: Tropical Complexity of Normal Form Computation

**Conjecture**: Computing the tropical normal form of an arbitrary min-plus expression is #P-hard, but for graph-generated expressions of bounded treewidth, it is polynomial.

**Test**: Implement the normalizer for random expressions and measure runtime scaling. Compare with known #P-hard reductions from counting simple paths.

**Impact**: This would establish that tropical normal forms are computationally meaningful objects — easy to compute for structured inputs (graphs, circuits) but hard in general. This mirrors the situation with Gröbner bases in commutative algebra.

**Catalog References**: `Pythagorean/TropicalTensorDistributivity.lean` (normalization function, topSumCount invariant)

**Proof Strategy**: Reduce from #PATH (counting simple s-t paths in a DAG) to computing the monomial count of a tropical normal form. The reduction encodes each edge as an atom and each path choice as a tmin. For bounded treewidth, use the tree decomposition to bound the intermediate expression size.

**Domain Bridges**: Computational complexity theory, graph theory, parameterized algorithms

**Lineage**: Extends the semiring-independence theorem (Theorem 1) to complexity analysis

**Ambition**: ★★★★☆ (Grand Challenge — connects rewriting theory to complexity theory)

---

## Direction 2: All-Pairs Shortest Paths via Tropical Matrix Normal Forms

**Conjecture**: For an n-vertex weighted digraph G, the tropical normal form of the matrix expression `A ⊕ A² ⊕ ··· ⊕ Aⁿ⁻¹` (where A is the adjacency matrix in the tropical semiring) computes the all-pairs shortest path matrix, and the monomial count in position (i,j) equals the number of shortest paths from i to j.

**Test**: Implement tropical matrix multiplication and compare with Floyd-Warshall output for random graphs on 5-20 vertices. Count monomials and compare with shortest-path counts.

**Impact**: Would provide a symbolic/algebraic algorithm for all-pairs shortest paths, with the normal form serving as a complete certificate of optimality.

**Catalog References**: `Pythagorean/TropicalTensorDistributivity.lean` (graph encoding, bridge theorems), `Catalog/Tropical/BellmanFord.lean` (feasibility characterization)

**Proof Strategy**: Define tropical matrix expressions as MPExpr with matrix indices. Extend the normalization soundness theorem (Theorem 3) to matrix products. Use induction on the power sum to connect with Bellman-Ford iterations.

**Domain Bridges**: Combinatorial optimization, linear algebra over semirings, algebraic graph theory

**Lineage**: Direct extension of the bridge theorems (normalized_singleHop_eq_edge_weight, normalized_twoHop_eq_bellman)

**Ambition**: ★★★☆☆ (Solid Extension — natural next step)

---

## Direction 3: Tropical Confluence Modulo AC via Critical Pair Analysis

**Conjecture**: The distributive rewrite system for min-plus expressions is confluent modulo associativity and commutativity of both tmin and tplus. All critical pairs of the 4 distribution rules (left/right for tplus over tmin) join modulo AC.

**Test**: Enumerate all critical overlaps of the rewrite rules and verify joinability computationally for expressions up to depth 5. Verify that the normal form is unique modulo AC for random expressions.

**Impact**: Would complete the confluence theory for tropical distributive rewriting, establishing that the canonical normal form is truly unique (not just evaluation-preserving).

**Catalog References**: `Pythagorean/TropicalTensorDistributivity.lean` (DistStep relation, topSumCount invariance), `Catalog/Tropical/ACNormalForm.lean`, `Catalog/Tropical/TropicalACNormalization.lean`

**Proof Strategy**: Strategy B from the assignment: use Newman's lemma (strong normalization + local confluence → confluence). Strong normalization follows from the distPotential measure (with a refined version that decreases in all contexts). Local confluence requires checking all critical pairs — there are finitely many overlap configurations.

**Domain Bridges**: Term rewriting theory, universal algebra, automated reasoning

**Lineage**: Extends the topSumCount invariance and distStep soundness theorems

**Ambition**: ★★★☆☆ (Solid Extension — well-understood techniques but technically involved)

---

## Direction 4: Tropical Normal Forms as Bellman Certificates for Control Systems

**Conjecture**: For a finite-horizon deterministic optimal control problem with linear dynamics and additive cost, the tropical normal form of the cost-to-go expression equals the value function computed by the Bellman equation, and each monomial corresponds to an optimal control sequence.

**Test**: Formalize a simple 1D optimal control problem (e.g., inventory management with holding and ordering costs). Encode the cost-to-go as a min-plus expression. Normalize and compare with the dynamic programming solution.

**Impact**: Would establish tropical normal forms as a symbolic framework for optimal control, providing certified value functions with explicit optimal policy witnesses.

**Catalog References**: `Pythagorean/TropicalTensorDistributivity.lean` (normalization soundness, path decomposition), `Catalog/Tropical/BellmanFord.lean` (Bellman-Ford feasibility)

**Proof Strategy**: Model the control problem as a layered graph where vertices represent states and edges represent control actions. The cost-to-go expression is a min-plus expression over this graph. Apply Theorem 3 to show that normalization preserves the optimal cost. Interpret monomials as control sequences via the atomList decomposition.

**Domain Bridges**: Optimal control theory, operations research, Hamilton-Jacobi equations

**Lineage**: Extends the graph encoding and bridge theorems to dynamic systems

**Ambition**: ★★★★★ (Grand Challenge — bridges to a new domain)

---

## Direction 5: Quantum Tropical Deformation and Partition Functions

**Conjecture**: There exists a one-parameter family of "quantum tropical" semirings (ℝ, ⊕_β, +) where `a ⊕_β b = -β⁻¹ log(exp(-βa) + exp(-βb))`, such that:
- At β = 0: ordinary addition (a ⊕₀ b = a + b)
- At β → ∞: tropical addition (a ⊕_∞ b = min(a, b))
- The distributive normal form at finite β computes the log-partition function
- The β → ∞ limit of the normal form recovers the tropical shortest-path certificate

**Test**: Implement the quantum tropical operations numerically. Compute normal forms at various β values. Verify that the β → ∞ limit matches the tropical normal form and the β = 0 limit matches ordinary algebra.

**Impact**: Would connect tropical rewriting to statistical mechanics and quantum computing. The partition function Z = Σ exp(-βEᵢ) is the quantum version of min(E₁, ..., Eₖ), and the log-sum-exp is the quantum tropical addition.

**Catalog References**: `Pythagorean/TropicalTensorDistributivity.lean` (semiring-parametric normalization), `Catalog/Tropical/TropicalSemiring.lean` (logSumExp, softmax), `Catalog/Tropical/SoftMaxConvergence.lean`

**Proof Strategy**: Define the quantum tropical semiring as a parametric family. Show that the distributive law holds for all β. Apply the semiring-parametric normalization theorem (Theorem 2). Prove the β → ∞ convergence using dominated convergence and the asymptotic `log(e^(-βa) + e^(-βb)) → -β·min(a,b)`.

**Domain Bridges**: Statistical mechanics, quantum computing, information theory

**Lineage**: Leverages the semiring-independence insight (Theorem 1) to interpolate between classical and tropical settings

**Ambition**: ★★★★★ (Grand Challenge — paradigm-shifting connection)
