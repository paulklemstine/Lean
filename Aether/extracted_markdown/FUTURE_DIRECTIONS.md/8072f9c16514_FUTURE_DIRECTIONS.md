# Future Directions: Hyperbolic Number Theory

## Synthesis

This research cycle established the foundations of arithmetic on the Poincaré disk through three interconnected pillars: (1) the algebraic structure of split-complex integers ℤ[τ] with their Lorentzian norm, (2) the geometric theory of the Poincaré disk conformal factor and orbit counting, and (3) the number-theoretic characterization of hyperbolic primes as consecutive-integer pairs in bijection with odd rational primes.

The most promising cross-domain connection emerging from this cycle is the **bridge between Lorentzian lattice arithmetic and automorphic form theory**. The split-complex integers ℤ[τ] form a ring that is *not* an integral domain (it has zero divisors 1 ± τ), yet its forward light cone admits a well-behaved factorization theory. This suggests that the natural "zeta function" for this ring should be defined not over the full ring but over the light cone monoid, and should be related to Selberg-type zeta functions on the modular surface. The Brahmagupta multiplication's connection to Lorentz boosts (from `Catalog/Cryptography/BerggrenDiophantineLattice.lean` and its Lorentz form) suggests that the hyperbolic prime distribution may be governed by spectral theory on the modular curve.

The highest breakthrough potential lies in **Direction 1** (Hyperbolic Zeta Function), because it connects our concrete algebraic framework to the deep analytic machinery of automorphic forms, potentially yielding new insights into the distribution of primes in arithmetic progressions. Direction 3 (Tropical-Hyperbolic Bridge) has significant potential for connecting to the existing Catalog's tropical computation framework.

---

### Direction 1: The Hyperbolic Zeta Function and Its Zeros

**Conjecture**: Define the hyperbolic zeta function as
$$\zeta_H(s) = \sum_{n=1}^{\infty} \frac{1}{(2n+1)^s}$$
where the sum runs over positive hyperbolic norms 2n+1. Then ζ_H(s) = (1 − 2^{−s})ζ(s) − 1, where ζ(s) is the Riemann zeta function. In particular, the nontrivial zeros of ζ_H lie on the critical line Re(s) = 1/2 if and only if the Riemann Hypothesis holds.

**Test**: Compute ζ_H(s) numerically for s = 1/2 + it with t ∈ [0, 100] and verify that the first 29 zeros match the known Riemann zeros shifted by the correction factor. Specifically, verify |ζ_H(1/2 + 14.134i)| < 10⁻⁶.

**Impact**: If the identification ζ_H(s) = (1 − 2^{−s})ζ(s) − 1 is correct, it would show that hyperbolic prime distribution is *exactly* governed by the Riemann zeta function (with a Dirichlet-character twist), providing a geometric interpretation of the critical line. If incorrect, it would reveal that hyperbolic primes carry genuinely new arithmetic information beyond the classical setting.

**Catalog References**: `Catalog/Algebra/Foundations.lean` (critical_line_implies_unit_disk), `Catalog/Computation/HyperbolicNumberTheory.lean`

**Proof Strategy**: Express ζ_H(s) as a sum over odd integers minus the contribution of odd non-prime composites. The sum over odd integers is (1 − 2^{−s})ζ(s), from which we subtract 1 (the n=0 term, giving the integer 1). Verify this algebraic identity rigorously, then analyze zero locations via the known Riemann zero distribution. Key lemma needed: a rigorous proof that ∑_{n≥1} (2n+1)^{−s} = (1 − 2^{−s})ζ(s) − 1 for Re(s) > 1.

**Domain Bridges**: NumberTheory <-> Analysis, Algebra <-> Geometry

**Lineage**: Builds on the consecutive_hyp_prime_iff theorem and hyp_prime_family_unbounded from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Unique Factorization in the Light Cone Modulo Units

**Conjecture**: Every element x ∈ C⁺ (the forward light cone monoid) with N(x) > 1 has a unique factorization into irreducible elements, up to reordering and multiplication by units of norm 1 (i.e., the identity element (1,0)).

**Test**: For all light cone elements (a, b) with 1 < a ≤ 100 and |b| < a, compute all factorizations into irreducible elements and verify uniqueness. A single element with two essentially different factorizations (i.e., different multi-sets of irreducible norms) would disprove the conjecture.

**Impact**: If true, C⁺ would be the first known example of a "non-commutative-geometry-adjacent" unique factorization monoid with indefinite norm. If false, the failure mode would reveal the structure of the obstruction (analogous to how class groups measure failure of unique factorization in algebraic number fields).

**Catalog References**: `Catalog/Computation/HyperbolicNumberTheory.lean` (HypArithElt structure), `Catalog/Cryptography/BerggrenDiophantineLattice.lean`

**Proof Strategy**: The key insight is that C⁺ is isomorphic (as a monoid) to (ℤ_{>0}, ×) via the norm map N: C⁺ → ℤ_{>0}. However, the norm map is NOT injective (multiple elements can have the same norm), so uniqueness of factorization in C⁺ is stronger than unique factorization in ℤ. The first step is to characterize the fibers N⁻¹(n) for each n and show that irreducible elements are determined by their norm. Needed lemma: if x, y ∈ C⁺ are irreducible with N(x) = N(y) = p (prime), then x = y up to units.

**Domain Bridges**: Algebra <-> NumberTheory

**Lineage**: Builds on prime_norm_no_nontrivial_factorization and LightConeElt.mul_norm from this cycle.

