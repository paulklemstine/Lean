# Computational Evidence — Pole-order obstruction (cycles 3–8)

All numbers below were obtained by hand-expansion of small products of normalized
`q`-series and were then **re-derived inside Lean** as sorry-free theorems; the
Lean statements are named in each item.  Nothing here relies on an unchecked
external computation.

## 1. Pole orders add (small cases)

| factors | product | order |
|---|---|---|
| `q⁻¹ + 2` | `q⁻¹ + 2` | `−1` |
| `(q⁻¹+2)(q⁻¹+3)` | `q⁻² + 5q⁻¹ + 6` | `−2` |
| `(q⁻¹+2)(q⁻¹+3)(q⁻¹+5)` | `q⁻³ + 10q⁻² + 31q⁻¹ + 30` | `−3` |
| `m` normalized factors | — | `−m` |

Lean: `PoleOrderObstruction.orderTop_prod_normalized` (cycle 1),
`PoleOrderObstruction.coeff_prod_linTrace` (cycle 4).

## 2. Coefficients are elementary symmetric functions

For the linear normalized series `q⁻¹ + aᵢ` the coefficient in degree `k − m` is
`e_k(a₁,…,a_m)`.  Small-case check with `a = (2,3,5)`:

| `k` | degree `k−3` | `e_k` | value |
|---|---|---|---|
| 0 | `−3` | `1` | 1 |
| 1 | `−2` | `a₁+a₂+a₃` | 10 |
| 2 | `−1` | `a₁a₂+a₁a₃+a₂a₃` | 31 |
| 3 | `0` | `a₁a₂a₃` | 30 |

The two boldest entries were formalized as Lean theorems:
`PoleOrderObstruction.coeff_prod_linTrace_example_two` (`e₁(2,3) = 5`) and
`PoleOrderObstruction.coeff_prod_linTrace_example_three` (`e₂(2,3,5) = 31`),
together with the general endpoint statements
`coeff_prod_linTrace_top` (top coefficient `= ∏ aᵢ`) and
`coeff_prod_linTrace_eq_zero_of_gt` (vanishing above degree `0`).

This *predicts* and then *proves* that the earlier hand-computed Newton
identities of cycle 2 (`coeff_prod_normalized_subleading`,
`coeff_prod_normalized_subsubleading`) are the cases `k = 1, 2` of one formula.

## 3. Root-spectrum search (counterexample hunt)

Claim tested: *a product of `m` normalized series has an `n`-th root iff `n ∣ m`.*

Sample scan over `m = 1,…,10` and `n = 1,…,10` (by the pole-order criterion,
order `= −m`, root ⟺ `n ∣ m`):

| `m` | admissible `n` |
|---|---|
| 1 | 1 |
| 2 | 1, 2 |
| 4 | 1, 2, 4 |
| 6 | 1, 2, 3, 6 |
| 194 = 2·97 | 1, 2, 97, 194 |

No counterexample was found, and the general statement is now a theorem
(`PoleOrderObstruction.exists_pow_eq_iff_dvd_order`,
`PoleOrderObstruction.root_exponents_194`).  The negative instances are also
formalized: `not_exists_cube_root_prod_traceLaurent_194` (`3 ∤ 194`) and
`not_exists_fourth_root_prod_traceLaurent_194` (`4 ∤ 194`, since `194` is
squarefree).

## 4. Replication table

`V_d` (`q ↦ q^d`) multiplies the pole order by `d`; the admissible root exponents
of the Monster-sized product become the divisors of `194 d`:

| `d` | pole order | new exponents gained |
|---|---|---|
| 1 | 194 | — |
| 2 | 388 | 4, 388 |
| 3 | 582 | 3, 6, 291, 582 |
| 5 | 970 | 5, 10, 485, 970 |

Formalized: `PoleOrderObstruction.exists_pow_eq_replicate_prod_traceLaurent_194_iff`,
`exists_cube_root_replicate_three_194` (root gained at `d = 3`),
`not_exists_fifth_root_replicate_three_194` (`5 ∤ 582`, obstruction survives).

## 5. Divisible value group

Over the exponent group `ℚ` the divisibility table above collapses: every `n` is
admissible, because `-194/n ∈ ℚ`.  Sample: `n = 3` gives the root of order
`-194/3`, and `n = 194` gives a root of order exactly `-1`.  Formalized:
`PoleOrderObstruction.exists_pow_eq_puiseuxEmb_prod_normalized` and
`PoleOrderObstruction.exists_root_194_orderTop_neg_one`.

## 6. Dimension of the principal-part space (cycle 7)

Counting the free parameters of a principal part of pole order at most `m`
(coefficients of `q⁻¹, …, q^{-m}`):

| `m` | principal part | free parameters |
|---|---|---|
| 0 | — | 0 |
| 1 | `c₀ q⁻¹` | 1 |
| 2 | `c₀ q⁻¹ + c₁ q⁻²` | 2 |
| 3 | `c₀ q⁻¹ + c₁ q⁻² + c₂ q⁻³` | 3 |
| 194 | `c₀ q⁻¹ + ⋯ + c₁₉₃ q⁻¹⁹⁴` | 194 |

The linear count `dim = m` and the unit jump `dim(m+1) − dim(m) = 1` were then
proved in Lean for all `m`: `PoleOrderObstruction.finrank_polePartSpace` and
`PoleOrderObstruction.finrank_gradedPiece`.  For the Monster-sized product the
deepest coordinate is `1` (`principalPart_prod_traceLaurent_194_top`), which is
why it sits in `poleSpace 194 \ poleSpace 193`
(`prod_traceLaurent_194_notMem_poleSpace_193`).

## 7. Lattice interpolation (cycle 8)

Admissible root exponents `n` for the Monster product when the exponents of the
root are constrained to the lattice `(1/N)ℤ ⊆ ℚ` (predicted criterion
`n ∣ 194 N`, then proved):

| `N` | `194 N` | admissible `n` |
|---|---|---|
| 1 | 194 | 1, 2, 97, 194 |
| 2 | 388 | 1, 2, 4, 97, 194, 388 |
| 3 | 582 | 1, 2, 3, 6, 97, 194, 291, 582 |
| 5 | 970 | 1, 2, 5, 10, 97, 194, 485, 970 |

This table is *identical* to the replication table of section 4 with `d = N`,
which is the content of
`PoleOrderObstruction.lattice_root_iff_replicate_root`; the criterion itself is
`PoleOrderObstruction.exists_lattice_root_iff`, and the cube-root row is
isolated as `exists_lattice_cube_root_iff` (`3 ∣ N`).

## 8. OEIS

The only integer sequence appearing is the divisor set of `194 = 2 · 97`
(`{1, 2, 97, 194}`) and, in the replicated case, the divisors of `194 d`; these
are instances of A027750 (divisors of n) and carry no further structure.  The
coefficient sequences are the elementary symmetric functions `e_k`, i.e. the rows
of A000012-weighted subset sums, again not a specific catalogued sequence.
