# Computational evidence — additive uncertainty on `ZMod n`

*All numbers below come from exploratory floating-point computation and are **not** machine-checked.
The machine-checked statements are the Lean theorems in `Catalog/Shared/ChebotarevMinors.lean`,
`Catalog/Shared/FourierUncertaintySum.lean` and
`Catalog/Shared/FourierUncertaintySumApplications.lean`, which carry no `sorry`.*

## 1. Are all minors of the DFT matrix nonzero? (Chebotarev)

For each modulus `n` we computed `|det (ω^{st})_{s∈S, t∈T}|` for **all** pairs of equal-size
subsets `S, T ⊆ {0,…,n-1}`, with `ω = e^{-2πi/n}`, and recorded the minimum.

| n  | prime? | min ⎮det⎮ over all minors | attained at |
|----|--------|---------------------------|-------------|
| 2  | prime      | 1        | k=1 |
| 3  | prime      | 1        | k=1 |
| 4  | composite  | **0**    | k=2, S=T={0,2} |
| 5  | prime      | 1        | k=1 |
| 6  | composite  | **0**    | k=2, S={0,2}, T={0,3} |
| 7  | prime      | 0.867767 | k=2, S={1,3}, T={2,5} |
| 8  | composite  | **0**    | k=2, S={0,2}, T={0,4} |
| 9  | composite  | **0**    | k=2, S={0,3}, T={0,3} |
| 11 | prime      | 0.316145 | k=4, S={2,5,6,9}, T={1,4,7,10} |

The minimum is bounded away from `0` exactly at the primes; every composite modulus produces a
genuinely singular minor, always of the "subgroup / coset" shape.  This is the numerical shadow of
Chebotarev's theorem, formalised as `Chebotarev.det_pow_ne_zero`, and of its failure for composite
moduli, formalised in the concrete case `n = 4` as
`FourierCyclic.uncertainty_sum_fails_at_four`.

## 2. Is the bound `|supp f| + |supp f̂| ≥ n + 1` attained for every sparsity?

For each prime `p` and each `k` we built the extremal signal predicted by the theory: take
`A = {0,…,k-1}` as the spatial support and force the transform to vanish at the `k-1`
frequencies `{0,…,k-2}`; the resulting homogeneous system has a nonzero kernel vector `f`.
Measured supports:

| p  | (k, ⎮supp f⎮, ⎮supp f̂⎮) for k = 1 … p |
|----|----------------------------------------|
| 5  | (1,1,5) (2,2,4) (3,3,3) (4,4,2) (5,5,1) |
| 7  | (1,1,7) (2,2,6) (3,3,5) (4,4,4) (5,5,3) (6,6,2) (7,7,1) |
| 11 | (1,1,11) … (6,6,6) … (11,11,1) |
| 13 | (1,1,13) … (7,7,7) … (13,13,1) |

In every single instance `|supp f| + |supp f̂| = p + 1` exactly, and the spatial support came out
*full* (`= k`, no accidental cancellation), which is precisely the phenomenon proved in
`FourierCyclic.exists_supp_eq_of_card_add_card`.

## 3. Counterexample hunt for the additive bound

No violation of `|supp f| + |supp f̂| ≥ p + 1` was found for prime `p ≤ 13` in the searches above,
and the failure mode at composite `n` is always a subgroup indicator: for `n = 4`,
`f = 1_{\{0,2\}}` gives `f̂ = 2·1_{\{0,2\}}`, hence `2 + 2 = 4 < 5`, while the multiplicative bound
`2·2 ≥ 4` survives.  This is the boundary case proved in Lean.

## 4. Separation between the sum and the product bound

The product bound allows `|supp f| = |supp f̂| ≈ √p`; the sum bound forbids it.  The smallest
prime where the two disagree with equal supports is `p = 13`, `|supp f| = |supp f̂| = 4`
(`16 ≥ 13` but `8 < 14`), which is the regime excluded by
`FourierCyclic.uncertainty_sum_strictly_stronger`.

## Addendum (later cycles): the composite defect `min_{d ∣ n} (d + n/d)`

For each `n` the subgroup indicator of `d · ZMod n` (with `n = d · e`) has
`|supp f| + |supp f̂| = e + d`, so `min_{d ∣ n, d < n} (d + n/d)` is a *proved* upper bound for
the uncertainty minimum on `ZMod n` (this is the content of
`FourierCyclic.dftZMod_subgroupIndicator`; the divisor `d = 1` recovers the Dirac delta and the
value `n + 1`).  Tabulating that quantity:

| n  | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 |
|----|---|---|---|---|---|---|---|---|----|----|----|----|----|----|----|----|----|
| min| 3 | 4 | 4 | 6 | 5 | 8 | 6 | 6 | 7  | 12 | 7  | 14 | 9  | 8  | 8  | 18 | 9  |

The value is `n + 1` exactly at the primes `2, 3, 5, 7, 11, 13, 17` and strictly smaller at every
composite — matching `FourierCyclic.uncertainty_sum_iff_prime`, which is the Lean-verified
statement that the additive bound holds for all nonzero signals precisely when `n` is prime.
Whether this upper bound is also the exact minimum for composite `n` is left open as Direction 2
of `FUTURE_DIRECTIONS.md`; the table above is an arithmetic evaluation of the divisor formula, not
a verified computation of the true minimum.
