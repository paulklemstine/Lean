# Computational Evidence — finite-sample breakdown of the median

All numbers below were produced by `#eval` inside the Lean project itself
(`Catalog/Computation/MedianBreakdown*.lean`), so the "evidence" and the
formalisation share a single definition of every object.  Everything that is
asserted as a *theorem* is proved without `sorry`, `native_decide`, or extra
axioms (`propext`, `Classical.choice`, `Quot.sound` only).

## 1. The measured data

Each measurement is a triple of raw channel counts `(a, b, c)`; the recorded
statistic is the normalised first coordinate `a / (a + b + c)`.  All 16 triples
of the first run and all 8 of the second sum to 100, so the ratios are `a/100`.

```
triples16 first coordinates : 37 35 38 36 34 39 33 40 36 37 35 38 34 39 41 32
sorted                       : 32 33 34 34 35 35 36 36 37 37 38 38 39 39 40 41
                                                    ^^ ^^  (8th and 9th)

triples8  first coordinates : 37 35 38 36 34 39 33 40
sorted                       : 33 34 35 36 37 38 39 40
                                       ^^ ^^  (4th and 5th)
```

Evaluated in Lean:

```
#eval (ratios16.length, ratios8.length)                    -- (16, 8)
#eval ratios16.countP (fun x => decide (x ≤ 73/200))       -- 8
#eval lowerMedian ratios16                                 -- 9/25  = 0.36
#eval lowerMedian ratios8                                  -- 9/25  = 0.36
#eval (orderStat 0 ratios16, orderStat 7 ratios16, orderStat 15 ratios16)
                                                           -- (8/25, 9/25, 41/100)
```

For an even sample size the median is the whole interval between the two central
order statistics; `73/200 = 0.365` is the midpoint of `[0.36, 0.37]` for both
runs, and it satisfies the definition `IsMedian` with counts `8/8` (16 samples)
and `4/4` (8 samples).  These are exactly `isMedian_ratios16` and
`isMedian_ratios8`.

## 2. The breakdown profile of the 16-sample run

```
#eval (List.range 16).map (fun j => min (j+1) (16-j))
-- [1, 2, 3, 4, 5, 6, 7, 8, 8, 7, 6, 5, 4, 3, 2, 1]
```

This is the entire vector of breakdown *numbers* of the 16 order statistics; it
is a concave tent peaking at `j = 7, 8` with value `8 = ⌈16/2⌉`.  Theorem
`orderStat_breakdownNumber` proves the entry-by-entry formula
`min (j+1, n-j)` in general; `ratios16_orderStat_profile` is the instance above.

The two extreme entries (`j = 0`, the sample minimum, and `j = 15`, the sample
maximum) both have breakdown number `1`, i.e. exactly as fragile as the mean
(`mean_breakdownNumber`).  This is `ratios16_extremes_breakdown`.

## 3. Counterexample hunt

Three universal claims were stress-tested before formalisation.

| Claim | Test | Outcome |
|---|---|---|
| "7 corruptions cannot move the median of `ratios16` outside `[0.32, 0.41]`" | exhaustive reasoning via the count transfer bound `countP_le_countP_add_diffCount`; the count of data `≤ m` drops by at most 7, so at least `8 - 7 = 1` genuine data point survives on each side | no counterexample; proved as `ratios16_robust` |
| "8 corruptions can make **anything** the median of `ratios16`" | explicit witness `contaminate ratios16 8 t` for arbitrary `t`; counts are `8 ≥ 8` on both sides | witness verified; proved as `ratios16_sharp` |
| "some equivariant estimator beats `⌈n/2⌉`" | the shear pair `shearLo`/`shearHi` produces, for every budget `k` with `2k ≥ n`, two `k`-contaminations differing by an arbitrary global shift | claim **refuted**; `breakdown_ceiling_unbounded` |

A near-miss worth recording: the naive guess "budget `k` is safe iff `k < n/2`"
is *false* for odd `n` under the truncating-division reading — the correct
threshold is `2k < n`, i.e. `k ≤ ⌊(n-1)/2⌋`, and the breakdown number is
`⌊(n+1)/2⌋ = ⌈n/2⌉`.  For `n = 15` this is `8`, not `7`.  The Lean statement is
phrased with `2 * k < xs.length` throughout to avoid the ambiguity.

## 4. Sequence note

The breakdown profile `min(j+1, n-j)` for `j = 0, …, n-1` is the finite "tent"
`1, 2, …, ⌈n/2⌉, …, 2, 1`.  Read as a triangle over all `n` it is the classical
`A004736`/`A051340`-style tent family; the peak value sequence
`1, 1, 2, 2, 3, 3, 4, 4, …` (i.e. `⌈n/2⌉`) is **A008619** shifted, and no OEIS
lookup was needed to identify it.  No claim of novelty is attached to this
sequence — it is recorded only because it is the exact optimisation object in
`orderStat_profile_maximised_at_median`.

## 5. What the evidence does *not* show

The numerical values above are convenience checks; the theorems in the `.lean`
files do not depend on any of them.  In particular `lowerMedian ratios16 = 9/25`
is reported by `#eval` but is *not* asserted as a theorem, because kernel
reduction of `Rat` division through `mergeSort` is impractical and
`native_decide` is disallowed here.  Everything that is stated as a theorem is
proved by an insight-bearing argument (`induction`, `omega`, `linarith`,
`norm_num`), never by a bare decision procedure.
