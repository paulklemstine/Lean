# Future Directions: Tropical Lorentzian Geometry of Tensor Networks

## Synthesis

The theorems established in this cycle — tropical hypersurface characterization, bond-dimension support bounds, and the weight separation principle — form the foundation of a **tropical complexity theory for tensor networks**. The five directions below extend this foundation along complementary axes: matroidal structure (Direction 1), holographic duality (Direction 2), algorithmic applications (Direction 3), phase classification (Direction 4), and error correction (Direction 5). Together, they converge toward a unified framework where tropical geometry serves as the combinatorial backbone of quantum entanglement theory, connecting representation complexity, fault tolerance, and gravitational physics through the shared language of piecewise-linear optimization.

---

## Direction 1: Matroidal Exchange Properties of Determinantal Boundary Supports

**Conjecture:** For planar tensor networks whose local tensors are free-fermionic (i.e., the boundary measurement polynomial is determinantal), the support of the boundary measurement polynomial satisfies the symmetric basis exchange axiom of matroid theory. Specifically, for any two support vectors m₁, m₂ and any coordinate i with m₁(i) > m₂(i), there exists j with m₁(j) < m₂(j) such that the exchanged vector m₁ - eᵢ + eⱼ is also in the support.

**Test:** Enumerate support families for small planar determinantal networks (≤ 6 boundary legs, bond dimension ≤ 4). Check basis exchange directly by exhaustive enumeration. Any counterexample falsifies the conjecture; survival through extensive testing would strongly motivate a proof.

**Impact:** This would establish a deep connection between tensor network entanglement structure and matroid theory, opening access to the entire toolkit of matroid optimization (greedy algorithms, matroid intersection, valuated matroid theory). It would also connect to Brändén–Huh's Lorentzian polynomial theory, where matroidal supports play a central role.

**Catalog References:** `Catalog/Pythagorean/TropicalTensorNetwork.lean` (support cardinality bounds, `isBondDimCompatible`), `Catalog/Pythagorean/TropicalLorentzianShadows.lean` (exchange slack), `Catalog/Pythagorean/ValuatedMatroidExchange.lean` (exchange properties)

**Proof Strategy:** Restrict to networks whose local tensors are matchgate tensors (free-fermionic). Express the boundary polynomial as a determinant of a matrix whose entries are tropical affine functions. Use the fact that determinantal supports satisfy the basis exchange property (a classical result in matroid theory). Transfer this through the tropicalization functor.

**Domain Bridges:** Matroid theory ↔ free-fermionic tensor networks ↔ tropical Grassmannians

**Lineage:** Extends `support_card_le_of_bondDimCompatible` from cardinality bounds to structural (exchange) constraints on support geometry.

**Ambition:** 🔴 Grand Challenge — would establish a fundamentally new structural theory

---

## Direction 2: Tropical Hypersurfaces as Holographic Entanglement Shadows

**Conjecture:** For tensor networks arising from discretizations of the AdS/CFT correspondence (e.g., HaPPY codes, random tensor networks on hyperbolic tilings), the tropical hypersurface of the boundary measurement polynomial is dual to the set of minimal surfaces (Ryu-Takayanagi surfaces) in the bulk geometry. Specifically, the tropical hypersurface encodes the phase transitions between competing minimal surfaces as boundary subregions are varied.

**Test:** Construct small HaPPY-code tensor networks (5-7 boundary sites on a hyperbolic pentagon tiling). Compute boundary measurement polynomials and their tropical hypersurfaces. Compare the hypersurface structure to the known Ryu-Takayanagi phase diagram. Quantitative agreement would support the conjecture; qualitative mismatch would refine it.

**Impact:** This would provide the first combinatorially exact formulation of the holographic entanglement entropy formula in terms of tropical geometry, potentially resolving ambiguities in the continuous Ryu-Takayanagi prescription and providing new computational tools for holographic codes.

**Catalog References:** `Catalog/Pythagorean/TropicalTensorNetwork.lean` (TropicalHypersurfacePoint, competing sectors theorem), `Catalog/Pythagorean/BerggrenHolographicDuality.lean`

**Proof Strategy:** Model the HaPPY code as a finite tensor network. Express the boundary entanglement entropy as a function of the boundary measurement polynomial. Show that the tropical limit selects the minimal-cost contraction, which corresponds to the geodesic (Ryu-Takayanagi surface) in the bulk. The tropical hypersurface then corresponds to the phase boundary where two geodesics compete.

**Domain Bridges:** Tropical geometry ↔ holographic duality ↔ quantum gravity ↔ tensor network codes

**Lineage:** Builds on the tropical hypersurface characterization theorems and extends them to the specific geometry of holographic tensor networks.

**Ambition:** 🔴 Grand Challenge — would bridge tropical geometry to quantum gravity

---

## Direction 3: Tropical Complexity Lower Bounds for Tensor Network Contraction

