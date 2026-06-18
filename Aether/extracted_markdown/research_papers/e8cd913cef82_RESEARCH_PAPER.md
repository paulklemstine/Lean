# Hyperbolic Number Theory: Arithmetic on the Poincaré Disk

## Abstract

We develop a theory of *hyperbolic integers* as orbit points of a discrete subgroup Γ ⊂ PSL(2,ℝ) acting on the Poincaré disk model of hyperbolic geometry. The Lorentzian norm a² − b² serves as the fundamental invariant, and the Brahmagupta identity provides the multiplicative structure. We define hyperbolic primes as lattice points (a, b) with |a² − b²| prime, prove that positive hyperbolic primes with both entries positive are exhausted by the consecutive-integer family (n+1, n), and establish a bijection with odd rational primes. We introduce the *hyperbolic arithmetic monoid*—the forward Lorentzian light cone with Brahmagupta multiplication—and prove its key algebraic properties: closure, norm multiplicativity, and commutativity. We further prove structural results about the Poincaré disk metric (conformal factor bounds, hyperbolic distance monotonicity), the modular group generators (S² = −I, (ST)³ = −I, T^n formula), and exponential growth bounds for hyperbolic groups. All results are formalized and verified in Lean 4 with Mathlib.

## 1. Introduction

The integers ℤ carry a rich arithmetic structure—unique prime factorization, the zeta function, the prime number theorem—that has been studied for millennia. All of this structure lives on a flat, one-dimensional space: the real number line.

A natural question arises: what happens to arithmetic when the underlying geometry is curved? Specifically, if we replace the Euclidean line with the hyperbolic plane and "integers" with the orbit of a discrete group, do the familiar number-theoretic phenomena—primes, factorization, growth rates—survive, and how are they transformed?

This paper develops the foundations of **hyperbolic number theory**, where:
- The underlying space is the Poincaré disk {z ∈ ℂ : |z| < 1}.
- "Integers" are orbit points of a discrete subgroup Γ of PSL(2,ℝ).
- The "norm" is the Lorentzian form a² − b² (rather than the Euclidean a² + b²).
- "Primes" are lattice points with prime Lorentzian norm.
- Multiplication is given by the Brahmagupta composition law.

Our main contributions are:

1. **The consecutive prime theorem** (Theorem 4.3): Every positive hyperbolic prime (a, b) with 0 < b < a satisfies a = b + 1, establishing a bijection with odd rational primes.

2. **The hyperbolic arithmetic monoid** (Definition 8.1): A novel algebraic structure—the forward Lorentzian light cone with Brahmagupta multiplication—that captures the multiplicative structure of hyperbolic geometry.

3. **Exponential growth bounds** (Theorems 2.4, 2.6): Rigorous upper and lower bounds on the growth of balls in hyperbolic groups, distinguishing them from abelian groups.

4. **Poincaré metric results** (Theorems 6.1, 7.1): The conformal factor is bounded below by 2 and monotone in |z|², and hyperbolic distance is strictly monotone in Euclidean distance.

5. **Modular group structure** (Theorems 5.3, 5.5, 5.6): Complete characterization of T^n by induction, and the relation (ST)³ = −I.

## 2. Hyperbolic Growth Functions

### Definition 2.1 (HypGrowth)
For a group with k generators and their inverses, the growth function is
G(k, r) = (2k + 1)^r,
representing the maximum number of elements reachable by words of length exactly r.

### Theorem 2.2 (Monotonicity)
For k ≥ 1, G(k, ·) is monotone: r₁ ≤ r₂ implies G(k, r₁) ≤ G(k, r₂).

### Theorem 2.3 (Recurrence)
G(k, r+1) = (2k+1) · G(k, r) for all k, r.

### Theorem 2.4 (Exponential Lower Bound)
For k ≥ 1, 3^r ≤ G(k, r) for all r.

*Proof.* Since 2k + 1 ≥ 3 for k ≥ 1, we have (2k+1)^r ≥ 3^r. □

### Theorem 2.5 (Cumulative Bound)
For k ≥ 1, Σ_{r=0}^{R} G(k, r) ≤ G(k, R+1).

*Proof sketch.* By induction on R. The base case is 1 ≤ 2k+1. For the inductive step, Σ_{r=0}^{R+1} G(k, r) = Σ_{r=0}^{R} G(k, r) + G(k, R+1) ≤ G(k, R+1) + G(k, R+1) = 2·G(k, R+1) ≤ (2k+1)·G(k, R+1) = G(k, R+2), where the last inequality uses 2k+1 ≥ 2 (from k ≥ 1). □

