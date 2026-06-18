# Research Report: Carmichael's Primitive Divisor Theorem for Fibonacci Numbers

## Summary

We formalize a significant portion of Carmichael's Primitive Divisor Theorem (1913) for Fibonacci numbers in Lean 4 with Mathlib. The theorem states:

> **Theorem (Carmichael, 1913).** For every integer n ≥ 13, the Fibonacci number F(n) has a **primitive prime divisor** — a prime p such that p | F(n) but p does not divide F(k) for any 0 < k < n.

## Results Achieved

### Fully Proved Lemmas

1. **`fib_prime_dvd_gcd'`**: If p | F(n) and p | F(k), then p | F(gcd(n,k)). This is the fundamental GCD property of the Fibonacci sequence, derived from Mathlib's `Nat.fib_gcd`.

2. **`fib_gt_one`**: F(n) > 1 for n ≥ 3. Proved by case analysis and the Fibonacci recurrence.

3. **`fib_has_prime_factor'`**: F(n) has a prime factor for n ≥ 3. Follows from `fib_gt_one`.

4. **`non_primitive_to_proper_divisor`**: If a prime p divides both F(n) and F(k) for 0 < k < n, then p divides F(d) for some proper divisor d of n. Uses the GCD property.

5. **`fib_primitive_divisor_prime`**: For **prime** n ≥ 13, every prime factor of F(n) is a primitive divisor. The proof uses the fact that for prime n and 0 < k < n, gcd(n,k) = 1, so if p | F(n) and p | F(k), then p | F(1) = 1, contradicting p ≥ 2.

6. **`removePrimesOf_dvd`** and **`removePrimesOf_coprime`**: Properties of the `removePrimesOf` helper function used in the computational verification.

7. **`primitive_of_fibCoprimePart_pos`**: If the "coprime part" of F(n) (after removing all prime factors shared with F(d) for proper divisors d | n) is > 1, then F(n) has a primitive prime divisor.

8. **`fib_coprime_part_pos_small`**: Computational verification via `native_decide` that the coprime part is > 1 for all composite n with 14 ≤ n ≤ 50000.

### Remaining Sorry

- **`fib_carmichael_large`**: For composite n > 50000. This requires proving that Fibonacci numbers always have "new" prime factors not accounted for by smaller Fibonacci numbers, which in full generality requires either:
  - The cyclotomic factorization of Fibonacci numbers and bounds on |α − ζβ| for primitive roots of unity, or
  - Zsigmondy's theorem for Lucas sequences.
  
  Neither framework is currently available in Mathlib.

### Main Theorem

**`fib_primitive_divisor`**: Carmichael's theorem for n ≥ 13. Proved modulo `fib_carmichael_large`, by combining the prime case, computational verification for n ≤ 50000, and the large n lemma.

## Mathematical Significance

Carmichael's theorem is a foundational result in the arithmetic of recurrence sequences. It was first proved by R.D. Carmichael in 1913 and has connections to:

- **Algebraic number theory**: The primitive divisor corresponds to prime ideals in Z[φ] that first split at level n.
- **Cyclotomic theory**: The primitive part Ψ(n) of F(n) is analogous to the evaluation of cyclotomic polynomials.
- **Zsigmondy's theorem**: Carmichael's result is a special case of Zsigmondy-type theorems for Lucas sequences.
- **Elliptic divisibility sequences**: Generalizations of primitive divisor theorems play a role in the study of elliptic curves.

## Proof Architecture

```
fib_primitive_divisor (main theorem)
├── fib_primitive_divisor_prime (prime n case)
│   ├── fib_has_prime_factor'
│   │   └── fib_gt_one
│   └── fib_prime_dvd_gcd'
├── primitive_of_fibCoprimePart_pos (composite n ≤ 50000)
│   ├── removePrimesOf_dvd
│   ├── removePrimesOf_coprime
│   └── fib_coprime_part_pos_small (native_decide)
└── fib_carmichael_large (composite n > 50000) [sorry]
```

## Technical Notes

- The computational verification uses `native_decide` to check ~45,000 composite numbers in the range [14, 50000].
- The `fibCoprimePart` function computes the part of F(n) coprime to all F(d) for proper divisors d | n, by iteratively removing shared prime factors via GCD computations.
- The `fib_prime_dvd_gcd'` lemma leverages Mathlib's `Nat.fib_gcd` which establishes the strong divisibility property: F(gcd(m,n)) = gcd(F(m), F(n)).

## Future Work

To complete the proof, one would need to formalize either:
1. **Zsigmondy's theorem** for the Fibonacci/Lucas sequence, showing that α^n − β^n has a primitive divisor for n ≥ 13 where α = (1+√5)/2, β = (1−√5)/2.
2. **The cyclotomic Fibonacci factorization** F(n) = ∏_{d|n} Ψ(d) and the lower bound Ψ(n) > 1 for n ≥ 3, using the product formula Ψ(n) = ∏_{ζ primitive} |α − ζβ| > 1.

Both approaches require significant algebraic number theory infrastructure not currently in Mathlib.
