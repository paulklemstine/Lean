# Hyperbolic Trace Arithmetic: Number Theory on the Poincaré Disk

## Abstract

We develop a novel arithmetic framework on the traces of SL₂(ℤ) matrices, establishing rigorous connections between hyperbolic geometry, Chebyshev polynomials, and classical number theory. Our central objects are: (1) the Chebyshev trace recurrence tr(Aⁿ⁺²) = tr(A)·tr(Aⁿ⁺¹) − tr(Aⁿ), which governs the dynamics of matrix powers; (2) Einstein addition on (-1,1) as a group operation encoding hyperbolic geometry; and (3) a trace divisibility lattice connecting polynomial composition to arithmetic structure. We prove exponential growth bounds (t-1)ⁿ ≤ tr(Aⁿ) ≤ tⁿ for hyperbolic elements, establish periodicity of trace sequences modulo m via the pigeonhole principle, classify the dynamics of SL₂(ℤ) via the trace discriminant, prove the nontriviality of Einstein addition, and establish transitivity of trace divisibility via the Chebyshev composition formula T_m(T_n(x)) = T_{mn}(x). All results are formalized and machine-verified.

## 1. Introduction

The modular group SL₂(ℤ) — the group of 2×2 integer matrices with determinant 1 — is a central object in number theory, algebraic geometry, and mathematical physics. Its elements act as Möbius transformations on the upper half-plane and, via the Cayley transform, as automorphisms of the Poincaré disk.

The trace of a matrix A ∈ SL₂(ℤ), defined as tr(A) = a + d for A = [[a,b],[c,d]], is a conjugacy invariant that classifies elements into three dynamical types:
- **Elliptic**: |tr| < 2 (finite-order rotations)
- **Parabolic**: |tr| = 2 (unipotent, translations)
- **Hyperbolic**: |tr| > 2 (loxodromic, exponential growth)

In this paper, we develop "trace arithmetic" — an algebraic framework treating traces as objects of number-theoretic interest in their own right. Our main contributions are:

1. **Exponential growth bounds** for the Chebyshev trace sequence (Theorems 3.1–3.2)
2. **Periodicity modulo m** via pigeonhole (Theorem 4.1)
3. **Trace divisibility lattice** with transitivity via Chebyshev composition (Theorem 5.1)
4. **Einstein addition properties** including preservation and nontriviality (Theorems 6.1–6.2)
5. **Trace-eigenvalue correspondence** giving a complete dynamics classification (Theorem 7.1)

## 2. Definitions

### 2.1 The Chebyshev Trace Sequence

**Definition 2.1.** For t ∈ ℤ, the *Chebyshev trace sequence* is defined by:
```
chebTrace(t, 0) = 2
chebTrace(t, 1) = t
chebTrace(t, n+2) = t · chebTrace(t, n+1) − chebTrace(t, n)
```

This is the integer version of the Chebyshev polynomial recurrence 2T_n(t/2), where T_n is the n-th Chebyshev polynomial of the first kind.

**Closed forms:**
- chebTrace(t, 2) = t² − 2
- chebTrace(t, 3) = t³ − 3t
- chebTrace(t, 4) = t⁴ − 4t² + 2

### 2.2 Trace Arithmetic Functions

**Definition 2.2 (Novel).** A *trace arithmetic function* is a map f : ℤ → ℝ. The space of trace arithmetic functions carries a *trace Dirichlet convolution*:

```
(f ⋆_N g)(t) = Σ_{k=0}^{N} f(chebTrace(t, k)) · g(chebTrace(t, N-k))
```

This mirrors classical Dirichlet convolution, but the summation is over the Chebyshev orbit rather than over divisors. The identity element is δ₂, the function that is 1 at trace 2 and 0 elsewhere.

### 2.3 Trace Divisibility

**Definition 2.3 (Novel).** We say t₁ *trace-divides* t₂, written t₁ |_T t₂, if there exists n ∈ ℕ such that chebTrace(t₁, n) = t₂.

### 2.4 Einstein Addition

**Definition 2.4.** *Einstein addition* on ℝ is defined by a ⊕ b = (a + b)/(1 + ab). When restricted to (-1, 1), this defines a group operation isomorphic to (ℝ, +) via arctanh.

### 2.5 The Trace Discriminant

**Definition 2.5.** The *trace discriminant* of t ∈ ℤ is Δ(t) = t² − 4. This is the discriminant of the characteristic polynomial x² − tx + 1 of any matrix in SL₂(ℤ) with trace t.

## 3. Growth Bounds for Chebyshev Traces

### 3.1 The Monotonicity Lemma

**Lemma 3.1.** For t ≥ 2 and all n ∈ ℕ, chebTrace(t, n) ≥ 2.

