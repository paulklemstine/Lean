# Research Report: Carmichael's Theorem via Entry-Point Growth

## Summary

This report documents progress on formalizing **Carmichael's Primitive Divisor Theorem** for Fibonacci numbers in Lean 4 with Mathlib. The theorem states:

> **Theorem (Carmichael, 1913)**: For every integer n ≥ 13, the Fibonacci number F(n) has a *primitive prime divisor* — a prime p such that p | F(n) but p does not divide F(k) for any 0 < k < n.

## Key Results

### Fully Formalized

1. **Prime case** (`fib_primitive_divisor_prime`): For prime n ≥ 13, every prime factor of F(n) is primitive. This follows from the entry-point theory: if p | F(n) and p | F(k) with 0 < k < n, then p | F(gcd(n,k)) = F(1) = 1 (since n is prime and k < n), giving a contradiction.

2. **Entry-point theory** (multiple lemmas):
   - `fibEntryPt_dvd_of_fib_dvd`: The entry point α(p) divides any n with p | F(n)
   - `primitive_of_entryPt_eq`: If α(p) = n, then p is primitive for F(n)
   - `fib_dvd_gcd_of_dvd`: If p | F(n) and p | F(k), then p | F(gcd(n,k))

3. **Even semiprime case** (`fib_primitive_divisor_even_semiprime`): For n = 2p with p prime ≥ 7, F(n) has a primitive prime divisor. The proof uses:
   - The identity F(2m) = F(m) · L(m) where L(m) = 2F(m+1) - F(m) is the Lucas number
   - The bound gcd(F(m), L(m)) | 2
   - Entry-point analysis showing any odd prime q | L(p) has α(q) = 2p

4. **Supporting lemmas for Lucas numbers**:
   - `fib_two_mul_eq`: F(2m) = F(m) · L(m)
   - `gcd_fib_lucas_dvd_two`: gcd(F(m), L(m)) | 2
   - `lucasNum_has_odd_prime`: L(m) has an odd prime factor for m ≥ 4
   - `lucasNum_ge`: L(m) ≥ m for m ≥ 1

### Remaining Open

The **composite case** for general composite n ≥ 13 remains as `sorry`. This is the hardest part of Carmichael's theorem and requires one of:

- **Lifting the Exponent Lemma (LTE) for Fibonacci**: For odd prime p with α(p) | n: v_p(F(n)) = v_p(F(α(p))) + v_p(n/α(p))
- **Cyclotomic Fibonacci theory**: The primitive part Ψ_n = ∏_{d|n} F(d)^{μ(n/d)} satisfies Ψ_n > 1 for n ≥ 13
- **Comprehensive computational verification** for all composite n in a finite range, combined with growth bounds for large n

## Mathematical Background

### Entry-Point Theory

For any prime p ≥ 2, the **Fibonacci entry point** (or rank of apparition) α(p) is the smallest positive integer k such that p | F(k). Key properties:

1. α(p) always exists and is ≤ p² - 1
2. p | F(n) if and only if α(p) | n
3. gcd(F(m), F(n)) = F(gcd(m,n)) (strong divisibility)

### The Lucas Number Connection

For even n = 2m, the identity F(2m) = F(m) · L(m) provides a natural decomposition. The Lucas number L(m) = F(m-1) + F(m+1) satisfies:

- gcd(F(m), L(m)) ∈ {1, 2}
- L(m) ≥ m for m ≥ 1
- L(m) is odd when 3 ∤ m

Any odd prime q dividing L(m) satisfies q ∤ F(m) (since gcd | 2). By entry-point analysis, α(q) | 2m but α(q) ∤ m. For m prime, this forces α(q) = 2m, giving a primitive divisor.

### Why the General Case is Hard

For composite m, the entry point α(q) could be 2d for some proper divisor d of m, rather than 2m. Showing that at least one odd prime factor of L(m) has entry point exactly 2m requires either:

1. The LTE for Fibonacci (to control multiplicities)
2. Growth bounds on the "primitive part" Ψ_n
3. Algebraic number theory in ℤ[φ] where φ = (1+√5)/2

These represent significant formalization challenges beyond what is currently available in Mathlib.

## File Structure

- `Shared/CarmichaelHelper.lean` — Prime case and basic helpers
- `Shared/CarmichaelComposite.lean` — Entry-point theory and main theorem (composite case sorry'd)
- `Shared/CarmichaelLucas.lean` — Even semiprime case via Lucas numbers (fully proved)
- `Shared/CarmichaelComputational.lean` — Computational approach (composite case sorry'd)
- `Shared/Fib_gcd_identity.lean` — GCD identity and related results
- `Speculative/CarmichaelPrimitiveDivisor.lean` — Alternative formulation (sorry'd)

## References

- Carmichael, R.D. (1913). "On the numerical factors of the arithmetic forms α^n ± β^n." *Annals of Mathematics*, 15(1/4), 30-70.
- Yabuta, M. (2001). "A simple proof of Carmichael's theorem on primitive divisors." *Fibonacci Quarterly*, 39(5), 439-443.
