# Future Directions: Discriminant Uniformity and Stochastic Galois Theory

## Synthesis

This research cycle established three interconnected results about quadratic polynomials over finite fields. First, the **Discriminant Uniformity Theorem** (Theorem `disc_fiber_card`): for any prime p, the map (b,c) ↦ b² − 4c has perfectly uniform fibers of size p. Second, exact formulas for splitting type distributions: among p² monic quadratics over 𝔽_p, exactly p(p−1)/2 are split, p are ramified, and p(p−1)/2 are inert. Third, the formal connection between splitting types and Frobenius cycle types for degree 2.

The most promising cross-domain connection emerging from this cycle is between **algebraic fiber counting** (the uniformity theorem) and **probabilistic convergence** (splitting type fractions → random permutation statistics). The uniformity theorem provides the engine: because fibers are uniform, counting reduces to counting discriminant values of each type (zero, square, non-square), which is classical. This strategy should generalize to cubics when the underlying polynomial map has appropriate bijectivity properties — and our computational investigation reveals this holds exactly when p ≡ 2 (mod 3). The cycle also uncovered a concrete failure mode: the cubic discriminant is NOT uniform for p ≡ 1 (mod 3), providing a falsifiable prediction about which primes admit uniform fiber structures.

The highest breakthrough potential lies in Direction 1 (Cubic Splitting over p ≡ 2 mod 3), because formalizing the cubic case would be the first machine-verified instance of the polynomial-to-permutation dictionary beyond degree 2. Direction 3 (the mod-3 obstruction) has high theoretical value because it connects to the structure of the multiplicative group 𝔽_p* and the distribution of n-th power residues. Both connect to the Catalog's algebraic infrastructure via `Algebra/Advanced.lean` and the Bridges domain via cross-domain results.

---

### Direction 1: Cubic Splitting Type Distribution over 𝔽_p for p ≡ 2 (mod 3)

**Conjecture**: For a prime p ≡ 2 (mod 3), the depressed cubic discriminant map (b,c) ↦ −(4b³ + 27c²) from 𝔽_p² → 𝔽_p has every fiber of cardinality exactly p. Consequently, the splitting type distribution of depressed cubics x³ + bx + c over 𝔽_p has:
- Type [1,1,1] (three distinct roots): count = p · (number of d ∈ 𝔽_p* where d is a square and has three cube roots of d/(-4) in 𝔽_p)
- Type [2,1] (one root + irreducible quadratic factor): determined by remaining residues
- Type [3] (irreducible cubic): count = p · (number of non-cubes among appropriate residue set)

**Test**: Verify computationally for all primes p < 500 with p ≡ 2 (mod 3) that the cubic discriminant map has uniform fibers of size p. Then prove the uniformity formally using the fact that x ↦ x³ is bijective on 𝔽_p* when p ≡ 2 (mod 3) (since gcd(3, p−1) = 1).

**Impact**: Would establish the first formally verified cubic splitting type result, opening the door to the full Frobenius correspondence for degree 3. This bridges algebra (polynomial factorization) with combinatorics (cycle types in S₃) and probability (convergence to random permutation statistics).

**Catalog References**: `Algebra/Advanced.lean`, `Bridges/AlgebraEMLClosureComputation.lean`

**Proof Strategy**: 
1. Prove that x ↦ x³ is bijective on 𝔽_p* when gcd(3, p−1) = 1
2. Use this to show (b,c) ↦ (b, −4b³ − 27c²) is a bijection when both 4 and 27 are units and the cube map is bijective
3. Derive fiber uniformity analogously to the quadratic case
4. Count cubic splitting types using cubic residue theory

**Domain Bridges**: Algebra (polynomial factorization) ↔ Computation (efficient classification algorithms) ↔ EML (complexity of splitting type computation)

**Lineage**: Direct extension of `disc_fiber_card` and `four_isUnit_of_odd_prime` from this cycle. Uses the same fiber-counting strategy but requires cubic residue theory.

