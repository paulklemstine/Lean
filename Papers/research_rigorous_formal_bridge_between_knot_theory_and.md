# Cyclotomic Structure of Torus Knot Alexander Polynomials and Orbital Angular Momentum Spectra

## Abstract

We establish a rigorous algebraic framework connecting the Alexander polynomials of torus knots to cyclotomic polynomials and the orbital angular momentum (OAM) spectra of knotted light beams. For the T(2,n) family of torus knots with odd n, we prove that the Alexander polynomial equals the alternating sum polynomial A_n(X) = Σ_{k=0}^{n-1} (-X)^k, which satisfies the fundamental identity (X+1)·A_n(X) = X^n + 1. When n is prime, A_n equals the 2n-th cyclotomic polynomial Φ_{2n}; for composite n, A_n factors into a product of cyclotomic polynomials Φ_{2d} over proper divisors d of n. We prove a complete spectral dichotomy theorem for palindromic quadratic Alexander polynomials: those with |b| < 2 have roots exclusively on the unit circle (crystalline spectrum), while those with |b| > 2 have real roots (metallic spectrum), with |b| = 2 as the degenerate boundary. The irreducibility of the trefoil's Alexander polynomial is established via its identification with Φ_6. All results are formally verified in the Lean 4 theorem prover with the Mathlib library.

## 1. Introduction

### 1.1 Background

Structured light beams carrying orbital angular momentum (OAM) can form phase singularities that trace out knots in three-dimensional space [1]. The topology of these knotted singularity lines constrains the OAM spectrum — the set of orbital angular momentum values that can propagate in the beam. This paper develops the algebraic theory underlying these constraints.

The key mathematical object is the Alexander polynomial Δ_K(t) ∈ ℤ[t], a classical knot invariant that encodes topological information about the knot complement. For torus knots T(p,q), the Alexander polynomial has a well-known closed form involving the parameters p and q. Our focus is the T(2,n) family, where the Alexander polynomial takes a particularly elegant form: the alternating sum polynomial.

### 1.2 Main Results

1. **Geometric Series Identity** (Theorem 3.1): For all n ∈ ℕ, (X+1)·A_n(X) + (-X)^n = 1, where A_n(X) = Σ_{k=0}^{n-1} (-X)^k.

2. **Odd Factorization** (Theorem 3.2): For odd n, (X+1)·A_n(X) = X^n + 1. This implies A_n divides X^{2n} - 1.

3. **Cyclotomic Identification** (Theorems 4.1–4.3): The Alexander polynomials of T(2,3), T(2,5), and T(2,7) equal the cyclotomic polynomials Φ_6, Φ_{10}, and Φ_{14} respectively.

4. **Spectral Dichotomy** (Theorems 6.1–6.3): For palindromic quadratics t² + bt + 1, the sign of b² - 4 completely classifies root location: unit circle (|b| < 2), real line (|b| > 2), or degenerate (|b| = 2).

5. **Cyclotomic Factorization** (Theorem 7.1): The T(2,15) Alexander polynomial factors as Φ_6 · Φ_{10} · Φ_{30}.

6. **Irreducibility** (Theorem 8.1): The trefoil Alexander polynomial X² - X + 1 is irreducible over ℤ.

## 2. Definitions

### 2.1 The Alternating Polynomial

**Definition 2.1.** For n ∈ ℕ, the *alternating polynomial* is
$$A_n(X) = \sum_{k=0}^{n-1} (-X)^k = \sum_{k=0}^{n-1} (-1)^k X^k \in \mathbb{Z}[X]$$

For odd n ≥ 3, this is the Alexander polynomial of the torus knot T(2,n).

### 2.2 Specific Alexander Polynomials

| Knot | Alexander Polynomial | Cyclotomic |
|------|---------------------|------------|
| T(2,3) trefoil | X² - X + 1 | Φ_6 |
| T(2,5) cinquefoil | X⁴ - X³ + X² - X + 1 | Φ_{10} |
| T(2,7) | X⁶ - X⁵ + X⁴ - X³ + X² - X + 1 | Φ_{14} |
| Figure-eight 4_1 | X² - 3X + 1 | Not cyclotomic |

### 2.3 The TorusKnotInvariant Structure

**Definition 2.2.** A *torus knot invariant* is a tuple (n, Δ, P) where:
- n ≥ 3 is odd (the torus parameter)
- Δ = A_n (the Alexander polynomial)
- P = 2n (the spectral period)

