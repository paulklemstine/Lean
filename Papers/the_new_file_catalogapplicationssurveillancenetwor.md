# Computational evidence

Small-case computations run before formalization, all of them inside Lean 4 with
`#eval` on self-contained list models (binary vectors as `List Bool`, relabelings
as permutations of `List.range n`).  Every claim that survived was afterwards
proved formally; the numbers below are exploratory data, not verification.

## 1. Orbit covering radius under the full relabeling group

Model: `orbDist x y = min over permutations g of Hamming(x ∘ g, y)`, brute forced
over all `2^n` binary vectors and all `n!` relabelings.

| `n` | brute-force orbit covering radius | `⌈n/2⌉ = (n+1)/2` |
|-----|-----------------------------------|-------------------|
| 0   | 0                                 | 0                 |
| 1   | 1                                 | 1                 |
| 2   | 1                                 | 1                 |
| 3   | 2                                 | 2                 |
| 4   | 2                                 | 2                 |
| 5   | 3                                 | 3                 |

Compare the plain Hamming covering radius, which is `n` for every `n`
(parent file `hamming_coveringRadius`).  The data suggested the exact statement
now proved as `SurveillanceNetworks.Relabeling.orbit_coveringRadius`.

## 2. Orbit distance equals the weight gap

Exhaustive check over all `2^5 × 2^5 = 1024` pairs of binary vectors of length 5:

```
orbDist x y = |wt x − wt y|      →   true (all 1024 pairs)
```

This is now `SurveillanceNetworks.Relabeling.orbDist_eq_dist_wt`.

## 3. Counterexample hunt: is the majority vote always optimal?

Exhaustive minimization of `E_p[hdist(c, X)]` over all `2^3` reconstructions `c`,
compared with the conjectured closed form `∑_i min(mass_i(false), mass_i(true))`,
for five source laws on `{0,1}^3` (exact rational arithmetic):

| source law `p`                                   | brute-force minimum | `∑_i min(·,·)` | equal? |
|--------------------------------------------------|---------------------|----------------|--------|
| point mass                                        | `0`                 | `0`            | yes    |
| uniform                                           | `3/2`               | `3/2`          | yes    |
| `(1/2,1/4,1/8,1/16,1/32,1/32,0,0)`                | `19/32`             | `19/32`        | yes    |
| `(0,1/3,0,1/3,0,0,1/3,0)`                         | `1`                 | `1`            | yes    |
| `(2,1,1,1,2,1,1,1)/10`                            | `13/10`             | `13/10`        | yes    |

No counterexample; the uniform row is the `|α|/2 = 3/2` value.  Proved as
`privDist_hamming_eq_sum_minority` and `privDist_hamming_uniform`.  Note the point
mass shows `|α|/2` is *not* a lower bound over all source laws — only the uniform
statement is claimed.

## 4. Binomial tails and the zero-excess corner

For `n = 6`, `∑_{i ≤ D} C(6,i)` runs `1, 7, 22, 42, 57, 63, 64`, strictly below
`2^6 = 64` for every `D < 6`.  This is the finite shadow of
`sum_choose_lt_two_pow`, which converts the measure converse
`(1−ε)·2^n ≤ ∑_{i≤D} C(n,i)` at `ε = 0` back into the sharp threshold `D ≥ n`
(`private_zero_excess_forces_full_distortion`).

## 5. OEIS

The sequence of orbit covering radii `0, 1, 1, 2, 2, 3, 3, …` is
`⌈n/2⌉` (A004526 shifted, "integers repeated"); the layer volumes are ordinary
binomial coefficients (A007318) and the middle binomial coefficient
`C(n, ⌊n/2⌋)` appearing in `orbit_rate_bound` is A001405.  No new sequence arises.
