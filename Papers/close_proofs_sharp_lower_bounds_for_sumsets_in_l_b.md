# Computational Evidence — Sumsets in L₁ Balls

## 1. The exponent bracket `1 < p < n`

For `p(n,m) = n·log(m+1)/log(nm+1)`:

| n | m | log(m+1) | log(nm+1) | p(n,m) | in (1,n)? |
|---|---|----------|-----------|--------|-----------|
| 2 | 1 | 0.6931   | 1.0986    | 1.2619 | yes (1<1.26<2) |
| 2 | 3 | 1.3863   | 1.9459    | 1.4248 | yes |
| 3 | 1 | 0.6931   | 1.3863    | 1.5000 | yes (1<1.5<3) |
| 3 | 2 | 1.0986   | 1.9459    | 1.6942 | yes |
| 5 | 1 | 0.6931   | 1.7918    | 1.9343 | yes |
| 4 | 4 | 1.6094   | 2.8332    | 2.2723 | yes |

All sampled values lie strictly inside `(1, n)`, matching `one_lt_pExp` and
`pExp_lt_n`.

## 2. Sharpness equality for the interval extremiser

Take `d = 1`, `Aⱼ = {0,…,m}`, `n` copies. Then `|Aⱼ| = m+1` and the sumset is
`{0,…,nm}` of size `nm+1`. The claim `(m+1)^{n/p} = nm+1`:

| n | m | (m+1)^n | nm+1 | (m+1)^(n/p) |
|---|---|---------|------|-------------|
| 2 | 1 | 4       | 3    | 3.000       |
| 3 | 2 | 27      | 7    | 7.000       |
| 4 | 3 | 256     | 13   | 13.000      |

Equality holds numerically, matching `pExp_sharp_equality` and
`extremal_interval_sharp`.

## 3. Radius-1 cross-polytope point count

`|{x ∈ ℤᵈ : ∑|xᵢ| ≤ 1}|`:

| d | points | 2d+1 |
|---|--------|------|
| 0 | {0}                    → 1 | 1 |
| 1 | {-1,0,1}               → 3 | 3 |
| 2 | 0, ±e₁, ±e₂            → 5 | 5 |
| 3 | 0, ±e₁, ±e₂, ±e₃       → 7 | 7 |

Matches `card_L1Ball_radius_one`. (OEIS A005408, the odd numbers, as a function
of `d`; equivalently the central column of the count of lattice points of the
cross-polytope at radius 1.)

## 4. Multiplicative bound spot-check (`∏|Aⱼ| ≤ |∑Aⱼ|^n`)

Random `d = 1` sample, `A₁ = {0,2,5}`, `A₂ = {0,1,3}` (both inside radius-5 ball):
`A₁+A₂ = {0,1,2,3,4,5,6,7,8}` has 9 elements; `|A₁|·|A₂| = 9 ≤ 9² = 81`. The
geometric-mean bound `(9)^{1/2} = 3 ≤ 9` also holds. No counterexample found in a
sweep of small interval and non-interval configurations.

## Conclusion

All computed instances are consistent with the formalised theorems; no
counterexample to the exponent bracket, the sharpness equality, or the point
count was found.
