# Computational Evidence — H0 window geometry of `j² − N` (exp 581 / paper 231)

This note records the small-scale numerical exploration that preceded the Lean
formalisation in `Catalog/Algebra/HumpWindowGeometry.lean`,
`Catalog/Algebra/HumpFittedCurvature.lean` and
`Catalog/Algebra/HumpBinInvariance.lean`.

**Status of the numbers below: exploratory, not machine-verified.**  They were
produced by ordinary floating-point arithmetic while choosing which statements
to formalise.  Every claim that this project *asserts* is instead the Lean
statement named beside it, proved with `0` sorries and only the standard axioms
`propext, Classical.choice, Quot.sound`.

## 1. The object

With `r = √N`, `j = r + s`, window length `M`, relative position `x = s/M` and
aspect ratio `c = r/M`,

```
j² − N = s(s + 2r) = M² · x (x + 2c),      log-size = log x + log(x + 2c) + 2 log M.
```

The measured profile `R = T/M` is read against an affine reference in the
`j`-grid, so its interior deviation is the *chord gap* of the log-size profile.

## 2. Where the geometry puts the vertex

The chord-gap vertex `ξ` on a window `[a, b]` solves `1/ξ + 1/(ξ + 2c) = S`,
where `S` is the chord slope.  Solving numerically by bisection, with `b = 1`,
and reporting the **relative** vertex `(ξ − a)/(b − a)`:

| `a`     | `c = 0` | `c = 10` | `c = 10³` | `c = 10⁹` | log-mean rel. pos. | bound `1/log(b/a)` |
|---------|---------|----------|-----------|-----------|--------------------|--------------------|
| `0.5`   | 0.4427  | 0.4428   | 0.4427    | 0.4427    | 0.4427             | 1.4427             |
| `0.2`   | 0.3713  | 0.3714   | 0.3713    | 0.3713    | 0.3713             | 0.6213             |
| `0.1`   | 0.3232  | 0.3232   | 0.3232    | 0.3232    | 0.3232             | 0.4343             |
| `0.01`  | 0.2070  | 0.2071   | 0.2070    | 0.2070    | 0.2070             | 0.2171             |
| `10⁻³`  | 0.1438  | 0.1438   | 0.1438    | 0.1438    | 0.1438             | 0.1448             |
| `10⁻⁶`  | 0.0724  | 0.0724   | 0.0724    | 0.0724    | 0.0724             | 0.0724             |

Three observations, and what became of each:

1. **Every entry is `< 1/2`.**  Formalised, in full generality, as
   `HumpWindowGeometry.vertex_lt_midpoint` / `normalized_vertex_lt_half`.
   The measured pooled vertex is `0.5901` (independently `0.5896` in exp 579),
   *right* of centre; `HumpWindowGeometry.measured_vertex_not_from_window_geometry`
   is the resulting impossibility statement.
2. **The aspect ratio `c` is almost irrelevant** — the columns agree to four
   digits.  At `c = 0` the vertex *is* the logarithmic mean
   (`HumpWindowGeometry.vertex_c_zero`).  For general `c` this was subsequently
   formalised as a two-sided pin, `LM(a,b) ≤ ξ ≤ LM(a+2c,b+2c) − 2c`
   (`HumpVertexRigidity.vertex_mem_Icc`), whose lower end does not depend on `c`
   at all (`HumpVertexRigidity.vertex_indep_of_aspect`).  Note the table
   corrects the naive guess: the vertex sits *above* the logarithmic mean, not
   below it.
3. **The vertex collapses onto the left edge as the window widens**, tracking
   `1/log(b/a)`.  Formalised at `c = 0` as
   `HumpWindowGeometry.normalized_logMean_le_inv_log`.  In the sieve regime
   `a = 1/M`, `b = 1` this reads: relative vertex `≤ 1/log M`, e.g. `≈ 0.072`
   for `M = 10⁶`.  So the geometric channel does not merely fail to reach
   `0.5901`; it runs the other way.

## 3. Counterexample hunt against the conjecture "vertex ≥ 1/2"

The conjecture that the geometry could place the vertex at or right of centre
was tested over `a ∈ {10⁻⁹ … 0.999}`, `c ∈ {0, 10⁻³, 1, 10, 10³, 10⁶, 10⁹}`.
No instance reached `0.5`; the supremum of the relative vertex is approached as
`b/a → 1` and appears to be `1/2`, never attained.  This matched the proof
route via the strict inequality `2(t−1)/(t+1) < log t`
(`HumpWindowGeometry.log_gt_two_mul_sub_div`), which is exactly the statement
"logarithmic mean `<` arithmetic mean" and is the analytic engine of the
obstruction.

## 4. Sanity checks on the fitted-curvature statistic

The experiment reports `c = −0.105 … −0.44` in every stratum.  Fitting a
quadratic by least squares to `log x + log(x + 2c)` sampled on `64` equal bins
inside a window reproduces a negative coefficient at every bin width and offset
tried (`w ∈ {1,2,4,8,16}`, several offsets).  Rather than tabulate those runs,
the general fact was formalised:

* `HumpFittedCurvature.sum_profile_mul_quadratic_nonpos` — a negative fitted
  coefficient is a certificate of concavity for *any* concave profile and *any*
  grid-orthogonal quadratic;
* `HumpFittedCurvature.window_fitCurvature_statistic_neg` — for the `j² − N`
  profile the statistic is strictly negative at **every** bin count `n ≥ 3`,
  bin width `h > 0` and grid centre `m`;
* `HumpFittedCurvature.affine_profile_sum_eq_zero` and
  `HumpBinInvariance.affine_binAvg_second_difference_eq_zero` — the matching
  control: an affine profile fits with curvature exactly `0`.

## 5. What the evidence does *not* show

Nothing here reproduces the experiment's pipeline, its seeds, its hashes or its
`9594` hits; no such data is present in this repository, and no claim about them
is made.  The formal results are statements about the geometry of the
polynomial `j² − N` on an interval, which is the object the surviving channel
`H0` names.
