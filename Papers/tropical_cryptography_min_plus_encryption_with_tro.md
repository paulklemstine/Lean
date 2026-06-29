# Computational Evidence — Tropical Discrete Logarithm (min-plus) eigenvalue attack

All numbers below were produced by a self-contained min-plus computation over `ℚ`
(verified in Lean; reproduced here). The formal theorems live in
`Catalog/Tropical/TropicalDiscreteLog.lean` and
`Catalog/Bridges/TropicalStrongDivisibilityDLog.lean`.

## Setup

Tropical (min-plus) matrix–vector action `(A ⊗ v)_i = min_j (A_{ij} + v_j)`, with

```
A = [[3, 5],
     [5, 3]]          (constant diagonal c = 3)
v = (0, 1)            (tropical eigenvector)
```

`(c, v) = (3, (0,1))` is a tropical eigenpair: `A ⊗ v = v + 3`, verified
`A ⊗ v = (3, 4) = v + 3`.

## 1. Eigenvalue additivity under powers  (`tropMatPow_eigenpair`)

The residual `(A^{⊗t} ⊗ v)_i − v_i` measured after `t` applications, at both coordinates:

| genuine power `t` | residual coord 0 | residual coord 1 | predicted `t·c` |
|-------------------|------------------|------------------|-----------------|
| 1                 | 3                | 3                | 3               |
| 2                 | 6                | 6                | 6               |
| 3                 | 9                | 9                | 9               |
| 5                 | 15               | 15              | 15              |

The residual is **constant across coordinates** and equals `t·c` exactly — this is the
leak that breaks the TDLP: `k = residual/c − 1`.

## 2. Strong divisibility leak  (`tdlp_divisibility_leak`, `tropical_eigenvalue_gcd`)

The leaked eigenvalue sequence is `t ↦ c·t`. For `c = 3`:

```
gcd( eig(4), eig(6) ) = gcd(12, 18) = 6 = 3 · gcd(4,6) = eig(gcd(4,6)).
```

So the public eigenvalues form a *strong divisibility sequence*: their divisibility
lattice mirrors the divisibility lattice of the exponents.

## 3. Counterexample hunt — the boundary `c = 0`

For `c = 0` (the boundary eigenvalue of `Tropical/EigenzeroNoLeak.lean`) the sequence is
identically `0`, every value divides every other, and **no** exponent information leaks.
This is the precise complement of the broken regime: the `↔` in `tdlp_divisibility_leak`
genuinely requires `0 < c`. No counterexample to the guarded statements was found.

## OEIS

The eigenvalue sequence `t ↦ c·t` is the multiples-of-`c` sequence (e.g. `c=1` is
A000027, the identity sequence, which is also the `idSDS` of
`Bridges/StrongDivisibilitySequences.lean`). The strong divisibility property of `c·t`
is `Nat.gcd_mul_left`.
