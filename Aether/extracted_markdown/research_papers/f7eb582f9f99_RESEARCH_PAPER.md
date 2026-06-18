# Hyperbolic Number Theory: Arithmetic on the Poincaré Disk

## Abstract

We develop a theory of **hyperbolic integers** based on the split-complex ring ℤ[τ] where τ² = 1, equipped with the Lorentzian norm N(a + bτ) = a² − b². This ring, the hyperbolic analog of the Gaussian integers ℤ[i], admits a rich factorization theory rooted in the Brahmagupta–Fibonacci identity for norm multiplicativity. We establish that the forward Lorentzian light cone forms a monoid under Brahmagupta composition, prove that elements with prime norm are irreducible, characterize all positive hyperbolic primes as consecutive-integer pairs (n+1, n) with 2n+1 prime, and demonstrate the infinitude of hyperbolic primes. We connect these algebraic structures to the geometry of the Poincaré disk model of hyperbolic space through conformal factor analysis and orbit counting bounds. A falsifiable density conjecture is proposed and computationally verified for N ≤ 10⁵.

**Keywords**: split-complex integers, Lorentzian norm, Brahmagupta identity, hyperbolic primes, Poincaré disk, factorization theory

---

## 1. Introduction

The study of algebraic integers in number fields has been one of the most productive branches of mathematics since Gauss's introduction of ℤ[i] in the *Disquisitiones Arithmeticae* (1801). The Gaussian integers ℤ[i] = {a + bi : a, b ∈ ℤ} carry the Euclidean norm N(a + bi) = a² + b², which is multiplicative and governs the factorization theory of the ring.

The *split-complex numbers* (also called hyperbolic numbers, double numbers, or para-complex numbers) arise by replacing i with τ satisfying τ² = +1 instead of i² = −1. The resulting ring ℤ[τ] = {a + bτ : a, b ∈ ℤ} carries the **Lorentzian norm** N(a + bτ) = a² − b², which is also multiplicative via the classical Brahmagupta–Fibonacci identity.

This paper develops the arithmetic of ℤ[τ] from the perspective of hyperbolic geometry, using the Poincaré disk model to provide geometric intuition. Our main contributions are:

1. **Split-complex integer ring** (§3): Formal definition with multiplication, conjugation, and Lorentzian norm. Complete classification of the unit group.

2. **Light cone monoid** (§4): The forward Lorentzian light cone as a multiplicative monoid, with Brahmagupta composition as the operation.

3. **Hyperbolic prime theory** (§5): Characterization of irreducible elements, structural theorem limiting positive primes to consecutive pairs, and proof of infinitude.

4. **Geometric connections** (§6): Conformal factor bounds, blowup rates, and orbit counting for hyperbolic lattices.

5. **Density conjecture** (§7): A precise, falsifiable conjecture on hyperbolic prime density with computational evidence.

## 2. Preliminaries

### 2.1 The Lorentzian Norm

**Definition 2.1.** For a, b ∈ ℤ, the *Lorentzian norm* is N(a, b) = a² − b².

**Theorem 2.2** (Brahmagupta–Fibonacci). *The Lorentzian norm is multiplicative:*
$$N(a_1, b_1) \cdot N(a_2, b_2) = N(a_1 a_2 + b_1 b_2,\; a_1 b_2 + b_1 a_2).$$

*Proof.* Direct computation: both sides equal a₁²a₂² + b₁²b₂² − a₁²b₂² − b₁²a₂². □

**Theorem 2.3** (Factorization). N(a, b) = (a + b)(a − b).

### 2.2 The Poincaré Disk

The *Poincaré disk model* represents the hyperbolic plane as the open unit disk 𝔻 = {z ∈ ℂ : |z| < 1} with the Riemannian metric ds² = 4|dz|²/(1 − |z|²)².

**Definition 2.4.** The *conformal factor* at z ∈ 𝔻 is λ(z) = 2/(1 − |z|²).

**Theorem 2.5.** λ(z) ≥ 2 for all z ∈ 𝔻, with equality iff z = 0.

*Proof.* Since |z|² ≥ 0, we have 1 − |z|² ≤ 1, so 2/(1 − |z|²) ≥ 2/1 = 2. □

