# Computational evidence — DIAL-CROSS-TALK (paper 121)

The splitting type of an unramified prime `p` in a cubic field is read off from the number of
roots of the cubic mod `p` (3 roots → `111`, 1 root → `12`, 0 roots → `3`).  Primes
`5 ≤ p < 30000` that are unramified in both fields were used.  Mutual information is the plug-in
estimate in bits.  (Ad-hoc Python exploration; the exact values are what the Lean file proves.)

## 1. Small cases (exact, group side — proved in Lean)

| sample space | order | `H(T₁)` | `H(T₁ \| T₂)` | `I(T₁;T₂)` |
|---|---|---|---|---|
| `S₃ × S₃` (coprime discriminants) | 36 | `2/3 + ½ log₂3` | `2/3 + ½ log₂3` | **0** |
| `S₃ ×_{C₂} S₃` (shared resolvent) | 18 | `2/3 + ½ log₂3` | `½ log₂3 − 1/3` | **1** |
| `(S₃×S₃)²` semiprime pairs | 1296 | `4/3 + log₂3` | — | **0** |
| `(S₃×_{C₂}S₃)²` semiprime pairs | 324 | `4/3 + log₂3` | — | **2** |

Joint law on `S₃ ×_{C₂} S₃` (counts out of 18): `111/111:1, 111/3:2, 3/111:2, 3/3:4, 12/12:9`,
every other cell 0.

## 2. Prime experiments (empirical, not formally verified)

| pair | kind | primes | empirical `I` (bits) | theory |
|---|---|---|---|---|
| `x³+x+1` / `x³−x−1` (disc −31 / −23) | coprime | 3241 | 0.000243 | 0 |
| `x³−2` / `x³+x+1` | coprime | 3242 | 0.000808 | 0 |
| `x³−2` / `x³−3` (both `ℚ(√−3)`) | shared | 3243 | 1.000267 | 1 |
| `x³−2` / `x³−5` (both `ℚ(√−3)`) | shared | 3242 | 1.000023 | 1 |

Joint counts, `x³+x+1` vs `x³−x−1`: 82, 263, 180 / 275, 811, 546 / 170, 554, 360
(product law: 90, 270, 180 / 270, 810, 540 / 180, 540, 360).
Plug-in bias for a 3×3 table: `4/(2n ln 2) ≈ 0.00089` bits — the paper's `0.000437` is inside it.

## 3. Semiprimes

Consecutive prime pairs `(p, q)`, coprime cubics: 1617 samples, empirical `I(pair₁;pair₂) =
0.0216` bits, versus 9×9 bias `64/(2n ln 2) ≈ 0.029`.  Consistent with the exact `0`.

## 4. Counterexample hunt

No coprime-resolvent pair showed cross-talk beyond bias.  The only way to get cross-talk that we
found is a shared quadratic resolvent, and there it is 1 bit (to within 3·10⁻⁴).  A search for a
second cubic field with resolvent `ℚ(√−31)` among `x³+ax²+bx+c`, `|a| ≤ 1`, `|b|,|c| ≤ 40`, found
none (every candidate defined the same field as `x³+x+1`), so the pure cubics over `ℚ(√−3)` were
used for the shared case.

## 5. OEIS

No integer sequence arises; not applicable.