**Conjecture:** The tropical Lorentzian gap of a boundary measurement polynomial provides a lower bound on the contraction complexity of the underlying tensor network. Specifically, if the tropical gap is Ω(log χ), then any contraction ordering requires at least Ω(χ^{n/k}) time for some constant k depending on the network topology, where n is the number of boundary legs.

**Test:** Implement exact contraction algorithms for small tensor networks (≤ 10 tensors). Measure actual contraction time vs. tropical gap for families with varying bond dimension. Test whether networks with larger tropical gaps consistently require more contraction work. A systematic violation would falsify the conjecture.

**Impact:** This would establish the first complexity lower bounds for tensor network contraction derived from tropical geometric invariants, potentially providing new hardness results for quantum simulation and connecting to algebraic circuit complexity.

**Catalog References:** `Catalog/Pythagorean/TropicalTensorNetwork.lean` (bond dimension bounds, weight separation), `Catalog/Pythagorean/TropicalLorentzianShadows.lean` (tropical spectral gap)

**Proof Strategy:** Relate the tropical gap to the width of the tropical hypersurface, which controls the number of distinct contraction channels. Show that wide tropical hypersurfaces (many competing sectors) force any contraction ordering to maintain large intermediate tensors, yielding time lower bounds via information-theoretic arguments.

**Domain Bridges:** Tropical geometry ↔ computational complexity ↔ quantum simulation algorithms

**Lineage:** Extends the bond-dimension support bound to contraction complexity bounds.

**Ambition:** 🟡 Solid Extension — builds directly on established support bounds

---

## Direction 4: Tropical Phase Classification of Quantum Many-Body States

**Conjecture:** Distinct quantum phases of matter (e.g., trivial, symmetry-broken, topological) produce boundary measurement polynomials whose tropical hypersurfaces have qualitatively different combinatorial types. Specifically, topological phases produce tropical hypersurfaces with non-trivial higher homology, while trivial phases produce contractible (or empty) tropical hypersurfaces.

**Test:** Compute boundary measurement polynomials for small instances of the toric code, the AKLT chain, and a trivial product state. Compare the topology (connected components, cycles) of their tropical hypersurfaces. Observe whether phase transitions correspond to topological changes in the tropical hypersurface.

**Impact:** This would provide a new topological invariant for quantum phases derived from tropical geometry, potentially complementing existing invariants (entanglement spectrum, topological entanglement entropy) and providing new computational diagnostics for phase identification.

**Catalog References:** `Catalog/Pythagorean/TropicalTensorNetwork.lean` (TropicalHypersurfacePoint), `Catalog/Pythagorean/ArithmeticPhaseClassification.lean`

**Proof Strategy:** For stabilizer/CSS codes, express the boundary polynomial explicitly in terms of the stabilizer group. Show that the tropical hypersurface structure reflects the code distance and logical operator geometry. For general phases, use the monotonicity theorem (hypersurface_of_support_subset) to show that phase transitions manifest as support changes that alter tropical hypersurface topology.

**Domain Bridges:** Tropical geometry ↔ condensed matter physics ↔ topological quantum computing

**Lineage:** Extends the hypersurface characterization from individual states to families parameterized by physical parameters.

**Ambition:** 🟡 Solid Extension — leverages existing hypersurface theorems in a new physical context

---

## Direction 5: Tropical Quantum Error Correction

**Conjecture:** The tropical gap of a quantum error-correcting code's boundary measurement polynomial lower-bounds the code distance. Specifically, for a stabilizer code with n physical qubits and distance d, the tropical gap of the syndrome measurement polynomial satisfies gap ≥ c · log(d) for some universal constant c > 0.

**Test:** Compute tropical gaps for standard code families: repetition codes (distance = n), Steane [[7,1,3]] code, surface codes of varying sizes. Plot gap vs. log(d). Test whether the bound holds. A counterexample (code with large distance but small gap) would falsify the conjecture.

**Impact:** This would provide a new geometric lower bound on code distance derived from tropical geometry, potentially complementing linear-programming bounds and connecting quantum error correction to tropical optimization. It would also suggest new decoding algorithms based on tropical minimization.

**Catalog References:** `Catalog/Pythagorean/TropicalTensorNetwork.lean` (weight separation principle, bond dimension bounds), `Catalog/Pythagorean/TropicalLorentzianShadows.lean` (tropical spectral gap)

**Proof Strategy:** Model the error-correcting code as a tensor network where internal edges correspond to syndrome bits. Express the syndrome polynomial as a boundary measurement polynomial. Show that minimum-weight error operators correspond to tropical minimizers, and that the code distance equals the minimum weight of a non-trivial logical operator, which is bounded below by the tropical gap.

**Domain Bridges:** Tropical geometry ↔ quantum error correction ↔ coding theory ↔ optimization

**Lineage:** Extends the weight separation principle from generic boundary measurement data to the structured setting of error-correcting codes.

**Ambition:** 🟡 Solid Extension — applies established framework to a well-defined computational problem

---

*"The key insight is that the tropical hypersurface is not merely a mathematical shadow — it is a physical observable, encoding the competition between quantum configurations in the language of piecewise-linear geometry."*