## 3. The Split-Complex Integers

### 3.1 Ring Structure

**Definition 3.1.** The *split-complex integers* are ℤ[τ] = {a + bτ : a, b ∈ ℤ} with:
- Addition: (a + bτ) + (c + dτ) = (a+c) + (b+d)τ
- Multiplication: (a + bτ)(c + dτ) = (ac + bd) + (ad + bc)τ

Note that multiplication is exactly the Brahmagupta composition from Theorem 2.2.

**Definition 3.2.** The *norm* of x = a + bτ is N(x) = a² − b².

**Definition 3.3.** The *conjugate* of x = a + bτ is x̄ = a − bτ.

**Theorem 3.4** (Norm multiplicativity). *N(xy) = N(x)N(y) for all x, y ∈ ℤ[τ].*

*Proof.* Immediate from the Brahmagupta identity (Theorem 2.2). □

**Theorem 3.5** (Conjugation properties).
1. x̄̄ = x (involution)
2. (xx̄).im = 0 (product with conjugate is real)
3. (xx̄).re = N(x) (product with conjugate recovers norm)
4. N(x̄) = N(x) (norm is conjugation-invariant)

### 3.2 Unit Group

**Definition 3.6.** x ∈ ℤ[τ] is a *unit* if |N(x)| = 1, i.e., N(x) = ±1.

**Theorem 3.7** (Unit classification). *The units of ℤ[τ] are exactly {±1, ±τ}.*

*Proof.* If N(x) = a² − b² = ±1, then (a+b)(a−b) = ±1. In ℤ, the only factorizations of 1 are 1·1 and (−1)·(−1), and of −1 are 1·(−1) and (−1)·1.

- N(x) = 1: Either a+b = a−b = 1 (giving a = 1, b = 0) or a+b = a−b = −1 (giving a = −1, b = 0).
- N(x) = −1: Either a+b = 1, a−b = −1 (giving a = 0, b = 1) or a+b = −1, a−b = 1 (giving a = 0, b = −1). □

Note: ℤ[τ] has 4 units, compared to 4 for ℤ[i] and 2 for ℤ. Unlike ℤ[i], where the units form a cyclic group of order 4, the units of ℤ[τ] form the Klein four-group ℤ/2 × ℤ/2 (since τ² = 1, not τ⁴ = 1).

## 4. The Forward Light Cone Monoid

### 4.1 Definition and Closure

**Definition 4.1.** The *forward light cone* is
$$\mathcal{C}^+ = \{(a, b) \in \mathbb{Z}^2 : a > 0,\; a^2 > b^2\}.$$

**Theorem 4.2** (Closure). *If x, y ∈ C⁺, then their Brahmagupta product x·y ∈ C⁺.*

*Proof.* Let x = (a₁, b₁), y = (a₂, b₂) with aᵢ > 0 and |bᵢ| < aᵢ. The product is (a₁a₂ + b₁b₂, a₁b₂ + b₁a₂).

For positivity of the first coordinate: since |bᵢ| < aᵢ, we have a₁a₂ > |b₁||b₂| ≥ b₁b₂, so a₁a₂ + b₁b₂ > 0.

For the norm: N(x·y) = N(x)·N(y) > 0 by multiplicativity. □

**Theorem 4.3** (Identity). *(1, 0) ∈ C⁺ is the identity: (1, 0)·x = x for all x ∈ C⁺.*

### 4.2 Norm Power Theorem

**Theorem 4.4** (Norm of iterated products). *For x ∈ C⁺ and n ∈ ℕ, N(xⁿ) = N(x)ⁿ.*

*Proof.* By induction on n. Base case: N(x⁰) = N(1, 0) = 1 = N(x)⁰. Inductive step: N(xⁿ⁺¹) = N(x · xⁿ) = N(x) · N(xⁿ) = N(x) · N(x)ⁿ = N(x)ⁿ⁺¹. □

### 4.3 Irreducibility

**Theorem 4.5** (Prime norm implies irreducibility). *If x ∈ C⁺ has N(x).natAbs prime, then whenever N(x) = N(y)·N(z) for y, z ∈ C⁺, one of N(y) = 1 or N(z) = 1.*

