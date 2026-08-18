# Computational evidence

All numbers below were produced by `#eval` inside this Lean project (a scratch
module, since removed) using `Float` arithmetic.  They are *numerical
exploration*, not verified facts: the verified statements are the theorems in
`Catalog/Novelty/`, listed at the end.

## 1. The Shtarkov sum of the memoryless binary class

For block length `n`, the exact minimax pointwise regret of the class of
memoryless binary sources is `log₂ Sₙ` with

```
Sₙ = ∑_{k=0}^{n} C(n,k) · (k/n)^k · ((n−k)/n)^{n−k}
```

(the `k = 0` and `k = n` terms use `0^0 = 1`).  Computed values, together with
the two bounds proved in this project and the classical asymptotic
`√(πn/2)`:

| n  | Sₙ (computed) | proved lower bd √n/4 | √(πn/2) | proved upper bd n+1 |
|----|---------------|----------------------|---------|---------------------|
| 8  | 4.2450        | 0.7071               | 3.5449  | 9                   |
| 16 | 5.7043        | 1.0000               | 5.0133  | 17                  |
| 24 | 6.8268        | 1.2247               | 6.1400  | 25                  |
| 32 | 7.7740        | 1.4142               | 7.0898  | 33                  |
| 40 | 8.6091        | 1.5811               | 7.9267  | 41                  |
| 48 | 9.3644        | 1.7321               | 8.6832  | 49                  |
| 56 | 10.0591       | 1.8708               | 9.3789  | 57                  |
| 64 | 10.7058       | 2.0000               | 10.0265 | 65                  |
| 72 | 11.3133       | 2.1213               | 10.6347 | 73                  |
| 80 | 11.8880       | 2.2361               | 11.2100 | 81                  |
| 88 | 12.4346       | 2.3452               | 11.7571 | 89                  |
| 96 | 12.9569       | 2.4495               | 12.2799 | 97                  |

Observations:

* `Sₙ` tracks `√(πn/2) + 2/3` very closely (e.g. `n = 96`: `12.2799 + 0.667 =
  12.947` versus the computed `12.957`), matching the classical expansion of the
  binomial Shtarkov sum.  This is the numerical signature of the Rissanen rate
  `log₂ Sₙ = (1/2) log₂ n + O(1)`.
* The proved lower bound `√n/4` is correct but loose by a constant factor of
  about `5` (it comes from a Chebyshev argument with slack `3/4` per window and
  windows of half-width `⌈√n⌉`).  Only the *rate* — the coefficient `1/2` in
  front of `log₂ n` — is asymptotically sharp.
* The proved upper bound `n + 1` is a factor `√n` off; closing this to `O(√n)`
  is Conjecture 1 of `FUTURE_DIRECTIONS.md`.

## 2. Counterexample hunt

The two structural claims of the project were tested for counterexamples before
being proved:

* *Multiplicativity of the Shtarkov sum.* For product classes built from small
  random families (`|A| = |B| = 3`, `|Θ| = |Ψ| = 2`) the identity
  `S(P ⊗ Q) = S(P)·S(Q)` held exactly; no counterexample exists, and the identity
  is now proved (`shtarkov_prodClass`).
* *`S ≥ 1` with equality iff the class is a single source.* Confirmed on small
  families and proved as `one_le_shtarkov`.
* *Disjointly supported classes.* For `m` deterministic sources on `m` letters,
  `S = m` exactly, matching `shtarkov_disjointSupports`.

No counterexample to any conjecture that was subsequently formalised was found.

## 3. What is actually verified in Lean (0 sorries)

* `redundancy_nonneg`, `exists_code_redundancy_le_one` — Shannon bounds.
* `kl_compensation`, `exists_source_redundancy_ge_mutualInfo`,
  `price_of_universality_sandwich` — average-case price of universality.
* `minimax_regret_eq_logb_shtarkov`, `shtarkov_disjointSupports` — exact
  worst-case price.
* `shtarkov_bernClass_ge_sqrt`, `bernoulli_regret_ge_half_logb`,
  `bernoulli_regret_two_sided` — the Rissanen-style rate.
* `shtarkov_prodClass`, `two_block_bernoulli_regret` — additivity over
  independent components.
* `price_of_specialisation`, `exists_length_ge_logb_card` — the value of
  specialisation and the pigeonhole form of the bound.
