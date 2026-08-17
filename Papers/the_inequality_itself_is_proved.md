# Computational Evidence

Exploratory numerics used to *find* the right families and the right closed forms before
formalising.  Everything reported here was subsequently **proved in Lean** (see
`Catalog/Physics/FourierEnergyBound.lean`, `…/FourierEnergySidon.lean`,
`…/FourierEnergyFamilies.lean`, `…/FourierEnergyIntervals.lean`); the tables below are exploratory data, not the
verification.

Notation: `A ⊆ G` finite, `r(c) = #{(a,b) ∈ A×A : a+b = c}`,
`Ẽ = ∑_c r(c)²` (additive energy), `E = |G|·Ẽ − |A|⁴` (the nonprincipal Fourier energy of
`FourierAdd.card_support_rep_ge`), and

```
bound(A) = |G|·|A|⁴ / (|A|⁴ + E) = |A|⁴ / Ẽ      (this identity is Lean-proved:
                                                  FourierEnergy.fourierBound_eq_addEnergy_ratio)
pigeonhole(A) = |A| .
```

## 1. Intervals `A = {0,…,k−1} ⊆ ℤ/n` (the minimal-doubling family)

| n | k | \|A+A\| | Ẽ | bound = k⁴/Ẽ | pigeonhole |
|---|---|---------|---|--------------|------------|
| 3 | 2 | 3  | 6   | 2.667 | 2 |
| 9 | 3 | 5  | 19  | 4.263 | 3 |
| 12| 4 | 7  | 44  | 5.818 | 4 |
| 15| 5 | 9  | 85  | 7.353 | 5 |
| 18| 6 | 11 | 146 | 8.877 | 6 |

Observed closed form `Ẽ = k(2k²+1)/3` (matches all rows), giving
`bound = 3k³/(2k²+1) → 1.5k`.  Beats pigeonhole for every `k ≥ 2`, but only by a constant
factor — intervals have *minimal* doubling `|A+A| = 2k−1`, so no power gain is possible.
Since `bound/|A+A| = 3k³/((2k²+1)(2k−1))` increases to `3/4`, the bound is uniformly
within a factor `4/3` of the truth here, and never attains it.  All of this is now
formalised in `…/FourierEnergyIntervals.lean` (`addEnergy_discreteInterval`,
`fourierBound_discreteInterval`, `card_add_discreteInterval`,
`discreteInterval_bound_within_four_thirds`, `discreteInterval_bound_lt_card_add`).

## 2. Sidon sets — the parabola `P = {(x,x²)} ⊆ (ℤ/p)²`

Predicted from the Sidon structure: `Ẽ = 2k² − k`, `bound = k³/(2k−1) ≈ k²/2`.

| p | \|P\| | \|P+P\| | Ẽ | bound | pigeonhole |
|---|-------|---------|---|-------|------------|
| 3 | 3 | 6  | 15 | 5.400  | 3 |
| 5 | 5 | 15 | 45 | 13.889 | 5 |
| 7 | 7 | 28 | 91 | 26.385 | 7 |
| 11| 11| 66 | 231| 63.381 | 11|
| 13| 13| 91 | 325| 87.880 | 13|

`Ẽ = 2p² − p` on every row; `|P+P| = p(p+1)/2`; `bound/|P+P| → 1`.  A **quadratic** gain
over pigeonhole *and* asymptotic sharpness.  Formalised as
`FourierEnergyFamilies.parabola_*`.

## 3. Hamming ball of radius one `B = {0,e₁,…,eₙ} ⊆ 𝔽₂ⁿ`

| n | \|B\| | \|B+B\| | Ẽ | bound = (n+1)⁴/Ẽ | (n+1)³/(3n+1) | pigeonhole |
|---|-------|---------|---|------------------|---------------|------------|
| 1 | 2 | 2  | 8   | 2.000  | 2.000  | 2 |
| 2 | 3 | 4  | 21  | 3.857  | 3.857  | 3 |
| 3 | 4 | 7  | 40  | 6.400  | 6.400  | 4 |
| 4 | 5 | 11 | 65  | 9.615  | 9.615  | 5 |
| 5 | 6 | 16 | 96  | 13.500 | 13.500 | 6 |
| 6 | 7 | 22 | 133 | 18.053 | 18.053 | 7 |
| 7 | 8 | 29 | 176 | 23.273 | 23.273 | 8 |
| 8 | 9 | 37 | 225 | 29.160 | 29.160 | 9 |

`Ẽ = 3n²+4n+1 = (3n+1)(n+1)` on every row (also computed independently as the fourth
moment `2ⁿ·E[(1+X)⁴]`, `X = n−2·Binom(n,1/2)`, `= 2ⁿ(3n+1)(n+1)` for the *full* character
sum, confirming `E = 2ⁿ(3n²+4n+1) − (n+1)⁴`).  Equality with pigeonhole exactly at `n = 1`
(where `B` is the whole group, i.e. a subgroup!), strict for `n ≥ 2`.  Sumset sizes
`2, 4, 7, 11, 16, 22, 29, 37` are `1 + n(n+1)/2` — the *lazy caterer / central polygonal
numbers* (OEIS A000124).  Formalised as `FourierEnergyFamilies.hammingBall_*`.

## 4. Counterexample hunt for the dichotomy

Claim tested: `bound(A) > |A|` **iff** `|A+A| > |A|`.  Exhaustively checked over all
nonempty `A ⊆ ℤ/n` for `n ≤ 12` (all `2ⁿ−1` subsets of each `ℤ/n`, 8178 sets in total):
**0 counterexamples**.  A second scan over the same range found that every `A` with
`|A+A| = |A|` is a coset of a subgroup (**0** exceptions).  Proved in Lean as
`FourierEnergy.beats_pigeonhole_iff_card_add_gt` and `FourierEnergy.gain_or_coset`.

## 5. Where the ratio 3/2 comes from

For the exponent-two families the truth is `≈ k²/2` while the bound is `≈ k²/3`; the
tables above give `|B+B|/bound = 1.0, 1.037, 1.094, 1.144, 1.185, 1.219, 1.246, 1.269`,
increasing towards `3/2`.  This motivated the Lean theorem
`FourierEnergy.sidon2_bound_within_three_halves`, and the contrasting sharpness statement
`FourierEnergy.sidon_bound_sharp` (factor `1 + 1/(2k)`) in odd characteristic.
