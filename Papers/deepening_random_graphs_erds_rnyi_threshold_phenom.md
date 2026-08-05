# Computational evidence: the connectivity threshold of `G(n,p)`

All numbers below come from ordinary floating-point computation in Python (exact
enumeration for `n ≤ 6`, `lgamma`-based summation for the cut bound).  **They are
numerical exploration, not machine-verified results.**  The verified content of this
cycle is the Lean development in `Catalog/Probability/ErdosRenyiConnectivityLower.lean`
and `Catalog/Probability/ErdosRenyiConnectivityUpper.lean`, which builds without
`sorry`.

Throughout, `p = c·ln n / n` and `q = 1 - p`.

## 1. Exact small cases (full enumeration of all `2^{C(n,2)}` graphs)

| n | c = 0.5 | c = 1.0 | c = 2.0 |
|---|---------|---------|---------|
| 3 | 0.0883  | 0.3041  | 0.8235  |
| 4 | 0.0571  | 0.2996  | 0.8855  |
| 5 | 0.0412  | 0.3047  | 0.9166  |
| 6 | 0.0317  | 0.3132  | 0.9343  |

`P(G(n,p) connected)` already decreases in `n` for `c = 0.5`, increases for `c = 2`,
and stays nearly constant (`≈ 0.30`) at the critical constant `c = 1` — exactly the
behaviour predicted by the threshold theorem proved in Lean (and by the finer Poisson
window, where the limit at `c = 1` is `e^{-1} ≈ 0.368` only after the second-order
`log log n` correction is taken into account).

## 2. Expected number of isolated vertices `E[I_n] = n(1-p)^{n-1}`

| c | n=10¹ | 10² | 10³ | 10⁴ | 10⁵ | 10⁶ |
|---|-------|-----|-----|-----|-----|-----|
| 0.5 | 3.33 | 9.96 | 31.5 | 99.9 | 316 | 1000 |
| 0.9 | 1.24 | 1.51 | 1.97 | 2.51 | 3.16 | 3.98 |
| 1.1 | 0.72 | 0.58 | 0.49 | 0.40 | 0.32 | 0.25 |
| 2.0 | 0.039 | 0.0070 | 9.2e-4 | 9.9e-5 | 1.0e-5 | 1.0e-6 |

`E[I_n] ≈ n^{1-c}` diverges for `c < 1` and vanishes for `c > 1`, the quantitative
statement behind `tendsto_expected_isolated_atTop` and
`tendsto_expected_isolated_zero`.  The divergence for `c = 0.9` is slow (`n^{0.1}`),
which is why the Chebyshev bound below converges slowly.

## 3. The proved Chebyshev bound `P(connected) ≤ 1/(n q^{n-1}) + p/(1-p)`

(theorem `ErdosRenyi.prob_connected_le`)

| c | n=10² | 10³ | 10⁴ | 10⁶ | 10⁹ |
|---|-------|-----|-----|-----|-----|
| 0.5 | 0.124 | 0.035 | 0.010 | 1.0e-3 | 3.2e-5 |
| 0.9 | 0.704 | 0.514 | 0.400 | 0.251 | 0.126 |

The bound is non-trivial (`< 1`) already at `n = 100` for `c = 0.5`, and tends to `0`
for every `c < 1`, as proved.

## 4. The proved cut bound `P(disconnected) ≤ ∑_{1≤k≤n/2} C(n,k) q^{k(n-k)}`

(theorem `ErdosRenyi.prob_disconnected_le`)

| c | n=10² | 10³ | 10⁴ | 10⁵ |
|---|-------|-----|-----|-----|
| 1.1 | 0.822 | 0.636 | 0.487 | 0.372 |
| 1.5 | 0.088 | 0.031 | 0.0100 | 3.2e-3 |
| 2.0 | 7.0e-3 | 9.2e-4 | 9.9e-5 | 1.0e-5 |
| 3.0 | 4.1e-5 | 8.2e-7 | 9.7e-9 | 9.9e-11 |

Numerically the sum behaves like `n^{1-c}`, i.e. it is dominated by its `k = 1` term
(the isolated-vertex contribution) — the reason the sharp constant `c = 1` is
attainable, and the reason the Lean proof needs the entropy bound
`C(n,k) ≤ (e·n/k)^k` rather than the cruder `C(n,k) ≤ n^k` (the latter only gives
`c > 2`).

## 5. Counterexample hunt

* Exhaustive check for `2 ≤ n ≤ 6` and `c ∈ {0.25, 0.5, 1, 1.5, 2, 3}` (all admissible
  `p = c ln n/n ∈ [0,1)`): the exactly enumerated connection probability satisfies both
  proved bounds, `P(conn) ≤ 1/(n q^{n-1}) + p/(1-p)` and
  `1 - P(conn) ≤ ∑_{1≤k≤n/2} C(n,k) q^{k(n-k)}`, in every case.  No counterexample was
  found.  (Floating-point check only; the inequalities themselves are proved in Lean.)

## 6. OEIS

The number of labelled connected graphs on `n` nodes, which is the `p → 1/2`
specialisation of the enumeration in §1, is
[A001187](https://oeis.org/A001187): 1, 1, 1, 4, 38, 728, 26704, …
