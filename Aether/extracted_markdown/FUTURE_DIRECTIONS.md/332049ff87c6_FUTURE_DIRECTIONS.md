# Future Directions: L-Function Census

## Synthesis

This research cycle established that the invariant data of Selberg-class L-functions — triples (degree, conductor, spectral parameters) — possess rich combinatorial structure: a graded commutative monoid under the Rankin-Selberg product, additive spectral complexity, subadditive spectral entropy, and a well-founded factorization partial order. The conductor counting function N_d(Q, B) = Q · (2(2B+1))^d satisfies an exact multiplicative factorization identity N_{d₁+d₂}(Q,B) = N_{d₁}(1,B) · N_{d₂}(Q,B), connecting the algebraic product structure to the combinatorial enumeration. All 19 theorems were formally verified.

The most promising cross-domain connection is the bridge between **analytic number theory** and **combinatorial algebra/tropical geometry**. The spectral complexity function behaves like a tropical valuation (additive under products, non-negative integer values), suggesting that the monoid of Selberg data can be embedded into a tropical semiring. Meanwhile, the counting bound N_d(Q,B) ∝ Q · B^d echoes lattice-point counting in convex bodies, suggesting connections to the geometry of numbers and Ehrhart theory. The factorization ordering connects to existing Catalog work on order theory and well-founded structures.

The direction with highest breakthrough potential is **Direction 1** (density of realized data), because it bridges the abstract combinatorial framework to concrete number-theoretic content — determining *which* combinatorial fingerprints actually correspond to L-functions. This is where the Langlands program meets combinatorics. **Direction 2** (tropical spectral geometry) has the highest novelty potential, as it would establish a genuinely new connection between tropical mathematics and the Selberg class. **Direction 3** builds infrastructure for computational discovery.

---

### Direction 1: Density of Realized L-Function Data

**Conjecture**: Define the realization density R_d(Q, B) as the fraction of degree-d Selberg data with conductor ≤ Q and spectral shifts ≤ B that correspond to actual L-functions. For degree d = 1, R_1(Q, B) → C(B) · (6/π²) as Q → ∞, where C(B) encodes the proportion of primitive characters with spectral shift ≤ B, and 6/π² = 1/ζ(2) reflects the density of squarefree conductors.

**Test**: Compute R_1(Q, 0) for Q = 10, 100, 1000, 10000 by counting primitive Dirichlet characters of conductor ≤ Q and comparing to N_1(Q, 0) = 2Q. The ratio should approach 3/π² ≈ 0.3040 (since primitive characters with trivial spectral shift are essentially primitive characters mod q, which have density φ(q)/q → 6/π² on average, multiplied by the parity constraint).

**Impact**: If confirmed, this would be the first *quantitative* density result connecting the abstract combinatorial census to the actual landscape of L-functions. It would establish that roughly 30% of the degree-1 "slots" in the periodic table are actually occupied, with the vacancies corresponding to non-primitive or non-squarefree conductors. If false, it would reveal that the combinatorial framework over-counts in ways requiring structural refinement.

**Catalog References**: `Speculative/AutoResearch/LFunctionCensus/Theorems.lean` (conductorCount_degree_one), `Algebra/ArtinPrimitiveRoot.lean` (primitive root theory), `Speculative/AutoResearch/MahlerMeasure.lean` (lehmer_gap_degree_bounded_conjecture for connections to algebraic number theory)

**Proof Strategy**: 
1. Formalize the count of primitive Dirichlet characters mod q using Euler's totient function and inclusion-exclusion for primitivity.
2. Establish the asymptotic φ*(Q) := Σ_{q≤Q} φ*(q) ~ (3/π²)Q² using the Möbius function, where φ*(q) counts primitive characters.
3. Compare with N_1(Q, 0) = 2Q to extract the density.
4. Key lemmas needed: Mertens' estimates, summatory totient asymptotics, sieve bounds for squarefree numbers.

