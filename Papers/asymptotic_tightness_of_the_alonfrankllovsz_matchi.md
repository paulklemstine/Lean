# Computational Evidence — AFL Monochromatic Matching Bound

This note records the small-case evidence that shaped the formalization in
`Basic.lean`, `Bounds.lean`, and `Examples.lean`.  All *claims used as theorems*
are machine-checked in Lean; the tables below are orientation only.

## 1. The two competing fractions

* **AFL target** (asymptotic, for the complete/pseudorandom host): a monochromatic
  matching of size `(1/(r+t-1) - o(1))·n`.
* **Greedy / bounded-degree bound** (proved here, any host): a monochromatic matching of
  size `≥ #H / (r·t·Δ)`, which for a `d`-regular-like `t`-graph is `≈ n/(r·t)`.

The denominators satisfy `r+t-1 ≤ r·t` with slack exactly `(r-1)(t-1)`
(`afl_constant_gap`, `afl_constant_gap_strict`):

| r | t | r+t-1 (AFL) | r·t (greedy) | slack (r-1)(t-1) |
|---|---|-------------|--------------|------------------|
| 2 | 2 | 3           | 4            | 1                |
| 2 | 3 | 4           | 6            | 2                |
| 3 | 2 | 4           | 6            | 2                |
| 3 | 3 | 5           | 9            | 4                |
| 2 | 4 | 5           | 8            | 3                |

So the greedy route is provably correct but never tight for `r,t ≥ 2`: recovering
`1/(r+t-1)` is a strictly global phenomenon.

## 2. Worked host: complete graph `K_n` (`t = 2`)

For `K_n`: `#H = n(n-1)/2`, `Δ = n-1`.  With `r = 2`:

`#H / (r·t·Δ) = [n(n-1)/2] / (2·2·(n-1)) = n/8`.

AFL predicts `n/(r+t-1) = n/3`.  Ratio `(n/3)/(n/8) = 8/3 ≈ 2.67`, i.e. the greedy bound
loses the constant factor `r·t/(r+t-1) = 4/3`... times the additional `Δ`-vs-`tΔ` counting
loss.  The qualitative `Θ(n)` growth is captured; the optimal constant is not.

## 3. Counterexample hunt: is the clean fraction exact for finite `n`?

**No.**  Smallest interesting instance `n = 4, r = t = 2`.  Edges of `K₄` split into the
three perfect matchings `{12,34}, {13,24}, {14,23}`.  Colour each edge by whether it
contains vertex `1`:

* colour 0 (star at 1): `12, 13, 14` — pairwise intersecting ⟹ max matching `1`.
* colour 1 (triangle on `{2,3,4}`): `23, 24, 34` — pairwise intersecting ⟹ max matching `1`.

So **every monochromatic matching has size `1`**, while `n/(r+t-1) = 4/3 > 1`.  The clean
fraction is violated on a finite host; the `-o(1)` term is necessary.

This is verified in Lean: `AFLMatching.K4_no_mono_matching_two` (brute force over all
sub-collections of `K₄`'s edges via `decide`, wrapped through the project's `IsMatching`).

Meanwhile the general lower bound `mono_matching_nonempty` forces a *nonempty*
monochromatic matching here (since `K₄` has edges), so the true value is exactly `1` —
upper bound from the witness, lower bound `≥ 1` from the library.

## 4. OEIS

No new integer sequence is introduced; the quantities (`r+t-1`, `r·t`, `(r-1)(t-1)`) are
elementary polynomial expressions, so an OEIS lookup is not informative here.

## 5. Takeaways feeding `FUTURE_DIRECTIONS.md`

1. Bounded degree alone gives the right *order* `Θ(n/(rt))` but the *wrong constant*.
2. The gap `(r-1)(t-1)` is the precise price of ignoring global (LP/strip) structure.
3. The AFL constant is asymptotic by necessity: finite hosts dip below `n/(r+t-1)`.
