# Computational evidence — U35-LOCALIZED (exp 500, assessment v276)

All numbers below were computed in exact rational arithmetic before formalization, and every
one of them is re-derived inside the Lean files (`Catalog/Novelty/U35*.lean`), where it is a
theorem rather than a computation.  Nothing in this note is load-bearing for the formal
results; it records how the constants were chosen.

## 1. Recorded inputs

```
n                       = 14 seeds (20260950-63)
sp(3.5) mean            = 0.6282        sample sd = 0.0155     s.e. = 0.0041
bootstrap CI            = [0.6204, 0.6363]
sub-floor seeds         = 0 / 14        band floor = 0.60
Delta = sp(2.5)-sp(3.5) = 0.1057        CI [0.0999, 0.1112]    14/14 positive
```

## 2. Dispersion budgets

| quantity | value |
|---|---|
| margin to the floor `m − c` | `0.0282` |
| squared margin | `0.00079524` |
| sp-column budget `13 · 0.0155²` | `0.00312325` |
| paired budget `13 · 0.0110²` | `0.00157300` |
| Chebyshev ratio `0.00312325 / 0.00079524` | `3.9275…` → cap **3** |

The paired sd `0.0110` is read off the recorded paired CI: half-width
`(0.1112 − 0.0999)/2 = 0.00565`, so s.e. `≈ 0.00291` and sd `≈ 0.0109`; `0.0110` is used as a
conservative upper bound and appears as an explicit hypothesis in every theorem that uses it.

## 3. Sub-floor count: search for the extremal population

Two-point populations with `k` seeds at `0.5999` and `14 − k` seeds at the balancing value,
mean pinned to `0.6282`:

| k | high value | sample sd | inside budget? |
|---|---|---|---|
| 1 | `0.6303769…` | `0.008145` | yes |
| 2 | `0.6329167…` | `0.011990` | yes |
| 3 | `0.6359182…` | `0.015337` | **yes (extremal)** |
| 4 | `0.63952`    | `0.018574` | no |

So the Chebyshev cap `3` is attained and `4` is impossible — the cap is sharp.  The `k = 3`
population is `Catalog.Novelty.U35SubfloorCap.witness`; its exact squared-deviation sum is
`1681869/550000000 = 0.00305794… < 0.00312325`.

## 4. Depth ladder

Single-seed bound: `√0.00312325 = 0.0558861…`, so every seed exceeds `0.6282 − 0.0559 =
0.5723`.  Trade-off `k·δ² ≤ 0.00312325`:

| depth `δ` | max count | witness |
|---|---|---|
| `0.0282` (floor) | 3 | `witness` above |
| `0.0400` | 1 | `witnessDepth`: one seed at `0.5882`, thirteen at `41033/65000`, SS `= 14/8125` |
| `0.0559` | 0 | — (impossible) |

Paired analogue: `√0.001573 = 0.0396611…`, so every drop lies in `(0.0660, 0.1454)`.

## 5. Randomization tail

Sign vectors ↔ subsets: `signedSum d s = ∑d − 2·∑_{flipped} d`.  With every drop `≥ 0.066`, a
haircut of `2t = 0.26` (`t = 0.13 < 2·0.066`) admits only subsets of size `≤ 1`:

```
count <= C(14,0) + C(14,1) = 15      p <= 15/16384 = 0.000915... < 1e-3
exact (t = 0) count = 1              p = 1/16384 = 6.1035e-5
spectral gap at the top = 2 * 0.066 = 0.132 = 8.92 % of the total drop 1.4798
```

## 6. Crossing forecast

Affine model anchored at `u = 3.5`:

```
point estimate  u* = 3.5 + 0.0282/0.1057 = 3.76679...
CI box          [3.5 + 0.0204/0.1112, 3.5 + 0.0363/0.0999] = [3.6835, 3.8634]
```

so the forecast window `3.68 < u* < 3.87` is what gets formalized: `u = 3.5` safe, `u = 4.0`
breached, for the whole CI box.

## 7. Standard-error consistency

`0.0155/√14 = 0.00414254…` versus the published `0.0041` — a discrepancy of `4.3 · 10⁻⁵`.  The
CI half-width `0.00795` is `1.919` standard errors.  Both are formalized (the first with an
explicit bracket `3.7416 < √14 < 3.7417`).

## 8. Counterexample hunt

The hypotheses actively searched for and *found*:

* a population with the recorded mean, **smaller** sd than recorded, and 3 sub-floor seeds
  (section 3) — this refutes the tempting claim that the published summary already implies
  `0/14`;
* a population with one seed `0.04` below the mean inside the budget (section 4) — this
  refutes "no seed can be more than the margin below the mean".

The hypotheses searched for and *not* found (and then proved impossible): 4 sub-floor seeds
inside the budget; any seed below `0.5723`; any drop outside `(0.066, 0.1454)`.

No OEIS sequence is involved: the only integer sequence appearing is the binomial tail
`C(14,0), C(14,1), …` used for the robustified randomization p-value.