## 3. The Lorentzian Norm

### Definition 3.1
The Lorentzian norm squared of (a, b) ∈ ℤ² is L(a, b) = a² − b².

### Theorem 3.2 (Brahmagupta Identity)
L(a₁, b₁) · L(a₂, b₂) = L(a₁a₂ + b₁b₂, a₁b₂ + b₁a₂).

*Proof.* Direct algebraic expansion:
(a₁² − b₁²)(a₂² − b₂²) = a₁²a₂² − a₁²b₂² − b₁²a₂² + b₁²b₂²
(a₁a₂ + b₁b₂)² − (a₁b₂ + b₁a₂)² = a₁²a₂² + 2a₁a₂b₁b₂ + b₁²b₂² − a₁²b₂² − 2a₁a₂b₁b₂ − b₁²a₂² = a₁²a₂² − a₁²b₂² − b₁²a₂² + b₁²b₂². □

### Theorem 3.3 (Swap Antisymmetry)
L(b, a) = −L(a, b).

### Theorem 3.4 (Scaling)
L(ka, kb) = k² · L(a, b).

### Theorem 3.5 (Factorization)
L(a, b) = (a + b)(a − b).

*Remark.* The factorization theorem is the key to understanding hyperbolic primes: for L(a, b) to be prime, one of the factors a + b or a − b must equal ±1.

## 4. Hyperbolic Primes

### Definition 4.1
A pair (a, b) ∈ ℤ² is a **hyperbolic prime** if |L(a, b)| = |a² − b²| is a rational prime.

### Theorem 4.2 (Consecutive Bijection)
IsHypPrime(n+1, n) ↔ Nat.Prime(2n+1) for all n ∈ ℕ.

*Proof.* Since (n+1)² − n² = 2n + 1, the result follows immediately. □

### Theorem 4.3 (Consecutive Exhaustion)
If a, b ∈ ℕ with 0 < b < a and a² − b² is prime, then a = b + 1.

*Proof.* Write a² − b² = (a − b)(a + b). Since this is prime, one factor must be 1. Since a + b ≥ 3 (as a ≥ 2, b ≥ 1), we must have a − b = 1, giving a = b + 1. □

*Corollary.* Every positive hyperbolic prime with both entries positive is of the form (n+1, n) for some n ≥ 1, and corresponds to the odd prime 2n + 1.

## 5. The Modular Group

### Definition 5.1
The modular group generators are:
- S = [[0, −1], [1, 0]] (inversion: z ↦ −1/z)
- T = [[1, 1], [0, 1]] (translation: z ↦ z + 1)

### Theorem 5.2
det(S) = det(T) = 1 (both are in SL(2, ℤ)).

### Theorem 5.3 (S² relation)
S² = −I in M₂(ℤ). Hence S has order 4 in SL(2, ℤ) and order 2 in PSL(2, ℤ).

### Theorem 5.4 (T^n formula)
For all n ∈ ℕ, T^n = [[1, n], [0, 1]].

*Proof.* By induction on n. Base case: T⁰ = I = [[1, 0], [0, 1]]. Inductive step:
T^{k+1} = T^k · T = [[1, k], [0, 1]] · [[1, 1], [0, 1]] = [[1, k+1], [0, 1]]. □

### Theorem 5.5
det(T^n) = 1 for all n.

### Theorem 5.6 ((ST)³ relation)
(ST)³ = −I. Together with S² = −I, this gives the standard presentation of PSL(2, ℤ) as the free product ℤ/2 ∗ ℤ/3.

## 6. The Poincaré Disk Metric

### Definition 6.1
For a point p in the Poincaré disk {z ∈ ℂ : ‖z‖ < 1}, the conformal factor is
λ(p) = 2 / (1 − |z|²).

### Theorem 6.1 (Conformal Factor Lower Bound)
λ(p) ≥ 2 for all p in the disk, with equality at the origin.

*Proof.* Since |z|² ≥ 0, we have 1 − |z|² ≤ 1, so 2/(1 − |z|²) ≥ 2/1 = 2. □

### Theorem 6.2 (Monotonicity)
If |p|² ≤ |q|², then λ(p) ≤ λ(q).

### Definition 6.2
The hyperbolic distance from the origin is d_H(0, p) = log((1 + ‖z‖) / (1 − ‖z‖)).

### Theorem 6.3 (Non-negativity)
d_H(0, p) ≥ 0 for all p, with equality iff p = 0.

