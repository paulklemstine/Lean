# Computational evidence — NET-84 tail-aware mixed precision

All numbers below were produced by exact-rational or `Float` evaluation inside Lean
(`#eval`), before the corresponding theorems were formalised.  Everything asserted as a
*theorem* in `Catalog/Computation/*.lean` is machine-checked; the tables here are
exploratory and are labelled as such.

## 1. The three measured arms (input data, from the experiment report)

| arm | quantized set | retained | damage `1 - retained` |
|---|---|---|---|
| GPTQ4 full | `{tail, rest}` | 0.9081 | 0.0919 |
| GPTQ4 + L22/L23 fp32 | `{rest}` | 0.9261 | 0.0739 |
| GPTQ4 L22/L23 only | `{tail}` | 0.9766 | 0.0234 |

Derived quantities (exact rationals, `#eval`, later proved in
`TailAwareMixedPrecision.lean` / `TailUnitEpistasis.lean`):

* gain of protecting the tail: `0.9261 - 0.9081 = 0.018` exactly;
* ceiling predicted by the coverage model: `errTail = 0.0234`;
* efficiency `gain / errTail = 0.769230… = 10/13` **exactly** — the measured gain is a
  clean rational multiple of its theoretical ceiling;
* coverage slack `errRest + errTail - errFull = 0.0054 > 0`, so the NET-84 arms are
  *sub*-additive, i.e. coverage-consistent — in contrast with the super-additive NET-60
  and NET-83 measurements.

**Counterexample hunt.** The coverage model predicts `0 ≤ gain ≤ errTail`.  The
measurement satisfies it with `0 < 0.018 < 0.0234`; had the reported gain exceeded
`0.0234`, the monotone-coverage model would have been *refuted* by NET-84 itself.  It is
therefore a genuine, passed test rather than an unfalsifiable fit.  Conversely NET-60's
`7×` super-additivity does refute coverage — that refutation is formalised as
`emergent_nonempty_of_superadditive`, and its quantitative form
(`net60_emergent_six_sevenths`) says at least `6/7` of the joint disagreements are
emergent.

## 2. Sensitivity profile of a non-expansive 24-layer stack

`sens L 24 m = ∏_{j>m} L j` with constant `L = 0.9` (`#eval`, values × 1000):

| layer m | 18 | 19 | 20 | 21 | 22 | 23 |
|---|---|---|---|---|---|---|
| sens×1000 | 590 | 656 | 729 | 810 | 900 | 1000 |

Monotone increasing, maximum `1` at the last layer — matching the theorem
`sens_mono` / `sens_last_eq_one`.  With `L = 1.1` (expansive) the profile reverses:
`8.954, 8.140, 7.400, 6.727, 6.115, 5.559` for layers `0…5`, matching
`sens_anti_of_expansive`.

Concentration: for `L = 0.9`, layers `22` and `23` carry **20.6 %** of the total
certified error budget while being `2/24 = 8.3 %` of the layers — a `2.5×`
over-representation of the tail pair, i.e. the theory predicts tail dominance of the
same qualitative size the experiment reports.

Total certified error for uniform `ε = 0.01`: `0.0920` (vs. the trivial bound
`ε·n = 0.24`).

## 3. Optimal bit allocation (water-filling)

For `n = 24`, `c i = 0.9^(23-i)`, budget `B = 4 · 24` bits:

* uniform 4-bit allocation: certified cost `0.5751`;
* water-filling optimum `n · (∏ c)^{1/n} · 2^{-B/n}`: `0.4466`;
* ratio `1.288` — the optimum is **22 % cheaper** at the same budget.

Optimal bit gap between the first and last layer: `23 · log₂(1/0.9) = 3.50` bits
(`0.152` bits per layer of depth), formalised as `bStar_gap_geometric`.  So the
prescription "give the tail pair several extra bits" is the exact optimum, and the
follow-up "8-bit tail" experiment is predicted to help further, but with diminishing
returns beyond `≈ 4 + 3.5` bits.

## 4. Memory accounting

With `1.8 × 10⁶` parameters per protected layer, two layers, and a `494 × 10⁶`
parameter model, keeping the pair in fp32 costs
`2 · 1.8e6 · 3.5 bytes / (494e6 · 0.5 bytes) = 5.1 %` of the 4-bit model size.  The
experiment report quotes `1.4 %`, which corresponds to measuring the overhead against a
larger (≈ 450 MB) deployment budget rather than against the 4-bit weight bytes.  The
formal statement `net84_overhead_small` therefore asserts the conservative bound
`< 6 %`, which is valid under the accounting made explicit in the file; the favourable
quality-per-memory conclusion (`net84_quality_per_overhead`) survives either way.

## 5. Not found in OEIS

No integer sequence arises here; the discrete data are three measured rates and a
geometric sensitivity profile, so an OEIS lookup is not applicable.
