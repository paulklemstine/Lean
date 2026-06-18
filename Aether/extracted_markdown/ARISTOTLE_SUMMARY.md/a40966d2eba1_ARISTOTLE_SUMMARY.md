# Summary of changes for run 6a4f0cfa-6a6b-4254-ada3-e957d17aa7f9
## Carmichael's Primitive Divisor Theorem — Formalization Summary

### What was accomplished

I formalized a substantial portion of Carmichael's 1913 theorem: **every Fibonacci number F(n) with n ≥ 13 has a primitive prime divisor** (a prime dividing F(n) but no earlier Fibonacci number).

### Lean 4 Proof Structure

**Fully proved components:**

1. **Prime case** (`Shared/CarmichaelHelper.lean`): For prime n ≥ 13, every prime factor of F(n) is automatically primitive. The proof uses the GCD identity gcd(F(m), F(n)) = F(gcd(m,n)) — since n is prime, gcd(n,k) = 1 for 0 < k < n, so any shared factor would divide F(1) = 1.

2. **Computational composite case** (`Speculative/AutoResearch/CarmichaelComposite.lean`): For composite n ∈ [14, 100,000], verified via `native_decide` that the coprime-part stripping algorithm `fibCoprimePart` produces a value > 1, guaranteeing primitive divisors. The verification is split into three batches (14–10000, 10001–50000, 50001–100000) to avoid stack overflow.

3. **Entry point theory infrastructure**: Proved key lemmas including:
   - `fib_dvd_gcd_of_dvd`: if p | F(n) and p | F(k), then p | F(gcd(n,k))
   - `fibEntryPt_dvd_of_fib_dvd`: the entry point divides n when p | F(n)
   - `primitive_of_fibCoprimePart_pos`: the coprime-part algorithm is correct
   - `removePrimesOf_coprime`: the stripping function produces coprime results

4. **Connected theorems**: `fib_primitive_divisor` in `CarmichaelPrimitiveDivisor.lean` and `fib_primitive_divisor_existence` in `Fib_gcd_identity.lean` are connected to the main proof.

**Remaining sorry (1 location, same mathematical gap in 2 files):**

- `fib_carmichael_large`: composite n > 100,000. This requires formalizing the cyclotomic Fibonacci factorization Φ_n ≈ φ^{φ(n)}, which needs Möbius function infrastructure and analytic bounds not yet available in Mathlib. The mathematical argument is well-understood but the formal infrastructure is substantial.

### Files modified/created

| File | Status |
|------|--------|
| `Shared/CarmichaelHelper.lean` | **Created** — prime case proof |
| `Speculative/PisanoPeriodFactoring.lean` | **Created** — stub for missing import |
| `Speculative/AutoResearch/CarmichaelComposite.lean` | **Modified** — extended computational verification from 10,000 to 100,000; restructured proof |
| `Speculative/AutoResearch/CarmichaelPrimitiveDivisor.lean` | **Modified** — connected to main proof |
| `Speculative/AutoResearch/Fib_gcd_identity.lean` | **Modified** — removed broken import, connected to main proof |
| `Shared/CarmichaelProof.lean` | **Unchanged** (1 sorry remains, same gap) |

### Deliverables

- **`demo.py`** — Interactive Python demo showing primitive divisors, entry points, the GCD identity, coprime-part stripping, and large-scale verification
- **`RESEARCH_REPORT.md`** — Full research paper with mathematical background, proof details, and an accessible discussion section
- **`FUTURE_DIRECTIONS.md`** — Recommendations for closing the remaining sorry and extending the work
- **`diagram.svg`** — Visual overview of the proof structure, entry points, and growth bounds

### Sorry reduction

- **Before:** 4 sorry placeholders across 4 files (CarmichaelComposite, CarmichaelPrimitiveDivisor, Fib_gcd_identity, CarmichaelProof)
- **After:** 2 sorry locations in 2 files, both representing the **same** mathematical gap (composite n > 100,000). The other 2 sorries were eliminated by connecting to the proved infrastructure.