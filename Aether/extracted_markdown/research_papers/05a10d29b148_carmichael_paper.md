# Carmichael's Theorem for Fibonacci Numbers: A Formalization in Lean 4

## Abstract

We present a partial formalization of Carmichael's theorem (1913) in Lean 4 with Mathlib: for every n ≥ 13, the Fibonacci number F(n) possesses at least one primitive prime divisor — a prime p dividing F(n) that does not divide F(k) for any 0 < k < n. Our formalization covers the prime case completely and verifies the composite case computationally for n in [13, 10000] using native_decide. The infinite tail (composite n > 10000) remains as an open sorry, requiring formalization of the Lifting the Exponent Lemma for Fibonacci numbers or Zsigmondy's theorem, neither of which is currently in Mathlib.

## 1. Introduction

The Fibonacci sequence satisfies F(n+2) = F(n+1) + F(n) with F(0) = 0, F(1) = 1. Carmichael (1913) proved that for n ≥ 13, F(n) always has a primitive prime divisor: a prime appearing for the first time at index n. The only exceptions are n = 1, 2, 6, 12.

## 2. Proof Structure

### Prime Case
When n is prime, every prime factor of F(n) is automatically primitive, since the only proper divisors of n are 1, and no prime divides F(1) = 1. Formalized as `fib_primitive_divisor_prime`.

### Composite Case — Finite Verification
For composite n in [13, 10000], we compute the primitive part of F(n) by stripping GCD factors with F(d) for proper divisors d. Verified by `native_decide`.

### Composite Case — Infinite Tail
For composite n > 10000, the standard proof uses the cyclotomic decomposition F(n) = product of Psi(d) over divisors d of n. Showing Psi(n) > 1 for n >= 3 requires the Lifting the Exponent Lemma for Fibonacci numbers.

## 3. Applications

- Fibonacci pseudorandom generators with provable unpredictability
- Primality certificates via primitive divisor witnesses
- Connections to Zsigmondy's theorem and Diophantine equations

## 4. What Remains

Closing the sorry requires formalizing the LTE for Fibonacci numbers or Zsigmondy's theorem in Mathlib.
