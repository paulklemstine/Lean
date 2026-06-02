# Cyclotomic Knot Spectra: Alexander Polynomials, Cyclotomic Number Theory, and Spectral Classification

## Abstract

We establish a rigorous algebraic framework connecting Alexander polynomials of T(2,n) torus knots to cyclotomic number theory. Our central results are: (1) the **fundamental identity** (X+1)·A_n(X) = X^n + 1 for odd n, where A_n is the alternating geometric sum (Alexander polynomial of T(2,n)); (2) the **cyclotomic bridge theorem** establishing that A_p = Φ_{2p} for odd prime p, proved by polynomial cancellation in the integral domain ℤ[X]; (3) the **palindromicity theorem** showing coefficient symmetry via parity arithmetic; (4) the **spectral dichotomy theorem** classifying palindromic quadratic polynomials by the single invariant b² − 4; and (5) the **OAM channel identity** φ(2n) = φ(n) for odd n, connecting Euler's totient to information capacity of knotted light beams. All results are formalized and machine-verified in Lean 4 with the Mathlib library.

## 1. Introduction

The Alexander polynomial, introduced by J.W. Alexander in 1928, is one of the oldest and most fundamental knot invariants. For the family of torus knots T(2,n), it takes the particularly elegant form of an alternating geometric sum. While the algebraic properties of these polynomials are classical, their precise relationship to cyclotomic polynomials — and the consequences of this relationship for applications in structured light and information theory — have not been systematically formalized.

This paper develops a unified framework that we call the **Cyclotomic Knot Spectrum**, which encodes:
- The Alexander polynomial as an alternating geometric sum
- Its cyclotomic factorization structure
- A spectral classification of palindromic factors (crystalline vs. metallic)
- Channel-counting identities via Euler's totient function

### 1.1 Related Work

The connection between Alexander polynomials of torus knots and cyclotomic polynomials is implicit in classical knot theory (see Rolfsen, "Knots and Links," 1976; Lickorish, "An Introduction to Knot Theory," 1997). The specific identity A_p = Φ_{2p} for primes p appears in various forms in the literature on fibered knots and Seifert matrices. Our contribution is the rigorous formalization of this identity chain and the introduction of the spectral dichotomy framework.

The application to OAM (orbital angular momentum) channels in structured light is motivated by recent advances in optical communication using vortex beams (Padgett, 2017; Wang et al., 2012), where the topological charge of an OAM mode corresponds to the winding number of a torus knot.

## 2. Definitions

### 2.1 Alexander Polynomial of T(2,n)

**Definition 1** (Alexander Torus Polynomial). For n ∈ ℕ, the Alexander polynomial of the torus knot T(2,n) is:

$$A_n(X) = \sum_{i=0}^{n-1} (-X)^i = 1 - X + X^2 - X^3 + \cdots + (-1)^{n-1} X^{n-1}$$

In Lean 4:
```lean
def alexanderTorusPoly (n : ℕ) : ℤ[X] :=
  ∑ i ∈ Finset.range n, (-X) ^ i
```

### 2.2 Spectral Classification

**Definition 2** (Spectral Class). A palindromic quadratic polynomial X² - bX + 1 is classified as:
- **Crystalline** if b² < 4 (roots on the unit circle)
- **Metallic** if b² ≥ 4 (real roots)

```lean
def spectralClassify (b : ℤ) : SpectralClass :=
  if b ^ 2 < 4 then SpectralClass.crystalline
  else SpectralClass.metallic
```

### 2.3 Cyclotomic Knot Spectrum (Novel)

**Definition 3** (CyclotomicKnotSpectrum). The cyclotomic knot spectrum of T(2,n) is the triple (A_n, d(n), σ) where:
- A_n is the Alexander polynomial
- d(n) is the number of divisors of n (controlling the cyclotomic factorization)
- σ ∈ {crystalline, metallic} is the spectral class of the lowest-degree palindromic factor

This is a novel algebraic invariant that unifies topological (knot), arithmetic (cyclotomic), and analytic (spectral) information into a single structure.

## 3. Main Results

### 3.1 Fundamental Identity

**Theorem 1** (Fundamental Identity). For odd n ∈ ℕ:
$$(X + 1) \cdot A_n(X) = X^n + 1$$

