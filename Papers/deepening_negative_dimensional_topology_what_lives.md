# Computational Evidence — Euler characteristic in negative dimensions

Before formalizing, we tested the central formula
`χ(X) = (-1)^n · |π₀(X)|` for a space of dimension `-n`
and the algebraic laws it must satisfy.

## 1. The dimensional sign `sgn d = (-1)^d`

Tabulating `sgn d` for `d = -4 … 4`:

| d    | -4 | -3 | -2 | -1 | 0 | 1  | 2 | 3  | 4 |
|------|----|----|----|----|---|----|---|----|---|
| sgn d| +1 | -1 | +1 | -1 | +1| -1 | +1| -1 | +1|

Observations, all confirmed in the formal development:

* `sgn` depends only on the parity of `d`, hence `sgn(-d) = sgn(d)`.
* `sgn(a+b) = sgn(a)·sgn(b)` on every tested pair (e.g. `sgn(-3+5)=sgn(2)=+1`
  and `sgn(-3)·sgn(5) = (-1)(-1) = +1`). No counterexample exists because parity
  is additive mod 2.
* `sgn(-n) = (-1)^n`, matching the target sign in the headline formula.

## 2. The negative-dimensional formula on small cases

For a "formal `(-n)`-sphere with `k` components" (dimension `-n`, `|π₀| = k`):

| n | k | predicted χ = (-1)^n·k |
|---|---|------------------------|
| 0 | 3 | +3 |
| 1 | 3 | -3 |
| 2 | 3 | +3 |
| 1 | 1 | -1 |
| 3 | 2 | -2 |

Each entry equals `sgn(-n)·k`, confirming the two definitions agree.

## 3. Stabilization tower

Applying suspension `Σ` (dimension `+1`) `n` times to a dimension-`-n` object:

```
dim:  -n  → -n+1 → … → -1 → 0
χ  :  (-1)^n k → (-1)^{n-1} k → … → -k → k
```

Each suspension flips the sign of χ, and after `n` steps the dimension is `0`
and `χ = k = |π₀|`. This is the computational shadow of `chi_stabilize` and
`chi_via_stabilization`.

## 4. Multiplicativity spot-check

`χ(X × Y) = χ(X)·χ(Y)`: e.g. `X` at dim `-1`, `k=2` (χ = -2) times `Y` at dim
`-2`, `k=3` (χ = +3) gives a product at dim `-3`, `k=6`, χ = `(-1)^3·6 = -6 =
(-2)(3)`. ✓

## 5. Topological sanity: the genus-`g` surface

The alternating Betti sum `b₀ - b₁ + b₂` with `b₀ = 1`, `b₁ = 2g`, `b₂ = 1`
gives `2 - 2g` for `g = 0,1,2,3 → 2, 0, -2, -4`, the classical Euler
characteristic of the closed orientable surface. The sign-weighted invariant
`chiGraded` reproduces exactly these numbers.

## Conclusion

No counterexample appeared to any conjectured identity. The computational
landscape is fully consistent with a multiplicative, suspension-sign-reversing
Euler characteristic extending to negative dimensions, which is what the formal
development then establishes.
