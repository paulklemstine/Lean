# Computational Evidence — Extremal Graph Theory (Turán, Kruskal–Katona, Roth)

All computations were run in Lean (`#eval`) against the same Mathlib used for the
proofs, so the numbers below are exact, not floating-point approximations.

## 1. Turán density bound collapses to Mantel for `r = 3`

The integer Turán bound that Mathlib proves,
`B(n,s) = (n² − (n%s)²)·(s−1)/(2s) + C(n%s, 2)`, at `s = r−1 = 2` should equal
`⌊n²/4⌋`. Comparing `⌊n²/4⌋` with `B(n,2)` for `n = 0..8`:

| n            | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|--------------|---|---|---|---|---|---|---|---|---|
| ⌊n²/4⌋       | 0 | 0 | 1 | 2 | 4 | 6 | 9 | 12| 16|
| B(n,2)       | 0 | 0 | 1 | 2 | 4 | 6 | 9 | 12| 16|

Perfect agreement → `mantel`'s `⌊n²/4⌋` bound is exactly the `r=3` Turán bound,
and the density form `(1−1/(r−1))n²/2 = n²/4` is its real-number envelope.

## 2. Kruskal–Katona + Pascal (`family_union_shadow_ge`)

The combined bound rests on `C(k+1, r) = C(k, r−1) + C(k, r)`. Check `k=5, r=3`:

`C(6,3) = 20` and `C(5,2) + C(5,3) = 10 + 10 = 20`. ✓

So a `3`-uniform family on `Fin n` with `≥ C(5,3)=10` sets has, together with its
shadow, at least `C(6,3)=20` sets.

## 3. Additive energy lower bound (catalog Fourier bridge)

For `A = {0,1,2} ⊆ ℤ/7ℤ`: additive energy `E(A) = 19`, `|A|⁴ = 81`, `N = 7`.
Spectral bound `|A|⁴/N = 81/7 ≈ 11.57 ≤ 19 = E(A)`. ✓ (catalog
`card_pow_four_div_le_addEnergy`).

Note `2|A|² = 18 < 19 = E(A)`: `{0,1,2}` is *not* near-Sidon (it contains the
3-AP `0,1,2`, so it carries extra additive quadruples). This is the precise
dichotomy exploited in `RothThreeAP.lean`: 3-AP-rich sets have *large* energy,
near-Sidon sets have *small* energy and hence small cardinality (`|A|² ≤ 2N`).

## 4. Roth threshold sanity

`roth_3ap_dense` inherits Mathlib's `cornersTheoremBound ε ≤ card G` largeness
hypothesis; for any fixed density `ε > 0` this is satisfied once `G` is large
enough, and then every `A` with `|A| ≥ ε·|G|` contains a genuine 3-AP
`a, a+d, a+2d` with `d ≠ 0`. The extraction step was unit-tested in Lean on the
negated `ThreeAPFree` witness.
