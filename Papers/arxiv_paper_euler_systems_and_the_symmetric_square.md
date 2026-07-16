# Computational evidence

The finite computation concerns the contrarian faithfulness conjecture for the scalar model of symmetric square, `x ↦ x²`.

## Small cases and counterexample hunt

| x | y | x² | y² | same input? |
|---:|---:|---:|---:|:---:|
| 1 | -1 | 1 | 1 | no |
| 2 | -2 | 4 | 4 | no |
| 3 | -3 | 9 | 9 | no |
| 0 | 0 | 0 | 0 | yes |

Thus exact faithfulness fails immediately at `(1, -1)`. Testing the integer box `-10 ≤ x,y ≤ 10` yields the pattern `x² = y²` exactly when `x = y` or `x = -y`. The Lean development proves this corrected characterization over every commutative integral domain, so the table is evidence rather than the basis of verification.

## Sequence / OEIS

The relevant nonnegative values are the squares `0, 1, 4, 9, 16, 25, …`, commonly catalogued as OEIS A000290. No OEIS fact is used in the formal proof.

## Interpretation

The calculation warns against an unconditional claim that symmetric square retains exact input data. It retains scalar data only modulo sign; in representation-theoretic settings the analogous expected ambiguity is quadratic twisting.
