# Computational evidence

The formal target concerns a uniform guessing rank on `N = b^k` candidates.  The exact formulas subsequently proved in `ExactPrefactors.lean` are

- `E[G] = (N+1)/2`,
- `E[G²] = (N+1)(2N+1)/6`,
- `Var(G)/N² = (1-N⁻²)/12`.

## Small cases

For the binary case `N = 2^k`:

| `k` | `N` | `E[G]/N` | `E[G²]/N²` | `Var(G)/N²` | `Var(G)/E[G]²` |
|---:|---:|---:|---:|---:|---:|
| 1 | 2  | 0.750000 | 0.625000 | 0.062500 | 0.111111 |
| 2 | 4  | 0.625000 | 0.468750 | 0.078125 | 0.200000 |
| 3 | 8  | 0.562500 | 0.398438 | 0.082031 | 0.259259 |
| 4 | 16 | 0.531250 | 0.365234 | 0.083008 | 0.294118 |

The columns approach respectively `1/2`, `1/3`, `1/12`, and `1/3`, matching the formal limit theorems.

## OEIS search

The unnormalized first and second raw sums are the classical power-sum sequences `1+⋯+N` (triangular numbers, OEIS A000217) and `1²+⋯+N²` (square pyramidal numbers, OEIS A000330).  These identifiers are contextual only; no OEIS fact is used by the Lean proofs.

## Counterexample hunt

Direct substitution into the closed forms for bases `b = 2,3,4,5` and dimensions `k = 0,…,8` found no discrepancy.  The edge case `k=0` gives a singleton list, hence mean and second moment both `1` and variance `0`, also agreeing with the exact formulas.  This numerical hunt is illustrative; machine-checked universal proofs are in `ExactPrefactors.lean`.
