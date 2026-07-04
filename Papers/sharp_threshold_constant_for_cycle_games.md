# Computational Evidence — Sharp Threshold Constant for Cycle Games

Target: Maker–Breaker `C_k`-game on `K_n`, `k ≥ 4`. Claimed threshold bias
`c_k · n^{(k-2)/(k-1)}` with `c_k = ((k-1)·(2(k-1)/k)^{k-2})^{1/(k-1)}`.

## 1. The threshold exponent `(k-2)/(k-1)` vs. the 2-density `(k-1)/(k-2)`

| k | exponent (k-2)/(k-1) | m₂(C_k) = (k-1)/(k-2) | product |
|---|----------------------|-----------------------|---------|
| 4 | 0.6667 | 1.5000 | 1 |
| 5 | 0.7500 | 1.3333 | 1 |
| 6 | 0.8000 | 1.2500 | 1 |
| 7 | 0.8333 | 1.2000 | 1 |

The exponent equals `1/m₂(C_k)` exactly, matching the Bednarska–Łuczak law
`bias = Θ(n^{1/m₂(H)})`. The exponent increases to `1`; the density decreases to `1`.

## 2. Maximum 2-density of `C_k` is attained by the whole cycle

Every proper subgraph of a cycle is a disjoint union of `c ≥ 1` paths, a forest with
`v = e + c` vertices (`e < v`). Its 2-density is
`(e-1)/(v-2) = (e-1)/(e+c-2) ≤ 1`, with equality iff `c = 1` (a single path).
The whole cycle has `e = v = k` and density `(k-1)/(k-2) > 1`. Hence

  `m₂(C_k) = max = (k-1)/(k-2)`,   attained uniquely by the whole cycle.

Small cases: `k=4 → 3/2`, `k=5 → 4/3`, `k=6 → 5/4`, i.e. `1 + 1/(k-2)`.

## 3. Numerical values of the threshold constant `c_k`

Computed in Lean with `Float`:

| k | c_k |
|---|-----|
| 4 | 1.8899 |
| 5 | 2.0119 |
| 6 | 2.0762 |
| 7 | 2.1123 |
| 10 | 2.1525 |
| 20 | 2.1448 |
| 100 | 2.0598 |
| 1000 | 2.0105 |

**Surprising, verified numerically:** `c_k` is *not* monotone. It increases from
`c_4 ≈ 1.89`, overshoots to a maximum `≈ 2.15` near `k ≈ 10..20`, then decreases,
apparently converging to `2` from above as `k → ∞`. This is because
`c_k = (k-1)^{1/(k-1)} · (2(k-1)/k)^{(k-2)/(k-1)}`, whose two factors tend to `1` and
`2` respectively.

## 4. Counterexample hunt

- Duality `exponent · density = 1`: holds for all tested `k` (exact rational identity).
- `m₂(C_k) = (k-1)/(k-2)`: no proper-subgraph density exceeded it in any enumerated
  cycle up to `k = 12`.
- Closed form `c_k^{k-1} = (k-1)·(2(k-1)/k)^{k-2}`: matches to floating-point precision.

No counterexamples found. All three claims formalized and proved with `0` sorries in
`Density.lean` and `Constant.lean` (axioms: `propext`, `Classical.choice`, `Quot.sound`).
