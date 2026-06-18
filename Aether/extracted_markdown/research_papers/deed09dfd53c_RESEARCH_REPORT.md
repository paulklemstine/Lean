# Research Report: Fibonacci Entry-Point Theory and Carmichael's Primitive Divisor Theorem

## Overview

This project formalizes the **entry-point theory** for Fibonacci numbers and makes significant progress toward **Carmichael's 1913 theorem** on primitive prime divisors. The theorem states that for every n ≥ 13, the Fibonacci number F(n) has at least one *primitive prime divisor* — a prime p such that p divides F(n) but does not divide F(k) for any 0 < k < n.

## Key Results Formalized

### 1. Entry-Point Infrastructure (Fully Proven)

The **Fibonacci entry point** α(p) of a prime p is the smallest positive integer k such that p | F(k). We formalized and proved:

- **Entry point divides index** (`fibEntryPt_dvd_of_fib_dvd`): If p | F(n) and n > 0, then α(p) | n. This uses the GCD identity gcd(F(m), F(n)) = F(gcd(m,n)) from Mathlib.
- **Entry point characterizes primitivity** (`primitive_of_entryPt_eq`): If α(p) = n, then p is a primitive prime divisor of F(n).
- **GCD divisibility** (`fib_dvd_gcd_of_dvd`): If p | F(n) and p | F(k), then p | F(gcd(n,k)).

### 2. Prime Case (Fully Proven)

For **prime n ≥ 13** (`fib_primitive_divisor_prime`): Every prime factor of F(n) is primitive. The proof uses the fact that for prime n, gcd(n,k) = 1 for 0 < k < n, hence F(gcd(n,k)) = F(1) = 1, so no prime can divide both F(n) and F(k).

### 3. Composite Case — Computational Verification (n ≤ 112)

For **composite n with 13 ≤ n ≤ 112** (`fib_carmichael_le_112`): Verified by native computation (`native_decide`). The approach:

1. Define a function `findPrimitivePrimeDivisor` that factorizes F(n) and checks each prime factor for primitivity
2. Prove correctness: if the function returns a witness p, then p is indeed a primitive prime divisor
3. Verify computationally that the function succeeds for all n in [13, 112]

This covers **100 consecutive values** of n, including all composite numbers up to 112.

### 4. Remaining Open Case (n > 112)

The case of composite n > 112 remains as `sorry`. The bottleneck is **factorization**: F(113) has approximately 23 decimal digits, and trial-division factorization (used by Lean's `primeFactorsList`) becomes computationally infeasible for `native_decide` verification beyond this point.

## Mathematical Context

### Why n = 112 is the Computational Boundary

The verification function must factorize F(n) to find prime factors. Lean's `primeFactorsList` uses trial division, which has complexity O(√N) where N = F(n) ≈ φ^n. For n = 112, √F(112) ≈ 10^{11.5}, which is borderline for native compilation. For n = 113, the computation times out.

### What Would Complete the Proof

The remaining case requires a **growth bound** or **algebraic argument** showing that for composite n > 112, not all prime factors of F(n) can have entry points strictly less than n. Classical approaches include:

1. **Cyclotomic Fibonacci numbers**: Show the primitive part Φ_n = ∏_{d|n} F(d)^{μ(n/d)} exceeds 1, where μ is the Möbius function
2. **Lifting-the-exponent lemma**: Bound p-adic valuations v_p(F(n)) vs. max_{d<n} v_p(F(d))
3. **Zsigmondy-type arguments**: Generalize the Bang-Zsigmondy theorem to Lucas sequences

None of these are currently available in Mathlib.

## File Structure

| File | Role | Sorry Status |
|------|------|-------------|
| `Shared/CarmichaelHelper.lean` | Prime case proof | ✅ No sorry |
| `Shared/CarmichaelVerified.lean` | Computational verification infrastructure | ✅ No sorry |
| `Shared/CarmichaelComposite.lean` | Entry-point theory + main theorem | ⚠️ Sorry for n > 112 |
| `Shared/CarmichaelComputational.lean` | Alternative proof structure | ⚠️ Sorry for n > 112 |
| `Shared/Fib_gcd_identity.lean` | GCD identity + primitive divisor existence | ⚠️ Sorry for n > 112 |
| `Speculative/AutoResearch/CarmichaelComposite.lean` | Duplicate of Shared version | ⚠️ Sorry for n > 112 |
| `Speculative/AutoResearch/CarmichaelPrimitiveDivisor.lean` | Standalone version | ⚠️ Sorry for n > 112 |

## Impact

The formalized entry-point framework and computational verification establish a foundation for:
- **Tropical Hecke algebra**: Entry points index orbits under tropical GL₂ actions
- **Niven integrality**: Controlling prime divisors of F(n) for integrality arguments
- **Lucas sequence theory**: The framework generalizes to arbitrary Lucas sequences U_n(P,Q)
