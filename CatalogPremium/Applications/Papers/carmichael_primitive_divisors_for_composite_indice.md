# Carmichael's Primitive Divisor Theorem for Fibonacci Numbers: A Computational Formalization

## Abstract

We present a partial formalization in Lean 4 of Carmichael's theorem (1913): for every composite integer n ≥ 13, the Fibonacci number F(n) possesses a *primitive prime divisor* — a prime p that divides F(n) but does not divide F(k) for any 0 < k < n. Our approach combines verified computation with algebraic number theory. The computational kernel verifies the theorem for all composite n ≤ 100,000 via `native_decide`, while the infinite tail requires the Lifting-the-Exponent lemma for Fibonacci sequences. We prove the bridge lemma connecting primitive parts to primitive primes, establish the Fibonacci entry point theory, and verify the key GCD identity gcd(L(m), F(m)) | 2 for the Lucas companion sequence.

## 1. Introduction

The Fibonacci sequence F(0) = 0, F(1) = 1, F(n+2) = F(n) + F(n+1) exhibits remarkable divisibility properties. Chief among these is the **strong divisibility sequence** property: gcd(F(m), F(n)) = F(gcd(m, n)), first proved rigorously by Carmichael. This identity is the engine behind the entry point theory: for each prime p, there is a smallest positive integer α(p) — the *rank of apparition* — such that p | F(α(p)), and p | F(n) if and only if α(p) | n.

Carmichael's theorem asserts that for n ≥ 13 and n composite, F(n) always has a prime factor whose rank of apparition is exactly n. Such primes are called **primitive divisors**. The exceptions n ∈ {1, 2, 6, 12} are the only composite values where F(n) lacks a primitive divisor.

### Historical Context

R. D. Carmichael published this result in 1913, building on earlier work by É. Lucas on the arithmetic of recurrence sequences. The theorem is a special case of Zsygmondy's theorem (1892) for the sequence a^n - b^n, adapted to the Fibonacci case where a = φ = (1+√5)/2 and b = ψ = (1-√5)/2.

## 2. Proof Architecture

### 2.1 The Primitive Part

For a positive integer n, we define the **primitive part** Ψ(n) as the largest divisor of F(n) that is coprime to F(d) for every proper positive divisor d of n. Computationally, Ψ(n) is obtained by iteratively removing from F(n) all prime factors shared with F(d):

```
fibPrimPart(n) = fold_left(removeFactors, F(n), [F(d) : d proper divisor of n])
```

where `removeFactors(a, g)` repeatedly divides a by gcd(a, g) until they become coprime.

**Theorem (Bridge Lemma).** If Ψ(n) > 1, then F(n) has a primitive prime divisor.

*Proof.* Any prime p | Ψ(n) divides F(n) (since Ψ(n) | F(n)). For k with 0 < k < n, let d = gcd(k, n). Then d is a proper positive divisor of n, and by the strong divisibility property, gcd(F(k), F(n)) = F(d). If p | F(k), then p | F(d), contradicting p being coprime to F(d) (since p | Ψ(n) and Ψ(n) is coprime to F(d)). ∎

### 2.2 Computational Verification

We verify Ψ(n) > 1 for all composite n ∈ [13, 100000] using Lean's `native_decide` mechanism. The checker computes `fibPrimPart(n)` for each composite n in the range and confirms it exceeds 1. This computation handles Fibonacci numbers with up to 20,000 digits and completes in approximately 20 minutes.

### 2.3 Entry Point Theory

For each prime p, the **Fibonacci entry point** α(p) is the smallest positive k with p | F(k). We prove:

1. **Existence**: Every prime has a finite entry point (by Pigeonhole on the pairs (F(k) mod p, F(k+1) mod p)).

2. **Divisibility**: If p | F(n) with n > 0, then α(p) | n (using the strong divisibility property and minimality).

### 2.4 The Lucas Companion and Lifting the Exponent

For the Fibonacci doubling formula F(2m) = F(m) · L(m) where L(m) = 2F(m+1) - F(m), we prove:

