# Future Directions: Cryptography from Dynamical Systems Irreversibility

## Synthesis

This cycle established the mathematical foundations for treating the Collatz map as a cryptographic one-way function, proving three core properties (forward efficiency, exponential preimage witnesses, and pigeonhole collisions) in a machine-verified framework. The most significant discovery is the complete characterization of the "all-even" preimage path: 2^a · v always maps to v in exactly a steps, providing a concrete witness that the search space for inversion grows exponentially. The collision structure theorem — showing that collisions at depth a+1 decompose into "local" (same successor) or "deep" (converging successors) components — opens a path toward formal collision resistance analysis.

The most promising cross-domain connection is between dynamical systems theory and computational complexity. The Collatz preimage tree is not merely a cryptographic abstraction but a genuine mathematical object whose branching statistics encode information about the mixing properties of the Collatz map. Connecting the branching factor to ergodic-theoretic quantities (Lyapunov exponents, measure-theoretic entropy) would establish a bridge between the dynamical systems catalog (`Catalog/Computation/`) and cryptographic security (`Catalog/Cryptography/`). This is the direction with the highest breakthrough potential: if the average branching factor can be shown to exceed 1 + ε for some ε > 0, it would imply sub-exponential preimage density — a quantitative one-way function result.

The work also connects naturally to the tropical cryptography line (`Catalog/Cryptography/TropicalOneWayFoundations.lean`, `TropicalPostQuantum.lean`) through the shared structure of "forward-easy, backward-hard" iterated maps. The Collatz map can be viewed as a piecewise-affine map over ℕ, analogous to tropical polynomial evaluation. Formalizing this analogy could unify the two cryptographic families under a common framework.

---

### Direction 1: Ergodic Theory of Collatz Preimage Trees

**Conjecture**: The average branching factor of the Collatz preimage tree at depth d converges to 4/3 as d → ∞. More precisely, if B(v, d) denotes the number of nodes at depth d in the preimage tree rooted at v > 0, then for "typical" v (avoiding small multiples of powers of 2), B(v, d) ∼ (4/3)^d.

**Test**: Compute B(v, d) for v ∈ {7, 11, 13, 17, 19, 23} and d ∈ {1, ..., 20}. Fit log B(v, d) vs d to estimate the growth rate. If the slope is consistently near log(4/3) ≈ 0.288, the conjecture is supported. If the slope varies significantly across v or stabilizes elsewhere, the conjecture is falsified.

**Impact**: If true, this implies the preimage density decays as (3/4)^d, proving quantitative one-wayness: an adversary searching for a preimage at depth d must examine at least (3/4)^{-d} ≈ 1.33^d candidates, an exponential lower bound. This would be the first rigorous connection between Collatz dynamics and computational hardness.

**Catalog References**: `Catalog/Cryptography/CohomologicalCrypto/Foundation.lean` (CertifiedOWF structure), `Catalog/Computation/PadicValuationDepth.lean` (ValuationDepthMeasure — related depth complexity measure)

**Proof Strategy**: 
1. Define the branching indicator function: β(n) = 1 if n has exactly one preimage (2n), β(n) = 2 if n also has an odd preimage (n ≡ 1 mod 3 and (n-1)/3 odd).
2. Prove β(n) = 2 iff n ≡ 4 (mod 6) (the exact condition for odd-branch existence).
3. Show that among {1, ..., N}, exactly N/3 + O(1) values satisfy β(n) = 2.
4. Average branching factor = (2/3 · 1 + 1/3 · 2) = 4/3.
5. Apply equidistribution results to show typical preimage trees realize this average.

**Domain Bridges**: NumberTheory <-> Cryptography, DynamicalSystems <-> Cryptography

**Lineage**: Builds on `CollatzOWF.preimage_tree_min_branch` and `CollatzOWF.odd_preimage` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Quantum Resistance of Collatz Inversion

**Conjecture**: The Collatz inversion problem — given (a, T^a(n)), find n — cannot be solved in O(poly(a)) quantum queries to T, i.e., it requires Ω(2^{a/2}) quantum queries. This would match the generic Grover lower bound, confirming that the Collatz map's non-algebraic structure prevents Shor-type speedups.

**Test**: Formalize a quantum query model for the Collatz map. Prove that no quantum algorithm with q queries can distinguish T^a(n₀) from a random value with advantage better than O(q² / 2^a). This is equivalent to showing the Collatz OWF is a quantum-secure pseudorandom generator when a is the security parameter.

**Impact**: If true, this would establish the first dynamical-systems-based post-quantum cryptographic primitive, complementing lattice-based (LWE) and code-based (McEliece) approaches. If false — if a polynomial quantum algorithm exists — it would reveal exploitable algebraic structure in Collatz orbits, a breakthrough in number theory.

**Catalog References**: `Catalog/Cryptography/CohomologicalCrypto/Foundation.lean` (PostQuantumCertificate, quantum_query_lower_bound), `Catalog/Cryptography/TropicalPostQuantum.lean` (tropical_key_space_exponential)

**Proof Strategy**:
1. Define a quantum query oracle for the Collatz step function.
2. Show that Collatz composition T^a is a unitary-implementable function (standard for classical functions).
3. Prove that the Collatz map has no exploitable period structure (unlike modular exponentiation, which has period-finding via Shor).
4. Apply the BBBV theorem (Bennett et al., 1997) to get the Ω(2^{a/2}) lower bound for unstructured search.
5. The key step is proving "unstructured-ness": no polynomial-size quantum circuit can approximate the inverse of T^a.

**Domain Bridges**: Cryptography <-> QuantumComputation, NumberTheory <-> QuantumComputation

**Lineage**: Builds on `CollatzOWF.search_space_exponential` and the quantum_query_lower_bound from the Catalog.