**Domain Bridges**: Analytic number theory (character theory, Mertens' estimates) <-> Combinatorial enumeration (counting functions, density) <-> Algebraic number theory (primitive characters, conductors)

**Lineage**: Builds on this cycle's counting function framework and the degree-1 specialization theorem. Extends toward connecting abstract fingerprints to concrete number-theoretic objects.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Spectral Geometry of the Selberg Monoid

**Conjecture**: The spectral complexity function χ: SelbergData → ℕ extends to a tropical valuation on the completion of the Selberg data monoid, and the "Newton polytope" of the generating function Σ_D t^{χ(D)} x^{d(D)} y^{q(D)} is a rational polyhedral cone in tropical ℝ³ whose face lattice encodes the factorization structure.

**Test**: Compute the generating function G(t, x) = Σ_{d≥0} Σ_{k≥0} N_d^{(k)} x^d t^k where N_d^{(k)} counts degree-d data with spectral complexity exactly k (and fixed conductor/spectral bound). Verify that G factors as a product over primitive spectral types, and that the tropical limit (t → 0⁺ in logarithmic coordinates) yields a polyhedral structure.

**Impact**: If true, this would establish a novel connection between tropical geometry and the Selberg class, providing geometric intuition for the distribution of spectral parameters. The face structure of the tropical polytope would encode which combinations of degree and spectral complexity are "extremal," potentially revealing new constraints on L-function data. If false, the obstruction would clarify the limits of tropical methods in analytic number theory.

**Catalog References**: `Speculative/AutoResearch/SpectralTropicalEntropy.lean` (tropical_spectral_entropy_bound), `Speculative/AutoResearch/Bridges/TropicalValuationFunctor.lean` (tropical_sort_complexity_bound), `Cryptography/TropicalQuadraticSieve.lean` (tropical_sieve_kernel_work_bound)

**Proof Strategy**:
1. Define the tropical semiring (ℝ ∪ {∞}, min, +) and the spectral valuation χ.
2. Show that χ is a monoid homomorphism to (ℕ, +), already proved in this cycle.
3. Define the generating function and compute its coefficients using the counting formula.
4. Analyze the Newton polytope using Ehrhart theory for the integer points in the region {(d, k) : k ≤ dB, d ≤ D}.
5. Key lemma: the number of spectral types of degree d and complexity k equals the number of partitions of k into d non-negative parts ≤ B.

**Domain Bridges**: Tropical geometry (valuations, Newton polytopes) <-> Analytic number theory (Selberg class, spectral data) <-> Combinatorics (integer partitions, lattice point counting)

**Lineage**: Builds on spectral complexity additivity and the tropical entropy bounds from previous Catalog work. Extends the tropical-number theory bridge.

**Ambition**: grand_challenge

---

### Direction 3: Computational Discovery of Primitive Spectral Types

**Conjecture**: The number of primitive spectral types of degree d with maximum shift ≤ B grows as Θ(B^{d-1}/(d-1)!) for large B, reflecting that "most" spectral shapes of degree d are decomposable.

**Test**: For d = 2, 3, 4 and B = 1, 2, ..., 20, enumerate all spectral types, check primitivity (cannot be expressed as a product of two types with positive degree), and plot the count against B^{d-1}/(d-1)!.

**Impact**: If confirmed, this establishes a "prime number theorem" for spectral types — most types are composite, and the primitive ones thin out polynomially. This would guide computational searches for new L-functions by focusing on the sparse set of primitive types. If false (e.g., if primitives are denser), it would suggest that the factorization structure is less constraining than expected.

**Catalog References**: `Speculative/AutoResearch/LFunctionCensus/Defs.lean` (SpectralType, isPrimitive), `Speculative/AutoResearch/LFunctionCensus/Theorems.lean` (complexity_prod, entropy_prod_le)

**Proof Strategy**:
1. Implement an enumeration algorithm for spectral types: sorted lists of non-negative integers ≤ B with length d.
2. Implement a compositeness test: check all partitions d = d₁ + d₂ with d₁, d₂ ≥ 1 and all ways to split the profile.
3. Count primitives and fit to the asymptotic B^{d-1}/(d-1)!.
4. For the upper bound, use the fact that the number of spectral types is the number of non-decreasing sequences in {0,...,B} of length d, which equals C(B+d, d), and the number of composite ones is at least the number of concatenations of shorter types.

**Domain Bridges**: Combinatorics (integer compositions, partition theory) <-> Computational number theory (enumeration algorithms) <-> Algebra (monoid factorization, unique factorization domains)

**Lineage**: Builds directly on this cycle's definitions of SpectralType and the product operation. Uses the complexity additivity theorem as a necessary condition for decomposability.

**Ambition**: extension

---

### Direction 4: Spectral Entropy Concentration for Automorphic Families

**Conjecture**: For the family of holomorphic newforms of weight k and level N → ∞ on GL(2), the spectral entropy H concentrates at H = 1 (all spectral parameters equal to (k-1)/2), while for Maass forms of eigenvalue λ → ∞, the spectral entropy H = 1 but the spectral complexity χ grows as √λ.

**Test**: Compute the spectral data for known GL(2) L-functions (weight-k newforms: spectral params are {(k-1)/2, (k-1)/2} with both parities, so complexity = k-1, entropy = 1; Maass forms with eigenvalue λ = 1/4 + r²: spectral params are {ir, -ir} rounded to integers, so complexity ≈ 2r, entropy = 1). Verify these predictions against tables of automorphic forms (LMFDB database).

**Impact**: If confirmed, this would show that the spectral entropy is essentially trivial for GL(2) families (always equal to 1), meaning the interesting spectral structure only emerges for GL(n) with n ≥ 3. This would redirect research toward higher-degree L-functions where entropy becomes a non-trivial invariant. If false, it would reveal unexpected spectral diversity in GL(2) families.

**Catalog References**: `Speculative/AutoResearch/SpectralTropicalEntropy.lean` (tropical_spectral_entropy_bound), `Speculative/AutoResearch/ThermodynamicClosureCore.lean` (fixed_point_entropy_upper_bound)

**Proof Strategy**:
1. Formalize the spectral parameters of GL(2) L-functions: for holomorphic weight k, params are ((k-1)/2, 0) and ((k-1)/2, 1); for Maass eigenvalue 1/4+r², params are (⌊r⌋, 0) and (⌊r⌋, 1).
2. Compute complexity and entropy directly from these formulas.
3. For the concentration result, use the fact that both params have the same absolute shift, so entropy = 1 identically.
4. For complexity growth in the Maass case, use Weyl's law to relate eigenvalue to shift.

**Domain Bridges**: Automorphic representation theory (spectral theory of modular forms) <-> Combinatorial invariants (entropy, complexity) <-> Analytic number theory (Weyl's law, eigenvalue statistics)

**Lineage**: Builds on the spectral entropy subadditivity theorem and the SpectralType framework. Connects to existing spectral theory in the Catalog.

**Ambition**: extension

---

### Direction 5: Möbius Inversion on the Factorization Poset

**Conjecture**: The Möbius function of the factorization poset on degree-conductor pairs (d, q) with d ≤ D, q ≤ Q factors as μ_fact((d₁,q₁), (d₂,q₂)) = μ_nat(d₂-d₁) · μ_div(q₁, q₂), where μ_nat is the Möbius function of the natural numbers under ≤ (which is 1 if d₂-d₁ = 0, -1 if d₂-d₁ = 1, 0 otherwise) and μ_div is the Möbius function of the divisibility lattice.

**Test**: Compute the Möbius function explicitly for the poset of pairs (d, q) with d ≤ 3, q ≤ 12. Verify that it factors as claimed by comparing with the product of the two individual Möbius functions. The degree factor should give the "finite difference" operator (values 1, -1, 0, ...) and the conductor factor should give the classical number-theoretic Möbius function μ(q₂/q₁).

**Impact**: If true, this factorization would enable efficient Möbius inversion on the factorization poset, allowing us to count primitive data by inclusion-exclusion from the total count. The formula P_d(Q,B) = Σ_{k|d, k≤d} μ(d/k) · N_k(Q,B) would give primitive counts in closed form. If false, the Möbius function has a more complex structure reflecting interactions between degree and conductor that don't decouple.

**Catalog References**: `Speculative/AutoResearch/LFunctionCensus/Defs.lean` (DegreeConductor, conductorMoebius from earlier draft), `Algebra/ArithmeticDarkMatter.lean` (arithmetic structure)

**Proof Strategy**:
1. Formalize the factorization poset as a product of two posets: (ℕ, ≤) and (ℕ⁺, |).
2. Prove that the Möbius function of a product poset is the product of the Möbius functions (Philip Hall's theorem for product posets).
3. Compute the Möbius function of (ℕ, ≤) explicitly: μ(m,n) = 1 if m=n, -1 if m=n-1, 0 otherwise.
4. Identify the Möbius function of (ℕ⁺, |) with the classical μ function.
5. Combine to get the factored formula.

**Domain Bridges**: Order theory (Möbius functions on posets, incidence algebras) <-> Analytic number theory (classical Möbius function, sieve methods) <-> Combinatorics (inclusion-exclusion, lattice theory)

**Lineage**: Builds on the factorization order defined in this cycle and the DegreeConductor partial order theorems. Extends toward a full incidence algebra on the Selberg data poset.

**Ambition**: extension
