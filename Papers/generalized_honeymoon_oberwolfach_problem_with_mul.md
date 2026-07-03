# Computational Evidence — Generalized Honeymoon Oberwolfach Problem

All computations below were run inside Lean (decision procedures / `#eval`) against the
definitions in `Basic.lean`, so the numbers are machine-checked, not hand-tabulated.

## 1. The acquaintance count `2n(n-1)`

For `n` couples (`2n` guests) the number of non-spouse unordered pairs is
`C(2n,2) - n`.

| `n` | guests `2n` | `C(2n,2)` | couples `n` | `acq` count | `2n(n-1)` |
|----:|------------:|----------:|------------:|------------:|----------:|
| 2   | 4           | 6         | 2           | 4           | 4         |
| 3   | 6           | 15        | 3           | 12          | 12        |
| 4   | 8           | 28        | 4           | 24          | 24        |
| 5   | 10          | 45        | 5           | 40          | 40        |

`#eval (acq 2).card, (acq 3).card, (acq 4).card` returned `4, 12, 24`.
This rules out the naive guess `n(n-1)` (which gives `2, 6, 12`) and confirms the
right-hand side of the divisibility condition is `2n(n-1)`.

The sequence `2, 12, 24, 40, 60, …` (i.e. `2n(n-1)`) is **OEIS A046092** (`4·triangular`)
scaled, equivalently `A002378` (pronic numbers `n(n-1)`) doubled.

## 2. Divisibility gate `M ∣ 2n(n-1)` for multiple round tables

With `M = ∑ mᵢ` and `n = s + M`, the necessary condition is `M ∣ 2n(n-1)`.  Representative
multi-round-table instances (`t ≥ 2`):

| couples `n` | round tables (sizes) | `s` | `M = ∑ mᵢ` | `2n(n-1)` | `M ∣ 2n(n-1)`? | nights `D` |
|------------:|----------------------|----:|-----------:|---------:|:--------------:|-----------:|
| 4 | 4, 4 (`m=2,2`)        | 0   | 4          | 24        | yes            | 6          |
| 6 | 4, 8 (`m=2,4`)        | 0   | 6          | 60        | yes            | 10         |
| 6 | 4, 4 (`m=2,2`)        | 2   | 4          | 60        | yes            | 15         |
| 5 | 4, 6 (`m=2,3`)        | 0   | 5          | 40        | yes            | 8          |
| 7 | 4, 4, 6 (`m=2,2,3`)   | 0   | 7          | 84        | yes            | 12         |
| 8 | 6, 6 (`m=3,3`)        | 2   | 6          | 112       | no (112/6)     | —          |

The row `n=8, M=6` shows the condition genuinely fails for some multi-table configurations
(`6 ∤ 112`), confirming the divisibility test is non-vacuous as a filter.

## 3. Explicit two-round-table construction (`n = 4`, `t = 2`)

Guests `0..7 = (couple, spouse)`.  Six nights, each two round tables of size 4:

```
N1: (C0C1 ∥)(C2C3 ∥) = 0-2 1-3 | 4-6 5-7
N2: (C0C1 ×)(C2C3 ×) = 0-3 1-2 | 4-7 5-6
N3: (C0C2 ∥)(C1C3 ∥) = 0-4 1-5 | 2-6 3-7
N4: (C0C2 ×)(C1C3 ×) = 0-5 1-4 | 2-7 3-6
N5: (C0C3 ∥)(C1C2 ∥) = 0-6 1-7 | 2-4 3-5
N6: (C0C3 ×)(C1C2 ×) = 0-7 1-6 | 2-5 3-4
```

Machine checks (`decide`) confirm: each night realises exactly 4 acquaintance pairs,
the six nights are pairwise disjoint, and their union is **exactly** the 24-element set
`acq 4`.  Hence `multiTableSchedule : HoneymoonSchedule 4 6 4` is a genuine partition.

## 4. Counterexample hunt for the *necessary* direction

No counterexample exists (and none should): the theorem `honeymoon_divisibility` proves
that *every* schedule forces `M ∣ 2n(n-1)`.  The hunt instead targeted the modelling
assumption "each night contributes exactly `M` acquaintance pairs".  Re-deriving `M` from
first principles (a size-`2m` round table with couples adjacent has `2m` cycle edges, of
which `m` are spouse edges) confirms `m` acquaintance edges per round table and `M = ∑ mᵢ`
per night, matching the partition model.
