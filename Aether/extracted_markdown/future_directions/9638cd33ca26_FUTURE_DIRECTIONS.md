# Future Directions: Hyperbolic Number Theory

## Synthesis

This cycle established the foundations of hyperbolic number theory — arithmetic on the Poincaré disk via Möbius transformations. The core results include disk preservation, exponential growth bounds, the Fricke-Vogt trace identity, and a tropical-hyperbolic bridge. The most promising cross-domain connection is the **trace algebra ↔ spectral geometry** bridge: the Fricke-Vogt identity is the simplest case of the Selberg trace formula, which connects discrete algebraic data (traces of group elements) to continuous geometric data (eigenvalues of the Laplacian on hyperbolic surfaces). This bridge is the gateway to proving analytic results about hyperbolic zeta functions.

The exponential growth results reveal a fundamental structural difference between flat and curved arithmetic. This connects naturally to the Catalog's existing work on tropical geometry (where growth rates also play a central role) and to the algebraic circuit complexity theory in `Catalog/Algebra/AlgebraicCircuitComplexity.lean`. The tropical shadow map T(r) = −log(1 − r²) deserves deeper study: it may provide a dictionary translating hyperbolic number theory problems into tropical optimization problems.

The highest breakthrough potential lies in **Direction 1** (the Selberg zeta function), because it connects our combinatorial framework directly to analytic number theory. If the Selberg zeta function can be computed explicitly for PSL(2,ℤ), its zeros can be compared with the classical Riemann zeros, potentially revealing structural relationships between the Riemann Hypothesis and hyperbolic geometry.

---

### Direction 1: Selberg Zeta Function for PSL(2,ℤ) — Explicit Computation and Zero Distribution

**Conjecture**: The Selberg zeta function Z_Γ(s) for Γ = PSL(2,ℤ) can be expressed in terms of the Riemann zeta function ζ(s) via the identity Z_Γ(s) = ζ(s) · ζ(s−1) · (correction terms). Furthermore, the non-trivial zeros of Z_Γ are precisely the zeros of ζ and the eigenvalues of the Laplacian on the modular surface, all lying on the critical line Re(s) = 1/2.

**Test**: Compute the first 100 eigenvalues of the Laplacian on the modular surface SL(2,ℤ)\ℍ using the finite element method. Verify that each eigenvalue λ = s(1−s) with s = 1/2 + it gives a zero of the Selberg zeta function. Compare the distribution of these zeros with the Riemann zeros.

**Impact**: If confirmed, this would provide a geometric interpretation of the Riemann zeros as resonances of hyperbolic surfaces, and would establish a precise dictionary between the Riemann Hypothesis and spectral gap problems in hyperbolic geometry. This is a known but under-explored connection in formal mathematics.

**Catalog References**: `Catalog/Algebra/Foundations.lean` (critical_line_implies_unit_disk), `Catalog/Speculative/HyperbolicNumberTheory/Core.lean` (fricke_vogt_trace_identity, sl2_discriminant_sign)

**Proof Strategy**: 
1. Define the Selberg zeta function as Z_Γ(s) = Π_{[γ]} Π_{k=0}^∞ (1 − e^{−(s+k)ℓ(γ)}) where the outer product runs over primitive conjugacy classes.
2. Express ℓ(γ) in terms of tr(γ) using our trace classification theorems.
3. Use the Fricke-Vogt identity to relate products of traces to individual traces.
4. Connect to the Riemann zeta function via the Euler product.

**Domain Bridges**: NumberTheory <-> HyperbolicGeometry, SpectralTheory <-> Algebra

**Lineage**: Builds on fricke_vogt_trace_identity, sl2_discriminant_sign, and the SL2R framework from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Hyperbolic Factorization and Unique Decomposition

**Conjecture**: In a free hyperbolic lattice with k ≥ 2 generators, every hyperbolic integer z ≠ 0 has a unique representation as a reduced word in the generators (no cancellation of inverse pairs). However, for Fuchsian groups with relations (e.g., PSL(2,ℤ) with S² = (ST)³ = 1), uniqueness fails, and the failure is governed by the relator structure: two representations of the same point differ by a sequence of relator insertions.

**Test**: Enumerate all words of length ≤ 8 in the PSL(2,ℤ) generators S and T. Identify collisions (different words giving the same point). Verify that each collision is explained by the relations S² = 1 and (ST)³ = 1. Count the number of distinct hyperbolic integers as a function of word length and compare with the Euler characteristic formula.

**Impact**: A positive result would give an explicit "factorization theory" for hyperbolic integers, analogous to the fundamental theorem of arithmetic. A negative result would reveal new constraints on arithmetic in curved spaces.

**Catalog References**: `Catalog/Speculative/HyperbolicNumberTheory/Core.lean` (IsHyperbolicInteger, IsHyperbolicPrime, wordNorm_concat)

**Proof Strategy**: 
1. Define reduced words (no consecutive inverse pairs) and prove the free group case by induction on word length.
2. For PSL(2,ℤ), implement the Dehn algorithm for the word problem and prove termination.
3. Count distinct cosets using the Euler characteristic χ = 1 − k + r where k = generators, r = relations.

**Domain Bridges**: Algebra <-> Combinatorics, GroupTheory <-> NumberTheory

**Lineage**: Extends the HyperbolicLattice and evalHypWord definitions from this cycle.

**Ambition**: extension

---

### Direction 3: Tropical-Hyperbolic Dictionary for Optimization

