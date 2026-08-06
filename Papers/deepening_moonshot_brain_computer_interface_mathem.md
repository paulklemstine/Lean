# Computational Evidence: Capacity of Noise-Tolerant Neural Codes

We study `A(N, d)` = the maximum number of binary activity patterns on `N`
neurons that can be used as a codebook whose distinct patterns are pairwise at
Hamming distance at least `d` (so the population still distinguishes concepts
after `d - 1` neurons misfire).

## 1. Exhaustive small-case computation

A branch-and-bound maximum-clique search over all `2^N` patterns gives the exact
values below, together with the four classical bounds we formalize:

* Gilbert–Varshamov (lower): `2^N / V(N, d-1)` where `V(N,r) = Σ_{k≤r} C(N,k)`,
* Hamming/sphere packing (upper): `2^N / V(N, t)` with `t = ⌊(d-1)/2⌋`,
* Singleton (upper): `2^(N+1-d)`,
* Plotkin (upper, only when `2d > N`): `2d / (2d - N)`.

```
N  d  A(N,d)   GV      Hamming   Singleton  Plotkin
1  1    2      2.0      2.0        2         2.0
1  2    1      1.0      2.0        1         1.333
2  1    4      4.0      4.0        4          –
2  2    2      1.333    4.0        2         2.0
2  3    1      1.0      1.333      1         1.5
3  1    8      8.0      8.0        8          –
3  2    4      2.0      8.0        4         4.0
3  3    2      1.143    2.0        2         2.0
3  4    1      1.0      2.0        1         1.6
4  1   16     16.0     16.0       16          –
4  2    8      3.2     16.0        8          –
4  3    2      1.455    3.2        4         3.0
4  4    2      1.067    3.2        2         2.0
4  5    1      1.0      1.455      1         1.667
5  1   32     32.0     32.0       32          –
5  2   16      5.333   32.0       16          –
5  3    4      2.0      5.333      8         6.0
5  4    2      1.231    5.333      4         2.667
5  5    2      1.032    2.0        2         2.0
5  6    1      1.0      2.0        1         1.714
6  1   64     64.0     64.0       64          –
6  2   32      9.143   64.0       32          –
6  3    8      2.909    9.143     16          –
6  4    4      1.524    9.143      8         4.0
6  5    2      1.123    2.909      4         2.5
6  6    2      1.016    2.909      2         2.0
6  7    1      1.0      1.524      1         1.75
```

No violation of any of the four bounds occurs in this exhaustive sample
(all `1 ≤ d ≤ N + 1`, `N ≤ 6`), which is a counterexample hunt over every
codebook on up to 6 neurons.

## 2. Patterns suggested by the data (all subsequently proved in Lean)

* `A(N, 1) = 2^N` — raw capacity.
* `A(N, 2) = 2^(N-1)` — one parity check halves capacity.
* `A(N, N) = 2` for `N ≥ 1` — only the repetition code survives; the upper bound
  here is exactly Plotkin's (`2d/(2d-N) = 2` at `d = N`), Singleton is also `2`.
* `A(N, N+1) = 1`.
* `A(N, d)` is antitone in `d`.
* **Parity-extension identity** `A(N+1, 2t+2) = A(N, 2t+1)`:
  `(N,d) = (5,3) ↦ (6,4)`: `4 = 4`; `(3,3) ↦ (4,4)`: `2 = 2`;
  `(4,3) ↦ (5,4)`: `2 = 2`; `(6,3) ↦ (7,4)`: `8 = 8`;
  `(1,1) ↦ (2,2)`: `2 = 2`; `(2,1) ↦ (3,2)`: `4 = 4`;
  `(5,1) ↦ (6,2)`: `32 = 32`.
  The identity holds on every computed instance.

## 3. Relation to OEIS

The row `A(N,3)` for `N = 1,2,3,…` is `1, 1, 2, 2, 4, 8, 16, 20, 40, …`
(OEIS A005864, sizes of optimal binary single-error-correcting codes); our
computed prefix `1, 1, 2, 2, 4, 8` agrees. The values `A(N,N) = 2` and
`A(N,1) = 2^N` are the constant sequence `2` and A000079 respectively. No new
sequence is claimed here — the formal content is the bounds and the exact
values, not a new sequence.

## 4. Sparse (constant-weight) assemblies

Exhaustive maximum-packing search for the largest family of `w`-element
assemblies in `[N]` that pairwise share fewer than `s` neurons, against the
packing bound `C(N,s) / C(w,s)` proved in `NeuralCodeSparsePacking.lean`:

```
N  w  s   max family   C(N,s)/C(w,s)
6  3  2       4            5.00
7  3  2       7            7.00     (Fano plane — bound attained)
9  3  2      12           12.00     (Steiner triple system — attained)
6  2  1       3            3.00     (disjoint assemblies — attained)
9  3  1       3            3.00     (disjoint assemblies — attained)
8  4  2       2            4.67
7  3  3      35           35.00
5  2  2      10           10.00
```

The bound is never violated and is attained exactly on Steiner systems and on
perfect partitions into disjoint assemblies, matching the tightness statement
`oneHot_attains_disjoint_bound`.

## 5. The largest-term (entropy) lower bound on binomial coefficients

For the rate ceiling proved in `Catalog/Novelty/NeuralCodeRateCeiling.lean` the
key inequality is `N^N ≤ (N+1) · r^r · (N-r)^(N-r) · C(N,r)`.  Values of the two
sides (computed with `#eval` in Lean; the inequality itself is *proved* as
`pow_self_le_succ_mul_binTerm`, so these are illustrations, not the evidence):

```
N   N^N        min over r of (N+1)·r^r·(N-r)^(N-r)·C(N,r)   ratio
2       4                 6                                 1.50
4     256               480                                 1.88
6   46656            102060                                 2.19
8 16777216         41287680                                 2.46
```

The minimum is attained at the central `r = N/2`, where Stirling gives
`r^r (N-r)^(N-r) C(N,r) ≈ N^N / √(πN/2)`, so the ratio above behaves like
`(N+1)/√(πN/2) = Θ(√N)`: the `1/(N+1)` largest-term loss is generous, but it
costs only `O(log N)` in the exponent and therefore vanishes per neuron, which
is all the rate statement needs.

The central-binomial corollary `4^n ≤ (2n+1)·C(2n,n)`:

```
n      0    1    2     3     4      5      6      7
4^n    1    4   16    64   256   1024   4096  16384
rhs    1    6   30   140   630   2772  12012  51480
```

## 6. Tightness of the Plotkin bound (affine / Hadamard populations)

For `Catalog/Novelty/NeuralCodePlotkinTightness.lean` the relevant data is the
diagonal `d = N/2` of the table in §1, compared with the boundary Plotkin bound
`A(2d, d) ≤ 4d` and with the size `2N` of the affine code:

```
N = 2d   d    A(N,d)   4d = 2N    affine code size
  2      1      4         4              4
  4      2      8         8              8
  6      3      8        12              –   (6 is not a power of two)
```

The two ends of the exhaustive range confirm the equality
`A(2^(m+1), 2^m) = 2^(m+2)` at `m = 0` (`A(2,1) = 4`) and `m = 1`
(`A(4,2) = 8`), and the row `N = 6` shows that the power-of-two hypothesis is
genuinely used: `A(6,3) = 8 < 12`, so the boundary Plotkin bound is *not*
attained for every even `N`.  Both the bound and its attainment at powers of two
are proved in Lean (`plotkin_boundary`, `hadamard_capacity`); the table is an
illustration.
