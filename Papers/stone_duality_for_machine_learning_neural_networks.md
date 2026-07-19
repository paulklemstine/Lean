# Computational evidence

## Small cases

The certified calculations are in `ComputationalExamples.lean`.

| gates | activation map | formal patterns | feasible patterns |
|---:|---|---:|---:|
| 0 | any map from a nonempty finite input type | 1 | 1 |
| 2 | identity on `Fin 2 → Bool` | 4 | 4 |
| 2 | both gates copy one Boolean input | 4 | 2 |

Thus `2^k` is an upper bound, not an unconditional equality. Equality holds exactly when the activation map is surjective, as proved in `feasible_card_eq_pow_iff`.

## Counterexample hunt

The duplicated-gate example is a counterexample to the claim that a network with two neurons always has four activation patterns. The stronger one-point construction in `two_gates_not_always_four` also gives a certified counterexample.

A second conceptual counterexample is proved in `singleton_concept_not_shatter_nonempty`: one fixed classifier (one decision region) cannot shatter any nonempty set. Consequently, its VC dimension cannot equal a positive number of linear regions. VC dimension applies to a parameterized family of classifiers. The full powerset family on a finite feasible-pattern space does have VC dimension equal to the number of feasible patterns, proved by `powerset_vc_exact`.

## OEIS search

The formal-pattern counts are powers of two, `1, 2, 4, 8, ...` (OEIS A000079). No new sequence search was needed: feasible counts depend on the activation map and can range below this upper bound.

## Plots

No plot is informative for these finite cardinality examples; the table gives the complete small cases used by the formal development.
