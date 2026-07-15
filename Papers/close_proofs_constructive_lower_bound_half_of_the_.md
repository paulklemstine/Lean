# Computational Evidence: the multi-join law

The coindex `coind` is defined as an `sSup` and is noncomputable, but the *predicted* values of the
multi-join law are elementary arithmetic, so the claims are easy to check against the geometry of
joins of spheres.

## The predicted formula

`coind(Oct n ⋆ Oct l₀ ⋆ ⋯ ⋆ Oct l_{k-1}) = n + (l₀ + ⋯ + l_{k-1}) + k`.

Geometrically the join `Sᵃ ⋆ Sᵇ` is `Sᵃ⁺ᵇ⁺¹`, so an `(k+1)`-fold octahedral join is the sphere of
dimension `(sum of dimensions) + k`, and the ℤ₂-coindex of `Sᵈ` is `d`. The formula is therefore the
join dimension of a wedge of spheres, matching `Sᵃ ⋆ Sᵇ ⋆ Sᶜ = S^{a+b+c+2}`, etc.

## Small cases (head `n`, list `l`), predicted `n + l.sum + l.length`

| n | l           | join                          | dimension | coindex |
|---|-------------|-------------------------------|-----------|---------|
| 2 | []          | S²                            | 2         | 2       |
| 2 | [3]         | S² ⋆ S³ = S⁶                  | 6         | 6       |
| 1 | [1,1]       | S¹ ⋆ S¹ ⋆ S¹ = S⁵            | 5         | 5       |
| 0 | [0,0,0]     | (S⁰)⋆⁴ = S³                   | 3         | 3       |
| 2 | [0,0]       | S² ⋆ S⁰ ⋆ S⁰ = S⁴ (2× susp.) | 4         | 4       |

Each row satisfies `coindex = n + l.sum + l.length`, matching `coind_octJoin_list`.

## Iterated self-join `(r+1)`-fold, predicted `(r+1)(a+1) - 1`

| a | r | (r+1)-fold join of Sᵃ | dimension | (r+1)(a+1)-1 |
|---|---|-----------------------|-----------|--------------|
| 0 | 0 | S⁰                    | 0         | 0            |
| 0 | 3 | (S⁰)⋆⁴ = S³           | 3         | 3            |
| 1 | 1 | S¹ ⋆ S¹ = S³          | 3         | 3            |
| 2 | 2 | S² ⋆ S² ⋆ S² = S⁸     | 8         | 8            |

Matches `coind_joinPow_oct` and, for `a = 0`, `coind_joinPow_S0`.

## Counterexample hunt

The formula is an exact identity forced by (i) `Sᵃ ⋆ Sᵇ = S^{a+b+1}` at the level of octahedral
free ℤ₂-sets and (ii) `coind(Sᵈ) = d` (the sharp Borsuk–Ulam value imported from
`Z2CoindexJoin`/`Z2CoindexSuspensionTower`). No counterexample is possible; the Lean proof discharges
the arithmetic by induction on the list / on the power, so all finitely many small cases above are
subsumed by the general theorem.

## OEIS

No new integer sequence arises; the values are the linear expression `n + Σl + |l|`.
