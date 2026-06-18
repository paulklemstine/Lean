# Research Report: Carmichael's Primitive Divisor Theorem for Fibonacci Numbers

## Overview

This project formalizes Carmichael's Primitive Divisor Theorem (1913) for Fibonacci numbers in Lean 4 with Mathlib. The theorem states:

**Theorem (Carmichael, 1913):** For n ≥ 13, the n-th Fibonacci number F(n) has a *primitive prime divisor* — a prime p such that p | F(n) but p ∤ F(k) for all 0 < k < n.

## Mathematical Background

### Entry Point Theory

The *entry point* (or *rank of apparition*) α(p) of a prime p is the smallest positive integer k such that p | F(k). The key property is:

**p | F(n) if and only if α(p) | n**

This follows from the identity gcd(F(m), F(n)) = F(gcd(m, n)), which makes the Fibonacci sequence a *strong divisibility sequence*.

A prime p is a *primitive divisor* of F(n) if and only if α(p) = n.

### Exceptions

The values of n for which F(n) has no primitive prime divisor are exactly n ∈ {1, 2, 6, 12}:
- F(1) = F(2) = 1 (no prime factors at all)
- F(6) = 8 = 2³ (2 has entry point 3)
- F(12) = 144 = 2⁴ · 3² (2 has entry point 3, 3 has entry point 4)

## Formalization Progress

### Fully Proved (Sorry-free)

1. **Entry Point Theory** (`FibEntryPoint.lean`):
   - Every prime divides some Fibonacci number (`prime_dvd_some_fib`)
   - Definition of entry point via `Nat.find` (`fib_entry_point`)
   - Entry point divides n when p | F(n) (`entry_point_dvd_of_fib_dvd`)
   - Biconditional: p | F(n) ↔ entry_point(p) | n (`fib_dvd_iff_entry_point_dvd`)
   - Primitivity from entry point equality (`primitive_of_entry_point_eq`)
   - Prime index theorem: all prime factors of F(p) are primitive for prime p (`fib_primitive_for_prime_index`)

2. **Lucas Number Theory** (`FibLucas.lean`):
   - Definition of Lucas numbers with recurrence relation
   - Identity L(n) = F(n-1) + F(n+1) (`lucasNum_eq_fib`)
   - Key identity F(2m) = F(m) · L(m) (`fib_two_mul_eq_fib_mul_lucas`)
   - gcd(F(m), L(m)) | 2 (`gcd_fib_lucas_dvd_two`)
   - Growth bound L(m) ≥ 3 for m ≥ 2 (`lucasNum_ge_three`)

3. **Carmichael Helpers** (`CarmichaelHelpers.lean`):
   - F(n) is even iff 3 | n (`fib_even_iff`)
   - F(p) is odd for prime p ≥ 7 (`fib_odd_of_prime_ge_seven`)
   - gcd(F(p), L(p)) = 1 for prime p ≥ 7 (`gcd_fib_lucas_eq_one_of_prime`)
   - L(p) has prime factor coprime to F(p) (`lucas_has_prime_not_dividing_fib`)
   - Entry point determination for L(p) primes (`entry_point_eq_two_mul_prime`)
   - Complete proof for n = 2p case (`fib_primitive_two_mul_prime`)

4. **Main Theorem — Prime Case** (`CarmichaelPrimitiveDivisor.lean`):
   - Carmichael's theorem for prime n ≥ 13 (`fib_primitive_divisor_prime`)

### Remaining Sorry

The **composite case** (`fib_primitive_divisor_composite`) remains as a sorry. This requires the full algebraic machinery of Carmichael's original proof, involving bounds on cyclotomic-like factors of Fibonacci numbers in the number field ℚ(√5).

The special case n = 2p (p prime ≥ 7) is fully proved via a clean divisor-counting argument: L(p) is coprime to F(p) for prime p ≥ 7, and its prime factors must have entry point 2p (since the only divisors of 2p not dividing p are 2 and 2p, and entry point 2 is impossible).

## Significance

This formalization represents one of the deepest results about Fibonacci number theory attempted in Lean 4. The entry point theory and Lucas number identities form reusable infrastructure for future work on:
- Zsigmondy's theorem for Lucas sequences
- Wall's conjecture on Pisano periods
- Distribution of prime factors in recurrence sequences

## References

- Carmichael, R. D. (1913). "On the numerical factors of the arithmetic forms αⁿ ± βⁿ." *Annals of Mathematics*, 15, 30–70.
- Yabuta, M. (2001). "A simple proof of Carmichael's theorem on primitive divisors." *Fibonacci Quarterly*, 39, 439–443.