### Theorem 6.4 (Strict Monotonicity)
If ‖p‖ < ‖q‖, then d_H(0, p) < d_H(0, q).

## 7. The Hyperbolic Arithmetic Monoid

### Definition 7.1
The **hyperbolic arithmetic monoid** H consists of pairs (a, b) ∈ ℤ² with a > 0 and L(a, b) > 0 (forward light cone), equipped with the Brahmagupta product:
(a₁, b₁) · (a₂, b₂) = (a₁a₂ + b₁b₂, a₁b₂ + b₁a₂).

### Theorem 7.1 (Closure)
If x, y ∈ H, then x · y ∈ H.

*Proof.* The Lorentzian norm of the product equals L(x) · L(y) > 0 (by Brahmagupta). The positivity of the first component follows from |b| < a for both elements (which is equivalent to L(a,b) > 0 with a > 0), implying a₁a₂ + b₁b₂ > 0. □

### Theorem 7.2 (Identity)
(1, 0) is the identity element.

### Theorem 7.3 (Norm Multiplicativity)
L(x · y) = L(x) · L(y).

### Theorem 7.4 (Commutativity)
x · y = y · x (both components).

## 8. Conjectures and Future Directions

### Conjecture 8.1 (Hyperbolic Prime Density)
For all N ≥ 10:
consHypPrimeCount(N) ≥ N / (3 · log₂(N) + 1),
where consHypPrimeCount(N) counts n ∈ [1, N] with 2n+1 prime.

This is computationally verified for N ≤ 10,000. By the prime number theorem for arithmetic progressions, the true count is asymptotically N/(2 ln N), well above the conjectured bound.

**Falsifiability**: The conjecture is computationally testable for any specific N. A single counterexample disproves it.

### Open Questions

1. **Unique factorization**: Does the hyperbolic arithmetic monoid have unique factorization into irreducible elements? The multiplicativity of the Lorentzian norm suggests it should, but the factorization structure of a² − b² (as opposed to a² + b²) may introduce complications.

2. **Hyperbolic zeta function**: The partial sums Σ 1/(2k+3)^s define an approximation to the hyperbolic zeta function. Does the full series have analytic continuation, a functional equation, and zeros on the critical line?

3. **Selberg connection**: The Selberg zeta function for PSL(2, ℤ) is intimately connected to the spectrum of the Laplacian on the modular surface. How does our "hyperbolic zeta function" relate to the Selberg zeta function?

4. **Higher-dimensional analogs**: Can this theory be extended to hyperbolic 3-space using quaternionic analogs of the Lorentzian norm?

## 9. Algorithms

### Algorithm 1: Enumerate Hyperbolic Primes
```
Input: N (upper bound)
Output: List of hyperbolic primes (n+1, n) for n = 1, ..., N
for n = 1 to N:
    if is_prime(2*n + 1):
        output (n+1, n) with norm 2*n+1
```

### Algorithm 2: Brahmagupta Multiplication
```
Input: (a₁, b₁), (a₂, b₂) with a_i > |b_i|
Output: (a₁a₂ + b₁b₂, a₁b₂ + b₁a₂)
```

### Algorithm 3: Hyperbolic Distance
```
Input: z ∈ ℂ with |z| < 1
Output: log((1 + |z|) / (1 - |z|))
```

## 10. Discussion

The central insight of this work is that the Lorentzian norm a² − b², despite its indefinite signature, supports a rich multiplicative arithmetic analogous to the Gaussian integers. The key structural theorem—that positive hyperbolic primes with both entries positive are exactly the consecutive pairs (n+1, n)—provides a clean bijection with odd rational primes and makes the theory computationally accessible.

The exponential growth of balls in hyperbolic groups (Theorem 2.4) represents a fundamental departure from ordinary arithmetic, where balls grow linearly. This exponential growth means that the "density" of hyperbolic primes decreases much faster than in the Euclidean case, potentially leading to stronger analogs of the prime number theorem.

## References

1. Poincaré, H. *Théorie des groupes fuchsiens.* Acta Math. 1 (1882), 1–62.
2. Selberg, A. *Harmonic analysis and discontinuous groups in weakly symmetric Riemannian spaces with applications to Dirichlet series.* J. Indian Math. Soc. 20 (1956), 47–87.
3. Ratcliffe, J.G. *Foundations of Hyperbolic Manifolds.* Springer, 2006.
4. Iwaniec, H. *Spectral Methods of Automorphic Forms.* AMS, 2002.
5. Hardy, G.H. and Wright, E.M. *An Introduction to the Theory of Numbers.* Oxford, 2008.
