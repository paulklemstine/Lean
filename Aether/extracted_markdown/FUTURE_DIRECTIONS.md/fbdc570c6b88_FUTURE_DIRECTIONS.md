# Future Directions: Causal Integration Algebra

## What We Built

This cycle established the **Causal Integration Algebra** — a rigorous Lean 4 formalization of Integrated Information Theory (IIT) that identifies Φ with the minimum cut of a weighted directed graph. We proved 11 theorems sorry-free in `Computation/CausalIntegrationAlgebra.lean`:

- **Nonnegativity** (`phi_nonneg`): Φ ≥ 0 always
- **Scaling** (`phi_scale`): Φ(cC) = cΦ(C) for c ≥ 0
- **Monotonicity** (`phi_mono_of_weight_le`): increasing edge weights cannot decrease Φ
- **Disconnection** (`phi_zero_of_disconnected`): systems with a zero-cut bipartition have Φ = 0
- **Upper bound** (`phi_le_totalWeight`): Φ never exceeds total edge weight
- **Symmetrization invariance** (`crossInfo_symmetrize`, `phi_symmetrize`): directed and symmetrized systems have identical Φ
- **Complement symmetry** (`crossInfo_compl`): cross-info is invariant under taking the complement partition
- **Cross-info nonnegativity** (`crossInfo_nonneg`): all cut values are nonneg
- **Cross-info scaling** (`crossInfo_scale`): cut values scale linearly
- **Cross-info monotonicity** (`crossInfo_mono`): cut values are monotone in edge weights

---

### Direction 1: Spectral Lower Bound via Fiedler Value

For symmetric causal systems, the algebraic connectivity λ₂(L) of the graph Laplacian should provide a polynomial-time computable lower bound on Φ. The key insight is that the Rayleigh quotient characterization of λ₂ directly relates to the minimum bisection problem — any indicator vector for a bipartition gives a Rayleigh quotient that upper-bounds λ₂, and the minimum over all such vectors is precisely Φ (up to normalization). This would import Cheeger-type inequalities into integration theory.

**Conjecture**: λ₂(L) ≤ Φ(C) ≤ n · λ₂(L) / 4 for symmetric systems on n vertices.

**Why now?** Our `phi_symmetrize` theorem shows that every directed system can be reduced to a symmetric one without changing Φ. This means spectral methods (which require symmetric matrices) apply to the full generality of directed causal systems. The Laplacian formalization in Lean would build on our `CausalSystem` structure by extracting the degree matrix and adjacency matrix.

---

### Direction 2: Submodularity of Cross-Information

The cross-information function may exhibit submodularity on the power set lattice, which would give polynomial-time algorithms for computing Φ via submodular minimization.

The key insight is that for disjoint subsets A, B ⊆ V, the edges crossing in A∪B are exactly those crossing in A or B minus the edges between A and B that were counted as "internal" to the union. This telescoping structure is the hallmark of submodularity. Formally, crossInfo(A∪B) + crossInfo(A∩B) ≤ crossInfo(A) + crossInfo(B) should hold when the weight function is symmetric.

**Conjecture**: For symmetric causal systems, S ↦ crossInfo(C, S) is submodular on the lattice of subsets.

**Why now?** Our `crossInfo_compl` and `crossInfo_mono` establish that crossInfo respects the basic lattice structure. Lean's `Finset` API provides all the union/intersection operations needed. If true, this would give the first polynomial-time algorithm for computing Φ.

---

### Direction 3: K-Partition Refinement and Integration Spectrum

Generalizing from bipartitions to k-partitions creates an "integration spectrum" Φ_k that captures multi-way decomposition.

The key insight is that Φ₂ = Φ is just the first level. Defining Φ_k as the minimum total inter-part edge weight over all k-partitions, we get a monotone sequence Φ₂ ≤ Φ₃ ≤ ... ≤ Φ_n, with Φ_n = totalWeight(C). The rate of growth encodes the system's "complexity" — how much information is lost at each level of decomposition.

**Conjecture**: For strongly connected systems, Φ_k is strictly increasing, and Φ_n = totalWeight(C).

**Why now?** Our `phi_le_totalWeight` provides the natural upper bound for the spectrum. The k-partition generalization reuses our `crossInfo` infrastructure.

---

### Direction 4: Compositional Integration via Direct Sums

When two causal systems are composed with inter-system edges, a precise formula for Φ of the composite would solve the "combination problem" of IIT.

The key insight is that for the block-diagonal direct sum C₁ ⊕ C₂, our `phi_zero_of_disconnected` already shows Φ = 0. When inter-system edges are added, Φ grows monotonically (by `phi_mono_of_weight_le`). The minimum cut of the composite must either separate within C₁, within C₂, or between them, giving a three-way minimum formula.

**Conjecture**: Φ(C₁ ⊕ C₂ + E) = min(Φ(C₁) + cross₁(E), Φ(C₂) + cross₂(E), cross(E)).

**Why now?** Our monotonicity and disconnection theorems provide the boundary conditions and one direction of the inequality.

---

### Direction 5: Dual Characterization via Maximum Flow

There should be a max-flow min-cut duality for Φ: the minimum cut (Φ) equals the maximum concurrent flow value.

The key insight is that our definition of Φ as a minimum cut directly invites application of the max-flow min-cut theorem. For symmetric systems (via `phi_symmetrize`, this is without loss of generality), the undirected max-flow min-cut theorem applies. This would give Φ a constructive interpretation as the bottleneck information capacity.

**Conjecture**: For symmetric causal systems, Φ(C) equals the maximum concurrent flow where each vertex pair (i,j) demands flow w(i,j).

**Why now?** Our framework identifies Φ with the minimum cut, and `phi_symmetrize` reduces to the symmetric case where classical flow theory applies directly.
