# Computational Evidence — round-65 #1 (exp 533, bitlen 76)

All numbers below were used to *choose* the statements; every claim that appears as a
theorem is proved in Lean (`Catalog/Novelty/ZeroFitDial*.lean`) and is marked
**[Lean-verified]**.  Items marked *(exploratory)* were computed with exact rational
arithmetic outside Lean and are reported only as motivation.

## 1. Exact ceilings of `p`-adic tie profiles

Tie profile of the base-`p` trailing-zero statistic on `{0,…,p^b−1}`:
blocks `(p−1)p^{b−1}, …, (p−1)p, (p−1), 1`.  Exact `ρ² = 1 − 12·Σ(m³−m)/12 / (n³−n)`:

| p | b | profile | exact ρ² | closed form `3p/(p²+p+1)·(1+1/(p^b(p^b+1)))` |
|---|---|---------|----------|-----------------------------------------------|
| 2 | 2 | [2,1,1] | 0.900000 | 0.900000 ✓ |
| 2 | 4 | [8,4,2,1,1] | 0.860294 | 0.860294 ✓ |
| 3 | 2 | [6,2,1] | 0.700000 | 0.700000 ✓ |
| 3 | 4 | [54,18,6,2,1] | 0.692412 | 0.692412 ✓ |
| 5 | 3 | [100,20,4,1] | 0.483902 | 0.483902 ✓ |
| 7 | 2 | [42,6,1] | 0.368571 | 0.368571 ✓ |
| 7 | 4 | [2058,294,42,6,1] | 0.368421 | 0.368421 ✓ |

The closed form matched the brute-force value in every case tested (exact `Fraction`
arithmetic, all `p ∈ {2,3,5,7}`, `b ≤ 4`).  **[Lean-verified]** as
`padic_spearmanSq` (all `p ≥ 2`, `b ≥ 1`).

## 2. Asymptotic ceiling table `L(p) = 3p/(p²+p+1)`

| p | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
|---|---|---|---|---|---|---|---|---|
| L(p) | 0.857143 | 0.692308 | 0.571429 | 0.483871 | 0.418605 | **0.368421** | 0.328767 | 0.296703 |

Recorded bitlen-76 dial, squared: seeds `0.351649 / 0.381924 / 0.374544`,
pooled `0.369664`.  Only `L(7) = 7/19 = 0.368421` falls inside `[0.351649, 0.381924]`.
**[Lean-verified]** as `effective_base_seven` (uniqueness over all integer bases `p ≥ 2`,
using strict antitonicity of `L`).

## 3. Continuous inversion

`effBase(r) = ((3−r) + √(3(1−r)(3+r)))/(2r)` solves `3p/(p²+p+1) = r`:

| r | 0.593² | 0.608² | 0.612² | 0.618² | 7/19 |
|---|--------|--------|--------|--------|------|
| effBase(r) | 7.39603 | **6.97205** | 6.86405 | 6.70584 | 7 (exact) |

**[Lean-verified]**: `effBase_spec` (identity), `effBase_seven` (`effBase(7/19) = 7`
exactly, since the discriminant is the perfect square `(48/19)²`),
`effBase_pooled_bracket` (`6.9 < effBase(0.608²) < 7.05`), `effBase_seed_bracket`
(both extreme seeds inside `(6.6, 7.4)`).

## 4. Flatness check (bitlen 72 vs 76)

`ρ²(2,b) − 6/7 = (6/7)/(2^b(2^b+1))`, so

* `ρ²(2,72) − ρ²(2,76) ≈ 3.83·10⁻⁴⁴`  **[Lean-verified]** `dial_flat_72_76` (`< 10⁻⁴³`);
* `ρ²(2,64) − ρ²(2,76) ≈ 2.52·10⁻³⁹`, i.e. `10³⁰ ×` that change is still below the
  recorded drop `0.648 − 0.608 = 0.04`  **[Lean-verified]** `tie_mechanism_excluded_64_76`.

## 5. Counterexample hunt for the "dominant block" claim

Claim tested: *can a tie profile with all blocks `≤ n/2` reach `ρ² ≤ 0.37`?*
Exhaustive search over all integer partitions of `n ≤ 40` with maximal part `≤ n/2`
*(exploratory)*: the minimum for each `n` is attained by two equal blocks `[n/2, n/2]`
and decreases towards `3/4` from above (`n = 4`: `0.8000`; `n = 12`: `0.75524`;
`n = 40`: `0.750469`); no partition ever went below `3/4`.
This suggested — and Lean now proves in full generality —
`balanced_profile_ge_three_quarters`: max block `≤ n/2 ⟹ ρ² ≥ 3/4`, and the sharper
`spearmanSq_ge_of_max_block`: `ρ² ≥ 1 − (M²−1)/(n²−1)`.  Inverting it,
a ceiling as low as `0.608²` needs `M > 0.79 n`  **[Lean-verified]**
`u76_requires_dominant_block`.

## 6. OEIS

The dyadic profile `1, 1, 2, 4, 8, …` and the base-`p` profile `1, p−1, (p−1)p, …` are the
standard geometric block sequences; no non-obvious integer sequence arose in this cycle,
so no OEIS identification is claimed.
