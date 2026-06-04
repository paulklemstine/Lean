# The Cyclotomic-Alexander Bridge: Deep Extensions of the Torus Knot–Number Theory Connection

## Abstract

We deepen the known connection between Alexander polynomials of torus knots T(2,p) and cyclotomic polynomials. Our main contributions are: (1) the **negation bridge identity** Φ_{2p}(X) = Φ_p(−X) for odd prime p, which reveals the structural origin of the cyclotomic-knot correspondence; (2) an **irreducibility transfer** showing the Alexander polynomial of T(2,p) is irreducible over ℤ, inherited from cyclotomic irreducibility; (3) a **degree-genus formula** connecting Seifert genus to Euler's totient function via g(T(2,p)) = φ(2p)/2; (4) a **cyclotomic product decomposition** X^n + 1 = ∏_{d|n} Φ_{2d} for odd n, generalizing the bridge from prime to composite parameters; and (5) a **Galois-knot bridge** identifying the degree of the Alexander polynomial with the order of the Galois group of the corresponding cyclotomic field. All results are formalized with complete machine-verified proofs.

## 1. Introduction

The Alexander polynomial Δ_K(t) is a classical invariant of knots, introduced by J.W. Alexander in 1928. For the family of torus knots T(2,n) with n odd, the Alexander polynomial takes a particularly simple form:

A_n(X) = Σ_{i=0}^{n-1} (−1)^i X^i = 1 − X + X² − ⋯ + X^{n-1}

This alternating geometric sum satisfies the fundamental identity (X+1) · A_n(X) = X^n + 1.

It has been observed that when n = p is an odd prime, A_p coincides with the 2p-th cyclotomic polynomial Φ_{2p}. This paper investigates the structural reasons for this coincidence and derives several non-trivial consequences that bridge knot theory, algebraic number theory, and Galois theory.

### 1.1 Catalog References

This work builds upon and extends:
- `Tropical/CyclotomicKnotSpectra.lean`: The fundamental identity and basic cyclotomic bridge (cyclotomic_torus_knot_identity, alexander_eq_cyclotomic_bridge)
- `Algebra/CyclotomicGaloisGroup.lean`: Cyclicity of cyclotomic Galois groups (prime_cyclotomic_galois_group_cyclic)
- `Bridges/KnottedLightTopology.lean`: Spectral dichotomy for palindromic polynomials (palindromic_complex_roots_on_unit_circle)

## 2. Definitions

**Definition 2.1** (Alexander polynomial of T(2,n)). For n ∈ ℕ, define
```
alexanderPoly(n) = Σ_{i=0}^{n-1} (−X)^i ∈ ℤ[X]
```

**Definition 2.2** (Cyclotomic polynomial). The n-th cyclotomic polynomial Φ_n ∈ ℤ[X] is the minimal polynomial of primitive n-th roots of unity, characterized by ∏_{d|n} Φ_d = X^n − 1.

**Definition 2.3** (Seifert genus). For a knot K, the Seifert genus g(K) is the minimal genus of an oriented surface bounded by K. For T(2,p) with odd prime p, g = (p−1)/2.

## 3. Main Results

### 3.1 The Negation Bridge (Theorem A)

**Theorem 3.1** (cyclotomic_negation_bridge). *For every odd prime p,*
```
Φ_{2p}(X) = Φ_p(−X)
```

*Proof sketch.* We show both sides satisfy f(X) · (X+1) = X^p + 1. For Φ_{2p}, this follows from the cyclotomic product formula: X^{2p} − 1 = ∏_{d|2p} Φ_d, combined with the factorization X^{2p} − 1 = (X^p − 1)(X^p + 1) and X^p − 1 = Φ_1 · Φ_p.

For Φ_p(−X), we use that Φ_p = Σ X^i for prime p, so Φ_p(−X) = Σ(−X)^i = alexanderPoly(p), and the fundamental identity gives alexanderPoly(p) · (X+1) = X^p + 1.

Since X + 1 is not a zero divisor in ℤ[X] (an integral domain), cancellation gives equality. □

**Corollary 3.2** (alexander_eq_cyclotomic_comp_neg). *alexanderPoly(p) = Φ_p(−X) for prime p.*

This follows immediately from the definition: alexanderPoly(p) = Σ(−X)^i and Φ_p = Σ X^i.

### 3.2 Irreducibility Transfer (Theorem B)

**Theorem 3.3** (alexander_irreducible). *For every odd prime p, alexanderPoly(p) is irreducible over ℤ.*

*Proof sketch.* By the negation bridge, alexanderPoly(p) = Φ_p(−X) = Φ_{2p}(X). The classical theorem of Kronecker-Weber-Dedekind establishes that cyclotomic polynomials are irreducible over ℤ. Since Φ_{2p} is irreducible and alexanderPoly(p) = Φ_{2p}, the result follows. □

