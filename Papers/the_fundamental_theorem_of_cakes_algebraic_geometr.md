# Computational Evidence: the dimension `3g − 3 + n` of the moduli of decorated surfaces

## 1. Small-case enumeration of the moduli dimension

The claimed dimension of the moduli space `M_{g,n}` of genus-`g` surfaces with `n` marked
points (cherries) is `3g − 3 + n`. The unmarked value `3g − 3` for `g ≤ 5`:

| genus g | 0  | 1 | 2 | 3 | 4  | 5  |
|---------|----|---|---|---|----|----|
| 3g − 3  | −3 | 0 | 3 | 6 | 9  | 12 |

The values for `g ≥ 2` are `3, 6, 9, 12`, all positive and increasing by exactly `3` per
handle. This matches the classical dimension count for `M_g` and is verified in Lean by
`enumeration_g_le_five` and `moduli_step`.

The genus `0` and `1` entries (`−3` and `0`) are meaningless as dimensions of a nonempty space;
this signals that these strata are only well posed once enough cherries are added.

## 2. The exceptional low-genus strata, repaired by cherries

Using the marked formula `3g − 3 + n`:

| (g, n)      | 3g−3+n | stable? (2g−2+n > 0) | classical dim of M_{g,n} |
|-------------|--------|----------------------|--------------------------|
| (0, 3)      | 0      | yes (1 > 0)          | 0  ✓                     |
| (0, 4)      | 1      | yes                  | 1  ✓ (cross-ratio)       |
| (0, n)      | n − 3  | iff n ≥ 3            | n − 3  ✓                 |
| (1, 1)      | 1      | yes                  | 1  ✓ (j-invariant)       |
| (1, n)      | n      | iff n ≥ 1            | n  ✓                     |
| (2, 0)      | 3      | yes                  | 3  ✓                     |

The stability inequality `2g − 2 + n > 0` coincides exactly with the range where the dimension
formula returns a nonnegative number and the surface has finitely many automorphisms. This is
`stable_of_genus_two` and `dim_nonneg_of_stable` in the Lean file.

## 3. Two independent Riemann–Roch derivations of `3g − 3`

Both computations use `χ(L) = deg L + 1 − g` on a genus-`g` curve.

- **Deformations** `H¹(C, T_C)`: `deg T_C = 2 − 2g`, so
  `χ(T_C) = (2 − 2g) + 1 − g = 3 − 3g`, and since `H⁰(T_C) = 0` for `g ≥ 2`,
  `h¹(T_C) = −χ(T_C) = 3g − 3`.
- **Quadratic differentials** `H⁰(C, 2K_C)`: `deg 2K_C = 4g − 4`, so
  `χ(2K_C) = (4g − 4) + 1 − g = 3g − 3`, and since `H¹(2K_C) = H⁰(−K_C)* = 0` for `g ≥ 2`,
  `h⁰(2K_C) = 3g − 3`.

The two agree by Serre duality — verified by `deformation_eq_quadratic`.

## 4. OEIS

The unmarked dimension sequence `3g − 3` for `g = 2, 3, 4, …` is `3, 6, 9, 12, 15, …`, the
positive multiples of `3` (OEIS A008585, `a(n) = 3n`, reindexed). The Teichmüller real-dimension
sequence `6g − 6` is `6, 12, 18, 24, …` (A008588, `a(n) = 6n`). These are the classical
"complex dimension `3g − 3`, real dimension `6g − 6`" of Teichmüller theory.

## 5. Counterexample hunt

The only place the raw formula `3g − 3` fails to give a valid dimension is `g ∈ {0, 1}`, and
this is a *known* feature (unstable range), not a counterexample: adding cherries restores the
correct value `3g − 3 + n`, and the boundary is precisely the stability inequality. No
counterexample to the marked formula was found in the tested range `g ≤ 5`, `n ≤ 6`.
