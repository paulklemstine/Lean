# Computational Evidence

## Object

For `n ≥ 1`, `σ₅(n)` is the minimal absolute value of a non-vanishing sum of `n`
fifth roots of unity:

```
σ₅(n) = min { |∑_{j} ζ^{k_j}| : k_1,…,k_n ∈ {0,…,4},  ∑_j ζ^{k_j} ≠ 0 },   ζ = e^{2πi/5}.
```

## Small-case calculations (brute force over all multisets of n roots)

| n  | σ₅(n)      | closed form           |
|----|------------|-----------------------|
| 1  | 1.000000   | 1                     |
| 2  | 0.618034   | φ⁻¹                   |
| 3  | 0.618034   | φ⁻¹                   |
| 4  | 0.381966   | φ⁻²                   |
| 5  | 0.726543   | (algebraic in φ)      |
| 6  | 0.381966   | φ⁻²                   |
| 7  | 0.236068   | φ⁻³                   |
| 8  | 0.236068   | φ⁻³                   |
| 9  | 0.381966   | φ⁻²                   |
| 10 | 0.449028   | (algebraic in φ)      |
| 11 | 0.145898   | φ⁻⁴                   |
| 12 | 0.236068   | φ⁻³                   |
| 13 | 0.236068   | φ⁻³                   |
| 14 | 0.145898   | φ⁻⁴                   |
| 15 | 0.277515   | (algebraic in φ)      |

Here `φ = (1+√5)/2 = 1.618034…`, `φ⁻¹ = 0.618034…`, `φ⁻² = 0.381966…`,
`φ⁻³ = 0.236068…`, `φ⁻⁴ = 0.145898…`.

**Key observation.** Every computed value of `σ₅(n)` is an algebraic number in the
golden field `ℚ(√5)`, and along each residue class `n ≡ r (mod 5)` the values are
monotone non-increasing.  The reciprocal golden powers `φ⁻ᵏ` appear repeatedly.  This
is exactly the phenomenon the formalized bridge explains: the two Gaussian periods of
`ℚ(ζ₅)` are `-φ` and `-ψ = φ⁻¹`, so the arithmetic of these sums is governed by powers
of the golden ratio — and hence by Fibonacci and Lucas numbers.

## The n = 2 value and the formalized theorem

The moduli of the two-term sums `ζ^a + ζ^b` are, for `k = b - a (mod 5)`,
`2|cos(πk/5)| ∈ {2, φ, φ⁻¹}` (and `k = 0` gives `2`, never vanishing).  The minimum
over non-vanishing sums is `φ⁻¹`, so `σ₅(2) = φ⁻¹`.  This matches the table and is the
value witnessed by the theorem `golden_ratio_is_modulus` in the Lean file: the two
Gaussian periods have moduli exactly `{φ, φ⁻¹}`.

## Monotonicity and jumps (checked numerically)

Along `n ≡ 2 (mod 5)`: `σ₅(2) = φ⁻¹ > σ₅(7) = φ⁻³ = σ₅(12) = …`; the strict drop
happens at `n + 5 = 7 = L₄` (a Lucas number).

Along `n ≡ 0 (mod 5)`: strict drops occur at `n + 5 = 10 = 5·F₃` and `n + 5 = 15 = 5·F₄`.

These agree with the conjectured description of the jump set as `{5Fₘ, Lₘ, 2Lₘ}`
(with `Fₘ`, `Lₘ` the Fibonacci and Lucas numbers).  A full proof of the jump
characterization is left to future work (see `FUTURE_DIRECTIONS.md`); the formalized
results establish the exact algebraic bridge (Gaussian periods ↔ golden ratio ↔
Fibonacci/Lucas) that makes those integer sequences appear.

## OEIS

* Fibonacci numbers `Fₙ`: A000045 (`0,1,1,2,3,5,8,13,…`).
* Lucas numbers `Lₙ`: A000032 (`2,1,3,4,7,11,18,29,…`).

## Counterexample hunt

No counterexample was found to the two proven unconditional identities
`(ζ+ζ⁴)ⁿ + (ζ²+ζ³)ⁿ = (-1)ⁿ Lₙ` and `((ζ+ζ⁴)ⁿ − (ζ²+ζ³)ⁿ)² = 5 Fₙ²`; both were
checked numerically for `n ≤ 20` and are proved in Lean for all `n`.
