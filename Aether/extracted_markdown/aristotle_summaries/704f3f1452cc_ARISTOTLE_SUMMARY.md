# Summary of changes for run 1dbeaba8-75c8-4cb3-b757-3a9949fd1578
## Carmichael's Primitive Divisor Theorem - Partial Formalization

### What was accomplished

I significantly advanced the formalization of Carmichael's Primitive Divisor Theorem for Fibonacci numbers in `Speculative/CarmichaelPrimitiveDivisor.lean`. The theorem states: *For n ≥ 13, F(n) has a primitive prime divisor — a prime p dividing F(n) but not F(k) for any 0 < k < n.*

### Proof structure (from 1 bare sorry to a structured proof with 1 isolated sorry)

The original file had a single `sorry` covering the **entire** theorem. I restructured the proof into three cases:

1. **Prime n** (`fib_primitive_divisor_prime`) — **Fully proved.** For prime n, gcd(n,k) = 1 for 0 < k < n, so any common prime factor of F(n) and F(k) would divide F(1) = 1 — impossible. This covers infinitely many n.

2. **Composite n ≤ 10000** — **Fully proved** via computational verification (`native_decide`). A "primitive part" function strips away all factors shared with Fibonacci numbers at proper divisor indices, and the result is verified to exceed 1 for all composite n in [13, 10000].

3. **Composite n > 10000** — **Remains as sorry.** This is the deep content of Carmichael's 1913 theorem, requiring either cyclotomic Fibonacci polynomial theory or the Lifting-the-Exponent lemma for Lucas sequences, neither currently in Mathlib.

### New lemmas proved

- **`fib_primitive_divisor_prime`**: Every prime factor of F(p) is primitive for prime p ≥ 13
- **`gcd_fib_lucas_dvd_two`**: gcd(F(n), 2·F(n+1) - F(n)) divides 2 (key structural lemma)
- **`primPart_implies_primitive`**: If the primitive part exceeds 1, a primitive divisor exists
- **`primPart_check`**: Computational verification for [13, 10000] via `native_decide`
- Full correctness proofs for the factor-stripping infrastructure

### Supporting files created

- **`RESEARCH_REPORT.md`**: Technical report on the proof architecture and what remains
- **`DISCUSSION.md`**: Scientific American-style explanation of the theorem
- **`demo.py`**: Python demonstration with numerical examples
- **`diagram.svg`**: Visual diagram of the proof architecture

### Why the remaining sorry is hard

The sorry for composite n > 10000 is equivalent to showing that the "Fibonacci cyclotomic polynomial" Ψ_n = ∏_{gcd(j,n)=1} (α - ζ_n^j · β) satisfies Ψ_n > 1 for n ≥ 13, AND that every prime factor of Ψ_n has entry point exactly n. This requires algebraic number theory infrastructure not yet available in Mathlib. The result was classified as "Speculative" in the project's catalog, reflecting its status as a known open formalization challenge.