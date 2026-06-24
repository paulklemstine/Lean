# Computational Evidence — Uniform Witness Bound `W(d,s,n)`

All numbers below were produced by `#eval` in Lean (so they use Mathlib's exact
`Nat.choose`), with

```
W d s n = C(n-1, d) + (if d+2 ≤ 2s then C(n - 2(d+1-s) - 2, 2s - d - 2) else 0)
```

## 1. The `s = 0` slice equals `C(n-1, d)` (the EKR value)

`W(2,0,n)` for `n = 6, 8, 10`:

| n | W(2,0,n) | C(n-1,2) |
|---|----------|----------|
| 6 | 10 | 10 |
| 8 | 21 | 21 |
| 10 | 36 | 36 |

So `W(d,0,n) = C(n-1,d)` exactly — this is the value the formal theorem
`card_le_W_zero`/`isGreatest_card_W_zero` proves to be the *maximum* family size.
Checked also at the EKR threshold `n = 2(d+1)`:

`(W(d,0,2(d+1)), C(2d+1,d))` for `d = 2..6`:
`[(10,10), (35,35), (126,126), (462,462), (1716,1716)]` — all equal (central-ish binomials).

## 2. Where the second term switches on

`W(4, s, 12)` for `s = 0,1,2,3,4,5`:

```
[330, 330, 330, 331, 358, 540]
```

- `s = 0,1,2`: value is `330 = C(11,4)`; the indicator `d+2 ≤ 2s` is **false**
  (`6 ≤ 2s` needs `s ≥ 3`), so `W = C(11,4)`. This matches `W_small` (regime `2s ≤ d+1`).
- `s = 3`: `2s = 6 = d+2`, the second term `C(12-2(4+1-3)-2, 6-4-2) = C(6,0) = 1`
  switches on: `330 + 1 = 331`.
- `s = 4`: `C(12-2(4+1-4)-2, 8-4-2) = C(8,2) = 28`, giving `330 + 28 = 358`.

This is the **boundary** the analysis isolates: `s = 0` (indeed all `s ≤ ⌊(d+1)/2⌋`)
is the tractable EKR regime; the genuinely hard / partially-false regime begins exactly
when the second binomial term becomes defined, i.e. `2s ≥ d+2`.

## 3. Counterexample hunt for the `s = 0` claim

Goal: find a `(d+1)`-uniform family with the size-`0` missing-trace property and
`|ℱ| > C(n-1,d)`. None exists — this is precisely the Erdős–Ko–Rado theorem, formalized
here via `Finset.erdos_ko_rado`. The reduction `hasMissingTraceOfSize_zero_iff`
(missing-trace-`0` ⇔ intersecting) is what closes the search: any candidate
counterexample would be an intersecting `(d+1)`-uniform family exceeding `C(n-1,d)`,
contradicting EKR for `n ≥ 2(d+1)`.

The star family `{F : |F| = d+1, a ∈ F}` *attains* `C(n-1,d)`
(`starFamily_card`), so the bound is sharp and the threshold in §2 is exact.

## 4. OEIS

The diagonal `W(d,0,2(d+1)) = C(2d+1,d)` for `d = 2,3,4,5,6` is
`10, 35, 126, 462, 1716`, the odd-indexed central binomial coefficients
(OEIS A001700, `C(2n+1,n)`).