*Proof sketch.* Apply the geometric series formula to x = -X:
$$\left(\sum_{i=0}^{n-1} (-X)^i\right) \cdot ((-X) - 1) = (-X)^n - 1$$

For odd n, (-X)^n = -X^n, giving:
$$\left(\sum_{i=0}^{n-1} (-X)^i\right) \cdot (-X - 1) = -X^n - 1$$

Negating both sides: A_n(X) · (X + 1) = X^n + 1. ∎

### 3.2 Coefficient Structure

**Theorem 2** (Coefficient Formula). For all n, i ∈ ℕ:
$$\text{coeff}_i(A_n) = \begin{cases} (-1)^i & \text{if } i < n \\ 0 & \text{otherwise} \end{cases}$$

*Proof.* The sum ∑ (-X)^i = ∑ (-1)^i X^i is a polynomial with coefficient (-1)^i at position i for i in range, and the coefficients of distinct monomials don't interact. ∎

### 3.3 Palindromicity

**Theorem 3** (Palindromic Alexander). For odd n and 0 ≤ i < n:
$$\text{coeff}_i(A_n) = \text{coeff}_{n-1-i}(A_n)$$

*Proof.* By Theorem 2, coeff_i = (-1)^i and coeff_{n-1-i} = (-1)^{n-1-i}. Since n is odd, n-1 is even, so (-1)^{n-1} = 1. Therefore (-1)^i · (-1)^{n-1-i} = (-1)^{n-1} = 1, implying (-1)^i = (-1)^{n-1-i}. ∎

### 3.4 Cyclotomic Bridge

**Theorem 4** (Cyclotomic Bridge). For odd prime p:
$$\Phi_{2p}(X) \cdot (X + 1) = X^p + 1$$

*Proof.* From the product formula ∏_{d | 2p} Φ_d(X) = X^{2p} - 1. For prime p ≠ 2, the divisors of 2p are {1, 2, p, 2p}, giving:
$$\Phi_1 \cdot \Phi_2 \cdot \Phi_p \cdot \Phi_{2p} = X^{2p} - 1$$

Since X^{2p} - 1 = (X^p - 1)(X^p + 1) and X^p - 1 = Φ_1 · Φ_p, we get:
$$\Phi_1 \cdot \Phi_p \cdot \Phi_2 \cdot \Phi_{2p} = \Phi_1 \cdot \Phi_p \cdot (X^p + 1)$$

Cancelling Φ_1 · Φ_p (which is nonzero) yields Φ_2 · Φ_{2p} = X^p + 1, i.e., (X+1) · Φ_{2p} = X^p + 1. ∎

**Theorem 5** (Alexander = Cyclotomic). For odd prime p:
$$A_p(X) = \Phi_{2p}(X)$$

*Proof.* Both A_p and Φ_{2p} satisfy f · (X+1) = X^p + 1 (by Theorems 1 and 4). Since ℤ[X] is an integral domain and X+1 ≠ 0, cancellation gives A_p = Φ_{2p}. ∎

### 3.5 Totient Channel Identity

**Theorem 6** (OAM Channel Identity). For odd n > 0:
$$\varphi(2n) = \varphi(n)$$

*Proof.* Since n is odd, gcd(2,n) = 1. By multiplicativity of Euler's totient, φ(2n) = φ(2)φ(n) = 1 · φ(n) = φ(n). ∎

### 3.6 Spectral Dichotomy

**Theorem 7** (Spectral Dichotomy). For b ∈ ℤ, the quadratic palindrome X² - bX + 1 has:
- All roots on the unit circle iff b² < 4
- Real roots iff b² ≥ 4

*Proof.* The discriminant is b² - 4. Roots are (b ± √(b²-4))/2. When b² < 4, the discriminant is negative, giving complex conjugate roots of modulus √1 = 1 (on the unit circle). When b² ≥ 4, both roots are real. ∎

### 3.7 Evaluation Identity

**Theorem 8** (Evaluation at -1). For all n ∈ ℕ:
$$A_n(-1) = n$$

*Proof.* A_n(-1) = ∑_{i=0}^{n-1} (-(-1))^i = ∑_{i=0}^{n-1} 1 = n. ∎

