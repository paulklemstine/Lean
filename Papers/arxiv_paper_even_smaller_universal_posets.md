# Computational Evidence

## Small cases

For an n-point antichain, each principal label is a singleton. For an n-point chain `0 < 1 < ··· < n-1`, the labels are the nested initial segments of cardinalities `1, 2, …, n`. In both families, label inclusion agrees exactly with the source order.

The canonical Boolean host sizes for `n = 0,1,2,3,4,5,6` are respectively:

| n | host size `2^n` |
|---:|---:|
| 0 | 1 |
| 1 | 2 |
| 2 | 4 |
| 3 | 8 |
| 4 | 16 |
| 5 | 32 |
| 6 | 64 |

For comparison, the asymptotic target exponent in the motivating result approaches `n/2`, suggesting square-root-scale compression relative to the canonical host.

## OEIS search

The host-size sequence is the powers of two, OEIS A000079: `1, 2, 4, 8, 16, 32, 64, …`.

## Counterexample hunt

The reflection argument was checked against the two extremal order shapes above and against the diamond order. No counterexample can occur: if the label of x is included in the label of y, reflexivity places x in its own principal label, and inclusion therefore forces `x ≤ y`. Conversely, transitivity forces label inclusion whenever `x ≤ y`.

A stronger compression claim was deliberately not inferred from these cases. Small examples provide no evidence for the regularity estimates needed to obtain the asymptotic `2^((1+η)n/2)` host.

## Structural table

| source operation or relation | Boolean-label counterpart |
|---|---|
| `x ≤ y` | `principalLabel x ⊆ principalLabel y` |
| `x = y` | equal labels |
| `x ⊓ y` | intersection of labels |
| order isomorphism | inverse-image transport of labels |
