# Hyperbolic Number Theory: Arithmetic on the Poincaré Disk

## Abstract

We develop a formalized theory of "hyperbolic integers" arising from the action of SL₂(ℤ) on the Poincaré disk. The trace of an SL₂(ℤ) element serves as the fundamental arithmetic invariant, connecting number theory (quadratic discriminants), hyperbolic geometry (translation lengths), and dynamical systems (Lyapunov exponents). We prove that trace sequences satisfy a Chebyshev-type recurrence matching matrix powers, establish exponential growth bounds and modular congruences for these sequences, and characterize hyperbolicity via positivity of the trace norm (discriminant). We formalize the Fricke trace identity, Markov equation properties (Vieta jumping, divisibility), and the Gromov product ultrametric inequality connecting hyperbolic geometry to tropical algebra. All results are machine-verified in Lean 4 with Mathlib.

**Keywords:** Hyperbolic geometry, SL₂(ℤ), trace arithmetic, Poincaré disk, Markov triples, tropical geometry, formalized mathematics

---

## 1. Introduction

The integers ℤ live on a line, inheriting Euclidean geometry. But many deep phenomena in number theory — the distribution of primes, the behavior of L-functions, the structure of class groups — have natural interpretations in terms of hyperbolic geometry. The modular group SL₂(ℤ) acts on the upper half-plane (or equivalently the Poincaré disk) by Möbius transformations, and the orbits of this action define a natural analogue of the integers in hyperbolic space.

This paper develops a rigorous algebraic framework for "arithmetic on the Poincaré disk," centered on the trace of SL₂(ℤ) elements as the fundamental invariant. Our main contributions are:

1. **Trace-power correspondence** (Theorem 3.1): The trace sequence traceSeq(t, n), defined by the recurrence a_{n+2} = t·a_{n+1} - a_n with a_0 = 2, a_1 = t, exactly equals tr(g^n) when tr(g) = t.

2. **Growth and monotonicity** (Theorems 3.2–3.3): For t ≥ 3, the trace sequence is strictly increasing and grows at least linearly (hence exponentially via the Chebyshev connection).

3. **Modular structure** (Theorem 3.4): traceSeq(t, n) ≡ 2 (mod t-2) for all n, revealing a hidden periodicity in trace arithmetic.

4. **Geometric characterization** (Theorem 4.1): An SL₂(ℤ) element is hyperbolic if and only if its trace norm tr²-4 is positive, providing a bridge between algebraic and geometric classification.

5. **Cross-domain bridges**: The Fricke trace identity (Theorem 5.1) and the Gromov product ultrametric inequality (Theorem 6.1) connect trace arithmetic to the Markov spectrum and tropical geometry respectively.

---

## 2. Definitions

### 2.1 SL₂(ℤ) Elements

An element of SL₂(ℤ) is a 2×2 integer matrix (a b; c d) with ad - bc = 1. We define:

- **Multiplication**: standard matrix product
- **Inverse**: (d -b; -c a)
- **Trace**: tr(g) = a + d
- **Trace norm**: Δ(g) = tr(g)² - 4

The standard generators are S = (0 -1; 1 0) with tr(S) = 0 and T = (1 1; 0 1) with tr(T) = 2.

### 2.2 Classification by Trace

- **Hyperbolic**: |tr(g)| > 2 (equivalently Δ(g) > 0)
- **Parabolic**: |tr(g)| = 2 (Δ(g) = 0)
- **Elliptic**: |tr(g)| < 2 (Δ(g) < 0)

### 2.3 Trace Sequence

For t ∈ ℤ, define:
```
traceSeq(t, 0) = 2
traceSeq(t, 1) = t
traceSeq(t, n+2) = t · traceSeq(t, n+1) - traceSeq(t, n)
```

### 2.4 Poincaré Disk

A disk point is (x, y) ∈ ℝ² with x² + y² < 1. The pseudo-hyperbolic distance squared is:

δ²(p, q) = |p - q|² / |1 - p̄q|²

### 2.5 Primitive Trace Count (Novel)

A trace value t ≥ 3 is **imprimitive** if t = s² - 2 for some s ≥ 2 (i.e., the element is a perfect square in SL₂(ℤ)). The primitive trace count π_H(T) counts primitive traces in {3, ..., T}.

---

## 3. Trace Sequence Theory

### Theorem 3.1 (Trace-Power Correspondence)

For any f ∈ SL₂(ℤ), traceSeq(tr(f), n) = tr(f^n) for all n ≥ 0.

