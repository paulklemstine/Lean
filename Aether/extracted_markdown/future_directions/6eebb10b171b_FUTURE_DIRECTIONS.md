# Future Directions: Stochastic Galois Theory

## Synthesis

This research cycle established the **Discriminant Uniformity Theorem** for quadratic polynomials over finite fields: the map (b, c) ↦ b² − 4c from 𝔽_p² to 𝔽_p has every fiber of cardinality exactly p. This seemingly simple result has deep consequences: it gives the exact distribution of quadratic discriminants, the separability density (1 − 1/p), and the irreducibility fraction ((p−1)/(2p) → 1/2). Crucially, we corrected a false conjecture: over finite fields, the Galois group of a random polynomial is **never** the full symmetric group Sₙ for n ≥ 3 (since all Galois groups over finite fields are cyclic). The correct analog of Hilbert's irreducibility theorem involves the splitting type (a partition recording irreducible factor degrees), which connects to permutation cycle types via the Frobenius correspondence.

The most promising cross-domain connection is between the **splitting type distribution** (algebra) and **random permutation statistics** (combinatorics/probability). The Frobenius correspondence — splitting types of polynomials over 𝔽_q mirror cycle types of random permutations — is a gateway to the Katz-Sarnak philosophy connecting function field arithmetic to random matrix theory. Formalizing this correspondence would bridge the Algebra, Computation, and EML catalog domains. The highest breakthrough potential lies in Direction 1 (formalizing the Frobenius correspondence for degree 3) because it would be the first machine-verified instance of the polynomial-to-permutation dictionary.

A secondary insight is that the "uniformity" of the discriminant map generalizes: any affine-linear polynomial map 𝔽_p^n → 𝔽_p has exactly equal fibers. This structural principle (Direction 3) connects to coding theory and the Lang-Weil theorem, opening a path to formalizing fiber-counting results for arbitrary polynomial maps over finite fields.

---

### Direction 1: Cubic Splitting Type Distribution Over Finite Fields

**Conjecture**: For monic cubics x³ + ax² + bx + c over 𝔽_p, the number of polynomials with each splitting type satisfies:
- Type [3] (irreducible): exactly (p³ − p)/3
- Type [2,1] (one linear, one quadratic factor): exactly p(p² − 1)/2
- Type [1,1,1] (fully split): exactly (p³ + 2p)/6 for p ≡ 1 mod 6, with similar but distinct formulas for other residues

These counts should sum to p³ (the total number of monic cubics) and converge to the Sₙ cycle-type probabilities (1/3, 1/2, 1/6) as p → ∞.

**Test**: Enumerate all p³ monic cubics over 𝔽_p for p = 5, 7, 11, 13. Compute the splitting type of each using distinct-degree factorization. Verify the counts match the formula. Specifically, verify that the irreducible count equals (p³ − p)/3 (this is known by the necklace formula, but the other counts need verification).

**Impact**: This would be the first formalized proof connecting polynomial factorization statistics to permutation cycle-type statistics. It opens the door to formalizing the Frobenius density theorem and the Chebotarev density theorem in the function field setting.

**Catalog References**: `Geometry/StochasticGalois.lean` (SplittingType definition, discriminant uniformity), `Algebra/Basic.lean`

**Proof Strategy**:
1. Formalize the distinct-degree factorization of polynomials over finite fields.
2. Count polynomials of each splitting type using inclusion-exclusion: type [1,1,1] = polynomials with 3 roots in 𝔽_p; type [2,1] = polynomials with exactly one root; type [3] = irreducible.
3. For the irreducible count, use the Möbius inversion formula: I(3,p) = (1/3)(p³ − p).
4. Key lemma: the number of monic cubics with at least one root in 𝔽_p, counted with multiplicity, is p · p² = p³, but distinct-root counting requires inclusion-exclusion.

**Domain Bridges**: Algebra (polynomial factorization) <-> Combinatorics (permutation cycle types) <-> Number Theory (Chebotarev density)

**Lineage**: Builds on this cycle's SplittingType definition, discFiber_card_eq, and the Frobenius correspondence discussion.

