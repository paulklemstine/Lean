# Future Directions: Hyperbolic Number Theory

## Synthesis

This research cycle established the foundational layer of number theory on the Poincaré disk, proving six core theorems that bridge hyperbolic geometry with arithmetic and analytic number theory. The most promising discovery is the precise correspondence between the critical strip (Re(s) > 1/2) and the disk interior via ρ ↦ 1 - 1/ρ (Theorem `halfplane_to_disk`), which provides a geometric framework for studying zeta zero locations. This builds on the catalog's `critical_line_implies_unit_disk` (in `Algebra/Foundations.lean`), which handles the boundary case Re(s) = 1/2.

The conformal product identity (Theorem `hypDelta_le_conformal_product`) reveals that hyperbolic distance is exactly — not approximately — determined by local curvature data. This perfect tightness is unusual in geometric inequalities and suggests that the Poincaré disk has especially rigid arithmetic structure, analogous to how ℤ has unique factorization while generic rings do not.

The highest-breakthrough-potential direction is **Direction 1** (Multiplicative Hyperbolic Arithmetic), because establishing unique factorization in hyperbolic lattices would open a direct path to hyperbolic analogues of the fundamental theorem of arithmetic and potentially the Riemann Hypothesis via spectral methods. The cross-domain bridge between Algebra ↔ Number Theory ↔ Hyperbolic Geometry is the most productive axis for future exploration.

---

### Direction 1: Multiplicative Hyperbolic Arithmetic and Unique Factorization

**Conjecture**: Define hyperbolic multiplication on a lattice L = Γ·0 by z ⊗ w = γ_z(w) where γ_z is the unique group element mapping 0 to z. Then the lattice (L, ⊗) satisfies unique factorization into hyperbolic primes, modulo the action of the stabilizer of 0.

**Test**: For the modular group Γ = PSL(2,ℤ), compute the orbit of 0 up to 1000 points. For each composite lattice point (one where hypNorm decomposes as a sum), verify that the multiplicative decomposition under ⊗ is unique up to order and stabilizer. A single counterexample (two essentially different factorizations) disproves the conjecture.

**Impact**: If true, this would establish the Poincaré disk as a genuine "curved number system" with the same structural rigidity as ℤ. This opens the door to hyperbolic algebraic number theory: extensions, ideal theory, class numbers. If false, the failure mode reveals which curvature conditions are needed for unique factorization.

**Catalog References**: `Algebra/Foundations.lean` (critical_line_implies_unit_disk), `Speculative/HyperbolicNumberTheory/Main.lean` (exists_hyperbolic_prime_of_minimal, hypNorm_origin_eq)

**Proof Strategy**: 
1. Define ⊗ formally via the group action and verify associativity using Möbius composition.
2. Prove that ‖z ⊗ w‖_H = ‖z‖_H + ‖w‖_H + 2·Re(z·w̄)/((1-|z|²)(1-|w|²)) (the hyperbolic addition formula).
3. Show that the "hyperbolic norm" is a Euclidean-type norm for ⊗, analogous to the absolute value for ℤ.
4. Apply the Euclidean algorithm argument: if ⊗ admits a division algorithm (Theorem `hyp_division_exists` — not yet proved), then unique factorization follows.

**Domain Bridges**: Algebra <-> Geometry, NumberTheory <-> HyperbolicGeometry

**Lineage**: Builds directly on `conformalFactor_eq_two_iff`, `exists_hyperbolic_prime_of_minimal`, and `hypNorm_origin_eq` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Spectral Approach to Hyperbolic Primes via Selberg Trace Formula

**Conjecture**: The hyperbolic prime counting function π_H(R) for the lattice PSL(2,ℤ)·0 satisfies π_H(R) = R²/(2 log R) + O(R²/log²R), where the error term is governed by the smallest eigenvalue of the Laplacian on the modular surface.

**Test**: Compute π_H(R) for R ∈ {1, 2, 5, 10, 20, 50, 100} using the orbit of PSL(2,ℤ) with 10⁴ points. Fit the data to R²/(c·log R) and determine c. If c ≈ 2, the conjecture survives. Also compute the error term and check whether it correlates with the spectral gap λ₁ = 1/4 + r₁² of the modular surface.

**Impact**: This would connect hyperbolic number theory to the deep spectral theory of automorphic forms. The Selberg eigenvalue conjecture (λ₁ ≥ 1/4) would have direct implications for the error term in hyperbolic prime counting. This is a concrete instance of the "primes ↔ eigenvalues" philosophy.

**Catalog References**: `Algebra/Foundations.lean` (critical_line_implies_unit_disk), `EML/ModularForms.lean` (modular form structures)

**Proof Strategy**:
1. Express π_H(R) using the Selberg trace formula applied to a smoothed counting function.
2. Identify the main term from the identity contribution in the trace formula.
3. Bound the error term using Weyl's law for the eigenvalue distribution.
4. The key lemma: relate "hyperbolic primality" to "primitive conjugacy classes" in PSL(2,ℤ).

**Domain Bridges**: NumberTheory <-> SpectralTheory, HyperbolicGeometry <-> AutomorphicForms

**Lineage**: Builds on the hyperbolic prime number theorem conjecture from this cycle and the modular form infrastructure in `EML/ModularForms.lean`.

**Ambition**: grand_challenge

---

### Direction 3: Hyperbolic Lattice Cryptography