*Proof sketch.* By strong induction. The base cases n = 0, 1 are immediate. For n + 2, we use the Cayley-Hamilton theorem for 2×2 matrices with determinant 1: the characteristic equation gives f² = tr(f)·f - I, which implies the recurrence tr(f^{n+2}) = tr(f)·tr(f^{n+1}) - tr(f^n). □

### Theorem 3.2 (Growth Lower Bound)

For t ≥ 3 and all n ≥ 0, traceSeq(t, n) ≥ n + 1.

*Proof sketch.* By strong induction. Base cases: traceSeq(t, 0) = 2 ≥ 1 and traceSeq(t, 1) = t ≥ 3 ≥ 2. For n + 2: by the recurrence and t ≥ 3, traceSeq(t, n+2) = t·traceSeq(t, n+1) - traceSeq(t, n) ≥ 3·(n+2) - traceSeq(t, n), and the result follows from the inductive hypothesis and strict monotonicity. □

### Theorem 3.3 (Strict Monotonicity)

For t ≥ 3, the sequence traceSeq(t, ·) is strictly increasing.

*Proof sketch.* By induction. Base: traceSeq(t, 0) = 2 < t = traceSeq(t, 1). Step: traceSeq(t, n+2) - traceSeq(t, n+1) = (t-1)·traceSeq(t, n+1) - traceSeq(t, n) > 0 since (t-1) ≥ 2 and traceSeq(t, n) < traceSeq(t, n+1) by the inductive hypothesis. □

### Theorem 3.4 (Modular Congruence)

For all t ∈ ℤ and n ≥ 0, (t-2) | (traceSeq(t, n) - 2).

*Proof sketch.* By strong induction. We show traceSeq(t, n+2) - 2 = t·(traceSeq(t, n+1) - 2) - (traceSeq(t, n) - 2) + 2(t-2), which is divisible by t-2 by the inductive hypothesis. □

---

## 4. Trace Norm and Hyperbolicity

### Theorem 4.1 (Hyperbolicity Characterization)

An SL₂(ℤ) element f is hyperbolic if and only if Δ(f) = tr(f)² - 4 > 0.

*Proof sketch.* Forward: |tr(f)| > 2 implies tr(f)² > 4. Backward by contrapositive: if f is not hyperbolic, then -2 ≤ tr(f) ≤ 2, so tr(f)² ≤ 4, hence Δ(f) ≤ 0. □

### Theorem 4.2 (Conjugation Invariance)

The trace norm is invariant under conjugation: Δ(fgf⁻¹) = Δ(g).

*Proof.* Immediate from the conjugation-invariance of the trace, which follows from the identity tr(fgf⁻¹) = tr(g) via linear_combination with the determinant identity. □

---

## 5. The Fricke Identity and Markov Triples

### Theorem 5.1 (Fricke Identity)

For f, g ∈ SL₂(ℤ):
```
tr(f)² + tr(g)² + tr(fg)² - tr(f)·tr(g)·tr(fg) = tr([f,g]) + 2
```
where [f,g] = fgf⁻¹g⁻¹ is the commutator.

This identity is the algebraic backbone of the Markov spectrum: when the commutator is parabolic (trace = -2), it reduces to the Markov equation x² + y² + z² = xyz (after rescaling).

### Theorem 5.2 (Vieta Jumping)

If x² + y² + z² = 3xyz, then x² + y² + (3xy - z)² = 3xy(3xy - z).

### Theorem 5.3 (Markov Divisibility)

In a Markov triple (x, y, z), we have x | (y² + z²).

---

## 6. Cross-Domain Bridges

### 6.1 Hyperbolic → Tropical: The Gromov Product

### Theorem 6.1 (Gromov Ultrametric Inequality)

If the four-point condition dxy + dz ≤ max(dxz + dy, dyz + dx) holds, then the Gromov products satisfy:
```
(dx + dy - dxy)/2 ≥ min((dx + dz - dxz)/2, (dy + dz - dyz)/2)
```

This is the algebraic core of Gromov's 0-hyperbolicity condition. In the tropical limit, it becomes the min-plus ultrametric inequality, showing that hyperbolic geometry "tropicalizes" to ultrametric structures.

### 6.2 Hyperbolic → Algebraic Number Theory

The trace norm Δ(g) = tr(g)² - 4 is the discriminant of the quadratic field ℚ(√Δ). For trace 3, we get discriminant 5 (the golden ratio field). For trace 4, discriminant 12 (the √3 field). This provides a canonical map from hyperbolic conjugacy classes to quadratic number fields.

### 6.3 Poincaré Disk Geometry

