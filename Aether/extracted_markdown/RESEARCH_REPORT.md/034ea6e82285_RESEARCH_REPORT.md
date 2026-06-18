# Research Report: Carmichael's Primitive Divisor Theorem for Fibonacci Numbers

## Summary

This work formalizes key components of **Carmichael's Primitive Divisor Theorem** (1913): for every integer n ≥ 13, the n-th Fibonacci number F(n) has a *primitive prime divisor* — a prime p that divides F(n) but does not divide F(k) for any 0 < k < n.

## What Was Proved

### Fully Proved Lemmas (no sorry)

1. **Entry Point Existence** (`fib_entry_point_exists`): Every prime p divides some positive Fibonacci number. This uses a pigeonhole argument on the Pisano period (pairs of consecutive Fibonacci values mod p repeat within p² steps).

2. **Entry Point Divides** (`fib_entry_dvd`): If p divides F(n), then the entry point of p (smallest positive m with p | F(m)) divides n. This follows from the strong divisibility identity F(gcd(m,n)) = gcd(F(m), F(n)).

3. **GCD Property** (`fib_prime_dvd_gcd'`): If p | F(n) and p | F(k), then p | F(gcd(n,k)).

4. **Prime Case** (`fib_primitive_divisor_of_prime`): For any prime n ≥ 3, F(n) has a primitive prime divisor. Proof: any prime factor p of F(n) would have α(p) | n, but since n is prime, α(p) = 1 or α(p) = n, and F(1) = 1 rules out α(p) = 1.

5. **Finite Verification** (`fib_primitive_composite_bounded`): For each composite n with 14 ≤ n ≤ 93, explicit primitive prime divisors are provided and verified using `native_decide`. This covers 46 composite values with witnesses ranging from 19 (for n=18) to 14,736,206,161 (for n=65).

6. **Main Theorem Structure**: The main theorem `fib_primitive_divisor` is fully structured, reducing to three cases: prime n (proved), composite n ≤ 93 (proved computationally), and composite n > 93 (remaining sorry).

### Remaining Sorry

One sorry remains in `fib_primitive_composite_large`: proving the theorem for composite n > 93. This requires showing that the "primitive part" of F(n) — the product of prime powers whose entry point equals n — is greater than 1.

## Mathematical Significance

Carmichael's theorem is a foundational result in the theory of divisibility sequences. It establishes that Fibonacci numbers at index n ≥ 13 always contain "new" prime factors not seen at any earlier index. This has applications in:

- **Algebraic number theory**: Connection to cyclotomic polynomials and the structure of algebraic integers
- **Primality testing**: Fibonacci-based primality tests (Lucas primality test)
- **Cryptography**: Security analysis of Fibonacci-based pseudorandom generators

## Approach

The formalization uses three main strategies:

1. **Entry point theory**: Developed from scratch using Mathlib's `Nat.fib_gcd` identity
2. **Prime case**: A clean structural argument using properties of gcd
3. **Computational verification**: Explicit witnesses verified by Lean's `native_decide`

## Files

- `Speculative/FibEntryPoint.lean`: Entry point existence and divisibility properties
- `Speculative/CarmichaelPrimitiveDivisor.lean`: Main theorem and supporting lemmas