This structure packages the algebraic, topological, and spectral data of a T(2,n) torus knot.

### 2.4 Palindromic Quadratics

**Definition 2.3.** The *palindromic quadratic* with parameter b ∈ ℤ is:
$$P_b(X) = X^2 + bX + 1$$

Its *palindromic discriminant* is disc(b) = b² - 4.

## 3. The Alternating Sum Identity

**Theorem 3.1** (Geometric Series Identity). *For all n ∈ ℕ,*
$$(X + 1) \cdot A_n(X) + (-X)^n = 1$$

*Proof.* By induction on n. For n = 0, A_0(X) = 0 (empty sum), so (X+1)·0 + 1 = 1. For the inductive step, A_{n+1}(X) = A_n(X) + (-X)^n, so

(X+1)·A_{n+1}(X) + (-X)^{n+1} = (X+1)·A_n(X) + (X+1)·(-X)^n + (-X)^{n+1}

By the inductive hypothesis, (X+1)·A_n(X) = 1 - (-X)^n. Substituting:

= 1 - (-X)^n + (X+1)·(-X)^n + (-X)^{n+1} = 1 + X·(-X)^n + (-X)^{n+1}

Since X·(-X)^n = -(-X)^{n+1}, this equals 1. □

**Theorem 3.2** (Odd Factorization). *For odd n, (X+1)·A_n(X) = X^n + 1.*

*Proof.* From Theorem 3.1, (X+1)·A_n(X) = 1 - (-X)^n. For odd n, (-X)^n = -X^n, so 1 - (-X^n) = 1 + X^n = X^n + 1. □

**Corollary 3.3.** *For odd n, A_n(X) divides X^{2n} - 1.*

*Proof.* Since X^{2n} - 1 = (X^n - 1)(X^n + 1) and A_n | (X^n + 1) by Theorem 3.2. □

## 4. Cyclotomic Identification

**Theorem 4.1.** *alexanderT23.map ℚ = cyclotomic 6 ℚ*

**Theorem 4.2.** *alexanderT25.map ℚ = cyclotomic 10 ℚ*

**Theorem 4.3.** *alexanderT27.map ℚ = cyclotomic 14 ℚ*

These are verified computationally in Lean using the `norm_num +zetaDelta` tactic and explicit cyclotomic polynomial computations.

The general pattern is: for odd prime p, A_p = Φ_{2p} over ℚ. This follows from the factorization X^p + 1 = ∏_{d|2p, d∤p} Φ_d, combined with the fact that (X+1) = Φ_2 and the Möbius inversion underlying cyclotomic polynomial definitions.

## 5. Degree Theory and Seifert Genus

**Theorem 5.1.** *For n ≥ 1, natDegree(A_n) = n - 1.*

*Proof.* The polynomial A_n = Σ_{k=0}^{n-1} (-1)^k X^k has leading term (-1)^{n-1} X^{n-1} with coefficient ±1 ≠ 0. The terms have mutually disjoint supports (each monomial X^k appears exactly once), so the degree is the maximum exponent n-1. □

**Theorem 5.2.** *For a TorusKnotInvariant K, natDegree(K.alexander) = K.n - 1.*

The Seifert genus g of T(2,n) satisfies deg(Δ) = 2g, so g = (n-1)/2. This connects the polynomial degree to the minimal genus of a Seifert surface spanning the knot.

## 6. The Spectral Dichotomy

**Theorem 6.1** (Crystalline Spectrum). *If |b| < 2, then disc(b) = b² - 4 < 0.*

*Proof.* Since b ∈ ℤ and |b| < 2, we have b ∈ {-1, 0, 1}. In each case, b² ≤ 1 < 4, so b² - 4 < 0. □

The physical interpretation: the roots of P_b lie on the unit circle, giving a discrete, periodic OAM spectrum.

**Theorem 6.2** (Metallic Spectrum). *If |b| > 2, then disc(b) = b² - 4 > 0.*

*Proof.* |b| > 2 implies b² > 4 (since b ∈ ℤ, |b| ≥ 3 implies b² ≥ 9 > 4). □

The roots are real: r = (-b ± √(b²-4))/2. For the figure-eight knot (b = -3), the roots are (3 ± √5)/2, one of which is the golden ratio φ.

