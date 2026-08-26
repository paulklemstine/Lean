# Computational Evidence — generator tilt and scan-order inversion

All numbers below were produced by **exhaustive enumeration inside Lean** (`#eval` over the
complete set of prime pairs at a given bit length), not by an external script.  They are
*exploratory* evidence: they motivated and cross-checked the theorems, but only the Lean
theorems in `Catalog/Novelty/GeneratorTilt*.lean` are machine-verified claims.

## 1. The model and the measured quantities

For a semiprime `N = p q` with `p ≤ q`, the canonical window is `[a, b]` with
`a = ⌈√(N/2)⌉`, `b = ⌊√N⌋`.  Costs are touch counts:

* window-ascending `asc = p - a + 1`,
* sqrt-descending `desc = b - p + 1`,
* tilt `z = (p - a)/(b - a)`, pool speedup `S = Σdesc / Σasc`.

The enumeration ran over **all** pairs of primes `p ≤ q` in `[2^(b-1), 2^b)`.

## 2. Same-bit-length ("RSA-style / deployed") pools

| bit length | pairs `n` | mean tilt `z̄` | `Σdesc/Σasc` | `in_win` |
|---|---|---|---|---|
| 8  | 276    | 0.667347 | 0.501214 | 1.000 |
| 9  | 946    | 0.644195 | 0.539918 | 1.000 |
| 10 | 2850   | 0.652260 | 0.525707 | 1.000 |
| 11 | 9453   | 0.644844 | 0.538387 | 1.000 |
| 12 | 32640  | 0.641729 | 0.544068 | 1.000 |

`in_win = 1.000` exactly: every pair is inside the window (all `n` equal the total number of
pairs, e.g. `32640 = 255·256/2` with `255` primes in `[2048, 4096)`).  This is now a theorem,
`GeneratorTilt.same_bitlength_in_window`.

**Comparison with the analytic value.**  Cycle 3 proves the exact mean tilt of the
independent same-bit-length model:

`(9 − 5√2)/3 = 0.642963…`  (`GeneratorTilt.mean_tilt_independent`)

The enumerated `z̄` at bit length 12 is `0.641729`, and the sequence
`0.6673, 0.6442, 0.6523, 0.6448, 0.6417` tracks it as the discretisation coarseness falls.
The tilt-only predictor `(1 − z̄)/z̄` at the analytic value is `0.55529…`; the enumerated
`Σdesc/Σasc` at bit length 12 is `0.5441` (the `O(1/L)` gap is bounded by
`GeneratorTilt.abs_speedup_sub_predictor_le`).

Every one of these pools is **top-heavy** (`z̄ > 1/2`) and **loses** under window-ascending
(`Σdesc/Σasc < 1`), the reported inversion.

## 3. Sign flip at the critical ratio `r★ = 24 − 16√2 ≈ 1.37258`

Restricting the bit-length-12 pool by prime ratio:

| ratio band | pairs `n` | mean tilt `z̄` | `Σdesc/Σasc` | winner |
|---|---|---|---|---|
| `q/p < 1.37250` | 23114 | 0.772244 | 0.291418 | sqrt-descending |
| `q/p > 1.37260` | 9524  | 0.325008 | 2.061582 | window-ascending |

The predicted tie point separates the two regimes cleanly, and both sides land on the
predicted side of `z̄ = 1/2`.  This is the empirical face of
`GeneratorTilt.half_lt_zOfRatio_iff`.

## 4. Control: ratio-uniform pools

A pool whose *ratio* is uniform on `[1,2]` (rather than obtained from two independent
same-bit-length draws) has mean tilt `√2 − 1 = 0.414214…`
(`GeneratorTilt.integral_zOfRatio`) and tilt-only speedup exactly `√2 = 1.41421…`
(`GeneratorTilt.predictor_at_uniform_balance`).  These match the reported hard-balance
control readings `z = 0.4114 [0.3887, 0.4341]` and `S = 1.5896 ± 0.0538` in sign and
approximate magnitude, and they are on the *opposite* side of `1/2` from every enumerated
prime pool above.

The general-window version, `mean tilt = 1/(1 + √R)` for ratio-uniform pools with window
multiplier `R` (`GeneratorTilt.mean_zGen_uniform`), is `< 1/2` for every `R > 1`.

## 5. Counterexample hunt

* Searched for a same-bit-length pool that is bottom-heavy: none exists at bit lengths 8–12
  (all `z̄ > 0.64`).  Consistent with the exact value `(9 − 5√2)/3 > 1/2`.
* Searched for a window multiplier `R` making near-balanced ratios bottom-heavy: impossible,
  since `r★(R) = 4R/(1+√R)² > 1` for every `R > 1`
  (`GeneratorTilt.one_lt_criticalRatioGen`), and `r★(R) < 4` always
  (`GeneratorTilt.criticalRatioGen_lt_four`).
* Off-window semiprimes exist as soon as balance is not enforced (`21 = 3·7`), formalised as
  `GeneratorTilt.exists_semiprime_outside_window`.

## 6. Sequences

No integer sequence arises here (the objects are real constants:
`√2 − 1`, `24 − 16√2`, `(9 − 5√2)/3`, `4R/(1+√R)²`, `1/(1+√R)`), so no OEIS lookup applies.