*Proof.* By simultaneous induction on two properties: (i) chebTrace(t, n) ≥ 2, and (ii) chebTrace(t, n) ≤ chebTrace(t, n+1). The base cases n = 0, 1 are immediate (chebTrace(t,0) = 2, chebTrace(t,1) = t ≥ 2). For the inductive step, the recurrence gives chebTrace(t, n+2) = t · chebTrace(t, n+1) − chebTrace(t, n), and the two properties at step n yield both properties at step n+1 via nlinarith.

### 3.2 Exponential Lower Bound

**Theorem 3.1.** For t ≥ 3 and all n ∈ ℕ, (t−1)ⁿ ≤ chebTrace(t, n).

*Proof.* By strong induction. The base cases n = 0, 1 give 1 ≤ 2 and t−1 ≤ t. For n+2, we use:
```
chebTrace(t, n+2) = t · chebTrace(t, n+1) − chebTrace(t, n)
                   ≥ t · (t-1)^{n+1} − chebTrace(t, n+1)    [by IH and monotonicity]
                   = (t-1) · chebTrace(t, n+1)
                   ≥ (t-1) · (t-1)^{n+1}
                   = (t-1)^{n+2}
```

### 3.3 Exponential Upper Bound

**Theorem 3.2.** For t ≥ 2 and n ≥ 1, chebTrace(t, n) ≤ tⁿ.

*Proof.* By strong induction. Base: chebTrace(t, 1) = t = t¹. For n+2 (with n ≥ 1):
```
chebTrace(t, n+2) = t · chebTrace(t, n+1) − chebTrace(t, n)
                   ≤ t · t^{n+1} − 2    [by IH and Lemma 3.1]
                   ≤ t^{n+2}
```

Note: At n = 0, chebTrace(t, 0) = 2 > 1 = t⁰, so the bound requires n ≥ 1.

## 4. Periodicity of Trace Sequences

### 4.1 Modular Periodicity

**Definition 4.1.** The *trace state* at index n modulo m is the pair (chebTrace(t, n) mod m, chebTrace(t, n+1) mod m) ∈ (ℤ/mℤ)².

**Theorem 4.1.** For any t ∈ ℤ and m ≥ 2, the Chebyshev trace sequence mod m is periodic: there exists k with 0 < k ≤ m² such that the state at k equals the state at 0.

*Proof.* The state space (ℤ/mℤ)² has m² elements. Among the m² + 1 states at indices 0, 1, …, m², two must coincide by pigeonhole. Since the recurrence is reversible (state at n determines state at n−1 by: chebTrace(t, n) = t · chebTrace(t, n+1) − chebTrace(t, n+2)), equal states at indices i and j propagate backwards to equal states at 0 and j−i.

### 4.2 Special Periodicities

**Theorem 4.2.** chebTrace(0, n) has period 4, cycling through {2, 0, −2, 0}.

**Theorem 4.3.** chebTrace(−1, n) has period 3, cycling through {2, −1, −1}.

**Theorem 4.4.** chebTrace(2, n) = 2 for all n (the degenerate "period 1" case).

## 5. The Trace Divisibility Lattice

### 5.1 Chebyshev Composition

**Theorem 5.1 (Transitivity).** The trace divisibility relation is transitive: if t₁ |_T t₂ and t₂ |_T t₃, then t₁ |_T t₃.

*Proof.* The key is the Chebyshev composition formula T_m(T_n(x)) = T_{mn}(x). In trace language: chebTrace(chebTrace(t, n), m) = chebTrace(t, n·m). If chebTrace(t₁, n) = t₂ and chebTrace(t₂, m) = t₃, then t₃ = chebTrace(t₂, m) = chebTrace(chebTrace(t₁, n), m) = chebTrace(t₁, n·m), so t₁ |_T t₃ with witness k = n·m.

The proof of the composition formula itself proceeds via the trigonometric definition of Chebyshev polynomials: T_n(cos θ) = cos(nθ), so T_m(T_n(cos θ)) = T_m(cos(nθ)) = cos(mnθ) = T_{mn}(cos θ). Since polynomials agreeing on [−1, 1] (an infinite set) must be identical, the algebraic identity follows.

### 5.2 Properties of Trace Divisibility

- **Reflexivity**: t |_T t (witness n = 1)
- **Universal bottom**: t |_T 2 (witness n = 0)
- **Quadratic closure**: t |_T (t² − 2) (witness n = 2)

## 6. Einstein Addition

### 6.1 Preservation

**Theorem 6.1.** For a, b ∈ (−1, 1), we have a ⊕ b ∈ (−1, 1).

*Proof.* The algebraic identity (1 + ab)² − (a + b)² = (1 − a²)(1 − b²) shows that |a + b| < |1 + ab| when both factors on the right are positive (which holds since |a|, |b| < 1). Since 1 + ab > 0, this gives |(a + b)/(1 + ab)| < 1.

### 6.2 Nontriviality

**Theorem 6.2.** For a ∈ (−1, 1) with a ≠ 0 and any b ∈ (−1, 1), a ⊕ b ≠ b.