**Ambition**: grand_challenge

---

### Direction 2: Discriminant Uniformity for General Affine Polynomial Maps

**Conjecture**: Let F: 𝔽_p^n → 𝔽_p be a polynomial map of the form F(x₁, ..., xₙ) = g(x₁, ..., xₙ₋₁) − α · xₙ where α ∈ 𝔽_p* is a unit and g is any polynomial. Then every fiber of F has cardinality p^{n-1}. More generally, if F is a polynomial map and F is a "fibration" (surjective with geometrically irreducible generic fiber), then |F⁻¹(d)| = p^{n-1} + O(p^{(n-1)/2}) by the Lang-Weil theorem, but the exact equality |F⁻¹(d)| = p^{n-1} holds if and only if F is affine-linear in at least one variable.

**Test**: For n = 3, define F(a, b, c) = a²b² − 4b³ − 4a³c + 18abc − 27c² (the cubic discriminant). Compute fiber sizes for p = 5, 7, 11. Verify they are NOT all equal (since the cubic discriminant is nonlinear in every variable), but satisfy |F⁻¹(d)| = p² + O(p) by Lang-Weil.

**Impact**: A formal characterization of when polynomial maps have exactly uniform fibers would unify discriminant analysis across all degrees and provide a clean criterion for when exact counting (as opposed to asymptotic) is possible.

**Catalog References**: `Geometry/StochasticGalois.lean` (discFiber_card_eq proves the n=2 case)

**Proof Strategy**:
1. Prove the "affine-linear implies uniform fibers" direction: if F(x₁,...,xₙ) = g(x₁,...,xₙ₋₁) + αxₙ with α a unit, then for each choice of (x₁,...,xₙ₋₁), there is exactly one xₙ satisfying F = d.
2. For the converse, find a counterexample: a map that is not affine-linear in any variable but has uniform fibers.
3. Investigate the Lang-Weil error term for specific discriminant maps.

**Domain Bridges**: Algebra (polynomial maps) <-> Geometry (algebraic varieties, fiber dimension) <-> Coding Theory (weight distributions)

**Lineage**: Direct generalization of this cycle's discriminant uniformity theorem.

**Ambition**: extension

---

### Direction 3: Squarefree Density and Polynomial Sieving

**Conjecture**: The fraction of monic degree-n polynomials over 𝔽_q that are squarefree is exactly 1 − 1/q for all n ≥ 2 and all prime powers q. Moreover, this can be proved by a "polynomial sieve" analogous to the integer sieve: a monic polynomial f is not squarefree iff it is divisible by g² for some irreducible g of degree d ≤ n/2, and inclusion-exclusion gives the exact count.

**Test**: Enumerate monic polynomials of degrees 2, 3, 4 over 𝔽_p for p = 2, 3, 5, 7 and count squarefree ones. Verify the fraction equals 1 − 1/p in all cases.

**Impact**: The squarefree density theorem is foundational for analytic number theory in function fields. A formal proof would connect to sieve theory and the function field Riemann hypothesis. The result is classical but not yet formalized.

**Catalog References**: `Geometry/StochasticGalois.lean` (separable_quadratic_card proves the n=2 case for separability, which equals squarefreeness for polynomials)

**Proof Strategy**:
1. Define squarefree polynomials in Lean: `Squarefree f ↔ ∀ g, g^2 ∣ f → IsUnit g`.
2. Key lemma: f is squarefree iff gcd(f, f') = 1 (where f' is the formal derivative).
3. Count: the map f ↦ gcd(f, f') from degree-n monics to lower-degree polynomials. The non-squarefree polynomials are those where gcd(f, f') has degree ≥ 1.
4. The derivative map f ↦ f' on monic degree-n polynomials is a specific linear map; analyze its kernel and image to get exact counts.

**Domain Bridges**: Algebra (polynomial GCD) <-> Number Theory (sieve methods) <-> Computation (GCD algorithms)

**Lineage**: Extends this cycle's separability analysis from n=2 to arbitrary degree.