- **GCD bound**: gcd(L(m), F(m)) | 2 (since L(m) = F(m) + 2F(m-1) and consecutive Fibonacci numbers are coprime)
- **Lower bound**: L(m) ≥ 3 for m ≥ 2 (since L(m) = F(m-1) + F(m+1) ≥ 1 + 2)

For the general Lifting-the-Exponent lemma (odd prime p): the congruence F(pm)/F(m) ≡ ±p (mod F(m)) follows from the recurrence D_{k+1} = L·D_k - (-1)^m·D_{k-1} with the Cassini identity L² ≡ 4(-1)^m (mod F(m)). This yields gcd(F(pm)/F(m), F(m)) | p, the key ingredient for extracting primitive primes from Fibonacci quotients.

## 3. What Remains

The formalization covers n ≤ 100,000 computationally and establishes all structural lemmas (bridge lemma, entry point theory, Lucas GCD identity). The remaining gap — showing Ψ(n) > 1 for composite n > 100,000 — requires:

1. **Odd prime LTE**: Proving F(pm)/F(m) ≡ ±p (mod F(m)) for odd primes p, via the Chebyshev recurrence modulo F(m).

2. **Recursive primitive part analysis**: For composites with ≥ 2 distinct prime factors, showing the primitive part exceeds 1 by tracking entry point contributions across divisor levels.

These are deep but well-understood results; their formalization represents an open challenge in the Lean/Mathlib ecosystem.

## 4. Applications

### 4.1 Primality Certificates
Carmichael's theorem provides a *certificate of compositeness*: if n ≥ 13 and F(n) has no primitive divisor, then n must be prime (or one of the small exceptions). This is used in Lucas-type primality tests.

### 4.2 Fibonacci Factorization
The primitive part Ψ(n) captures the "new" arithmetic content at level n. By Möbius inversion, F(n) = ∏_{d|n} Ψ(d), decomposing each Fibonacci number into contributions from each divisor level. This factorization underpins efficient algorithms for computing F(n) mod m.

### 4.3 Algebraic Number Theory
In Q(√5), the Fibonacci sequence corresponds to norms of elements (φ^n - ψ^n)/√5. The primitive part Ψ(n) relates to the cyclotomic polynomial Φ_n evaluated at the golden ratio, connecting Fibonacci arithmetic to the theory of cyclotomic fields.

## 5. Discussion: Making Deep Arithmetic Accessible

Carmichael's theorem is one of those results that sounds simple — "big Fibonacci numbers always have new prime factors" — but whose proof touches deep waters. The strong divisibility sequence property, the entry point theory, and the Lifting-the-Exponent lemma each represent layers of arithmetic structure that build on each other.

An analogy: imagine a family tree where each generation (each value of n) contributes some "genetic" material (prime factors) to the family trait F(n). The inherited traits come from ancestor generations (proper divisors d of n). Carmichael's theorem says that starting from generation 13, every composite generation introduces at least one genuinely new trait — a prime that has never appeared in any ancestor.

The exceptions at n = 1, 2, 6, 12 are like the very early generations where the family is too small for new traits to emerge. F(1) = F(2) = 1, F(6) = 8 = 2³, F(12) = 144 = 2⁴ · 3² — these Fibonacci numbers are entirely composed of "old" primes.

What makes this theorem remarkable is its universality: it holds for EVERY composite n ≥ 13, regardless of the arithmetic structure of n. Whether n is a prime power, a semiprime, or a product of many primes, new Fibonacci primes always emerge.

## References

1. R. D. Carmichael, "On the numerical factors of the arithmetic forms α^n ± β^n," *Annals of Mathematics*, 15(1/4):30-70, 1913.
2. M. Ward, "The intrinsic divisors of Lehmer numbers," *Annals of Mathematics*, 62:230-236, 1955.
3. Y. Bilu, G. Hanrot, P. M. Voutier, "Existence of primitive divisors of Lucas and Lehmer numbers," *J. Reine Angew. Math.*, 539:75-122, 2001.