**Remark.** In knot-theoretic terms, irreducibility means the Alexander polynomial cannot be written as a product of Alexander polynomials of simpler knots (after appropriate normalization). This provides a number-theoretic proof that torus knots T(2,p) are "algebraically prime."

### 3.3 Fox Normalization (Theorem C)

**Theorem 3.4** (alexander_fox_normalization). *For every odd prime p, alexanderPoly(p) evaluated at 1 equals 1.*

*Proof sketch.* The sum Σ_{i=0}^{p-1} (−1)^i telescopes: for odd p, consecutive pairs cancel leaving the final term (−1)^{p−1} = 1. □

**Theorem 3.5** (alexander_determinant). *For any n, alexanderPoly(n) evaluated at −1 equals n.*

This gives the knot determinant det(T(2,n)) = n.

### 3.4 Degree-Genus Bridge (Theorem D)

**Theorem 3.6** (alexander_degree_eq_totient). *For odd prime p,*
```
deg(alexanderPoly(p)) = φ(2p)
```

**Theorem 3.7** (totient_two_mul_odd_prime). *For odd prime p, φ(2p) = p − 1.*

**Corollary 3.8** (seifert_genus_eq). *The Seifert genus of T(2,p) satisfies*
```
g(T(2,p)) = deg(alexanderPoly(p))/2 = (p−1)/2
```

*This bridges topology (genus) to arithmetic (totient).*

### 3.5 Cyclotomic Product Decomposition (Theorem E)

**Theorem 3.9** (cyclotomic_product_Xn_plus_one). *For odd n > 0,*
```
X^n + 1 = ∏_{d|n} Φ_{2d}(X)
```

*Proof sketch.* From the master identity ∏_{d|m} Φ_d = X^m − 1 applied to m = 2n and m = n:
- ∏_{d|2n} Φ_d = X^{2n} − 1 = (X^n − 1)(X^n + 1)
- ∏_{d|n} Φ_d = X^n − 1

The divisors of 2n (for odd n) partition as {d : d|n} ∪ {2d : d|n} (since n is odd, these sets are disjoint). Thus:

∏_{d|n} Φ_d · ∏_{d|n} Φ_{2d} = (X^n − 1)(X^n + 1)

Canceling X^n − 1 (nonzero in ℤ[X]) gives the result. □

**Remark.** This theorem generalizes the single-prime bridge to all odd n. Each factor Φ_{2d} corresponds to the Alexander polynomial of a component torus knot T(2,d), revealing the divisor lattice as a "factorization lattice" of knot invariants.

### 3.6 Galois-Knot Bridge (Theorem F)

**Theorem 3.10** (alexander_degree_eq_galois_order). *For odd prime p,*
```
deg(alexanderPoly(p)) = |Gal(ℚ(ζ_{2p})/ℚ)|
```

*This identifies the degree of a knot invariant with the order of a Galois group.*

*Proof sketch.* Both sides equal φ(2p) = p − 1. The degree comes from Theorem 3.6. The Galois group order comes from the fact that [ℚ(ζ_{2p}):ℚ] = φ(2p) and the extension is Galois. □

### 3.7 Monicity (Theorem G)

**Theorem 3.11** (alexander_monic). *For odd n > 1, alexanderPoly(n) has leading coefficient 1.*

The leading term is (−X)^{n−1} = X^{n−1} since n − 1 is even for odd n.

## 4. The PEGB Framework

### Theorem A: Negation Bridge Φ_{2p} = Φ_p(−X)

- **Proof**: Complete formal proof using cancellation in ℤ[X] after establishing both sides satisfy f·(X+1) = X^p+1.
- **Example**: p=3: Φ₆(X) = X²−X+1 = Φ₃(−X) = (−X)²+(−X)+1 = X²−X+1 ✓
- **Generalization**: The identity Φ_{2n}(X) = Φ_n(−X) holds for ALL odd n (not just primes), via the same divisor-lattice argument.
- **Boundary**: Fails for n even: Φ_4(X) = X²+1 but Φ₂(−X) = −X+1 ≠ X²+1. The doubling-and-negation pattern requires oddness.

### Theorem B: Irreducibility of Alexander Polynomial

- **Proof**: Direct transfer from cyclotomic irreducibility via the bridge identity.
- **Example**: alexanderPoly(3) = X²−X+1 has discriminant −3 < 0, no rational roots, irreducible.
- **Generalization**: For composite odd n, alexanderPoly(n) factors as ∏_{d|n, d>1} Φ_{2d}, each factor irreducible. The factorization of the Alexander polynomial mirrors the divisor structure of n.
- **Boundary**: For n=1, alexanderPoly(1) = 1, a unit, not irreducible.

### Theorem E: Cyclotomic Product Decomposition

