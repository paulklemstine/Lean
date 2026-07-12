# Computational Evidence — Siegel–Weil identity for the E₈ theta series

We test the prediction `r(n) = 240·σ₃(n)`, where `r(n)` is the number of vectors
of squared length `2n` in an even, positive-definite, unimodular rank-`8` lattice
(necessarily the `E₈` lattice), and `σ₃(n) = ∑_{d ∣ n} d³`.

## 1. Small-case calculations

| n | σ₃(n) = ∑_{d∣n} d³            | 240·σ₃(n) | known E₈ count of norm 2n |
|---|-------------------------------|-----------|---------------------------|
| 1 | 1                             | 240       | 240 (the roots)           |
| 2 | 1 + 8 = 9                     | 2160      | 2160                      |
| 3 | 1 + 27 = 28                   | 6720      | 6720                      |
| 4 | 1 + 8 + 64 = 73              | 17520     | 17520                     |
| 5 | 1 + 125 = 126                | 30240     | 30240                     |
| 6 | 1 + 8 + 27 + 216 = 252      | 60480     | 60480                     |
| 7 | 1 + 343 = 344               | 82560     | 82560                     |
| 8 | 1 + 8 + 64 + 512 = 585      | 140400    | 140400                    |

All eight values match the classical `E₈` vector counts. The first five of these
matches are verified exactly in the accompanying formal development
(`rE8_one`, …, `rE8_five`).

## 2. OEIS

* `σ₃(n)` = **A001158**: 1, 9, 28, 73, 126, 252, 344, 585, 757, 1134, …
* `240·σ₃(n)` (n ≥ 1) are the nonconstant Fourier coefficients of the Eisenstein
  series `E₄` and the theta series of `E₈`, **A004009**:
  1, 240, 2160, 6720, 17520, 30240, 60480, 82560, 140400, …

## 3. Structural checks (the Hecke eigenform property)

The identity `θ_{E₈} = E₄` forces the coefficient function `240·σ₃` to be that of
a Hecke eigenform. We tested the two structural laws proved formally:

* **Prime-power recurrence** `σ₃(p^{r+2}) + p³·σ₃(pʳ) = σ₃(p)·σ₃(p^{r+1})`:
  e.g. `p = 2`, `r = 1`: `σ₃(8) + 8·σ₃(2) = 585 + 72 = 657 = 9·73 = σ₃(2)·σ₃(4)`. ✓
* **Global Hecke identity** `σ₃(m)·σ₃(n) = ∑_{d ∣ gcd(m,n)} d³·σ₃(mn/d²)`:
  e.g. `m = 4, n = 6`, `gcd = 2`, `mn = 24`:
  `σ₃(24) + 8·σ₃(6) = 16380 + 2016 = 18396 = 73·252 = σ₃(4)·σ₃(6)`. ✓

## 4. Counterexample hunt

No counterexample exists: both structural identities are proved for all inputs in
the formal development, and the low-order counts agree with the tabulated `E₈`
data. A search over `1 ≤ m, n ≤ 40` of the global Hecke identity found perfect
agreement in every case.
