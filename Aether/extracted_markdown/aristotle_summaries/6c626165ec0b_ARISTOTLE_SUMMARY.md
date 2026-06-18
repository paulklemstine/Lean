# Summary of changes for run b1542672-838c-4a05-bd5c-8f348f55e58d
## Summary of Work on Carmichael's Primitive Divisor Theorem

### Task
Fill the `sorry` in `Speculative/CarmichaelPrimitiveDivisor.lean` for `fib_primitive_divisor` — Carmichael's theorem stating that for n ≥ 13, F(n) has a primitive prime divisor (a prime p dividing F(n) but not F(k) for any 0 < k < n).

### Progress Made
The original file had a single `sorry` for the complete theorem `fib_primitive_divisor`. I significantly reduced its scope by proving two major cases:

1. **Prime case** (`fib_primitive_divisor_of_prime`, fully proved): For prime n ≥ 3, every prime factor of F(n) is automatically primitive. The proof uses the GCD identity `gcd(F(m), F(n)) = F(gcd(m,n))` — since gcd(n,k) = 1 for 0 < k < n when n is prime, any prime dividing both F(n) and F(k) would divide F(1) = 1, which is impossible.

2. **Small composite case** (`fib_primitive_divisor_composite_small`, fully proved via computation): For composite n from 14 to 50, verified computationally using 27 explicit primitive prime witnesses. Each witness was verified using `native_decide` for primality and divisibility, and `interval_cases` + `native_decide` to confirm non-divisibility for all F(k), 0 < k < n.

### Remaining Sorry
The sorry for **composite n > 50** remains. This is the deep case of Carmichael's 1913 theorem, requiring either:
- Entry point theory (defining the smallest k > 0 with m | F(k) and proving m | F(n) ↔ entry(m) | n)
- Fibonacci cyclotomic numbers Ψ_n and the bound Ψ_n > 1 for n ≥ 13
- Analytical bounds from the Binet formula

These require substantial mathematical infrastructure not currently in Mathlib. Multiple automated proof attempts were made with different strategies but were unable to close this deep number-theoretic gap.

### Deliverables Created
- `Speculative/CarmichaelPrimitiveDivisor.lean` — Lean 4 formalization with proven helpers and partial proof
- `RESEARCH_REPORT.md` — Detailed research report explaining the theorem, proof strategy, and remaining gaps
- `demo.py` — Python demonstration computing primitive prime divisors for F(13) through F(50)
- `diagram.svg` — Visual diagram of the proof structure and key identity
- `DISCUSSION.md` — Scientific American-style exposition of the theorem's significance

### Key Declarations
- `fib_prime_dvd_gcd'` — GCD divisibility property (proved)
- `fib_gt_one` — F(n) > 1 for n ≥ 3 (proved)
- `fib_has_prime_factor'` — F(n) has a prime factor for n ≥ 3 (proved)
- `non_primitive_to_proper_divisor` — Non-primitive factors reduce to proper divisors (proved)
- `fib_primitive_divisor_of_prime` — Prime index case (proved)
- `fib_primitive_divisor_composite_small` — Composite n ∈ [14,50] (proved)
- `fib_primitive_divisor` — Main theorem (1 sorry remaining for composite n > 50)