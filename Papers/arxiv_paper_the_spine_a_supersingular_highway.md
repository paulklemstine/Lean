# Computational Evidence — Metric structure of the supersingular 2-isogeny spine

This note records the small-case computations that guided the formalization in
`SupersingularSpinePath.lean`. For `ℓ = 2` and `p ≡ 71, 119 (mod 120)` the connected
components of the spine, after deleting the single non-`𝔽_p` edge, are finite paths `P_m`.
All of the paper's organizing functions — distance, eccentricity, diameter and the mean
diameter — are therefore consequences of the combinatorial geometry of `P_m`, which we
verified numerically before proving in general.

## 1. Distance function

For the path `P_m` on the vertex labels `{0, …, m−1}`, the distance between labels `i` and
`j` is the absolute difference `|i − j|`. This was checked exhaustively for small `m` and is
the content of `pathGraph_dist`. Each isogeny step moves the label by exactly `±1`, so the
distance cannot beat `|i − j|`, and a monotone chain realizes it.

## 2. Eccentricity function

For `P_{n+1}` (labels `0..n`) the eccentricity of vertex `i` is `max(i, n − i)`. For
`n = 6` the eccentricity profile across the seven vertices is

```
i        : 0 1 2 3 4 5 6
ecc(i)   : 6 5 4 3 4 5 6
```

a symmetric "V" with minimum at the centre (the graph radius `⌈n/2⌉`) and maximum `n` at the
endpoints (the diameter). This matches `pathGraph_eccent` and `pathGraph_diam`.

## 3. Wiener index (total pairwise distance)

Let `W(m) = Σ_{i,j} |i − j|` be the sum of all ordered pairwise distances in `P_m`. Direct
computation gives

```
m       : 0  1  2  3   4   5   6    7
W(m)    : 0  0  2  8  20  40  70  112
(m³−m)/3: 0  0  2  8  20  40  70  112
```

so `W(m) = (m³ − m)/3 = 2·binom(m+1, 3)`, i.e. `3·W(m) + m = m³` in subtraction-free form.
The sequence `0, 0, 2, 8, 20, 40, 70, 112, …` is `2·(tetrahedral numbers)` and is the Wiener
index of the path graph (OEIS A002623/A007290-type tetrahedral scaling). This is proved as
`wiener_interval` and transported to graph distance in `pathGraph_wiener`. Dividing by the
number of ordered pairs `m²` gives the mean intra-component distance
`(m² − 1)/(3m) → m/3`.

## 4. Mean diameter as a discriminator

Model a spine by the multiset of its component vertex-counts. The mean diameter is the
average of the component diameters `mᵢ − 1`, and it collapses to

```
mean diameter = (total vertex count) / (number of components) − 1.
```

Fixing a total of `12` supersingular vertices and splitting into `k` equal path components:

```
k (components) : 1   2   3   4   6
comp. size     : 12  6   4   3   2
mean diameter  : 11  5   3   2   1
```

The mean diameter is strictly decreasing in the number of components, so — for a fixed
supersingular vertex count — it detects how finely the spine is fragmented. This is exactly
the role the paper assigns to the mean diameter as a discriminator of spine structure as `p`
varies, and it is captured by `meanDiameter_eq` and `meanDiameter_replicate`.

## Conclusion

Every numerical prediction matched the closed forms with no counterexamples, so we proceeded
to the general proofs. No conjecture in this cycle was refuted by the computations.
