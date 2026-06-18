# Summary of changes for run 3067dd32-32ec-4f2d-9c74-c9600c063b0e
## Summary of Work on Carmichael's Primitive Divisor Theorem

### What was accomplished

I made significant progress on formalizing Carmichael's 1913 theorem that for n ≥ 13, the Fibonacci number F(n) has a primitive prime divisor (a prime dividing F(n) but not F(k) for any 0 < k < n).

### New file created: `Shared/CarmichaelVerified.lean`

This file contains the **computational verification infrastructure** — fully proven, no sorries:

1. **`findPrimitivePrimeDivisor`**: A computable function that finds primitive prime divisors by factorizing F(n) and checking each prime factor
2. **`findPrimitivePrimeDivisor_correct`**: Formal proof that the function's output is correct
3. **`carmichael_verified_range`**: Computational verification via `native_decide` that the theorem holds for all n ∈ [13, 112]
4. **`fib_carmichael_le_112`**: The theorem statement proved for the bounded range 13 ≤ n ≤ 112

### Files modified (5 files with sorry narrowing)

Each of the 5 files with sorry placeholders was updated to:
- Import `Shared.CarmichaelVerified` for the computational verification
- Split the composite case into n ≤ 112 (proven by computation) and n > 112 (sorry)

**Modified files:**
- `Shared/CarmichaelComposite.lean` — Entry-point theory + main theorem
- `Shared/CarmichaelComputational.lean` — Alternative proof structure  
- `Shared/Fib_gcd_identity.lean` — GCD identity + primitive divisor existence
- `Speculative/AutoResearch/CarmichaelComposite.lean` — Duplicate of Shared version
- `Speculative/AutoResearch/CarmichaelPrimitiveDivisor.lean` — Standalone version

### What remains

All 5 files retain one sorry each, narrowed to: **composite n > 112**. The prime case (for all n) is fully proved. The composite case for n ≤ 112 is computationally verified. The bottleneck for n > 112 is that Lean's trial-division factorization of F(n) becomes too slow for `native_decide` beyond F(112) (which has ~23 decimal digits). The mathematical proof for the general case would require either:
- Formalizing the Möbius-based primitive part Φ_n and showing Φ_n > 1
- Or the lifting-the-exponent lemma for Fibonacci sequences
Neither of which is currently available in Mathlib.

### Deliverables created

- **`RESEARCH_REPORT.md`**: Technical report on the formalization
- **`demo.py`**: Python demonstration with concrete numerical examples
- **`diagram.svg`**: Visual diagram of entry-point theory and the theorem
- **`DISCUSSION.md`**: Scientific American-style discussion of the mathematics

All modified Lean files compile successfully with `lake build`.