# Computational Evidence — Seidel energy of `K_{m,n}` under edge deletion

All numbers below are reproduced *exactly* inside the Lean development; this note
records the numerical exploration that pinned down the correct theorem.

## Set-up

The Seidel matrix of a graph is `S = J − I − 2A`.  For `K_{m,n}` (parts of sizes
`m`, `n`) the entries are `0` on the diagonal, `+1` inside a part, `−1` across
parts, i.e. `S = w wᵀ − I` with `w = (+1 on the left, −1 on the right)`.  The
Seidel energy is `E(S) = Σ |λ|` over the eigenvalues.

## Closed forms (derived, then verified numerically and in Lean)

* Base graph:            `E(K_{m,n})     = 2(m+n−1)`.
* One cross edge deleted: `E(K_{m,n} − e) = (m+n−2) + √((m+n−2)(m+n+6))`  (valid for `m+n ≥ 3`).

Spectra:

* `K_{m,n}`      : `{ m+n−1 }  ∪  {−1}^{m+n−1}`.
* `K_{m,n} − e`  : `{ 1 } ∪ {−1}^{m+n−3} ∪ { r₊, r₋ }`, where `r± = ((m+n−4) ± √((m+n−2)(m+n+6)))/2`.

## Numerical table (`numpy`, deleting one edge; ↑ = strict increase, = : equal)

```
 m  n | E(K)  E(K−e)     diff
 1  1 |   2   2.00000   +0.000   =
 1  2 |   4   4.00000   +0.000   =
 1  3 |   6   6.47214   +0.472   ↑
 2  2 |   6   6.47214   +0.472   ↑     <-- COUNTEREXAMPLE to "both ≥ 3"
 2  3 |   8   8.74456   +0.745   ↑
 2 15 |  32  33.57418   +1.574   ↑
 3  3 |  10  10.92820   +0.928   ↑
 4  4 |  14  15.16515   +1.165   ↑
```

The pattern is unambiguous: the energy strictly increases **iff `m + n ≥ 4`**; it
stays equal only for `K_{1,1}` and `K_{1,2}` (`m+n ≤ 3`).

## Counterexample hunt

The conjecture "strict increase ⇔ both parts `≥ 3`" fails already at the smallest
possible witness:

* `K_{2,2}` : `E = 6`, `E(−e) = 2 + 2√5 ≈ 6.4721 > 6`, yet neither part has size 3.
* `K_{1,3}` : `E = 6`, `E(−e) = 6 + √20 ≈ 6.4721 > 6`, and one part has size 1.

Both directions of the conjecture are wrong: it over-predicts *no increase* for
`K_{2,2}` and `K_{1,3}`. The Lean file formalises the `K_{2,2}` witness
(`Ktwotwo_energies`, `conjecture_is_false`) and the general sharp threshold
(`seidel_energy_increase_iff`).

## Comparison to the sharp inequality

`E(K−e) − E(K) = √((m+n−2)(m+n+6)) − (m+n)`, which is `> 0` iff
`(m+n−2)(m+n+6) > (m+n)²` iff `4(m+n) − 12 > 0` iff `m+n > 3`.  For integers this
is exactly `m + n ≥ 4` — the threshold proved in Lean.
