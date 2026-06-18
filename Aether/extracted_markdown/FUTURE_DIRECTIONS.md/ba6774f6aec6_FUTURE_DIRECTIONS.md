# Future Directions: Newton Persistence and Arithmetic Monodromy

## Synthesis

This cycle established the foundational layer of **Newton persistence theory** — the framework connecting Newton's method dynamics over finite fields to arithmetic invariants of polynomials via persistent homology. The core results are: (1) the Newton Fixed Point Theorem identifying roots with fixed points of the Newton step, (2) orbit periodicity over finite fields via pigeonhole, (3) basin separation showing that Newton dynamics of product polynomials respect algebraic factorization, and (4) the first verified instance of the Frobenius depth conjecture for x² − 1.

The most promising cross-domain connection emerging from this cycle is the **depth filtration ↔ Frobenius cycle type** bridge. The Newton depth filtration partitions the finite field into layers, and computational evidence strongly suggests these layers encode the cycle structure of the Frobenius automorphism. This connects arithmetic dynamics (algebra) to persistent homology (topology) to Galois theory (number theory), creating a three-way bridge with potential applications to the inverse Galois problem and computational number theory.

The highest breakthrough potential lies in **Direction 3** (Persistent Chebotarev), which would generalize the classical Chebotarev density theorem to persistence diagrams. If successful, this would establish that the *distribution* of Newton persistence statistics across primes is governed by the Galois group, providing a new equidistribution theorem in arithmetic dynamics. The infrastructure built in this cycle (definitions, fixed-point theorem, orbit bounds) provides the necessary formal foundation.

---

### Direction 1: Higher-Depth Barcodes and Frobenius Cycle Detection

**Conjecture**: For a squarefree polynomial f ∈ ℤ[X] of degree d reduced modulo a good prime p, define the Newton step N_f(x) = x − f(x)/f′(x) on 𝔽_p (with N_f(x) = x when f′(x) = 0), and define depth_f(x) as the minimum number of Newton iterations to reach a fixed point. Then the number of elements x ∈ 𝔽_p with depth_f(x) = 0 and f′(x) ≠ 0 equals the number of 𝔽_p-rational roots of f, and more generally, the depth-k histogram {|{x : depth(x) = k}| : k ≥ 0} is determined by the cycle type of the Frobenius element Frob_p in the Galois group Gal(f/ℚ).

**Test**: Compute depth histograms for the polynomial f(x) = x⁵ − x − 1 (which has Galois group S₅) over all primes p < 10,000. Classify each prime by its Frobenius cycle type (computed via factorization of f mod p). Verify that primes with the same Frobenius cycle type produce the same depth histogram shape (up to a normalization by p). A single counterexample disproves the conjecture; agreement across all primes would be strong evidence.

**Impact**: If true, this would provide a new *dynamical* method for computing Frobenius elements, complementary to the standard factorization approach. It would also establish that Newton's method carries more arithmetic information than previously recognized — not just root counts, but full cycle-type data.

**Catalog References**: `Catalog/Algebra/CyclotomicGaloisGroup.lean` (Galois groups of cyclotomic polynomials), `Catalog/Algebra/IdempotentClosure/Basic.lean` (monotone closure stabilization)

**Proof Strategy**: Begin with cyclotomic polynomials x^n − 1 where the Frobenius cycle type is determined by the residue of p mod n. For these polynomials, the depth-0 count equals gcd(n, p−1) (the number of n-th roots of unity in 𝔽_p). Prove this count formula using the structure of (ℤ/nℤ)* and the isomorphism 𝔽_p* ≅ ℤ/(p−1)ℤ. Then extend to depth k > 0 by analyzing preimages of the Newton step. Key lemma needed: if x has depth k, then N_f(x) has depth k−1.

**Domain Bridges**: NumberTheory <-> Topology, Algebra <-> ArithmeticDynamics

**Lineage**: Builds on `newtonStep_fixed_iff_root` and `frobenius_depth_x2_minus_1` from this cycle. Extends the depth-0 analysis (which we fully verified) to arbitrary depth.

**Ambition**: grand_challenge

---

### Direction 2: Spectral Invariants of Newton Graphs

