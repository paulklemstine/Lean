# Summary of changes for run 60fb5871-7feb-43bf-a3c6-6d1bff507658
## Carmichael's Primitive Divisor Theorem (Composite Case) — Summary

### What was accomplished

I worked toward proving that every composite Fibonacci number beyond the known exceptions (n = 1, 2, 6, 12) admits a primitive prime divisor. Specifically, the target theorem states:

```
∀ n > 12, ¬Prime n → ∃ p, Prime p ∧ p ∣ F_n ∧ ∀ m, 0 < m → m < n → ¬p ∣ F_m
```

### Lean formalization

**Files created/modified:**

1. **`Catalog/Algebra/CarmichaelComposite.lean`** (new, 188 lines) — Contains:
   - `stripAllAux`, `propDivs`, `primPart`: computational infrastructure for stripping shared prime factors
   - Correctness lemmas: `primPart_dvd`, `primPart_coprime_proper_divs`, `primPart_implies_primitive`
   - **Computational verification** via `native_decide` covering all composite n ∈ [13, 50000] in 5 chunks
   - The main theorem `carmichael_composite_primitive_prime_divisor`
   - **One remaining sorry**: `primPart_large` for n > 50000

2. **`Catalog/Algebra/Lifting_the_Exponent_Lemma_for_Fibonacci_and_Primitive_Prime_Divisors_of_Composite_Index_Fibonacci_Numbers.lean`** (modified) — Added import of `CarmichaelComposite` and reference to the main theorem.

3. **`lakefile.toml`** (modified) — Added `srcDir = "Catalog"` to fix the source directory configuration.

### Remaining sorry

The lemma `primPart_large` (n > 50000 composite → primPart n > 1) requires the theory of **Fibonacci cyclotomic polynomials**: showing that Φ_n = ∏_{d|n} F_d^{μ(n/d)} satisfies Φ_n > 1 and has a prime factor not dividing n. The key estimate is ln(Φ_n) ≈ φ(n) · ln(φ) where φ(n) ≥ 4 for composite n > 12. This requires real analysis bounds on the Binet formula that are not currently formalized in Mathlib. The theorem is mathematically well-established (Carmichael 1913) but its full formalization is a known open challenge in the formal verification community.

### Python demos

- **`demos/carmichael_demo.py`**: Interactive demonstration showing primitive prime divisors for specific Fibonacci numbers, entry point tables, LTE verification, and statistics.
- **`demos/applications.py`**: Applications including Fibonacci-based compositeness testing, Diophantine equation analysis, entry point structure for cryptography, and the connection to perfect Fibonacci numbers.

### Research paper

- **`paper/carmichael_paper.md`**: Research paper covering the proof structure, the LTE, computational verification approach, a Scientific American-style discussion explaining the result intuitively, and connections to open problems.