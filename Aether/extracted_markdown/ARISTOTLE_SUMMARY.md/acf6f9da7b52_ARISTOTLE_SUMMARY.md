# Summary of changes for run f847a494-b3a8-4cbb-aae5-3760baf65cce
## Summary

I worked on filling the `sorry` in `fib_composite_has_primitive` — Carmichael's 1913 theorem stating that for composite n > 12, the Fibonacci number F_n has a primitive prime divisor.

### What was accomplished

**Lean formalization** (`RequestProject/CarmichaelComputational.lean`):

1. **Proved the reduction lemma** (`primitive_of_not_dvd_proper_divisors`): Using Mathlib's `Nat.fib_gcd`, I proved that a prime dividing F_n which doesn't divide F_d for any proper positive divisor d|n is automatically primitive (doesn't divide F_m for any 0 < m < n). This is the structural backbone of the proof.

2. **Proved coprimality** (`fib_coprime_of_coprime`): F_a and F_b are coprime when gcd(a,b) = 1, via `Nat.fib_gcd`.

3. **Reduced the main theorem** to its algebraic core: The `suffices` block cleanly reduces the general primitive divisor claim to finding a prime that avoids all F_d for proper divisors d|n.

4. **The core algebraic claim remains as `sorry`**: This is the deep part of Carmichael's theorem — showing that for composite n > 12, not all prime factors of F_n can have "entry point" (smallest k with p | F_k) strictly less than n. The standard proof uses the Möbius primitive part Φ_n = ∏_{d|n} F_d^{μ(n/d)} ≈ φ^{φ(n)}, which requires substantial number-theoretic infrastructure (Möbius function on divisor lattices, Fibonacci lifting-the-exponent lemma, p-adic valuation analysis) that isn't currently available in Mathlib.

### Why the sorry could not be filled

Carmichael's theorem is a genuine deep result in algebraic number theory. The proof requires either:
- The Möbius primitive part theory (showing Φ_n > rad(n) for composite n > 12)
- The full Fibonacci lifting-the-exponent lemma (controlling p-adic valuations of F_n)
- Or equivalently, results about cyclotomic-like polynomials for Lucas sequences

None of this infrastructure exists in Mathlib, and building it from scratch would require hundreds of lines of new formalization — a significant standalone project.

### Other deliverables

- **Python demo** (`demos/carmichael_demo.py`): Comprehensive demonstration verifying Carmichael's theorem computationally for composite n from 14 to 60, showing entry points, primitive divisors, Möbius primitive parts, and generating visualization plots.

- **Research paper** (`demos/carmichael_paper.md`): Mathematical paper covering the theorem statement, proof structure, entry point theory, Möbius primitive part analysis, applications to cryptography and primality testing, and an accessible discussion section.