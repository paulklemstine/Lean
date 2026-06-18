# Summary of changes for run 82c13b3a-ae6e-4187-80e8-13f1728fdcf2
## Fibonacci Carmichael Growth Lemma — Progress Report

### What was accomplished

I made significant progress on formalizing Carmichael's theorem that for composite n ≥ 13, F(n) has a primitive prime divisor (a prime p | F(n) with p ∤ F(k) for all 0 < k < n).

### New files created (sorry-free)

1. **`Shared/CarmichaelGrowth.lean`** — Key mathematical infrastructure:
   - `fib_lucas_gcd_dvd_two`: gcd(F(n), L(n)) divides 2
   - `fib_even_iff`: F(n) is even ↔ 3 | n
   - `fib_prime_odd`: F(p) is odd for prime p ≠ 3
   - `fib_lucas_coprime_of_odd`: F(n) odd ⟹ gcd(F(n), L(n)) = 1
   - `lucas_gt_one`: L(n) > 1 for n ≥ 2
   - `entry_point_not_dvd_implies`: entry point non-divisibility
   - **`primitive_divisor_double_prime`**: For prime p ≥ 7, F(2p) has a primitive prime divisor — proved using the doubling formula F(2p) = F(p)·L(p) and coprimality

2. **`Shared/CarmichaelProof.lean`** — Computational verification:
   - `fib_prim_bounded`: For ALL composite n with 13 ≤ n ≤ 100, F(n) has a primitive prime divisor — proved by providing explicit witnesses verified via `native_decide`
   - `fib_prim_double_prime`: Adapter using `primitive_divisor_double_prime` for n > 100 of the form 2p

### Files modified (sorry reduced)

3. **`Shared/CarmichaelComposite.lean`** — The main `fib_carmichael` theorem now handles:
   - Prime n: via existing `fib_primitive_divisor_prime` ✓
   - Composite n ≤ 100: via computational verification ✓
   - Composite n = 2p (p prime): via doubling formula ✓
   - Remaining: 2 narrower sorries (even n > 100 with n/2 composite, and odd composite n > 100)

4. **`Shared/CarmichaelComputational.lean`** — `fib_composite_has_primitive` similarly improved

5. **`Speculative/AutoResearch/CarmichaelComposite.lean`** — Same improvements

6. **`Shared/Fib_gcd_identity.lean`** — `fib_primitive_divisor_existence` similarly improved

### Deliverables created

- **`RESEARCH_REPORT.md`** — Technical report explaining the mathematical approach and results
- **`demo.py`** — Python demonstration computing primitive prime divisors for Fibonacci numbers
- **`diagram.svg`** — Visual diagram of the proof structure
- **`DISCUSSION.md`** — Scientific American-style article on Carmichael's theorem

### What remains

The remaining sorries cover composite n > 100 that are not of the form n = 2p for prime p. Completing these requires the **Lifting-the-Exponent Lemma (LTE) for Fibonacci sequences** or the **cyclotomic Fibonacci factorization** — both are substantial formalizations not currently in Mathlib. The remaining gap is clearly identified and documented in the research report.