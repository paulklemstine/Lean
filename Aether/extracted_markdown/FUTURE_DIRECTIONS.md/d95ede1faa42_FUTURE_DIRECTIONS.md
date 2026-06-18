# Future Directions: Primewise Persistent Homology of Rational Dynamics

## Synthesis

This research cycle established the mathematical foundations for using persistence profiles — topological invariants extracted from mod-*p* functional graphs — as conjugacy classifiers for rational dynamical systems. The key proven results are: (1) the preimage sum identity, which anchors all counting arguments; (2) conjugacy invariance of the degree sequence, establishing that persistence profiles are well-defined on conjugacy classes; (3) orbit entropy non-negativity via Jensen's inequality, bridging arithmetic dynamics to information theory; and (4) the persistence separation theorem, showing that degree sequence differences force persistence profile differences.

The most promising cross-domain connection is between **arithmetic dynamics and information theory** via orbit entropy. The entropy measures preimage concentration and is provably non-negative, connecting to Shannon's theory. This bridge could extend to thermodynamic formalism (transfer operators), cryptographic security (one-way function hardness), and statistical mechanics (partition functions). The Catalog's existing bridges — particularly `FINAL/Bridges/ThermoDioCryptoSecurity.lean` (connecting thermodynamic formalism to cryptographic bounds) and `FINAL/Bridges/HolographicProofRenormalization.lean` (fixed point bounds on orbits) — provide natural extension points.

The highest breakthrough potential lies in **Direction 1** (Arboreal Galois Persistence), which connects our mod-*p* persistence profiles to the deep theory of arboreal Galois representations. If the persistence profile encodes the Galois action on preimage trees, this would give a computable invariant of a fundamental number-theoretic object, with implications for the inverse Galois problem and Serre's uniformity conjecture.

---

### Direction 1: Arboreal Galois Persistence Correspondence

**Conjecture**: For a rational map *f ∈ ℚ(x)* of degree *d* ≥ 2, the primewise persistence profile Π_f(p) at depth *n* encodes the image of Frobenius at *p* in the arboreal Galois representation ρ_{f,n} : Gal(Q̄/ℚ) → Aut(T_n), where T_n is the *n*-th level preimage tree. Specifically, the periodic counts at level *k* equal the number of fixed points of ρ_{f,k}(Frob_p) on the tree, and the tail counts encode the cycle structure of Frob_p acting on tree levels.

**Test**: For the polynomial f(x) = x² - 1 over ℚ, compute: (a) the arboreal Galois group at levels 1–4 using the algorithm of Jones (2008); (b) the persistence profile at primes p = 5, 7, 11, ..., 97 at depth 4; (c) the Frobenius cycle type in Aut(T_4) at each prime. Verify that the persistence profile uniquely determines the Frobenius conjugacy class.

**Impact**: If true, this provides a computable bridge between TDA and Galois theory — two areas with no known connection. It would give a polynomial-time algorithm to compute Frobenius elements in arboreal representations, bypassing expensive algebraic number field computations. If false, the specific failure pattern reveals which aspects of the Galois action are invisible to persistence.

**Catalog References**: `Speculative/AutoResearch/PrimewisePersistence/Theorems.lean` (periodicPoints_subset_of_dvd, degreeSequence_conjugacy_invariant), `FINAL/Bridges/HolographicProofRenormalization.lean` (exists_fixed_point_on_orbit_with_bound).

**Proof Strategy**: (1) Formalize the preimage tree T_n as a Lean structure over Fin(d^n). (2) Define the Frobenius action on T_n from the mod-*p* map. (3) Prove that the fixed point count on T_k equals periodicPoints(k).card. (4) Show the cycle type of Frobenius determines and is determined by the persistence profile via Burnside's lemma.

**Domain Bridges**: NumberTheory <-> TopologicalDataAnalysis, ArithmeticDynamics <-> GaloisTheory

**Lineage**: Builds on degreeSequence_conjugacy_invariant and periodicPoints_subset_of_dvd from this cycle. Extends Jones (2008) on arboreal Galois representations.

**Ambition**: grand_challenge

---

### Direction 2: Thermodynamic Orbit Entropy and Cryptographic Hardness

**Conjecture**: For a rational map *f* of degree *d*, the orbit entropy H_f(p) satisfies H_f(p) → log(d) as p → ∞ for non-Lattès maps, and H_f(p) = log(d) for all good primes iff f is a power map or Chebyshev polynomial. Furthermore, maps with orbit entropy bounded away from log(d) yield stronger one-way function candidates: the preimage-finding problem for f mod p requires Ω(p^{1-H_f(p)/log(d)}) queries.

**Test**: Compute orbit entropy for f(x) = x² + c (c = 0,...,50) over primes p = 101, 1009, 10007, 100003. Plot H_f(p) vs log(2) and verify convergence. For the exceptional cases (power maps, Chebyshev), verify exact equality at small primes.

**Impact**: This would establish a new connection between dynamics and cryptography: orbit entropy as a quantitative measure of one-way function hardness. It would give a computable, formally verified certificate for cryptographic security bounds.

**Catalog References**: `FINAL/Bridges/ThermoDioCryptoSecurity.lean` (exists_large_preimage_from_average), `FINAL/Bridges/TropicalCryptographyBreakthrough.lean` (tropical_preimage_with_large_hidden), `Speculative/AutoResearch/PrimewisePersistence/Theorems.lean` (orbit_entropy_nonneg).

