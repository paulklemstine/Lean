# Computational Evidence — Alien Number Systems: Beyond Base-N

All claims below are reproduced as fully proved (0-`sorry`) Lean theorems in
`FactorialBase.lean` and `TowerAndLowerBounds.lean`. This note records the
small-case numerics that guided the formalization.

## 1. Factorial number system (factoradic)

Canonical digit extractor: `factDigit n i = (n / i!) % (i+1)`, position weight `i!`,
digit at position `i` ranges over `{0,…,i}`.

Worked example `n = 17`:

| position i | weight i! | digit (17/i!)%(i+1) | contribution |
|-----------:|----------:|--------------------:|-------------:|
| 1          | 1         | 1                   | 1            |
| 2          | 2         | 2                   | 4            |
| 3          | 6         | 2                   | 12           |

Sum `= 1 + 4 + 12 = 17`. ✓  (`#eval` confirmed: digits `1,2,2`.)

First factoradic representations (digits high→low, positions 3,2,1):

```
0 -> 0 0 0      5 -> 0 2 1      10 -> 1 2 0
1 -> 0 0 1      6 -> 1 0 0      11 -> 1 2 1
2 -> 0 1 0      7 -> 1 0 1      12 -> 2 0 0
3 -> 0 1 1      8 -> 1 1 0      ...
4 -> 0 2 0      9 -> 1 1 1      23 -> 3 2 1 = 4!-1
```

`k` factoradic digits cover exactly `{0,…,(k+1)!-1}` (identity
`∑_{i=1}^k i·i! = (k+1)!-1`, checked `decide` at `k=4`: `∑ = 119 = 5!-1`).

## 2. Digit-efficiency separation (growing vs fixed radix)

Maximum value representable with `k` digits:

| k | binary `2^k - 1` | factoradic `(k+1)! - 1` |
|--:|-----------------:|------------------------:|
| 1 | 1                | 1                       |
| 2 | 3                | 5                       |
| 3 | 7                | 23                      |
| 4 | 15               | 119                     |
| 5 | 31               | 719                     |

So `2^k ≤ (k+1)!` always, strict for `k ≥ 2` — a fixed alphabet wastes capacity
relative to the growing factoradic radix. (Formalized: `two_pow_le_factorial`,
`two_pow_lt_factorial`, `factoradic_beats_binary`.)

## 3. Tower base and the log* conjecture

`tower 0 = 1`, `tower (k+1) = 2 ^ tower k`:

```
tower 0 = 1
tower 1 = 2
tower 2 = 4
tower 3 = 16
tower 4 = 65536
tower 5 = 2^65536   (astronomically large)
```

The number of tower "blocks" needed for `n` is the iterated logarithm `log* n`, which
is ≤ 5 for every `n < 2^65536`. The digit *count* really is sub-logarithmic.

## 4. Counterexample hunt — does tower base give compression?

Claim tested: "tower base yields sub-logarithmic *information* content."

**Counterexample / refutation (information-theoretic):** Any injective code into `k`
positions over a fixed alphabet of size `B` names at most `B^k` values. To label
`{0,…,n}` we therefore need `k > log_B n`. Tower base only beats this by using an
*unbounded* per-position alphabet (`tower k → ∞`), so the "missing" `log n` bits are
hidden inside the digits. No fixed-alphabet positional system can be sub-logarithmic.
(Formalized: `alphabet_card_bound`, `fixedAlphabet_needs_log_digits`,
`tower_unbounded`.)

**Verdict:** "log* digit count" — TRUE. "Sub-logarithmic compression" — FALSE.

## OEIS pointers

- Factoradic / factorial base: OEIS A007623.
- `∑ i·i! = (n+1)! - 1`: OEIS A033312 (`n! - 1`).
- Power tower of 2: OEIS A014221 (`1, 2, 4, 16, 65536, …`).
