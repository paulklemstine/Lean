# Summary of changes for run 51780e47-32d0-482e-bda2-2cabaf50f5eb
## Summary of Work on Carmichael's Primitive Divisor Theorem

### What was accomplished

**Lean 4 Formalization (Catalog/Shared/CarmichaelProof.lean):**

1. **Extended computational verification from n ≤ 10,000 to n ≤ 50,000** — The `primPart_check` theorem now verifies via `native_decide` that for all composite n in [13, 50000], the primitive part `primPart n > 1`, confirming Carmichael's theorem computationally for this entire range. This is a 5× expansion of the verified range.

2. **Proved the `composite_proper_div_le_half` lemma** — For composite n ≥ 4, every proper divisor d of n satisfies d ≤ n/2. This structural lemma about composite numbers was proved from scratch.

3. **Preserved all existing proofs** — The bridge lemma, `primPart` correctness infrastructure (`stripAllAux_dvd`, `stripAllAux_coprime`, `primPart_dvd`, `primPart_coprime_proper_divs`, `primPart_implies_primitive`), and the computational verification framework all remain intact and compile cleanly.

**Remaining sorry:** One sorry remains at line 149, for the case of composite n > 50,000. This requires proving `1 < primPart n` for all such n — the deep asymptotic case of Carmichael's 1913 theorem. The proof requires formalizing the cyclotomic Fibonacci polynomial bound Ψ_n ≥ φ^{φ(n)} − 1 > rad(n), which needs approximately 500 lines of infrastructure (Möbius inversion on Fibonacci p-adic valuations, golden ratio algebraic bounds, Euler totient lower bounds). The sorry is clearly documented in the code with a description of the required mathematical argument.

**Python demos (demos/):**
- `carmichael_demo.py` — Interactive demonstration showing the theorem with concrete examples: exceptions at n ≤ 12, verification table for n = 13..35, entry point map for small primes, and applications
- `carmichael_visualization.py` — Generates plots of primitive prime counts, entry point distributions, and divisibility matrices
- `carmichael_paper.md` — Research paper explaining the formalization strategy, the Lifting-the-Exponent Lemma, the computational verification approach, and the remaining cyclotomic growth bound, with a Scientific American-style discussion section

### Why the sorry could not be fully closed

Carmichael's theorem for composite n > 50,000 requires proving that the "cyclotomic Fibonacci number" Ψ_n = ∏_{d|n} F_d^{μ(n/d)} satisfies Ψ_n > rad(n) for all composite n > 12. This bound follows from the product formula Ψ_n = ∏_{gcd(j,n)=1} (φ − ζ_n^j · ψ) and the inequality |φ − ψ · e^{iθ}| = √(3 + 2cos θ) ≥ 1. Formalizing this requires:
- Defining cyclotomic Fibonacci numbers via Möbius inversion
- Proving they are positive integers via the product formula
- Establishing the lower bound using complex analysis / algebraic number theory
- Connecting to the radical of n via Euler's totient function

This is genuine deep mathematics requiring ~500 lines of new Lean infrastructure that doesn't exist in Mathlib or the project. The project's existing Lifting-the-Exponent Lemma for Fibonacci (in `Algebra/Lifting_the_Exponent_Lemma_for_Fibonacci_...`) provides part of the needed infrastructure but not the cyclotomic bound itself.