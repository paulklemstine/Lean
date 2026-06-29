# Computational Evidence — Gaussian–Pythagorean Bridge for LWE Hardness

Scope: evidence supporting the claims formalized in
`Catalog/Cryptography/LWE/GaussianBridge.lean`.

## 1. Splitting primes are sums of two squares (Fermat)

Primes `p ≡ 1 (mod 4)` and an explicit decomposition `p = a² + b²`
(computed over ℕ):

| p  | (a, b) | a² + b² |
|----|--------|---------|
| 5  | (1, 2) | 5       |
| 13 | (2, 3) | 13      |
| 17 | (1, 4) | 17      |
| 29 | (2, 5) | 29      |
| 37 | (1, 6) | 37      |
| 41 | (4, 5) | 41      |

Inert primes `p ≡ 3 (mod 4)` (e.g. 3, 7, 11, 19, 23) admit **no** such
decomposition — matching `−1` being a non-residue mod `p`.

## 2. Brahmagupta–Fibonacci composition

`(1² + 2²)(2² + 3²) = 5·13 = 65 = (1·2 − 2·3)² + (1·3 + 2·2)² = (−4)² + 7² = 16 + 49`.

Note: the identity is an **integer** identity; evaluating the left witness over
ℕ truncates `1·2 − 2·3` to `0`, so the formal statement is correctly phrased over
`ℤ` (`brahmagupta_fibonacci`).

## 3. Gaussian norm sanity checks

`N(3 + 0i) = 9`, `N(a + bi) = a² + b²`, and `N` is multiplicative; units
`{1, −1, i, −i}` all have norm `1`, so rerandomizing by a unit preserves noise
magnitude.

## 4. Noise-disk containment

For `r = q/4 > 0`, any `(x, y)` with `x² + y² < r²` satisfies `|x| < r` and
`|y| < r`, since `x² ≤ x² + y² < r²`. This is the 2-D Euclidean (Pythagorean)
form of LWE decryption correctness.

All four observations are discharged as theorems (0 sorries) in the Lean file.
