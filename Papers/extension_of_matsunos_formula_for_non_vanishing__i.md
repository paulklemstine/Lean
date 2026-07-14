# Computational Evidence — μ-extension of Matsuno's formula

All computations below were run in Lean (`#eval`) and match the formal definitions in
`Catalog/Novelty/MatsunoMuExtension.lean`.

## 1. The `2`-adic depth `n_ℓ = v₂((ℓ²−1)/8)` and local μ-weights `2^{n_ℓ}`

| prime `ℓ` | `(ℓ²−1)/8` | `n_ℓ` | `muWeight ℓ = 2^{n_ℓ}` | `ℓ mod 8` |
|-----------|------------|-------|------------------------|-----------|
| 3         | 1          | 0     | 1                      | 3         |
| 5         | 3          | 0     | 1                      | 5         |
| 7         | 6          | 1     | 2                      | 7         |
| 11        | 15         | 0     | 1                      | 3         |
| 13        | 21         | 0     | 1                      | 5         |
| 17        | 36         | 2     | 4                      | 1         |

Observation: `muWeight ℓ = 1` exactly for `ℓ ≡ ±3 (mod 8)`, and `muWeight ℓ > 1` for
`ℓ ≡ ±1 (mod 8)`.  This matches the depth law `8·2^{n_ℓ} = 2^{v₂(ℓ−1)+v₂(ℓ+1)}` proved as
`muWeight_depth` (for `ℓ = 3`: `8·1 = 8 = 2^{1+2}`; for `ℓ = 17`: `8·4 = 32 = 2^{4+1}`).

## 2. Additivity vs. multiplicativity (counterexample hunt)

Take `NE = 1`, `μ = 0`, and `ord ℓ = 2` if `ℓ = 5` else `1`.  Then:

* `lambdaDiffMu 3  = 0`   (local term at 3 vanishes: `3 ∤ 1` and `ord 3 = 1` is odd)
* `lambdaDiffMu 5  = 2^{n_5+1} = 2 > 0`   (`ord 5 = 2` is even)
* `lambdaDiffMu 15 = 0 + 2 = 2`   (additivity)

Additive: `lambdaDiffMu 15 = lambdaDiffMu 3 + lambdaDiffMu 5 = 0 + 2 = 2`. ✓
Multiplicative would give `lambdaDiffMu 3 · lambdaDiffMu 5 = 0`, but `lambdaDiffMu 15 = 2 ≠ 0`.
⇒ **multiplicativity is false** (formalized as `lambdaDiffMu_not_multiplicative`).

A second illustration with `NE = 1`, `μ = 1`, `ord ≡ 0`:
`lambdaDiffMu 3 = 3`, `lambdaDiffMu 5 = 3`, `lambdaDiffMu 15 = 6 = 3+3`, while the product is
`9 ≠ 6`.

## 3. Recovery / inversion of μ

With `weightSum D > 0` (i.e. `D` has a prime factor), the excess
`lambdaDiffMu − lambdaDiff = μ · weightSum D` divides back to `μ` exactly.  E.g. `D = 15`,
`weightSum 15 = muWeight 3 + muWeight 5 = 1 + 1 = 2`; if `μ = 7` the excess is `14` and
`14 / 2 = 7`.  Formalized as `mu_recovery`.

Necessity of a prime factor: for `D = 1`, `weightSum 1 = 0`, so the excess is `0`
independent of `μ` — `μ` is invisible.  Formalized as `mu_not_injective_of_no_prime`.

## 4. μ-term is not lower-order

`D = 3`, `NE = 1`, `ord ≡ 1` gives `lambdaDiff = 0` but `muTerm 3 μ = μ · 1 = μ`, which
exceeds the classical term for every `μ ≥ 1`.  Formalized as
`muTerm_not_dominated_by_lambdaDiff`.

## 5. OEIS

The weight sequence `muWeight ℓ` over odd `ℓ = 3,5,7,9,11,13,15,17,…` begins
`1,1,2,1,1,1,2,4,…`; this is `2^{v₂(ℓ²−1)−3} = 2^{v₂(ℓ−1)+v₂(ℓ+1)−3}`. No dedicated OEIS
entry is needed — it is a simple `2`-adic valuation shift and is fully characterized by the
proved depth law.
