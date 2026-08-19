# Computational evidence

All computations below were run in double-precision floating point before the Lean
formalization, purely to select and sanity-check the statements that were then
proved.  Only the Lean files in `Catalog/Physics/` constitute verified results;
the numbers here are exploratory.

Notation: `e(x) = exp(2πix)`, `step a n = n/2` (`n` even), `a n + 1` (`n` odd),
`ratio_L(a,n) = step^L(n)/n`, and `F_L(a,ω,N) = Σ_{n≤N} e(ω · ratio_L(a,n))`.

## 1. The depth-two amplitude

Predicted model (proved in `CollatzTwoStepSpectrum.lean`):
`limitAmp2 a ω = (e(ω/4) + 3 e(aω/2))/4`.

| a | ω | \|F₂\|/N, N=10³ | \|F₂\|/N, N=10⁴ | model |
|---|---|---|---|---|
| 3 | 0.2 | 0.78860 | 0.79033 | 0.79057 |
| 3 | 1/3 | 0.54499 | 0.54759 | 0.54794 |
| 3 | 2/5 | 0.49834 | 0.49983 | 0.50000 |
| 5 | 1/3 | 0.79189 | 0.79077 | 0.79057 |
| 5 | 2/9 | 0.49945 | 0.49994 | 0.50000 |
| 7 | 2/13 | 0.49973 | 0.49997 | 0.50000 |

The one-step transform vanishes at the resonances (`a=3, ω=1/5`: `|F₁|/N = 0.00063`
at `N=10⁴`), while at the same parameters `|F₂|/N = 0.79`.  The minimum `1/2` of
the depth-two amplitude is attained exactly at `ω = 2/(2a-1)`, as the table shows
for `a = 3, 5, 7`.  Both facts are theorems: `norm_limitAmp2_ge_half`,
`norm_limitAmp2_eq_half`, `resonance_destroyed_by_iteration`.

## 2. Mean-square power versus iteration depth

Numerical average of `‖amplitude‖²` over `ω ∈ [0,40]` (200 000 sample points):

| a | depth 1 | depth 2 | depth 3 (model) |
|---|---------|---------|-----------------|
| 3 | 0.5000 | 0.6250 | 0.4687 |
| 5 | 0.5000 | 0.6250 | 0.4687 |
| 7 | 0.5000 | 0.6250 | 0.4687 |

Depth one and depth two are proved exactly (`1/2` and `5/8`, over the period
`[0,4]`).  The depth-three value matches `1/64 + 25/64 + 4/64 = 15/32`, i.e. the
sum of squared branch weights `(1/8, 5/8, 1/4)`; note that the power is **not**
monotone in the depth.  This is numerical only.

## 3. Depth-three branch weights (basis of Conjecture 1)

A Terras-style analysis modulo `8` predicts, for odd `a`, three limiting phases
`ω/8`, `aω/4`, `a²ω/2` with weights `1/8`, `5/8`, `1/4`.  Comparing the empirical
minimum of `|F₃|/N` at `N = 2·10⁴` over a grid of 400 frequencies with the minimum
of the predicted model:

| a | empirical min | model min |
|---|---------------|-----------|
| 3 | 0.2726 | 0.2728 |
| 5 | 0.2582 | 0.2580 |
| 7 | 0.2542 | 0.2540 |

The dominant weight `5/8 > 1/2` predicts a lower bound `5/8 - 3/8 = 1/4`, matched
by the data.  Formally verified: only the depth-one and depth-two cases.

## 4. The `b`-adic maps (`n ↦ n/b` if `b ∣ n`, else `a n + 1`)

Minimum of `|F(b,a=3,ω,N)|/N` over a grid of 2000 frequencies in `[0,10]`,
`N = 3000`:

| b | empirical min | proved lower bound `(b-2)/(2b)` |
|---|---------------|---------------------------------|
| 2 | 0.0019 | 0 (resonances exist) |
| 3 | 0.3152 | 0.1667 |
| 4 | 0.4793 | 0.2500 |
| 5 | 0.5773 | 0.3000 |

Base `2` is the only base whose empirical minimum drops to `0`; this is the
content of `halving_is_the_unique_resonant_base`.  The empirical minima are close
to `1 - 2/b`, twice the proved constant, suggesting the constant can be doubled
(Conjecture 3 in `FUTURE_DIRECTIONS.md`).

## 5. Counterexample hunt

* Pointwise decay of `F₁/N` over all irrational `ω`: refuted already in the
  previous cycle (`peak_near_zero`), and again visible here — `|F₁|/N → 1` as
  `ω → 0` for every map.
* Depth-two cancellation: searched `a ∈ {3,5,7}`, 2000 frequencies, `N` up to
  `10⁴`; the smallest observed value of `|F₂|/N` was `0.4867`, consistent with the
  proved bound `1/2` in the limit.  No counterexample.
* Monotonicity of mean-square power in the depth: **counterexample found**
  numerically at depth three (`15/32 < 1/2`); accordingly the proved theorem
  `meanSquare_strict_mono_in_depth` is stated only for depths one and two.

## 6. OEIS

The counting sequences that appear (`⌊N/4⌋`, `⌊N/b⌋`) are the elementary
quotient sequences (e.g. A002265 for `⌊N/4⌋`); no new integer sequence arose.