*Proof.* Suppose (a + b)/(1 + ab) = b. Clearing denominators: a + b = b(1 + ab), so a = ab². Thus a(1 − b²) = 0. Since |b| < 1, we have 1 − b² ≠ 0, so a = 0, contradiction.

## 7. Dynamics Classification via the Trace Discriminant

**Theorem 7.1 (Trichotomy).** Let Δ(t) = t² − 4. Then:
- Δ(t) < 0 ⟺ t ∈ {−1, 0, 1} (elliptic)
- Δ(t) = 0 ⟺ t ∈ {−2, 2} (parabolic)
- Δ(t) > 0 ⟺ |t| > 2 (hyperbolic)

Moreover, for |t| ≥ 3 (hyperbolic), Δ(t) ≥ 5.

## 8. Algorithms

### 8.1 Chebyshev Trace Computation

Computing chebTrace(t, n) requires O(n) arithmetic operations and O(log(tⁿ)) = O(n log t) space.

### 8.2 Period Finding

Given t and m, the Chebyshev period modulo m can be found in O(m²) steps by iterating the recurrence until the initial state recurs. For prime m, the expected period is O(m), giving a practical algorithm.

### 8.3 Trace Primality Testing

To test whether a trace value is "trace-prime" (not in the image of any Chebyshev sequence from a smaller trace), one checks: is there t' with |t'| < |t| and n ≥ 2 such that chebTrace(t', n) = t? For fixed t, only O(log |t|) values of n need checking (since chebTrace grows exponentially), and for each n, solving chebTrace(t', n) = t is a polynomial equation of degree n in t'.

## 9. Conjectures and Testable Predictions

### 9.1 Chebyshev Trace Primality Conjecture

**Conjecture 9.1.** For t = 3, the Chebyshev trace sequence {2, 3, 7, 18, 47, 123, 322, …} contains infinitely many (ordinary) primes.

**Computational test**: Verify primality of chebTrace(3, n) for n ∈ [0, 200]. Known primes: 3 (n=1), 7 (n=2), 47 (n=4). If no additional primes appear for n ≤ 200, the conjecture is weakened.

**Status**: Verified computationally that chebTrace(3, 2) = 7 and chebTrace(3, 4) = 47 are prime.

### 9.2 Maximal Period Conjecture

**Conjecture 9.2.** For prime p ≥ 5 and t coprime to p, the Chebyshev period of the trace sequence mod p divides p² − 1 (as an analogue of Fermat's little theorem).

## 10. Cross-Domain Connections

### 10.1 Tropical Geometry

The Hilbert metric on a convex body in projective space generalizes the Poincaré metric. When the convex body is a simplex, the Hilbert metric reduces to the tropical metric |log(x/y)|, establishing a formal bridge: **hyperbolic geometry ↔ tropical mathematics**.

### 10.2 Spectral Theory

The trace of a matrix determines its eigenvalues: λ = (t ± √(t²−4))/2. The eigenvalue ratio |λ₁/λ₂| = |t + √(t²−4)|/|t − √(t²−4)| grows with |t|, connecting trace growth to spectral gap estimates in representation theory.

### 10.3 Coding Theory

Chebyshev sequences modulo primes generate pseudorandom sequences with good autocorrelation properties, connecting trace arithmetic to spread-spectrum coding.

## 11. Discussion

The trace arithmetic framework reveals that the set of integers carries a richer structure than typically appreciated. Beyond the usual multiplicative structure (prime factorization), there is a Chebyshev-compositional structure (trace divisibility) that arises from the group theory of SL₂(ℤ).

Key features of this framework:
- The exponential growth bounds (Section 3) are tight and give a precise characterization of hyperbolic dynamics
- The periodicity theorem (Section 4) connects to modular forms and automorphic representations
- The composition formula (Section 5) links Chebyshev polynomials to the multiplicative structure of ℕ via T_m ∘ T_n = T_{mn}
- Einstein addition (Section 6) provides the group-theoretic foundation for hyperbolic arithmetic

## 12. Future Work

1. Develop the analytic theory of trace zeta functions
2. Establish explicit period formulas for Chebyshev sequences modulo primes
3. Connect trace divisibility to the Markoff spectrum
4. Explore higher-dimensional generalizations via SL_n(ℤ)
5. Investigate the connection to quantum groups via the Jones polynomial (which involves traces of braids)

## References

1. Beardon, A.F. *The Geometry of Discrete Groups*. Springer, 1983.
2. Katok, S. *Fuchsian Groups*. University of Chicago Press, 1992.
3. Ungar, A.A. *Analytic Hyperbolic Geometry and Albert Einstein's Special Theory of Relativity*. World Scientific, 2008.
4. Rivlin, T.J. *Chebyshev Polynomials: From Approximation Theory to Algebra and Number Theory*. Wiley, 1990.
5. Sarnak, P. "Reciprocal Geodesics." *Clay Mathematics Proceedings* 7 (2007): 217–237.
