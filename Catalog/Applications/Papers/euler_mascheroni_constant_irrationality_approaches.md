# Computational Evidence — Euler–Mascheroni constant γ

All numbers below were produced with `Float` `#eval` in Lean (see commands at the
bottom). They are *evidence*, not proof; the proofs are in the `.lean` files and
build with 0 sorries.

## 1. The defining sequence `H_n − log(n+1)` approaches γ ≈ 0.5772

| n | `eulerMascheroniSeq n = H_n − log(n+1)` |
|---|------------------------------------------|
| 0 | 0.000000 |
| 1 | 0.306853 |
| 2 | 0.401388 |
| 3 | 0.447039 |
| 4 | 0.473895 |
| 5 | 0.491574 |
| 6 | 0.504090 |
| 7 | 0.513416 |

Monotonically increasing toward γ = 0.5772156649… (slow, `O(1/n)` convergence —
exactly the rate certified by `gamma_sub_seq_lt_inv`).

## 2. The telescoping series terms `emTerm k = 1/(k+1) − log((k+2)/(k+1))`

| k | emTerm k |
|---|----------|
| 0 | 0.306853 |
| 1 | 0.094535 |
| 2 | 0.045651 |
| 3 | 0.026856 |
| 4 | 0.017678 |
| 5 | 0.012516 |

All strictly positive and decreasing (consistent with `emTerm_nonneg`); their
running sums reproduce column 1 of Table 1 (telescoping identity
`partialSum_emTerm`). Asymptotically `emTerm k ≈ 1/(2(k+1)²)`, so the series
converges and is summable (`summable_emTerm`).

## 3. Tropical soft-max cap

`log 2 = 0.693147…`. The soft-max term `softMax 1 0 (−log(k+1)) = log((k+2)/(k+1))`
takes its maximum value at `k = 0` (namely `log 2 = 0.693`), and decreases to `0`.
This matches the EML dequantization sandwich `0 ≤ softMax ≤ log 2`
(`softMax_term_mem_Icc`): the hard tropical max `max(0, −log(k+1)) = 0`, and the
soft correction never exceeds `log 2`.

## 4. Counterexample hunt

- Claim "`emTerm k ≥ 0`": tested `k = 0..200`, no negative term. (Proved.)
- Claim "`softMax 1 0 (−log(k+1)) ≤ log 2`": tested `k = 0..200`, max at `k=0` equals
  `log 2`; never exceeded. (Proved.)
- Claim "error `< 1/n`": for `n = 1..50`, `γ_approx(n) := H_n − log(n+1)` satisfies
  `γ − γ_approx(n) < 1/n` with healthy margin (the true gap is ≈ `1/(2n)`).
  No counterexample. (Proved as `gamma_sub_seq_lt_inv`.)

## OEIS

The harmonic numerators/denominators (A001008 / A002805) and γ's decimal expansion
(A001620) are the relevant catalogued sequences; the telescoping correction series
`1/k − log(1+1/k)` is a standard but un-tabulated transcendental series.

## Reproduction (Lean `#eval`)

```lean
def H : ℕ → Float | 0 => 0 | (n+1) => H n + 1.0/(Float.ofNat (n+1))
def seqn (n:ℕ) : Float := H n - Float.log (Float.ofNat n + 1.0)
#eval (List.range 8).map (fun n => (n, seqn n))
#eval Float.log 2
#eval (List.range 6).map (fun k =>
  (k, 1.0/(Float.ofNat k+1.0) - (Float.log (Float.ofNat k+2.0) - Float.log (Float.ofNat k+1.0))))
```
