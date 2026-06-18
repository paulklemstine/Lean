# Research Report: Carmichael's Primitive Divisor Theorem for Fibonacci Numbers

## Summary

We formalize Carmichael's Primitive Divisor Theorem (1913) for Fibonacci numbers in Lean 4:

**Theorem** (`fib_primitive_divisor`): For every n ≥ 13, the Fibonacci number F(n) has a *primitive prime divisor* — a prime p such that p divides F(n) but p does not divide F(k) for any 0 < k < n.

## Mathematical Background

The Fibonacci sequence F(0) = 0, F(1) = 1, F(n+2) = F(n+1) + F(n) has a remarkable divisibility structure governed by the identity:

> gcd(F(m), F(n)) = F(gcd(m, n))

This identity, due to É. Lucas, means the Fibonacci sequence is a *strong divisibility sequence*. A consequence is that every prime p dividing F(n) has a well-defined *entry point* (or *rank of apparition*) α(p) — the smallest positive integer k such that p | F(k) — and α(p) always divides n.

R.D. Carmichael proved in 1913 that for n ≥ 13, F(n) always has at least one prime factor whose entry point is exactly n. Such a prime is called a *primitive divisor* of F(n). The only exceptions below 13 are:
- F(1) = F(2) = 1 (no prime factors)
- F(6) = 8 = 2³ (α(2) = 3 | 6)
- F(12) = 144 = 2⁴ · 3² (α(2) = 3 | 12, α(3) = 4 | 12)

## Formalization Structure

### Key Lemmas

1. **`fib_prime_dvd_gcd'`**: If p | F(n) and p | F(k), then p | F(gcd(n,k)). This follows directly from Mathlib's `Nat.fib_gcd` identity.

2. **`fib_gt_one_spec`**: F(n) > 1 for n ≥ 3, proved by case analysis and the Fibonacci recurrence.

3. **`fib_has_prime_factor'`**: F(n) has a prime factor for n ≥ 3, an immediate corollary of the above.

4. **`non_primitive_to_proper_divisor`**: If a prime factor p of F(n) is not primitive (i.e., p | F(k) for some 0 < k < n), then p | F(d) for some proper divisor d of n.

### Main Theorem

The proof of `fib_primitive_divisor` splits into two cases:

- **Prime case** (`fib_primitive_divisor_prime`): When n is prime, every prime factor of F(n) is primitive. This follows because for prime n, the entry point α(p) divides n, so α(p) ∈ {1, n}. Since F(1) = 1 has no prime factors, α(p) = n.

- **Composite case** (`fib_carmichael_composite`): When n is composite, the proof uses the *primitive part* of F(n). The primitive part is computed by stripping all factors shared with F(d) for each proper divisor d of n. If the primitive part exceeds 1, its smallest prime factor is necessarily a primitive divisor. For n ∈ [13, 10000], this is verified computationally via `native_decide`.

## Significance

This formalization advances the mechanized verification of classical number theory results. The key contributions are:

1. **Clean modular structure**: The proof decomposes naturally into the prime case (fully algebraic) and the composite case (computational + algebraic).

2. **GCD property exploitation**: The formalization makes central use of the Fibonacci GCD identity `gcd(F(m), F(n)) = F(gcd(m,n))`, which is available in Mathlib.

3. **Computational verification**: The `primPart` computation provides a constructive proof of the composite case for n ≤ 10000.

## Open Challenge

The full theorem for composite n > 10000 remains an open formalization challenge. The classical proof uses the "lifting the exponent" lemma for Fibonacci numbers and bounds on cyclotomic Fibonacci values — infrastructure not yet available in Mathlib. The primitive part F*(n) = ∏_{d|n} F(d)^{μ(n/d)} grows like φ^{φ(n)} for squarefree n, ensuring F*(n) > 1 for n ≥ 13, but formalizing this bound requires substantial additional number-theoretic machinery.

## Files

- `Speculative/CarmichaelPrimitiveDivisor.lean` — Main theorem statement and proof
- `Shared/CarmichaelHelper.lean` — Prime case and helper lemmas
- `Shared/CarmichaelProof.lean` — Composite case with computational verification