**Conjecture**: Let A_f(p) be the adjacency matrix of the Newton functional graph of f over 𝔽_p, viewed as a p × p matrix with A_f(p)_{xy} = 1 if N_f(x) = y and 0 otherwise. Define the *Newton spectral width* as the number of distinct eigenvalues of A_f(p). Then for a squarefree degree-d polynomial f, the Newton spectral width is bounded below by the number of distinct roots of f in 𝔽_p and above by p, and the spectral width modulo suitable normalization is an invariant of the Galois group of f.

**Test**: Compute the eigenvalues of A_f(p) for f(x) = x³ − 1 across primes p < 500. Plot the spectral width as a function of p. Test whether primes with the same number of roots (determined by p mod 3) have spectral width values that cluster. Specifically, primes p ≡ 1 (mod 3) should show a spectral width pattern distinct from p ≡ 2 (mod 3).

**Impact**: If spectral invariants encode Galois information beyond what persistence captures, this would establish a new bridge between spectral graph theory and arithmetic geometry. The adjacency matrix of a functional graph has special structure (every row has exactly one nonzero entry), which constrains its spectral theory in ways that could be exploited for efficient computation.

**Catalog References**: `Catalog/Algebra/CausalCertification.lean` (spectral_width_increases_with_primes), `Catalog/Algebra/SpectralArithmetic.lean`

**Proof Strategy**: The adjacency matrix of a functional graph is a permutation-like matrix. Its eigenvalues are n-th roots of unity where n divides the cycle lengths in the functional graph. Therefore, the spectrum is determined by the multiset of cycle lengths, which in turn relates to the orbit structure of the Newton step. Prove that the number of distinct cycle lengths provides a lower bound on the spectral width, then connect cycle lengths to the Frobenius cycle type via Direction 1.

**Domain Bridges**: SpectralTheory <-> NumberTheory, GraphTheory <-> Algebra

**Lineage**: Builds on `newtonStep_orbit_eventually_periodic` from this cycle and `spectral_width_increases_with_primes` from the Catalog.

**Ambition**: extension

---

### Direction 3: Persistent Chebotarev Density Theorem

**Conjecture**: Let f ∈ ℤ[X] be a monic irreducible polynomial of degree d with Galois group G = Gal(f/ℚ). For each conjugacy class C ⊆ G, define the *persistence signature* σ_C as the persistence diagram (viewed as a multiset of pairs) that arises from primes p with Frob_p ∈ C. Then:
(a) The persistence signature σ_C is well-defined (i.e., all primes in C give the same persistence diagram shape, appropriately normalized).
(b) The density of primes p ≤ N such that the persistence diagram of f mod p has signature σ_C converges to |C|/|G| as N → ∞.

**Test**: For f(x) = x⁴ − 2 (Galois group D₄ of order 8, with 5 conjugacy classes), compute persistence diagrams for all good primes p < 50,000. Cluster the diagrams by shape and verify that the cluster sizes converge to |C|/|G| for each conjugacy class C. The five predicted densities are 1/8, 1/4, 1/4, 1/4, 1/8 (corresponding to the identity, (12)(34), (1234), (13)(24), (24) conjugacy classes respectively).

**Impact**: This would be a topological generalization of the Chebotarev density theorem — one of the central results in algebraic number theory. The classical theorem says that each Frobenius conjugacy class occurs with the predicted density; the persistent version would say that the *Newton persistence diagram* determines the conjugacy class and occurs with the same density. This would establish persistent homology as a legitimate tool in analytic number theory.

**Catalog References**: `Catalog/Algebra/CyclotomicGaloisGroup.lean`, `Catalog/Algebra/IdempotentClosure/Basic.lean` (closure stabilization), `Catalog/Algebra/TropicalAnalyticDuality.lean`

**Proof Strategy**: The key is to show that the persistence diagram is a function of the Frobenius conjugacy class alone (part a), after which part (b) follows from the classical Chebotarev theorem. For part (a), use the fact that the Newton graph over 𝔽_p depends only on the reduction of f mod p, and two primes with the same Frobenius class have isomorphic reductions (up to automorphism). The challenge is formalizing "isomorphic reductions give isomorphic Newton graphs," which requires showing that the Newton step commutes with field automorphisms.

**Domain Bridges**: NumberTheory <-> Topology, AnalyticNumberTheory <-> PersistentHomology

**Lineage**: Builds on all results from this cycle, especially `newtonStep_fixed_point_set_eq_roots` (which proves the zeroth-order case: root count = fixed point count) and `newtonStep_orbit_eventually_periodic` (orbit structure).

**Ambition**: grand_challenge

---

### Direction 4: Tropical Newton Filtrations

