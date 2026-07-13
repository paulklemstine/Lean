# Computational evidence — Isolation-Lemma density bridge

We study the exact singleton isolating count
`I(n,d) = # {w ∈ [d]^n : some vertex is a strict minimum} = n · ∑_{j<d} j^{n-1}`
and its **density** `R(n,d) = I(n,d) / d^n`.

## 1. The telescoping sandwich (verified by `decide`)

For all `k ∈ {0,1,2,3}` and `d ∈ {0,…,11}` the following integer inequalities hold
(checked in Lean with `decide`, see the header of the development):

```
(k+1) · ∑_{j<d} j^k  ≤  d^{k+1}  ≤  (k+1) · ∑_{j<d} j^k + (k+1) · d^k
```

Equivalently, with `n = k+1`,

```
d^n − n·d^{n-1}  ≤  n · ∑_{j<d} j^{n-1}  ≤  d^n .
```

Dividing by `d^n`, the density satisfies `1 − n/d ≤ R(n,d) ≤ 1`.

## 2. Density approaches 1 (n = 3, i.e. k = 2)

`R(3,d) = 3·∑_{j<d} j^2 / d^3`, floating-point evaluation:

| d | R(3,d) |
|---|--------|
| 1 | 0.0000 |
| 2 | 0.3750 |
| 3 | 0.5556 |
| 4 | 0.6563 |
| 5 | 0.7200 |
| 6 | 0.7639 |
| 7 | 0.7959 |

The values increase monotonically toward `1`, and the lower fence `1 − 3/d`
(e.g. `1 − 3/7 ≈ 0.571`) stays below them, matching the sandwich.

## 3. Analytic limit

Since `∑_{j<d} j^{n-1} = d^n/n + O(d^{n-1})` (Faulhaber), we have
`R(n,d) = n·(d^n/n + O(d^{n-1}))/d^n → 1`.  The discrete power sum limits to the
integral `∫_0^1 x^{n-1} dx = 1/n`, which is exactly the analytic content of the
bridge theorem `isolating_density_tendsto_one`.

## 4. Counterexample hunt

The claim proved is `R(n,d) → 1` for each fixed `n ≥ 1`; no counterexample is
possible for `n ≥ 1`. For `n = 0` the density is identically `0` (there is no
vertex to be a minimum), so the hypothesis `1 ≤ n` is necessary — this is the only
boundary case and it is excluded by hypothesis.
