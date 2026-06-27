# Computational Evidence — Linear Brown–Erdős–Sós at the span threshold

This note records the small-case arithmetic that motivated the formal results in
`LinearBrownErdosSos.lean` and `LinearHypergraphPacking.lean`. All claims below are
*proved* in Lean; the numbers here are the scratch checks that guided the formalization.

## 1. Greedy span bound vs. the BES threshold

For a linear `r`-uniform hypergraph, adding an edge to a union of `m` previous edges adds at
least `r - m` new vertices (each old edge steals at most one), so `k` distinct edges span at
least

    g(r,k) := r·k − C(k,2)      (greedy bound, `LinearBES.span_card_ge`)

vertices. The BES span threshold is

    t(r,k) := (r−2)·k + 3.

Difference `t − g = C(k,2) + 3 − 2k = (k−2)(k−3)/1` (as integers, `(k-2)(k-3) = k^2-5k+6`):

| k | C(k,2) | g(r,k)−rk part −C(k,2) | t−g = C(k,2)+3−2k | sign |
|---|--------|------------------------|-------------------|------|
| 3 | 3      | −3                     | 3+3−6 = 0         | =    |
| 4 | 6      | −6                     | 6+3−8 = 1         | +    |
| 5 | 10     | −10                    | 10+3−10 = 3       | +    |
| 6 | 15     | −15                    | 15+3−12 = 6       | +    |
| 7 | 21     | −21                    | 21+3−14 = 10      | +    |

So `t − g = (k−2)(k−3)` and is `0` at `k = 3`, positive for `k ≥ 4`. This is exactly
`LinearBES.trivial_eq_threshold_at_three` (equality at `k=3`) and
`LinearBES.trivial_lt_threshold_of_four_le` (strict for `k≥4`). **Interpretation:** for `k ≥ 4`
the threshold sits strictly above what linearity forces for free, so a `k`-edge family spanning
`≤ t(r,k)` vertices is *possible*; forbidding it is a genuine hypothesis. At `k = 3` the
threshold *is* the linear minimum — the Ruzsa–Szemerédi `(6,3)` boundary.

## 2. The packing ceiling is `Θ(n²)`, never `o(n²)`

The linear packing bound `|E|·C(r,2) ≤ C(n,2)` (`LinearBES.linear_packing`) gives, for `r = 3`,

    |E| ≤ C(n,2)/3 = n(n−1)/6.

Steiner triple systems (when they exist, e.g. `n ≡ 1, 3 mod 6`) achieve `|E| = n(n−1)/6`, so the
packing bound is *tight up to the constant*: it is `Θ(n²)` and can never by itself yield `o(n²)`.

| n  | C(n,2) | packing ceiling ⌊C(n,2)/3⌋ | STS edge count n(n−1)/6 |
|----|--------|----------------------------|--------------------------|
| 7  | 21     | 7                          | 7 (Fano plane)          |
| 9  | 36     | 12                         | 12                       |
| 13 | 78     | 26                         | 26                       |
| 15 | 105    | 35                         | 35                       |

This is the precise sense in which the conjecture's content is the **constant-density →
vanishing-density** jump, invisible to packing arguments. (Steiner systems do contain dense local
configurations, so they do *not* satisfy the BES hypothesis — consistent with the conjecture.)

## 3. Counterexample hunt

No counterexample is possible to the *proved* statements (they are theorems). We instead sanity
checked that the proved inequalities are not vacuous:

* `span_card_ge` at `r=3, k=3`: a "triangle" `{a,b,x},{b,c,y},{c,a,z}` spans `6 = 3·3 − C(3,2)`
  vertices, meeting the bound with equality — the bound is tight.
* `linear_packing` at the Fano plane (`r=3, n=7, |E|=7`): `7·C(3,2) = 21 = C(7,2)`, equality —
  the bound is tight.

## 4. OEIS

The greedy minimum-span sequence `g(3,k) = 3k − C(k,2)` for `k = 1,2,3,…` is `3, 5, 6, 6, 5, …`
(it decreases once `k > 3` because the greedy estimate degrades; the true minimum span is
`max(3, that)`). The strictly-increasing threshold `t(3,k) = k + 3` is `4, 5, 6, 7, 8, …`
(A000027 shifted). No deep sequence is involved; the arithmetic is elementary and fully
formalized, so an extended OEIS search was unnecessary.