**Conjecture**: The Newton depth filtration of a polynomial f over 𝔽_p admits a tropical-geometric interpretation: the depth of x ∈ 𝔽_p equals the minimum weight of a path from x to a root in the tropical Newton polygon of f, where weights are defined by p-adic valuations of the coefficients of iterates of the Newton step.

More precisely, define the tropical Newton map T_f : ℝ → ℝ by T_f(v) = v − val_p(f(x))/val_p(f′(x)) where x is any lift of the 𝔽_p-element with valuation v. The fixed points of T_f correspond to the slopes of the Newton polygon of f.

**Test**: For f(x) = x³ − p² (which has Newton polygon with a single slope of 2/3), compute both the tropical Newton depth and the actual Newton depth over 𝔽_p for small primes p. Verify that the tropical depth provides an upper bound on the actual depth. Find examples where the bound is tight.

**Impact**: A tropical interpretation would provide *combinatorial* control over the depth filtration, replacing case-by-case algebraic arguments with polygon geometry. This could make the Frobenius depth conjecture (Direction 1) amenable to proof, since tropical methods give explicit formulas for orbit structure.

**Catalog References**: `Catalog/Algebra/TropicalAnalyticDuality.lean` (tropical_order_eq_rank_via_LData), `Catalog/Algebra/TropicalBSDEquality.lean`, `Catalog/Computation/PadicValuationDepth.lean`

**Proof Strategy**: Start with the case of Eisenstein polynomials (f(x) = x^n − p^a) where the Newton polygon has a single slope and the tropical dynamics are one-dimensional. Prove that the tropical Newton step has a unique fixed point at the slope value, and that the tropical depth of a point equals the number of tropical Newton steps to reach this fixed point. Then generalize to polynomials with multiple slopes, where each slope creates a separate tropical basin.

**Domain Bridges**: TropicalGeometry <-> ArithmeticDynamics, Combinatorics <-> NumberTheory

**Lineage**: Builds on `tropical_order_eq_rank_via_LData` from the Catalog and connects to the p-adic valuation depth machinery in `PadicValuationDepth.lean`.

**Ambition**: extension

---

### Direction 5: Newton Persistence as Galois Group Classifier

**Conjecture**: There exists a polynomial-time algorithm that, given a polynomial f ∈ ℤ[X] of degree d ≤ 10, determines its Galois group over ℚ with probability ≥ 1 − ε by computing Newton persistence diagrams modulo O(log(1/ε)) random primes.

Specifically, define the *persistence feature vector* of f mod p as the sorted multiset of persistence values {death − birth} from the Newton persistence diagram. The persistence feature vectors for sufficiently many primes uniquely determine the Galois group among the finite list of transitive subgroups of S_d.

**Test**: Implement the classifier for degree-5 polynomials (where there are 5 possible Galois groups: S₅, A₅, D₅, F₂₀, ℤ/5ℤ). Generate 1000 random polynomials for each group, compute persistence features modulo 50 primes each, and measure classification accuracy using a simple nearest-neighbor classifier. Target: ≥ 95% accuracy.

**Impact**: Determining the Galois group of a polynomial is a fundamental problem in computational algebra. Current methods (e.g., resolvent polynomials, p-adic methods) have high complexity for large degrees. If persistence features suffice for classification, this would provide a practical, embarrassingly parallel algorithm: compute Newton steps modulo independent primes, extract persistence features, and classify.

**Catalog References**: `Catalog/Algebra/CyclotomicGaloisGroup.lean`, `Catalog/Algebra/GroupSolvability.lean`, `Catalog/Algebra/StochasticGalois.lean`

**Proof Strategy**: For the theoretical result, show that distinct Galois groups produce distinct *expected* persistence feature vectors (averaged over primes). By Chebotarev, the expected number of roots of f mod p equals d/|G| · |{g ∈ G : g fixes a root}|, which differs between non-conjugate subgroups. The persistence features refine this root-count information, so they have at least as much discriminating power. For the algorithm, use concentration inequalities to bound the number of primes needed for reliable classification.

**Domain Bridges**: Algebra <-> MachineLearning, NumberTheory <-> ComputationalComplexity

**Lineage**: Builds on all results from this cycle. Uses `newtonStep_fixed_iff_root` to connect fixed points to roots, `newtonStep_orbit_eventually_periodic` for orbit structure, and `newtonStep_product_at_root` for basin separation.

**Ambition**: extension
