# Summary of changes for run c0e4d740-1ae5-4299-a0f6-5ae7a12dccca
# Carmichael's Theorem: Primitive Prime Divisors of Fibonacci Numbers

## What was accomplished

### Lean 4 Formalization (`RequestProject/CarmichaelPrimitivePrime.lean`)

I formalized Carmichael's 1913 theorem on primitive prime divisors of Fibonacci numbers. The main theorem:

```lean
theorem carmichael_composite_primitive_prime_divisor {n : ℕ}
    (hn : n > 12) (hcomp : ¬Nat.Prime n) :
    ∃ p : ℕ, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬ p ∣ Nat.fib k
```

**Fully proved helper lemmas** (no sorry):
- `coprimePart_dvd` / `coprimePart_coprime` / `coprimePart_gt_one_has_coprime_prime` — Properties of the coprime-part function that strips shared radical factors
- `primitive_iff_proper_divisors` — Reduces primitivity from all k ∈ (0,n) to only proper divisors of n, using Mathlib's `Nat.fib_gcd`
- `fibProdProperDivsC_pos` — Positivity of the Fibonacci product over proper divisors
- `coprime_fibProd_implies_primitive` — Coprimality to the product implies primitivity
- `coprimePart_test_sound` — Soundness of the coprime-part computational test
- `finite_range_check` — Machine-verified computation via `native_decide` confirming the result for **all composite n from 13 to 100,000**

**One remaining sorry**: `large_n_has_ppd` (the case n > 100,000). This requires the Lifting the Exponent Lemma (LTE) for Fibonacci sequences — a substantial piece of algebraic number theory not currently in Mathlib. The main theorem is proved modulo this single lemma.

### Python Demo (`demos/carmichael_demo.py`)
- Computational verification of Carmichael's theorem
- Coprime-part method demonstration (matching the Lean proof strategy)
- Growth analysis of primitive parts
- Visualization support (matplotlib)

### Research Paper (`paper.md`)
- Mathematical background on primitive prime divisors
- Detailed explanation of the proof strategy
- Discussion section making the result accessible to non-specialists
- Applications to pseudoprime theory and cryptography
- Future directions including LTE formalization

## What remains

The single sorry in `large_n_has_ppd` covers composite n > 100,000. Closing it requires formalizing the Lifting the Exponent Lemma for Fibonacci numbers: for odd prime p with rank r, v_p(F_{rm}) = v_p(F_r) + v_p(m). This combined with growth bounds would show that the absence of primitive primes leads to F_n ≤ n · lcm(F_d), contradicting the exponential growth of Fibonacci numbers. The computational verification up to 100,000 (with the tightest case at n=30 where the ratio is ≈1.033) strongly supports the bound.