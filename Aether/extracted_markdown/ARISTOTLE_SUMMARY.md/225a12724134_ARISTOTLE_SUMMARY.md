# Summary of changes for run 05ea31b1-e9f0-40c9-94e5-4033cac89365
# Carmichael's Theorem — Formalization Progress

## What was accomplished

### Lean formalization

1. **Prime case fully proved** (`Shared/CarmichaelHelper.lean`):  
   `fib_primitive_divisor_prime` — for prime n ≥ 13, F(n) has a primitive prime divisor. Proved using `Nat.fib_gcd`: if p | F(n) and n is prime, then for any k < n, gcd(n,k) = 1 (since n is prime), so p | F(gcd(n,k)) = F(1) = 1, which is impossible.

2. **Finite composite case verified** (`Shared/CarmichaelProof.lean`):  
   `primPart_check` — verified by `native_decide` that for all composite n ∈ [13, 10000], the primitive part of F(n) is > 1.

3. **Growth bound lemmas proved**:  
   - `fib_ge_self`: F(n) ≥ n for n ≥ 5  
   - `fib_double_quot_ge`: F(2n)/F(n) ≥ F(n) + 1 for n ≥ 2

4. **Infrastructure proved**:  
   - `bridge_lemma`: reduces "primitive for F(n)" to "coprime to F(d) for proper divisors d | n"
   - `primPart_implies_primitive`: if the primitive part > 1, extracts a primitive prime
   - `primPart_dvd`, `stripAllAux_dvd`, `stripAllAux_coprime`: correctness of GCD stripping
   - Entry point infrastructure in `Shared/CarmichaelInfiniteTail.lean`

5. **Main theorem structure** (`fib_carmichael_composite`):  
   Reduced to a single sorry: `primPart_pos_of_large` — showing that for composite n > 10000, the primitive part of F(n) is > 1.

### What remains (the sorry)

The infinite tail `primPart_pos_of_large` requires proving that for ALL composite n > 10000, F(n) has a prime factor not appearing in F(d) for any proper divisor d of n. This is the deep core of Carmichael's theorem, requiring one of:
- The **Lifting the Exponent Lemma** for Fibonacci numbers (showing v_p(F(n)) = v_p(F(α(p))) + v_p(n/α(p)))
- **Zsigmondy's theorem** for Lucas sequences
- The **cyclotomic decomposition** F(n) = ∏_{d|n} Ψ_d with Ψ_n > 1

None of these are currently available in Mathlib. The finite verification confirms the result computationally up to n = 10000 (and I tested up to 100,000 via `#eval`).

### Python demos (`demos/`)
- `carmichael_demo.py`: Interactive demonstration showing primitive primes, entry points, and the primitive part Ψ(n) for n = 1..50
- `visualize_carmichael.py`: Matplotlib visualizations of primitive prime growth and entry point distributions

### Documentation (`docs/`)
- `carmichael_paper.md`: Research paper explaining the theorem, proof structure, and what remains

### Supporting files
- `Speculative/PisanoPeriodFactoring.lean`: Stub created for import dependency
- `Shared/CarmichaelInfiniteTail.lean`: Alternative formulation with entry point infrastructure