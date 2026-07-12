# Computational Evidence — Fractional-slope irreducibility

Setup: for an odd prime `p`, even weight `k`, and `a_p` with normalised valuation
`s = v(a_p)` (with `v(p) = 1`), the Frobenius eigenvalues are roots of
`X² − a_p·X + p^{k−1}`. Their Newton-polygon valuations (Frobenius slopes) are
`s` and `(k−1) − s` whenever `0 < s < (k−1)/2`.

## 1. Small-case slope tables

| p | k | s = v(a_p) | lowSlope | highSlope | sum | both fractional? | distinct? |
|---|---|------------|----------|-----------|-----|------------------|-----------|
| 3 | 6 | 1/3        | 1/3      | 14/3      | 5   | yes              | yes       |
| 5 | 8 | 2/5        | 2/5      | 33/5      | 7   | yes              | yes       |
| 5 | 6 | 1/2        | 1/2      | 9/2       | 5   | yes              | yes       |
| 7 | 10| 3/7        | 3/7      | 60/7      | 9   | yes              | yes       |
| 3 | 4 | 1/2        | 1/2      | 5/2       | 3   | yes              | yes       |

In every fractional-slope row both Newton slopes are non-integral and unequal,
matching `slopes_sum`, `lowSlope_lt_highSlope`, and `highSlope_not_isInt`.

Boundary (balanced) case: if `s = (k−1)/2` the two slopes coincide; for even `k`,
`(k−1)/2` is a genuine half-integer (`middle_slope_half_integer`), so it is still
fractional but distinctness fails — this is exactly why the strict bound
`2s < k−1` is load-bearing.

## 2. Residual (mod p) discriminant checks

The irreducibility of a two–dimensional residual representation with trace `a` and
determinant `d` over `𝔽_p` is governed by whether `disc = a² − 4d` is a square.

| p | a | d | a²−4d mod p | square in 𝔽_p? | residual irreducible? |
|---|---|---|-------------|----------------|-----------------------|
| 5 | 1 | 2 | 3           | no             | yes                   |
| 5 | 0 | 1 | 1 (=−4)     | yes            | no                    |
| 7 | 1 | 1 | 4           | yes            | no                    |
| 7 | 2 | 3 | 6           | no             | yes                   |

Squares mod 5 are `{0,1,4}` (3 is a non-square); squares mod 7 are `{0,1,2,4}`
(6 is a non-square). Both irreducible rows are confirmed by `decide` in the Lean file.

## 3. Counterexample hunt

The universal claim being certified is arithmetic: *for even `k` and fractional
`s` with `2s < k−1`, both Newton slopes are non-integral, distinct, and sum to
`k−1`.* A search over `k ∈ {4,6,8,10,12}` and `s = j/p` for `p ∈ {3,5,7}`,
`1 ≤ j < p·(k−1)/2` found **no counterexample**: whenever `s` is non-integral so
is `(k−1) − s`, since they differ by the integer `k−1`. This is precisely the
propagation proved in `highSlope_not_isInt`.

## 4. OEIS note

No integer sequence is central here; the objects are rational valuations. The
count of quadratic non-residues mod `p` equals `(p−1)/2` (A005097-adjacent),
matching the density of trace values `a` giving irreducible residual reductions
when `d` is a fixed non-zero-slope datum.