## 4. Algorithms

### 4.1 Alexander Polynomial Computation

Computing A_n(X) is O(n) by direct evaluation of the alternating sum. For evaluation at a specific point z, Horner's method gives O(n) arithmetic operations.

### 4.2 Spectral Classification

Given a palindromic quadratic X² - bX + 1, spectral classification is O(1): compute b² and compare to 4.

### 4.3 OAM Channel Count

Computing φ(n) for the channel count uses Euler's product formula: φ(n) = n · ∏_{p|n} (1 - 1/p), requiring O(√n) trial divisions.

## 5. Applications

### 5.1 Structured Light Engineering

The identity φ(2n) = φ(n) for odd n implies that OAM-multiplexed communication systems gain no additional channels from even-fold symmetry enhancements. System designers should focus on odd-order configurations for maximum channel efficiency.

### 5.2 Cyclotomic Error-Correcting Codes

The Galois group Gal(ℚ(ζ_{2p})/ℚ) ≅ (ℤ/2pℤ)* acts on OAM modes by permutation. This Galois action could be exploited for error-correcting codes where codewords are invariant under Galois symmetries, providing algebraic error correction properties inherited from cyclotomic field structure.

### 5.3 Knot Invariant Computation

The identity A_p = Φ_{2p} means that computing Alexander polynomials of T(2,p) knots reduces to computing cyclotomic polynomials, for which efficient algorithms exist (e.g., via Möbius inversion of the product formula).

## 6. Discussion

### 6.1 The Nature of the Bridge

The cyclotomic bridge theorem reveals that the Alexander polynomial — originally defined via Seifert matrices and homological algebra — coincides exactly with an object defined purely in terms of roots of unity. This suggests a deeper structural reason: the fundamental group of the torus knot complement has a presentation whose abelianization naturally produces the cyclotomic polynomial.

### 6.2 Beyond T(2,n)

For general torus knots T(m,n), the Alexander polynomial is:
$$A_{m,n}(X) = \frac{(X^{mn} - 1)(X - 1)}{(X^m - 1)(X^n - 1)}$$

The cyclotomic content of this expression — which cyclotomic polynomials appear in its factorization — is a richer invariant that we package as the CyclotomicKnotSpectrum structure.

### 6.3 Spectral Rigidity

A remarkable consequence of A_p = Φ_{2p} is that the Mahler measure of the Alexander polynomial of T(2,p) is always exactly 1 (since cyclotomic polynomials have Mahler measure 1). This **spectral rigidity** distinguishes torus knot Alexander polynomials from those of hyperbolic knots, where the Mahler measure can take transcendental values related to hyperbolic volumes.

## 7. Future Work

1. **Jones Polynomial Spectral Theory**: Extend the framework to Jones polynomials via Temperley-Lieb algebra representations.
2. **Mahler Measure Phase Transitions**: Investigate the Mahler measure landscape for Alexander polynomials of non-torus knots.
3. **Galois-Theoretic Error Correction**: Develop error-correcting codes based on Galois symmetries of cyclotomic knot spectra.
4. **General T(m,n) Classification**: Extend the spectral classification to the full family of torus knots.

## 8. Formalization

All main results (Theorems 1–8) are formalized in Lean 4 using the Mathlib library. The formalization consists of approximately 170 lines of Lean code in `Tropical/CyclotomicKnotSpectra.lean`. Key Mathlib dependencies include:
- `Polynomial.cyclotomic` for cyclotomic polynomial definitions
- `geom_sum_mul` for the geometric series formula
- `Nat.totient_mul` for multiplicativity of Euler's totient
- `Polynomial.prod_cyclotomic_eq_X_pow_sub_one` for the cyclotomic product formula

## References

1. Alexander, J.W. (1928). "Topological invariants of knots and links." *Transactions of the AMS*, 30(2), 275–306.
2. Rolfsen, D. (1976). *Knots and Links*. Publish or Perish.
3. Lickorish, W.B.R. (1997). *An Introduction to Knot Theory*. Springer.
4. Washington, L.C. (1997). *Introduction to Cyclotomic Fields*. Springer.
5. Padgett, M.J. (2017). "Orbital angular momentum 25 years on." *Optics Express*, 25(10), 11265–11274.
