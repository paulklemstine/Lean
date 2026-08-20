# Computational evidence — tropical (min-plus) digests

All computations below are Lean `#eval`s and are reproducible from
`Catalog/Pythagorean/TropicalCryptocurrency/Evidence.lean` (the file compiles and
prints exactly the outputs quoted here).  Model: integer min-plus digest

```
dg A m i = min_j ( A i j + m j ),   A an r × k integer key table.
```

Notation: `Act i` = active (minimizing) coordinates of component `i`;
`τ` = minimum size of a set meeting every `Act i` (hitting number);
`maxConeDim` = largest `|S|` such that raising *all* coordinates in `S` leaves the
whole digest unchanged (the maximal coordinate collision-cone dimension, found by
brute force over all `2^k` subsets).

## 1. Small-case calculations

| `A` | `m` | digest | active sets | `τ` | `maxConeDim` | `k − r` |
|---|---|---|---|---|---|---|
| `[[0,3,5,2],[4,1,7,6],[9,8,2,3]]` | `[0,0,0,0]` | `[0,1,2]` | `[{0},{1},{2}]` | 3 | 1 | 1 |
| `[[0,0,5,2],[0,1,7,6]]` | `[0,0,0,0]` | `[0,0]` | `[{0,1},{0}]` | 1 | 3 | 2 |
| `[[0,1],[0,1]]` | `[0,0]` | `[0,0]` | `[{0},{0}]` | 1 | 1 | 0 |

Reading of the three rows.

1. *Generic* instance: unique, pairwise distinct minimizers, `τ = r = 3`, and the
   cone dimension is exactly `k − r = 1`.  This is the case settled by
   `finrank_span_collisionCone_eq`.
2. Overlapping active sets: `τ = 1 < r = 2` and the cone dimension `3` strictly
   exceeds the universal bound `k − r = 2`.  So `k − r` is a lower bound only, and
   the true invariant is `k − τ`.
3. The SDR counterexample: both components have the single active coordinate `0`,
   so the active family has **no** system of distinct representatives (Hall's
   condition fails), yet a `1`-dimensional collision cone exists.  This is the
   instance formalised in `sdr_criterion_counterexample`.

## 2. Counterexample hunt for `maxConeDim = k − τ`

400 pseudorandom instances with `k = 4`, `r ∈ {1,2,3}`, key entries in `{0,…,5}`,
messages in `{0,…,3}`:

```
(maxConeDim = k − τ for all instances, maxConeDim ≥ k − r for all instances)
= (true, true)
```

No counterexample.  This is exactly the corrected Hall-type criterion proved in
`exists_collisionSupport_card_iff` (a coordinate cone of dimension `≥ d` exists iff
a hitting set of size `≤ k − d` exists, i.e. iff `d ≤ k − τ`), together with the
universal bound `τ ≤ r` proved in `exists_collisionSupport`.

## 3. Counterexample hunt for one-shot inversion under box constraints

50 pseudorandom instances with `k = 3`, `r ∈ {1,2}`, target digests `y` with
entries in `{−2,…,5}`, box `{0,…,12}^3`.  For each instance we compare

* brute force over all `13^3 = 2197` messages in the box, and
* the single candidate `w = max(canon A y, 0)` where
  `canon A y j = max_i (y i − A i j)`:

```
brute-force feasibility = candidate test, for all 50 instances = true
```

No counterexample; this is `box_preimage_exists_iff`.

## 4. Bounded alphabets

No search is needed for the bounded-alphabet claim: the construction in
`exists_two_letter_collision` is explicit (constant message `a`, one unused
coordinate raised to `b`), keys enter nowhere, and it is formally verified.  The
tabulated instances above confirm the underlying combinatorial input — with `r < k`
the union of active sets never covers all `k` coordinates.

## 5. OEIS

No integer sequence arises: the quantities appearing here (`k − r`, `τ`, `k − τ`)
are instance-dependent dimensions rather than a canonical sequence, so an OEIS
lookup is not meaningful for this cycle.
