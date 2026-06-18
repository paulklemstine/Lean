# Future Directions: Non-Desarguesian Geometry and the Defect Spectrum

## Synthesis

This cycle introduced the **Desarguesian Defect Spectrum** (DDS), a novel numerical invariant that quantifies how a finite projective plane deviates from being Desarguesian. The key discovery is that the defect dimension δ = k/d − 1 cleanly characterizes Desarguesian planes (δ = 0) and provides a monotone measure of non-Desarguesian behavior. The collineation group bound theorem establishes a precise "symmetry tax" for non-Desarguesian planes, connecting algebraic defect to geometric symmetry loss.

The most promising cross-domain connection is between the defect spectrum and coding theory. Every projective plane of order n corresponds to a (n² + n + 1, n + 1, 1)-BIBD, and the defect spectrum constrains the automorphism group of this design. This connects our geometric results to the Algebra catalog (through nearfield theory) and potentially to the Cryptography catalog (through the relationship between finite geometry and error-correcting codes). The collineation bound theorem (`hall_plane_collineation_bound`) directly extends the existing `hall_collineation_lt_pgl` from the Geometry catalog with quantitative estimates.

The highest-breakthrough-potential direction is Direction 1 (Dickson nearfield formalization), because it would provide the first machine-verified construction of non-Desarguesian planes from first principles, connecting algebra, geometry, and finite model theory in a single formal development.

---

### Direction 1: Formal Construction of Dickson Nearfields

**Conjecture**: For every prime p and integers n ≥ 2, q = p^n, and every proper divisor d of n, the Dickson nearfield construction produces a right nearfield of order q with kernel GF(p^d), and this nearfield is not a field (i.e., left distributivity fails for at least one element).

The Dickson nearfield D(q, d) is defined on the underlying set GF(q) with standard addition but modified multiplication: for a, b ∈ GF(q), define a ∘ b = a · b^(p^(id mod d)) where i is determined by a's position in a fixed coset decomposition of GF(q)* by GF(p^d)*. This is a right nearfield iff (q − 1)/(p^d − 1) is coprime to d... but the exact conditions are subtle and depend on the Zsygmondy prime structure.

**Test**: Construct D(9, 1) explicitly as a 9-element nearfield. Verify computationally that right distributivity holds, left distributivity fails for at least one triple, and the kernel has exactly 3 elements.

**Impact**: A verified Dickson construction would close the gap between the DDS invariant (which we formalized) and the actual geometric objects it classifies. It would also provide the first formally verified example of a non-associative finite algebraic structure coordinatizing a geometry.

**Catalog References**: `Geometry/NonDesarguesian.lean` (DDS theorems), `Geometry/Nearfield.lean` (right nearfield definition)

**Proof Strategy**:
1. Define the Dickson multiplication on `ZMod (p^n)` or `GF(p^n)`.
2. Prove right distributivity using properties of the Frobenius automorphism.
3. Prove left distributivity failure by exhibiting a concrete counterexample triple.
4. Verify the kernel is exactly GF(p^d) by checking the distributivity condition.
5. Connect to the DDS via `defect_spectrum_d1_exists`.

**Domain Bridges**: Algebra (nearfield theory) ↔ Geometry (projective planes) ↔ Cryptography (finite field arithmetic)

**Lineage**: Builds on `DesarguesianDefectSpectrum`, `RightNearfield`, and `exists_non_desarguesian` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: The Defect Spectrum of Hall Triple Systems

**Conjecture**: Every Steiner triple system S(2, 3, v) that is also a Hall triple system (closed under the Steiner quasigroup operation) admits a natural DDS invariant. Specifically, if v = 3^k, the Hall triple system has a kernel of order 3^d where d | k, and the defect dimension k/d − 1 determines the automorphism group structure.

Hall triple systems are the ternary analogs of non-Desarguesian planes: they coordinatize affine planes of order 3 with specific algebraic structure. The connection to the DDS is through the fact that every Hall triple system is equivalent to a commutative Moufang loop of exponent 3, and the kernel of this loop plays the role of the nearfield kernel.

**Test**: Enumerate all Hall triple systems of order 3^3 = 27 and 3^4 = 81, compute their automorphism groups, and check whether the automorphism group order is predicted by the DDS formula.

**Impact**: Would unify the theory of non-Desarguesian planes with Hall triple systems, extending the DDS framework to a broader class of combinatorial structures. This is a genuine cross-domain bridge between geometry and design theory.

**Catalog References**: `Geometry/NonDesarguesian.lean` (DDS), `Geometry/Nearfield.lean` (kernel theory)

**Proof Strategy**:
1. Define Hall triple systems as Steiner triple systems with the closure property.
2. Define the associated commutative Moufang loop.
3. Define the kernel of the loop (the set of elements satisfying the associative law with all pairs).
4. Prove the kernel has order 3^d for some d | k.
5. Connect to the DDS and prove the automorphism bound.

**Domain Bridges**: Geometry (projective planes) ↔ Combinatorics (Steiner systems) ↔ Algebra (Moufang loops)

**Lineage**: Extends the DDS framework from this cycle to Hall triple systems, a closely related but distinct combinatorial structure.

