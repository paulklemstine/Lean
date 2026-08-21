# Computational evidence for the single-voter exchange programme

All numbers below were produced by `#eval` inside Lean 4 (exact rational
arithmetic, `ℚ`), using a brute-force re-implementation of the min-plus
aggregator

```
agg δ x = min_k (δ k + x k),      dec δ x = { k | δ k + x k = agg δ x }
```

on lists.  These runs are *exploratory*: they guided the statements, they are
not proofs.  Every claim they support is proved independently and without
`sorry` in `Catalog/Pythagorean/ExchangeLawSharp.lean`,
`Catalog/Pythagorean/ExchangeGallery.lean` and
`Catalog/Pythagorean/ExchangeRigidity.lean`.

## 1. The sharp exchange trichotomy (four voters)

Weights `δ = (0, 1, 5/2, 3)`, neutral profile `x = (0,0,0,0)`.

| computation | value |
|---|---|
| `agg δ x` | `0` |
| `dec δ x` | `{0}` — voter 0 is the incumbent |
| exchange thresholds `θ_j = x₀ + δ₀ − δ_j`, `j = 1,2,3` | `−1, −5/2, −3` |
| `dec δ (update x 2 (−5/2))` | `{0, 2}` — exactly the wall |
| `dec δ (update x 2 (−5/2 − 1/10))` | `{2}` — open cell of the challenger |
| `dec δ (update x 2 (−5/2 + 1/10))` | `{0}` — incumbent survives |

This is exactly the trichotomy `c < θ` / `c = θ` / `c > θ` proved as
`decisiveSet_update_eq_singleton_iff`, `exchange_wall_iff` and
`mem_decisiveSet_update_incumbent_iff`.  No sample violated it.

## 2. Coalition exchanges

Same weights, target coalition `T = {1, 3}`.

| computation | value |
|---|---|
| `dec δ (coalition exchange onto T with ε = 1/2)` | `{1, 3}` = `T` |
| `dec δ (coalition exchange onto T with ε = 0)` | `{0, 1, 3}` = `T ∪ dec δ x` |

matching `decisiveSet_coalitionExchange` and
`decisiveSet_coalitionExchange_wall`.

## 3. Pythagorean weights `(3, 4, 5)`

| computation | value |
|---|---|
| `dec [3,4,5] (0,0,0)` | `{0}` — the hypotenuse voter is never decisive at the neutral profile |
| `dec [3,4,5] (0,0,−2)` | `{0, 2}` — the wall is reached at exchange size exactly `c − a = 2` |
| `dec [3,4,5] (0,0,−2−1/100)` | `{2}` |

matching `pythagorean_exchange_gap` and `pythagorean_exchange_345`.  The gap
`c − a > 0` is forced by `a² + b² = c²` with `a, b > 0` (`leg_lt_hyp`).

## 4. Counting the cells: `f`-vector and Euler characteristic

Number of cells `2ⁿ − 1` for `n = 1, …, 7`:

```
1, 3, 7, 15, 31, 63, 127
```

(OEIS A000225, "Mersenne numbers" — the count of nonempty subsets of an
`n`-set.)  The `f`-vector for `n = 4`, cells by codimension `d = 0,1,2,3`:

```
4, 6, 4, 1        (= choose 4 (d+1))
```

Alternating sums `Σ_d (−1)^d · choose n (d+1)` for `n = 1, …, 7`:

```
1, 1, 1, 1, 1, 1, 1
```

confirming `euler_characteristic_eq_one` (the complex is Euler-contractible)
and `card_labels_of_card`.

## 5. Counterexample hunt

* **Is the exchange lower bound true for arbitrary (non-downward) moves?**  No.
  Two voters, `δ = (0, 1)`, `x = (0,0)` has label `{0}`; raising the incumbent's
  own score to `y = (2, 0)` gives label `{1}` while voter `1` never moves.  This
  counterexample was found in the exploratory runs and is now *proved* in Lean as
  `exchange_lower_bound_fails_for_raises`, which is why the exchange metric
  theorems carry the hypothesis `∀ k, y k ≤ x k`.
* **Does the update formula `F(update x j c) = min (c + δ j) (x i + δ i)` need
  `j ∈ S`?**  Yes: a voter outside the support is invisible, and for very small
  `c` the two sides differ.  The first draft of the statement omitted `j ∈ S`
  and was rejected during formalization; the hypothesis is now present.
* No counterexample was found to any statement that appears as a theorem in the
  three Lean files.
