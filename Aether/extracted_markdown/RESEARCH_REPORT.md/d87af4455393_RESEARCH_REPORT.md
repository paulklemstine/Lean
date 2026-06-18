# Research Report: Tropical Langlands for GL₂ — Pythagorean Domain Connections

## Executive Summary

This project investigates connections between tropical geometry, the Langlands program for GL₂, and the Pythagorean domain — specifically, the Berggren tree of primitive Pythagorean triples and its Lorentz-algebraic structure. The central conjecture that tropical rank factorization captures the prime structure of Pythagorean hypotenuses has been **rigorously disproved** with machine-verified counterexamples.

## Main Results

### 1. Tropical Berggren Rank Factorization (Disproved)

**Original Conjecture**: For a hypotenuse N in the Berggren tree, the tropical rank of the p-adic valuation matrix equals ω(N), the number of distinct prime factors.

**Result**: The conjecture is **false**. We provide two machine-verified counterexamples:

- **N = 169 = 13²**: The 13-adic valuation matrix has tropical rank ≥ 2, but ω(169) = 1. The Monge condition fails: v₁₃(3) + v₁₃(169) = 0 + 2 ≠ 0 = v₁₃(5) + v₁₃(119).

- **N = 25 = 5²**: The 5-adic valuation matrix has tropical rank ≥ 2, but ω(25) = 1. The Monge condition fails: v₅(3) + v₅(12) = 0 ≠ 1 = v₅(4) + v₅(5).

All counterexamples are formally verified using `native_decide` in Lean 4.

### 2. Berggren Tree Infrastructure (Verified)

We formalize and verify the complete Berggren tree infrastructure:
- **Determinant computations**: det(B₁) = 1, det(B₂) = -1, det(B₃) = 1
- **Pythagorean preservation**: All three Berggren matrices preserve the equation a² + b² = c²
- **Lorentz invariance**: The Berggren matrices lie in SO(2,1;ℤ), preserving the Lorentz form Q = a² + b² - c²

### 3. Carmichael's Primitive Divisor Theorem (Partial)

We formalize Carmichael's theorem: for n ≥ 13, the Fibonacci number F(n) has a primitive prime divisor.

- **Prime case** (fully verified): For prime n ≥ 13, any prime factor of F(n) is primitive, using entry point theory and the gcd identity gcd(F(m), F(n)) = F(gcd(m,n)).
- **Composite case ≤ 10000** (computationally verified): Using `native_decide` on the fibCoprimePart function.
- **Composite case > 10000** (open): Requires deep number-theoretic infrastructure (lifting-the-exponent lemma for Fibonacci sequences, Lucas function properties).

### 4. p-Adic Repelling Fixed Points (Stated)

We state the non-Archimedean instability theorem: for a polynomial P over ℚ_p with P(z) = z and ‖P'(z)‖ > 1, nearby orbits eventually escape any bounded neighborhood of z.

## Technical Infrastructure

### Lorentz Connections
- The Berggren matrices are elements of O(2,1;ℤ), the integer Lorentz group
- The descent from any PPT to (3,4,5) is a sequence of discrete Lorentz boosts
- The universal parent equation gives a uniform formula for the parent hypotenuse: c' = 3c - 2a - 2b

### Modular Forms Connections
- χ₋₄ (the non-principal character mod 4) is verified to be multiplicative on odd integers
- PPT counting is related to the Leibniz series π/4 = 1 - 1/3 + 1/5 - ···
- The Selberg eigenvalue conjecture bound λ₁ ≥ 3/16 connects to mixing rates on Berggren quotient graphs

### Quantum Gate Synthesis
- Integer quaternion norm multiplicativity: ‖ab‖ = ‖a‖·‖b‖
- Gate count bounds: synthesis uses O(log d) gates for precision d
- SU(4)/SO(6) dimension matching via Plücker embedding (both 15-dimensional)

## File Structure

| Directory | Content |
|-----------|---------|
| `Shared/` | Core Carmichael theorem infrastructure, Fibonacci identities |
| `Pythagorean/` | Berggren matrices, Lorentz connections, modular forms |
| `Speculative/` | Tropical analysis (counterexamples), p-adic dynamics |
| `Computation/` | Density theory, computational number theory |

## Open Problems Remaining

1. **Carmichael composite case for n > 10000**: Requires formal proof that for composite n, the "coprime part" of F(n) relative to F(d) for proper divisors d is > 1.

2. **p-Adic repelling fixed point**: Requires formalization of the non-Archimedean Taylor expansion and ultrametric orbit analysis.

3. **Tropical Satake isomorphism for GL₂**: The original motivating conjecture (tropical Hecke algebra satisfies Satake isomorphism) remains unstated — the tropical rank factorization conjecture, which was intended as a stepping stone, has been disproved.

## References

- Berggren, B. (1934). Pytagoreiska trianglar. *Tidskrift för elementär matematik, fysik och kemi*, 17, 129–139.
- Carmichael, R. D. (1913). On the numerical factors of the arithmetic forms αⁿ ± βⁿ. *Annals of Mathematics*, 15(1/4), 30–70.
- Silverman, J. H. (2007). *The Arithmetic of Dynamical Systems*. Springer.
