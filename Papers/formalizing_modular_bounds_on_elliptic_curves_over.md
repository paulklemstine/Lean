# Computational evidence

All numbers below were produced with `#eval` inside Lean itself, using the definitions of
`Catalog/Combinatorics/EllipticPointCount.lean`
(`cardPoints a b` = affine points of `y² = x³ + a x + b` plus the point at infinity,
`frobTrace a b = q + 1 - cardPoints a b`, `charSum a b = ∑ₓ χ(x³+ax+b)`).
The most important checks were subsequently re-verified **by the Lean kernel** with
`decide` in `Catalog/Combinatorics/EllipticLabNotes.lean` (no `native_decide`).

## 1. Point counts in small families

| family | prime | counts (b or a running over F_p) |
|---|---|---|
| `y² = x³ + b` | 5 | `6, 6, 6, 6, 6` |
| `y² = x³ + b` | 11 | `12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12` |
| `y² = x³ + a x` | 7 | `8, 8, 8, 8, 8, 8, 8` |
| `y² = x³ + a x` | 13 | `14, 20, 10, 20, 8, 10, 10, 18, 18, 20, 8, 18, 8` |
| `y² = x³ + x + b` | 5 | `4, 9, 4, 4, 9` |
| `y² = x³ + x + b` | 13 | `20, 18, 12, 15, 14, 9, 13, 13, 9, 14, 15, 12, 18` |

Observations that became theorems:

* `5 % 3 = 2` and `11 % 3 = 2` ⟹ the `y² = x³ + b` counts are constantly `p + 1`
  (`cardPoints_zmod_eq_of_three`).
* `7 % 4 = 3` ⟹ the `y² = x³ + a x` counts are constantly `p + 1`
  (`cardPoints_zmod_eq_of_four`); for `13 % 4 = 1` they are *not* constant, so the
  congruence hypothesis is necessary, not an artefact.
* Every count above is `≡ 1 + #{roots of the cubic} (mod 2)` (`two_dvd_cardPoints_sub`).

## 2. The second moment `∑_{a,b} a(a,b)²`

| p | computed | `p³ - p²` |
|---|---|---|
| 5 | 100 | 100 |
| 7 | 294 | 294 |
| 11 | 1210 | 1210 |
| 13 | 2028 | 2028 |

This exact identity is `second_moment_charSum` / `second_moment_frobTrace`.
(The sequence `q³ - q²` = 4, 18, 100, 294, 1210, 2028, … is `q²(q-1)`; no OEIS lookup was
needed — the closed form was conjectured from the table and then proved.)

## 3. Vertical second moments `∑_b a(a,b)²` over `F_13` (`χ(-3) = +1` here)

| a | computed | `q² - q(1 + χ(-3) + χ(-a/3))` |
|---|---|---|
| 0 | 312 | 312 (via the `a = 0` formula `q(q-1)(1+χ(-3))`) |
| 1 | 130 | 130 |
| 2 | 156 | 156 |
| 3 | 130 | 130 |
| 4 | 130 | 130 |
| 5–8 | 156 | 156 |
| 9,10 | 130 | 130 |
| 11 | 156 | 156 |
| 12 | 130 | 130 |

Over `F_11` (`χ(-3) = -1`) the vertical moment at `a = 0` is `0`, i.e. the whole family
`y² = x³ + b` is supersingular — the computation that suggested
`vertical_second_moment_zero_eq_zero_iff` and the bridge
`cube_bijective_iff_char_neg_three`.

## 4. Counterexample hunt

* *Is the point count always even when the cubic has a root?* **No** — only for
  nonsingular curves. The singular curve `y² = x³ + 2x + 2 = (x-1)²(x+2)` over `F_5` has
  `disc = 0`, exactly two distinct roots, and `cardPoints = 7`, an odd number. So the
  guard `disc ≠ 0` in `two_dvd_cardPoints_iff` and `rootSet_card_cases` is not removable.
  This counterexample is kernel-checked as `singular_counterexample_F5`.
* *Is `a(a,b)` ever larger than the second moment allows?* An exhaustive kernel check
  (`hasse_F5`, `hasse_F7`, `hasse_F11`, `hasse_F13`) found no violation of `a² ≤ 4p`,
  consistent with Hasse; conversely `exists_frobTrace_sq_ge` shows some curve always has
  `a² ≥ q - 1`, and the tables above attain e.g. `a² = 9 ≥ 4` for `p = 5`.
