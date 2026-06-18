# Research Report: Carmichael's Primitive Divisor Theorem for Fibonacci Numbers

## Summary

This project formalizes key components of Carmichael's Primitive Divisor Theorem in Lean 4 with Mathlib. The theorem states that for every n ≥ 13, the n-th Fibonacci number F(n) has a **primitive prime divisor**: a prime p such that p | F(n) but p ∤ F(k) for all 0 < k < n.

## Results Achieved

### Fully Proved Lemmas

1. **`fib_prime_dvd_gcd'`**: If p | F(n) and p | F(k), then p | F(gcd(n,k)). This follows directly from Mathlib's `Nat.fib_gcd` identity: F(gcd(m,n)) = gcd(F(m), F(n)).

2. **`fib_gt_one`**: F(n) > 1 for n ≥ 3. Proved by case analysis and the Fibonacci recurrence.

3. **`fib_has_prime_factor'`**: F(n) has a prime factor for n ≥ 3. Follows from F(n) > 1.

4. **`non_primitive_to_proper_divisor`**: If a prime factor of F(n) is not primitive, there exists a proper divisor d of n with p | F(d). Uses the GCD property.

5. **`fib_primitive_divisor_of_prime`**: For **prime** n ≥ 3, every prime factor of F(n) is a primitive prime divisor. The key insight: for prime n, gcd(n,k) = 1 for all 0 < k < n, so if p | F(k), then p | F(1) = 1, a contradiction.

6. **Computational verification (13 ≤ n ≤ 100)**: Using `native_decide` with a decidable predicate over `Nat.primeFactors`, we verify computationally that every n in {13, ..., 100} has a primitive prime divisor.

### Main Theorem Structure

The main theorem `fib_primitive_divisor` is proved modulo one remaining sorry:
- **n ≤ 100**: Handled computationally via `native_decide`.
- **n > 100, n prime**: Handled algebraically via `fib_primitive_divisor_of_prime`.
- **n > 100, n composite**: Remaining sorry (`fib_primitive_composite_large`).

### Remaining Challenge

The composite case for n > 100 requires showing that the **primitive part** Φ_n = ∏_{d|n} F(d)^{μ(n/d)} has a prime factor coprime to n. This involves:
- Proving Φ_n is a positive integer (Möbius inversion).
- Establishing growth bounds (Φ_n ≈ φ^{φ(n)}).
- Bounding the p-adic valuation v_p(Φ_n) for primes p | n.

These are deep results requiring significant Fibonacci number theory infrastructure not currently in Mathlib.

## Mathematical Background

Carmichael's theorem (1913) is a fundamental result in the theory of Lucas sequences. The exceptions to the primitive divisor property are exactly n ∈ {1, 2, 6, 12}. The proof relies on the strong divisibility property gcd(F(m), F(n)) = F(gcd(m,n)) and careful analysis of the "entry point" α(p) = min{k > 0 : p | F(k)}.

## Technical Approach

The formalization leverages:
- **Mathlib's `Nat.fib_gcd`**: The key algebraic identity for the GCD of Fibonacci numbers.
- **`native_decide`**: For efficient computational verification of decidable propositions.
- **Entry point theory**: The concept that each prime's divisibility pattern in the Fibonacci sequence is governed by a minimal index.

## Files

- `Speculative/CarmichaelPrimitiveDivisor.lean`: Main formalization with 5 proved lemmas, computational verification for n ∈ [13, 100], and the structured main theorem.