**Ambition**: grand_challenge

---

### Direction 3: Tropical Defect Spectrum

**Conjecture**: The left distributivity defect of a nearfield has a tropical analog: in the tropical semiring (ℝ ∪ {∞}, min, +), the "tropical defect" of an element a is D_trop(a, b, c) = min(a + b, a + c) − a − min(b, c). This defect is always zero (since tropical multiplication distributes over tropical addition), implying that **all tropical planes are Desarguesian**.

**Test**: Verify computationally that the tropical defect vanishes for all real triples (a, b, c). Then prove this formally in Lean using the properties of min and +. Investigate what structure replaces the DDS when the base algebraic structure is changed from fields to semirings.

**Impact**: If true, this establishes a fundamental difference between classical and tropical geometry: tropical geometry is inherently Desarguesian, while classical geometry admits non-Desarguesian perturbations. This would be a novel cross-domain bridge connecting our geometric results to the Tropical catalog.

**Catalog References**: `Tropical/TropicalLanglandsGL1.lean`, `Geometry/NonDesarguesian.lean`

**Proof Strategy**:
1. Define the tropical semiring formally (or use Mathlib's existing `Tropical` type).
2. Define the tropical left distributivity defect.
3. Prove it vanishes identically using `min_add_add_left` or equivalent.
4. State and prove: "Every tropical projective plane is Desarguesian."

**Domain Bridges**: Geometry (non-Desarguesian planes) ↔ Tropical (tropical semirings) ↔ Algebra (distributivity)

**Lineage**: Cross-domain bridge from this cycle's DDS framework to the Tropical catalog.

**Ambition**: extension

---

### Direction 4: Collineation Group Phase Transitions

**Conjecture**: For a fixed prime p and increasing k, the number of non-isomorphic non-Desarguesian planes of order p^k grows at least as fast as the number of divisors of k. Moreover, the collineation group orders of these planes exhibit "phase transitions" at values of k where the divisor structure changes (e.g., k prime vs k highly composite).

Specifically, conjecture that for k = p₁ · p₂ · ... · p_r (a product of r distinct primes), there are at least 2^r − 1 non-isomorphic non-Desarguesian planes (one for each non-trivial divisor of k).

**Test**: For p = 2 and k = 6 (divisors: 1, 2, 3, 6), verify that there are at least 3 non-isomorphic non-Desarguesian planes of order 64. For k = 12 (divisors: 1, 2, 3, 4, 6, 12), verify at least 5.

**Impact**: Would provide the first formal lower bounds on the number of non-Desarguesian planes of given order, connecting combinatorial number theory (divisor functions) to finite geometry.

**Catalog References**: `Geometry/NonDesarguesian.lean` (DDS existence theorems)

**Proof Strategy**:
1. Prove that distinct valid (p, k, d) triples give non-isomorphic planes (by collineation group order).
2. Use the DDS to show that planes with different kernel dimensions are non-isomorphic.
3. Count the number of valid d values for a given k.
4. Connect to the divisor function τ(k).

**Domain Bridges**: Geometry (plane classification) ↔ Number Theory (divisor functions) ↔ Algebra (nearfield classification)

**Lineage**: Builds on `defect_monotone` and `exists_non_desarguesian` from this cycle.

**Ambition**: extension

---

### Direction 5: Wedderburn Obstruction in Infinite Nearfields

**Conjecture**: For infinite nearfields, the DDS can be generalized by replacing the kernel dimension d with the transcendence degree of the kernel over the prime subfield. In this setting, the "infinite defect spectrum" is a pair (κ, τ) where κ is the cardinality and τ is the transcendence degree, and the Wedderburn dichotomy FAILS: there exist infinite Desarguesian planes that are NOT coordinatized by commutative fields (e.g., quaternionic planes).

**Test**: Construct an infinite nearfield with prescribed kernel transcendence degree. Verify that Desargues' theorem holds for the associated plane (because infinite division rings ARE allowed, unlike the finite case where Wedderburn forces commutativity).

**Impact**: Would demonstrate that the Wedderburn-Veblen dichotomy (Theorem 7 from this cycle) is a genuinely finite phenomenon, and that infinite geometry has fundamentally different behavior. This challenges the common assumption that finite and infinite geometry are parallel.

**Catalog References**: `Geometry/NonDesarguesian.lean` (Wedderburn-Veblen dichotomy), `Geometry/ProjectivePlane.lean` (abstract projective planes)

**Proof Strategy**:
1. Define infinite nearfields using Hilbert's construction or ordered nearfields.
2. Prove that the quaternion algebra ℍ coordinatizes a Desarguesian plane.
3. Show that ℍ has kernel ℝ with transcendence degree equal to the cardinality of the continuum.
4. Prove Desargues holds despite ℍ not being a field.

**Domain Bridges**: Geometry (infinite planes) ↔ Algebra (quaternions, division rings) ↔ Logic (set-theoretic issues with infinite constructions)

**Lineage**: Extends the Wedderburn-Veblen dichotomy from this cycle to the infinite case, where it fails.

**Ambition**: extension
