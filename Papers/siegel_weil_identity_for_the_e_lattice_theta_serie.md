# Computational Evidence: the `E₄² = E₈` congruence shadow

We study the weight-`8` / weight-`4` divisor sums
`σ₇(n) = ∑_{d ∣ n} d⁷` and `σ₃(n) = ∑_{d ∣ n} d³`, the Fourier coefficient
systems of the Eisenstein series `E₈` and `E₄`. The Siegel–Weil identity for
rank `8` gives `θ_{E₈} = E₄`; squaring yields `E₄² = E₈`, whose coefficient form
is the convolution law

```
σ₇(n) = σ₃(n) + 120 · ∑_{i=1}^{n-1} σ₃(i)·σ₃(n-i).
```

## 1. Small-case verification of the convolution law

Writing `C(n) = ∑_{i=1}^{n-1} σ₃(i)·σ₃(n-i)`:

| n  | σ₇(n)    | σ₃(n) + 120·C(n) | equal? |
|----|----------|------------------|--------|
| 1  | 1        | 1                | ✓      |
| 2  | 129      | 129              | ✓      |
| 3  | 2188     | 2188             | ✓      |
| 4  | 16513    | 16513            | ✓      |
| 5  | 78126    | 78126            | ✓      |
| 6  | 282252   | 282252           | ✓      |
| 7  | 823544   | 823544           | ✓      |
| 8  | 2113665  | 2113665          | ✓      |
| 9  | 4785157  | 4785157          | ✓      |
| 10 | 10078254 | 10078254         | ✓      |
| 11 | 19487172 | 19487172         | ✓      |

The convolution law holds on the entire tested range, so `σ₇(n) − σ₃(n)` is a
positive multiple of `120` for every `n ≥ 1`.

## 2. The congruence residue

Reducing the coefficient systems modulo `120`:

| n | σ₇(n) mod 120 | σ₃(n) mod 120 |
|---|---------------|---------------|
| 1 | 1  | 1  |
| 2 | 9  | 9  |
| 3 | 28 | 28 |
| 4 | 73 | 73 |
| 5 | 6  | 6  |
| 6 | 12 | 12 |
| 7 | 104| 104|
| 8 | 105| 105|
| 9 | 37 | 37 |

The two systems coincide modulo `120` — this is the statement proved in full
generality as `sigma7_modEq_sigma3`.

## 3. Optimality of the modulus

At `n = 2` the difference is `σ₇(2) − σ₃(2) = 129 − 9 = 120`, which is divisible
by `120` but **not** by `240`. Hence `120` is the largest modulus for which the
congruence `σ₇ ≡ σ₃` holds universally; this sharpness is formalized as
`sigma7_not_modEq_sigma3_mod240`.

## 4. Pointwise power congruence

The engine of the divisor-sum congruence is `d⁷ ≡ d³ (mod 120)` for all `d`,
verified on residues `0,…,119` and proved by gluing the coprime factors `8, 3,
5` via the Chinese Remainder Theorem. Sequence of `d⁷ − d³` for `d = 0,…,6`:
`0, 0, 120, 2160, 16320, 78000, 279720`, each a multiple of `120`.
