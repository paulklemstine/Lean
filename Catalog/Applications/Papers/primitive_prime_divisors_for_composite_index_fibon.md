# Toward a Fully Formalized Proof of Carmichael's Primitive Divisor Theorem

## Abstract

We report on progress toward the first complete machine-verified proof of Carmichael's 1913 theorem: for every integer n > 12, the Fibonacci number F(n) possesses at least one *primitive prime divisor* — a prime p such that p | F(n) but p does not divide F(k) for all 0 < k < n. Our formalization in Lean 4 with Mathlib establishes the complete entry-point theory for the Fibonacci sequence, proves key growth bounds including the sub-multiplicativity F(a+b) ≥ F(a)·F(b), and verifies the theorem computationally for all n ≤ 10,000. The remaining challenge — an analytic argument via the Binet formula and Möbius inversion for the "large n" tail — is identified and discussed.

## 1. Introduction

The Fibonacci sequence F(0) = 0, F(1) = 1, F(n+2) = F(n) + F(n+1) is one of the most studied objects in number theory. A prime p is a *primitive prime divisor* of F(n) if p | F(n) and p does not divide F(k) for all 0 < k < n.

**Theorem (Carmichael, 1913).** For every n > 12, the Fibonacci number F(n) has at least one primitive prime divisor.

The exceptional indices n = 1, 2, 6, 12 correspond to F(1)=1, F(2)=1, F(6)=8=2³, and F(12)=144=2⁴·3², none of which have primitive prime divisors.

## 2. Proof Architecture

### 2.1 The Prime Case (Fully Formalized)
For prime n ≥ 13: any prime p | F(n) is automatically primitive, since gcd(n,k) = 1 for 0 < k < n implies p | F(gcd(n,k)) = F(1) = 1, contradiction.

### 2.2 The Composite Case — Small n (Computationally Verified)
For composite n with 14 ≤ n ≤ 10,000: verified via native_decide on the primPart function.

### 2.3 The Composite Case — Large n (Open)
For composite n > 10,000: requires showing the primitive part Ψ(n) = ∏_{d|n} F(d)^{μ(n/d)} > 1.

By the Binet formula, log Ψ(n) ≈ φ(n)·log(φ) where φ(n) is Euler's totient and φ is the golden ratio. For n > 10,000 composite, φ(n) ≥ 5000, giving Ψ(n) ≈ φ^5000 >> 1.

## 3. Formalized Results

### Fibonacci Growth Bounds (sorry-free)
- F(a+b) ≥ F(a)·F(b) for a,b ≥ 1
- F(ab) ≥ F(a)^b for a,b ≥ 1
- Strict monotonicity for indices ≥ 2
- F(n) ≥ n for n ≥ 5

### Entry Point Theory (sorry-free)
- Entry point existence, positivity, divisibility
- Entry point minimality
- Bridge lemma: proper divisor check suffices for primitivity

## 4. Applications

Carmichael's theorem has applications in:
- Primality testing via Lucas sequences
- Algebraic factorization of Fibonacci numbers
- LFSR period analysis in cryptography
- Cyclotomic field theory

## References

1. R. D. Carmichael, "On the numerical factors of the arithmetic forms α^n ± β^n," Annals of Mathematics, 1913.
2. Y. Bilu, G. Hanrot, P. M. Voutier, "Existence of primitive divisors of Lucas and Lehmer numbers," J. reine angew. Math., 2001.