**Ambition**: grand_challenge

---

### Direction 2: Chebotarev Density as the Infinite-Prime Limit

**Conjecture**: The splitting type distribution of monic degree-n polynomials over 𝔽_p, as p → ∞, converges to the cycle type distribution of random permutations in Sₙ. Formally: for each partition λ of n,

    lim_{p → ∞} |{f ∈ 𝔽_p[x] monic degree n : splitting type = λ}| / pⁿ = |{σ ∈ Sₙ : cycle type = λ}| / n!

This is the finite-field analog of the Chebotarev density theorem.

**Test**: Verify computationally for n = 2, 3, 4 and primes p up to 100 that the splitting type fractions approach the random permutation fractions. For n = 2, we proved this exactly: split fraction = (p−1)/(2p) → 1/2, which matches P(identity in S₂) = 1/2.

**Impact**: A formal proof would provide the first machine-verified instance of the polynomial-to-permutation convergence principle. This is a key step toward formalizing the Katz-Sarnak philosophy.

**Catalog References**: `Algebra/Advanced.lean`, `Computation/InfoEfficientAlgorithms.lean`

**Proof Strategy**:
1. For each partition λ of n, express the count of polynomials with splitting type λ in terms of:
   - The number of n-th power residues of various types
   - Fiber sizes of discriminant-like maps
2. Show these counts have leading term pⁿ · (|{σ ∈ Sₙ : cycle type λ}| / n!)
3. The error term is O(p^{n-1/2}) by the Weil bound

**Domain Bridges**: Algebra (splitting types) ↔ EML (ensemble complexity of classification) ↔ Computation (algorithms for counting)

**Lineage**: Extends `disc_fiber_card`, `nonsquare_count`, and the splitting type distribution from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: The Mod-3 Obstruction and n-th Power Residue Fiber Theory

**Conjecture**: For a polynomial map Φ: 𝔽_p^k → 𝔽_p of the form Φ(x₁, ..., xₖ) = Σᵢ aᵢ · xᵢⁿⁱ (a "diagonal" polynomial), the fiber |Φ⁻¹(d)| = p^{k-1} for all d ∈ 𝔽_p if and only if gcd(nᵢ, p−1) = 1 for all i. When some gcd(nᵢ, p−1) > 1, the fiber sizes vary and can be computed in terms of the number of nᵢ-th roots of certain elements.

For the quadratic discriminant b² − 4c, we have n₁ = 2 and n₂ = 1. Since gcd(1, p−1) = 1 always holds and gcd(2, p−1) = 2 for odd p, the naive criterion fails — but uniformity still holds because the "mixed" structure (b² − 4c rather than b² + c) compensates. The precise condition for uniformity of a mixed polynomial map requires analyzing the full fiber structure, not just the individual degree conditions.

**Test**: For diagonal maps aX^n + bY^m over 𝔽_p, compute fiber sizes for various (n, m, p) triples and determine the exact uniformity condition.

**Impact**: Would provide a general theory of when polynomial maps have uniform fibers, subsuming both the quadratic (always uniform) and cubic (conditionally uniform) discriminant results. This connects to the Lang-Weil theorem and the theory of exponential sums.

**Catalog References**: `Algebra/Advanced.lean`, `Cryptography/BerggrenDiophantineLattice.lean`

**Proof Strategy**:
1. Define "diagonal polynomial map" formally
2. Prove that X^n has uniform fibers (all of size gcd(n, p−1)) when restricted to 𝔽_p*
3. Derive fiber sizes for sums of power maps using character sum estimates
4. Specialize to recover the quadratic and cubic discriminant results

**Domain Bridges**: Algebra (power residues) ↔ Cryptography (discrete log structure) ↔ Computation (exponential sum algorithms)

