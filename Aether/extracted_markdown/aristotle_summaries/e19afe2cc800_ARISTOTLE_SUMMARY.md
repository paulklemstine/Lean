# Summary of changes for run d6ebd7dd-14dd-4c60-9d7f-0f94d84422a0
## Summary

### Sorry Status in `Catalog/Shared/CarmichaelProof.lean`

The file contains **one sorry** that I was unable to fill, at line 149. This sorry is inside the proof of `fib_carmichael_composite` and corresponds to proving `1 < primPart n` for composite `n > 50000`.

**What is proven (sorry-free):**
- `bridge_lemma`: Proper-divisor primitivity implies full primitivity via the Fibonacci GCD identity
- `stripAllAux_dvd`, `stripAllAux_coprime`: Correctness of the iterative GCD stripping procedure
- `primPart_dvd`: The primitive part divides F(n)
- `primPart_coprime_proper_divs`: The primitive part is coprime to F(d) for all proper divisors d
- `primPart_implies_primitive`: If primPart(n) > 1, then F(n) has a primitive prime divisor
- `primPart_check`: Computational verification for n ∈ [13, 50000] via `native_decide`
- `composite_proper_div_le_half`: Proper divisor bound for composite numbers
- `fib_carmichael_composite` for n ≤ 50000 (the finite case)
- `fib_primitive_divisor_prime` (in CarmichaelHelper.lean): The prime-index case

**The remaining sorry** requires the theory of *cyclotomic Fibonacci numbers* Ψ_n = ∏_{d|n} F(d)^{μ(n/d)}, specifically:
1. The multiplicative identity F(n) = ∏_{d|n} Ψ_d
2. The intrinsic factor theorem: primes dividing multiple Ψ_d's must divide n
3. The lower bound Ψ_n ≥ φ^{φ(n)} − 1

This infrastructure is not available in Mathlib and would require approximately 400–500 lines of new formalization (Möbius inversion on Fibonacci valuations, golden ratio algebraic bounds, Euler totient bounds). This represents a genuine mathematical gap in current Lean/Mathlib formalization, not a limitation of proof automation.

### Additional Deliverables

- **Python demo** (`Catalog/Shared/carmichael_demo.py`): Interactive demonstration showing entry points, the Fibonacci GCD identity, Lucas numbers, Carmichael's exceptions, primitive prime divisors, and computational verification up to n = 200.

- **Research paper** (`Catalog/Shared/carmichael_research.md`): Detailed mathematical exposition covering the entry-point theory, primitive part framework, formalization results, the cyclotomic gap, accessible discussion, applications, and future directions.