**Proof Strategy**: (1) Prove H_f(p) ≤ log(d) using the preimage sum identity and AM-GM. (2) Show H_f(p) ≥ log(d) - O(1/p) for non-Lattès maps using equidistribution results. (3) Connect the entropy gap to preimage concentration via the thermodynamic formalism in ThermoDioCryptoSecurity.lean.

**Domain Bridges**: ArithmeticDynamics <-> Cryptography, InformationTheory <-> ThermodynamicFormalism

**Lineage**: Builds on orbit_entropy_nonneg from this cycle and exists_large_preimage_from_average from the Catalog.

**Ambition**: grand_challenge

---

### Direction 3: Persistence Profile Determines Moduli Coordinates

**Conjecture**: For the moduli space M_d of rational maps of degree *d* modulo PGL₂-conjugacy, the map sending a conjugacy class [f] to its persistence profile sequence {Π_f(p)}_p (for all good primes p up to a bound B(d)) is injective on a Zariski-open subset of M_d. The bound B(d) = O(d² log d) suffices.

**Test**: For d = 2, the moduli space M₂ ≅ A² (parametrized by σ₁, σ₂ from the multiplier spectrum). Compute persistence profiles for a grid of 1000 points in M₂ over primes up to B(2) = 20. Verify injectivity.

**Impact**: This would give effective, arithmetic coordinates on moduli spaces of dynamical systems, useful for computational arithmetic geometry and for understanding the geography of dynamical moduli.

**Catalog References**: `Speculative/AutoResearch/PrimewisePersistence/Defs.lean` (PersistenceProfile, ModPDynamics.toPersistenceProfile), `Speculative/AutoResearch/PrimewisePersistence/Theorems.lean` (persistence_separation_from_degree).

**Proof Strategy**: (1) Show that multiplier spectra are determined by periodic point counts (classical). (2) Show periodic point counts are determined by persistence profiles (from periodicCounts in the profile). (3) Use Milnor's theorem that M₂ is parametrized by multiplier invariants. (4) Extend to higher degree by induction on dimension of M_d.

**Domain Bridges**: ArithmeticDynamics <-> AlgebraicGeometry, NumberTheory <-> ModuliTheory

**Lineage**: Builds on persistence_separation_from_degree and the full persistence profile framework from this cycle.

**Ambition**: extension

---

### Direction 4: Tropical Persistence and Berkovich Space Structure

**Conjecture**: The persistence profile of f mod p converges, in a suitable tropical limit as p → ∞, to a persistence diagram on the Berkovich projective line ℙ¹_Berk over ℚ_p. The limiting persistence diagram encodes the Julia set of f on ℙ¹_Berk.

**Test**: For f(x) = x² - 2, compute persistence profiles at primes p = 2, 3, 5, 7, ..., 97 and plot the convergence of normalized tail counts. Compare with the known Berkovich Julia set structure for this map.

**Impact**: This would connect finite-field dynamics to non-Archimedean dynamics via tropical geometry, creating a new bridge between discrete combinatorics and analytic geometry.

**Catalog References**: `FINAL/Bridges/TropicalPersistenceRealizationDuality.lean` (exists_minimal_graph_from_rank_data), `Speculative/AutoResearch/ArithmeticBerkovichCellDecomposition.lean` (exists_refinement_cell_for_pair).

**Proof Strategy**: (1) Define the tropical limit of persistence profiles using valuations. (2) Relate the limiting tail counts to the diameter filtration on the Berkovich tree. (3) Show the persistence diagram of the limiting complex computes the Čech cohomology of the Julia set.

**Domain Bridges**: ArithmeticDynamics <-> TropicalGeometry, TopologicalDataAnalysis <-> BerkovichAnalysis

**Lineage**: Builds on exists_minimal_graph_from_rank_data from the Catalog and the persistence framework from this cycle.

**Ambition**: extension

---

### Direction 5: Machine Learning on Persistence Profiles for Dynamical Classification

**Conjecture**: A neural network trained on persistence profiles {Π_f(p)}_{p ≤ B} can predict the conjugacy class of f with > 99% accuracy for quadratic maps and > 95% accuracy for cubic maps, using profiles at only B = 10 primes.

**Test**: Generate 10,000 quadratic rational maps with random rational coefficients (numerator/denominator ≤ 100). Compute persistence profiles at primes 2, 3, 5, 7, 11, 13, 17, 19, 23, 29. Train a classifier to predict conjugacy class labels (computed by exact algebraic methods). Measure accuracy on a held-out test set.

**Impact**: This would demonstrate that persistence profiles are not just theoretically invariant but practically discriminating, enabling fast conjugacy testing for large-scale dynamical databases.

**Catalog References**: `Speculative/AutoResearch/PrimewisePersistence/Theorems.lean` (all theorems), `FINAL/MachineLearning/LegendreGapReduction.lean` (exists_prime_between_sq_and_two_mul_sq — for prime distribution).

**Proof Strategy**: No formal proof needed for the ML experiment. However, formally verify that the feature extraction pipeline preserves conjugacy invariance (using degreeSequence_conjugacy_invariant) so that the ML model provably cannot misclassify conjugate maps as different.

**Domain Bridges**: ArithmeticDynamics <-> MachineLearning, TopologicalDataAnalysis <-> NeuralNetworks

**Lineage**: Builds on the full persistence profile framework from this cycle. Extends the Algebra <-> MachineLearning structural opportunity identified in the Catalog.

**Ambition**: extension