**Ambition**: extension

---

### Direction 3: Tropical-Hyperbolic Duality

**Conjecture**: The Brahmagupta multiplication on the forward light cone, when transported to logarithmic coordinates via (a, b) ↦ (log a, log b), converges to the tropical semiring operation (max, +) in the limit where a, b → ∞ with a − b fixed.

**Test**: For elements (n+1, n) with n = 10, 100, 1000, ..., compute the Brahmagupta products in logarithmic coordinates and measure the deviation from tropical multiplication. Verify that the relative error decreases as O(1/n).

**Impact**: If true, this would establish a rigorous "tropicalization" functor from hyperbolic arithmetic to tropical arithmetic, connecting the Poincaré disk to the tropical geometry framework already developed in the Catalog. This would unify two apparently disparate mathematical structures. If false, it would show that the Lorentzian sign structure prevents tropicalization, which would itself be an interesting obstruction result.

**Catalog References**: `Catalog/Computation/TropicalAmortized.lean`, `Catalog/Computation/TropicalCompression.lean`, `Catalog/Computation/ReversibleTropicalMachine.lean`

**Proof Strategy**: Write the Brahmagupta product (a₁a₂ + b₁b₂, a₁b₂ + b₁a₂) in terms of sums and differences sᵢ = aᵢ + bᵢ, dᵢ = aᵢ − bᵢ. The product becomes ((s₁s₂ + d₁d₂)/2, (s₁s₂ − d₁d₂)/2). In the limit where sᵢ → ∞ with dᵢ fixed, log of the first coordinate → log(s₁) + log(s₂) − log(2), which is tropical multiplication in the (max, +) semiring. Formalize this asymptotic expansion as a rigorous limit theorem.

**Domain Bridges**: Tropical <-> NumberTheory, Computation <-> Geometry

**Lineage**: Builds on lorentz_brahmagupta from this cycle and the tropical computation framework in the Catalog.

**Ambition**: grand_challenge

---

### Direction 4: Spectral Gap and Hyperbolic Prime Gaps

**Conjecture**: The maximal gap between consecutive hyperbolic primes (i.e., the maximal gap between consecutive primes in the sequence 3, 5, 7, 11, 13, ...) up to N satisfies gap(N) ≤ C · (log N)² for an explicit constant C ≤ 4. This is the hyperbolic analog of Cramér's conjecture.

**Test**: Compute maximal gaps between consecutive odd primes ≤ 10⁷ and fit the constant C. If C > 4 for any observed gap, the conjecture fails.

**Impact**: If true with C ≤ 4, this would give the tightest known bound on gaps between primes in the arithmetic progression 2n+1 (odd primes), potentially improving on existing results via the geometric perspective. The connection to spectral gaps in the Laplacian on the modular surface (via Selberg's eigenvalue conjecture) would provide a completely new approach to prime gap problems.

**Catalog References**: `Catalog/Computation/Spectral.lean`, `Catalog/Computation/SpectralOracle.lean`

**Proof Strategy**: Use the orbit counting bound (orbit_count_upper_bound) to bound the number of lattice points between consecutive primes. The spectral gap of the hyperbolic Laplacian controls the error term in the lattice point counting function. If the spectral gap is ≥ 1/4 (Selberg's conjecture), the error term is small enough to guarantee the conjectured gap bound. Key needed result: a formalization of the connection between spectral gaps and lattice point counting error terms.

**Domain Bridges**: NumberTheory <-> Spectral Theory, Computation <-> Physics

**Lineage**: Builds on orbit_count_upper_bound and hyp_prime_family_unbounded from this cycle.

**Ambition**: extension

---

### Direction 5: Cryptographic Hardness of the Hyperbolic Discrete Logarithm

**Conjecture**: The discrete logarithm problem in the forward light cone monoid — given x, y ∈ C⁺, find n such that xⁿ = y (if it exists) — requires Ω(N^{1/4}) operations in the worst case, where N = N(y). This would make it harder than the standard integer discrete logarithm (which can be solved in O(N^{1/2}) by baby-step giant-step) due to the non-commutative geometric structure.

**Test**: Implement baby-step giant-step for the light cone monoid and measure runtime. Compare with the standard integer DLP for equivalent norm sizes. If the light cone DLP is consistently slower by a factor ≥ N^{ε} for some ε > 0, the conjecture is supported.

**Impact**: If the light cone DLP is genuinely harder than the integer DLP, it would provide a new candidate for post-quantum cryptographic primitives based on hyperbolic geometry. The connection to Lorentz boosts gives a physical interpretation: breaking the cryptosystem corresponds to "undoing time evolution" in a discrete relativistic system.

**Catalog References**: `Catalog/Cryptography/BerggrenDiophantineLattice.lean`, `Catalog/Cryptography/BerggrenFingerprintRigidity.lean`, `Catalog/Cryptography/BerggrenGroupoidOrbit.lean`

**Proof Strategy**: The key observation is that the light cone monoid is *not* a group (elements are not invertible in general), which prevents direct application of Pollard's rho or index calculus. Lower bound the DLP by reducing from a known hard problem. First formalize the monoid structure (lorentz_norm_pow_induction gives the norm of powers), then show that finding the exponent n from N(xⁿ) = N(x)ⁿ reduces to a subset-sum variant.

**Domain Bridges**: Cryptography <-> NumberTheory, Algebra <-> Computation

**Lineage**: Builds on LightConeElt.pow, lorentz_norm_pow_induction from this cycle.

**Ambition**: extension
