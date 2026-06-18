# Future Directions: Primewise Persistent Homology and Arithmetic Obstructions

## Synthesis

This research cycle established a formal bridge between persistent homology and arithmetic local-global principles. The key discovery is that Frobenius orbit decompositions of curves mod p naturally generate persistence barcodes whose invariants (total persistence, Euler characteristic) exactly capture arithmetic quantities (point counts, orbit numbers). Twelve theorems were proved with full machine verification, zero sorries.

The most promising cross-domain connection is the **Euler-Orbit Correspondence** (Theorem 3.3): the topological Euler characteristic of the orbit barcode equals the number of Frobenius orbits, a quantity directly related to the factorization of the characteristic polynomial of Frobenius. This suggests that higher persistence invariants (beyond Euler characteristic) may capture information invisible to classical point-counting, potentially including shadows of the Tate-Shafarevich group.

The Pell separation conjecture provides a concrete computational testbed. All 45 pairs of squarefree integers tested were separated by primes ≤ 50, supporting the hypothesis that persistence signatures carry enough arithmetic information for discrimination. The mod-9 obstruction bridge demonstrates compatibility with existing catalog results (`Algebra/LocalGlobal.lean`), showing that classical obstructions appear naturally as persistence vanishing.

The highest breakthrough potential lies in **Direction 1** (Extension Field Orbits), because over F_{p^k} for k > 1, Frobenius orbits acquire nontrivial sizes that encode information about the Weil polynomial — precisely the data from which Tate-Shafarevich invariants might be extracted.

---

### Direction 1: Extension Field Orbits and Weil Polynomial Recovery

**Conjecture**: For an elliptic curve E/ℚ with good reduction at p, the persistence barcode of the Frobenius action on E(F_{p^k}) for k = 1, 2, ..., K determines the characteristic polynomial of Frobenius χ_p(T) = T² - a_p T + p, and hence the trace a_p, from the orbit size partition alone when K ≥ 2.

**Test**: For curves y² = x³ + ax + b with known a_p values, compute Frobenius orbits on E(F_{p²}) and E(F_{p³}). The orbits over F_{p²} have sizes dividing 2, and the number of fixed points equals N_{p²} = p² + 1 - (a_p² - 2p). Verify that the orbit partition over F_{p²} uniquely determines a_p. Test with 50 curves and 20 primes each.

**Impact**: If true, this provides a topological encoding of L-function data. The Weil polynomial encodes all point counts over extension fields, so recovering it from persistence data would establish an information-theoretic equivalence between persistence signatures and L-function coefficients. If false, it identifies which Weil polynomial information is invisible to persistence.

**Catalog References**: `Bridges/PrimewisePersistentHomology.lean` (orbit_barcode_total_persistence, frobenius_orbit_divides), `Pythagorean/DynamicalSquaring.lean` (prime_has_two_fixed_points)

**Proof Strategy**: Over F_{p^k}, a point has Frobenius orbit size d | k. The number of points with orbit size d equals N_{p^d}/d minus contributions from smaller divisors (Möbius inversion). From the orbit partition, recover N_{p^d} for d | k, then use Newton's identities to recover the Weil polynomial coefficients. The key lemma is that the orbit partition determines the power sums of the Frobenius eigenvalues.

**Domain Bridges**: Number Theory <-> Algebraic Topology, Algebra <-> Combinatorics

**Lineage**: Builds on orbit_barcode_total_persistence and euler_char_eq_numOrbits from this cycle. Extends frobenius_orbit_divides to extension fields.

**Ambition**: grand_challenge

---

### Direction 2: Persistence Distance and Conductor Proximity

**Conjecture**: There exists a constant C > 0 such that for two elliptic curves E₁, E₂/ℚ with conductors N₁, N₂, the bottleneck distance between their primewise persistence barcodes (averaged over good primes p ≤ B) satisfies:

d_B(Barcode(E₁), Barcode(E₂)) ≥ C · |N₁ - N₂| / B^{1/2} + O(1/B)

In other words, curves with different conductors have asymptotically separated persistence signatures.

**Test**: Compute persistence barcodes for all elliptic curves with conductor ≤ 100 in the LMFDB database. For each pair, compute bottleneck distance over primes ≤ 200. Regress log(distance) against log(|N₁ - N₂|) and check that the slope is positive.

**Impact**: Would establish a quantitative metric on the space of elliptic curves via persistence, connecting the arithmetic conductor (which controls ramification) to a topological distance. This would be the first formal stability result in arithmetic persistence theory.

**Catalog References**: `Bridges/PrimewisePersistentHomology.lean` (barcode_shift_totalPersistence, finite_window_local_agreement), `Bridges/HolographicProofRenormalization.lean` (exists_fixed_point_on_orbit_with_bound)

**Proof Strategy**: The key input is the Hasse-Weil bound |a_p| ≤ 2√p. For curves with different conductors, the set of primes where they have different reduction types creates a persistent difference in orbit structures. Formalize this using the explicit formula for the barcode from orbit data, and bound the bottleneck distance below using the structural theorems from this cycle.

