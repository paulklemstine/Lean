# Summary of changes for run c24990ea-3a7c-484f-a988-372db04dd8b0
## Summary of Work Done

### New Results Proved (Sorry-Free)

**`Shared/CarmichaelLucas.lean`** — A new file containing a **fully proved** special case of Carmichael's theorem, with **zero sorries**:

1. **`fib_primitive_divisor_even_semiprime`**: For n = 2p with p prime ≥ 7, F(n) has a primitive prime divisor. This is the first formally verified component of the composite case.

The proof uses the Lucas number decomposition F(2m) = F(m) · L(m) and entry-point theory. Supporting lemmas proved include:
- `fib_two_mul_eq`: F(2m) = F(m) · L(m)
- `gcd_fib_lucas_dvd_two`: gcd(F(m), L(m)) | 2
- `lucasNum_has_odd_prime`: L(m) has an odd prime factor for m ≥ 4
- `lucasNum_ge`: L(m) ≥ m for m ≥ 1
- `odd_prime_lucas_not_dvd_fib`: odd primes dividing L(p) don't divide F(p)
- `entry_point_eq_two_mul_prime`: such primes have entry point 2p

All proofs verified clean: `#print axioms fib_primitive_divisor_even_semiprime` shows only `propext`, `Classical.choice`, `Quot.sound`.

### Remaining Sorries

The **general composite case** of Carmichael's theorem (for arbitrary composite n ≥ 13) remains as `sorry` in:
- `Shared/CarmichaelComposite.lean` (line 80)
- `Shared/CarmichaelComputational.lean` (line 71)
- `Shared/Fib_gcd_identity.lean` (line 30)
- `Speculative/AutoResearch/CarmichaelComposite.lean` (line 80)
- `Speculative/CarmichaelPrimitiveDivisor.lean` (line 47)

This is because the general composite case requires either the **Lifting the Exponent Lemma for Fibonacci**, **cyclotomic Fibonacci theory**, or other deep number-theoretic infrastructure not available in Mathlib. Computational verification confirms the theorem holds for all composite n ≤ 1000.

### Deliverables Created

- **`RESEARCH_REPORT.md`**: Technical report on the formalization approach, results, and remaining challenges
- **`demo.py`**: Python demonstration showing primitive prime divisors for Fibonacci numbers, entry-point theory, and the Lucas number connection
- **`diagram.svg`**: SVG visualization of the proof structure showing proved vs. open components
- **`DISCUSSION.md`**: Scientific American-style article explaining Carmichael's theorem and its significance

### Key Mathematical Insight

The even-semiprime proof works via a clean argument: for odd prime p, any odd prime q dividing the Lucas number L(p) cannot divide F(p) (since gcd(F(p), L(p)) | 2). Since p is prime, the only divisors of 2p are {1, 2, p, 2p}, and the entry point α(q) must be 2p (since α(q) = 2 would require q | F(2) = 1). This gives a primitive prime for F(2p). The general composite case would require extending this argument to handle all divisor structures, which is the fundamental difficulty.