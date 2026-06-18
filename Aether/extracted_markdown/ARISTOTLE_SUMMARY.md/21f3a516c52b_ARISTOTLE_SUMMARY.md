# Summary of changes for run b7bc44ef-d269-45dc-b556-55944d0e1830
## Summary of Work on Carmichael's Primitive Divisor Theorem

### What was accomplished

I made significant progress on the sorry in `Shared/CarmichaelProof.lean` (line ~129), which asks for a proof that every composite n ≥ 13 has a primitive prime divisor of F(n).

**Main achievement:** The sorry was reduced from covering all composite n > 10,000 to only composite n > 50,000, by extending the computational verification.

### Changes to `Shared/CarmichaelProof.lean`:
1. **Added LTE import** — imported the Lifting the Exponent Lemma file for Fibonacci quotient infrastructure.
2. **Increased heartbeat limit** to 3,200,000 to accommodate the extended `native_decide` check.
3. **Extended computational verification** from [13, 10000] to [13, 50000] via a second `native_decide` block.
4. **Extracted remaining sorry** into a clean standalone lemma `fib_carmichael_composite_gt50000` for composite n > 50,000.

### New file `Shared/CarmichaelLargeProof.lean`:
Built supporting mathematical infrastructure including:
- **`prime_dvd_fib_sq_sub_one`** — proved that p | F(p²−1) for any prime p ≠ 5, using the Binet formula over algebraic closures of finite fields and Frobenius endomorphism.
- **`coprime_pow_sq_sub_one`** — proved gcd(p^(k-1), p²-1) = 1 for primes p.
- **`prime_not_dvd_fib_prime_pow`** — combined the above to show p ∤ F(p^(k-1)) for p ≠ 5 prime and k ≥ 2.
- **`fib_primitive_prime_power_ne5`** — proved that F(p^k) has a primitive prime for prime powers with p ≠ 5, using `fibQuot_not_dvd` from the LTE and `bridge_lemma`.
- **`dvd_prime_pow_dichotomy`** — every divisor of p^k divides p^(k-1) or equals p^k.
- Extended computational verification (`primPart_check_ext`) for the range [10001, 50000].

### What remains (one sorry)
The remaining sorry (`fib_carmichael_composite_gt50000`) covers composite n > 50,000. This requires either:
1. **The algebraic norm argument** — showing the Fibonacci cyclotomic polynomial Ψ_n = β^{φ(n)} · Φ_n(ω) satisfies |Ψ_n| > 1 for n ≥ 3, which requires formalizing cyclotomic polynomial evaluation over ℤ[√5] and norm estimates.
2. **Extended LTE for p = 5** — the current LTE file excludes p = 5, so prime powers 5^k with k ≥ 7 need special treatment.
3. **The non-prime-power case** — for composites with ≥ 2 distinct prime factors, showing F(n)/(F(a)·F(b)) has a prime with entry point n.

These constitute the deep mathematical core of Carmichael's 1913 theorem and represent a major formalization challenge. The infrastructure built here (entry point theory, LTE for Fibonacci, algebraic closure arguments) provides the foundation for completing this work.