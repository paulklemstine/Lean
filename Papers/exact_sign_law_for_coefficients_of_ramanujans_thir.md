# Computational Evidence — Sign law for ρ(q)

Ramanujan's third order mock theta function

$$\rho(q) = \sum_{m\ge 0} \frac{q^{2m(m+1)}}{\prod_{k=0}^{m}(1+q^{2k+1}+q^{4k+2})} = \sum_{n\ge0} r(n)\,q^{n}.$$

## 1. Small-case calculation

Two independent implementations were compared: (i) a Python power-series
computation using explicit series inversion, and (ii) the Lean model in
`Catalog/Novelty/RamanujanRhoMockTheta.lean` using the closed-form reciprocal
`1/(1+q^{2k+1}+q^{4k+2}) = (1-q^{2k+1})\sum_j q^{(6k+3)j}`. They agree exactly.

First coefficients `r(0..29)`:

```
n :  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29
r :  1 -1  0  1  0 -1  1 -1  0  1 -1  0  2 -1 -1  1 -1 -1  2 -1  0  2 -1 -1  2 -2 -1  3 -2 -1
```

Grouped by residue class mod 3:

| n mod 3 | sample values of r(n) (in increasing n)                    | observed sign |
|---------|------------------------------------------------------------|---------------|
| 0       | 1, 1, 1, 1, 2, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 6, 6, 7, 7, 8 | strictly > 0  |
| 1       | -1, 0, -1, -1, -1, -1, -1, -1, -2, -2, -2, -2, -3, -2, -3    | ≤ 0           |
| 2       | 0, -1, 0, 0, -1, -1, 0, -1, -1, -1, -1, -1, -1, -2, -2       | ≤ 0           |

Note: the positive class is **not** monotone (e.g. `r(12)=2` but `r(15)=1`); it
is strictly positive but only grows on average.

## 2. The exact zero set

Within the negative residue classes (`n ≢ 0 mod 3`), the coefficient `r(n)`
vanishes **only** at

```
n = 2, 4, 8, 11, 20.
```

No zero occurs in the class `n ≡ 0 (mod 3)`. Both facts are machine-verified for
all `n ≤ 150` (`negative_class_zeros`, `positive_class_pos`).

## 3. Counterexample hunt

The universal sign law
`r(3n) > 0 ∧ r(3n+1) ≤ 0 ∧ r(3n+2) ≤ 0`
was tested for all `n ≤ 150`. **No counterexample was found.** The verification is
recorded as the theorem `sign_law_finite`.

## 4. Structural observation driving the modulus 3

Each denominator factor `1 + q^{2k+1} + q^{4k+2}` has exponents `0, 2k+1, 4k+2`.
Modulo 3 these are `{0, a, 2a}` with `a = (2k+1) mod 3`; whenever `a ≠ 0` this is a
complete residue system mod 3. The reciprocal has the closed form
`(1-q^{2k+1})/(1-q^{6k+3})`, coming from the cube identity
`(1-Y)(1+Y+Y^2) = 1-Y^3`. This identity, and the resulting telescoping product
`∏(1-q^{2k+1})·∏(1+q^{2k+1}+q^{4k+2}) = ∏(1-q^{6k+3})`, are proved in full
generality in `Catalog/Novelty/RamanujanRhoFactorization.lean`.

## 5. Sequence note

The coefficient sequence `1, -1, 0, 1, 0, -1, 1, -1, 0, 1, -1, 0, 2, …` is the
power-series expansion of the third order mock theta function `ρ(q)`. (No specific
OEIS identifier is asserted here to avoid an unverified reference.)
