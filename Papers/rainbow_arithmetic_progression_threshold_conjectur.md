# Computational Evidence — rainbow pair-spectrum threshold `T_k`

## 0. What is being measured

For `k` colours put `N = k²` (the number of *ordered colour pairs*, i.e. the number of possible
colourings of a 2-term arithmetic progression).  A word `f : Fin m → Fin k × Fin k` records the
colour pattern of each of `m` consecutive 2-term progressions of a `k`-colouring; the word has
*full pair spectrum* iff it is surjective.  Define

```
T_k = least m such that a strict majority of the N^m words of length m has full pair spectrum.
```

This is the `Fin k × Fin k` case of `RainbowAP.spectrumThreshold`.

## 1. Exact small-case values (inclusion–exclusion, exploratory computation)

The exact number of surjective words is `Surj(m,N) = Σ_{i=0}^{N} (-1)^i C(N,i) (N-i)^m`; `T_k` is
the least `m` with `2·Surj(m,N) > N^m`.  The table below was produced by exact integer arithmetic
outside Lean, so it is **exploratory evidence, not a verified computation** — except for the three
windows marked ✔, which are Lean theorems (`RainbowAP.T_two_window`, `T_three_window`,
`T_four_window`).

| k  | N = k² | exact `T_k` | proved lower bound `(N-1)log(N+1)` | proved upper bound `N log(2N)+1` | `T_k / (k² ln k)` |
|----|--------|-------------|------------------------------------|----------------------------------|-------------------|
| 2  | 4      | 7  (✔ window [6, 8])   | 4.83   | 9.32   | 2.5247 |
| 3  | 9      | 23 (✔ window [20, 25]) | 18.42  | 27.01  | 2.3262 |
| 4  | 16     | 51 (✔ window [44, 54]) | 42.50  | 56.45  | 2.2993 |
| 5  | 25     | 90                     | 78.19  | 98.80  | 2.2368 |
| 6  | 36     | 142                    | 126.38 | 154.96 | 2.2014 |
| 7  | 49     | 209                    | 187.78 | 225.66 | 2.1919 |
| 8  | 64     | 290                    | 262.99 | 311.53 | 2.1791 |
| 9  | 81     | 386                    | 352.54 | 413.10 | 2.1688 |
| 10 | 100    | 497                    | 456.90 | 530.83 | 2.1584 |
| 11 | 121    | 625                    | 576.48 | 665.16 | 2.1541 |
| 12 | 144    | 768                    | 711.67 | 816.47 | 2.1463 |

**Every exact value lies strictly inside the interval proved in
`Catalog/Shared/RainbowAPSpectrumAsymptotics.lean`.**  No counterexample to the two-sided bound was
found in the range `2 ≤ k ≤ 12`.

## 2. Convergence of the normalised threshold

The last column decreases monotonically towards `2`, in agreement with the Lean theorem
`RainbowAP.T_tendsto_two` (`T_k / (k² log k) → 2`).  The observed deviations fit

```
T_k / (k² ln k) ≈ 2 + 0.3665 / ln k ,
```

for instance at `k = 12`: `2 + 0.3665/2.4849 = 2.1475` versus the exact `2.1463`.  The constant
`0.3665 ≈ ln(1/ln 2)` is exactly the second-order coupon-collector constant coming from the
median of the collection time (`N e^{-m/N} = ln 2`).  This is *strictly inside* the proved window
`[-(log N + 1), N log 2 + 1]` of `RainbowAP.spectrumThreshold_window` (note `0.3665 < log 2 =
0.6931`), so the verified bounds are consistent with — and one additive `O(N)` step away from —
the conjectural second-order term recorded in `FUTURE_DIRECTIONS.md`.

## 3. Counterexample hunt

* Two-sided bound `(N-1)log(N+1) ≤ T ≤ N log(2N) + 1`: tested for all `N = k²`, `2 ≤ k ≤ 12`; no
  violation.  (The bound is a theorem, so this is only a sanity check of the formalisation.)
* Monotonicity of the transition (`majority_iff_threshold_le`): the exact sequence
  `2·Surj(m,N)/N^m` was checked to be increasing in `m` for all tested `N`; consistent with the
  proved extension injection `N·Surj(m) ≤ Surj(m+1)`.
* Optimality of the constants: the claim "`c₁ = c₂ = 2` are the optimal constants" is not
  contradicted by any data point; the ratio is above `2` for all computed `k`, matching the
  proved lower-order positive correction.

## 4. OEIS

The exact sequence `T_k` for `k = 2, 3, 4, …` begins `7, 23, 51, 90, 142, 209, 290, 386, 497`.
A search of the first terms of this specific normalisation returned no matching OEIS entry; the
closely related coupon-collector median sequence for `N` coupons is classical but is indexed by
`N`, not by `k = √N`.  (Reported as a negative search result, not as a verified claim.)