*Proof.* Since y, z ∈ C⁺, both N(y) > 0 and N(z) > 0. The equation N(x) = N(y)·N(z) gives a factorization of a positive integer with prime absolute value into a product of positive integers. By primality, one factor must be 1. □

## 5. Hyperbolic Prime Theory

### 5.1 Consecutive Pair Characterization

**Definition 5.1.** An element x ∈ ℤ[τ] is a *hyperbolic prime* if |N(x)| is a rational prime.

**Theorem 5.2** (Consecutive norm). *N((n+1) + nτ) = 2n + 1 for all n ∈ ℤ.*

*Proof.* (n+1)² − n² = 2n + 1. □

**Theorem 5.3** (Structural theorem). *If a, b ∈ ℕ with b > 0, b < a, and a² − b² is prime, then a = b + 1.*

*Proof.* Since a² − b² = (a−b)(a+b) is prime and a+b ≥ 3 > 1, we must have a − b = 1, i.e., a = b + 1. □

**Corollary 5.4.** *The positive hyperbolic primes are in bijection with the odd rational primes: the prime p = 2n+1 corresponds to the element (n+1) + nτ.*

**Theorem 5.5** (Irreducibility of consecutive elements). *If n > 0 and 2n+1 is prime, then (n+1) + nτ has prime norm absolute value.*

### 5.2 Infinitude

**Theorem 5.6** (Infinitely many hyperbolic primes). *For every B ∈ ℕ, there exists n > 0 with 2n+1 > B and 2n+1 prime.*

*Proof.* By Euclid's theorem, there exists a prime p > max(B, 2). Since p > 2, p is odd, so p = 2n+1 for n = (p−1)/2 > 0. Then 2n+1 = p > B and p is prime. □

## 6. Geometric Connections

### 6.1 Conformal Factor Bounds

**Theorem 6.1** (Conformal minimum). *The conformal factor λ(z) = 2/(1 − |z|²) satisfies λ(z) ≥ 2 for all z in the Poincaré disk, with equality at z = 0.*

**Theorem 6.2** (Blowup rate). *For 0 ≤ r < 1, we have 1/(1−r) ≤ 2/(1−r²).*

*Proof.* Factor 1 − r² = (1−r)(1+r). Then 2/(1−r²) = 2/((1−r)(1+r)). We need 1/(1−r) ≤ 2/((1−r)(1+r)), which simplifies (after multiplying by 1−r > 0) to 1 ≤ 2/(1+r), i.e., 1+r ≤ 2, i.e., r ≤ 1. ✓ □

### 6.2 Orbit Counting

**Definition 6.3.** For a group with k generators, the *growth function* is G(k, r) = (2k+1)ʳ.

**Theorem 6.4** (Orbit counting bound). *For k ≥ 1, ∑ᵢ₌₀ᴿ G(k, i) ≤ G(k, R+1).*

*Proof.* By induction on R. Base: G(k, 0) = 1 ≤ 2k+1 = G(k, 1). Step: ∑ᵢ₌₀ᴿ⁺¹ G(k, i) = (∑ᵢ₌₀ᴿ G(k, i)) + G(k, R+1) ≤ G(k, R+1) + G(k, R+1) = 2·G(k, R+1) ≤ (2k+1)·G(k, R+1) = G(k, R+2). □

### 6.3 Modular Group

The modular group PSL(2, ℤ) is generated by S = [[0,−1],[1,0]] and T = [[1,1],[0,1]].

**Theorem 6.5** (T-power formula). *Tⁿ = [[1, n], [0, 1]] for all n ∈ ℕ.*

*Proof.* By induction. Base: T⁰ = I. Step: Tⁿ⁺¹ = T·Tⁿ = [[1,1],[0,1]]·[[1,n],[0,1]] = [[1,n+1],[0,1]]. □

## 7. The Hyperbolic Prime Density Conjecture

**Definition 7.1.** The *hyperbolic prime counting function* is
$$\pi_H(N) = |\{n \in [1, N] : 2n+1 \text{ is prime}\}|.$$

**Conjecture 7.2** (Hyperbolic prime density). *For all N ≥ 10,*
$$\frac{N}{3\lfloor\log_2 N\rfloor + 1} \leq \pi_H(N).$$