**Conjecture**: The tropical shadow map T(r) = −log(1 − r²) induces a functor from the category of Möbius transformations on 𝔻 to the category of tropical linear maps on ℝ≥0. Specifically, for Möbius maps φ_a and φ_b, the tropical shadow satisfies T(ρ(φ_a∘φ_b(0), 0)) ≤ T(ρ(φ_a(0), 0)) + T(ρ(φ_b(0), 0)) (a tropical triangle inequality), making T a quasi-morphism from the hyperbolic group to the tropical semiring.

**Test**: Compute T(ρ(φ_a∘φ_b(0), 0)) and T(ρ(φ_a(0), 0)) + T(ρ(φ_b(0), 0)) for 10,000 random pairs (a, b) ∈ 𝔻². Measure the defect and determine whether it is bounded (quasi-morphism) or grows without bound.

**Impact**: If T is a quasi-morphism, it would provide a systematic way to translate optimization problems on hyperbolic networks (e.g., shortest paths, facility location) into tropical optimization problems, which have polynomial-time algorithms. This would connect hyperbolic geometry to tropical algebraic geometry and potentially to the existing tropical work in `Catalog/Tropical/`.

**Catalog References**: `Catalog/Speculative/HyperbolicNumberTheory/Core.lean` (tropicalShadow, tropicalShadow_nonneg, tropicalShadow_mono), `Catalog/Tropical/` (existing tropical geometry framework)

**Proof Strategy**:
1. Prove the tropical triangle inequality using the composition formula for pseudohyperbolic distances.
2. Bound the defect using the fundamental identity moebius_norm_sq_difference.
3. Show that the quasi-morphism constant depends only on the curvature (which is −1 in our normalization).

**Domain Bridges**: HyperbolicGeometry <-> TropicalGeometry, Optimization <-> Algebra

**Lineage**: Extends tropicalShadow_nonneg and tropicalShadow_mono from this cycle.

**Ambition**: extension

---

### Direction 4: Quantum Hyperbolic Integers and the Modular Functor

**Conjecture**: There exists a quantization of the hyperbolic integer lattice that produces a modular functor: a consistent family of finite-dimensional Hilbert spaces indexed by hyperbolic surfaces, with tensor product structure governed by the Möbius composition law. The dimension of the Hilbert space at level k equals the Verlinde formula dim V_k = (k+1)^(g−1) Σ (sin²(πj/(k+2)))^(1−g), where g is the genus of the surface.

**Test**: For the modular surface (g = 1), compute the Verlinde dimensions for k = 1, ..., 10 and verify against known values. For the (2,3,7) triangle group (g = 3), compute and compare with the trace formula predictions.

**Impact**: This would connect hyperbolic number theory to topological quantum field theory and conformal field theory, potentially explaining why the Riemann Hypothesis has physical interpretations (the Hilbert-Pólya conjecture that ζ-zeros are eigenvalues of a self-adjoint operator).

**Catalog References**: `Catalog/Physics/` (quantum structures), `Catalog/Algebra/Foundations.lean` (critical_line_implies_unit_disk), `Catalog/Speculative/HyperbolicNumberTheory/Core.lean` (SL2R, fricke_vogt_trace_identity)

**Proof Strategy**:
1. Define the quantized Möbius map as a unitary operator on L²(𝔻) with parameter ℏ.
2. Show that the Fricke-Vogt identity quantizes to the quantum group relation at q = e^{2πi/(k+2)}.
3. Construct the modular functor using the representation theory of SU_q(2).

**Domain Bridges**: NumberTheory <-> QuantumPhysics, Algebra <-> TopologicalFieldTheory

**Lineage**: Builds on SL2R and fricke_vogt_trace_identity from this cycle.

**Ambition**: grand_challenge

---

### Direction 5: Hyperbolic Machine Learning — Cayley Graph Neural Networks

**Conjecture**: Graph neural networks operating on hyperbolic lattice Cayley graphs achieve lower distortion for hierarchical classification tasks than Euclidean GNNs, with the improvement factor scaling as O(log(n)/log(k)) where n is the number of nodes and k is the branching factor.

**Test**: Embed the WordNet noun hierarchy (82,000 nodes, tree-depth 20) into the Poincaré disk using Möbius transformations. Train a hyperbolic GNN and compare classification accuracy with a Euclidean GNN of the same parameter count. Measure distortion as the ratio of embedded distances to graph distances.

**Impact**: This would provide a mathematically rigorous foundation for hyperbolic neural networks, connecting the proven exponential growth bounds to concrete ML performance gains. It bridges `Catalog/MachineLearning/` with `Catalog/Algebra/` via the shared structure of the Poincaré disk.

**Catalog References**: `Catalog/MachineLearning/` (existing ML framework), `Catalog/Speculative/HyperbolicNumberTheory/Core.lean` (moebius_maps_disk_to_disk, hyperbolic_cayley_growth_lower_bound)

**Proof Strategy**:
1. Prove that the Möbius map is a contraction in hyperbolic distance (follows from disk preservation).
2. Show that depth-k composition of contractions has exponential precision in the hyperbolic metric.
3. Use the growth bounds to prove that the embedding dimension needed for ε-distortion is O(log(n)) in hyperbolic space vs O(n^{1/d}) in ℝ^d.

**Domain Bridges**: MachineLearning <-> HyperbolicGeometry, Algebra <-> MachineLearning

**Lineage**: Extends moebius_maps_disk_to_disk and hyperbolic_cayley_growth_lower_bound from this cycle.

**Ambition**: extension
