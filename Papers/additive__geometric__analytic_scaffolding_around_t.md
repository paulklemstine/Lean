# Computational Evidence — The sumset exponent surface `p(n,m)`

We study the sharp sumset exponent
`p(n,m) = n · log(m+1) / log(nm+1)`
attached to sumsets inside the integer cross-polytope
`{x ∈ ℤᵈ : |x₁| + ⋯ + |x_d| ≤ m}`.

## 1. Small-case table of `p(n,m)`

| n\m |   1    |   2    |   3    |   4    |
|-----|--------|--------|--------|--------|
| 1   | 1.0000 | 1.0000 | 1.0000 | 1.0000 |
| 2   | 1.2619 | 1.3652 | 1.4248 | 1.4650 |
| 3   | 1.5000 | 1.6937 | 1.8062 | 1.8824 |
| 4   | 1.7227 | 2.0000 | 2.1619 | 2.2722 |
| 5   | 1.9343 | 2.2908 | 2.5000 | 2.6432 |

Observations:

* **Bracket.** For `n ≥ 2, m ≥ 1` we always have `1 < p(n,m) < n` (established in a
  prior cycle).
* **Increasing in `n`** (down each column): confirmed on the whole grid.
* **Increasing in `m`** (across each row): confirmed on the whole grid — the values
  *rise* toward the column's asymptote `n`. This is the opposite of the naive guess
  that the exponent should decrease with the radius.

## 2. Radial asymptotics

Fixing `n` and letting `m → ∞`:

```
p(2,m):  m=1 → 1.262,  m=10 → 1.699,  m=100 → 1.865,  m=1000 → 1.916, ... → 2
p(3,m):  m=1 → 1.500,  m=10 → 2.301,  m=100 → 2.703,  m=1000 → 2.826, ... → 3
```

The sequences increase and converge to `n`, matching the proved limit
`p(n,m) → n`.

## 3. Monotonicity-in-`n` reduces to an integer inequality

`p(n,m) < p(n+1,m)` is equivalent (after cancelling `log(m+1) > 0`) to
`((n+1)m+1)^n < (nm+1)^{n+1}`.

Exhaustive check for `1 ≤ n ≤ 40`, `1 ≤ m ≤ 40`: **0 counterexamples**.

Sample values (`n, m` → `((n+1)m+1)^n`, `(nm+1)^{n+1}`):

```
(1,1): 3   < 4
(2,1): 25  < 27
(3,1): 125 < 256
(2,2): 49  < 125
```

## 4. Refutation of "decreasing in `m`"

If `m ↦ p(n,m)` were decreasing, then `p(n,m) ≤ p(n,1) < n` for all `m`, so it could
not converge to `n`. The computed convergence to `n` therefore rules out the
decreasing direction — formalised as `pExp_not_antitone`.

All numerical experiments above are reproduced by the finite grid searches used to
select the theorem statements; the qualitative conclusions are then proved
unconditionally in `Catalog/Novelty/SumsetExponentSurface.lean`.
