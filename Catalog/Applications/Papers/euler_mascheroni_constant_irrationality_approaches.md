# Computational Evidence — Euler–Mascheroni constant `γ`

All numbers below were produced with `Float` evaluation in Lean (`#eval`).
Reference value: `γ = 0.5772156649…`.

## 1. The positive series `γ = ∑_k gterm k`, `gterm k = 1/(k+1) − log((k+2)/(k+1))`

| `k` | `gterm k` |
|----|-----------|
| 0  | 0.306853  (= 1 − log 2) |
| 1  | 0.094535  |
| 9  | 0.004690  |

Every term is positive and decreasing, with `gterm k ≈ 1/(2(k+1)^2)` (e.g.
`gterm 9 ≈ 0.00469 ≈ 1/(2·100)`), so the series converges (slowly, like a tail
`∑ 1/k^2`).  This matches `gterm_pos` and `summable_gterm`.

## 2. Partial sums = lower approximant `eulerMascheroniSeq n = H_n − log(n+1)`

| `n`   | `seq n` (lower) | `seq' n` (upper) |
|-------|-----------------|------------------|
| 10    | 0.531073        | 0.626383         |
| 100   | 0.572257        | 0.582207         |
| 1000  | 0.576716        | —                |

The partial sums increase monotonically toward `γ ≈ 0.57722` (confirming
`strictMono_eulerMascheroniSeq`) and stay strictly below it
(`integral_partialSum_lt_lt_seq'`), while `seq'` stays strictly above.

## 3. Trap width

`seq' 100 − seq 100 = 0.009950 = log(101/100)`, matching the exact width
`log(1 + 1/n)`.  Convergence is only `~1/n`; this is the structural reason an
elementary irrationality proof is out of reach (the catalog engine in
`Catalog/NumberTheory/Irrationality.lean` needs `o(1/q)` *rational* forms).

## 4. Stieltjes order 0

`stieltjesSeq 0 n = ∑_{k=1}^n 1/k − log n = H_n − log n = seq' n` for `n ≥ 1`,
which is the upper approximant above; it converges to `γ` from above
(`tendsto_stieltjesSeq_zero`).  `γ_0 = γ` is the anchoring case of the Stieltjes
hierarchy.

## 5. OEIS / references

- `γ`: OEIS A001620 (decimal expansion 0, 5, 7, 7, 2, 1, 5, 6, 6, 4, 9, …).
- Stieltjes constants `γ_n`: OEIS A001620 (`γ_0 = γ`), A082633 (`γ_1`), etc.

No counterexample was found to any claim formalized; all computational checks are
consistent with the proved theorems.