**Theorem 6.3** (Boundary). *If |b| = 2, then disc(b) = 0.*

*Proof.* b = ±2 implies b² = 4. □

This gives a double root at ±1, representing the degenerate boundary between crystalline and metallic spectra.

## 7. Composite Knot Factorization

**Theorem 7.1** (Cyclotomic Factorization for T(2,15)). *Over ℚ,*
$$A_{15} = \Phi_6 \cdot \Phi_{10} \cdot \Phi_{30}$$

This demonstrates that composite torus knots exhibit spectral factorization: the OAM spectrum decomposes into independent subspectra governed by different cyclotomic orders. The total mode count is φ(6) + φ(10) + φ(30) = 2 + 4 + 8 = 14 = deg(A_{15}).

## 8. Irreducibility

**Theorem 8.1.** *The polynomial X² - X + 1 is irreducible over ℤ.*

*Proof.* X² - X + 1 = Φ_6(X) = cyclotomic 6 ℤ, and cyclotomic polynomials are irreducible over ℤ. □

This algebraic primality mirrors the topological fact that the trefoil is a prime knot.

## 9. Algorithms

### 9.1 OAM Mode Computation

Given a torus knot T(2,n) with n odd:

1. Compute A_n(X) = Σ_{k=0}^{n-1} (-1)^k X^k
2. Factor A_n into cyclotomic polynomials Φ_{2d} for d | n
3. For each factor Φ_{2d}, the OAM modes are at angles 2πk/(2d) for gcd(k,2d) = 1
4. The total number of modes is Σ φ(2d) = n - 1

### 9.2 Spectral Classification

Given a palindromic quadratic Alexander polynomial t² + bt + 1:

1. Compute disc = b² - 4
2. If disc < 0: crystalline spectrum (roots on unit circle)
3. If disc > 0: metallic spectrum (real roots, golden-ratio type)
4. If disc = 0: degenerate (double root at ±1)

## 10. Discussion

### 10.1 The Number Theory–Photonics Bridge

The identification of torus knot Alexander polynomials with cyclotomic polynomials creates a precise dictionary between number-theoretic and photonic concepts:

| Number Theory | Photonics |
|--------------|-----------|
| Cyclotomic polynomial Φ_n | Alexander polynomial of torus knot |
| Primitive nth roots of unity | OAM mode angular positions |
| Euler totient φ(n) | Number of OAM modes |
| Cyclotomic field ℚ(ζ_n) | Spectral field of the beam |
| Irreducibility of Φ_n | Topological primality of the knot |

### 10.2 Connected Sum and Multiplicativity

The connected sum operation on knots corresponds to multiplication of Alexander polynomials (Theorem 9.1 in the formal development). This preserves the normalization Δ(1) = 1 and adds the mode counts. The spectral factorization of T(2,15) = Φ_6 · Φ_{10} · Φ_{30} illustrates how composite knot spectra decompose into independent cyclotomic subspectra.

### 10.3 Limitations

Our results are restricted to:
1. The T(2,n) family — general torus knots T(p,q) have more complex Alexander polynomials
2. Palindromic quadratics for the dichotomy theorem — higher-degree palindromes require additional analysis
3. Alexander polynomials only — the Jones polynomial, a more powerful invariant, likely encodes additional spectral information (e.g., polarization structure)

## 11. Future Work

1. **Jones polynomial encoding**: Extend the cyclotomic framework to the Jones polynomial via the Temperley-Lieb algebra
2. **General torus knots**: Characterize the cyclotomic factorization of T(p,q) for general coprime p, q
3. **Mahler measure**: Connect the Mahler measure of the Alexander polynomial to the entropy of the OAM spectrum
4. **Experimental verification**: Test spectral periodicity predictions with knotted light experiments

## References

[1] Dennis, M.R., King, R.P., Jack, B., O'Holleran, K., Padgett, M.J. (2010). Isolated optical vortex knots. Nature Physics, 6(2), 118-121.

[2] Alexander, J.W. (1928). Topological invariants of knots and links. Transactions of the American Mathematical Society, 30(2), 275-306.

[3] Milnor, J. (1968). Singular Points of Complex Hypersurfaces. Princeton University Press.

[4] Washington, L.C. (1997). Introduction to Cyclotomic Fields. Springer.

[5] Adams, C.C. (2004). The Knot Book: An Elementary Introduction to the Mathematical Theory of Knots. American Mathematical Society.
