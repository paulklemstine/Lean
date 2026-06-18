## Research Brief: Combinatorial Hodge Theory for Polyhedral Decision Surfaces

### Context
The previous attempt (NeuralHodgeConjecture.lean) defined combinatorial quantities (reluHodgeNumber, reluTotalBetti, regionBound) and proved standard binomial bounds, but failed to prove the core Hodge-type claim and produced only a trivial rfl adapter to the catalog. The title's ambition (solving the Hodge Conjecture) vastly exceeded the delivery.

### Problem Statement
For a ReLU neural network f : R^n → R, the decision surface V(f) = {x : f(x) = 0} is a piecewise-linear (polyhedral) hypersurface. We need to prove the fundamental structural theorem: the polyhedral cell decomposition of V(f) determines its homology completely, and every homology class is represented by a cellular cycle.

### Definitions Required
1. **PolyhedralComplex**: A finite cell complex where each cell is a convex polyhedron and the boundary of each cell is a union of lower-dimensional cells.
2. **ReLUDecisionSurface**: For a ReLU network f with parameters (depth d, widths w_0, ..., w_d), define V(f) as the zero set with its natural polyhedral decomposition induced by the ReLU activation pattern regions.
3. **CellularChainComplex**: The chain complex C_*(V(f)) where C_k is the free abelian group on k-dimensional cells of V(f), with boundary maps induced by the cell incidence relations.

### Main Theorems to Prove

**Theorem 1 (Polyhedral Homology = Singular Homology)**: For a ReLU decision surface V(f), the cellular homology H_k^{cell}(V(f)) is isomorphic to the singular homology H_k(V(f), Z).

Proof strategy: (a) Prove V(f) is a regular CW-complex (each cell is homeomorphic to a closed ball, and the boundary of each cell is a subcomplex). (b) Apply the standard theorem that cellular homology of a regular CW-complex equals singular homology. (c) For ReLU networks, regularity follows because the polyhedral cells are convex and intersect transversely along faces.

**Theorem 2 (PL Cycle Generation)**: Every rational homology class [α] ∈ H_{n-2}(V(f), Q) is represented by a Z-linear combination of (n-2)-dimensional polyhedral cells of V(f).

Proof strategy: This is an immediate corollary of Theorem 1, since cellular homology classes are by definition represented by cellular cycles.

**Theorem 3 (Polyhedral Betti Bound)**: For a ReLU network of depth d with widths w_0 = n, w_1, ..., w_d = 1:
  β_k(V(f)) ≤ #{k-dimensional cells in V(f)} ≤ ZonotopeBound(d, n, w)
where ZonotopeBound is a computable function derived from the hyperplane arrangement count.

Proof strategy: (a) The k-th Betti number equals dim H_k^{cell}(V(f)). (b) H_k^{cell}(V(f)) is a quotient of C_k^{cell}(V(f)), so its dimension is bounded by rank(C_k). (c) rank(C_k) equals the number of k-cells. (d) Bound the number of k-cells using the Zaslavsky-type theorem for hyperplane arrangements induced by ReLU activations.

### Connection to Catalog
The HodgeDiamond structure in HodgeEPolynomial.lean should be instantiated for polyhedral decision surfaces by defining h^{p,q}(V(f)) = dim H^{p,q}_{cell}(V(f)) where the cellular Hodge numbers are defined via the polyhedral decomposition. This is NOT an rfl adapter: it requires proving that the cellular Hodge decomposition satisfies the Hodge diamond symmetries h^{p,q} = h^{q,p} and h^{p,q} = h^{n-p,n-q} (Serre duality) for compact polyhedral manifolds.

### Constraints
- Do NOT attempt to prove the classical Hodge Conjecture. We are proving the tractable PL analogue.
- Every theorem statement MUST have a complete proof. No sorry fills, no truncated theorem blocks.
- The catalog bridge must contain substantive mathematical content, not a trivial rfl definition.
- Build from simplicial/polyhedral infrastructure in Mathlib (SimplicialComplex, etc.) rather than from scratch.

### Expected Deliverables
1. Formalization of PolyhedralComplex and its cellular chain complex
2. Proof that ReLU decision surfaces are regular polyhedral complexes
3. Theorem 1: Cellular homology = Singular homology for these complexes
4. Theorem 2: PL Cycle Generation (every rational class is a cellular cycle)
5. Theorem 3: Betti number bounds via cell counting
6. A substantive catalog bridge connecting cellular Hodge numbers to HodgeEPolynomial.HodgeDiamond with verified symmetry properties