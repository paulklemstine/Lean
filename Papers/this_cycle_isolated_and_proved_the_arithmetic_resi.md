# Computational Evidence

Supporting the theorems in `EisensteinPowerCongruence.lean`.

## 1. Pointwise power residues

`d⁷ − d³` and `d⁵ − d³` were checked exhaustively over the relevant residue
systems inside `ZMod` (proved in Lean by `decide`):

* `∀ x : ZMod 120, x⁷ = x³`  ✓
* `∀ x : ZMod 24,  x⁵ = x³`  ✓

Sharpness witnesses:

* `2⁷ − 2³ = 128 − 8 = 120`  → no modulus larger than `120` can divide all `d⁷ − d³`.
* `2⁵ − 2³ = 32 − 8 = 24`   → `24` is sharp for the weight-`6` law.

## 2. Divisor-sum congruence `σ₇(n) ≡ σ₃(n) (mod 120)`

First divisor sums (`σ_k(n) = ∑_{d∣n} d^k`) and the residue:

| n | σ₃(n) | σ₇(n) | σ₇(n) − σ₃(n) | ÷120 |
|---|-------|-------|----------------|------|
| 1 | 1     | 1     | 0              | 0    |
| 2 | 9     | 129   | 120            | 1    |
| 3 | 28    | 2188  | 2160           | 18   |
| 4 | 73    | 16513 | 16440          | 137  |
| 5 | 126   | 78126 | 78000          | 650  |

Sharpness witness for the divisor-sum form: `σ₇(2) − σ₃(2) = 120`.

## 3. Exact convolution law (Direction 1)

Conjecture: `σ₇(n) = σ₃(n) + 120·∑_{i=1}^{n-1} σ₃(i)·σ₃(n−i)`.

Verified computationally (`decide`) for `n = 0, 1, …, 11` — all hold. The first
five (`n = 2,3,4,5`) are proved as named theorems (`convolution_law_two` …
`convolution_law_five`). Example, `n = 2`:
`σ₇(2) = 129`, `σ₃(2) = 9`, `∑ = σ₃(1)·σ₃(1) = 1`, and `9 + 120·1 = 129` ✓.

The general convolution identity is equivalent to the transcendental modular
identity `E₄² = E₈` and is left as future work (see `FUTURE_DIRECTIONS.md`).

## 4. E₈-normalized modulus (Direction 3)

`28800 = 240 · 120`. Since `120 ∣ σ₇(n) − σ₃(n)`, multiplying by the `E₈`
vector-count normalization `240` gives `28800 ∣ 240·σ₇(n) − 240·σ₃(n)`
(theorem `E8_normalized_congruence`), the modulus against which the two rank-16
even unimodular lattices are compared.

## No counterexamples

No counterexample was found to any congruence tested; the sharpness witnesses
confirm the moduli `120` and `24` are exactly optimal.
