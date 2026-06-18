# Future Directions: Hyperbolic Number Theory

## Synthesis

This research cycle established the foundations of arithmetic on the Poincaré disk: Möbius transformations preserve the disk (formally verified), hyperbolic distance satisfies metric properties, lattice counting functions are monotone, and a counting-norm Galois connection bridges classical and hyperbolic number theory. The most promising cross-domain connection is the structural parallel between the classical prime counting function π(x) and the hyperbolic lattice counting function N(r), mediated by the counting-norm duality theorem (`counting_norm_galois` in `Speculative/HyperbolicNumberTheory/PoincareDisk.lean`).

The Catalog's under-explored Algebra domain (13064 declarations) contains substantial infrastructure for group actions, ring theory, and algebraic structures that could support deeper formalization of PSL(2,ℤ) actions. The existing bridge between algebra and number theory (e.g., `Algebra/Foundations.lean` containing `critical_line_implies_unit_disk`) provides a natural connection point for relating the hyperbolic zeta function to the classical Riemann zeta function. The `EML` domain's modular forms infrastructure (`EML/ModularForms.lean`) is particularly relevant for connecting hyperbolic lattice enumeration to automorphic forms.

The highest breakthrough potential lies in Direction 1 (Selberg Trace Formula Bridge), because the Selberg trace formula provides the exact machinery to prove the functional equation for the hyperbolic zeta function — and potentially to establish the hyperbolic Riemann hypothesis via spectral methods. This would be significant both mathematically (a provable RH analogue) and for the Catalog (connecting Speculative, Algebra, and EML domains).

---

### Direction 1: Selberg Trace Formula and the Hyperbolic Zeta Function

**Conjecture**: The hyperbolic zeta function ζ_H(s) = Σ_{z ∈ Γ·0, z≠0} 1/d(0,z)^{2s} for Γ = PSL(2,ℤ) satisfies a functional equation ζ_H(s) = Φ(s) · ζ_H(1-s) for an explicit function Φ(s), and all nontrivial zeros lie on Re(s) = 1/2.

**Test**: (1) Compute ζ_H(s) numerically for 1000+ lattice points and verify the functional equation at s = 0.3, 0.4, 0.6, 0.7 to within 10⁻⁴. (2) Locate the first 20 zeros on the critical strip and verify Re(s) = 1/2 ± 10⁻⁶. (3) Compare with eigenvalues of the Laplacian on PSL(2,ℤ)\ℍ (Maass forms).

**Impact**: If true, this provides a *provable* Riemann Hypothesis on a curved space. The proof would use the Selberg trace formula to relate zeros to eigenvalues of a self-adjoint operator (the Laplacian), bypassing the analytic difficulties of the classical RH. If false, the failure would reveal which aspects of the classical RH are genuinely special to the integers and cannot be replicated geometrically.

**Catalog References**: `Speculative/HyperbolicNumberTheory/PoincareDisk.lean` (hyperbolic zeta definition), `Algebra/Foundations.lean` (`critical_line_implies_unit_disk`), `EML/ModularForms.lean` (modular form infrastructure), `Speculative/IdempotentCollapse/TheoreticalExtensions.lean` (`RH_via_fixed_points`)

**Proof Strategy**: (1) Formalize the Selberg trace formula for PSL(2,ℤ)\ℍ in Lean, relating spectral data (Laplacian eigenvalues) to geometric data (closed geodesic lengths). (2) Show that ζ_H(s) can be expressed in terms of the Selberg zeta function Z(s). (3) Use the functional equation Z(s) = Z(1-s) · (explicit factors) to derive the functional equation for ζ_H. (4) Apply the spectral theorem for the Laplacian (self-adjoint ⟹ real eigenvalues ⟹ zeros on critical line). Key lemmas needed: discreteness of the Laplacian spectrum, Weyl law for eigenvalue asymptotics, trace class estimates.