**Lineage**: Motivated by the failure of cubic uniformity at p ≡ 1 (mod 3) discovered in this cycle. Extends `disc_fiber_card`.

**Ambition**: extension

---

### Direction 4: Formal Frobenius Correspondence for Degree 3

**Conjecture**: For a separable cubic f over 𝔽_p with Galois group G ≤ S₃, the splitting type of f equals the cycle type of the Frobenius element Frob_p ∈ G. For cubics over 𝔽_p, the Galois group is cyclic (always Z/1Z, Z/2Z, or Z/3Z), and the Frobenius correspondence gives:
- Splitting type [1,1,1] ↔ Frob = id ∈ G (trivial Galois group)
- Splitting type [2,1] ↔ Frob has order 2 in G ≅ Z/2Z
- Splitting type [3] ↔ Frob has order 3 in G ≅ Z/3Z

**Test**: For each cubic f(x) = x³ + bx + c over 𝔽_p (p = 5, 7, 11, 13), compute the splitting type and the Frobenius element, verifying they match.

**Impact**: Would be the first formal proof of the Frobenius correspondence for cubics, a key ingredient in the theory of Artin L-functions. This bridges finite field arithmetic with Galois theory and representation theory.

**Catalog References**: `Bridges/AlgebraEMLClosureComputation.lean`, `Algebra/Advanced.lean`

**Proof Strategy**:
1. Define the splitting field of a cubic over 𝔽_p (it's 𝔽_{p^k} for k = lcm of factor degrees)
2. Define the Frobenius automorphism x ↦ x^p on the splitting field
3. Show the Frobenius acts on roots with cycle type matching the splitting type
4. This requires the formal theory of finite field extensions in Mathlib

**Domain Bridges**: Algebra (Galois theory) ↔ Computation (polynomial factorization algorithms) ↔ Cryptography (elliptic curve point counting via Frobenius)

**Lineage**: Extends `splitTypeToCyclePartition` and `cycle_partition_sum` from this cycle. Requires formal finite field extension theory.

**Ambition**: extension

---

### Direction 5: Discriminant Uniformity for Multivariate Affine Maps

**Conjecture**: Let L: 𝔽_p^n → 𝔽_p be any affine-linear map (i.e., L(x) = a₁x₁ + ... + aₙxₙ + b where some aᵢ ≠ 0). Then every fiber of L has cardinality p^{n-1}. More generally, for a polynomial map P: 𝔽_p^n → 𝔽_p that is "affine-linear in at least one variable" (i.e., for some variable xᵢ, P is of the form f(x₁,...,x̂ᵢ,...,xₙ) · xᵢ + g(x₁,...,x̂ᵢ,...,xₙ) where f is never zero), every fiber of P has cardinality p^{n-1}.

The quadratic discriminant b² − 4c is affine-linear in c (with linear coefficient −4 ≠ 0), explaining its uniformity.

**Test**: Implement and verify for random polynomial maps of the required form over 𝔽_p for p = 3, 5, 7, 11.

**Impact**: Would provide a general principle explaining why many natural polynomial maps in number theory have uniform fibers, unifying the quadratic discriminant result with other fiber-counting theorems.

**Catalog References**: `Algebra/Advanced.lean`, `Bridges/AlgebraEMLPhysics/FilteredClosureReconstruction.lean`

**Proof Strategy**:
1. Prove the affine-linear case directly: for fixed values of all variables except xᵢ, the map xᵢ ↦ L(x) is a bijection
2. Sum over all choices of the other variables to get fiber size = p^{n-1}
3. For the polynomial generalization, reduce to the affine-linear case by the condition on f

**Domain Bridges**: Algebra (linear algebra over finite fields) ↔ Computation (counting algorithms) ↔ EML (information-theoretic uniformity)

**Lineage**: Direct generalization of `disc_fiber_card_odd`. The proof strategy (fix all variables but one, show bijectivity) is the same.

**Ambition**: extension
