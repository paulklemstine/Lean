# Summary of changes for run 3422fc80-6144-4bd2-b488-8260be890af1
## Summary

I worked on formalizing Carmichael's Primitive Divisor Theorem for Fibonacci numbers (composite index case) in Lean 4. Here is what was accomplished:

### Lean Formalization (`RequestProject/CarmichaelPrimitive.lean`)

**Fully proved lemmas (8 results, no sorry):**

1. **`prime_dvd_fib_gcd`** — If p | F_m and p | F_n, then p | F_{gcd(m,n)}, using Mathlib's strong divisibility property `Nat.fib_gcd`.

2. **`prime_dvd_some_fib`** — Every prime divides some positive Fibonacci number. Proved via the pigeonhole principle on Fibonacci pairs mod p.

3. **`entry_point_dvd_of_fib_dvd`** — The entry point (rank of apparition) of a prime divides n whenever p | F_n. This is the structural backbone of primitive divisor theory.

4. **`fib_dvd_iff_entry_dvd`** — Complete characterization: p | F_k ⟺ z(p) | k, where z(p) is the entry point of p.

5. **`composite_proper_div_le_half`** — Every proper divisor of a composite number n > 1 is at most n/2.

6. **`fib_strict_mono`**, **`fib_le_two_pow`**, **`fib_ge_id`** — Fibonacci growth bounds: strict monotonicity for indices ≥ 2, upper bound F_n ≤ 2^n, and lower bound F_n ≥ n for n ≥ 5.

**Remaining sorry (1 result):**

- **`fib_composite_has_primitive`** — The main theorem stating that for composite n > 10000, F_n has a primitive prime divisor. This remains as a `sorry`.

**Why the sorry remains:** Carmichael's theorem (1913) requires the theory of *cyclotomic Fibonacci numbers* Φ_n — the "primitive parts" defined by Möbius inversion of the multiplicative identity F_n = ∏_{d|n} Φ_d. Proving Φ_n > n for composite n > 10000 requires:
- Defining Φ_n via Möbius inversion and proving integrality
- The lower bound Φ_n ≈ φ^{φ(n)} (involving Euler's totient function)
- The intrinsic factor theorem (primes appearing in multiple Φ_d must divide n)

This infrastructure is not currently available in Mathlib and represents a substantial development project (estimated 500+ lines of new algebraic number theory). The entry point theory, which forms the structural framework, is fully formalized.

### Python Demo (`demos/primitive_divisor_demo.py`)

An interactive demonstration that:
- Computes entry points for small primes and verifies the divisibility laws
- Shows primitive divisors for all composite n ≤ 30, identifying the exceptions n = 6, 12
- Verifies Carmichael's theorem computationally for all composite n from 13 to 100
- Demonstrates why primitive divisors exist using the Φ_n growth bound

### Research Paper (`paper/carmichael_primitive_divisor.md`)

A mathematical paper covering:
- The entry point theory and its formalization
- Carmichael's proof strategy via cyclotomic Fibonacci numbers
- Applications to cryptography, primality testing, and algebraic number theory
- An accessible discussion section explaining the result to a general audience
- Assessment of the formalization status and future directions