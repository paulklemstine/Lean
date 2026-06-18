# Summary of changes for run 24f32061-a3bf-4b68-97fe-e960aa0d1342
## Carmichael's Theorem: Primitive Prime Divisors of Fibonacci Numbers

### Theorem Statement
For every composite n ≥ 13, F(n) has at least one primitive prime divisor — a prime p dividing F(n) that does not divide F(k) for any 0 < k < n.

### Lean Formalization (`RequestProject/FibPrimitive.lean`)

The proof is structured in layers:

1. **Entry Point Theory** (fully proven):
   - `prime_dvd_fib_gcd`: If p | F(k) and p | F(n), then p | F(gcd(k,n)), using Mathlib's `Nat.fib_gcd`.
   - `fib_primitive_iff_divisors`: Checking primitivity over all k < n reduces to checking only proper divisors of n.

2. **Verified Computational Checker** (fully proven):
   - A GCD-based algorithm computes the "primitive residual" R of F(n) by iteratively dividing out common factors with F(d) for proper divisors d.
   - `verifyResidual_sound`: If R > 1, R | F(n), and gcd(R, F(d)) = 1 for all proper divisors d, then F(n) has a primitive prime divisor.
   - `checkRangePrimitive_sound`: Soundness of the range checker.

3. **Computational Verification** (fully verified via `native_decide`):
   - `fib_primitive_le_50000`: All composite n ∈ [13, 50000] are verified.

4. **Main Theorem** (`fib_composite_has_primitive`):
   - For n ≤ 50000: uses the computational verification.
   - For n > 50000: reduces to `fib_primitive_large` which requires the Fibonacci Lifting-the-Exponent Lemma.

### Remaining Sorry
One sorry remains: `fib_primitive_large` (line 169), handling composite n > 50000. This requires formalizing the Fibonacci LTE — the identity v_p(F(mk)) = v_p(F(m)) + v_p(k) for odd primes p | F(m) — which follows from the standard LTE (`padicValNat.pow_sub_pow` in Mathlib) applied to the eigenvalues of the Fibonacci companion matrix. The mathematical argument is outlined in the file's documentation.

### Python Demo (`demos/fibonacci_primitive_divisors.py`)
- Interactive table of Fibonacci primitive prime divisors for n = 1..30
- Sharpness demonstration (n = 12 is the last exception)
- Growth analysis of the primitive part Φ_n ≈ φ^{φ(n)}
- Visualizations saved as `demos/primitive_parts_growth.png` and `demos/entry_points.png`

### Research Paper (`paper/carmichael_theorem.md`)
- Mathematical background on entry points and strong divisibility
- Proof architecture (computational + asymptotic)
- Discussion of applications and future directions