**Conjecture**: The Shortest Vector Problem (SVP) in hyperbolic lattices is at least as hard as in Euclidean lattices of the same rank, with an additional exponential factor from the exponential growth of hyperbolic balls.

**Test**: Implement LLL-type lattice reduction for hyperbolic lattices (replacing Euclidean inner products with hyperbolic ones). Measure the approximation factor achieved on random hyperbolic lattices of dimension 10-50. Compare with Euclidean LLL on equivalent-density lattices. If the approximation factor is worse by a factor of ≥ 2^(n/10), the conjecture is supported.

**Impact**: Post-quantum cryptographic protocols based on Euclidean lattice problems (LWE, NTRU) could be strengthened by moving to hyperbolic lattices. The exponential growth of hyperbolic space means that lattice points are exponentially farther apart, potentially making brute-force search even harder.

**Catalog References**: `Cryptography/BerggrenDiophantineLattice.lean` (Euclidean lattice structures), `Speculative/HyperbolicNumberTheory/Main.lean` (MoebiusAut, hypDelta)

**Proof Strategy**:
1. Define a hyperbolic analogue of the Gram-Schmidt process using the hyperbolic inner product.
2. Prove a hyperbolic analogue of Minkowski's theorem: the minimum norm in a lattice is bounded by the covolume.
3. Show that the covolume of a hyperbolic lattice grows exponentially with dimension, giving the SVP hardness boost.
4. Implement and benchmark the algorithms.

**Domain Bridges**: Cryptography <-> HyperbolicGeometry, Computation <-> Algebra

**Lineage**: Builds on MoebiusAut and hypDelta from this cycle; connects to `Cryptography/BerggrenDiophantineLattice.lean`.

**Ambition**: extension

---

### Direction 4: Machine Learning with Hyperbolic Integer Arithmetic

**Conjecture**: For tree-structured data with branching factor b and depth d, embedding into a hyperbolic lattice (rather than continuous hyperbolic space) achieves distortion ≤ 1 + O(1/b) with O(d · log b) bits per coordinate, compared to O(d · b^d) dimensions needed in Euclidean space.

**Test**: Embed WordNet (82,000 nodes, tree depth ~15) into (a) continuous Poincaré disk, (b) the natToDisk lattice with interpolation, (c) Euclidean space. Compare distortion, compression ratio, and nearest-neighbor query time. If the lattice embedding achieves comparable distortion with discrete (integer) coordinates, it validates the approach.

**Impact**: Discrete hyperbolic embeddings would be more computationally efficient than continuous ones (integer arithmetic vs. floating point), more amenable to formal verification, and naturally compatible with hash-based data structures. This bridges hyperbolic number theory with practical machine learning.

**Catalog References**: `MachineLearning/` (existing ML infrastructure), `Speculative/HyperbolicNumberTheory/Main.lean` (natToDisk, natToDisk_coord_strictMono)

**Proof Strategy**:
1. Prove that the natToDisk embedding has bounded distortion for tree graphs.
2. Define a "rounding" operation from continuous disk to nearest lattice point.
3. Bound the rounding error in hyperbolic distance.
4. Show that nearest-neighbor queries can be answered in O(log n) time using the lattice structure.

**Domain Bridges**: MachineLearning <-> HyperbolicGeometry, Algebra <-> MachineLearning

**Lineage**: Builds on natToDisk_coord_strictMono and the conformal product identity from this cycle.

**Ambition**: extension

---

### Direction 5: Zeta Zeros and Disk Dynamics

**Conjecture**: Define the "disk dynamics" map T: 𝔻 → 𝔻 by T(w) = w² (squaring in the disk). Then the fixed points of T^n correspond to nth roots of unity on ∂𝔻, and the pre-images of the fixed point 0 under iterated T encode the non-trivial zeros of the Riemann zeta function via the bridge map ρ ↦ 1-1/ρ.

**Test**: Compute the iterates T^n(w₀) for w₀ near the image of a known zeta zero under the bridge map. If the orbit converges to ∂𝔻, this supports the conjecture. If it spirals into the interior, the dynamics provide a new characterization of zero locations.

**Impact**: If the dynamics of T on 𝔻 are ergodic with respect to hyperbolic area, then the equidistribution of zeta zeros on the critical line would follow from ergodic theory — potentially providing a dynamical proof of the Riemann Hypothesis.

**Catalog References**: `Pythagorean/DynamicalSquaring.lean` (prime_has_two_fixed_points), `Speculative/IdempotentCollapse/TheoreticalExtensions.lean` (RH_via_fixed_points), `Algebra/Foundations.lean` (critical_line_implies_unit_disk)

**Proof Strategy**:
1. Formalize the squaring map T on 𝔻 and prove it preserves hyperbolic area.
2. Classify the fixed points: T(w) = w ⟺ w = 0 or w = 1, connecting to `prime_has_two_fixed_points`.
3. Show that periodic orbits of T on ∂𝔻 are dense and equidistributed.
4. Relate the periodic orbit structure to the Selberg zeta function.
5. Use the halfplane_to_disk bridge to translate back to zeta zero locations.

**Domain Bridges**: NumberTheory <-> DynamicalSystems, HyperbolicGeometry <-> SpectralTheory

**Lineage**: Builds on halfplane_to_disk and the existing `RH_via_fixed_points` and `prime_has_two_fixed_points` in the catalog.

**Ambition**: grand_challenge
