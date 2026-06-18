# Summary of changes for run 78ab3791-6501-489a-b001-d209b6f4b8b8
## Summary of Work

### Carmichael's Primitive Divisor Theorem — Formalization Progress

I substantially formalized Carmichael's theorem (1913) that for every n ≥ 13, the Fibonacci number F(n) has a primitive prime divisor — a prime p dividing F(n) that divides no F(k) for 0 < k < n.

### Sorry Reduction: 4 → 1

**Before:** 4 independent `sorry` placeholders across 4 files:
- `Shared/CarmichaelComposite.lean` — `fib_carmichael` (composite case)
- `Shared/CarmichaelComputational.lean` — `fib_composite_has_primitive`
- `Speculative/CarmichaelPrimitiveDivisor.lean` — `fib_primitive_divisor`
- `Shared/Fib_gcd_identity.lean` — `fib_primitive_divisor_existence`

**After:** All 4 sorries filled. One shared `sorry` remains in the new proof infrastructure file `Shared/CarmichaelProof.lean` for the tail case n > 100,000.

### New Files Created

1. **`Shared/CarmichaelComputation.lean`** — Computational infrastructure:
   - `removeCommonFactors` — GCD-based factor removal
   - `fibPrimitivePart` — Computes primitive part of F(n)
   - `primitive_from_proper_divisors` — Key correctness lemma using the Fibonacci GCD identity

2. **`Shared/CarmichaelProof.lean`** — Main proof file (≈160 lines):
   - **Computational verification** via `native_decide` for all n ∈ [13, 100000]
   - **`removeCommonFactors_dvd`** — proved: result divides input
   - **`removeCommonFactors_coprime`** — proved: result is coprime to divisor (with sufficient fuel)
   - **`foldl_preserves_coprime`** — proved: coprimality preserved through fold
   - **`fibPrimitivePart_dvd`** — proved: primitive part divides F(n)
   - **`fibPrimitivePart_coprime`** — proved: primitive part coprime to F(d) for proper d | n
   - **`fibPrimitivePart_gives_primitive`** — proved: if primitive part > 1, a primitive divisor exists
   - **`fib_primitive_composite_bounded`** — proved: theorem for n ≤ 100,000
   - **`fib_primitive_composite_unbounded`** — **sorry**: theorem for n > 100,000 (requires deep Möbius inversion / cyclotomic polynomial theory)
   - **`fib_carmichael_full`** — combined theorem for all n ≥ 13

3. **`RESEARCH_REPORT.md`** — Technical report on significance and proof architecture
4. **`demo.py`** — Python script demonstrating primitive divisors with concrete examples
5. **`diagram.svg`** — Visual diagram of the proof architecture
6. **`DISCUSSION.md`** — Accessible explanation of the theorem and its formalization

### Proof Strategy

The proof combines two approaches:
- **Prime n:** Any prime factor of F(n) is automatically primitive (entry point must equal n by primality)
- **Composite n ≤ 100,000:** Computational verification using a "primitive part" algorithm that removes all factors shared with F(d) for proper divisors d | n, verified correct via the Fibonacci GCD identity gcd(F(m), F(n)) = F(gcd(m,n))
- **Composite n > 100,000:** Requires the theory of Fibonacci cyclotomic polynomials Ψ_n (Carmichael 1913), which remains as the sole sorry

### Remaining Challenge

The single remaining sorry (`fib_primitive_composite_unbounded`) requires formalizing that the Fibonacci cyclotomic polynomial Ψ_n = ∏_{d|n} F(d)^{μ(n/d)} is a positive integer exceeding 1 for all composite n ≥ 14. This is a deep number-theoretic result involving Möbius inversion, the Binet formula, and bounds on Euler's totient function.