**Computational evidence:** The conjecture has been verified for all N ≤ 100,000. The ratio π_H(N) / (N/(3⌊log₂ N⌋ + 1)) stabilizes around 8.5–9.0 for large N.

| N | π_H(N) | Lower bound | Ratio |
|---|--------|-------------|-------|
| 100 | 45 | 5 | 9.00 |
| 1,000 | 302 | 35 | 8.63 |
| 10,000 | 2,261 | 250 | 9.04 |
| 100,000 | 17,983 | 2,040 | 8.82 |

**Remark.** By the Prime Number Theorem for arithmetic progressions, π_H(N) ~ N/(2 ln N) as N → ∞. Since ln N ≈ 0.693 · log₂ N, the lower bound N/(3 log₂ N + 1) ≈ N/(2.08 ln N) is slightly tighter than the asymptotic density, suggesting the conjecture may be tight for moderate N but could potentially fail for very large N. This makes it genuinely falsifiable.

## 8. Algorithms

### 8.1 Brahmagupta Multiplication

```
INPUT: (a₁, b₁), (a₂, b₂) ∈ ℤ²
OUTPUT: (a₁a₂ + b₁b₂, a₁b₂ + b₁a₂)
COMPLEXITY: O(M(n)) where M(n) is the cost of integer multiplication
```

### 8.2 Hyperbolic Prime Enumeration

```
INPUT: N ∈ ℕ
OUTPUT: List of hyperbolic primes with norm ≤ N
ALGORITHM:
  FOR n = 1 TO (N-1)/2:
    IF is_prime(2n + 1):
      OUTPUT (n+1) + nτ
COMPLEXITY: O(N · √N) using trial division, O(N · log²N · log log N) using sieve
```

## 9. Discussion

### 9.1 Comparison with Gaussian Integers

| Property | ℤ[i] | ℤ[τ] |
|----------|------|------|
| Defining relation | i² = −1 | τ² = +1 |
| Norm | a² + b² (definite) | a² − b² (indefinite) |
| Unit group | {±1, ±i} ≅ ℤ/4 | {±1, ±τ} ≅ ℤ/2 × ℤ/2 |
| Integral domain | Yes | No (zero divisors: (1+τ)(1−τ) = 0) |
| Unique factorization | Yes | Needs careful formulation |
| Geometric setting | Euclidean plane | Hyperbolic plane |

The presence of zero divisors in ℤ[τ] (namely 1 ± τ) means that unique factorization cannot hold in the naive sense. However, within the forward light cone (where the norm is positive), the factorization theory is well-behaved and parallels the Gaussian integer theory.

### 9.2 Connections to Physics

The forward light cone monoid C⁺ is precisely the set of "timelike future-pointing" vectors in (1+1)-dimensional Minkowski space, restricted to integer coordinates. The Brahmagupta multiplication corresponds to the composition of Lorentz boosts. This suggests that hyperbolic arithmetic may have applications in the study of discrete Lorentz groups and lattice models in special relativity.

## 10. Future Work

1. **Hyperbolic zeta function**: Define ζ_H(s) = Σ 1/N(x)ˢ over irreducible elements and study its analytic properties.

2. **Higher-dimensional generalizations**: Extend to ℤ[τ₁, ..., τₙ] with multiple hyperbolic units.

3. **Connections to automorphic forms**: Relate the hyperbolic prime counting function to Selberg's trace formula.

4. **Cryptographic applications**: The discrete logarithm problem in the light cone monoid as a basis for cryptographic protocols.

## References

1. Brahmagupta, *Brahmasphutasiddhanta*, 628 CE.
2. C.F. Gauss, *Disquisitiones Arithmeticae*, 1801.
3. H. Poincaré, "Théorie des groupes fuchsiens," *Acta Mathematica* 1 (1882), 1–62.
4. A. Selberg, "Harmonic analysis and discontinuous groups in weakly symmetric Riemannian spaces with applications to Dirichlet series," *J. Indian Math. Soc.* 20 (1956), 47–87.
5. I.M. Yaglom, *Complex Numbers in Geometry*, Academic Press, 1968.
6. W. Scharlau and H. Opolka, *From Fermat to Minkowski*, Springer, 1985.
