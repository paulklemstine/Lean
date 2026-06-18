# Summary of changes for run 97177f65-7de6-4bb3-a1b4-7002d6e874a4
## Summary of Completed Work

### Carmichael's Primitive Divisor Theorem for Fibonacci Numbers

I made significant progress on formalizing Carmichael's theorem: for n ≥ 13, F(n) has a primitive prime divisor (a prime p dividing F(n) but not F(k) for any 0 < k < n).

### New Infrastructure Created

**`Shared/FibPrimitivePart.lean`** (new file, 0 sorries):
- Defined `removeAllFactors n g`: removes all prime factors of g from n via iterated GCD
- Defined `fibPrimitivePart n`: computes the primitive part of F(n) by removing factors from F(d) for all proper divisors d | n
- Proved 9 key lemmas including:
  - `removeAllFactors_dvd`, `removeAllFactors_pos`, `removeAllFactors_coprime`
  - `fib_factor_to_divisor`: if p | F(k) for 0 < k < n, then p | F(d) for some proper d | n (uses Mathlib's `Nat.fib_gcd`)
  - `fibPrimitivePart_dvd_fib`, `fibPrimitivePart_coprime`
  - `fibPrimitivePart_gives_primitive`: **main correctness theorem** — if fibPrimitivePart > 1, then a primitive prime divisor exists
  - `fibPrimitivePart_gt_one_range`: computational verification via `native_decide` for n ∈ [13, 10000]
  - `fib_primitive_divisor_range`: Carmichael's theorem for all n ∈ [13, 10000]

### Files Modified

Each original sorry was narrowed from covering the full theorem to covering only composite n > 10000:

| File | Status |
|------|--------|
| `Shared/FibPrimitivePart.lean` | **New, fully proved (0 sorries)** |
| `Shared/CarmichaelComposite.lean` | Sorry reduced to composite n > 10000 only |
| `Shared/CarmichaelComputational.lean` | Sorry reduced to composite n > 10000 only |
| `Speculative/CarmichaelPrimitiveDivisor.lean` | Sorry reduced to composite n > 10000 only |
| `Shared/Fib_gcd_identity.lean` | Sorry reduced to composite n > 10000 only |

### What's Proved

- **Prime case (all primes ≥ 13)**: Fully proved mathematically. Any prime factor of F(p) is primitive because the entry point must be 1 or p, and F(1) = 1 rules out 1.
- **Composite case (n ≤ 10000)**: Fully proved via computational verification using `native_decide`.
- **Overall**: Carmichael's theorem holds for all n ∈ [13, 10000] without any `sorry`.

### Remaining Gap

The composite n > 10000 case remains open. Closing this requires either:
1. Extending the computational verification range (limited by F(n) growing to thousands of digits)
2. Formalizing the Lifting-the-Exponent Lemma for Fibonacci numbers
3. Formalizing cyclotomic polynomial theory for Lucas sequences

### Deliverables Created

- **RESEARCH_REPORT.md**: Technical details of the approach and results
- **demo.py**: Python demonstration with numerical examples of primitive divisors
- **diagram.svg**: Visual overview of the proof architecture
- **DISCUSSION.md**: Scientific American-style explanation of Carmichael's theorem