**Ambition**: extension

---

### Direction 4: Random Polynomial Galois Groups Over Function Fields

**Conjecture**: Over the rational function field 𝔽_p(t), random monic polynomials of degree n (with coefficients that are polynomials in t of bounded degree D) have Galois group Sₙ with probability approaching 1 as D → ∞ (for fixed p and n). This is the function field analog of Hilbert's irreducibility theorem, and unlike the finite field case, the full symmetric group CAN arise because 𝔽_p(t) has non-cyclic extensions.

**Test**: For n = 3, p = 5, D = 2, enumerate monic cubics in 𝔽_5(t)[x] with coefficients of degree ≤ 2 and compute Galois groups over 𝔽_5(t). Verify that the fraction with Gal = S₃ is close to 1.

**Impact**: This would establish the correct setting for "generic Galois groups" over finite-characteristic fields, resolving the tension between Hilbert's theorem (Gal = Sₙ is generic over Q) and the cyclic constraint (Gal is always cyclic over 𝔽_p). Function fields are the natural intermediate case.

**Catalog References**: `Geometry/StochasticGalois.lean` (SplittingType, corrected conjecture discussion)

**Proof Strategy**:
1. Use the geometric formulation: a polynomial f(x) ∈ 𝔽_p(t)[x] defines a cover of P¹ over 𝔽_p. The Galois group is the monodromy group of this cover.
2. By the Hilbert irreducibility theorem for function fields (a theorem of S. Lang), the set of specializations where the Galois group drops is a proper closed subset.
3. Count lattice points in the complement to get the density.
4. Key obstacle: formalizing covers of curves and monodromy groups.

**Domain Bridges**: Algebra (Galois theory) <-> Geometry (algebraic curves, covers) <-> Number Theory (Hilbert irreducibility)

**Lineage**: Addresses the fundamental limitation discovered in this cycle (cyclic Galois groups over finite fields) by moving to the correct setting (function fields).

**Ambition**: grand_challenge

---

### Direction 5: Computational Verification of Splitting Type Convergence Rates

**Conjecture**: For degree-n monic polynomials over 𝔽_p, the deviation of the splitting type distribution from the random permutation distribution satisfies:
$$\left| P(\text{type } \lambda) - \frac{|\{σ ∈ S_n : \text{cycle type}(σ) = \lambda\}|}{n!} \right| = O(1/p)$$
with an explicit constant depending on n and λ. More precisely, for the irreducible fraction:
$$P(\text{irreducible}) = \frac{1}{n} - \frac{1}{np} + O(1/p^2)$$

**Test**: For n = 2, 3, 4, 5 and p = 5, 7, 11, 13, 17, 19, 23, 29, 31, compute the exact splitting type distribution by enumeration. Fit the leading correction term and verify it matches the predicted O(1/p) rate with the conjectured coefficient.

**Impact**: Establishing the rate of convergence would quantify the Frobenius correspondence and connect to error terms in the Chebotarev density theorem. The explicit constants would have applications in cryptographic parameter selection (how large must p be for the "random polynomial" model to be accurate?).

**Catalog References**: `Geometry/StochasticGalois.lean` (SplittingType, irreducibleCubicCount), `Computation/InfoEfficientAlgorithms.lean`

**Proof Strategy**:
1. For n = 2: the exact formula P(irred) = (p−1)/(2p) = 1/2 − 1/(2p) gives the coefficient −1/2.
2. For n = 3: compute I(3,p)/p³ = (p³−p)/(3p³) = 1/3 − 1/(3p²), which is O(1/p²), not O(1/p). This suggests the rate depends on n.
3. General conjecture: P(irred) = 1/n − 1/(np^{n-1}) + O(1/p^n), i.e., the convergence rate is O(1/p^{n-1}).
4. Verify this refined conjecture computationally.

**Domain Bridges**: Algebra (polynomial counting) <-> Probability (convergence rates) <-> Cryptography (parameter selection)

**Lineage**: Quantitative refinement of the Frobenius correspondence from this cycle.

**Ambition**: extension
