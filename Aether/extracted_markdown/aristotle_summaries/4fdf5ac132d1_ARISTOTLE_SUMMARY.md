# Summary of changes for run aecd4869-cafd-4a7c-b218-ab6143caa0cc
## Summary of Work

### Task
Fill two `sorry` placeholders in Carmichael's primitive divisor theorem for Fibonacci numbers:
1. `fib_carmichael_large` in `Catalog/Speculative/AutoResearch/CarmichaelComposite.lean`
2. `fib_composite_has_primitive` in `Catalog/Speculative/AutoResearch/CarmichaelComputational.lean`

### What Was Accomplished

**Import fixes:** Both target files had broken imports (`Shared.CarmichaelHelper` → `Catalog.Shared.CarmichaelHelper`), which were corrected.

**New helper file created:** `Catalog/Speculative/AutoResearch/CarmichaelLargeHelper.lean` — a substantial 250+ line file providing the mathematical infrastructure for Carmichael's theorem for large composite Fibonacci indices. This file imports and builds upon the existing Lifting-the-Exponent (LTE) machinery in `Catalog/Algebra/Lifting_the_Exponent_Lemma_for_Fibonacci_and_Primitive_Prime_Divisors_of_Composite_Index_Fibonacci_Numbers.lean`.

**Fully proved lemmas (no sorry):**
- `composite_dichotomy` — every composite n > 1 is a prime power or has a coprime factorization
- `fib_gt_self` — F(n) > n for n ≥ 7
- `fib_mul_dvd_of_coprime` — F(a)·F(b) | F(a·b) when gcd(a,b) = 1
- `fib_dvd_gcd'` — if p | F(n) and p | F(k), then p | F(gcd(n,k))
- `primitive_of_not_dvd_proper` — bridge from proper-divisor non-divisibility to primitivity
- `prime_pow_divisor_dichotomy` — the only divisor of p^k not dividing p^(k−1) is p^k itself
- `fibQuot_prime_pow_ge_two` — F(p^k)/F(p^(k−1)) ≥ 2
- `two_dvd_fib_iff` — 2 | F(n) ↔ 3 | n
- `five_dvd_fib_iff` — 5 | F(n) ↔ 5 | n
- `odd_prime_not_dvd_fibQuot` — for odd prime q ≠ 5 with q | F(m) and q ≠ p: q ∤ F(mp)/F(m)
- `exists_new_prime_large_p` — for p ≥ 7 prime: F(p^k)/F(p^(k−1)) has a new prime factor
- `fib_prime_power_primitive` — F(p^k) has a primitive prime divisor (modulo sub-lemmas)
- `exists_new_prime_factor_fibQuot` — assembled from sub-cases (modulo p=2,3,5 sub-lemmas)
- `fib_large_composite_primitive` — main theorem assembly from prime-power + coprime cases

**Target sorry resolutions:**
- `fib_carmichael_large` — replaced with `fib_large_composite_primitive n hn hnp hn1` (no sorry in this file)
- `fib_composite_has_primitive` — replaced with `fib_carmichael n hn` (no sorry in this file)

### Remaining Gaps

The proof chain transitively depends on 4 sorrys in `CarmichaelLargeHelper.lean`:

1. **`exists_new_prime_p2`** (p=2 prime power case) — The mathematical argument is clean (no prime dividing F(2^(k−1)) can divide the quotient, by two_dvd_fib_iff + five_dvd_fib_iff + odd_prime_not_dvd_fibQuot), but proof automation budget was exhausted before it could be completed.

2. **`exists_new_prime_p3`** (p=3 prime power case) — Requires showing fibQuot(3^(k−1),3) is odd via mod-2 analysis of the Fibonacci quotient congruence.

3. **`exists_new_prime_p5`** (p=5 prime power case) — Requires showing v₅(fibQuot) = 1 without the standard LTE lemma (which excludes p=5), using direct mod-25 analysis.

4. **`fib_coprime_factor_primitive`** (coprime factorization case) — The deepest remaining gap. Requires showing that F(a·b)/(F(a)·F(b)) has a prime factor coprime to both F(a) and F(b), using growth bounds on Fibonacci numbers.

### Architecture

The proof follows the standard mathematical approach to Carmichael's 1913 theorem:
- **Composite n ≤ 10000:** Verified computationally via `native_decide` (existing `fib_coprime_part_pos_small`)
- **Composite n > 10000, prime power:** Via Lifting-the-Exponent for Fibonacci (the quotient F(p^k)/F(p^(k−1)) has a new prime)
- **Composite n > 10000, coprime factorization:** Via growth bounds on F(a·b)/(F(a)·F(b))
- **Prime n:** Via the existing `fib_primitive_divisor_prime`

The LTE infrastructure from the imported file provides the key algebraic tool, and the new helper lemmas (two_dvd_fib_iff, five_dvd_fib_iff, odd_prime_not_dvd_fibQuot) handle the number-theoretic case analysis.