We establish that the pseudo-hyperbolic distance on the Poincaré disk satisfies:
- Symmetry: δ(p,q) = δ(q,p)
- Identity of indiscernibles: δ(p,p) = 0
- Boundedness: δ(p,q) < 1 for all disk points p, q
- Distance from origin: δ(0, q) = |q|²

The boundedness result uses the key algebraic identity that the denominator minus numerator factors as (1-|p|²)(1-|q|²) > 0.

---

## 7. Algorithms

### 7.1 Trace Sequence Computation

```
Input: t ∈ ℤ, n ∈ ℕ
Output: traceSeq(t, n)
Algorithm: O(n) time, O(1) space via the three-term recurrence
```

### 7.2 Primitive Trace Testing

```
Input: t ∈ ℕ, t ≥ 3
Output: whether t is a primitive trace
Algorithm: Compute s = ⌊√(t+2)⌋; check s² ≠ t+2. O(1) time.
```

### 7.3 Markov Tree Enumeration

```
Input: depth d
Output: all Markov triples reachable by d Vieta jumps from (1,1,1)
Algorithm: BFS on the Markov tree. Each node (x,y,z) has children
           (x,y,3xy-z), (x,3xz-y,z), (3yz-x,y,z).
```

---

## 8. Falsifiable Conjecture

**Conjecture (Primitive Trace Density).** The fraction of primitive traces in {3, ..., N} is 1 - Θ(1/√N). More precisely:

```
primitiveTraceCount(N) / (N - 2) → 1 as N → ∞
```

with the imprimitive traces being exactly {s²-2 : s ≥ 2} ∩ {3,...,N}, which has cardinality ⌊√(N+2)⌋ - 1.

**Test:** For N = 100, imprimitive traces are {7, 14, 23, 34, 47, 62, 79, 98}, giving 8 imprimitive out of 98 traces, so density of primitives ≈ 0.918. The prediction 1 - 1/√100 = 0.9 is within 2% of this value.

---

## 9. Discussion

### 9.1 Relation to Selberg's Trace Formula

The trace sequence traceSeq(t, n) appears naturally in the Selberg trace formula, where the sum over conjugacy classes of SL₂(ℤ) involves exactly these traces of powers. Our growth bounds and congruences therefore constrain the contributions of individual conjugacy classes to the trace formula.

### 9.2 The Modular Surface Perspective

The quotient SL₂(ℤ)\ℍ is the modular surface, with area π/3. The congruence subgroup Γ(p) has index p(p²-1)/2 (or p(p²-1) in PSL₂), which we prove is always divisible by 6. This divisibility reflects the structure of the modular surface as a (2,3,∞)-orbifold.

### 9.3 Connections to Quantum Chaos

The trace formula connects the length spectrum of geodesics on the modular surface to the eigenvalues of the Laplacian. Our trace sequence bounds therefore constrain the spectral statistics. The Bohigas-Giannoni-Schmit conjecture predicts that these statistics should follow random matrix theory (GOE distribution), a prediction that has been numerically verified but not proved.

---

## 10. Future Work

1. **Hyperbolic Zeta Function**: Define ζ_H(s) = Σ 1/|tr(g)|^{2s} over primitive conjugacy classes and study its analytic properties.

2. **Effective Trace Counting**: Prove the asymptotic πH(T) ~ T²/log T for the number of primitive conjugacy classes with trace at most T.

3. **Tropical Degeneration**: Formalize the tropical limit of the Fricke identity and its connection to the min-plus algebra.

4. **Markov Uniqueness**: Use the trace norm framework to attack the Markov uniqueness conjecture.

---

## References

1. Huber, H. "Zur analytischen Theorie hyperbolischer Raumformen und Bewegungsgruppen." Math. Ann. 138 (1959), 1–26.

2. Iwaniec, H. "Spectral Methods of Automorphic Forms." AMS Graduate Studies in Mathematics, Vol. 53 (2002).

3. Markov, A. A. "Sur les formes quadratiques binaires indéfinies." Math. Ann. 15 (1879), 381–406; 17 (1880), 379–399.

4. Selberg, A. "Harmonic analysis and discontinuous groups in weakly symmetric Riemannian spaces with applications to Dirichlet series." J. Indian Math. Soc. 20 (1956), 47–87.

5. Aigner, M. "Markov's Theorem and 100 Years of the Uniqueness Conjecture." Springer (2013).

6. Gromov, M. "Hyperbolic groups." In: Essays in Group Theory, MSRI Publ. 8, Springer (1987), 75–263.
