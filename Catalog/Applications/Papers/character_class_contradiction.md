# Computational Evidence — Character Class Contradiction

Object: `A = !![1,1;1,1]` (full 2-shift / Cuntz–Krieger matrix of `𝒪₂`), and the family
`J n =` (`n × n` all-ones matrix) `=` transition matrix of the full shift on `n` symbols
(`= 𝒪ₙ`). The "characteristic class / point count" is `N_r = tr((J n)^r)`.

## 1. Small-case calculations

### Point count `N_r = tr(A^r)` for `n = 2`

| r | A^r            | tr(A^r) | 2^r |
|---|----------------|---------|-----|
| 0 | I = !![1,0;0,1]| 2       | 1   |  (r=0 excluded: tr=2≠1)
| 1 | !![1,1;1,1]    | 2       | 2   |
| 2 | !![2,2;2,2]    | 4       | 4   |
| 3 | !![4,4;4,4]    | 8       | 8   |
| 4 | !![8,8;8,8]    | 16      | 16  |

So `tr(A^r) = 2^r` for `r ≥ 1`, never `0` — contradicting the naive "0 for r ≠ 1".

### Family `tr((J n)^r) = n^r`, `r ≥ 1`

| n \ r | 1 | 2  | 3   | 4    |
|-------|---|----|-----|------|
| 1     | 1 | 1  | 1   | 1    |  (the single F₁-point: count constant = 1)
| 2     | 2 | 4  | 8   | 16   |
| 3     | 3 | 9  | 27  | 81   |
| 4     | 4 | 16 | 64  | 256  |

The "expected vanishing/constant" regime is exactly `n = 1`.

## 2. Zeta reciprocal (Bowen–Lanford / Weil rationality)

`det(1 - t·J n) = 1 - n·t`:

| n | det(1 - t·J n) | Z(t) = 1/det |
|---|----------------|--------------|
| 1 | 1 - t          | 1/(1-t)      |
| 2 | 1 - 2t         | 1/(1-2t)     |
| 3 | 1 - 3t         | 1/(1-3t)     |

Consistency check: `Z(t) = exp(∑_{r≥1} N_r t^r / r) = exp(∑ n^r t^r / r) = exp(-log(1-nt)) = 1/(1-nt)`,
matching `1/det(1 - t·J n)`. ✓

## 3. K-theory order `K₀(𝒪ₙ) = ℤ/(n-1)`

`det(1 - J n) = 1 - n`, so `|det| = n - 1 = |K₀(𝒪ₙ)|`:

| n | det(1-J n) | K₀(𝒪ₙ)   |
|---|------------|----------|
| 1 | 0          | ℤ (degenerate / not finite) |
| 2 | -1         | ℤ/1 = 0  |  (verified as `Subsingleton` cokernel)
| 3 | -2         | ℤ/2      |
| 4 | -3         | ℤ/3      |

For `n = 2`, `1 - A` is unimodular (`det = -1`), so the cokernel of `1 - Aᵀ` on `ℤ²` is trivial:
`K₀(𝒪₂) = 0`. This is the classical "absorbing" property of `𝒪₂`.

## 4. Counterexample hunt

The universal claim under test is the *naive* "`tr((J n)^r) = 0` for all `r ≠ 1`". It is refuted
at the very first instance `n = 2, r = 2` (count `4 ≠ 0`); this is `naive_zero_expectation_false`.
No counterexample to the *proved* statements `n^r`, `1 - n·t`, `1 - n` was found across
`1 ≤ n ≤ 8`, `1 ≤ r ≤ 8` (all match exactly).

## Note

Every entry above is reproved symbolically (for all `n`, `r`) in the Lean files
`CharacterClassContradiction.lean` and `CuntzKriegerFullShiftFamily.lean`, not just spot-checked.