**Domain Bridges**: Number Theory <-> Topology, Algebra <-> Analysis

**Lineage**: Builds on the barcode stability theorems (barcode_shift_size, barcode_shift_totalPersistence) from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Machine Learning on Persistence Signatures for Sha Detection

**Conjecture**: A gradient-boosted classifier trained on primewise persistence signatures {(total_persistence(p), euler_char(p), rank_at(p, 1)) : p ≤ B} for elliptic curves with known Sha order achieves > 80% accuracy in predicting whether |Ш(E/ℚ)| > 1, for B = 100.

**Test**: From the LMFDB, extract 500 curves with known Sha order. Compute persistence features at all good primes ≤ 100. Train a classifier with 5-fold cross-validation. The conjecture is refuted if no classifier exceeds 65% accuracy (chance for imbalanced data).

**Impact**: Would demonstrate that topological persistence captures computable shadows of the Tate-Shafarevich group, opening a new approach to the Birch and Swinnerton-Dyer conjecture. Even partial success would identify which persistence features correlate with Sha nontriviality.

**Catalog References**: `Bridges/PrimewisePersistentHomology.lean` (euler_char_eq_numOrbits, locally_solvable_of_fixed_point), `MachineLearning/NeuralSheafCohomology.lean` (exists_global_radius_of_finite_local_witnesses)

**Proof Strategy**: No formal proof needed for the ML component, but formalize the feature extraction pipeline: prove that the persistence features are well-defined and computable from standard curve data. Use `exists_global_radius_of_finite_local_witnesses` from the catalog to justify that finitely many local features suffice for global prediction.

**Domain Bridges**: MachineLearning <-> Number Theory, Algebra <-> Topology

**Lineage**: Builds on the complete theorem suite from this cycle, particularly the finite window principle (finite_window_local_agreement).

**Ambition**: extension

---

### Direction 4: Tropical Persistence and Reduction Types

**Conjecture**: For an elliptic curve E/ℚ with semistable reduction at p, the Frobenius orbit barcode over F_p is determined by the Kodaira-Néron reduction type (I_n, II, III, etc.), and the persistence Euler characteristic encodes the number of components of the special fiber.

**Test**: For elliptic curves with known Kodaira symbols from the LMFDB, compute orbit barcodes at primes of bad reduction. Verify that curves with the same Kodaira symbol produce the same barcode invariants.

**Impact**: Would connect the persistence framework to tropical geometry (reduction types correspond to tropical curves) and Néron models, establishing a three-way bridge: persistence ↔ tropical geometry ↔ arithmetic geometry.

**Catalog References**: `Bridges/PrimewisePersistentHomology.lean` (euler_char_eq_numOrbits, partition_persistence_eq), `Tropical/` (existing tropical geometry infrastructure)

**Proof Strategy**: For type I_n reduction, the special fiber has n components forming a cycle. The Frobenius permutes these components, and the orbit structure on the smooth part of the special fiber is determined by this permutation. Formalize the correspondence between Kodaira symbols and orbit partitions using the explicit classification.

**Domain Bridges**: Tropical <-> Number Theory, Topology <-> Algebra

**Lineage**: Builds on euler_char_eq_numOrbits and the partition framework from this cycle. Connects to the Tropical catalog.

**Ambition**: extension

---

### Direction 5: Persistence Zeta Functions

**Conjecture**: Define the *persistence zeta function* Z_pers(E, s) = Π_p (1 - totalPersistence(p) · p^{-s})^{-1} for an elliptic curve E. Then Z_pers(E, s) has a meromorphic continuation to Re(s) > 1/2 and its residue at s = 1 is related to the rank of E(ℚ) and the order of Ш(E/ℚ).

**Test**: Compute Z_pers(E, s) for 100 curves with known rank and Sha. Numerically evaluate the product at s = 1 + ε for small ε and compare with the BSD prediction L(E, 1) · (correction factors). The conjecture is supported if the persistence zeta residue correlates strongly (r > 0.8) with the BSD formula.

**Impact**: Would establish an entirely new zeta function in arithmetic geometry, providing a "persistence shadow" of the Hasse-Weil L-function. This could suggest new analytic approaches to BSD and related conjectures.

**Catalog References**: `Bridges/PrimewisePersistentHomology.lean` (orbit_barcode_total_persistence), `Pythagorean/TropicalBerggrenZeta.lean` (prime_one_mod_four_has_sum_two_squares)

**Proof Strategy**: By Theorem 3.2, totalPersistence(p) = totalPoints(D_p) ≈ p (for elliptic curves). So Z_pers has the same Euler product structure as the Hasse-Weil zeta function, modified by replacing N_p with N_p - 1 (affine points only). Analyze the convergence and functional equation using standard analytic number theory tools.

**Domain Bridges**: Number Theory <-> Analysis, Algebra <-> Topology

**Lineage**: Builds on orbit_barcode_total_persistence from this cycle and connects to the zeta function infrastructure in `Pythagorean/TropicalBerggrenZeta.lean`.

**Ambition**: grand_challenge
