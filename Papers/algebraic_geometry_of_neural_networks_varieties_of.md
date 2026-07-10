# Computational Evidence: Tropical Structure of Decision Boundaries

Concise numerical support for the two growth laws proved in
`DecisionBoundaryVarieties.lean`.

## 1. Monomial counts: addition under activation

A tropical polynomial with `k` monomials, passed through a rectified-linear
activation of a rational `p ⊖ q` (with `|p| = k`, `|q| = m`), yields a numerator
`max(p,q)` with `k + m` monomials. Small cases:

| `|p|` | `|q|` | numerator `|max(p,q)|` (= `k+m`) |
|------:|------:|--------------------------------:|
|   1   |   1   |               2                 |
|   2   |   1   |               3                 |
|   2   |   2   |               4                 |
|   3   |   2   |               5                 |

This matches `Fintype.card (ι ⊕ κ) = card ι + card κ` (`relu_numerator_card`).

## 2. Depth doubling: the `2^L` envelope

Iterating "at most double per layer" from a single input piece:

| depth `L` | max monomials `2^L` |
|----------:|--------------------:|
|     0     |          1          |
|     1     |          2          |
|     2     |          4          |
|     3     |          8          |
|     4     |         16          |

This is the content of `layer_count_le_pow_two`.

## 3. Width product: the `∏ w_i` region count

Combining independent tropical factors of widths `w_i` via the tropical product
gives exactly `∏ w_i` monomials:

| widths `(w_1,…)` | `∏ w_i` |
|------------------|--------:|
| (2, 3)           |    6    |
| (2, 2, 2)        |    8    |
| (3, 3)           |    9    |
| (2, 3, 4)        |   24    |

This is `tropProduct_card_eq_prod` (via `Fintype.card_pi`).

## 4. Boundary sanity check (1-D ReLU unit)

For `f(x) = ReLU(x) = max(x, 0)`, realized as a two-monomial tropical polynomial:
- monomials: `0` (slope 0) and `x` (slope 1);
- decision boundary `{x : max(x,0) = 0} = (-∞, 0]` has its non-smooth vertex at
  `x = 0`, where both monomials tie — exactly the argmax-multiplicity condition
  predicted for singular points.

This concrete unit is verified in the file's `example`.

## Counterexample hunt

The two growth laws are stated as *exact equalities* of piecewise linear
functions (`tropVal_max`, `tropVal_add`), so no counterexample is possible; the
`2^L` and `∏ w_i` statements are upper bounds and lower-bound tightness is left
as Conjecture 1 in `FUTURE_DIRECTIONS.md`. No violating instance was found in the
finite sweeps above.