**Domain Bridges**: NumberTheory <-> HyperbolicGeometry, Algebra <-> SpectralTheory, EML <-> Speculative

**Lineage**: Builds on `mobius_image_in_disk`, `counting_norm_galois`, and the cross-ratio properties from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Hyperbolic Unique Factorization and the Arithmetic of Möbius Primes

**Conjecture**: The hyperbolic integers Z_H under Möbius addition ⊕ do NOT have unique factorization into hyperbolic primes. Specifically, there exist hyperbolic integers with at least two distinct prime decompositions (up to reordering).

**Test**: (1) Enumerate all Möbius sums a ⊕ b for the first 100 lattice points. (2) Find a point z that equals both a₁ ⊕ b₁ and a₂ ⊕ b₂ for distinct prime pairs (a₁,b₁) ≠ (a₂,b₂). (3) If no counterexample is found among 100 points, extend to 500 points.

**Impact**: If factorization is NOT unique, this reveals a fundamental difference between flat and curved arithmetic — the integers ℤ have unique factorization, but their hyperbolic analogue does not. This would motivate defining "ideal hyperbolic integers" (analogous to Kummer's ideal numbers) to restore unique factorization, connecting to algebraic number theory. If factorization IS unique, this would be a remarkable rigidity result suggesting deep structural constraints from hyperbolic geometry.

**Catalog References**: `Speculative/HyperbolicNumberTheory/PoincareDisk.lean` (`IsHypPrime`, `hadd`), `Algebra/Basic.lean`, `Cryptography/BerggrenDiophantineLattice.lean`

**Proof Strategy**: Define a formal notion of "factorization length" for hyperbolic integers. Prove or disprove: every hyperbolic integer has a Möbius-prime factorization, and if so, is it unique? Use the non-commutativity of Möbius composition (φ_a ∘ φ_b ≠ φ_b ∘ φ_a in general) to construct distinct factorizations. Key lemma: non-commutativity of Möbius addition ⊕.

**Domain Bridges**: NumberTheory <-> Algebra, HyperbolicGeometry <-> AlgebraicNumberTheory

**Lineage**: Builds on `HyperbolicInteger.IsHypPrime` and `HyperbolicInteger.hadd` from this cycle.

**Ambition**: extension

---

### Direction 3: Tropical-Hyperbolic Bridge via Valuations

**Conjecture**: There exists a natural valuation map v : Z_H → ℝ≥0 defined by v(z) = -log(1 - |z|²) such that the image of Z_H under v forms a tropical semiring, and hyperbolic addition becomes tropical addition (min) under this valuation.

**Test**: (1) Compute v(z ⊕ w) and min(v(z), v(w)) for 50 pairs of lattice points. (2) Check whether v(z ⊕ w) ≈ min(v(z), v(w)) within 10%. (3) If not exact, characterize the error and determine whether a modified valuation works.

**Impact**: If true, this establishes a bridge between hyperbolic number theory and tropical geometry, connecting the Catalog's Tropical domain to the Speculative domain. The tropical structure would provide combinatorial tools (tropical Bézout's theorem, tropical Riemann-Roch) for studying hyperbolic lattices. If false, the failure reveals that hyperbolic arithmetic is fundamentally non-archimedean in ways that tropical geometry cannot capture.

**Catalog References**: `Tropical/` (tropical geometry infrastructure), `Speculative/HyperbolicNumberTheory/PoincareDisk.lean` (`hypDistCrossRatio`, `hadd`), `Algebra/Foundations.lean`

**Proof Strategy**: (1) Define the valuation v(z) = -log(1 - |z|²) and show it maps to ℝ≥0 (using `one_sub_normSq_pos`). (2) Show v(0) = 0 (since |0| = 0). (3) Compute v(z ⊕ w) explicitly and compare with min(v(z), v(w)). (4) If exact, formalize the tropical semiring structure. If approximate, bound the error using the cross-ratio.

