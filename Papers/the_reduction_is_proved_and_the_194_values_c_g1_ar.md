# Computational evidence

Everything reported here was afterwards **proved in Lean**; the numerics only guided
the formalization.  Items marked *(unverified exploration)* were computed in a
throw-away script and are **not** backed by a Lean artifact — they are listed for
transparency and are not used in any proof.

## 1. The object under study

A normalized McKay–Thompson-shaped series is

```
T = q⁻¹ + 0 + c(1) q + c(2) q² + ⋯ ,
```

so `q · T = 1 + 0·q + c(1) q² + c(2) q³ + ⋯` is a power series `≡ 1 mod q²`.
For a product of `m` such series the Laurent expansion starts at `q^(-m)`, and the
research question of this cycle is: which coefficients above the pole are *finite
arithmetic* in the table `c_g(1), c_g(2), …`?

## 2. Small-case calculations for the stable range

Product of `m` series `≡ 1 mod q²`, coefficients of the product in low degrees
(symbolically, `a_i = coeff 2 (q·T_i)`, `b_i = coeff 3`, `d_i = coeff 4`):

| degree `k` of `∏ (q·T_i)` | coefficient |
|---|---|
| 1 | `0` |
| 2 | `∑ a_i` |
| 3 | `∑ b_i` |
| 4 | `∑ d_i + ∑_{i<j} a_i a_j` |

So additivity holds exactly for `1 ≤ k ≤ 3 = 2·2 − 1` and breaks at `k = 4`.
Concrete break: `f = g = 1 + q²` gives `coeff 4 (f·g) = 1 ≠ 0 = coeff 4 f + coeff 4 g`.
Both the range and this counterexample are formalized
(`coeff_prod_of_isOneMod`, `stable_range_sharp`).

## 3. Head coefficients of eta quotients from frame shapes

For a balanced frame shape `∏ k^(a k)` the associated eta quotient satisfies
`q/η_g = ∏_{m ≥ 1} (1 − q^m)^(−b m)` with `b m = ∑_{k ∣ m} a k`.
Expanding to order `q²` predicts

```
c_g(1) = a₁(a₁+3)/2 + a₂ .
```

Direct power-series computation of `(η(τ)/η(nτ))^e` (exact integer arithmetic,
truncated at `q^8`), for the eight balanced shapes `1^(−e) n^(e)` with `e(n−1) = 24`:

| n | e | q-expansion of `q·(η/η_n)^e` | `c(1)` | formula `e(e−3)/2` (+`e` if n=2) |
|----|----|---|---|---|
| 2 | 24 | `1 − 24q + 276q² − 2048q³ + 11202q⁴` | 276 | 252 + 24 = 276 |
| 3 | 12 | `1 − 12q + 54q² − 76q³ − 243q⁴` | 54 | 54 |
| 4 | 8 | `1 − 8q + 20q² + 0q³ − 62q⁴` | 20 | 20 |
| 5 | 6 | `1 − 6q + 9q² + 10q³ − 30q⁴` | 9 | 9 |
| 7 | 4 | `1 − 4q + 2q² + 8q³ − 5q⁴` | 2 | 2 |
| 9 | 3 | `1 − 3q + 0q² + 5q³ + 0q⁴` | 0 | 0 |
| 13 | 2 | `1 − 2q − q² + 2q³ + q⁴` | −1 | −1 |
| 25 | 1 | `1 − q − q² + 0q³ + 0q⁴` | −1 | −1 |

The formula matches in all eight cases.  It is proved in Lean
(`MoonshineHeadTable.coeff_two_etaPartial`), so the table entries are *derived*, not
tabulated: `MoonshineHeadTable.etaHeadTable_values`.

Sum of the eight entries: `276+54+20+9+2+0−1−1 = 359`
(`MoonshineHeadTable.sum_etaHeadTable`, by `decide`).

## 4. Counterexample hunt

* *Universal additivity* `coeff k (∏ f_i) = ∑ coeff k (f_i)` for series `≡ 1 mod q^d`:
  **false** beyond `k < 2d`; explicit counterexample above, formalized.
* *Lower bound* `c(1) ≥ −1` for the family `1^(−e) n^(e)`, `n > 2`: searched
  `e ∈ [−50, 50]`, no violation; minimum `−1` attained at `e = 1, 2`
  (*unverified exploration*).  Proved in general in Lean:
  `MoonshineHeadTable.headCoeff_pmFrame_ge_neg_one`.
* *Naive guess* `c(1) = a₂ − a₁` (an early hypothesis): fails already for `n = 3`
  (predicts 12, true value 54).  Discarded.

## 5. Sequence remarks

The eight derived values `276, 54, 20, 9, 2, 0, −1, −1` are the `q¹`-coefficients of
the eight hauptmodul-type eta quotients `(η(τ)/η(nτ))^{24/(n−1)}`; the admissible
`n` are exactly those with `n − 1 ∣ 24`, i.e. `n ∈ {2,3,4,5,7,9,13,25}`
(`MoonshineHeadTable.pmData_balanced` records the balance condition `e(n−1) = 24`).
No OEIS lookup was performed; no claim about OEIS membership is made here.

## 6. Cycle 7: the full head block from the Newton recursion

Running the proved recursion `r c_r = ∑_{k<r} c_k σ_a(r−k)`, `σ_a(r) = ∑_{d ∣ r} d b_d`,
on the eight balanced frame shapes gives the head block

| n | e | c₀ | c₁ | c₂ | c₃ | c₄ |
|---|---|----|----|----|----|----|
| 2 | 24 | 1 | −24 | 276 | −2048 | 11202 |
| 3 | 12 | 1 | −12 | 54 | −76 | −243 |
| 4 | 8 | 1 | −8 | 20 | 0 | −62 |
| 5 | 6 | 1 | −6 | 9 | 10 | −30 |
| 7 | 4 | 1 | −4 | 2 | 8 | −5 |
| 9 | 3 | 1 | −3 | 0 | 5 | 0 |
| 13 | 2 | 1 | −2 | −1 | 2 | 1 |
| 25 | 1 | 1 | −1 | −1 | 0 | 0 |

Columns `c₂` and `c₃` reproduce the tables obtained earlier by two *independent* jet
computations; the agreement is now itself a theorem
(`MoonshineNewtonRecursion.coeff_two_etaPartial_via_recursion`,
`MoonshineNewtonRecursion.coeff_three_etaPartial_via_recursion`), which is the
strongest cross-check available for the earlier cycles.

Column `c₄` is new and verified in Lean
(`MoonshineNewtonRecursion.coeff_four_etaPartial_pmFrame`), with sum `10863`
(`sum_etaThirdHeadTable`).  Feeding it, together with `∑ c₁ = 359` and
`∑ c₁² = 79579`, into the boundary formula of cycle 5 gives the Laurent coefficient
`35514` of the eight-fold product in degree `−4`
(`MoonshineNewtonRecursion.coeff_prod_etaClasses_third`) — the first degree in which
the elementary symmetric correction `e₂` genuinely contributes.

No OEIS lookup was performed for these columns; no claim about OEIS membership is
made.
