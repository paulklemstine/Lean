# Summary of changes for run 44577ce5-5559-49fd-9133-4601cc91859a
## Summary of Work: Fibonacci Primitive Divisors via Entry-Point Divisibility

### Lean Formalization Progress

**Sorry Eliminated:**
- `Catalog/Speculative/AutoResearch/CarmichaelStandalone.lean`: Proved `primPart_implies_primitive` — the key lemma showing that if the primitive part of F(n) exceeds 1, then F(n) has a primitive prime divisor. This required adding two helper lemmas:
  - `stripAllAux_coprime`: After iterative GCD stripping, the result is coprime to the stripped divisor
  - `primPart_coprime_proper_divs`: The primitive part is coprime to F(d) for every proper divisor d of n
  
  The proof uses the bridge lemma structure: extract a prime factor p of primPart(n), show p | F(n) via `primPart_dvd`, then for any 0 < k < n, show p ∤ F(k) by reducing via `Nat.fib_gcd` to a proper divisor of n and applying coprimality.

**Remaining Sorries — All Reduce to One Deep Theorem:**

Every remaining sorry in the Carmichael/Fibonacci development (across ~11 files in Shared and Speculative) reduces to the same mathematical fact:

> **For composite n beyond a computational bound, primPart(n) > 1** (equivalently, F(n) has a primitive prime divisor).

This is the deep content of Carmichael's 1913 theorem. The existing formalization handles:
- **Prime n ≥ 13**: Every prime factor of F(n) is automatically primitive (proved via `Nat.fib_gcd` coprimality)
- **Composite n ≤ 50,000** (Shared) / **n ≤ 10,000–100,000** (Speculative): Verified computationally via `native_decide`

The asymptotic case requires ~500 lines of cyclotomic Fibonacci infrastructure:
1. Möbius inversion: F(n) = ∏_{d|n} Ψ_d where Ψ_d is the d-th cyclotomic Fibonacci number
2. Lower bound: Ψ_n ≥ φ^{φ(n)} − 1 (golden ratio to Euler totient power)
3. For composite n > 50,000: φ(n) > 158, making Ψ_n astronomically large
4. Intrinsic factor theorem: primes dividing Ψ_n but not n are primitive

This infrastructure was attempted but is genuinely beyond what can be formalized in a single session.

### Already-Proved Infrastructure (Existing in Project)

The project already contains a solid formalization layer:
- **`Catalog/Algebra/NumberTheory/FibEntry.lean`**: Entry point definition, existence, divisibility (`entry_dvd_of_fib_dvd`, `fib_dvd_iff_entry_dvd`)
- **`Catalog/Shared/CarmichaelHelper.lean`**: Prime case of Carmichael's theorem
- **`Catalog/Shared/CarmichaelHelpers.lean`**: Fibonacci quotient GCD bound, coprime product divisibility
- **`Catalog/Shared/Fib_gcd_identity.lean`**: GCD identity, linear growth, exponential bound, composite test

### Python Demos (`demos/`)

1. **`fibonacci_primitive_divisors.py`**: Comprehensive demonstration including:
   - Table of F(n), prime factors, and primitive divisors for n = 1..30
   - Entry points (ranks of apparition) for primes up to 97
   - Verification of gcd(F(m), F(n)) = F(gcd(m,n)) identity
   - Primitive part growth visualization
   - Entry-point bridge demonstration
   - Visualization saved as `fibonacci_primitive_divisors.png`

2. **`applications.py`**: Five practical applications:
   - Fibonacci primality certificates
   - Pisano period structure via entry points
   - Fibonacci-based integer factoring
   - Fibonacci pseudoprime detection
   - Cryptographic hash chain period analysis

### Research Paper (`demos/research_paper.md`)

A comprehensive paper covering:
- Mathematical framework (strong divisibility, entry points, bridge lemma)
- Formalization details in Lean 4
- The chain of reasoning from p | F(n) to primitivity
- Discussion section with hotel analogy for accessibility
- Connections to Zsigmondy's theorem and future directions
- Applications in primality testing, factoring, and cryptography

### Key Insight

The central contribution is identifying the **entry-point bridge** as the reusable interface:

```
p | F(n) → α(p) | n → if α(p) = n then p is primitive
→ any prime dividing primPart(n) gives a primitive divisor
→ primPart(n) > 1 for composite n ≥ 13 [computational + asymptotic]
```

Once the entry-point bridge is established, primitivity arguments reduce to simple divisibility contradictions. The only remaining gap is the asymptotic bound on the primitive part, which is well-understood mathematically but requires substantial formal infrastructure.