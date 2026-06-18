# Gravitational Factoring: Answered Questions v12

## 82+ Questions Answered Through Formal Verification

---

## Questions Answered in v12

### Q73. Can Korselt's criterion be computationally verified for specific Carmichael numbers?
**Answer: YES.** We formally verify the squarefreeness and divisibility conditions for both 561 and 1729. For 561 = 3 × 11 × 17: Squarefree 561 ✓, (2|560) ∧ (10|560) ∧ (16|560) ✓. For 1729 = 7 × 13 × 19: Squarefree 1729 ✓, (6|1728) ∧ (12|1728) ∧ (18|1728) ✓.

### Q74. What are the first seven Carmichael numbers?
**Answer: 561, 1105, 1729, 2465, 2821, 6601, 8911.** All factorizations formally verified in `first_carmichael_numbers`. Notable: all seven have exactly 3 prime factors.

### Q75. Is 1729 really the Hardy-Ramanujan "taxicab" number?
**Answer: YES.** Formally verified: 1729 = 1³ + 12³ AND 1729 = 9³ + 10³. Also the third Carmichael number (1729 = 7 × 13 × 19). This makes 1729 one of the most mathematically distinguished numbers.

### Q76. Can π(x) be computed for x up to 1000 in Lean?
**Answer: YES.** Using `native_decide`, we verify: π(2)=1, π(3)=2, π(5)=3, π(10)=4, π(20)=8, π(30)=10, π(100)=25, π(1000)=168. All computed and verified automatically.

### Q77. Is the prime counting function monotone?
**Answer: YES.** Formally proved: a ≤ b → π(a) ≤ π(b). The proof uses `Finset.card_le_card` and `Finset.filter_subset_filter`.

### Q78. Can specific instances of Bertrand's postulate be verified?
**Answer: YES.** Five instances formally verified by providing explicit witness primes: (n=1, p=2), (n=2, p=3), (n=3, p=5), (n=10, p=11), (n=50, p=53).

### Q79. Can the von Mangoldt identity Σ Λ(d) = log n be formalized?
**Answer: YES.** Using Mathlib's `ArithmeticFunction.vonMangoldt_sum`, which provides this identity directly. Our `vonMangoldt_sum` wraps it with our `vonMangoldtFn` definition.

### Q80. Does Mathlib support the von Mangoldt function natively?
**Answer: YES.** Mathlib provides `ArithmeticFunction.vonMangoldt` with lemmas for values at 1, primes, prime powers, and the divisor sum identity. Our v12 builds directly on this infrastructure.

### Q81. Can Chebyshev's ψ function be defined in Lean using Mathlib?
**Answer: YES.** `chebyshevPsiFn x = Σ_{n ≤ x} vonMangoldtFn n` using Finset.sum and our vonMangoldtFn wrapper around Mathlib's von Mangoldt.

### Q82. Can `exact?` placeholders be replaced with concrete proofs?
**Answer: YES.** Three `exact?` calls in DirichletSeriesFoundations.lean replaced with: `ArithmeticFunction.coe_mul_zeta_apply`, `liouville_one`, and `perm_primeFactorsList_mul hm hn`.

---

## Previously Answered Questions (v1-v11, Selected)

### Q1. Can the divisors of N be characterized as zeros of E(x) = N mod x?
**Answer: YES.** `energy_zero_iff`: E(x) = 0 ⟺ x | N. Formally verified.

### Q5. Can quadratic reciprocity be fully formalized?
**Answer: YES (v10).** Full law + both supplements + Σ(a/p) = 0. Complete.

### Q10. Is the Euclid-Euler theorem provable end-to-end?
**Answer: YES (v10).** Both directions: even perfect ⟺ 2^(p-1)(2^p - 1) with 2^p - 1 prime.

### Q15. Can the Miller-Rabin test be formally defined?
**Answer: YES (v11).** Including IsMillerRabinWitness, IsStrongPseudoprime, and prime_passes_miller_rabin.

### Q20. Can σ₁(5040) = 19344 be formally computed?
**Answer: YES (v11).** Via `native_decide`. This is the boundary value for Robin's inequality.

### Q25. What is the smallest Fermat pseudoprime to base 2?
**Answer: 341 = 11 × 31 (v11).** Formally verified: ¬Prime 341 ∧ 2^340 % 341 = 1.

### Q30. Can the Liouville function be formalized?
**Answer: YES (v11).** λ(n) = (-1)^Ω(n) with λ(1) = 1, λ(p) = -1, completely multiplicative.

### Q35. Is 561 a Carmichael number?
**Answer: YES (v11).** All coprime bases pass Fermat's test. But base 7 is an MR witness.

---

## Key Discovery: The Verification Infrastructure Pipeline

One of the most important insights from v12 is that a **verification infrastructure pipeline** is emerging:

```
σ₁ basics (v9)
    → Möbius inversion (v10)
        → Dirichlet convolution (v11)
            → von Mangoldt identity (v12)
                → Chebyshev bounds (future)
                    → PNT (long-term)

QR basics (v9)
    → Full QR (v10)
        → Euler criterion (v10)
            → MR test (v11)
                → Korselt (v12)
                    → MR error bound (future)
                        → Certified primality (long-term)
```

Each version builds directly on the previous one, creating an ever-deepening foundation for computational number theory.

---

## Questions Still Open

### Tier 1: High Feasibility (expected to be answered soon)
1. Can the full Korselt criterion be proved (both directions)?
2. Can Bertrand's postulate be proved in full generality?
3. Can Chebyshev's bounds c₁x ≤ ψ(x) ≤ c₂x be verified?
4. Can the Miller-Rabin error bound (≤ 1/4) be formally proved?

### Tier 2: Medium Feasibility
5. Can the Euler product ζ(s) = Π(1-p^{-s})^{-1} be formalized?
6. Can Mertens' theorem Σ 1/p ~ ln ln x be proved?
7. Can Robin's inequality be verified for n ∈ [5041, 10000]?
8. Does the QS have a complete end-to-end formal proof?

### Tier 3: Long-term
9. Can an elementary PNT proof be formalized?
10. Do odd perfect numbers exist?
11. Can the AKS primality test be formalized?
12. Can P ≠ NP barriers be formally stated?
