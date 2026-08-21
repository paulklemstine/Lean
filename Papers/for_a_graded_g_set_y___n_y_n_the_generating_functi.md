# Computational evidence

All numbers below were produced by `#eval` inside the project's Lean/Mathlib
environment (Lean 4.28.0), before the formal proofs were written.  They are
exploratory data, not verification: every claim they suggested is proved
formally in `Catalog/Shared/GradedTransitivity/`.

## 1. The two model graded `G`-sets

Both use the same underlying graded set `Y_n = Fin n`; they differ only in the
acting group.

| grade `n`                                   | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---------------------------------------------|---|---|---|---|---|---|---|---|---|
| `t_2(Y_n)`, `G_n = Perm (Fin n)` (transitive) | 0 | 0 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
| `t_3(Y_n)`, `G_n = Perm (Fin n)`              | 0 | 0 | 0 | 1 | 1 | 1 | 1 | 1 | 1 |
| `t_2(Y_n)`, `G_n = ⊥` (trivial)               | 0 | 0 | 2 | 6 | 12| 20| 30| 42| 56|
| `t_3(Y_n)`, `G_n = ⊥`                         | 0 | 0 | 0 | 6 | 24| 60|120|210|336|
| `C(n,2)`                                     | 0 | 0 | 1 | 3 | 6 | 10| 15| 21| 28|

For the trivial group every injective `r`-tuple is its own orbit, so
`t_r(Y_n) = n(n-1)⋯(n-r+1) = r!·C(n,r)` (the falling factorial); the `r = 2`
row is `n(n-1)` (the pronic/oblong numbers shifted by one index) and the
`r = 3` row is `n(n-1)(n-2)`.  No online OEIS lookup was available in this
environment, so the sequences are identified here by closed form rather than
by an OEIS id.

## 2. Finite differences (the mechanism behind the theorem)

Forward differences of `t_2(Y_n) = n(n-1)` (trivial group):

```
a      = [0, 0, 2, 6, 12, 20, 30, 42, 56]
Δa     = [0, 2, 4, 6,  8, 10, 12, 14]
Δ²a    = [2, 2, 2, 2,  2,  2,  2]
Δ³a    = [0, 0, 0, 0,  0,  0]
```

`Δ³ = 0` but `Δ² ≠ 0`: exactly the predicted pole of order `3 = r+1` at `q=1`
for `r = 2`, and the reason the exponent cannot be lowered.  For the
symmetric-group family, `Δa = 0` already from the transitivity threshold on,
which is why one factor of `(1-q)` suffices there.

## 3. Denominator-clearing convolutions

Coefficients of `(1-q)^k · ∑_n a_n qⁿ`, computed by convolution:

| series                                   | `k` | result (first 9 coefficients)      |
|------------------------------------------|-----|------------------------------------|
| `a_n = n(n-1)`  (trivial group, `r=2`)   | 3   | `[0,0,2,0,0,0,0,0,0]` → `2q²`      |
| `a_n = n(n-1)`  (trivial group, `r=2`)   | 2   | `[0,0,2,2,2,2,2,2,2]` → **not** a polynomial |
| `a_n = [n ≥ 2]` (symmetric group, `r=2`) | 1   | `[0,0,1,0,0,0,0,0,0]` → `q²`       |

These match the formal theorems `trivial_family_generating_function`
(`(1-q)^{r+1}·H = r!·q^r`), `trivial_family_denominator_sharp`, and
`perm_graded_gen` (`(1-q)·H = q^r`).

## 4. Counterexample hunt

The universal claim tested was: *eventual `r`-transitivity ⟹ `(1-q)` clears the
Hilbert series.*  Sampling families with an arbitrary finite "defect region"
(arbitrary values `t_r(Y_n)` for `n < N`, value `1` afterwards) never produced
a non-polynomial numerator — consistent with the proof, since only the tail of
the sequence controls the denominator.  The hunt did, however, immediately
falsify the stronger guess *"`(1-q)` clears the series for every graded
`G`-set with polynomially bounded `t_r`"*: the trivial-group family above is a
counterexample, and this is now the formal theorem
`trivial_family_denominator_sharp`.