- **Proof**: Divisor partition + cancellation in integral domain ℤ[X].
- **Example**: n=15: X¹⁵+1 = Φ₂·Φ₆·Φ₁₀·Φ₃₀ = (X+1)(X²−X+1)(X⁴−X³+X²−X+1)Φ₃₀.
- **Generalization**: Replace ℤ by any integral domain R.
- **Boundary**: Fails for even n: X²+1 ≠ ∏_{d|2} Φ_{2d} = Φ₂·Φ₄ = (X+1)(X²+1). The parity condition is essential for the divisor partition.

## 5. Algorithms

### Algorithm 1: Alexander Polynomial Computation
```
Input: odd integer n ≥ 1
Output: coefficients of alexanderPoly(n)
for i = 0 to n-1:
    coeff[i] = (-1)^i
return coeff
```
Time complexity: O(n). Space complexity: O(n).

### Algorithm 2: Cyclotomic Bridge Verification
```
Input: odd prime p
Output: True if alexanderPoly(p) = Φ_{2p}
1. Compute A = alexanderPoly(p)
2. Compute Φ = cyclotomic(2p)
3. Return A == Φ
```

### Algorithm 3: Genus Computation
```
Input: odd prime p
Output: Seifert genus of T(2,p)
return (p - 1) / 2
```

## 6. Discussion

The results in this paper reveal that the cyclotomic-Alexander bridge is not an isolated coincidence but a structured phenomenon with multiple facets:

1. **Structural origin**: The negation bridge Φ_{2p} = Φ_p(−X) explains *why* the bridge exists: the alternating signs in the Alexander polynomial correspond to the index-doubling in the cyclotomic polynomial, both mediated by the sign-flip X ↦ −X.

2. **Irreducibility transfer**: The bridge transmits deep arithmetic structure (irreducibility of cyclotomic polynomials) into topological consequences (algebraic primality of torus knots).

3. **Product decomposition**: The generalization from prime to composite n reveals the divisor lattice as the organizing principle for knot factorization.

4. **Cross-domain identification**: The Galois-knot bridge identifies quantities from three different domains (knot degree, totient value, Galois group order) as a single integer.

## 7. Future Work

Several extensions suggest themselves:

1. **Jones polynomial spectral theory**: Does the Jones polynomial of T(2,p), which encodes strictly more information than the Alexander polynomial, have a similarly precise connection to cyclotomic or modular objects?

2. **Higher torus knots**: The knots T(m,n) for m > 2 have Alexander polynomials with more complex structure. Is there a "higher cyclotomic bridge" connecting these to products of cyclotomic polynomials?

3. **Tropical degeneration**: The roots of Φ_{2p} lie on the unit circle. Under tropicalization (taking logarithms of absolute values), they collapse to 0. What algebraic structure survives this degeneration, and does it connect to the tropical spectral theory in the Catalog?

4. **L-functions**: The Alexander polynomial is the simplest case of a knot L-function. The analogy with Dedekind zeta functions suggests deeper connections to analytic number theory.

## 8. References

1. Alexander, J.W. "Topological invariants of knots and links." *Transactions of the AMS* 30 (1928), 275–306.
2. Rolfsen, D. *Knots and Links*. AMS Chelsea Publishing, 2003.
3. Washington, L.C. *Introduction to Cyclotomic Fields*. Springer GTM 83, 1997.
4. **Catalog references**:
   - `Tropical/CyclotomicKnotSpectra.lean`: cyclotomic_torus_knot_identity, alexander_eq_cyclotomic_bridge
   - `Algebra/CyclotomicGaloisGroup.lean`: prime_cyclotomic_galois_group_cyclic
   - `Bridges/KnottedLightTopology.lean`: palindromic_complex_roots_on_unit_circle, spectral_dichotomy_crystalline

## Appendix: Summary of Formal Theorems

| Theorem | Statement | Significance |
|---------|-----------|-------------|
| `cyclotomic_negation_bridge` | Φ_{2p} = Φ_p(−X) | Structural origin of the bridge |
| `alexander_eq_cyclotomic_comp_neg` | A_p = Φ_p(−X) | Compositional form of Alexander poly |
| `alexander_irreducible` | A_p irreducible over ℤ | Number-theoretic proof of knot primality |
| `alexander_fox_normalization` | A_p(1) = 1 | Fox normalization via non-prime-power |
| `alexander_determinant` | A_p(−1) = p | Knot determinant computation |
| `alexander_degree_eq_totient` | deg(A_p) = φ(2p) | Degree-totient bridge |
| `totient_two_mul_odd_prime` | φ(2p) = p−1 | Totient simplification |
| `seifert_genus_eq` | g = (p−1)/2 | Genus-totient formula |
| `alexander_fundamental` | A_n·(X+1) = X^n+1 | Fundamental identity |
| `alexander_monic` | lc(A_n) = 1 | Monicity for odd n |
| `cyclotomic_product_Xn_plus_one` | ∏Φ_{2d} = X^n+1 | Product decomposition for odd n |
| `two_mul_prime_not_prime_pow` | 2p ≠ q^k | Arithmetic lemma |
| `alexander_degree_eq_galois_order` | deg = |Gal| | Galois-knot bridge |
