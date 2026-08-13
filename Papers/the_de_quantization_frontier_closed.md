# Computational evidence — de-quantization frontier (Barrier IV)

All numbers below were produced by `#eval` inside Lean 4 (kernel-evaluated ℕ
arithmetic), before the corresponding theorems were formalised.  Every claim that
survives into the Lean files is proved there; the tables here are exploratory data
that guided the statements.

## 1. Orders and the order-finding split (`b = 2`)

`r = ord_N(2)`; the split column is `gcd(2^{r/2} - 1, N)` and `gcd(2^{r/2} + 1, N)`.

| `N`  | `r`  | `r` even | `gcd(2^{r/2}-1, N)` | `gcd(2^{r/2}+1, N)` | split? |
|------|------|----------|---------------------|---------------------|--------|
| 15   | 4    | yes      | 3                   | 5                   | yes    |
| 21   | 6    | yes      | 7                   | 3                   | yes    |
| 33   | 10   | yes      | 1                   | 33                  | **no** (`2^5 ≡ -1`) |
| 35   | 12   | yes      | 7                   | 5                   | yes    |
| 77   | 30   | yes      | 7                   | 11                  | yes    |
| 91   | 12   | yes      | 7                   | 13                  | yes    |
| 143  | 60   | yes      | 11                  | 13                  | yes    |
| 187  | 40   | yes      | 11                  | 17                  | yes    |
| 209  | 90   | yes      | 1                   | 209                 | **no** (`2^45 ≡ -1`) |
| 247  | 36   | yes      | 19                  | 13                  | yes    |

The two failures are exactly the case `b^{r/2} ≡ -1 (mod N)`.  This is why
`Dequant.order_finding_splits` carries the hypothesis
`¬ (N : ℤ) ∣ b^{r/2} + 1` and *nothing else*: the companion condition
`b^{r/2} ≢ 1` is not an assumption, it is derived from minimality of the order
(`Dequant.probe_false_below_order`).  Machine-checked instances `N = 15` and
`N = 21` appear as `Dequant.split_15_value` (`= 3`) and
`Dequant.split_21_value` (`= 7`).

Cross-check against OEIS **A002326** ("multiplicative order of 2 mod 2n+1"):
`a(7) = 4` for `2n+1 = 15` and `a(10) = 6` for `2n+1 = 21`, matching the computed
orders above.

## 2. Density of informative probes

Number of `t ∈ {1, …, 60}` for which the free probe `N ∣ 2^t - 1` fires:

| `N`  | `r`  | firing probes in `[1,60]` | predicted `⌊60/r⌋` |
|------|------|---------------------------|--------------------|
| 15   | 4    | 15                        | 15                 |
| 21   | 6    | 10                        | 10                 |
| 33   | 10   | 6                         | 6                  |
| 35   | 12   | 5                         | 5                  |
| 77   | 30   | 2                         | 2                  |
| 91   | 12   | 5                         | 5                  |
| 143  | 60   | 1                         | 1                  |

Perfect agreement in all 7 cases, i.e. the probe fires exactly on the multiples of
`r` — this is `Dequant.probe_iff_ord_dvd`.  The informative fraction is `1/r`:
a budget of `o(r)` consecutive probes returns the constant answer `false`
(`Dequant.probe_false_below_order`), which is the `Θ(r)`-sealed extraction.

## 3. Peak counts of the comb spectrum

`#{y < Q : (Q/r) ∣ y}` for `r ∣ Q`:

| `(Q, r)`  | peaks counted | `r` |
|-----------|---------------|-----|
| `(16, 4)` | 4             | 4   |
| `(16, 8)` | 8             | 8   |
| `(64, 8)` | 8             | 8   |
| `(64,16)` | 16            | 16  |
| `(12, 3)` | 3             | 3   |
| `(36, 9)` | 9             | 9   |

Counted peaks `=` `r` in all cases (`Dequant.card_peaks`), and the peak *sets*
`peaks 16 4 = {0,4,8,12}`, `peaks 12 3 = {0,4,8}` are machine-checked by `decide`
in `Frontier.lean`.

## 4. Counterexample hunt

* **Is `1 - k/r` the right sparse-approximation constant?**  Testing the uniform
  distribution on `k` of the `r` peaks gives total variation exactly `1 - k/r`
  (e.g. `r = 16, k = 4 → 0.75`).  No sparse distribution was found beating the
  bound, and indeed `Dequant.sparse_approx_lower_bound` proves none exists while
  `Dequant.sparse_approx_sharp` proves the value is attained.  So the constant is
  exact, not an artefact.
* **Are peak sets of different orders disjoint?**  No — every peak set contains the
  frequency `0`.  The naive "disjoint supports ⇒ `TV = 1`" argument is therefore
  *false*, and the formal statement `Dequant.peaks_disjoint_of_coprime` is about
  `peaks \ {0}` and needs coprimality (e.g. `Q = 48`, `r = 3` and `r = 16`:
  common peaks are multiples of `lcm(16,3) = 48`, i.e. only `0`; total variation
  `1 - 1/16 = 0.9375`).  This corner case is exactly why
  `Dequant.no_order_free_sampler` states the bound `1 - 1/R - 1/k` and not `1`.
  The exploratory value `0.9375` is now a theorem: `Dequant.tv_comb_comb` computes
  the distance exactly as `1 - gcd(r₁,r₂)/max(r₁,r₂)`, with the instance
  `Dequant.tv_48_3_16` machine-checked.
* **Does aliasing help?**  For `r ∤ Q` the visible peak count drops to
  `gcd(r, Q) ≤ r/2` (`Dequant.aliasing_halves_information`), so a mismatched grid
  loses information rather than gaining it; for `gcd(r,Q) = 1` only the trivial
  frequency survives.

## 5. What the evidence does *not* show

Nothing here is a complexity-theoretic separation.  The formal results are
unconditional statements about probes, spectra, ranks and total variation
distances; the reading "de-quantizing Shor = factoring" is the informal
interpretation of the two proved halves (`Dequant.sampled_frequency_yields_factor`
and `Dequant.dequantization_frontier_closed`), not a proved statement about
complexity classes.