**Ambition**: grand_challenge

---

### Direction 3: Tropical-Collatz Unification

**Conjecture**: The Collatz map T(n) can be embedded as a special case of a tropical polynomial evaluation map over ℕ, where the min-plus semiring operations model the piecewise definition. Specifically, there exists a tropical polynomial P over ℕ such that P(n) = T(n) for all n > 0, and the one-way function properties of T follow from general tropical OWF theorems.

**Test**: Define the tropical embedding explicitly: T(n) = min(n/2, 3n+1) where the "min" selects the branch based on parity (this requires a modified tropical framework incorporating parity predicates). Verify computationally that the embedding preserves preimage structure for n up to 10^6. Then prove that the tropical collision bound (from `tropical_hash_collision_bound`) applies to the embedded Collatz hash.

**Impact**: If true, this would unify two independent cryptographic families (Collatz-based and tropical-based) under a common algebraic framework, enabling transfer of security results between them. The tropical framework's algebraic tractability could provide proof techniques unavailable in the raw number-theoretic setting.

**Catalog References**: `Catalog/Cryptography/TropicalOneWayFoundations.lean` (tropical_hash_collision_bound), `Catalog/Cryptography/TropicalMinPlusOWF.lean` (tropical_key_space_exponential), `Catalog/Cryptography/TropicalPostQuantumPrimitives.lean` (tropical_exponential_hardness)

**Proof Strategy**:
1. Define a "parity-augmented tropical semiring" extending the min-plus semiring with a parity bit.
2. Embed the Collatz step as a tropical polynomial in this extended semiring.
3. Show that the tropical preimage bound transfers: if tropical inversion requires exponential time, so does Collatz inversion.
4. Apply `tropical_hash_collision_bound` to the embedded Collatz hash.

**Domain Bridges**: Tropical <-> Cryptography, Algebra <-> NumberTheory

**Lineage**: Builds on `CollatzOWF.collatzHash_lt_mod` from this cycle and the tropical cryptography catalog.

**Ambition**: extension

---

### Direction 4: Tight Preimage Counting and Image Compression Rates

**Conjecture**: The image compression ratio r(a, B) = |Im(a, B)| / B satisfies r(a, B) ∼ C · a^{-α} for constants C, α > 0 as a → ∞ with B fixed. Computational experiments suggest α ≈ 0.5, consistent with the heuristic that after a iterations, about B/√a distinct images remain.

**Test**: Compute r(a, B) for B = 10000 and a ∈ {1, 2, 5, 10, 20, 50, 100, 200}. Fit log r(a, B) vs log a to estimate α. If α is stable across different B values, the conjecture is supported. If r(a, B) decays faster or slower than any power law, the functional form is wrong.

**Impact**: A precise compression rate directly translates to collision probability bounds. If r(a, B) ∼ C/√a, then the expected number of collision pairs is B²(1 - C/√a)/2, giving precise security parameters for the Collatz hash at any iteration depth.

**Catalog References**: `Catalog/Cryptography/CollatzOWF.lean` (image_compression, pigeonhole_collisions)

**Proof Strategy**:
1. Count even vs odd values in Im(a, B) using the parity statistics of Collatz orbits.
2. Use the heuristic that even/odd transitions are roughly equiprobable (Lagarias's "stochastic Collatz" model).
3. Under this model, the image size after a iterations follows a random walk absorption process.
4. Formalize the connection between absorption time and image compression.

**Domain Bridges**: Cryptography <-> Probability, NumberTheory <-> DynamicalSystems

**Lineage**: Builds on `CollatzOWF.image_compression` and `CollatzOWF.preimage_density_le` from this cycle.

**Ambition**: extension

---

### Direction 5: Generalized Dynamical OWFs: The (p, q) Map Family

**Conjecture**: For the generalized Collatz map T_{p,q}(n) = n/q if q|n, pn+1 otherwise, the function f_a(n) = T_{p,q}^a(n) is a one-way function candidate whenever p > q ≥ 2 and gcd(p, q) = 1. Furthermore, the preimage tree branching factor is (q+1)/q for arbitrary (p, q) (generalizing the Collatz 4/3 conjecture for (p,q) = (3,2)).

**Test**: Implement T_{p,q} for (p,q) ∈ {(3,2), (5,2), (5,3), (7,2), (7,3), (7,5)}. For each, compute the image compression ratio and preimage tree branching statistics for a ∈ {1, ..., 30}. Verify that the exponential preimage witness generalizes: q^a · v maps to v in a steps. If any (p,q) pair yields polynomial-time inversion, the family conjecture is falsified for that pair.

**Impact**: A parameterized family of one-way function candidates would provide cryptographic key diversity — different deployments could use different (p,q) pairs, reducing systemic risk. The family structure could also illuminate which arithmetic properties of T drive computational hardness.

**Catalog References**: `Catalog/Cryptography/CohomologicalCrypto/Foundation.lean` (CertifiedOWF), `Catalog/Cryptography/PostIdempotentCrypto.lean` (security_gap_exponential)

**Proof Strategy**:
1. Define T_{p,q} in Lean and prove the even preimage theorem: T_{p,q}(q·n) = n for n > 0.
2. Prove the exponential witness: T_{p,q}^a(q^a · v) = v by induction.
3. Prove the composition theorem: T_{p,q}^{a+b} = T_{p,q}^a ∘ T_{p,q}^b.
4. Analyze branching: T_{p,q} has a "divisible" preimage (q·n) and potentially additional preimages from the pn+1 branch.
5. Count the fraction of n with multiple preimages to derive the average branching factor.

**Domain Bridges**: NumberTheory <-> Cryptography, DynamicalSystems <-> Algebra

**Lineage**: Directly generalizes all results from `CollatzOWF.lean` in this cycle.

**Ambition**: extension
