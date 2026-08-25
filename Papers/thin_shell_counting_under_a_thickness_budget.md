# Computational evidence: thin shells under a thickness budget

All computations use the catalog's peeling radii
`shellRadius R d N k = R (1 - k/N)^{1/d}` (radius `R = 1` throughout), shell thickness
`t_k = shellRadius k - shellRadius (k+1)`, and

```
thick(R, d, N, δ) = #{ k < N : t_k > δ }.
```

They were run in Lean with `Float` arithmetic (`#eval`). They are *exploratory*: every claim
below that is asserted as a theorem has a separate, machine-checked, `sorry`-free Lean proof in
`Catalog/Cryptography/ShellThicknessBudget*.lean`. The floating-point tables themselves are not
verified computations.

## 1. Small cases

`δ = 0.02`, `N = 100`: `thick = 0` for `d = 1`, `6` for `d = 2`, `6` for `d = 5`, `4` for
`d = 10`. (For `d = 1` every shell has thickness exactly `1/N = 0.01 < δ`.)

`d = 2`, `δ = 0.01`, varying `N`:

| N       | 10 | 25 | 49 | 50 | 51 | 60 | 100 | 200 | 400 | 1000 |
|---------|----|----|----|----|----|----|-----|-----|-----|------|
| thick   | 10 | 25 | 49 | 50 | 49 | 42 | 25  | 13  | 6   | 3    |

The count first equals `N` (every shell is thick), peaks at `N ≈ R/(2dδ) = 25`…`50`, and then
decays. The peak value `50` equals `R/(dδ) = 100/2`.

`N = 1000`, `δ = 0.01`, varying `d`: `d = 1 ↦ 0`, `2 ↦ 3`, `3 ↦ 6`, `5 ↦ 8`, `10 ↦ 6`,
`20 ↦ 4`, `50 ↦ 2`.

## 2. The supremum over `N` — the quantity the conjecture is about

`max_{1 ≤ N ≤ M} thick(1, d, N, 0.01)`:

| d  | M    | max | `R/(dδ)` | conjectured `d·log(R/δ)` |
|----|------|-----|----------|---------------------------|
| 2  | 400  | 50  | 50       | 9.2                       |
| 5  | 400  | 20  | 20       | 23.0                      |
| 10 | 2000 | 10  | 10       | 46.1                      |

The measured maximum is exactly `R/(dδ)`; it **decreases** in `d`, whereas the conjectured
bound `O(d log(R/δ))` increases in `d`. This is the numerical shape of the refutation
(`thickCount_not_bigO_dim_log`) and of the matching bounds
`thickCount_le` (`≤ 1 + R/(dδ)`) and `thickCount_max_ge` (`≥ R/(2dδ) - 1`).

## 3. Counterexample hunt for the conjectured `O(d log(R/δ))` bound

Family used in the Lean refutation: `R = 1`, fixed `d`, `N` arbitrary, `δ = 1/(2dN)`. Then every
shell is thick (each has thickness `≥ R/(dN) = 2δ`), so `thick = N`, while
`d log(R/δ) = d log(2dN)`. E.g. `d = 2`, `N = 10^4`: count `10^4` versus `d log(R/δ) ≈ 21`.
No constant `C` can absorb this, for any fixed `d`.

## 4. The thin-shell threshold

Smallest `N` with `thick = 0`:

| d | δ    | measured | `(R/δ)^d` |
|---|------|----------|-----------|
| 3 | 0.25 | 64       | 64        |
| 4 | 0.5  | 16       | 16        |
| 5 | 0.5  | 32       | 32        |

Exactly `⌈(R/δ)^d⌉`, matching `all_thin_iff_card` / `least_thin_N`. Note `(1-δ/R)^{-d}` would
predict `(4/3)^3 ≈ 2.4` in the first row: wrong by a factor `27`. The two agree only at
`δ = R/2`.

## 5. Contiguity of the thick block

For every `N ≤ 300` with `d = 3`, `δ = 0.02`, the set `{k : t_k > δ}` is exactly a terminal
interval `[N - thick, N)` (checked exhaustively, `true`). Examples: `d = 2, δ = 0.01`,
`N = 100` gives thick set `[75, 100)`; `N = 200` gives `[187, 200)`; `d = 5, N = 1000,
δ = 0.01` gives `[992, 1000)`. This is proved in `exists_thick_threshold`.

## 6. The decay inequality `(m-1)^{d-1} N ≤ (R/(dδ))^d`

Checked (floating point, with a `10^{-6}` relative slack) for all `d ∈ {1,2,3,4,5,7,10}`,
`N ≤ 200`, `δ ∈ {0.005, 0.01, 0.03, 0.1, 0.3}`, `R = 1`: no violation. Tightness for `d = 2`,
`δ = 0.01` (right-hand side `2500`):

| N            | 50   | 100  | 200  | 400  | 1000 |
|--------------|------|------|------|------|------|
| m            | 50   | 25   | 13   | 6    | 3    |
| `(m-1)·N`    | 2450 | 2400 | 2400 | 2000 | 2000 |

The proved theorem is `peeling_thick_decay`.

## 7. Two-sided pinning `thickCount ∈ {j, j+1}`

With `j(d,N,δ) = max{j : j^{d-1} N < (R/(dδ))^d}` (the index supplied by `peeling_thick_lower`)
and `m` the true count, at `R = 1`:

| `d` | `N`  | `δ`   | `m` | `j` |
|-----|------|-------|-----|-----|
| 2   | 10   | 0.05  | 10  | 9   |
| 2   | 50   | 0.05  | 2   | 1   |
| 3   | 20   | 0.05  | 4   | 3   |
| 3   | 100  | 0.02  | 7   | 6   |
| 4   | 50   | 0.02  | 8   | 7   |
| 5   | 200  | 0.01  | 11  | 11  |

In every sample `m ∈ {j, j+1}`, as `thickCount_pinned` asserts, and both values of the pair do
occur — the residual `±1` in the formalised statement is therefore not removable without a
tie-break rule.

## 8. Bit cost of the thin threshold

With `M(d) = max(1, ⌈(R/δ)^d⌉)` the least admissible number of shells:

| `R/δ` | `d` | `M`  | `log M`  | `d log(R/δ)` | gap    |
|-------|-----|------|----------|--------------|--------|
| 8     | 1   | 8    | 2.079442 | 2.079442     | 0      |
| 8     | 2   | 64   | 4.158883 | 4.158883     | 0      |
| 8     | 3   | 512  | 6.238325 | 6.238325     | 0      |
| 1.5   | 1   | 2    | 0.693147 | 0.405465     | 0.2877 |
| 1.5   | 2   | 3    | 1.098612 | 0.810930     | 0.2877 |
| 1.5   | 3   | 4    | 1.386294 | 1.216395     | 0.1699 |
| 1.5   | 4   | 6    | 1.791759 | 1.621860     | 0.1699 |

The gap is `0` when `(R/δ)^d` is an integer and never exceeds `log 2 ≈ 0.693`, as proved in
`thin_threshold_log_bounds` / `thin_threshold_bitcost`.

## 9. OEIS

The integer sequences appearing here (`⌈(R/δ)^d⌉` for fixed `δ`, e.g. `4, 16, 64, 256, …`) are
plain geometric progressions; no OEIS lookup is informative.
