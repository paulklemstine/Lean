# Computational Evidence — σ₅(n), minimal modulus of a sum of n fifth roots of unity

## Definition tested
For `ζ = exp(2πi/5)`, `σ₅(n) = min { |a₀ + a₁ζ + a₂ζ² + a₃ζ³ + a₄ζ⁴| : aⱼ ∈ ℕ, Σ aⱼ = n }`.

## Small-case table (brute force over all multiplicity tuples)

| n | n mod 5 | σ₅(n) |
|---|---------|-------|
| 0 | 0 | 0.00000 |
| 1 | 1 | 1.00000 |
| 2 | 2 | 0.61803 |
| 3 | 3 | 0.61803 |
| 4 | 4 | 0.38197 |
| 5 | 0 | 0.00000 |
| 6 | 1 | 0.38197 |
| 7 | 2 | 0.23607 |
| 8 | 3 | 0.23607 |
| 9 | 4 | 0.38197 |
| 10 | 0 | 0.00000 |
| 11 | 1 | 0.14590 |
| 12 | 2 | 0.23607 |
| 13 | 3 | 0.23607 |
| 14 | 4 | 0.14590 |
| 15 | 0 | 0.00000 |
| 16 | 1 | 0.14590 |
| 17 | 2 | 0.23607 |
| 18 | 3 | 0.09017 |
| 19 | 4 | 0.14590 |
| 20 | 0 | 0.00000 |

## Monotonicity check within each residue class (the conjecture)
* r=0: 0, 0, 0, 0, 0  — non-increasing ✓ (in fact identically 0)
* r=1: 1.000, 0.382, 0.146, 0.146 — non-increasing ✓
* r=2: 0.618, 0.236, 0.236, 0.236 — non-increasing ✓
* r=3: 0.618, 0.236, 0.236, 0.090 — non-increasing ✓
* r=4: 0.382, 0.382, 0.146, 0.146 — non-increasing ✓

No counterexample found up to n = 20 (all 5 classes). This matches the padding
argument: appending one copy of each root (`1+ζ+ζ²+ζ³+ζ⁴ = 0`) turns any optimal
size-n configuration into a size-(n+5) configuration of equal modulus, so
`σ₅(n+5) ≤ σ₅(n)`.

## Why the residue framing is necessary (cross-class non-monotonicity)
σ₅ is NOT globally monotone in n: e.g. σ₅(4)=0.382, σ₅(5)=0, σ₅(6)=0.382 goes down
then up. The monotone structure lives entirely along arithmetic progressions of
common difference 5.

## Golden-ratio fingerprints
The attained values are algebraic numbers in ℚ(√5): 0.61803… = φ⁻¹, 0.38197… = φ⁻²,
0.23607… = √5 − 2, 0.14590…, 0.09017…, reflecting that ℚ(ζ₅) contains the golden
ratio. This suggests (see FUTURE_DIRECTIONS) a closed form for σ₅ in terms of φ.

## OEIS
The value sequence is real-valued (irrational), so not a direct OEIS integer
sequence; the underlying combinatorial "reduced budget" counts are standard
compositions into 5 parts (OEIS A000581-style constructions), the enumerative
backdrop of MSC 05A15.
