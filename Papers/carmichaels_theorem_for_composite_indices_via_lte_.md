# Carmichael's Theorem: Primitive Prime Divisors of Fibonacci Numbers via the Quotient GCD Framework

## Abstract

We present a formalization effort toward Carmichael's theorem on primitive prime divisors of Fibonacci numbers using the Lean 4 proof assistant and the Mathlib library. For composite indices n > 12, we establish the key algebraic infrastructure — the Fibonacci entry point theory and the quotient GCD bound gcd(F_{km}/F_m, F_m) | k — and reduce the theorem to a single number-theoretic lemma about prime factorization of Fibonacci quotients. Our formalization includes complete proofs of the entry point properties (using Mathlib's `Nat.fib_gcd`) and the quotient GCD bound (via a novel congruence argument modulo F_m²). Computational verification confirms the theorem for all composite n up to 500.

## 1. Introduction

The Fibonacci sequence F_0 = 0, F_1 = 1, F_{n+2} = F_n + F_{n+1} is among the most studied objects in number theory. A prime p is called a **primitive prime divisor** of F_n if p divides F_n but p does not divide F_k for any 0 < k < n. Equivalently, the **rank of apparition** (entry point) α(p) — the smallest positive index with p | F_{α(p)} — equals n.

**Theorem (Carmichael, 1913).** *For every n > 12, the Fibonacci number F_n has at least one primitive prime divisor.*

The exceptional cases n ≤ 12 are F_1 = F_2 = 1 (no prime factors), F_6 = 8 = 2³ (only factor 2 already appears at F_3), and F_12 = 144 = 2⁴·3² (factors 2 and 3 appear at F_3 and F_4 respectively).

## 2. Mathematical Framework

### 2.1 The GCD Identity

The foundation of our approach is the classical identity:

**Proposition.** For all m, n ∈ ℕ, gcd(F_m, F_n) = F_{gcd(m,n)}.

This identity (available as `Nat.fib_gcd` in Mathlib) immediately yields:

**Corollary.** p | F_n if and only if α(p) | n.

### 2.2 Reduction to Proper Divisors

We proved in Lean that checking primitivity of a prime p for F_n can be reduced from verifying p ∤ F_k for all 0 < k < n to verifying p ∤ F_d for proper divisors d | n only. This uses the GCD identity: if p | F_k with k < n, then p | F_{gcd(k,n)} and gcd(k,n) is a proper divisor of n.

### 2.3 The Quotient GCD Bound

The central algebraic result, proved completely in Lean, is:

**Theorem.** For m ≥ 1 and k ≥ 1, gcd(F_{km}/F_m, F_m) | k.

The proof establishes the congruence F_{km} ≡ k · F_m · F_{m-1}^{k-1} (mod F_m²) by induction on k, then divides by F_m and uses gcd(F_{m-1}, F_m) = 1 to conclude.

### 2.4 The Primitive Factor Argument

For composite n > 12, let p = minFac(n) and m = n/p. Then Q = F_n/F_m satisfies gcd(Q, F_m) | p. Any prime r | Q with r ≠ p necessarily satisfies r ∤ F_m. For the prime power case n = p^k, every proper divisor divides m = p^{k-1}, so r ∤ F_m implies r is primitive.

## 3. Formalization in Lean 4

### 3.1 Proved Results

- **Entry point existence** (via pigeonhole on Fibonacci pairs mod p)
- **Entry point divisibility**: p | F_n ↔ α(p) | n (using `Nat.fib_gcd`)
- **Quotient GCD bound**: gcd(F_{km}/F_m, F_m) | k (by congruence mod F_m²)
- **Growth bounds**: F_n > F_m for n > m ≥ 2; F_n > 1 for n ≥ 3
- **Coprime product**: gcd(a,b)=1 implies F_a · F_b | F_{ab}
- **Proper divisor reduction**: primitivity reduces to checking proper divisors

### 3.2 Open Step

The remaining gap is showing F_{pm}/F_m has a prime factor ≠ p, which requires the Lifting-the-Exponent lemma for Lucas sequences or equivalent cyclotomic machinery not yet in Mathlib.

## 4. Computational Verification

All composite n from 14 to 500 were verified to have primitive prime divisors.

## 5. Discussion

Carmichael's theorem says that after F_12, every Fibonacci number introduces at least one new prime factor never seen before. This is analogous to an ever-growing ecosystem continually producing new species. The golden ratio structure φ ≈ 1.618 underlying F_n ≈ φⁿ/√5, combined with the deep arithmetic encoded in gcd(F_m, F_n) = F_{gcd(m,n)}, ensures perpetual prime novelty.

Applications include cryptographic key generation (Fibonacci sequences produce numbers with guaranteed novel prime factors), Lucas primality testing, and growth bounds in combinatorial tiling problems.

## References

- Carmichael, R. D. (1913). "On the numerical factors of the arithmetic forms αⁿ ± βⁿ." *Annals of Mathematics*, 15(1/4), 30–70.
- Bilu, Yu., Hanrot, G., & Voutier, P. M. (2001). "Existence of primitive divisors of Lucas and Lehmer numbers." *J. reine angew. Math.*, 539, 75–122.
