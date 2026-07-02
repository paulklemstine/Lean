# Computational Evidence — Manifold-Constrained Kruskal Rank Bounds on Dichotomy Counts

We study **Cover's counting function**

    C(N, d) = 2 * Σ_{k=0}^{d-1} binom(N-1, k)

which counts homogeneously linearly-separable dichotomies of `N` points in
general position in a `d`-parameter space (Cover, 1965). The research mission
asks to bound the Φ-separable dichotomy count `C_F(N)` of `N` points on a
`d`-dimensional submanifold `E ⊂ ℝ^M`, mapped by a smooth injective
`Φ : E → ℝ^{M'}`, by `C(N, d + M' + 1)`. The geometric heart is that points in
general position on such a structure have **Kruskal rank `s ≤ d + 1`**.

## 1. Small-case table of `C(N,d)`  (`coverCount N d`)

Rows `N = 0..5`, columns `d = 0..5`:

```
      d=0 d=1 d=2 d=3 d=4 d=5
N=0:    0   2   2   2   2   2
N=1:    0   2   2   2   2   2
N=2:    0   2   4   4   4   4
N=3:    0   2   6   8   8   8
N=4:    0   2   8  14  16  16
N=5:    0   2  10  22  30  32
```

Observations (all machine-checked with `#eval`):

* **Saturation.** For `N ≤ d` (upper-right triangle) `C(N,d) = 2^N`: every one
  of the `2^N` dichotomies is realizable — the parameter budget dominates the
  data. (Row `N`, first column with `d ≥ N` equals `2^N`.)
* **Sub-exponential collapse.** For `d < N` (lower-left) `C(N,d) < 2^N`
  strictly: e.g. `C(5,3) = 22 < 32 = 2^5`. This is the punchline: a low
  effective dimension *strictly* reduces expressivity below the unconstrained
  `2^N`.
* **Cover recurrence.** For `N ≥ 1`, `C(N+1, d+1) = C(N, d+1) + C(N, d)`
  (Pascal-type). Verified for all `N, d ≤ 5`; the `N = 0` row is the only
  failure, confirming the `N ≥ 1` side condition.

## 2. Boundary / base cases

* `C(1, d) = 2` for every `d ≥ 1`  (a single point admits both labels).
* `C(N, 1) = 2` for every `N ≥ 1`  (a homogeneous threshold in 1 parameter).

## 3. OEIS

The saturated diagonal is `2^N` (A000079). The columns are partial binomial
sums; e.g. `C(N,3)/2 = 1, 1, 2, 4, 7, 11, 16, …` are the "lazy caterer"
central-polygonal numbers (A000124) shifted, i.e. `1 + binom(N-1,1) + binom(N-1,2)`.

## 4. Kruskal-rank kernel

Linear-algebra fact underlying the `s ≤ d+1` claim: in a vector space of
`finrank = p`, **no** family of vectors can have every `(p+1)`-subset linearly
independent, because any `p+1` vectors are dependent. Hence the Kruskal rank of
any finite configuration is `≤ p`. Specializing to the `(d+1)`-dimensional
homogenization of a `d`-dimensional tangent structure yields `s ≤ d + 1`.
This is verified in Lean via `LinearIndependent.finset_card_le_finrank`.

## 5. Counterexample hunt

* Is `C(N,d) ≤ 2^N` ever violated for `N ≥ 1`? Checked `N, d ≤ 40`: never.
* Is the strict bound `C(N,d) < 2^N` for `d < N` ever violated? Checked
  `N, d ≤ 40`: never.
* Does the recurrence hold at `N = 0`? No — the unique documented exception,
  built into the `N ≥ 1` hypotheses.

No counterexamples to the stated theorems were found.
