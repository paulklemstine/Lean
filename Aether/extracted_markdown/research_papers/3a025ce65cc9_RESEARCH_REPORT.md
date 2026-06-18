# Research Report: Fibonacci Lifting-the-Exponent and Primitive Divisor Theorem

## Summary

This work advances the formalization of Carmichael's Primitive Divisor Theorem for Fibonacci numbers in Lean 4 with Mathlib. The theorem states that for every n ≥ 13, the Fibonacci number F(n) has a **primitive prime divisor**: a prime p that divides F(n) but does not divide F(k) for any 0 < k < n.

## Mathematical Background

### Carmichael's Theorem (1913)
R. D. Carmichael proved that for n ≥ 13, F(n) has at least one primitive prime divisor. The only exceptions below 13 are n ∈ {1, 2, 6, 12}, where F(n) = 1, 1, 8, 144 respectively have no primitive prime factors.

### The Entry Point
For a prime p, the **Fibonacci entry point** (or rank of apparition) α(p) is the smallest positive integer k such that p | F(k). A fundamental property is that p | F(n) if and only if α(p) | n. This follows from the GCD identity:

    gcd(F(m), F(n)) = F(gcd(m, n))

### The Primitive Part
We define the **primitive part** of F(n) as the result of removing from F(n) all prime factors that also divide F(d) for some proper divisor d | n with d > 0. If this primitive part exceeds 1, its prime factors are exactly the primitive prime divisors of F(n).

## Our Approach

### Key Innovation: Computational Primitive Part
Rather than following the classical algebraic proof (which requires cyclotomic polynomial theory or the Lifting-the-Exponent Lemma), we take a computational approach:

1. **Define `removeAllFactors n g`**: Removes all prime factors of g from n by repeatedly dividing by gcd(n, g).

2. **Define `fibPrimitivePart n`**: Applies `removeAllFactors` to F(n) for each F(d) where d is a proper divisor of n.

3. **Prove correctness**: If `fibPrimitivePart n > 1`, then F(n) has a primitive prime divisor.

4. **Verify computationally**: Using `native_decide`, we verify that `fibPrimitivePart n > 1` for all n ∈ [13, 10000].

### Correctness Proof Structure

The correctness argument proceeds as follows:

1. **Divisibility**: `fibPrimitivePart n` divides `F(n)` (proved by induction on the fold).

2. **Coprimality**: `fibPrimitivePart n` is coprime to `F(d)` for every proper divisor d of n (proved using the coprimality property of `removeAllFactors`).

3. **Entry point reduction**: If p | F(k) for some 0 < k < n, then p | F(gcd(n,k)) where gcd(n,k) is a proper divisor of n. This key step uses `Nat.fib_gcd` from Mathlib.

4. **Conclusion**: Any prime factor of `fibPrimitivePart n` divides F(n) but not F(k) for any 0 < k < n.

### Results

- **Prime case**: Fully proved for all primes n ≥ 13 (entry point must be 1 or n; F(1) = 1 excludes 1).
- **Composite case**: Computationally verified for all composite n ∈ [13, 10000] via `native_decide`.
- **Remaining gap**: Composite n > 10000 requires either extending the computational range or a mathematical growth bound argument.

## Files Modified

| File | Original Sorries | Current Sorries | Notes |
|------|-----------------|----------------|-------|
| `Shared/FibPrimitivePart.lean` | N/A (new) | 0 | Core infrastructure, fully proved |
| `Shared/CarmichaelComposite.lean` | 1 | 1 | Reduced to composite n > 10000 |
| `Shared/CarmichaelComputational.lean` | 1 | 1 | Reduced to composite n > 10000 |
| `Speculative/CarmichaelPrimitiveDivisor.lean` | 1 | 1 | Reduced to composite n > 10000 |
| `Shared/Fib_gcd_identity.lean` | 1 | 1 | Reduced to composite n > 10000 |

## Key Lemmas Proved

1. `removeAllFactors_pos`: The function preserves positivity.
2. `removeAllFactors_dvd`: The result divides the input.
3. `removeAllFactors_coprime`: The result is coprime to the second argument.
4. `fib_factor_to_divisor`: Non-primitive factors correspond to proper divisors.
5. `fibPrimitivePart_dvd_fib`: The primitive part divides F(n).
6. `fibPrimitivePart_coprime`: The primitive part is coprime to each F(d).
7. `fibPrimitivePart_gives_primitive`: The main correctness theorem.
8. `fibPrimitivePart_gt_one_range`: Computational verification for [13, 10000].
9. `fib_primitive_divisor_range`: Carmichael's theorem for n ∈ [13, 10000].

## Open Challenges

### Closing the Gap for n > 10000
The remaining sorry covers composite n > 10000. Approaches to resolve this include:

1. **Extending computation**: The `native_decide` range could potentially be pushed to 50000+, but F(50000) has ~10000 digits, making GCD computations slow.

2. **Lifting-the-Exponent Lemma**: For an odd prime p ≠ 5 with p | F(m), proving v_p(F(km)) = v_p(F(m)) + v_p(k) would enable an algebraic proof.

3. **Cyclotomic approach**: Using the Möbius-inverted primitive part Ψ_n = ∏_{d|n} F(d)^{μ(n/d)} and showing |Ψ_n| ≈ φ^{φ(n)} > 1 for n ≥ 13.

4. **Growth bound**: Showing that for large composite n, the non-primitive contribution is too small to account for all of F(n).

## Significance

This work represents significant progress toward a complete formalization of Carmichael's theorem:
- The computational framework (`fibPrimitivePart`) is novel and avoids the need for deep algebraic infrastructure.
- The correctness proof cleanly separates the mathematical argument from the computational verification.
- The approach is extensible: increasing the computational range requires only more compute time, not more mathematical machinery.