**Domain Bridges**: HyperbolicGeometry <-> TropicalGeometry, NumberTheory <-> Combinatorics

**Lineage**: Builds on `PoincareDiskPt.one_sub_normSq_pos` and `HyperbolicInteger.hadd` from this cycle. Connects to Catalog's Tropical infrastructure.

**Ambition**: extension

---

### Direction 4: Quantum Error Correction on Hyperbolic Surfaces

**Conjecture**: Hyperbolic surface codes — quantum error-correcting codes defined on the tessellation of the Poincaré disk by PSL(2,ℤ) — achieve a code rate (logical qubits / physical qubits) that scales as Ω(1) (constant rate), compared to O(1/√n) for Euclidean toric codes.

**Test**: (1) Construct the tessellation graph for PSL(2,ℤ)\ℍ with N faces. (2) Compute the homology H₁ of the tessellation (number of logical qubits). (3) Verify that dim(H₁)/N → constant as N → ∞.

**Impact**: If true, hyperbolic surface codes would be a breakthrough in quantum computing, providing the first practical constant-rate quantum LDPC codes with geometric structure. The hyperbolic prime structure could inform decoder design. If false, the failure reveals topological obstructions to constant-rate codes on specific tessellations.

**Catalog References**: `Speculative/HyperbolicNumberTheory/PoincareDisk.lean` (lattice structure), `Computation/` (algorithmic infrastructure), `Physics/` (quantum information)

**Proof Strategy**: (1) Formalize the CW-complex structure of the modular tessellation. (2) Compute the Euler characteristic χ = V - E + F using the Gauss-Bonnet theorem (χ = Area/(2π) for hyperbolic surfaces). (3) Use the relation dim(H₁) = E - V - F + 2 = 2 - χ to bound the code rate. (4) Key insight: for hyperbolic surfaces, Area grows exponentially with radius, so the genus (and hence H₁) grows linearly with the number of faces.

**Domain Bridges**: HyperbolicGeometry <-> QuantumComputation, NumberTheory <-> Physics

**Lineage**: Builds on the hyperbolic lattice infrastructure from this cycle. Connects to `Computation/` and `Physics/` domains.

**Ambition**: grand_challenge

---

### Direction 5: Machine Learning on Hyperbolic Integers

**Conjecture**: Graph neural networks operating on hyperbolic integer embeddings (using Möbius addition for aggregation) achieve lower distortion on hierarchical graph classification tasks than Euclidean GNNs, with the improvement scaling as O(log(tree-width)).

**Test**: (1) Implement a Möbius-GNN that uses z ⊕ w for message passing instead of z + w. (2) Train on the ENZYMES and PROTEINS graph classification benchmarks. (3) Compare classification accuracy with Euclidean baseline. (4) Measure embedding distortion (average ratio of hyperbolic distance to graph distance).

**Impact**: If true, this provides a practical application of hyperbolic arithmetic to machine learning, demonstrating that the formal properties proved in this cycle (disk closure, distance properties) have computational consequences. If false, the failure would suggest that the overhead of Möbius operations outweighs the geometric advantage.

**Catalog References**: `MachineLearning/` (ML infrastructure), `Speculative/HyperbolicNumberTheory/PoincareDisk.lean` (`mobius_image_in_disk`, `hadd`), `Algebra/Foundations.lean`

**Proof Strategy**: This is primarily computational/experimental. The theoretical contribution would be proving that Möbius aggregation preserves certain invariants (e.g., equivariance under disk isometries) that Euclidean aggregation does not. Key lemma: `mobius_image_in_disk` ensures that all intermediate representations stay in the disk, preventing numerical overflow.

**Domain Bridges**: MachineLearning <-> HyperbolicGeometry, Algebra <-> MachineLearning

**Lineage**: Builds on `mobius_image_in_disk` and the disk closure property. Connects the under-explored Algebra <-> MachineLearning bridge identified in the Catalog analysis.

**Ambition**: extension
